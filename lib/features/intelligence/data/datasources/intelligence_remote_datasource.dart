import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../../property/data/models/property_models.dart';
import '../../../property/domain/entities/property_entities.dart';
import '../../domain/entities/preference_entities.dart';
import '../../domain/entities/requirement_entities.dart';
import '../../domain/entities/property_watch_entities.dart';
import '../../domain/entities/entitlement_entities.dart';
import '../../domain/services/survey_identity_normalizer.dart';
import '../models/intelligence_models.dart';

import '../../../property/utils/owner_identity_bridge.dart';

class EntitlementRequiredException extends AppException {
  const EntitlementRequiredException([
    super.message = 'Active paid entitlement required for this feature.',
    super.statusCode = 402,
  ]);
}

abstract class IntelligenceRemoteDataSource {
  Future<PropertyPreferenceEntity?> getPreference();
  Future<PropertyPreferenceEntity> savePreference(PropertyPreferenceEntity preference);
  Future<void> deletePreference();

  Future<List<SavedRequirementEntity>> getSavedRequirements();
  Future<SavedRequirementEntity> saveRequirement(SavedRequirementEntity requirement);
  Future<void> updateRequirementActiveStatus(String id, bool isActive);
  Future<void> deleteRequirement(String id);

  Future<List<PropertyAlertMatchEntity>> getAlertMatches({String? requirementId});
  Future<void> markMatchAsViewed(String matchId);

  Future<List<PropertyWatchEntity>> getPropertyWatches();
  Future<PropertyWatchEntity> addPropertyWatch(PropertyWatchEntity watch);
  Future<void> deletePropertyWatch(String watchId);

  Future<UserEntitlementEntity?> getMonitoringEntitlement();

  Future<List<Property>> getPersonalizedProperties(PropertyPreferenceEntity preference);
}

class IntelligenceRemoteDataSourceImpl implements IntelligenceRemoteDataSource {
  final SupabaseService _supabaseService;

