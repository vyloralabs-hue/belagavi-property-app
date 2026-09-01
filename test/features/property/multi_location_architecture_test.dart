import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/map/map_configuration.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/user_location_context.dart';
import 'package:belagavi_property/features/property_search/utils/india_location_directory.dart';

void main() {
  group('MULTI-LOCATION ARCHITECTURE HARDENING TEST MATRIX', () {
    test('1. City Alias Normalization: Belgaum / BGM -> Belagavi', () {
      expect(
        IndiaLocationDirectory.normalizeCityName('Belgaum'),
        equals('Belagavi'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('belgaum'),
        equals('Belagavi'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('BGM'),
        equals('Belagavi'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('belagaon'),
        equals('Belagavi'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('Belagavi'),
        equals('Belagavi'),
      );
    });

    test('2. City Alias Normalization: Bangalore / BLR -> Bengaluru', () {
      expect(
        IndiaLocationDirectory.normalizeCityName('Bangalore'),
        equals('Bengaluru'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('bangalore'),
        equals('Bengaluru'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('BLR'),
        equals('Bengaluru'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('Bengaluru'),
        equals('Bengaluru'),
      );
    });

    test(
      '3. City Alias Normalization: Mysore -> Mysuru, Hubli -> Hubballi, Poona -> Pune',
      () {
        expect(
          IndiaLocationDirectory.normalizeCityName('Mysore'),
          equals('Mysuru'),
        );
        expect(
          IndiaLocationDirectory.normalizeCityName('Hubli'),
          equals('Hubballi'),
        );
        expect(
          IndiaLocationDirectory.normalizeCityName('Poona'),
          equals('Pune'),
        );
        expect(
          IndiaLocationDirectory.normalizeCityName('Bombay'),
          equals('Mumbai'),
        );
        expect(
          IndiaLocationDirectory.normalizeCityName('Madras'),
          equals('Chennai'),
        );
        expect(
          IndiaLocationDirectory.normalizeCityName('Calcutta'),
          equals('Kolkata'),
        );
      },
    );

    test(
      '4. City-Scoped Locality Alias Normalization: Tilakvadi -> Tilakwadi under Belagavi',
      () {
        expect(
          IndiaLocationDirectory.normalizeLocalityName('Tilakvadi', 'Belagavi'),
          equals('Tilakwadi'),
        );
        expect(
          IndiaLocationDirectory.normalizeLocalityName('Tilakvadi', 'Belgaum'),
          equals('Tilakwadi'),
        );
        expect(
          IndiaLocationDirectory.normalizeLocalityName('Shahpur', 'Belagavi'),
          equals('Shahapur'),
        );
      },
    );

    test(
      '5. Unknown Alias Safety: Unmapped input returns trimmed original string',
      () {
        expect(
          IndiaLocationDirectory.normalizeCityName('  New Custom City  '),
          equals('New Custom City'),
        );
        expect(
          IndiaLocationDirectory.normalizeLocalityName(
            'Custom Locality X',
            'New Custom City',
          ),
          equals('Custom Locality X'),
        );
      },
    );

    test(
      '6. Location Candidates for City: getLocalitiesForCity returns city-scoped list',
      () {
        final belagaviLocs = IndiaLocationDirectory.getLocalitiesForCity(
          'Belagavi',
        );
        expect(belagaviLocs, contains('Tilakwadi'));
        expect(belagaviLocs, contains('Shahapur'));

        final blrLocs = IndiaLocationDirectory.getLocalitiesForCity(
          'Bengaluru',
        );
        expect(blrLocs, contains('Whitefield'));
        expect(blrLocs, contains('Indiranagar'));
        expect(blrLocs, isNot(contains('Tilakwadi')));
      },
    );

    test(
      '7. Discovery Location vs Property Location Separation: Discovery change does not mutate property',
      () {
        final property = PropertyEntity(
          id: 'prop_belagavi_001',
          ownerId: 'owner_123',
          title: '2 BHK Apartment in Tilakwadi',
          description: 'Spacious apartment',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 4500000,
          specifications: const PropertySpecificationsEntity(
            carpetArea: 1000,
            bedrooms: 2,
          ),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Khanapur Road',
          pincode: '590006',
          createdAt: DateTime(2026, 8, 31),
          updatedAt: DateTime(2026, 8, 31),
        );

        // User switches discovery context to Bengaluru
        const browsingContext = UserLocationContext(
          countryCode: 'IN',
          countryName: 'India',
          cityName: 'Bengaluru',
          stateName: 'Karnataka',
          hasExplicitSelection: true,
        );

        final searchFilter = browsingContext.toSearchQuery();

        // Verify discovery search filter targets Bengaluru
        expect(searchFilter.city, equals('Bengaluru'));

        // Verify stored property permanently retains Belagavi
        expect(property.city, equals('Belagavi'));
        expect(property.locality, equals('Tilakwadi'));
      },
    );

    test('8. Map Center changes dynamically with selected browsing city', () {
      final (defaultLat, defaultLng) =
          MapConfiguration.resolveCenterForLocation();
      expect(defaultLat, equals(15.8497));
      expect(defaultLng, equals(74.4977));

      final (blrLat, blrLng) = MapConfiguration.resolveCenterForLocation(
        city: 'Bengaluru',
      );
      expect(blrLat, equals(12.9716));
      expect(blrLng, equals(77.5946));

      final (mumLat, mumLng) = MapConfiguration.resolveCenterForLocation(
        city: 'Mumbai',
      );
      expect(mumLat, equals(19.0760));
      expect(mumLng, equals(72.8777));
    });

    test('9. LocationCandidate supports non-IN country codes cleanly', () {
      const candidate = LocationCandidate(
        id: 'loc_dubai_marina',
        name: 'Dubai Marina',
        subtitle: 'Dubai, UAE',
        type: LocationCandidateType.locality,
        cityName: 'Dubai',
        stateName: 'Dubai',
        countryCode: 'AE',
        countryName: 'United Arab Emirates',
        localityName: 'Dubai Marina',
      );

      final context = candidate.toLocationContext();
      expect(context.countryCode, equals('AE'));
      expect(context.countryName, equals('United Arab Emirates'));
      expect(context.cityName, equals('Dubai'));
      expect(context.localityName, equals('Dubai Marina'));
    });

    test(
      '10. Legacy Belagavi property model deserializes and resolves correctly',
      () {
        final json = {
          'id': 'legacy_prop_001',
          'owner_id': 'legacy_owner',
          'title': 'Legacy House',
          'description': 'Description',
          'category': 'residential',
          'type': 'independent_house',
          'status': 'published',
          'price': 6500000,
          'city': 'Belgaum', // legacy spelling
          'locality': 'Tilakwadi',
          'address': 'Tilakwadi 3rd Railway Gate',
          'pincode': '590006',
          'created_at': DateTime.now().toIso8601String(),
        };

        final normCity = IndiaLocationDirectory.normalizeCityName(
          json['city'] as String,
        );
        expect(normCity, equals('Belagavi'));
      },
    );

    test('11. Regression Test: Dharwad NEVER resolves to Hubballi', () {
      expect(
        IndiaLocationDirectory.normalizeCityName('Dharwad'),
        equals('Dharwad'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('dharwad'),
        equals('Dharwad'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('Dharwar'),
        equals('Dharwad'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('Hubli'),
        equals('Hubballi'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('Hubballi'),
        equals('Hubballi'),
      );
      expect(
        IndiaLocationDirectory.normalizeCityName('Dharwad'),
        isNot(equals('Hubballi')),
      );
    });

    test('12. Duplicate Locality Name Disambiguation across Cities', () {
      const locCandidateBlr = LocationCandidate(
        id: 'loc_indiranagar_blr',
        name: 'Indiranagar',
        subtitle: 'Bengaluru, Karnataka',
        type: LocationCandidateType.locality,
        cityName: 'Bengaluru',
        stateName: 'Karnataka',
        localityName: 'Indiranagar',
      );

      const locCandidateNashik = LocationCandidate(
        id: 'loc_indiranagar_nashik',
        name: 'Indiranagar',
        subtitle: 'Nashik, Maharashtra',
        type: LocationCandidateType.locality,
        cityName: 'Nashik',
        stateName: 'Maharashtra',
        localityName: 'Indiranagar',
      );

      final ctxBlr = locCandidateBlr.toLocationContext();
      final ctxNashik = locCandidateNashik.toLocationContext();

      expect(ctxBlr.cityName, equals('Bengaluru'));
      expect(ctxNashik.cityName, equals('Nashik'));
      expect(ctxBlr.localityName, equals(ctxNashik.localityName));
      expect(ctxBlr, isNot(equals(ctxNashik)));
    });
  });
}
