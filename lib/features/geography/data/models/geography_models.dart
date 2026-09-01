import '../../domain/entities/geography_entities.dart';

// ─── Country Model ────────────────────────────────────────────────────────────
class CountryModel extends CountryEntity {
  const CountryModel({
    required super.code,
    required super.name,
    super.dialCode = '',
    super.currencyCode = '',
    super.currencySymbol = '',
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dialCode: json['dial_code'] as String? ?? '',
      currencyCode: json['currency_code'] as String? ?? '',
      currencySymbol: json['currency_symbol'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'dial_code': dialCode,
        'currency_code': currencyCode,
        'currency_symbol': currencySymbol,
      };
}

// ─── State Model ──────────────────────────────────────────────────────────────
class StateModel extends StateEntity {
  const StateModel({
    required super.id,
    super.countryCode = 'IN',
    required super.name,
    required super.code,
    super.isUnionTerritory = false,
    super.translations,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? 'IN',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      isUnionTerritory: json['is_union_territory'] as bool? ?? false,
      translations: (json['translations'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'country_code': countryCode,
        'name': name,
        'code': code,
        'is_union_territory': isUnionTerritory,
        'translations': translations,
      };
}

// ─── District Model ───────────────────────────────────────────────────────────
class DistrictModel extends DistrictEntity {
  const DistrictModel({
    required super.id,
    required super.stateId,
    required super.name,
    required super.stateCode,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as String? ?? '',
      stateId: json['state_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      stateCode: json['state_code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'state_id': stateId,
        'name': name,
        'state_code': stateCode,
      };
}

// ─── Taluk Model ──────────────────────────────────────────────────────────────
class TalukModel extends TalukEntity {
  const TalukModel({
    required super.id,
    required super.districtId,
    required super.name,
  });

  factory TalukModel.fromJson(Map<String, dynamic> json) {
    return TalukModel(
      id: json['id'] as String? ?? '',
      districtId: json['district_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'district_id': districtId,
        'name': name,
      };
}

// ─── City Model ───────────────────────────────────────────────────────────────
class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.talukId,
    required super.name,
    super.isTier1 = false,
    super.isTier2 = true,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String? ?? '',
      talukId: json['taluk_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isTier1: json['is_tier1'] as bool? ?? false,
      isTier2: json['is_tier2'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'taluk_id': talukId,
        'name': name,
        'is_tier1': isTier1,
        'is_tier2': isTier2,
      };
}

// ─── Locality Model ───────────────────────────────────────────────────────────
class LocalityModel extends LocalityEntity {
  const LocalityModel({
    required super.id,
    required super.cityId,
    required super.name,
    required super.pincode,
    super.latitude,
    super.longitude,
  });

  factory LocalityModel.fromJson(Map<String, dynamic> json) {
    return LocalityModel(
      id: json['id'] as String? ?? '',
      cityId: json['city_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'city_id': cityId,
        'name': name,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
      };
}

// ─── Area Model ───────────────────────────────────────────────────────────────
class AreaModel extends AreaEntity {
  const AreaModel({
    required super.id,
    required super.localityId,
    required super.name,
    super.areaCode,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as String? ?? '',
      localityId: json['locality_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      areaCode: json['area_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'locality_id': localityId,
        'name': name,
        'area_code': areaCode,
      };
}
