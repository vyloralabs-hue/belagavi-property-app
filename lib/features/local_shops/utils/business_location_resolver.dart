import 'package:belagavi_property/features/geography/domain/entities/geography_entities.dart';

class ResolvedBusinessLocation {
  final String countryCode;
  final String stateId;
  final String districtId;
  final String cityId;
  final String localityId;
  final String? areaId;
  final String displayLabel;

  const ResolvedBusinessLocation({
    this.countryCode = 'IN',
    required this.stateId,
    required this.districtId,
    required this.cityId,
    required this.localityId,
    this.areaId,
    required this.displayLabel,
  });
}

class BusinessLocationResolver {
  /// Deterministic location resolution mapping user input text to location hierarchy (0 AI)
  static ResolvedBusinessLocation resolve(String input) {
    final query = input.trim().toLowerCase();

    if (query.contains('tilakwadi') || query.contains('camp')) {
      return const ResolvedBusinessLocation(
        countryCode: 'IN',
        stateId: 'st_karnataka',
        districtId: 'dst_belagavi',
        cityId: 'ct_belagavi',
        localityId: 'loc_tilakwadi',
        displayLabel: 'Tilakwadi, Belagavi, Karnataka',
      );
    } else if (query.contains('kothrud') || query.contains('pune')) {
      return const ResolvedBusinessLocation(
        countryCode: 'IN',
        stateId: 'st_maharashtra',
        districtId: 'dst_pune',
        cityId: 'ct_pune',
        localityId: 'loc_kothrud',
        displayLabel: 'Kothrud, Pune, Maharashtra',
      );
    } else if (query.contains('rohini') || query.contains('delhi')) {
      return const ResolvedBusinessLocation(
        countryCode: 'IN',
        stateId: 'st_delhi',
        districtId: 'dst_delhi_north',
        cityId: 'ct_delhi',
        localityId: 'loc_rohini',
        displayLabel: 'Rohini, New Delhi, Delhi',
      );
    }

    // Default fallback: Belagavi City
    return const ResolvedBusinessLocation(
      countryCode: 'IN',
      stateId: 'st_karnataka',
      districtId: 'dst_belagavi',
      cityId: 'ct_belagavi',
      localityId: 'loc_belagavi_central',
      displayLabel: 'Belagavi Central, Karnataka',
    );
  }

  /// Converts LocationSelection entity to ResolvedBusinessLocation
  static ResolvedBusinessLocation fromSelection(LocationSelection selection) {
    return ResolvedBusinessLocation(
      countryCode: selection.country?.code ?? 'IN',
      stateId: selection.state?.id ?? 'st_karnataka',
      districtId: selection.district?.id ?? 'dst_belagavi',
      cityId: selection.city?.id ?? 'ct_belagavi',
      localityId: selection.locality?.id ?? 'loc_belagavi_central',
      areaId: selection.area?.id,
      displayLabel: selection.breadcrumb,
    );
  }
}
