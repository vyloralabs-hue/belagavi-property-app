import 'package:equatable/equatable.dart';

/// Base ISO Country Entity for international expansion
class CountryEntity extends Equatable {
  final String code; // e.g. 'IN', 'US', 'AE', 'GB', 'SG'
  final String name;
  final String dialCode; // e.g. '+91', '+1', '+44'
  final String currencyCode; // e.g. 'INR', 'USD', 'GBP'
  final String currencySymbol; // e.g. '₹', '$', '£'

  const CountryEntity({
    required this.code,
    required this.name,
    this.dialCode = '',
    this.currencyCode = '',
    this.currencySymbol = '',
  });

  @override
  List<Object?> get props => [code, name, dialCode, currencyCode, currencySymbol];
}

/// State / Province / Region Entity — worldwide compatible
class StateEntity extends Equatable {
  final String id;
  final String countryCode;
  final String name;
  final String code; // e.g. 'KA', 'MH', 'CA', 'ENG'
  final bool isUnionTerritory;
  final Map<String, String>? translations; // e.g. {'kn': 'ಕರ್ನಾಟಕ', 'hi': 'कर्नाटक'}

  const StateEntity({
    required this.id,
    this.countryCode = 'IN',
    required this.name,
    required this.code,
    this.isUnionTerritory = false,
    this.translations,
  });

  @override
  List<Object?> get props => [id, countryCode, name, code, isUnionTerritory, translations];
}

/// District / County / Region Entity
class DistrictEntity extends Equatable {
  final String id;
  final String stateId;
  final String name;
  final String stateCode;

  const DistrictEntity({
    required this.id,
    required this.stateId,
    required this.name,
    required this.stateCode,
  });

  @override
  List<Object?> get props => [id, stateId, name, stateCode];
}

/// Taluk / Tehsil / Sub-district Entity
/// Also used as generic county/region level for non-Indian geographies
class TalukEntity extends Equatable {
  final String id;
  final String districtId;
  final String name;

  const TalukEntity({
    required this.id,
    required this.districtId,
    required this.name,
  });

  @override
  List<Object?> get props => [id, districtId, name];
}

/// City / Town Entity
class CityEntity extends Equatable {
  final String id;
  final String talukId;
  final String name;
  final bool isTier1;
  final bool isTier2;

  const CityEntity({
    required this.id,
    required this.talukId,
    required this.name,
    this.isTier1 = false,
    this.isTier2 = true,
  });

  @override
  List<Object?> get props => [id, talukId, name, isTier1, isTier2];
}

/// Locality / Neighborhood / Suburb Entity
class LocalityEntity extends Equatable {
  final String id;
  final String cityId;
  final String name;
  final String pincode;
  final double? latitude;
  final double? longitude;

  const LocalityEntity({
    required this.id,
    required this.cityId,
    required this.name,
    required this.pincode,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [id, cityId, name, pincode, latitude, longitude];
}

/// Area / Micro-locality / Zone Entity (6th level)
/// e.g. Sector 12, Phase 2, Extension, Layout, Ward
class AreaEntity extends Equatable {
  final String id;
  final String localityId;
  final String name;
  final String? areaCode;

  const AreaEntity({
    required this.id,
    required this.localityId,
    required this.name,
    this.areaCode,
  });

  @override
  List<Object?> get props => [id, localityId, name, areaCode];
}

/// PIN Code / ZIP Code Entity — quick location lookup
class PincodeEntity extends Equatable {
  final String pincode;
  final String cityId;
  final String districtName;
  final String stateName;

  const PincodeEntity({
    required this.pincode,
    required this.cityId,
    required this.districtName,
    required this.stateName,
  });

  @override
  List<Object?> get props => [pincode, cityId, districtName, stateName];
}

/// Represents a fully resolved location selection across all hierarchy levels
class LocationSelection extends Equatable {
  final CountryEntity? country;
  final StateEntity? state;
  final DistrictEntity? district;
  final CityEntity? city;
  final LocalityEntity? locality;
  final AreaEntity? area;

  const LocationSelection({
    this.country,
    this.state,
    this.district,
    this.city,
    this.locality,
    this.area,
  });

  /// Default: India > Karnataka > Belagavi
  static const defaultBelagavi = LocationSelection();

  /// Builds a human-readable breadcrumb string
  String get breadcrumb {
    final parts = <String>[];
    if (country != null) parts.add(country!.name);
    if (state != null) parts.add(state!.name);
    if (district != null && district!.name != state?.name) parts.add(district!.name);
    if (city != null) parts.add(city!.name);
    if (locality != null) parts.add(locality!.name);
    if (area != null) parts.add(area!.name);
    return parts.join(' › ');
  }

  /// Returns a short location label (city or locality level)
  String get shortLabel {
    if (locality != null) return locality!.name;
    if (city != null) return city!.name;
    if (district != null) return district!.name;
    if (state != null) return state!.name;
    if (country != null) return country!.name;
    return 'Belagavi';
  }

  LocationSelection copyWith({
    CountryEntity? country,
    StateEntity? state,
    DistrictEntity? district,
    CityEntity? city,
    LocalityEntity? locality,
    AreaEntity? area,
    bool clearBelow = false,
  }) {
    return LocationSelection(
      country: country ?? this.country,
      state: clearBelow ? null : (state ?? this.state),
      district: clearBelow ? null : (district ?? this.district),
      city: clearBelow ? null : (city ?? this.city),
      locality: clearBelow ? null : (locality ?? this.locality),
      area: clearBelow ? null : (area ?? this.area),
    );
  }

  LocationSelection withCountry(CountryEntity c) => LocationSelection(country: c);
  LocationSelection withState(StateEntity s) => LocationSelection(country: country, state: s);
  LocationSelection withDistrict(DistrictEntity d) => LocationSelection(country: country, state: state, district: d);
  LocationSelection withCity(CityEntity c) => LocationSelection(country: country, state: state, district: district, city: c);
  LocationSelection withLocality(LocalityEntity l) => LocationSelection(country: country, state: state, district: district, city: city, locality: l);
  LocationSelection withArea(AreaEntity a) => LocationSelection(country: country, state: state, district: district, city: city, locality: locality, area: a);

  @override
  List<Object?> get props => [country, state, district, city, locality, area];
}
