import 'package:equatable/equatable.dart';

class SavedRequirementEntity extends Equatable {
  final String id;
  final String profileId;
  final String title;
  final String purpose;
  final String category;
  final String state;
  final String district;
  final String taluk;
  final List<String> preferredLocalities;
  final double minBudget;
  final double maxBudget;
  final double priceTolerancePercent; // 5.0, 10.0, 20.0
  final int? minBedrooms;
  final int? maxBedrooms;
  final double? minArea;
  final double? maxArea;
  final String alertFrequency; // 'instant', 'daily', 'weekly'
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedRequirementEntity({
    required this.id,
    required this.profileId,
    required this.title,
    this.purpose = 'buy',
    this.category = 'residential',
    this.state = 'Karnataka',
    this.district = 'Belagavi',
    this.taluk = 'Belagavi',
    this.preferredLocalities = const [],
    required this.minBudget,
    required this.maxBudget,
    this.priceTolerancePercent = 10.0,
    this.minBedrooms,
    this.maxBedrooms,
    this.minArea,
    this.maxArea,
    this.alertFrequency = 'instant',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Allowable budget min after applying tolerance percentage
  double get allowableMinBudget => minBudget * (1.0 - (priceTolerancePercent / 100.0));

  /// Allowable budget max after applying tolerance percentage
  double get allowableMaxBudget => maxBudget * (1.0 + (priceTolerancePercent / 100.0));

  SavedRequirementEntity copyWith({
    String? id,
    String? profileId,
    String? title,
    String? purpose,
    String? category,
    String? state,
    String? district,
    String? taluk,
    List<String>? preferredLocalities,
    double? minBudget,
    double? maxBudget,
    double? priceTolerancePercent,
    int? minBedrooms,
    int? maxBedrooms,
    double? minArea,
    double? maxArea,
    String? alertFrequency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedRequirementEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      category: category ?? this.category,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      preferredLocalities: preferredLocalities ?? this.preferredLocalities,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      priceTolerancePercent: priceTolerancePercent ?? this.priceTolerancePercent,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      alertFrequency: alertFrequency ?? this.alertFrequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        title,
        purpose,
        category,
        state,
        district,
        taluk,
        preferredLocalities,
        minBudget,
        maxBudget,
        priceTolerancePercent,
        minBedrooms,
        maxBedrooms,
        minArea,
        maxArea,
        alertFrequency,
        isActive,
        createdAt,
        updatedAt,
      ];
}

class PropertyAlertMatchEntity extends Equatable {
  final String id;
  final String savedRequirementId;
  final String propertyId;
  final int matchScore; // 0 to 100
  final List<String> matchReasons;
  final bool isViewed;
  final DateTime? notifiedAt;
  final DateTime createdAt;
  final Map<String, dynamic>? propertySnapshot;

  const PropertyAlertMatchEntity({
    required this.id,
    required this.savedRequirementId,
    required this.propertyId,
    required this.matchScore,
    this.matchReasons = const [],
    this.isViewed = false,
    this.notifiedAt,
    required this.createdAt,
    this.propertySnapshot,
  });

  PropertyAlertMatchEntity copyWith({
    String? id,
    String? savedRequirementId,
    String? propertyId,
    int? matchScore,
    List<String>? matchReasons,
    bool? isViewed,
    DateTime? notifiedAt,
    DateTime? createdAt,
    Map<String, dynamic>? propertySnapshot,
  }) {
    return PropertyAlertMatchEntity(
      id: id ?? this.id,
      savedRequirementId: savedRequirementId ?? this.savedRequirementId,
      propertyId: propertyId ?? this.propertyId,
      matchScore: matchScore ?? this.matchScore,
      matchReasons: matchReasons ?? this.matchReasons,
      isViewed: isViewed ?? this.isViewed,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      createdAt: createdAt ?? this.createdAt,
      propertySnapshot: propertySnapshot ?? this.propertySnapshot,
    );
  }

  @override
  List<Object?> get props => [
        id,
        savedRequirementId,
        propertyId,
        matchScore,
        matchReasons,
        isViewed,
        notifiedAt,
        createdAt,
        propertySnapshot,
      ];
}
