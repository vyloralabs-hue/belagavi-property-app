import '../../../../core/utils/typedefs.dart';
import '../entities/geography_entities.dart';

abstract class GeographyRepository {
  /// Fetch all supported countries (indexed, small dataset — safe to cache)
  FutureEither<List<CountryEntity>> getCountries();

  /// Fetch states/provinces for a given country code (e.g. 'IN', 'US')
  FutureEither<List<StateEntity>> getStates({String countryCode = 'IN'});

  /// Fetch districts/counties for a given state ID
  FutureEither<List<DistrictEntity>> getDistricts(String stateId);

  /// Fetch taluks/sub-districts for a given district ID
  FutureEither<List<TalukEntity>> getTaluks(String districtId);

  /// Fetch cities/towns for a given taluk ID
  FutureEither<List<CityEntity>> getCities(String talukId);

  /// Fetch localities/neighborhoods for a given city ID
  FutureEither<List<LocalityEntity>> getLocalities(String cityId);

  /// Fetch areas/micro-localities for a given locality ID (6th level)
  FutureEither<List<AreaEntity>> getAreas(String localityId);

  /// Look up a locality by pincode/zip code
  FutureEither<LocalityEntity?> getLocalityByPincode(String pincode);

  /// Full-text search across locality names (bounded, indexed)
  FutureEither<List<LocalityEntity>> searchLocalities(String query);
}
