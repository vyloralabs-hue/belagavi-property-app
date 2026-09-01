import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/geography_entities.dart';
import '../../domain/repositories/geography_repository.dart';
import '../datasources/geography_local_cache_datasource.dart';
import '../datasources/geography_remote_datasource.dart';

@LazySingleton(as: GeographyRepository)
class GeographyRepositoryImpl extends BaseRepository implements GeographyRepository {
  final GeographyRemoteDataSource _remoteDataSource;
  final GeographyLocalCacheDataSource _cacheDataSource;

  GeographyRepositoryImpl(this._remoteDataSource, this._cacheDataSource);

  @override
  FutureEither<List<CountryEntity>> getCountries() async {
    return safeCall(() async {
      final cached = _cacheDataSource.getCachedCountries();
      if (cached != null && cached.isNotEmpty) return cached;
      final remote = await _remoteDataSource.fetchCountries();
      await _cacheDataSource.cacheCountries(remote);
      return remote;
    });
  }

  @override
  FutureEither<List<StateEntity>> getStates({String countryCode = 'IN'}) async {
    return safeCall(() async {
      final cached = _cacheDataSource.getCachedStates(countryCode: countryCode);
      if (cached != null && cached.isNotEmpty) return cached;
      final remoteStates = await _remoteDataSource.fetchStates(countryCode);
      await _cacheDataSource.cacheStates(remoteStates, countryCode: countryCode);
      return remoteStates;
    });
  }

  @override
  FutureEither<List<DistrictEntity>> getDistricts(String stateId) async {
    return safeCall(() => _remoteDataSource.fetchDistricts(stateId));
  }

  @override
  FutureEither<List<TalukEntity>> getTaluks(String districtId) async {
    return safeCall(() => _remoteDataSource.fetchTaluks(districtId));
  }

  @override
  FutureEither<List<CityEntity>> getCities(String talukId) async {
    return safeCall(() => _remoteDataSource.fetchCities(talukId));
  }

  @override
  FutureEither<List<LocalityEntity>> getLocalities(String cityId) async {
    return safeCall(() => _remoteDataSource.fetchLocalities(cityId));
  }

  @override
  FutureEither<List<AreaEntity>> getAreas(String localityId) async {
    return safeCall(() => _remoteDataSource.fetchAreas(localityId));
  }

  @override
  FutureEither<LocalityEntity?> getLocalityByPincode(String pincode) async {
    return safeCall(() => _remoteDataSource.fetchLocalityByPincode(pincode));
  }

  @override
  FutureEither<List<LocalityEntity>> searchLocalities(String query) async {
    return safeCall(() => _remoteDataSource.searchLocalities(query));
  }
}
