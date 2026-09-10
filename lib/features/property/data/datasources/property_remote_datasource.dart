import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/errors/security_exceptions.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/local_storage.dart';
import '../../domain/entities/property_entities.dart';
import '../../utils/location_privacy_helper.dart';
import '../../utils/owner_identity_bridge.dart';
import '../../utils/property_security_guard.dart';
import '../../utils/property_unlock_guard.dart';
import '../models/property_models.dart';

String _generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40; // version 4
  values[8] = (values[8] & 0x3f) | 0x80; // variant
  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
}

bool _isValidUuid(String id) {
  return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id);
}

abstract class PropertyRemoteDataSource {
  Future<List<PropertyModel>> fetchProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  });

  Future<List<PropertyModel>> fetchPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  });

  Future<List<PropertyModel>> fetchAllPropertiesForAdmin({
    required String authenticatedUserId,
    UserRole? userRole,
    int limit = 100,
    int offset = 0,
  });

  Future<PropertyEntity?> fetchPropertyById(
    String id, {
    String? requestingUserId,
    List<PropertyUnlockEntity>? userUnlocks,
  });

  Future<PropertyModel> createProperty(
    PropertyModel property, {
    required String authenticatedUserId,
  });

  Future<PropertyModel> updateProperty(
    PropertyModel property, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<PropertyModel> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<PropertyModel> setPropertyPaused({
    required String propertyId,
    required bool isPaused,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<void> deleteProperty(
    String id, {
    required String authenticatedUserId,
    UserRole? userRole,
  });
}

@LazySingleton(as: PropertyRemoteDataSource)
class PropertyRemoteDataSourceImpl extends BaseRemoteDataSource
    implements PropertyRemoteDataSource {
  final SupabaseService _supabaseService;
  final LocalStorage? _localStorage;

  static const String _kLocalPropertiesKey = 'local_properties_vault';

  PropertyRemoteDataSourceImpl(
    this._supabaseService, [
    this._localStorage,
  ]);

  Future<List<PropertyModel>> _loadLocalProperties() async {
    try {
      final storage = _localStorage ?? LocalStorage();
      final raw = storage.get(_kLocalPropertiesKey);
      if (raw == null) return [];
      final List<dynamic> decoded = raw is String ? jsonDecode(raw) : (raw as List);
      return decoded.map((item) => PropertyModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalProperties(List<PropertyModel> properties) async {
    try {
      final storage = _localStorage ?? LocalStorage();
      final serialized = properties.map((p) => p.toJson()).toList();
      await storage.put(_kLocalPropertiesKey, jsonEncode(serialized));
    } catch (_) {}
  }

  Future<void> _upsertLocalProperty(PropertyModel property) async {
    try {
      final current = await _loadLocalProperties();
      final idx = current.indexWhere((p) => p.id == property.id);
      if (idx >= 0) {
        current[idx] = property;
      } else {
        current.insert(0, property);
      }
      await _saveLocalProperties(current);
    } catch (_) {}
  }

  @override
  Future<List<PropertyModel>> fetchProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeQuery(() async {
      List<PropertyModel> remoteModels = [];
      if (_supabaseService.isInitialized) {
        // Use properties_public view to guarantee physical column-level protection of address/contacts
        var query = _supabaseService.from('properties_public').select('*, property_media(*)');
        query = query.eq('status', ListingStatus.active.dbValue);
        query = query.eq('is_paused', false);

        // Expiry Guard: Exclude expired listings from public discovery.
        // Grandfathered listings are always immune.
        final nowIso = DateTime.now().toUtc().toIso8601String();
        query = query.or('is_grandfathered.eq.true,listing_expires_at.is.null,listing_expires_at.gt.$nowIso');

        if (category != null) query = query.eq('category', category.dbValue);
        if (type != null) query = query.eq('type', type.dbValue);
        if (city != null) query = query.eq('city', city);
        if (locality != null) query = query.eq('locality', locality);
        if (minPrice != null) query = query.gte('price', minPrice);
        if (maxPrice != null) query = query.lte('price', maxPrice);

        final response = await query
            .order('is_featured', ascending: false)
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);
        remoteModels = (response as List)
            .map((json) => PropertyModel.fromJson(json))
            .where((m) => m.isPubliclyVisibleNow)
            .toList();
      }

      lastRemoteFetchSucceeded = true;
      lastRemotePropertyIds = remoteModels.map((p) => p.id).toSet();

      // Public marketplace is 100% central backend authoritative from Supabase
      return remoteModels
          .map((m) => LocationPrivacyHelper.toPublicPropertyModel(m))
          .toList();
    });
  }

  static bool lastFetchProfileResolved = false;
  static bool lastRemoteFetchSucceeded = false;
  static String? lastFetchDiagnosticReason;
  static Set<String> lastRemotePropertyIds = {};

  /// Resolves Supabase profile UUID from Firebase UID, auto-provisioning if missing
  Future<String?> _resolveOrCreateProfileUuid(String firebaseUid) async {
    if (!_supabaseService.isInitialized || firebaseUid.isEmpty) return null;

    // 1. If already a valid UUID, return directly
    if (_isValidUuid(firebaseUid)) return firebaseUid;

    // 2. Query existing profile in public.profiles by firebase_uid
    try {
      final profileResp = await _supabaseService
          .from('profiles')
          .select('id')
          .eq('firebase_uid', firebaseUid)
          .maybeSingle();
      if (profileResp != null && profileResp['id'] != null) {
        final profileId = profileResp['id'] as String;
        if (_isValidUuid(profileId)) {
          OwnerIdentityBridge.registerMapping(firebaseUid: firebaseUid, profileId: profileId);
          return profileId;
        }
      }
    } catch (e) {
      AppLogger.w('[PropertyRemoteDS] Existing profile select error: $e');
    }

    // 3. Auto-provision profile row in Supabase if not yet created
    try {
      final fbUser = FirebaseAuth.instance.currentUser;
      final phone = fbUser?.phoneNumber;
      final email = fbUser?.email;
      final name = fbUser?.displayName ?? (email != null && email.contains('@') ? email.split('@')[0] : 'Belagavi Property User');

      final newProfileMap = <String, dynamic>{
        'firebase_uid': firebaseUid,
        'full_name': name,
        'phone_number': (phone != null && phone.isNotEmpty) ? phone : '+919113219906',
        if (email != null && email.isNotEmpty) 'email': email,
        'role': 'buyer',
      };

      final inserted = await _supabaseService
          .from('profiles')
          .insert(newProfileMap)
          .select('id')
          .maybeSingle();

      if (inserted != null && inserted['id'] != null) {
        final newId = inserted['id'] as String;
        OwnerIdentityBridge.registerMapping(firebaseUid: firebaseUid, profileId: newId);
        AppLogger.i('[PropertyRemoteDS] Successfully provisioned profile UUID: $newId for firebase_uid: $firebaseUid');
        return newId;
      }
    } catch (e) {
      AppLogger.e('[PropertyRemoteDS] Profile auto-provisioning failed: $e');
    }

    return null;
  }

  @override
  Future<List<PropertyModel>> fetchPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) async {
    return safeQuery(() async {
      List<PropertyModel> remoteModels = [];
      bool profileResolved = false;
      bool remoteFetchedSuccess = false;
      Set<String> remoteIds = {};
      String? diagReason;

      if (_supabaseService.isInitialized) {
        final profileId = await _resolveOrCreateProfileUuid(ownerId);
        if (profileId != null && profileId.isNotEmpty) {
          profileResolved = true;
          try {
            final response = await _supabaseService
                .from('properties')
                .select('*, property_media(*)')
                .eq('owner_id', profileId)
                .order('created_at', ascending: false)
                .range(offset, offset + limit - 1);
            remoteModels = (response as List).map((json) => PropertyModel.fromJson(json)).toList();
            remoteFetchedSuccess = true;
            remoteIds = remoteModels.map((p) => p.id).toSet();
            diagReason = 'REMOTE_SUCCESS (${remoteModels.length} properties)';
            AppLogger.i('[PropertyRemoteDS] fetchPropertiesByOwner authenticated=true profileResolved=true returned=${remoteModels.length}');
          } catch (e) {
            diagReason = 'QUERY_ERROR: $e';
            AppLogger.e('[PropertyRemoteDS] fetchPropertiesByOwner remote query error: $e');
          }
        } else {
          diagReason = 'PROFILE_NOT_RESOLVED';
          AppLogger.w('[PropertyRemoteDS] fetchPropertiesByOwner: Could not resolve or provision profile for ownerId: $ownerId');
        }
      } else {
        diagReason = 'SUPABASE_NOT_INITIALIZED';
      }

      lastFetchProfileResolved = profileResolved;
      lastRemoteFetchSucceeded = remoteFetchedSuccess;
      lastFetchDiagnosticReason = diagReason;
      lastRemotePropertyIds = remoteIds;

      // Merge locally created properties for this owner
      final local = await _loadLocalProperties();
      final localForOwner = local.where((p) => p.ownerId == ownerId || ownerId.isEmpty).toList();

      final existingIds = remoteModels.map((p) => p.id).toSet();
      final merged = <PropertyModel>[...remoteModels];
      for (final lp in localForOwner) {
        if (!existingIds.contains(lp.id)) {
          merged.add(lp);
          existingIds.add(lp.id);
        }
      }

      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return merged;
    });
  }

  @override
  Future<List<PropertyModel>> fetchAllPropertiesForAdmin({
    required String authenticatedUserId,
    UserRole? userRole,
    int limit = 100,
    int offset = 0,
  }) async {
    return safeQuery(() async {
      PropertySecurityGuard.verifyPropertyOwnership(
        authenticatedUserId: authenticatedUserId,
        ownerId: authenticatedUserId,
        userRole: userRole,
        actionName: 'view all properties as admin',
      );

      List<PropertyModel> remoteModels = [];
      if (_supabaseService.isInitialized) {
        final response = await _supabaseService
            .from('properties')
            .select('*, property_media(*)')
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
        remoteModels = (response as List).map((json) => PropertyModel.fromJson(json)).toList();
      }

      final local = await _loadLocalProperties();
      final existingIds = remoteModels.map((p) => p.id).toSet();
      final merged = <PropertyModel>[...remoteModels];
      for (final lp in local) {
        if (!existingIds.contains(lp.id)) {
          merged.add(lp);
          existingIds.add(lp.id);
        }
      }

      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return merged;
    });
  }

  @override
  Future<PropertyEntity?> fetchPropertyById(
    String id, {
    String? requestingUserId,
    List<PropertyUnlockEntity>? userUnlocks,
  }) async {
    return safeQuery(() async {
      PropertyEntity? rawProperty;
      if (_supabaseService.isInitialized) {
        final response =
            await _supabaseService.from('properties').select('*, property_media(*)').eq('id', id).maybeSingle();
        if (response != null) {
          rawProperty = PropertyModel.fromJson(response);
        }
      }

      if (rawProperty == null) {
        final local = await _loadLocalProperties();
        final match = local.where((p) => p.id == id);
        if (match.isNotEmpty) {
          rawProperty = match.first;
        }
      }

      if (rawProperty == null) return null;

      // Check visibility permissions for non-public listings
      if (!PropertySecurityGuard.canViewProperty(
        status: rawProperty.status,
        ownerId: rawProperty.ownerId,
        requestingUserId: requestingUserId,
      )) {
        return null;
      }

      final unlocked = PropertyUnlockGuard.isUnlocked(
        requestingUserId: requestingUserId,
        property: rawProperty,
        userUnlocks: userUnlocks ?? const [],
      );

      if (unlocked) {
        return rawProperty;
      } else {
        return LocationPrivacyHelper.toPublicPropertyEntity(rawProperty);
      }
    });
  }

  @override
  Future<PropertyModel> createProperty(
    PropertyModel property, {
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      PropertySecurityGuard.verifyPropertyOwnership(
        authenticatedUserId: authenticatedUserId,
        ownerId: property.ownerId,
        actionName: 'create property',
      );

      final String effectiveId = _isValidUuid(property.id) ? property.id : _generateUuidV4();
      var propertyWithId = property.copyWith(id: effectiveId);

      // 1. Immediately persist locally
      await _upsertLocalProperty(propertyWithId);

      if (!_supabaseService.isInitialized) {
        return propertyWithId;
      }

      String targetOwnerId = propertyWithId.ownerId;
      final resolvedProfileUuid = await _resolveOrCreateProfileUuid(authenticatedUserId);
      if (resolvedProfileUuid != null && _isValidUuid(resolvedProfileUuid)) {
        targetOwnerId = resolvedProfileUuid;
      }

      final payload = propertyWithId.copyWith(ownerId: targetOwnerId).toDatabaseJson();
      payload['id'] = effectiveId;

      final response =
          await _supabaseService.from('properties').insert(payload).select().single();
      var created = PropertyModel.fromJson(response);

      // Insert media list into property_media table if present
      if (property.mediaList.isNotEmpty) {
        try {
          final mediaPayloads = property.mediaList.map((m) {
            final mediaUuid = _isValidUuid(m.id) ? m.id : _generateUuidV4();
            return {
              'id': mediaUuid,
              'property_id': created.id,
              'media_url': m.mediaUrl,
              'type': m.type.name,
              'display_order': m.displayOrder,
              'is_cover': m.isCover,
              'caption': m.caption,
              'created_at': (m.uploadedAt ?? DateTime.now()).toIso8601String(),
            };
          }).toList();
          await _supabaseService.from('property_media').insert(mediaPayloads);
        } catch (e) {
          AppLogger.w('Failed to insert property_media rows: $e');
        }
      }

      created = created.copyWith(mediaList: property.mediaList);
      await _upsertLocalProperty(created);
      return created;
    });
  }

  @override
  @override
  Future<PropertyModel> updateProperty(
    PropertyModel property, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      AppLogger.i('[PropertyRemoteDS] updateProperty initiating for propId=${property.id}');
      String targetOwnerId = property.ownerId;
      final resolvedProfileUuid = await _resolveOrCreateProfileUuid(authenticatedUserId);
      if (resolvedProfileUuid != null && _isValidUuid(resolvedProfileUuid)) {
        targetOwnerId = resolvedProfileUuid;
      }

      PropertyModel? existing;
      if (_supabaseService.isInitialized) {
        final resp = await _supabaseService
            .from('properties')
            .select('*, property_media(*)')
            .eq('id', property.id)
            .maybeSingle();
        if (resp != null) {
          existing = PropertyModel.fromJson(resp);
        }
      }
      if (existing == null) {
        final local = await _loadLocalProperties();
        final match = local.where((p) => p.id == property.id);
        if (match.isNotEmpty) existing = match.first;
      }

      if (existing != null) {
        await PropertySecurityGuard.verifyPropertyUpdateAsync(
          existingOwnerId: existing.ownerId,
          updatedOwnerId: existing.ownerId,
          currentUserId: authenticatedUserId,
          userRole: userRole,
          currentStatus: existing.status,
          targetStatus: property.status,
        );
      } else {
        await PropertySecurityGuard.verifyPropertyOwnershipAsync(
          authenticatedUserId: authenticatedUserId,
          ownerId: property.ownerId,
          userRole: userRole,
          actionName: 'update property',
        );
      }

      await _upsertLocalProperty(property.copyWith(ownerId: targetOwnerId));

      if (!_supabaseService.isInitialized) {
        return property.copyWith(ownerId: targetOwnerId);
      }

      final payload = property.copyWith(ownerId: targetOwnerId).toDatabaseJson();

      final existingRemote = await _supabaseService
          .from('properties')
          .select('id')
          .eq('id', property.id)
          .maybeSingle();

      dynamic response;
      if (existingRemote == null) {
        payload['id'] = property.id;
        response = await _supabaseService
            .from('properties')
            .insert(payload)
            .select()
            .single();
      } else {
        response = await _supabaseService
            .from('properties')
            .update(payload)
            .eq('id', property.id)
            .select()
            .single();
      }
      var updated = PropertyModel.fromJson(response);

      // Synchronize property_media table
      try {
        if (existingRemote != null) {
          final currentMediaUuids = property.mediaList
              .where((m) => _isValidUuid(m.id))
              .map((m) => m.id)
              .toList();

          if (currentMediaUuids.isNotEmpty) {
            await _supabaseService
                .from('property_media')
                .delete()
                .eq('property_id', property.id)
                .not('id', 'in', '(${currentMediaUuids.join(",")})');
          } else {
            await _supabaseService
                .from('property_media')
                .delete()
                .eq('property_id', property.id);
          }
        }

        for (final m in property.mediaList) {
          final mediaUuid = _isValidUuid(m.id) ? m.id : _generateUuidV4();
          final mediaPayload = {
            'id': mediaUuid,
            'property_id': property.id,
            'media_url': m.mediaUrl,
            'type': m.type.name,
            'display_order': m.displayOrder,
            'is_cover': m.isCover,
            'caption': m.caption,
            'created_at': (m.uploadedAt ?? DateTime.now()).toIso8601String(),
          };
          await _supabaseService.from('property_media').upsert(mediaPayload);
        }
      } catch (e) {
        AppLogger.w('Failed to synchronize property_media rows: $e');
      }

      updated = updated.copyWith(mediaList: property.mediaList);
      await _upsertLocalProperty(updated);
      AppLogger.i('[PropertyRemoteDS] updateProperty SUCCESS for propId=${property.id}');
      return updated;
    });
  }

  @override
  Future<PropertyModel> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      AppLogger.i('[PropertyRemoteDS] updatePropertyStatus initiating: id=$propertyId, newStatus=${newStatus.name}');
      PropertyModel? existing;
      if (_supabaseService.isInitialized) {
        final resp = await _supabaseService
            .from('properties')
            .select('*, property_media(*)')
            .eq('id', propertyId)
            .maybeSingle();
        if (resp != null) {
          existing = PropertyModel.fromJson(resp);
        }
      }
      if (existing == null) {
        final local = await _loadLocalProperties();
        final match = local.where((p) => p.id == propertyId);
        if (match.isNotEmpty) existing = match.first;
      }

      if (existing == null) {
        AppLogger.e('[PropertyRemoteDS] updatePropertyStatus FAILED: Target property not found: $propertyId');
        throw const AccessDeniedException('Target property not found.');
      }

      await PropertySecurityGuard.verifyPropertyUpdateAsync(
        existingOwnerId: existing.ownerId,
        updatedOwnerId: existing.ownerId,
        currentUserId: authenticatedUserId,
        userRole: userRole,
        currentStatus: existing.status,
        targetStatus: newStatus,
      );

      final updatedLocal = existing.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await _upsertLocalProperty(updatedLocal);

      if (!_supabaseService.isInitialized) {
        return updatedLocal;
      }

      final response = await _supabaseService
          .from('properties')
          .update({
            'status': newStatus.dbValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId)
          .select()
          .single();

      final updated = PropertyModel.fromJson(response);
      await _upsertLocalProperty(updated);
      AppLogger.i('[PropertyRemoteDS] updatePropertyStatus SUCCESS: id=$propertyId, status=${newStatus.dbValue}');
      return updated;
    });
  }

  @override
  Future<PropertyModel> setPropertyPaused({
    required String propertyId,
    required bool isPaused,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      AppLogger.i('[PropertyRemoteDS] setPropertyPaused initiating: id=$propertyId, isPaused=$isPaused');
      PropertyModel? existing;
      if (_supabaseService.isInitialized) {
        final resp = await _supabaseService
            .from('properties')
            .select('*, property_media(*)')
            .eq('id', propertyId)
            .maybeSingle();
        if (resp != null) {
          existing = PropertyModel.fromJson(resp);
        }
      }
      if (existing == null) {
        final local = await _loadLocalProperties();
        final match = local.where((p) => p.id == propertyId);
        if (match.isNotEmpty) existing = match.first;
      }

      if (existing == null) {
        AppLogger.e('[PropertyRemoteDS] setPropertyPaused FAILED: Target property not found: $propertyId');
        throw const AccessDeniedException('Target property not found.');
      }

      await PropertySecurityGuard.verifyPropertyOwnershipAsync(
        authenticatedUserId: authenticatedUserId,
        ownerId: existing.ownerId,
        userRole: userRole,
        actionName: isPaused ? 'pause this listing' : 'resume this listing',
      );

      final updatedLocal = existing.copyWith(
        isPaused: isPaused,
        updatedAt: DateTime.now(),
      );

      await _upsertLocalProperty(updatedLocal);

      if (!_supabaseService.isInitialized) {
        return updatedLocal;
      }

      final response = await _supabaseService
          .from('properties')
          .update({
            'is_paused': isPaused,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId)
          .select()
          .single();

      final updated = PropertyModel.fromJson(response);
      await _upsertLocalProperty(updated);
      AppLogger.i('[PropertyRemoteDS] setPropertyPaused SUCCESS: id=$propertyId, isPaused=$isPaused');
      return updated;
    });
  }

  @override
  Future<void> deleteProperty(
    String id, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      AppLogger.i('[PropertyRemoteDS] deleteProperty initiating: id=$id');
      PropertyModel? existing;
      if (_supabaseService.isInitialized) {
        final resp = await _supabaseService
            .from('properties')
            .select('*, property_media(*)')
            .eq('id', id)
            .maybeSingle();
        if (resp != null) {
          existing = PropertyModel.fromJson(resp);
        }
      }
      if (existing == null) {
        final local = await _loadLocalProperties();
        final match = local.where((p) => p.id == id);
        if (match.isNotEmpty) existing = match.first;
      }

      if (existing == null) {
        AppLogger.e('[PropertyRemoteDS] deleteProperty FAILED: Target property not found: $id');
        throw const AccessDeniedException('Target property not found.');
      }

      await PropertySecurityGuard.verifyPropertyOwnershipAsync(
        authenticatedUserId: authenticatedUserId,
        ownerId: existing.ownerId,
        userRole: userRole,
        actionName: 'delete property',
      );

      final isAdmin = userRole != null && userRole.isAdminOrFounder;
      if (!isAdmin && existing.status == ListingStatus.disputed) {
        throw const AccessDeniedException(
          'Access Denied: Disputed listings cannot be deleted directly while under review.',
        );
      }

      // Supabase Storage Cleanup for property-media before removing DB row
      if (_supabaseService.isInitialized) {
        try {
          final storage = _supabaseService.storage('property-media');
          final storagePaths = <String>[];

          // Collect paths from property_media entities if available
          for (final media in existing.mediaList) {
            final uri = Uri.tryParse(media.mediaUrl);
            if (uri != null && uri.pathSegments.contains('property-media')) {
              final idx = uri.pathSegments.indexOf('property-media');
              if (idx + 1 < uri.pathSegments.length) {
                storagePaths.add(uri.pathSegments.sublist(idx + 1).join('/'));
              }
            }
          }

          // Also query directory objects for this property directly from storage
          try {
            final folderPrefix = '${existing.ownerId}/$id';
            final imageFiles = await storage.list(path: '$folderPrefix/images');
            for (final f in imageFiles) {
              storagePaths.add('$folderPrefix/images/${f.name}');
            }
            final docFiles = await storage.list(path: '$folderPrefix/documents');
            for (final f in docFiles) {
              storagePaths.add('$folderPrefix/documents/${f.name}');
            }
          } catch (_) {}

          if (storagePaths.isNotEmpty) {
            final distinctPaths = storagePaths.toSet().toList();
            AppLogger.i('[PropertyRemoteDS] Cleaning up ${distinctPaths.length} storage objects for property $id');
            await storage.remove(distinctPaths);
          }
        } catch (e) {
          AppLogger.w('[PropertyRemoteDS] Storage media cleanup warning: $e');
        }

        // Delete property row from database
        await _supabaseService.from('properties').delete().eq('id', id);
        AppLogger.i('[PropertyRemoteDS] Remote property row deleted for id=$id');
      }

      try {
        final local = await _loadLocalProperties();
        local.removeWhere((p) => p.id == id);
        await _saveLocalProperties(local);
      } catch (_) {}

      AppLogger.i('[PropertyRemoteDS] deleteProperty completed successfully for id=$id');
    });
  }
}

