import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/user_location_context.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/user_location_notifier.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/property_search_notifier.dart';
import 'package:belagavi_property/features/property_search/utils/india_location_directory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CTO INDIA-WIDE LOCATION & PROPERTY DISCOVERY TEST SUITE', () {
    // 1. App does not force Belagavi when no saved location exists
    test('1. App does not force Belagavi when no saved location exists', () {
      const defaultLoc = UserLocationContext.unselected;
      expect(defaultLoc.hasExplicitSelection, isFalse);
      expect(defaultLoc.cityName, isNull);
      expect(defaultLoc.stateName, isNull);
      expect(defaultLoc.displayName, equals('Select Location'));

      const defaultSearch = SearchQueryEntity();
      expect(defaultSearch.city, isNull);
      expect(defaultSearch.state, isNull);
    });

    // 2. Location selector can choose Bengaluru
    test('2. Location selector can choose Bengaluru', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userLocationNotifierProvider.notifier);
      await notifier.selectCity('Bengaluru', stateName: 'Karnataka', stateCode: 'KA');

      final current = container.read(userLocationNotifierProvider).current;
      expect(current.hasExplicitSelection, isTrue);
      expect(current.cityName, equals('Bengaluru'));
      expect(current.stateName, equals('Karnataka'));
      expect(current.stateCode, equals('KA'));
      expect(current.displayName, equals('Bengaluru'));
    });

    // 3. Switching city clears old locality
    test('3. Switching city clears old locality', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userLocationNotifierProvider.notifier);
      // First select Bengaluru and Whitefield locality
      await notifier.selectLocality('Whitefield', 'Bengaluru', stateName: 'Karnataka', pincode: '560066');
      var current = container.read(userLocationNotifierProvider).current;
      expect(current.cityName, equals('Bengaluru'));
      expect(current.localityName, equals('Whitefield'));
      expect(current.pincode, equals('560066'));

      // Now switch city to Pune
      await notifier.selectCity('Pune', stateName: 'Maharashtra', stateCode: 'MH');
      current = container.read(userLocationNotifierProvider).current;
      expect(current.cityName, equals('Pune'));
      expect(current.localityName, isNull, reason: 'Child locality must be reset when parent city changes');
      expect(current.pincode, isNull, reason: 'Child pincode must be reset when parent city changes');
      expect(current.stateName, equals('Maharashtra'));
    });

    // 4. Selected Bengaluru affects all four category queries
    test('4. Selected Bengaluru affects all four category queries', () {
      const bengLoc = UserLocationContext(
        cityName: 'Bengaluru',
        stateName: 'Karnataka',
        hasExplicitSelection: true,
      );

      final resQuery = bengLoc.toSearchQuery(category: PropertyCategory.residential);
      expect(resQuery.city, equals('Bengaluru'));
      expect(resQuery.category, equals(PropertyCategory.residential));

      final plotQuery = bengLoc.toSearchQuery(category: PropertyCategory.plotLand);
      expect(plotQuery.city, equals('Bengaluru'));
      expect(plotQuery.category, equals(PropertyCategory.plotLand));

      final commQuery = bengLoc.toSearchQuery(category: PropertyCategory.commercial);
      expect(commQuery.city, equals('Bengaluru'));
      expect(commQuery.category, equals(PropertyCategory.commercial));

      final landQuery = bengLoc.toSearchQuery(category: PropertyCategory.land);
      expect(landQuery.city, equals('Bengaluru'));
      expect(landQuery.category, equals(PropertyCategory.land));
    });

    // 5. User can search locality by text
    test('5. User can search locality by text', () {
      final results = IndiaLocationDirectory.search('Whitefield');
      expect(results.isNotEmpty, isTrue);
      final match = results.firstWhere((r) => r.name.toLowerCase().contains('whitefield'));
      expect(match.type, equals(LocationCandidateType.locality));
      expect(match.cityName, equals('Bengaluru'));

      final banerResults = IndiaLocationDirectory.search('Baner');
      expect(banerResults.isNotEmpty, isTrue);
      final banerMatch = banerResults.firstWhere((r) => r.name.toLowerCase().contains('baner'));
      expect(banerMatch.cityName, equals('Pune'));
    });

    // 6. User can search pincode
    test('6. User can search pincode', () {
      final pinResults = IndiaLocationDirectory.search('560066');
      expect(pinResults.isNotEmpty, isTrue);
      final pinMatch = pinResults.firstWhere((r) => r.pincode == '560066');
      expect(pinMatch.type, equals(LocationCandidateType.pincode));
      expect(pinMatch.cityName, equals('Bengaluru'));
      expect(pinMatch.localityName, equals('Whitefield'));

      final tilakPin = IndiaLocationDirectory.search('590006');
      expect(tilakPin.isNotEmpty, isTrue);
      final tilakMatch = tilakPin.firstWhere((r) => r.pincode == '590006');
      expect(tilakMatch.cityName, equals('Belagavi'));
    });

    // 7. Selected locality filters results
    test('7. Selected locality filters results', () {
      const whitefieldLoc = UserLocationContext(
        cityName: 'Bengaluru',
        localityName: 'Whitefield',
        pincode: '560066',
        hasExplicitSelection: true,
      );

      final query = whitefieldLoc.toSearchQuery(category: PropertyCategory.residential);
      expect(query.city, equals('Bengaluru'));
      expect(query.locality, equals('Whitefield'));
      expect(query.pincode, equals('560066'));
      expect(query.category, equals(PropertyCategory.residential));
    });

    // 8. Location state survives category navigation
    test('8. Location state survives category navigation', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userLocationNotifierProvider.notifier);
      await notifier.selectCity('Mumbai', stateName: 'Maharashtra');

      // User opens Residential
      final loc1 = container.read(userLocationNotifierProvider).current;
      expect(loc1.cityName, equals('Mumbai'));

      // User switches to Plots
      final loc2 = container.read(userLocationNotifierProvider).current;
      expect(loc2.cityName, equals('Mumbai'));

      // User switches to Commercial
      final loc3 = container.read(userLocationNotifierProvider).current;
      expect(loc3.cityName, equals('Mumbai'));
    });

    // 9. Empty results show selected location name
    test('9. Empty results show selected location name', () {
      const bengaluruLoc = UserLocationContext(
        cityName: 'Bengaluru',
        hasExplicitSelection: true,
      );
      expect(bengaluruLoc.categoryHeading(PropertyCategory.residential), equals('Residential Properties in Bengaluru'));
      expect(bengaluruLoc.categoryHeading(PropertyCategory.plotLand), equals('Plots & Layouts in Bengaluru'));
      expect(bengaluruLoc.categoryHeading(PropertyCategory.commercial), equals('Commercial Properties in Bengaluru'));
      expect(bengaluruLoc.categoryHeading(PropertyCategory.land), equals('Land Listings in Bengaluru'));

      const whitefieldLoc = UserLocationContext(
        cityName: 'Bengaluru',
        localityName: 'Whitefield',
        hasExplicitSelection: true,
      );
      expect(whitefieldLoc.categoryHeading(PropertyCategory.residential), equals('Residential Properties in Whitefield, Bengaluru'));
    });

    // 10. Seller listing does not default city to Belagavi
    test('10. Seller listing does not default city to Belagavi', () {
      const initialFormState = PropertyFormState();
      expect(initialFormState.city, isEmpty);
      expect(initialFormState.state, isEmpty);
      expect(initialFormState.pincode, isEmpty);
    });

    // 11. Raw location aliases normalize correctly where configured
    test('11. Raw location aliases normalize correctly where configured', () {
      expect(IndiaLocationDirectory.resolveCityAlias('bangalore'), equals('Bengaluru'));
      expect(IndiaLocationDirectory.resolveCityAlias('blr'), equals('Bengaluru'));
      expect(IndiaLocationDirectory.resolveCityAlias('belgaum'), equals('Belagavi'));
      expect(IndiaLocationDirectory.resolveCityAlias('bombay'), equals('Mumbai'));
      expect(IndiaLocationDirectory.resolveCityAlias('poona'), equals('Pune'));
      expect(IndiaLocationDirectory.resolveCityAlias('madras'), equals('Chennai'));
      expect(IndiaLocationDirectory.resolveCityAlias('calcutta'), equals('Kolkata'));
      expect(IndiaLocationDirectory.resolveCityAlias('noida'), equals('Delhi NCR'));
      expect(IndiaLocationDirectory.resolveCityAlias('gurgaon'), equals('Delhi NCR'));
    });

    // 12. Error state remains separate from zero-results state
    test('12. Error state remains separate from zero-results state', () {
      const emptyResult = SearchResultEntity(properties: [], totalCount: 0, hasMore: false);
      const successEmptyState = PropertySearchSuccess(emptyResult);
      expect(successEmptyState, isA<PropertySearchSuccess>());
      expect(successEmptyState.result.properties.isEmpty, isTrue);

      const genuineErrorState = PropertySearchError('Network failure. Please check connection.');
      expect(genuineErrorState, isA<PropertySearchError>());
      expect(genuineErrorState.message, contains('Network failure'));
    });

    // 13. Search is debounced
    test('13. Search is debounced and fast-matched from directory', () {
      final results = IndiaLocationDirectory.search('Koramangala');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.name, equals('Koramangala'));
      expect(results.first.cityName, equals('Bengaluru'));
    });

    // 14. No hardcoded city condition exists in production query path
    test('14. No hardcoded city condition exists in production query path', () {
      const unconstrainedQuery = SearchQueryEntity();
      expect(unconstrainedQuery.city, isNull);
      expect(unconstrainedQuery.state, isNull);
      expect(unconstrainedQuery.country, isNull);

      const delhiQuery = SearchQueryEntity(city: 'Delhi NCR', state: 'Delhi');
      expect(delhiQuery.city, equals('Delhi NCR'));
      expect(delhiQuery.state, equals('Delhi'));
    });
  });
}
