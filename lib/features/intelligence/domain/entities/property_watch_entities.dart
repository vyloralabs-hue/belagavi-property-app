import 'package:equatable/equatable.dart';

enum WatchRelationship {
  owner,
  prospectiveBuyer,
  neighbor,
  investor,
  legalCounsel,
}

extension WatchRelationshipExtension on WatchRelationship {
  String get displayName => switch (this) {
        WatchRelationship.owner => 'Property Owner',
        WatchRelationship.prospectiveBuyer => 'Prospective Buyer',
        WatchRelationship.neighbor => 'Neighboring Landowner',
        WatchRelationship.investor => 'Real Estate Investor',
        WatchRelationship.legalCounsel => 'Legal Researcher / Counsel',
      };

  String get dbValue => switch (this) {
        WatchRelationship.owner => 'owner',
        WatchRelationship.prospectiveBuyer => 'prospective_buyer',
        WatchRelationship.neighbor => 'neighbor',
        WatchRelationship.investor => 'investor',
        WatchRelationship.legalCounsel => 'legal_counsel',
      };

  static WatchRelationship fromString(String? val) {
    if (val == null) return WatchRelationship.prospectiveBuyer;
    return WatchRelationship.values.firstWhere(
      (e) => e.dbValue.toLowerCase() == val.toLowerCase() || e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => WatchRelationship.prospectiveBuyer,
    );
  }
}

class PropertyWatchEntity extends Equatable {
  final String id;
  final String profileId;
  final String watchName;
  final WatchRelationship relationship;
  final String country;
  final String state;
  final String district;
  final String taluk;
  final String cityOrVillage;
  final String locality;
  final String surveyNumber;
  final String? subdivisionNumber;
  final String normalizedIdentity;
  final String? propertyId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PropertyWatchEventEntity> recentEvents;

  const PropertyWatchEntity({
    required this.id,
    required this.profileId,
    required this.watchName,
    this.relationship = WatchRelationship.prospectiveBuyer,
    this.country = 'India',
    this.state = 'Karnataka',
    this.district = 'Belagavi',
    this.taluk = 'Belagavi',
    required this.cityOrVillage,
    required this.locality,
    required this.surveyNumber,
    this.subdivisionNumber,
    required this.normalizedIdentity,
    this.propertyId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.recentEvents = const [],
  });

  String get formattedSurveyDisplayName {
    if (subdivisionNumber != null && subdivisionNumber!.trim().isNotEmpty) {
      if (surveyNumber.contains('/')) return 'Survey No. $surveyNumber';
      return 'Survey No. $surveyNumber/$subdivisionNumber';
    }
    return 'Survey No. $surveyNumber';
  }

  String get formattedLocationDisplayName =>
      '$locality, $cityOrVillage, $taluk, $district';

  PropertyWatchEntity copyWith({
    String? id,
    String? profileId,
    String? watchName,
    WatchRelationship? relationship,
    String? country,
    String? state,
    String? district,
    String? taluk,
    String? cityOrVillage,
    String? locality,
    String? surveyNumber,
    String? subdivisionNumber,
    String? normalizedIdentity,
    String? propertyId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PropertyWatchEventEntity>? recentEvents,
  }) {
    return PropertyWatchEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      watchName: watchName ?? this.watchName,
      relationship: relationship ?? this.relationship,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      cityOrVillage: cityOrVillage ?? this.cityOrVillage,
      locality: locality ?? this.locality,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      subdivisionNumber: subdivisionNumber ?? this.subdivisionNumber,
      normalizedIdentity: normalizedIdentity ?? this.normalizedIdentity,
      propertyId: propertyId ?? this.propertyId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recentEvents: recentEvents ?? this.recentEvents,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        watchName,
        relationship,
        country,
        state,
        district,
        taluk,
        cityOrVillage,
        locality,
        surveyNumber,
        subdivisionNumber,
        normalizedIdentity,
        propertyId,
        isActive,
        createdAt,
        updatedAt,
        recentEvents,
      ];
}

class PropertyWatchEventEntity extends Equatable {
  final String id;
  final String watchId;
  final String eventType; // 'public_listing_created', 'public_notice_published', 'public_dispute_published', 'price_updated'
  final String title;
  final String description;
  final String sourceType; // 'property', 'legal_notice', 'dispute_listing'
  final String? sourceId;
  final String visibility;
  final DateTime eventTime;
  final DateTime createdAt;

  const PropertyWatchEventEntity({
    required this.id,
    required this.watchId,
    required this.eventType,
    required this.title,
    required this.description,
    required this.sourceType,
    this.sourceId,
    this.visibility = 'public_record',
    required this.eventTime,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        watchId,
        eventType,
        title,
        description,
        sourceType,
        sourceId,
        visibility,
        eventTime,
        createdAt,
      ];
}
