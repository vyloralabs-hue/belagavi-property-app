class GeographyFilterHelper {
  GeographyFilterHelper._();

  /// Builds a Postgrest filter query parameters map for location queries
  static Map<String, dynamic> buildLocationFilter({
    String? stateId,
    String? districtId,
    String? talukId,
    String? cityId,
    String? localityId,
    String? pincode,
  }) {
    final filters = <String, dynamic>{};
    if (stateId != null) filters['state_id'] = stateId;
    if (districtId != null) filters['district_id'] = districtId;
    if (talukId != null) filters['taluk_id'] = talukId;
    if (cityId != null) filters['city_id'] = cityId;
    if (localityId != null) filters['locality_id'] = localityId;
    if (pincode != null) filters['pincode'] = pincode;
    return filters;
  }
}
