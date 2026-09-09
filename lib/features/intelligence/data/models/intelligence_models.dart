import '../../domain/entities/preference_entities.dart';
import '../../domain/entities/requirement_entities.dart';
import '../../domain/entities/property_watch_entities.dart';
import '../../domain/entities/entitlement_entities.dart';

class PropertyPreferenceModel {
  static PropertyPreferenceEntity fromMap(Map<String, dynamic> map) {
    return PropertyPreferenceEntity(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      purpose: (map['purpose'] as String?) ?? 'buy',
      category: (map['category'] as String?) ?? 'residential',
      state: (map['state'] as String?) ?? 'Karnataka',
      district: (map['district'] as String?) ?? 'Belagavi',
      taluk: (map['taluk'] as String?) ?? 'Belagavi',
      preferredLocalities: map['preferred_localities'] != null
          ? List<String>.from(map['preferred_localities'] as List)
          : const [],
      minBudget: map['min_budget'] != null ? (map['min_budget'] as num).toDouble() : null,
      maxBudget: map['max_budget'] != null ? (map['max_budget'] as num).toDouble() : null,
      minBedrooms: map['min_bedrooms'] as int?,
      maxBedrooms: map['max_bedrooms'] as int?,
      minArea: map['min_area'] != null ? (map['min_area'] as num).toDouble() : null,
      maxArea: map['max_area'] != null ? (map['max_area'] as num).toDouble() : null,
      areaUnit: (map['area_unit'] as String?) ?? 'sqft',
      isActive: (map['is_active'] as bool?) ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'].toString()) : DateTime.now(),
    );
  }

  static Map<String, dynamic> toMap(PropertyPreferenceEntity entity) {
    final data = <String, dynamic>{
      'profile_id': entity.profileId,
      'purpose': entity.purpose,
      'category': entity.category,
      'state': entity.state,
      'district': entity.district,
      'taluk': entity.taluk,
      'preferred_localities': entity.preferredLocalities,
      'min_budget': entity.minBudget,
      'max_budget': entity.maxBudget,
      'min_bedrooms': entity.minBedrooms,
      'max_bedrooms': entity.maxBedrooms,
      'min_area': entity.minArea,
      'max_area': entity.maxArea,
      'area_unit': entity.areaUnit,
      'is_active': entity.isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (entity.id.isNotEmpty && entity.id.contains('-')) {
      data['id'] = entity.id;
    }
    return data;
  }
}

class SavedRequirementModel {
  static SavedRequirementEntity fromMap(Map<String, dynamic> map) {
    return SavedRequirementEntity(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      title: (map['title'] as String?) ?? 'Requirement',
      purpose: (map['purpose'] as String?) ?? 'buy',
      category: (map['category'] as String?) ?? 'residential',
      state: (map['state'] as String?) ?? 'Karnataka',
      district: (map['district'] as String?) ?? 'Belagavi',
      taluk: (map['taluk'] as String?) ?? 'Belagavi',
      preferredLocalities: map['preferred_localities'] != null
          ? List<String>.from(map['preferred_localities'] as List)
          : const [],
      minBudget: (map['min_budget'] as num?)?.toDouble() ?? 0.0,
      maxBudget: (map['max_budget'] as num?)?.toDouble() ?? 10000000.0,
      priceTolerancePercent: (map['price_tolerance_percent'] as num?)?.toDouble() ?? 10.0,
      minBedrooms: map['min_bedrooms'] as int?,
      maxBedrooms: map['max_bedrooms'] as int?,
      minArea: map['min_area'] != null ? (map['min_area'] as num).toDouble() : null,
      maxArea: map['max_area'] != null ? (map['max_area'] as num).toDouble() : null,
      alertFrequency: (map['alert_frequency'] as String?) ?? 'instant',
      isActive: (map['is_active'] as bool?) ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'].toString()) : DateTime.now(),
    );
  }

