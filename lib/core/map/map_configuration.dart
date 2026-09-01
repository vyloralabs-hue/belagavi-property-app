/// Map and Geocoding Configuration â€” Open Source & Zero-Google-Billing
/// Allows configurable tile servers, geocoding endpoints, and fallback offline resolvers.
class MapConfiguration {
  MapConfiguration._();

  /// Default OpenStreetMap / CartoDB tile URL template (Configurable via ENV)
  static String mapTileUrlTemplate = const String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  /// Configurable Geocoding Endpoint
  static String geocodingUrl = const String.fromEnvironment(
    'GEOCODING_URL',
    defaultValue: 'https://nominatim.openstreetmap.org/search',
  );

  /// Configurable Search / PostGIS Endpoint
  static String searchApiUrl = const String.fromEnvironment(
    'SEARCH_API_URL',
    defaultValue: '',
  );

  /// Default Geographic Center (Belagavi District, Karnataka, India)
  static const double defaultLatitude = 15.8497;
  static const double defaultLongitude = 74.4977;
  static const int defaultZoom = 13;

  /// Major Indian Cities Reference Registry for Zero-Network Locality Resolution
  static const List<MapLocationPreset> majorIndianCities = [
    MapLocationPreset(
      city: 'Belagavi',
      state: 'Karnataka',
      latitude: 15.8497,
      longitude: 74.4977,
      pincode: '590001',
      localities: [
        'Tilakwadi',
        'Camp',
        'Shahapur',
        'Mandoli Road',
        'College Road',
        'Khanapur Road',
        'Bhagya Nagar',
        'Peeranwadi',
        'Udyambag',
        'Vadgaon',
        'Angol',
        'Hindwadi',
        'Sambre',
        'Kakati',
        'Kudachi',
      ],
    ),
    MapLocationPreset(
      city: 'Bengaluru',
      state: 'Karnataka',
      latitude: 12.9716,
      longitude: 77.5946,
      pincode: '560001',
      localities: [
        'Whitefield',
        'Indiranagar',
        'Koramangala',
        'HSR Layout',
        'Jayanagar',
        'Electronic City',
        'Hebbal',
        'Yelahanka',
        'Marathahalli',
        'Banashankari',
      ],
    ),
    MapLocationPreset(
      city: 'Hubballi-Dharwad',
      state: 'Karnataka',
      latitude: 15.3647,
      longitude: 75.1240,
      pincode: '580020',
      localities: [
        'Vidyanagar',
        'Gokul Road',
        'Navanagar',
        'Keshwapur',
        'Sattur',
      ],
    ),
    MapLocationPreset(
      city: 'Mumbai',
      state: 'Maharashtra',
      latitude: 19.0760,
      longitude: 72.8777,
      pincode: '400001',
      localities: [
        'Bandra',
        'Andheri',
        'Juhu',
        'Powai',
        'Borivali',
        'Dadar',
        'Thane',
        'Navi Mumbai',
      ],
    ),
    MapLocationPreset(
      city: 'Pune',
      state: 'Maharashtra',
      latitude: 18.5204,
      longitude: 73.8567,
      pincode: '411001',
      localities: [
        'Kothrud',
        'Baner',
        'Wakad',
        'Hinjewadi',
        'Viman Nagar',
        'Kalyani Nagar',
        'Hadapsar',
      ],
    ),
    MapLocationPreset(
      city: 'Kolhapur',
      state: 'Maharashtra',
      latitude: 16.7050,
      longitude: 74.2433,
      pincode: '416001',
      localities: [
        'Tarabai Park',
        'Rajarampuri',
        'Nagala Park',
        'Shahupuri',
      ],
    ),
    MapLocationPreset(
      city: 'Goa',
      state: 'Goa',
      latitude: 15.2993,
      longitude: 74.1240,
      pincode: '403001',
      localities: [
        'Panaji',
        'Margao',
        'Vasco da Gama',
        'Mapusa',
        'Porvorim',
        'Candolim',
      ],
    ),
    MapLocationPreset(
      city: 'Delhi NCR',
      state: 'Delhi',
      latitude: 28.6139,
      longitude: 77.2090,
      pincode: '110001',
      localities: [
        'Connaught Place',
        'South Extension',
        'Dwarka',
        'Saket',
        'Noida Sector 62',
        'Gurugram Cyber Hub',
      ],
    ),
    MapLocationPreset(
      city: 'Hyderabad',
      state: 'Telangana',
      latitude: 17.3850,
      longitude: 78.4867,
      pincode: '500001',
      localities: [
        'Gachibowli',
        'Hitec City',
        'Jubilee Hills',
        'Banjara Hills',
        'Madhapur',
        'Kukatpally',
      ],
    ),
    MapLocationPreset(
      city: 'Chennai',
      state: 'Tamil Nadu',
      latitude: 13.0827,
      longitude: 80.2707,
      pincode: '600001',
      localities: [
        'Anna Nagar',
        'T Nagar',
        'Adyar',
        'Velachery',
        'OMR',
      ],
    ),
  ];

  /// Resolves any Indian locality or city query deterministically
  static MapLocationPreset? resolveLocation(String query) {
    if (query.trim().isEmpty) return null;
    final q = query.toLowerCase().trim();

    // Check locality match
    for (final city in majorIndianCities) {
      for (final loc in city.localities) {
        if (loc.toLowerCase() == q || loc.toLowerCase().contains(q) || q.contains(loc.toLowerCase())) {
          return city;
        }
      }
    }

    // Check city name match
    for (final city in majorIndianCities) {
      if (city.city.toLowerCase() == q || city.city.toLowerCase().contains(q) || q.contains(city.city.toLowerCase())) {
        return city;
      }
    }

    return null;
  }

  /// Dynamically resolves latitude/longitude center for a given city or locality,
  /// falling back to Belagavi default if unresolvable.
  static (double lat, double lng) resolveCenterForLocation({
    String? city,
    String? locality,
    double? fallbackLat,
    double? fallbackLng,
  }) {
    if (fallbackLat != null && fallbackLng != null && fallbackLat != 0 && fallbackLng != 0) {
      return (fallbackLat, fallbackLng);
    }
    if (locality != null && locality.isNotEmpty) {
      final locPreset = resolveLocation(locality);
      if (locPreset != null) return (locPreset.latitude, locPreset.longitude);
    }
    if (city != null && city.isNotEmpty) {
      final cityPreset = resolveLocation(city);
      if (cityPreset != null) return (cityPreset.latitude, cityPreset.longitude);
    }
    return (defaultLatitude, defaultLongitude);
  }
}


class MapLocationPreset {
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String pincode;
  final List<String> localities;

  const MapLocationPreset({
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.pincode,
    required this.localities,
  });
}