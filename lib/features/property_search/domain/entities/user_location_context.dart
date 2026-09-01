import 'package:equatable/equatable.dart';
import '../../../property/domain/entities/property_entities.dart';
import 'search_entities.dart';

enum LocationCandidateType {
  city,
  locality,
  area,
  landmark,
  pincode,
  state,
}

class LocationCandidate extends Equatable {
  final String id;
  final String name;
  final String subtitle;
  final LocationCandidateType type;
  final String cityName;
  final String stateName;
  final String? stateCode;
  final String countryCode;
  final String countryName;
  final String? localityName;
  final String? areaName;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  const LocationCandidate({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    required this.cityName,
    required this.stateName,
    this.stateCode,
    this.countryCode = 'IN',
    this.countryName = 'India',
    this.localityName,
    this.areaName,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  String get typeLabel {
    switch (type) {
      case LocationCandidateType.city:
        return 'CITY';
      case LocationCandidateType.locality:
        return 'LOCALITY';
      case LocationCandidateType.area:
        return 'AREA';
      case LocationCandidateType.landmark:
        return 'LANDMARK';
      case LocationCandidateType.pincode:
        return 'PINCODE';
      case LocationCandidateType.state:
        return 'STATE';
    }
  }

  UserLocationContext toLocationContext() {
    return UserLocationContext(
      countryCode: countryCode,
      countryName: countryName,
      stateCode: stateCode,
      stateName: stateName,
      cityName: cityName,
      localityName: localityName ?? (type == LocationCandidateType.locality ? name : null),
      areaName: areaName ?? (type == LocationCandidateType.area ? name : null),
      pincode: pincode ?? (type == LocationCandidateType.pincode ? name : null),
      latitude: latitude,
      longitude: longitude,
      hasExplicitSelection: true,
      isAllIndia: false,
    );
  }


  @override
  List<Object?> get props => [
        id,
        name,
        subtitle,
        type,
        cityName,
        stateName,
        stateCode,
        localityName,
        areaName,
        pincode,
        latitude,
        longitude,
      ];
}

class UserLocationContext extends Equatable {
  final String countryCode;
  final String countryName;
  final String? stateCode;
  final String? stateName;
  final String? districtName;
  final String? cityName;
  final String? localityName;
  final String? areaName;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final List<String> selectedLocalities;
  final bool hasExplicitSelection;
  final bool isAllIndia;

  const UserLocationContext({
    this.countryCode = 'IN',
    this.countryName = 'India',
    this.stateCode,
    this.stateName,
    this.districtName,
    this.cityName,
    this.localityName,
    this.areaName,
    this.pincode,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.selectedLocalities = const [],
    this.hasExplicitSelection = false,
    this.isAllIndia = false,
  });

  static const UserLocationContext unselected = UserLocationContext(
    countryCode: 'IN',
    countryName: 'India',
    hasExplicitSelection: false,
    isAllIndia: false,
  );

  static const UserLocationContext allIndia = UserLocationContext(
    countryCode: 'IN',
    countryName: 'India',
    hasExplicitSelection: true,
    isAllIndia: true,
  );

  String get displayName {
    if (isAllIndia) return 'All India';
    if (localityName != null && localityName!.isNotEmpty && cityName != null && cityName!.isNotEmpty) {
      return '$localityName, $cityName';
    }
    if (localityName != null && localityName!.isNotEmpty) {
      return localityName!;
    }
    if (cityName != null && cityName!.isNotEmpty) {
      return cityName!;
    }
    if (stateName != null && stateName!.isNotEmpty) {
      return stateName!;
    }
    return 'Select Location';
  }

  String get shortDisplayName {
    if (isAllIndia) return 'All India';
    if (localityName != null && localityName!.isNotEmpty) {
      return localityName!;
    }
    if (cityName != null && cityName!.isNotEmpty) {
      return cityName!;
    }
    if (stateName != null && stateName!.isNotEmpty) {
      return stateName!;
    }
    return 'Select Location';
  }

  String categoryHeading(PropertyCategory category) {
    final locationText = displayName;
    final hasLoc = locationText != 'Select Location';

    switch (category) {
      case PropertyCategory.residential:
        return hasLoc ? 'Residential Properties in $locationText' : 'Residential Properties';
      case PropertyCategory.plotLand:
        return hasLoc ? 'Plots & Layouts in $locationText' : 'Plots & Layouts';
      case PropertyCategory.commercial:
        return hasLoc ? 'Commercial Properties in $locationText' : 'Commercial Properties';
      case PropertyCategory.land:
        return hasLoc ? 'Land Listings in $locationText' : 'Land Listings';
      case PropertyCategory.industrial:
        return hasLoc ? 'Industrial Properties in $locationText' : 'Industrial Properties';
      case PropertyCategory.builderProject:
        return hasLoc ? 'Builder Projects in $locationText' : 'Builder Projects';
      case PropertyCategory.other:
        return hasLoc ? 'Properties in $locationText' : 'Properties';
    }
  }

  SearchQueryEntity toSearchQuery({
    PropertyCategory? category,
    PropertySubtype? type,
    ListingPurpose? purpose,
    String? sortBy,
    int limit = 20,
    int offset = 0,
    String? rawQuery,
  }) {
    if (isAllIndia) {
      return SearchQueryEntity(
        country: countryName,
        category: category,
        type: type,
        purpose: purpose,
        sortBy: sortBy ?? 'created_at_desc',
        limit: limit,
        offset: offset,
        rawQuery: rawQuery,
      );
    }

    return SearchQueryEntity(
      country: countryName.isNotEmpty ? countryName : null,
      state: stateName,
      district: districtName,
      city: cityName,
      locality: localityName,
      area: areaName,
      pincode: pincode,
      category: category,
      type: type,
      purpose: purpose,
      sortBy: sortBy ?? 'created_at_desc',
      limit: limit,
      offset: offset,
      rawQuery: rawQuery,
    );
  }

  UserLocationContext copyWith({
    String? countryCode,
    String? countryName,
    String? stateCode,
    String? stateName,
    String? districtName,
    String? cityName,
    String? localityName,
    String? areaName,
    String? pincode,
    double? latitude,
    double? longitude,
    double? radiusKm,
    List<String>? selectedLocalities,
    bool? hasExplicitSelection,
    bool? isAllIndia,
    bool clearLocality = false,
  }) {
    return UserLocationContext(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      stateCode: stateCode ?? this.stateCode,
      stateName: stateName ?? this.stateName,
      districtName: districtName ?? this.districtName,
      cityName: cityName ?? this.cityName,
      localityName: clearLocality ? null : (localityName ?? this.localityName),
      areaName: clearLocality ? null : (areaName ?? this.areaName),
      pincode: clearLocality ? null : (pincode ?? this.pincode),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      selectedLocalities: selectedLocalities ?? this.selectedLocalities,
      hasExplicitSelection: hasExplicitSelection ?? this.hasExplicitSelection,
      isAllIndia: isAllIndia ?? this.isAllIndia,
    );
  }

  Map<String, dynamic> toJson() => {
        'countryCode': countryCode,
        'countryName': countryName,
        'stateCode': stateCode,
        'stateName': stateName,
        'districtName': districtName,
        'cityName': cityName,
        'localityName': localityName,
        'areaName': areaName,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radiusKm,
        'selectedLocalities': selectedLocalities,
        'hasExplicitSelection': hasExplicitSelection,
        'isAllIndia': isAllIndia,
      };

  factory UserLocationContext.fromJson(Map<String, dynamic> json) {
    return UserLocationContext(
      countryCode: json['countryCode'] as String? ?? 'IN',
      countryName: json['countryName'] as String? ?? 'India',
      stateCode: json['stateCode'] as String?,
      stateName: json['stateName'] as String?,
      districtName: json['districtName'] as String?,
      cityName: json['cityName'] as String?,
      localityName: json['localityName'] as String?,
      areaName: json['areaName'] as String?,
      pincode: json['pincode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: (json['radiusKm'] as num?)?.toDouble(),
      selectedLocalities: (json['selectedLocalities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      hasExplicitSelection: json['hasExplicitSelection'] as bool? ?? false,
      isAllIndia: json['isAllIndia'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        countryCode,
        countryName,
        stateCode,
        stateName,
        districtName,
        cityName,
        localityName,
        areaName,
        pincode,
        latitude,
        longitude,
        radiusKm,
        selectedLocalities,
        hasExplicitSelection,
        isAllIndia,
      ];
}
