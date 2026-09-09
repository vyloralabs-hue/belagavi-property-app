import 'package:equatable/equatable.dart';

class PropertyPreferenceEntity extends Equatable {
  final String id;
  final String profileId;
  final String purpose; // 'buy', 'rent', 'lease', 'investment'
  final String category; // 'residential', 'commercial', 'plotLand', 'land'
  final String state;
  final String district;
  final String taluk;
  final List<String> preferredLocalities;
  final double? minBudget;
  final double? maxBudget;
  final int? minBedrooms;
  final int? maxBedrooms;
  final double? minArea;
  final double? maxArea;
  final String areaUnit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyPreferenceEntity({
    required this.id,
    required this.profileId,
    this.purpose = 'buy',
    this.category = 'residential',
    this.state = 'Karnataka',
    this.district = 'Belagavi',
    this.taluk = 'Belagavi',
    this.preferredLocalities = const [],
    this.minBudget,
    this.maxBudget,
    this.minBedrooms,
    this.maxBedrooms,
    this.minArea,
    this.maxArea,
    this.areaUnit = 'sqft',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  PropertyPreferenceEntity copyWith({
    String? id,
    String? profileId,
    String? purpose,
    String? category,
    String? state,
    String? district,
    String? taluk,
    List<String>? preferredLocalities,
    double? minBudget,
    double? maxBudget,
    int? minBedrooms,
    int? maxBedrooms,
    double? minArea,
    double? maxArea,
    String? areaUnit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyPreferenceEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      purpose: purpose ?? this.purpose,
      category: category ?? this.category,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      preferredLocalities: preferredLocalities ?? this.preferredLocalities,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      areaUnit: areaUnit ?? this.areaUnit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        purpose,
        category,
        state,
        district,
        taluk,
        preferredLocalities,
        minBudget,
        maxBudget,
        minBedrooms,
        maxBedrooms,
        minArea,
        maxArea,
        areaUnit,
        isActive,
        createdAt,
        updatedAt,
      ];
}