  static Map<String, dynamic> toMap(SavedRequirementEntity entity) {
    final data = <String, dynamic>{
      'profile_id': entity.profileId,
      'title': entity.title,
      'purpose': entity.purpose,
      'category': entity.category,
      'state': entity.state,
      'district': entity.district,
      'taluk': entity.taluk,
      'preferred_localities': entity.preferredLocalities,
      'min_budget': entity.minBudget,
      'max_budget': entity.maxBudget,
      'price_tolerance_percent': entity.priceTolerancePercent,
      'min_bedrooms': entity.minBedrooms,
      'max_bedrooms': entity.maxBedrooms,
      'min_area': entity.minArea,
      'max_area': entity.maxArea,
      'alert_frequency': entity.alertFrequency,
      'is_active': entity.isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (entity.id.isNotEmpty && entity.id.contains('-')) {
      data['id'] = entity.id;
    }
    return data;
  }
}

class PropertyAlertMatchModel {
  static PropertyAlertMatchEntity fromMap(Map<String, dynamic> map) {
    return PropertyAlertMatchEntity(
      id: map['id'] as String,
      savedRequirementId: map['saved_requirement_id'] as String,
      propertyId: map['property_id'] as String,
      matchScore: (map['match_score'] as num?)?.toInt() ?? 100,
      matchReasons: map['match_reasons'] != null
          ? List<String>.from(map['match_reasons'] as List)
          : const [],
      isViewed: (map['is_viewed'] as bool?) ?? false,
      notifiedAt: map['notified_at'] != null ? DateTime.tryParse(map['notified_at'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
      propertySnapshot: map['properties'] as Map<String, dynamic>?,
    );
  }
}

class PropertyWatchModel {
  static PropertyWatchEntity fromMap(Map<String, dynamic> map) {
    final eventsRaw = map['property_watch_events'] as List<dynamic>?;
    final List<PropertyWatchEventEntity> events = eventsRaw != null
        ? eventsRaw.map((e) => PropertyWatchEventModel.fromMap(e as Map<String, dynamic>)).toList()
        : [];

    return PropertyWatchEntity(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      watchName: (map['watch_name'] as String?) ?? 'Watch',
      relationship: WatchRelationshipExtension.fromString(map['relationship_type'] as String?),
      country: (map['country'] as String?) ?? 'India',
      state: (map['state'] as String?) ?? 'Karnataka',
      district: (map['district'] as String?) ?? 'Belagavi',
      taluk: (map['taluk'] as String?) ?? 'Belagavi',
      cityOrVillage: (map['city_or_village'] as String?) ?? 'Belagavi',
      locality: (map['locality'] as String?) ?? '',
      surveyNumber: (map['survey_number'] as String?) ?? '',
      subdivisionNumber: map['subdivision_number'] as String?,
      normalizedIdentity: (map['normalized_identity'] as String?) ?? '',
      propertyId: map['property_id'] as String?,
      isActive: (map['is_active'] as bool?) ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'].toString()) : DateTime.now(),
      recentEvents: events,
    );
  }

  static Map<String, dynamic> toMap(PropertyWatchEntity entity) {
    final data = <String, dynamic>{
      'profile_id': entity.profileId,
      'watch_name': entity.watchName,
      'relationship_type': entity.relationship.dbValue,
      'country': entity.country,
      'state': entity.state,
      'district': entity.district,
      'taluk': entity.taluk,
      'city_or_village': entity.cityOrVillage,
      'locality': entity.locality,
      'survey_number': entity.surveyNumber,
      'subdivision_number': entity.subdivisionNumber,
      'normalized_identity': entity.normalizedIdentity,
      'property_id': entity.propertyId,
      'is_active': entity.isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (entity.id.isNotEmpty && entity.id.contains('-')) {
      data['id'] = entity.id;
    }
    return data;
  }
}

class PropertyWatchEventModel {
  static PropertyWatchEventEntity fromMap(Map<String, dynamic> map) {
    return PropertyWatchEventEntity(
      id: map['id'] as String,
      watchId: map['watch_id'] as String,
      eventType: (map['event_type'] as String?) ?? 'public_update',
      title: (map['title'] as String?) ?? 'Public Record Update',
      description: (map['description'] as String?) ?? '',
      sourceType: (map['source_type'] as String?) ?? 'property',
      sourceId: map['source_id'] as String?,
      visibility: (map['visibility'] as String?) ?? 'public_record',
      eventTime: map['event_time'] != null ? DateTime.parse(map['event_time'].toString()) : DateTime.now(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
    );
  }
}

class UserEntitlementModel {
  static UserEntitlementEntity fromMap(Map<String, dynamic> map) {
    return UserEntitlementEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      entitlementKey: map['entitlement_key'] as String,
      totalQuota: (map['total_quota'] as num?)?.toInt() ?? 0,
      usedQuota: (map['used_quota'] as num?)?.toInt() ?? 0,
      expiresAt: map['expires_at'] != null ? DateTime.tryParse(map['expires_at'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'].toString()) : DateTime.now(),
    );
  }
}
