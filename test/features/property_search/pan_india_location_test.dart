import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/geo/geo_math.dart';
import 'package:belagavi_property/features/property_search/domain/entities/india_administrative_hierarchy.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/user_location_context.dart';
import 'package:belagavi_property/features/property_search/utils/india_location_directory.dart';

void main() {
  group('GeoMath Unit Tests', () {
    test('Haversine distance between Belagavi and Hubballi (~90 km)', () {
      // Belagavi: 15.8497 N, 74.4977 E
      // Hubballi: 15.3647 N, 75.1240 E
      final distKm = GeoMath.calculateDistanceKm(
        lat1: 15.8497,
        lon1: 74.4977,
        lat2: 15.3647,
        lon2: 75.1240,
      );

      expect(distKm, greaterThan(80.0));
      expect(distKm, lessThan(105.0));
    });

    test('Bounding box calculation around Belagavi for 20km', () {
      final bbox = GeoMath.calculateBoundingBox(
        centerLat: 15.8497,
        centerLng: 74.4977,
        radiusKm: 20.0,
      );

      expect(bbox.south, lessThan(15.8497));
      expect(bbox.north, greaterThan(15.8497));
      expect(bbox.west, lessThan(74.4977));
      expect(bbox.east, greaterThan(74.4977));

      // Contains center
      expect(bbox.contains(15.8497, 74.4977), isTrue);

      // Tilakwadi (~2 km away) must be inside
      expect(bbox.contains(15.8340, 74.5020), isTrue);

      // Hubballi (~90 km away) must be strictly outside
      expect(bbox.contains(15.3647, 75.1240), isFalse);
    });

    test('Distance formatting formats correctly', () {
      expect(GeoMath.formatDistance(0.450), '450 m');
      expect(GeoMath.formatDistance(4.5), '4.5 km');
      expect(GeoMath.formatDistance(24.2), '24 km');
    });
  });

  group('India Administrative Hierarchy Tests', () {
    test('All 28 States and 8 UTs are registered', () {
      expect(IndiaAdministrativeHierarchy.states.length, 28);
      expect(IndiaAdministrativeHierarchy.unionTerritories.length, 8);
      expect(IndiaAdministrativeHierarchy.allStatesAndUTs.length, 36);
    });

    test('All 31 Karnataka districts are present', () {
      final kaDistricts = IndiaAdministrativeHierarchy.getDistrictsForState('Karnataka');
      expect(kaDistricts.length, 31);

      final districtNames = kaDistricts.map((d) => d.name).toList();
      expect(districtNames, contains('Belagavi'));
      expect(districtNames, contains('Bengaluru Urban'));
      expect(districtNames, contains('Dharwad'));
      expect(districtNames, contains('Mysuru'));
      expect(districtNames, contains('Bagalkote'));
      expect(districtNames, contains('Uttara Kannada'));
      expect(districtNames, contains('Vijayanagara'));
    });

    test('Belagavi District contains all 15 taluks', () {
      final taluks = IndiaAdministrativeHierarchy.getTaluksForDistrict('Belagavi');
      expect(taluks.length, 15);
      expect(taluks, contains('Gokak'));
      expect(taluks, contains('Chikkodi'));
      expect(taluks, contains('Bailhongal'));
      expect(taluks, contains('Athani'));
      expect(taluks, contains('Khanapur'));
      expect(taluks, contains('Nippani'));
      expect(taluks, contains('Kittur'));
    });

    test('State and District lookup by alias works seamlessly', () {
      final mh = IndiaAdministrativeHierarchy.findState('MH');
      expect(mh, isNotNull);
      expect(mh!.name, 'Maharashtra');

      final blr = IndiaAdministrativeHierarchy.findDistrict('blr');
      expect(blr, isNotNull);
      expect(blr!.name, 'Bengaluru Urban');
    });
  });

  group('Canonical Normalization & Directory Tests', () {
    test('City aliases normalize correctly', () {
      expect(IndiaLocationDirectory.normalizeCityName('belgaum'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('bgm'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('bangalore'), 'Bengaluru');
      expect(IndiaLocationDirectory.normalizeCityName('blr'), 'Bengaluru');
      expect(IndiaLocationDirectory.normalizeCityName('poona'), 'Pune');
      expect(IndiaLocationDirectory.normalizeCityName('hubli'), 'Hubballi');
      expect(IndiaLocationDirectory.normalizeCityName('bombay'), 'Mumbai');
    });

    test('Locality normalization is strictly scoped by city', () {
      // Tilakwadi is valid in Belagavi
      expect(IndiaLocationDirectory.normalizeLocalityName('tilakvadi', 'Belagavi'), 'Tilakwadi');

      // Unknown localities in Belagavi preserve raw input without forcing another city
      expect(IndiaLocationDirectory.normalizeLocalityName('Kuvempu Nagar', 'Belagavi'), 'Kuvempu Nagar');
    });

    test('Directory search returns cascading administrative results', () {
      final results = IndiaLocationDirectory.search('Khanapur');
      expect(results.any((r) => r.name.toLowerCase() == 'khanapur'), isTrue);

      final stateResults = IndiaLocationDirectory.search('Goa');
      expect(stateResults.any((r) => r.name.toLowerCase() == 'goa'), isTrue);
    });
  });

  group('UserLocationContext to SearchQuery Tests', () {
    test('All India mode outputs All India query without coordinates bounding', () {
      const allIndiaContext = UserLocationContext.allIndia;
      final query = allIndiaContext.toSearchQuery();

      expect(query.country, 'India');
      expect(query.minLatitude, isNull);
      expect(query.city, isNull);
    });

    test('Near Me mode with 10km generates rectangular bounding box', () {
      const nearMeContext = UserLocationContext(
        latitude: 15.8497,
        longitude: 74.4977,
        radiusKm: 10.0,
        mode: DiscoveryLocationMode.nearMe,
      );

      final query = nearMeContext.toSearchQuery();

      expect(query.minLatitude, isNotNull);
      expect(query.maxLatitude, isNotNull);
      expect(query.minLongitude, isNotNull);
      expect(query.maxLongitude, isNotNull);
      expect(query.centerLatitude, 15.8497);
      expect(query.radiusKm, 10.0);
    });

    test('Hierarchy selection populates taluk and district', () {
      const hierarchyContext = UserLocationContext(
        stateName: 'Karnataka',
        districtName: 'Belagavi',
        talukName: 'Gokak',
        mode: DiscoveryLocationMode.chooseLocation,
      );

      final query = hierarchyContext.toSearchQuery();
      expect(query.state, 'Karnataka');
      expect(query.district, 'Belagavi');
    });

    test('Non-Belagavi locations (Bengaluru, Pune) build correctly', () {
      const blrContext = UserLocationContext(
        stateName: 'Karnataka',
        districtName: 'Bengaluru Urban',
        cityName: 'Bengaluru',
        localityName: 'Whitefield',
        mode: DiscoveryLocationMode.chooseLocation,
      );
      final blrQuery = blrContext.toSearchQuery();
      expect(blrQuery.city, 'Bengaluru');
      expect(blrQuery.locality, 'Whitefield');

      const puneContext = UserLocationContext(
        stateName: 'Maharashtra',
        districtName: 'Pune',
        cityName: 'Pune',
        localityName: 'Kothrud',
        mode: DiscoveryLocationMode.chooseLocation,
      );
      final puneQuery = puneContext.toSearchQuery();
      expect(puneQuery.city, 'Pune');
      expect(puneQuery.state, 'Maharashtra');
    });

    test('Rural / Agricultural flow works with Taluk and Village without city requirement', () {
      const ruralContext = UserLocationContext(
        stateName: 'Karnataka',
        districtName: 'Belagavi',
        talukName: 'Khanapur',
        localityName: 'Jamboti Village',
        mode: DiscoveryLocationMode.chooseLocation,
      );
      final ruralQuery = ruralContext.toSearchQuery();
      expect(ruralQuery.state, 'Karnataka');
      expect(ruralQuery.district, 'Belagavi');
      expect(ruralQuery.locality, 'Jamboti Village');
      expect(ruralQuery.city, isNull);
    });
  });
}
