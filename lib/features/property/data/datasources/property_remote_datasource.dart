import 'dart:convert';
import 'dart:math';
import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/errors/security_exceptions.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/local_storage.dart';
import '../../domain/entities/property_entities.dart';
import '../../utils/location_privacy_helper.dart';
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
        var query = _supabaseService.from('properties').select('*, property_media(*)');
        query = query.eq('status', ListingStatus.active.dbValue);

        if (category != null) query = query.eq('category', category.dbValue);
        if (type != null) query = query.eq('type', type.dbValue);
        if (city != null) query = query.eq('city', city);
        if (locality != null) query = query.eq('locality', locality);
        if (minPrice != null) query = query.gte('price', minPrice);
        if (maxPrice != null) query = query.lte('price', maxPrice);

        final response = await query.range(offset, offset + limit - 1);
        remoteModels = (response as List).map((json) => PropertyModel.fromJson(json)).toList();
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
  static Set<String> lastRemotePropertyIds = {};

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

      if (_supabaseService.isInitialized) {
        String effectiveOwnerId = ownerId;
        try {
          final profileResp = await _supabaseService
              .from('profiles')
              .select('id')
              .eq('firebase_uid', ownerId)
              .maybeSingle();
          if (profileResp != null && profileResp['id'] != null) {
            effectiveOwnerId = profileResp['id'] as String;
            profileResolved = true;
          }
        } catch (_) {}

        try {
          final response = await _supabaseService
              .from('properties')
              .select('*, property_media(*)')
              .eq('owner_id', effectiveOwnerId)
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
          remoteModels = (response as List).map((json) => PropertyModel.fromJson(json)).toList();
          remoteFetchedSuccess = true;
          remoteIds = remoteModels.map((p) => p.id).toSet();
          AppLogger.i('[PropertyRemoteDS] fetchPropertiesByOwner authenticated=true profileResolved=$profileResolved returned=${remoteModels.length}');
        } catch (e) {
          AppLogger.e('[PropertyRemoteDS] fetchPropertiesByOwner remote query error: $e');
        }
      }

      lastFetchProfileResolved = profileResolved;
      lastRemoteFetchSucceeded = remoteFetchedSuccess;
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

      final String effectiveId = property.id.isNotEmpty ? property.id : _generateUuidV4();
      var propertyWithId = property.copyWith(id: effectiveId);

      // 1. Immediately persist locally
      await _upsertLocalProperty(propertyWithId);

      if (!_supabaseService.isInitialized) {
        return propertyWithId;
      }

      String targetOwnerId = propertyWithId.ownerId;
      try {
        final profileResp = await _supabaseService
            .from('profiles')
            .select('id')
            .eq('firebase_uid', authenticatedUserId)
            .maybeSingle();
        if (profileResp != null && profileResp['id'] != null) {
          targetOwnerId = profileResp['id'] as String;
        }
      } catch (_) {}

      final payload = propertyWithId.copyWith(ownerId: targetOwnerId).toJson();
      if (property.id.isEmpty) {
        payload.remove('id'); // Allow Postgres default UUID generation if desired
      }

      final response =
          await _supabaseService.from('properties').insert(payload).select().single();
      var created = PropertyModel.fromJson(response);

      // Insert media list into property_media table if present
      if (property.mediaList.isNotEmpty) {
        try {
          final mediaPayloads = property.mediaList.map((m) => {
            'property_id': created.id,
            'media_url': m.mediaUrl,
            'type': m.type.name,
            'display_order': m.displayOrder,
            'is_cover': m.isCover,
            'caption': m.caption,
            'created_at': DateTime.now().toIso8601String(),
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
  Future<PropertyModel> updateProperty(
    PropertyModel property, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      final existing = await fetchPropertyById(property.id);
      if (existing != null) {
        PropertySecurityGuard.verifyPropertyUpdate(
          existingOwnerId: existing.ownerId,
          updatedOwnerId: property.ownerId,
          currentUserId: authenticatedUserId,
          userRole: userRole,
          currentStatus: existing.status,
          targetStatus: property.status,
        );
      } else {
        PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: authenticatedUserId,
          ownerId: property.ownerId,
          userRole: userRole,
          actionName: 'update property',
        );
      }

      await _upsertLocalProperty(property);

      if (!_supabaseService.isInitialized) {
        return property;
      }
      final response = await _supabaseService
          .from('properties')
          .update(property.toJson())
          .eq('id', property.id)
          .select()
          .single();
      final updated = PropertyModel.fromJson(response);
      await _upsertLocalProperty(updated);
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
      final existing = await fetchPropertyById(propertyId);
      if (existing == null) {
        throw const AccessDeniedException('Target property not found.');
      }

      PropertySecurityGuard.verifyPropertyUpdate(
        existingOwnerId: existing.ownerId,
        updatedOwnerId: existing.ownerId,
        currentUserId: authenticatedUserId,
        userRole: userRole,
        currentStatus: existing.status,
        targetStatus: newStatus,
      );

      final updatedLocal = PropertyModel(
        id: existing.id,
        ownerId: existing.ownerId,
        title: existing.title,
        description: existing.description,
        category: existing.category,
        type: existing.type,
        status: newStatus,
        verificationStatus: existing.verificationStatus,
        price: existing.price,
        isNegotiable: existing.isNegotiable,
        specifications: existing.specifications,
        mediaList: existing.mediaList,
        state: existing.state,
        district: existing.district,
        taluk: existing.taluk,
        city: existing.city,
        locality: existing.locality,
        address: existing.address,
        pincode: existing.pincode,
        latitude: existing.latitude,
        longitude: existing.longitude,
        viewsCount: existing.viewsCount,
        features: existing.features,
        createdAt: existing.createdAt,
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
      final existing = await fetchPropertyById(id);
      if (existing != null) {
        PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: authenticatedUserId,
          ownerId: existing.ownerId,
          userRole: userRole,
          actionName: 'delete property',
        );

        final isAdmin = userRole != null && userRole.isAdminOrFounder;
        if (!isAdmin && (existing.status == ListingStatus.disputed || existing.status == ListingStatus.sold)) {
          throw const AccessDeniedException(
            'Access Denied: Disputed or Sold listings cannot be deleted directly by customer.',
          );
        }
      } else {
        throw const AccessDeniedException('Target property not found.');
      }

      try {
        final local = await _loadLocalProperties();
        local.removeWhere((p) => p.id == id);
        await _saveLocalProperties(local);
      } catch (_) {}

      if (!_supabaseService.isInitialized) return;
      await _supabaseService.from('properties').delete().eq('id', id);
    });
  }
}

