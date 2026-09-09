import 'dart:math';
import '../../../core/utils/app_logger.dart';
import '../../property_search/utils/india_location_directory.dart';

/// Provenance source of location evidence
enum LocationEvidenceSource {
  userSelected,
  mapPin,
  foregroundDevice,
  photoExif,
  unknown,
}

/// Structured evidence and intelligence for property location
class MediaLocationEvidence {
  final LocationEvidenceSource source;
  final String canonicalCity;
  final String canonicalLocality;
  final String canonicalState;
  final double? latitude;
  final double? longitude;
  final double confidence; // 0.0 to 1.0
  final bool userConfirmed;
  final bool conflictDetected;
  final String? conflictDetails;

  const MediaLocationEvidence({
    required this.source,
    required this.canonicalCity,
    required this.canonicalLocality,
    this.canonicalState = 'Karnataka',
    this.latitude,
    this.longitude,
    this.confidence = 1.0,
    this.userConfirmed = true,
    this.conflictDetected = false,
    this.conflictDetails,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  String get displayAddress {
    final parts = <String>[];
    if (canonicalLocality.isNotEmpty) parts.add(canonicalLocality);
    if (canonicalCity.isNotEmpty) parts.add(canonicalCity);
    if (canonicalState.isNotEmpty) parts.add(canonicalState);
    return parts.join(', ');
  }

  MediaLocationEvidence copyWith({
    LocationEvidenceSource? source,
    String? canonicalCity,
    String? canonicalLocality,
    String? canonicalState,
    double? latitude,
    double? longitude,
    double? confidence,
    bool? userConfirmed,
    bool? conflictDetected,
    String? conflictDetails,
  }) {
    return MediaLocationEvidence(
      source: source ?? this.source,
      canonicalCity: canonicalCity ?? this.canonicalCity,
      canonicalLocality: canonicalLocality ?? this.canonicalLocality,
      canonicalState: canonicalState ?? this.canonicalState,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      confidence: confidence ?? this.confidence,
      userConfirmed: userConfirmed ?? this.userConfirmed,
      conflictDetected: conflictDetected ?? this.conflictDetected,
      conflictDetails: conflictDetails ?? this.conflictDetails,
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source.name,
        'canonical_city': canonicalCity,
        'canonical_locality': canonicalLocality,
        'canonical_state': canonicalState,
        'latitude': latitude,
        'longitude': longitude,
        'confidence': confidence,
        'user_confirmed': userConfirmed,
        'conflict_detected': conflictDetected,
        'conflict_details': conflictDetails,
      };

  factory MediaLocationEvidence.fromJson(Map<String, dynamic> json) {
    return MediaLocationEvidence(
      source: LocationEvidenceSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => LocationEvidenceSource.unknown,
      ),
      canonicalCity: json['canonical_city'] as String? ?? 'Belagavi',
      canonicalLocality: json['canonical_locality'] as String? ?? '',
      canonicalState: json['canonical_state'] as String? ?? 'Karnataka',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      userConfirmed: json['user_confirmed'] as bool? ?? true,
      conflictDetected: json['conflict_detected'] as bool? ?? false,
      conflictDetails: json['conflict_details'] as String?,
    );
  }
}

/// Core location intelligence and resolution engine
class MediaLocationResolver {
  MediaLocationResolver._();

  /// Approximate reference coordinates for well-known hub cities
  static const Map<String, (double, double)> _cityReferencePoints = {
    'belagavi': (15.8497, 74.4977),
    'hubballi': (15.3647, 75.1240),
    'dharwad': (15.4589, 75.0078),
    'bengaluru': (12.9716, 77.5946),
    'pune': (18.5204, 73.8567),
    'mumbai': (19.0760, 72.8777),
  };

  /// Resolves location according to strict priority order:
  /// 1. Explicit seller-selected locality & city
  /// 2. Explicit interactive map pin
  /// 3. Foreground device GPS captured in current session
  /// 4. Permitted photo EXIF GPS (evidence only, NEVER overwrites user selection)
  /// 5. Unknown / fallback
  static MediaLocationEvidence resolve({
    String? selectedCity,
    String? selectedLocality,
    String? selectedState,
    double? mapPinLatitude,
    double? mapPinLongitude,
    double? foregroundLatitude,
    double? foregroundLongitude,
    double? photoExifLatitude,
    double? photoExifLongitude,
    String? photoExifCity,
    String? photoExifLocality,
  }) {
    // 1. Canonicalize explicit inputs
    final rawCity = (selectedCity != null && selectedCity.trim().isNotEmpty)
        ? selectedCity.trim()
        : 'Belagavi';
    final canonicalCity = IndiaLocationDirectory.normalizeCityName(rawCity);

    final rawLocality = (selectedLocality != null && selectedLocality.trim().isNotEmpty)
        ? selectedLocality.trim()
        : '';
    final canonicalLocality = IndiaLocationDirectory.normalizeLocalityName(
      rawLocality,
      canonicalCity,
    );

    final rawState = (selectedState != null && selectedState.trim().isNotEmpty)
        ? selectedState.trim()
        : 'Karnataka';
    final canonicalState = IndiaLocationDirectory.normalizeStateName(rawState);

    // 2. Determine coordinates by strict priority
    double? resolvedLat;
    double? resolvedLng;
    LocationEvidenceSource source;
    double confidence;

    if (mapPinLatitude != null && mapPinLongitude != null) {
      resolvedLat = mapPinLatitude;
      resolvedLng = mapPinLongitude;
      source = LocationEvidenceSource.mapPin;
      confidence = 1.0;
    } else if (foregroundLatitude != null && foregroundLongitude != null) {
      resolvedLat = foregroundLatitude;
      resolvedLng = foregroundLongitude;
      source = LocationEvidenceSource.foregroundDevice;
      confidence = 0.95;
    } else if (photoExifLatitude != null && photoExifLongitude != null) {
      // EXIF coordinates present: use as coordinate evidence ONLY if map pin is absent
      resolvedLat = photoExifLatitude;
      resolvedLng = photoExifLongitude;
      source = LocationEvidenceSource.photoExif;
      confidence = 0.85;
    } else {
      // Fallback to default city center coordinates if available
      final ref = _cityReferencePoints[canonicalCity.toLowerCase()];
      if (ref != null) {
        resolvedLat = ref.$1;
        resolvedLng = ref.$2;
      }
      source = LocationEvidenceSource.userSelected;
      confidence = 0.9;
    }

    // 3. Conflict Detection: Photo metadata vs Explicit Seller Location
    bool conflictDetected = false;
    String? conflictDetails;

    // Check if photo EXIF city was provided and disagrees with canonical city
    if (photoExifCity != null && photoExifCity.trim().isNotEmpty) {
      final normExifCity = IndiaLocationDirectory.normalizeCityName(photoExifCity.trim());
      if (normExifCity.toLowerCase() != canonicalCity.toLowerCase()) {
        conflictDetected = true;
        conflictDetails =
            'Photo capture location ($normExifCity) differs from selected property city ($canonicalCity). Explicit seller location retained.';
        AppLogger.w('[MediaLocationResolver] Conflict: $conflictDetails');
      }
    }

    // Check coordinate distance if EXIF GPS is available
    if (!conflictDetected &&
        photoExifLatitude != null &&
        photoExifLongitude != null &&
        resolvedLat != null &&
        resolvedLng != null) {
      final distKm = _calculateHaversineDistanceKm(
        photoExifLatitude,
        photoExifLongitude,
        resolvedLat,
        resolvedLng,
      );

      // If photo was taken more than 50km away from property coordinates:
      if (distKm > 50.0) {
        conflictDetected = true;
        conflictDetails =
            'Photo GPS coordinates are ${distKm.toStringAsFixed(1)} km away from property location. Explicit property location retained.';
        AppLogger.w('[MediaLocationResolver] EXIF GPS distance anomaly: $conflictDetails');

        // Ensure photo EXIF DOES NOT contaminate property coordinates if there was an explicit map pin
        if (mapPinLatitude != null && mapPinLongitude != null) {
          resolvedLat = mapPinLatitude;
          resolvedLng = mapPinLongitude;
          source = LocationEvidenceSource.mapPin;
        }
      }
    }

    return MediaLocationEvidence(
      source: source,
      canonicalCity: canonicalCity,
      canonicalLocality: canonicalLocality,
      canonicalState: canonicalState,
      latitude: resolvedLat,
      longitude: resolvedLng,
      confidence: confidence,
      userConfirmed: true,
      conflictDetected: conflictDetected,
      conflictDetails: conflictDetails,
    );
  }

  /// Calculates distance in km between two GPS points using Haversine formula
  static double _calculateHaversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0; // Earth radius in km
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLon = (lon2 - lon1) * (pi / 180.0);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }
}
