import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/local_storage.dart';
import '../models/geography_models.dart';

abstract class GeographyLocalCacheDataSource {
  Future<void> cacheCountries(List<CountryModel> countries);
  List<CountryModel>? getCachedCountries();

  Future<void> cacheStates(List<StateModel> states, {String countryCode = 'IN'});
  List<StateModel>? getCachedStates({String countryCode = 'IN'});
}

@LazySingleton(as: GeographyLocalCacheDataSource)
class GeographyLocalCacheDataSourceImpl implements GeographyLocalCacheDataSource {
  final LocalStorage _localStorage;

  static const String _countriesCacheKey = 'cached_countries_v1';
  static String _statesCacheKey(String countryCode) => 'cached_states_${countryCode}_v1';

  GeographyLocalCacheDataSourceImpl(this._localStorage);

  @override
  Future<void> cacheCountries(List<CountryModel> countries) async {
    try {
      final jsonList = countries.map((c) => c.toJson()).toList();
      await _localStorage.put(_countriesCacheKey, jsonList);
      AppLogger.d('Cached ${countries.length} countries locally.');
    } catch (e) {
      AppLogger.w('Failed to cache countries locally: $e');
    }
  }

  @override
  List<CountryModel>? getCachedCountries() {
    try {
      final raw = _localStorage.get(_countriesCacheKey);
      if (raw is List) {
        return raw
            .map((json) => CountryModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
    } catch (e) {
      AppLogger.w('Failed to read cached countries: $e');
    }
    return null;
  }

  @override
  Future<void> cacheStates(List<StateModel> states, {String countryCode = 'IN'}) async {
    try {
      final jsonList = states.map((s) => s.toJson()).toList();
      await _localStorage.put(_statesCacheKey(countryCode), jsonList);
      AppLogger.d('Cached ${states.length} states for $countryCode locally.');
    } catch (e) {
      AppLogger.w('Failed to cache states locally: $e');
    }
  }

  @override
  List<StateModel>? getCachedStates({String countryCode = 'IN'}) {
    try {
      final raw = _localStorage.get(_statesCacheKey(countryCode));
      if (raw is List) {
        return raw
            .map((json) => StateModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
    } catch (e) {
      AppLogger.w('Failed to read cached states: $e');
    }
    return null;
  }
}
