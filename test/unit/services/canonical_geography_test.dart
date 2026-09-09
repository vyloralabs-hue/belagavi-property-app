import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property_search/utils/india_location_directory.dart';
import 'package:belagavi_property/features/property/services/media_location_resolver.dart';

void main() {
  group('Canonical Geography Normalization Tests', () {
    test('City canonicalization and aliases', () {
      expect(IndiaLocationDirectory.normalizeCityName('Belgaum'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('belgaum'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('bgm'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('belagaon'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('Hubli'), 'Hubballi');
      expect(IndiaLocationDirectory.normalizeCityName('hubli'), 'Hubballi');
      expect(IndiaLocationDirectory.normalizeCityName('Dharwad'), 'Dharwad');
      expect(IndiaLocationDirectory.normalizeCityName('dharwar'), 'Dharwad');
      expect(IndiaLocationDirectory.normalizeCityName('Bangalore'), 'Bengaluru');
      expect(IndiaLocationDirectory.normalizeCityName('blr'), 'Bengaluru');
      expect(IndiaLocationDirectory.normalizeCityName('Poona'), 'Pune');
      expect(IndiaLocationDirectory.normalizeCityName('Bombay'), 'Mumbai');
    });

    test('Locality normalization and city scoping', () {
      expect(IndiaLocationDirectory.normalizeLocalityName('Tilakvadi', 'Belagavi'), 'Tilakwadi');
      expect(IndiaLocationDirectory.normalizeLocalityName('tilakvadi', 'Belagavi'), 'Tilakwadi');
      expect(IndiaLocationDirectory.normalizeLocalityName('Piranvadi', 'Belagavi'), 'Piranwadi');
      expect(IndiaLocationDirectory.normalizeLocalityName('piranvadi', 'Belagavi'), 'Piranwadi');
      expect(IndiaLocationDirectory.normalizeLocalityName('Shahpur', 'Belagavi'), 'Shahapur');
      expect(IndiaLocationDirectory.normalizeLocalityName('shahpur', 'Belagavi'), 'Shahapur');
    });

    test('Ambiguity test: Shahpur requires city scope and does not cross-contaminate', () {
      final belagaviLoc = IndiaLocationDirectory.normalizeLocalityName('Shahpur', 'Belagavi');
      expect(belagaviLoc, 'Shahapur');

      final rawOther = IndiaLocationDirectory.normalizeLocalityName('Shahpur', 'Bengaluru');
      expect(rawOther, 'Shahpur');
    });

    test('State normalization', () {
      expect(IndiaLocationDirectory.normalizeStateName('ka'), 'Karnataka');
      expect(IndiaLocationDirectory.normalizeStateName('karnataka'), 'Karnataka');
      expect(IndiaLocationDirectory.normalizeStateName('mh'), 'Maharashtra');
      expect(IndiaLocationDirectory.normalizeStateName('maharashtra'), 'Maharashtra');
      expect(IndiaLocationDirectory.normalizeStateName('ts'), 'Telangana');
    });

    test('MediaLocationResolver integrates with canonical directory', () {
      final res = MediaLocationResolver.resolve(
        selectedCity: 'belgaum',
        selectedLocality: 'tilakvadi',
        selectedState: 'ka',
      );
      expect(res.canonicalCity, 'Belagavi');
      expect(res.canonicalLocality, 'Tilakwadi');
      expect(res.canonicalState, 'Karnataka');
      expect(res.displayAddress, 'Tilakwadi, Belagavi, Karnataka');
    });
  });

  group('Dry Run Backfill Simulation Tests', () {
    test('Simulate sample legacy property backfill categorization', () {
      final sampleProperties = [
        {'id': '1', 'city': 'Belagavi', 'locality': 'Tilakwadi', 'state': 'Karnataka'},
        {'id': '2', 'city': 'Belgaum', 'locality': 'Tilakvadi', 'state': 'Karnataka'},
        {'id': '3', 'city': 'Hubli', 'locality': 'Keshwapur', 'state': 'Karnataka'},
        {'id': '4', 'city': 'Dharwad', 'locality': 'Saptapur', 'state': 'Karnataka'},
        {'id': '5', 'city': 'Pune', 'locality': 'Baner', 'state': 'Maharashtra'},
        {'id': '6', 'city': 'Belagavi', 'locality': 'Shahpur', 'state': 'Karnataka'},
        {'id': '7', 'city': '', 'locality': '', 'state': ''},
      ];

      int exactMatches = 0;
      int aliasMatches = 0;
      int missingCity = 0;

      for (final p in sampleProperties) {
        final rawCity = p['city'] ?? '';
        final rawLoc = p['locality'] ?? '';

        if (rawCity.isEmpty) {
          missingCity++;
          continue;
        }

        final normCity = IndiaLocationDirectory.normalizeCityName(rawCity);
        final normLoc = IndiaLocationDirectory.normalizeLocalityName(rawLoc, normCity);

        if (normCity == rawCity && normLoc == rawLoc) {
          exactMatches++;
        } else {
          aliasMatches++;
        }
      }

      expect(exactMatches, 3);
      expect(aliasMatches, 3);
      expect(missingCity, 1);
    });
  });
}
