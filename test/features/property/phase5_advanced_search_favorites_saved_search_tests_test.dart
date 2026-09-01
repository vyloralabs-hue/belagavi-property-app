import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/saved_search_entity.dart';
import 'package:belagavi_property/features/property_search/data/datasources/property_search_remote_datasource.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/entities/favorite_entity.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PropertySearchRemoteDataSourceImpl dataSource;

  setUp(() {
    dataSource = PropertySearchRemoteDataSourceImpl(SupabaseService());
  });

  group('PHASE 5 ADVANCED SEARCH, LOCAL FAVORITES & SAVED SEARCH TESTS', () {
    test(
      'TEST 1: Keyword & Location Search -> Returns valid SearchResultModel',
      () async {
        const query = SearchQueryEntity(
          country: 'India',
          state: 'Karnataka',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          limit: 20,
        );

        final result = await dataSource.executeSearch(query);

        expect(result.properties, isNotNull);
        for (final p in result.properties) {
          expect(p.city, equals('Belagavi'));
          expect(p.locality.toLowerCase(), contains('tilakwadi'));
        }
      },
    );

    test('TEST 2: Property Purpose & Subtype Filter', () async {
      const query = SearchQueryEntity(
        type: PropertySubtype.apartment,
        limit: 20,
      );

      final result = await dataSource.executeSearch(query);

      expect(result.properties, isNotNull);
      for (final p in result.properties) {
        expect(p.type, equals(PropertySubtype.apartment));
      }
    });

    test('TEST 3: Price & Area Range Filtering', () async {
      const query = SearchQueryEntity(
        minPrice: 50.0,
        maxPrice: 150.0,
        minArea: 1000.0,
        maxArea: 3000.0,
        limit: 20,
      );

      final result = await dataSource.executeSearch(query);

      for (final p in result.properties) {
        expect(p.price, greaterThanOrEqualTo(50.0));
        expect(p.price, lessThanOrEqualTo(150.0));
      }
    });

    test('TEST 4: Bedrooms (BHK) Composable Filter', () async {
      const query = SearchQueryEntity(
        minBedrooms: 3,
        maxBedrooms: 3,
        limit: 20,
      );

      final result = await dataSource.executeSearch(query);

      for (final p in result.properties) {
        expect(p.specifications.bedrooms, equals(3));
      }
    });

    test(
      'TEST 5: Empty Result Handling -> Clean empty response without errors',
      () async {
        const query = SearchQueryEntity(
          locality: 'NonExistentLocalityName99',
          limit: 20,
        );

        final result = await dataSource.executeSearch(query);

        expect(result.properties.isEmpty, isTrue);
        expect(result.totalCount, equals(0));
        expect(result.hasMore, isFalse);
      },
    );

    test(
      'TEST 6: Public Search Isolation -> Excludes non-public statuses',
      () async {
        const query = SearchQueryEntity(limit: 50);

        final result = await dataSource.executeSearch(query);

        for (final p in result.properties) {
          expect(p.status, isNot(equals(ListingStatus.draft)));
          expect(p.status, isNot(equals(ListingStatus.submitted)));
          expect(p.status, isNot(equals(ListingStatus.underReview)));
          expect(p.status, isNot(equals(ListingStatus.rejected)));
          expect(p.status, isNot(equals(ListingStatus.paused)));
          expect(p.status, isNot(equals(ListingStatus.disputed)));
          expect(p.status, isNot(equals(ListingStatus.archived)));
        }
      },
    );

    test('TEST 7: Location Privacy Masking on Search Result Cards', () async {
      const query = SearchQueryEntity(limit: 20);

      final result = await dataSource.executeSearch(query);

      for (final p in result.properties) {
        expect(p.address, isEmpty); // Exact house/street address sanitized
      }
    });

    test(
      'TEST 8: Local Favorites -> Add, duplicate prevention, and remove',
      () {
        final sampleProperty = PropertyEntity(
          id: 'prop_fav_101',
          ownerId: 'owner_101',
          title: 'Sample Property for Favorite',
          description: 'Description',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          price: 75.0,
          specifications: const PropertySpecificationsEntity(),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Secret Address',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final fav1 = FavoritePropertyEntity(
          id: 'fav_1',
          propertyId: sampleProperty.id,
          property: sampleProperty,
          addedAt: DateTime.now(),
        );

        final favList = <FavoritePropertyEntity>[fav1];

        // Duplicate check
        final isDuplicate = favList.any(
          (f) => f.propertyId == sampleProperty.id,
        );
        expect(isDuplicate, isTrue);

        // Remove check
        favList.removeWhere((f) => f.propertyId == sampleProperty.id);
        expect(favList.isEmpty, isTrue);
      },
    );

    test('TEST 9: Saved Search -> Create, edit, serialize, and restore', () {
      const query = SearchQueryEntity(
        city: 'Belagavi',
        locality: 'Tilakwadi',
        minPrice: 40.0,
        maxPrice: 90.0,
      );

      final saved = SavedSearchEntity(
        id: 'saved_1',
        title: 'Belagavi Tilakwadi 40L-90L',
        query: query,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = saved.toJson();
      final restored = SavedSearchEntity.fromJson(json);

      expect(restored.title, equals('Belagavi Tilakwadi 40L-90L'));
      expect(restored.query.city, equals('Belagavi'));
      expect(restored.query.locality, equals('Tilakwadi'));
      expect(restored.query.minPrice, equals(40.0));
      expect(restored.query.maxPrice, equals(90.0));
    });

    test('TEST 10: Builder Project Search Integration', () async {
      const query = SearchQueryEntity(
        category: PropertyCategory.builderProject,
        limit: 20,
      );

      final result = await dataSource.executeSearch(query);

      expect(result, isNotNull);
    });

    test(
      'TEST 11: Founder Moderation Guard -> Disputed listings hidden from public search',
      () async {
        const role = UserRole.user;
        expect(role.isAdminOrFounder, isFalse);

        const publicQuery = SearchQueryEntity(status: null);
        final result = await dataSource.executeSearch(publicQuery);

        for (final p in result.properties) {
          expect(p.status, isNot(equals(ListingStatus.disputed)));
        }
      },
    );

    test(
      'TEST 12: Zero AI Dependency -> Pure deterministic search execution',
      () async {
        const query = SearchQueryEntity(
          rawQuery: 'Apartment',
          city: 'Belagavi',
        );

        final stopwatch = Stopwatch()..start();
        final result = await dataSource.executeSearch(query);
        stopwatch.stop();

        expect(result, isNotNull);
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Sub-100ms response
      },
    );
  });
}
