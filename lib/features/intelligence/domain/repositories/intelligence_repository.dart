import '../../../property/domain/entities/property_entities.dart';
import '../entities/preference_entities.dart';
import '../entities/requirement_entities.dart';
import '../entities/property_watch_entities.dart';
import '../entities/entitlement_entities.dart';

abstract class IntelligenceRepository {
  // Preference
  Future<PropertyPreferenceEntity?> getPreference();
  Future<PropertyPreferenceEntity> savePreference(PropertyPreferenceEntity preference);
  Future<void> deletePreference();

  // Saved Requirements
  Future<List<SavedRequirementEntity>> getSavedRequirements();
  Future<SavedRequirementEntity> saveRequirement(SavedRequirementEntity requirement);
  Future<void> updateRequirementActiveStatus(String id, bool isActive);
  Future<void> deleteRequirement(String id);

  // Alert Matches
  Future<List<PropertyAlertMatchEntity>> getAlertMatches({String? requirementId});
  Future<void> markMatchAsViewed(String matchId);

  // Property Watches (100% Paid)
  Future<List<PropertyWatchEntity>> getPropertyWatches();
  Future<PropertyWatchEntity> addPropertyWatch(PropertyWatchEntity watch);
  Future<void> deletePropertyWatch(String watchId);

  // Entitlement Check
  Future<UserEntitlementEntity?> getMonitoringEntitlement();

  // Personalized Home Feed
  Future<List<Property>> getPersonalizedProperties(PropertyPreferenceEntity preference);
}
