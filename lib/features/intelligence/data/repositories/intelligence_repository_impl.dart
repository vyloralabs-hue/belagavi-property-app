import '../../../property/domain/entities/property_entities.dart';
import '../../domain/entities/preference_entities.dart';
import '../../domain/entities/requirement_entities.dart';
import '../../domain/entities/property_watch_entities.dart';
import '../../domain/entities/entitlement_entities.dart';
import '../../domain/repositories/intelligence_repository.dart';
import '../datasources/intelligence_remote_datasource.dart';

class IntelligenceRepositoryImpl implements IntelligenceRepository {
  final IntelligenceRemoteDataSource _remoteDataSource;

  IntelligenceRepositoryImpl({IntelligenceRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? IntelligenceRemoteDataSourceImpl();

  @override
  Future<PropertyPreferenceEntity?> getPreference() {
    return _remoteDataSource.getPreference();
  }

  @override
  Future<PropertyPreferenceEntity> savePreference(PropertyPreferenceEntity preference) {
    return _remoteDataSource.savePreference(preference);
  }

  @override
  Future<void> deletePreference() {
    return _remoteDataSource.deletePreference();
  }

  @override
  Future<List<SavedRequirementEntity>> getSavedRequirements() {
    return _remoteDataSource.getSavedRequirements();
  }

  @override
  Future<SavedRequirementEntity> saveRequirement(SavedRequirementEntity requirement) {
    return _remoteDataSource.saveRequirement(requirement);
  }

  @override
  Future<void> updateRequirementActiveStatus(String id, bool isActive) {
    return _remoteDataSource.updateRequirementActiveStatus(id, isActive);
  }

  @override
  Future<void> deleteRequirement(String id) {
    return _remoteDataSource.deleteRequirement(id);
  }

  @override
  Future<List<PropertyAlertMatchEntity>> getAlertMatches({String? requirementId}) {
    return _remoteDataSource.getAlertMatches(requirementId: requirementId);
  }

  @override
  Future<void> markMatchAsViewed(String matchId) {
    return _remoteDataSource.markMatchAsViewed(matchId);
  }

  @override
  Future<List<PropertyWatchEntity>> getPropertyWatches() {
    return _remoteDataSource.getPropertyWatches();
  }

  @override
  Future<PropertyWatchEntity> addPropertyWatch(PropertyWatchEntity watch) {
    return _remoteDataSource.addPropertyWatch(watch);
  }

  @override
  Future<void> deletePropertyWatch(String watchId) {
    return _remoteDataSource.deletePropertyWatch(watchId);
  }

  @override
  Future<UserEntitlementEntity?> getMonitoringEntitlement() {
    return _remoteDataSource.getMonitoringEntitlement();
  }

  @override
  Future<List<Property>> getPersonalizedProperties(PropertyPreferenceEntity preference) {
    return _remoteDataSource.getPersonalizedProperties(preference);
  }
}
