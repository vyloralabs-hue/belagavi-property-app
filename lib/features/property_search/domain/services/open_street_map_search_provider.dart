import 'package:dio/dio.dart';
import '../../../../core/utils/app_logger.dart';
import '../../utils/india_location_directory.dart';
import 'location_search_provider.dart';

/// OpenStreetMap Nominatim implementation of LocationSearchProvider with
/// local directory fallback for fast, resilient offline/online search.
class OpenStreetMapSearchProvider implements LocationSearchProvider {
  final Dio _dio;

  // In-memory query cache with TTL (15 minutes)
  static final Map<String, (DateTime timestamp, List<GeocodedPlace> results)> _queryCache = {};
  static final Map<String, (DateTime timestamp, GeocodedPlace place)> _reverseCache = {};
  static DateTime _lastNetworkRequestTime = DateTime.fromMillisecondsSinceEpoch(0);
  CancelToken? _activeCancelToken;

  OpenStreetMapSearchProvider({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                headers: {
                  'User-Agent': 'BelagaviPropertyApp/1.0 (info@belagaviproperty.com)',
                },
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
              ),
            );

  @override
  String get name => 'OpenStreetMap (Nominatim)';

  @override
  Future<List<GeocodedPlace>> searchPlaces(
    String query, {
    double? biasLatitude,
    double? biasLongitude,
    int limit = 10,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return const [];

    final cacheKey = '${cleanQuery.toLowerCase()}_${biasLatitude?.toStringAsFixed(2)}_${biasLongitude?.toStringAsFixed(2)}_$limit';
    final cached = _queryCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.$1).inMinutes < 15) {
      return cached.$2;
    }

    final results = <GeocodedPlace>[];

    // 1. Check local directory candidates first (instant, works offline, zero network quota)
    final directoryMatches = IndiaLocationDirectory.searchLocations(cleanQuery, limit: limit);
    for (final m in directoryMatches) {
      // If candidate has lat/lng or default city lat/lng
      results.add(
        GeocodedPlace(
          id: 'dir_${m.id}',
          displayName: '${m.name}, ${m.cityName}, ${m.stateName}',
          mainText: m.name,
          secondaryText: '${m.cityName}, ${m.stateName}',
          latitude: m.latitude ?? 15.8497,
          longitude: m.longitude ?? 74.4977,
          locality: m.localityName,
          city: m.cityName,
          state: m.stateName,
          pincode: m.pincode,
          providerName: 'Directory',
        ),
      );
    }

    // 2. Query Nominatim for live pan-India street / landmark / road geocoding
    // Cancel any previous in-flight search request to prevent race conditions
    _activeCancelToken?.cancel('Superseded by newer query');
    _activeCancelToken = CancelToken();

    // Throttled to respect Nominatim 1 req/sec policy
    final now = DateTime.now();
    final elapsed = now.difference(_lastNetworkRequestTime);
    if (elapsed.inMilliseconds < 1000) {
      await Future<void>.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
    }
    _lastNetworkRequestTime = DateTime.now();

    try {
      final queryParams = <String, dynamic>{
        'q': cleanQuery,
        'format': 'json',
        'addressdetails': '1',
        'limit': limit,
        'countrycodes': 'in', // Pan-India scope
      };

      if (biasLatitude != null && biasLongitude != null) {
        // Use viewbox bounded to ~50km around bias
        queryParams['viewbox'] =
            '${biasLongitude - 0.4},${biasLatitude + 0.4},${biasLongitude + 0.4},${biasLatitude - 0.4}';
        queryParams['bounded'] = '0'; // Bias rather than strictly restrict
      }

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: queryParams,
        cancelToken: _activeCancelToken,
      );

      if (response.statusCode == 200 && response.data is List) {
        for (final item in (response.data as List)) {
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          if (lat == null || lon == null) continue;

          final address = item['address'] as Map<String, dynamic>? ?? {};
          final road = address['road'] as String?;
          final suburb = address['suburb'] as String? ?? address['neighbourhood'] as String?;
          final city = address['city'] as String? ??
              address['town'] as String? ??
              address['village'] as String? ??
              address['municipality'] as String?;
          final county = address['county'] as String?; // Often district/taluk
          final state = address['state'] as String?;
          final postcode = address['postcode'] as String?;

          final displayName = item['display_name'] as String? ?? cleanQuery;
          final mainText = road ?? suburb ?? city ?? cleanQuery;
          final secondaryText = [suburb, city, state].where((s) => s != null && s.isNotEmpty).join(', ');

          // Prevent exact duplicate id/coords
          if (!results.any((r) => (r.latitude - lat).abs() < 0.0001 && (r.longitude - lon).abs() < 0.0001)) {
            results.add(
              GeocodedPlace(
                id: 'osm_${item['place_id'] ?? lat}_$lon',
                displayName: displayName,
                mainText: mainText,
                secondaryText: secondaryText.isNotEmpty ? secondaryText : displayName,
                latitude: lat,
                longitude: lon,
                street: road,
                locality: suburb,
                taluk: county,
                city: city,
                district: county,
                state: state,
                pincode: postcode,
                providerName: name,
              ),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.w('Nominatim geocode error: $e, continuing with local directory results');
    }

    final finalResults = results.take(limit).toList();
    _queryCache[cacheKey] = (DateTime.now(), finalResults);
    return finalResults;
  }

  @override
  Future<GeocodedPlace?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
    final cached = _reverseCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.$1).inMinutes < 60) {
      return cached.$2;
    }

    try {
      final now = DateTime.now();
      final elapsed = now.difference(_lastNetworkRequestTime);
      if (elapsed.inMilliseconds < 1000) {
        await Future<void>.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
      }
      _lastNetworkRequestTime = DateTime.now();

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'format': 'json',
          'addressdetails': '1',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        final road = address['road'] as String?;
        final suburb = address['suburb'] as String? ?? address['neighbourhood'] as String?;
        final city = address['city'] as String? ??
            address['town'] as String? ??
            address['village'] as String?;
        final county = address['county'] as String?;
        final state = address['state'] as String?;
        final postcode = address['postcode'] as String?;

        final displayName = data['display_name'] as String? ?? 'Pinned Location';
        final mainText = road ?? suburb ?? city ?? 'Custom Location';
        final secondaryText = [suburb, city, state].where((s) => s != null && s.isNotEmpty).join(', ');

        final place = GeocodedPlace(
          id: 'osm_rev_${data['place_id'] ?? latitude}',
          displayName: displayName,
          mainText: mainText,
          secondaryText: secondaryText.isNotEmpty ? secondaryText : displayName,
          latitude: latitude,
          longitude: longitude,
          street: road,
          locality: suburb,
          taluk: county,
          city: city,
          district: county,
          state: state,
          pincode: postcode,
          providerName: name,
        );

        _reverseCache[cacheKey] = (DateTime.now(), place);
        return place;
      }
    } catch (e) {
      AppLogger.w('Nominatim reverse geocode error: $e');
    }

    // Fallback: structured reverse representation
    final fallbackPlace = GeocodedPlace(
      id: 'rev_${latitude}_$longitude',
      displayName: 'Location (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
      mainText: 'Location (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
      secondaryText: 'India',
      latitude: latitude,
      longitude: longitude,
      providerName: 'Fallback Coords',
    );
    _reverseCache[cacheKey] = (DateTime.now(), fallbackPlace);
    return fallbackPlace;
  }
}
