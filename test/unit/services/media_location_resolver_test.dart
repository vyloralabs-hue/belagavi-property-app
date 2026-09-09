import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/services/media_location_resolver.dart';

void main() {
  group('MediaLocationResolver Tests', () {
    test('User-selected location wins and canonicalizes Belgaum to Belagavi', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'belgaum',
        selectedLocality: 'tilakvadi',
      );

      expect(evidence.canonicalCity, 'Belagavi');
      expect(evidence.canonicalLocality, 'Tilakwadi');
      expect(evidence.source, LocationEvidenceSource.userSelected);
      expect(evidence.confidence, greaterThanOrEqualTo(0.9));
      expect(evidence.conflictDetected, isFalse);
    });

    test('Map pin coordinates take priority over default coordinates', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Tilakwadi',
        mapPinLatitude: 15.8450,
        mapPinLongitude: 74.5020,
      );

      expect(evidence.source, LocationEvidenceSource.mapPin);
      expect(evidence.latitude, 15.8450);
      expect(evidence.longitude, 74.5020);
      expect(evidence.confidence, 1.0);
    });

    test('EXIF coordinates used only if stronger evidence (map pin/foreground) is absent', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Tilakwadi',
        photoExifLatitude: 15.8490,
        photoExifLongitude: 74.4980,
      );

      expect(evidence.source, LocationEvidenceSource.photoExif);
      expect(evidence.latitude, 15.8490);
      expect(evidence.longitude, 74.4980);
      expect(evidence.confidence, 0.85);
    });

    test('EXIF missing fallback works cleanly with city reference coordinates', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Camp',
      );

      expect(evidence.canonicalCity, 'Belagavi');
      expect(evidence.canonicalLocality, 'Camp');
      expect(evidence.hasCoordinates, isTrue);
      expect(evidence.latitude, 15.8497);
      expect(evidence.longitude, 74.4977);
      expect(evidence.source, LocationEvidenceSource.userSelected);
    });

    test('Conflicting EXIF does NOT overwrite explicit location, marks conflict detected', () {
      // Seller chose Belagavi / Tilakwadi, but photo was taken in Bengaluru (>500km away)
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'Tilakwadi',
        mapPinLatitude: 15.8450,
        mapPinLongitude: 74.5020,
        photoExifCity: 'Bengaluru',
        photoExifLatitude: 12.9716,
        photoExifLongitude: 77.5946,
      );

      // Property location MUST remain Belagavi / Tilakwadi
      expect(evidence.canonicalCity, 'Belagavi');
      expect(evidence.canonicalLocality, 'Tilakwadi');
      // Map pin coordinates are retained
      expect(evidence.latitude, 15.8450);
      expect(evidence.longitude, 74.5020);
      // Conflict MUST be flagged
      expect(evidence.conflictDetected, isTrue);
      expect(evidence.conflictDetails, contains('differs from selected property city'));
    });

    test('Aliases are canonicalized properly: Hubli -> Hubballi, Piranvadi -> Piranwadi', () {
      final cityEvidence = MediaLocationResolver.resolve(
        selectedCity: 'hubli',
      );
      expect(cityEvidence.canonicalCity, 'Hubballi');

      final locEvidence = MediaLocationResolver.resolve(
        selectedCity: 'Belagavi',
        selectedLocality: 'piranvadi',
      );
      expect(locEvidence.canonicalLocality, 'Piranwadi');
    });

    test('Dharwad remains Dharwad without incorrect aliasing', () {
      final evidence = MediaLocationResolver.resolve(
        selectedCity: 'Dharwad',
      );

      expect(evidence.canonicalCity, 'Dharwad');
    });
  });
}
