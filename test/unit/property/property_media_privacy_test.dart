import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/services/media_location_resolver.dart';

void main() {
  group('Property Media Privacy & Location Evidence Tests', () {
    test('Explicit seller location strictly wins over photo EXIF metadata', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Tilakwadi',
        selectedState: 'Karnataka',
        mapPinLatitude: 15.8450,
        mapPinLongitude: 74.5020,
        photoExifCity: 'Goa',
        photoExifLatitude: 15.2993,
        photoExifLongitude: 74.1240,
      );

      // Property location MUST be the seller-selected location
      expect(evidence.canonicalCity, 'Belagavi');
      expect(evidence.canonicalLocality, 'Tilakwadi');
      expect(evidence.canonicalState, 'Karnataka');
      // Coordinates MUST be the explicit map pin
      expect(evidence.latitude, 15.8450);
      expect(evidence.longitude, 74.5020);
      expect(evidence.source, LocationEvidenceSource.mapPin);
      expect(evidence.conflictDetected, isTrue);
      expect(evidence.conflictDetails, contains('Photo capture location'));
    });

    test('Conflicting photo GPS (>50km away) triggers conflict flag and preserves explicit pin', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Shahapur',
        mapPinLatitude: 15.8500,
        mapPinLongitude: 74.5000,
        // Photo taken in Bengaluru (>450km away)
        photoExifLatitude: 12.9716,
        photoExifLongitude: 77.5946,
      );

      expect(evidence.conflictDetected, isTrue);
      expect(evidence.conflictDetails, contains('away from property location'));
      expect(evidence.latitude, 15.8500);
      expect(evidence.longitude, 74.5000);
    });

    test('Permitted EXIF GPS is used as fallback coordinates ONLY when no map pin exists', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Tilakwadi',
        mapPinLatitude: null,
        mapPinLongitude: null,
        photoExifLatitude: 15.8460,
        photoExifLongitude: 74.5030,
      );

      expect(evidence.latitude, 15.8460);
      expect(evidence.longitude, 74.5030);
      expect(evidence.source, LocationEvidenceSource.photoExif);
      expect(evidence.conflictDetected, isFalse);
    });

    test('Missing EXIF GPS falls back safely to city center reference without throwing', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Camp',
      );

      expect(evidence.canonicalCity, 'Belagavi');
      expect(evidence.canonicalLocality, 'Camp');
      expect(evidence.latitude, isNotNull);
      expect(evidence.longitude, isNotNull);
      expect(evidence.source, LocationEvidenceSource.userSelected);
      expect(evidence.conflictDetected, isFalse);
    });
  });
}