  IntelligenceRemoteDataSourceImpl({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  SupabaseClient get _client => _supabaseService.client;

  Future<String?> _resolveProfileId() async {
    final fbUid = AuthSessionStorageHelper.getUserUid();
    if (fbUid != null && fbUid.isNotEmpty) {
      return await OwnerIdentityBridge.resolveProfileId(fbUid, supabaseService: _supabaseService);
    }
    return null;
  }

  @override
  Future<PropertyPreferenceEntity?> getPreference() async {
    final profileId = await _resolveProfileId();
    if (profileId == null) return null;

    try {
      final res = await _client
          .from('property_preferences')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      if (res == null) return null;
      return PropertyPreferenceModel.fromMap(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PropertyPreferenceEntity> savePreference(PropertyPreferenceEntity preference) async {
    final profileId = await _resolveProfileId();
    if (profileId == null) {
      throw const UnauthorizedException('User profile not authenticated');
    }

    final entityToSave = preference.copyWith(profileId: profileId);
    final data = PropertyPreferenceModel.toMap(entityToSave);

    final res = await _client
        .from('property_preferences')
        .upsert(data, onConflict: 'profile_id')
        .select()
        .single();

    return PropertyPreferenceModel.fromMap(res);
  }

  @override
  Future<void> deletePreference() async {
    final profileId = await _resolveProfileId();
    if (profileId == null) return;

    await _client
        .from('property_preferences')
        .delete()
        .eq('profile_id', profileId);
  }

  @override
  Future<List<SavedRequirementEntity>> getSavedRequirements() async {
    final profileId = await _resolveProfileId();
    if (profileId == null) return [];

    final res = await _client
        .from('saved_property_requirements')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => SavedRequirementModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SavedRequirementEntity> saveRequirement(SavedRequirementEntity requirement) async {
    final profileId = await _resolveProfileId();
    if (profileId == null) {
      throw const UnauthorizedException('User profile not authenticated');
    }

    final entityToSave = requirement.copyWith(profileId: profileId);
    final data = SavedRequirementModel.toMap(entityToSave);

    final res = await _client
        .from('saved_property_requirements')
        .upsert(data)
        .select()
        .single();

    return SavedRequirementModel.fromMap(res);
  }

  @override
  Future<void> updateRequirementActiveStatus(String id, bool isActive) async {
    await _client
        .from('saved_property_requirements')
        .update({'is_active': isActive, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Future<void> deleteRequirement(String id) async {
    await _client.from('saved_property_requirements').delete().eq('id', id);
  }

  @override
  Future<List<PropertyAlertMatchEntity>> getAlertMatches({String? requirementId}) async {
    var query = _client.from('property_alert_matches').select('''
      *,
      properties:property_id (
        id, title, price, category, type, status, locality, taluk, district,
        bedrooms, carpet_area, super_built_up_area, plot_area, is_paused
      )
    ''');

    if (requirementId != null) {
      query = query.eq('saved_requirement_id', requirementId);
    }

    final res = await query.order('match_score', ascending: false);
    return (res as List)
        .map((e) => PropertyAlertMatchModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markMatchAsViewed(String matchId) async {
    await _client
        .from('property_alert_matches')
        .update({'is_viewed': true})
        .eq('id', matchId);
  }

  @override
  Future<List<PropertyWatchEntity>> getPropertyWatches() async {
    final profileId = await _resolveProfileId();
    if (profileId == null) return [];

    final res = await _client
        .from('property_watches')
        .select('''
          *,
          property_watch_events (
            id, watch_id, event_type, title, description, source_type, source_id, visibility, event_time, created_at
          )
        ''')
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => PropertyWatchModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PropertyWatchEntity> addPropertyWatch(PropertyWatchEntity watch) async {
    final profileId = await _resolveProfileId();
    if (profileId == null) {
      throw const UnauthorizedException('User profile not authenticated');
    }

    // Verify entitlement before sending to database
    final entitlement = await getMonitoringEntitlement();
    if (entitlement == null || !entitlement.hasAvailableQuota) {
      throw const EntitlementRequiredException(
        'Active paid entitlement required for property or survey monitoring. Please upgrade to a monitoring pack.',
      );
    }

    final normalized = SurveyIdentityNormalizer.normalize(
      country: watch.country,
      state: watch.state,
      district: watch.district,
      taluk: watch.taluk,
      cityOrVillage: watch.cityOrVillage,
      locality: watch.locality,
      surveyNumber: watch.surveyNumber,
      subdivisionNumber: watch.subdivisionNumber,
    );

    final entityToSave = watch.copyWith(
      profileId: profileId,
      normalizedIdentity: normalized,
    );
    final data = PropertyWatchModel.toMap(entityToSave);

    try {
      final res = await _client
          .from('property_watches')
          .insert(data)
          .select()
          .single();

      return PropertyWatchModel.fromMap(res);
    } on PostgrestException catch (pe) {
      if (pe.code == 'P0001' || pe.message.contains('entitlement')) {
        throw EntitlementRequiredException(pe.message);
      }
      rethrow;
    }
  }

  @override
  Future<void> deletePropertyWatch(String watchId) async {
    await _client.from('property_watches').delete().eq('id', watchId);
  }

  @override
  Future<UserEntitlementEntity?> getMonitoringEntitlement() async {
    final profileId = await _resolveProfileId();
    if (profileId == null) return null;

    try {
      final res = await _client
          .from('user_entitlements')
          .select()
          .eq('user_id', profileId)
          .inFilter('entitlement_key', ['property_watch', 'survey_monitoring'])
          .maybeSingle();

      if (res == null) return null;
      return UserEntitlementModel.fromMap(res);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Property>> getPersonalizedProperties(PropertyPreferenceEntity preference) async {
    if (!preference.isActive) return [];

    try {
      var query = _client.from('properties').select('''
        *,
        property_media (*)
      ''').inFilter('status', ['active', 'published']).eq('is_paused', false);

      // Filter category if specified
      if (preference.category.isNotEmpty) {
        query = query.eq('category', preference.category);
      }

      // Filter budget if specified
      if (preference.maxBudget != null) {
        query = query.lte('price', preference.maxBudget! * 1.15); // include near budget
      }

      final res = await query.order('created_at', ascending: false).limit(20);

      final models = (res as List)
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return models;
    } catch (e) {
      return [];
    }
  }
}
