import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/utils/app_logger.dart';

/// Universal Owner Identity Bridge for Belagavi Property
/// Resolves and verifies ownership between external Firebase Third-Party Auth identities
/// and internal Supabase PostgreSQL relational schemas.
///
/// Identity Mapping Architecture:
///   Firebase UID (String)
///   -> public.profiles.firebase_uid (TEXT UNIQUE)
///   -> public.profiles.id (UUID PRIMARY KEY)
///   -> public.properties.owner_id (UUID FOREIGN KEY)
///
/// Absolutely NEVER compares Firebase UID directly to Property ownerId UUID.
class OwnerIdentityBridge {
  OwnerIdentityBridge._();

  static final Map<String, String> _cacheFirebaseToProfileId = {};
  static final Map<String, String> _cacheProfileToFirebaseUid = {};

  static bool _isValidUuid(String str) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(str);
  }

  /// Clears in-memory identity resolution caches (e.g. on user logout)
  static void clearCache() {
    _cacheFirebaseToProfileId.clear();
    _cacheProfileToFirebaseUid.clear();
  }

  /// Resolves the canonical public.profiles UUID corresponding to a Firebase UID.
  /// If the input is already a valid UUID, returns it directly.
  static Future<String?> resolveProfileId(
    String firebaseUid, {
    SupabaseService? supabaseService,
  }) async {
    final cleanUid = firebaseUid.trim();
    if (cleanUid.isEmpty) return null;
    if (_isValidUuid(cleanUid)) return cleanUid;

    if (_cacheFirebaseToProfileId.containsKey(cleanUid)) {
      return _cacheFirebaseToProfileId[cleanUid];
    }

    try {
      final client = supabaseService?.client ?? Supabase.instance.client;
      final response = await client
          .from('profiles')
          .select('id')
          .eq('firebase_uid', cleanUid)
          .maybeSingle();

      if (response != null && response['id'] != null) {
        final profileId = response['id'].toString();
        if (_isValidUuid(profileId)) {
          _cacheFirebaseToProfileId[cleanUid] = profileId;
          _cacheProfileToFirebaseUid[profileId] = cleanUid;
          return profileId;
        }
      }
    } catch (e) {
      AppLogger.w('[OwnerIdentityBridge] resolveProfileId failed for UID: ');
    }

    return null;
  }

  /// Synchronously or asynchronously checks if a Firebase UID or Profile UUID owns the property.
  /// First does fast checks (exact match if both are UUIDs, or cached profile UUID match).
  /// Falls back to async database lookup if not yet cached.
  static Future<bool> isOwner({
    required String? callerId,
    required String propertyOwnerId,
    SupabaseService? supabaseService,
  }) async {
    if (callerId == null || callerId.trim().isEmpty) return false;
    final cleanCallerId = callerId.trim();
    final cleanOwnerId = propertyOwnerId.trim();

    // 1. Direct match (e.g., if callerId is already profile UUID)
    if (cleanCallerId == cleanOwnerId) return true;

    // 2. Check memory cache
    if (_cacheFirebaseToProfileId[cleanCallerId] == cleanOwnerId) return true;
    if (_cacheProfileToFirebaseUid[cleanOwnerId] == cleanCallerId) return true;

    // 3. Resolve via database
    final resolvedProfileId = await resolveProfileId(
      cleanCallerId,
      supabaseService: supabaseService,
    );

    if (resolvedProfileId != null && resolvedProfileId == cleanOwnerId) {
      return true;
    }

    return false;
  }

  /// Fast synchronous check against memory cache only.
  /// Returns true if definitively matching, false otherwise.
  static bool isOwnerSync({
    required String? callerId,
    required String propertyOwnerId,
  }) {
    if (callerId == null || callerId.trim().isEmpty) return false;
    final cleanCallerId = callerId.trim();
    final cleanOwnerId = propertyOwnerId.trim();

    if (cleanCallerId == cleanOwnerId) return true;
    if (_cacheFirebaseToProfileId[cleanCallerId] == cleanOwnerId) return true;
    if (_cacheProfileToFirebaseUid[cleanOwnerId] == cleanCallerId) return true;

    return false;
  }

  /// Registers a known mapping into the bridge cache.
  static void registerMapping({
    required String firebaseUid,
    required String profileId,
  }) {
    if (firebaseUid.isNotEmpty && profileId.isNotEmpty) {
      _cacheFirebaseToProfileId[firebaseUid] = profileId;
      _cacheProfileToFirebaseUid[profileId] = firebaseUid;
    }
  }
}
