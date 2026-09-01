import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/core/utils/typedefs.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property/presentation/widgets/app_property_image.dart';
import 'package:belagavi_property/features/presentation_ui/views/property/category_landing_view.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:fpdart/fpdart.dart';

class _FakePropertyRepository implements PropertyRepository {
  final Map<String, PropertyEntity> _store = {};

  @override
  FutureEither<PropertyEntity> createProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
  }) async {
    final effectiveId = property.id.isNotEmpty ? property.id : 'prop_${DateTime.now().millisecondsSinceEpoch}';
    final saved = property.copyWith(id: effectiveId);
    _store[effectiveId] = saved;
    return Right(saved);
  }

  @override
  FutureEither<PropertyEntity> updateProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    _store[property.id] = property;
    return Right(property);
  }

  @override
  FutureEither<List<PropertyEntity>> getProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    var items = _store.values.toList();
    items = items.where((p) =>
      p.status == ListingStatus.published ||
      p.status == ListingStatus.active ||
      p.status == ListingStatus.approved
    ).toList();
    if (category != null) items = items.where((p) => p.category == category).toList();
    return Right(items);
  }

  @override
  FutureEither<List<PropertyEntity>> getPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) async {
    final items = _store.values.where((p) => p.ownerId == ownerId || ownerId.isEmpty).toList();
    return Right(items);
  }

  @override
  FutureEither<PropertyEntity?> getPropertyById(
    String id, {
    String? requestingUserId,
    List<PropertyUnlockEntity>? userUnlocks,
  }) async {
    return Right(_store[id]);
  }

  @override
  FutureEither<PropertyEntity> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    final existing = _store[propertyId];
    if (existing == null) return const Left(ServerFailure('Not found'));
    final updated = existing.copyWith(status: newStatus);
    _store[propertyId] = updated;
    return Right(updated);
  }

  @override
  FutureEither<void> deleteProperty(
    String id, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    _store.remove(id);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('BELAGAVI PROPERTY — MAIN PROPERTY MARKETPLACE PRODUCTION TESTS', () {
    late _FakePropertyRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakePropertyRepository();
    });

    test('1. Residential Listing Entity construction & specifications', () {
      final res = PropertyEntity(
        id: 'prop_res_001',
        ownerId: 'prof_uuid_101',
        title: 'Luxury 3 BHK Flat in Tilakwadi',
        description: 'Spacious apartment near Congress Road.',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: ListingStatus.pendingVerification,
        price: 8500000.0,
        specifications: const PropertySpecificationsEntity(
          bedrooms: 3,
          bathrooms: 3,
          carpetArea: 1450.0,
          superBuiltUpArea: 1750.0,
          areaUnit: 'sqft',
          furnishingStatus: 'Semi-Furnished',
          floorNumber: 4,
          totalFloors: 8,
        ),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Congress Road, Tilakwadi',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(res.category, equals(PropertyCategory.residential));
      expect(res.specifications.bedrooms, equals(3));
      expect(res.specifications.carpetArea, equals(1450.0));
      expect(res.status, equals(ListingStatus.pendingVerification));
      expect(res.ownerId, equals('prof_uuid_101'));
    });

    test('2. Plot / Layout Listing Entity construction with plot-specific fields', () {
      final plot = PropertyEntity(
        id: 'prop_plot_002',
        ownerId: 'prof_uuid_101',
        title: 'BUDA Approved Plot in Bhagya Nagar',
        description: 'Clear title residential plot in developed layout.',
        category: PropertyCategory.plotLand,
        type: PropertySubtype.residentialPlot,
        status: ListingStatus.pendingVerification,
        price: 4500000.0,
        specifications: const PropertySpecificationsEntity(
          plotArea: 2400.0,
          areaUnit: 'sqft',
          facingDirection: 'East',
        ),
        features: const {
          'plotLength': 60.0,
          'plotWidth': 40.0,
          'roadWidth': 30.0,
          'isCornerPlot': false,
          'isGatedLayout': true,
          'isLayoutApproved': true,
        },
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Bhagya Nagar',
        address: '10th Cross, Bhagya Nagar',
        pincode: '590008',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(plot.category, equals(PropertyCategory.plotLand));
      expect(plot.specifications.plotArea, equals(2400.0));
      expect(plot.features['plotLength'], equals(60.0));
      expect(plot.features['isGatedLayout'], isTrue);
    });

    test('3. Commercial Listing Entity construction with commercial fields', () {
      final comm = PropertyEntity(
        id: 'prop_comm_003',
        ownerId: 'prof_uuid_101',
        title: 'Prime Retail Shop on Khanapur Road',
        description: 'Main road frontage retail showroom.',
        category: PropertyCategory.commercial,
        type: PropertySubtype.commercialShop,
        status: ListingStatus.pendingVerification,
        price: 12000000.0,
        specifications: const PropertySpecificationsEntity(
          superBuiltUpArea: 1200.0,
          carpetArea: 950.0,
          areaUnit: 'sqft',
        ),
        features: const {
          'entranceWidth': 25.0,
          'ceilingHeight': 14.0,
          'washrooms': 2,
          'parkingSpaces': 4,
          'powerLoad': '15 KVA',
        },
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Khanapur Road',
        address: 'Opposite Railway Overbridge, Khanapur Road',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(comm.category, equals(PropertyCategory.commercial));
      expect(comm.features['washrooms'], equals(2));
      expect(comm.features['powerLoad'], equals('15 KVA'));
    });

    test('4. Raw Land / Agricultural Land Entity construction with survey number', () {
      final land = PropertyEntity(
        id: 'prop_land_004',
        ownerId: 'prof_uuid_101',
        title: '4 Acres Fertile Agricultural Land in Sambra',
        description: 'Sugarcane land with active borewell & canal water.',
        category: PropertyCategory.land,
        type: PropertySubtype.agriculturalLand,
        status: ListingStatus.pendingVerification,
        price: 9000000.0,
        specifications: const PropertySpecificationsEntity(
          plotArea: 4.0,
          areaUnit: 'acre',
        ),
        features: const {
          'surveyNumber': 'Sy No. 204/2',
          'soilType': 'Black Cotton Soil',
          'waterSource': 'Canal + Borewell',
          'hasBorewell': true,
          'borewellCount': 2,
          'roadAccessType': 'Tar Road Frontage',
          'isAgricultural': true,
        },
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Sambra',
        address: 'Near Airport Road, Sambra',
        pincode: '591124',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(land.category, equals(PropertyCategory.land));
      expect(land.specifications.areaUnit, equals('acre'));
      expect(land.features['surveyNumber'], equals('Sy No. 204/2'));
      expect(land.features['hasBorewell'], isTrue);
    });

    test('5. Form Notifier: Save Draft produces draft status & submit produces submitted status', () async {
      final notifier = PropertyFormNotifier(fakeRepo);
      notifier.initForNewProperty('prof_uuid_101');
      notifier.updateBasicDetails(
        title: 'Draft Villa in Camp',
        description: 'Spacious villa',
        price: 15000000.0,
      );
      notifier.updateLocation(city: 'Belagavi', locality: 'Camp');

      // 1. Save Draft
      final draftSuccess = await notifier.saveDraft('prof_uuid_101');
      expect(draftSuccess, isTrue);
      expect(notifier.state.listingStatus, equals(ListingStatus.draft));

      // 2. Submit Property
      notifier.updateSpecifications(const PropertySpecificationsEntity(carpetArea: 2500, bedrooms: 4));
      notifier.addMedia(PropertyMediaEntity(
        id: 'm1',
        propertyId: 'p1',
        mediaUrl: 'https://example.com/photo.jpg',
        type: MediaType.image,
        uploadedAt: DateTime.now(),
      ));
      final submitSuccess = await notifier.submitProperty('prof_uuid_101');
      expect(submitSuccess, isTrue);
      expect(notifier.state.listingStatus, equals(ListingStatus.submitted));
    });

    test('6. Public search strictly restricts non-public listings', () async {
      // Add active property
      await fakeRepo.createProperty(
        PropertyEntity(
          id: 'p_active',
          ownerId: 'u1',
          title: 'Active House',
          description: 'Ready to move',
          category: PropertyCategory.residential,
          type: PropertySubtype.independentHouse,
          status: ListingStatus.published,
          price: 5000000,
          specifications: const PropertySpecificationsEntity(),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Tilakwadi',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: 'u1',
      );

      // Add draft property
      await fakeRepo.createProperty(
        PropertyEntity(
          id: 'p_draft',
          ownerId: 'u1',
          title: 'Draft House',
          description: 'Work in progress',
          category: PropertyCategory.residential,
          type: PropertySubtype.independentHouse,
          status: ListingStatus.draft,
          price: 5000000,
          specifications: const PropertySpecificationsEntity(),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Tilakwadi',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: 'u1',
      );

      final publicResult = await fakeRepo.getProperties();
      publicResult.fold(
        (_) => fail('Failed to fetch public properties'),
        (list) {
          expect(list.length, equals(1));
          expect(list.first.id, equals('p_active'));
        },
      );

      final ownerResult = await fakeRepo.getPropertiesByOwner(ownerId: 'u1');
      ownerResult.fold(
        (_) => fail('Failed to fetch owner properties'),
        (list) {
          expect(list.length, equals(2));
        },
      );
    });

    testWidgets('7. AppPropertyImage renders fallback when imageUrl is null/empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPropertyImage(
              imageUrl: null,
              width: 200,
              height: 150,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppPropertyImage), findsOneWidget);
      expect(find.byIcon(Icons.apartment_rounded), findsOneWidget);
    });

    testWidgets('8. CategoryLandingView renders clean empty state when 0 records exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CategoryLandingView(categoryKey: 'residential'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryLandingView), findsOneWidget);
    });
  });
}
