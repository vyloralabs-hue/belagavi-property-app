import 'dart:math' as math;

/// Spherical geographic math and distance calculator
class GeoMath {
  GeoMath._();

  static const double earthRadiusKm = 6371.0;
  static const double earthRadiusMeters = 6371000.0;

  /// Degrees to Radians
  static double toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Radians to Degrees
  static double toDegrees(double radians) => radians * (180.0 / math.pi);

  /// Calculates the great-circle distance between two points in Kilometers using Haversine formula
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = toRadians(lat2 - lat1);
    final dLon = toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRadians(lat1)) *
            math.cos(toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculates the great-circle distance in Meters
  static double calculateDistanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return calculateDistanceKm(lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2) * 1000.0;
  }

  /// Calculates a rectangular bounding box around a center coordinate given a radius in Kilometers
  static GeoBoundingBox calculateBoundingBox({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) {
    // 1 deg latitude is approximately 111.0 km
    final latDelta = radiusKm / 111.0;
    // 1 deg longitude varies with latitude
    final latRad = toRadians(centerLat);
    final cosLat = math.cos(latRad).abs();
    final lngDelta = cosLat > 0.0001 ? (radiusKm / (111.0 * cosLat)) : latDelta;

    final minLat = (centerLat - latDelta).clamp(-90.0, 90.0);
    final maxLat = (centerLat + latDelta).clamp(-90.0, 90.0);
    final minLng = (centerLng - lngDelta).clamp(-180.0, 180.0);
    final maxLng = (centerLng + lngDelta).clamp(-180.0, 180.0);

    return GeoBoundingBox(
      south: minLat,
      north: maxLat,
      west: minLng,
      east: maxLng,
    );
  }

  /// Formats human-readable distance (e.g. "850 m", "3.4 km")
  static String formatDistance(double km) {
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return '$meters m';
    } else if (km < 10.0) {
      return '${km.toStringAsFixed(1)} km';
    } else {
      return '${km.toStringAsFixed(0)} km';
    }
  }
}

/// Geographic Bounding Box representing a rectangular viewport
class GeoBoundingBox {
  final double south;
  final double north;
  final double west;
  final double east;

  const GeoBoundingBox({
    required this.south,
    required this.north,
    required this.west,
    required this.east,
  });

  bool contains(double lat, double lng) {
    return lat >= south && lat <= north && lng >= west && lng <= east;
  }

  Map<String, double> toMap() => {
    'south': south,
    'north': north,
    'west': west,
    'east': east,
  };

  @override
  String toString() => 'GeoBoundingBox(S: $south, N: $north, W: $west, E: $east)';
}
