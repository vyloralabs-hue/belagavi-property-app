import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/my_properties_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property/utils/location_privacy_helper.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakePropertyRepository implements PropertyRepository {
  final Map<String, PropertyEntity> _storage = {};

  @override
  Future<Either<Failure, PropertyEntity>> createProperty(PropertyEntity property, {required String authenticatedUserId}) async {
    if (authenticatedUserId.isEmpty) {
      return left(const ServerFailure('Unauthenticated'));
    }
    _storage[property.id] = property;
    return right(property);
  }

  @override
  Future<Either<Failure, PropertyEntity>> updateProperty(PropertyEntity property, {required String authenticatedUserId, UserRole? userRole}) async {
    if (authenticatedUserId.isEmpty || (property.ownerId != authenticatedUserId && (userRole == null || !userRole.isAdminOrFounder))) {
      return left(const ServerFailure('Access denied: Unauthorized property edit.'));
    }
    _storage[property.id] = property;
    return right(property);
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String id, {required String authenticatedUserId, UserRole? userRole}) async {
    final existing = _storage[id];
    if (existing == null || (existing.ownerId != authenticatedUserId && (userRole == null || !userRole.isAdminOrFounder))) {
      return left(const ServerFailure('Access denied: Cannot delete other owner\'s property.'));
    }
    _storage.remove(id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) async {
    return right(_storage.values.where((p) => p.ownerId == ownerId).toList());
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getAllPropertiesForAdmin({
    required String authenticatedUserId,
    UserRole? userRole,
    int limit = 100,
    int offset = 0,
  }) async {
    return right(_storage.values.toList());
  }

  @override
  Future<Either<Failure, PropertyEntity>> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    final existing = _storage[propertyId];
    if (existing == null) {
      return left(const ServerFailure('Property not found.'));
    }
    final updated = PropertyEntity(
      id: existing.id,
      ownerId: existing.ownerId,
      title: existing.title,
      description: existing.description,
      category: existing.category,
      type: existing.type,
      status: newStatus,
      verificationStatus: existing.verificationStatus,
      price: existing.price,
      isNegotiable: existing.isNegotiable,
      specifications: existing.specifications,
      mediaList: existing.mediaList,
      state: existing.state,
      district: existing.district,
      taluk: existing.taluk,
      city: existing.city,
      locality: existing.locality,
      address: existing.address,
      pincode: existing.pincode,
      latitude: existing.latitude,
      longitude: existing.longitude,
      viewsCount: existing.viewsCount,
      features: existing.features,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _storage[propertyId] = updated;
    return right(updated);
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    ListingStatus? statusFilter,
    String? requestingUserId,
    Set<String>? userUnlocks,
    int limit = 20,
    int offset = 0,
  }) async {
    return right(_storage.values.toList());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSupabaseService implements SupabaseService {
  @override
  bool get isInitialized => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PHASE 2 WORKFLOW HARDENING & OWNER PROPERTY MANAGEMENT TESTS', () {
    late FakePropertyRepository fakeRepository;
    late PropertyFormNotifier formNotifier;
    late MyPropertiesNotifier myPropertiesNotifier;

    const ownerId = 'usr_seller_101';
    const attackerId = 'usr_attacker_999';

    setUp(() {
      fakeRepository = FakePropertyRepository();
      formNotifier = PropertyFormNotifier(fakeRepository);
      myPropertiesNotifier = MyPropertiesNotifier(fakeRepository);
    });

    test('TEST 1: Create draft -> Default state initialized', () {
      formNotifier.initForNewProperty(ownerId);
      expect(formNotifier.state.currentStep, equals(0));
      expect(formNotifier.state.ownerId, equals(ownerId));
      expect(formNotifier.state.listingStatus, equals(ListingStatus.draft));
    });

    test('TEST 2: Move through all 8 steps -> Step step navigation within bounds (0 to 7)', () {
      formNotifier.initForNewProperty(ownerId);
      for (int i = 0; i <= 7; i++) {
        formNotifier.setStep(i);
        expect(formNotifier.state.currentStep, equals(i));
      }
      formNotifier.setStep(10); // Out of bounds check
      expect(formNotifier.state.currentStep, equals(7));
    });

    test('TEST 3: Back navigation -> Preserves current state and step decrements correctly', () {
      formNotifier.initForNewProperty(ownerId);
      formNotifier.setStep(5);
      expect(formNotifier.state.currentStep, equals(5));

      formNotifier.setStep(4);
      expect(formNotifier.state.currentStep, equals(4));
    });

    test('TEST 4: Data persistence -> Form state retains values across step transitions', () {
      formNotifier.initForNewProperty(ownerId);
      formNotifier.updateBasicDetails(title: 'Persistent Title', price: 9500000);
      formNotifier.updateLocation(locality: 'Tilakwadi', city: 'Belagavi');

      formNotifier.setStep(3);
      expect(formNotifier.state.title, equals('Persistent Title'));
      expect(formNotifier.state.price, equals(9500000));
      expect(formNotifier.state.locality, equals('Tilakwadi'));
    });

    test('TEST 5: Draft recovery -> Incomplete draft restored correctly into form state', () async {
      final draft = PropertyEntity(
        id: 'draft_rec_001',
        ownerId: ownerId,
        title: 'Draft Recovered Flat',
        description: 'Recovered description text',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: ListingStatus.draft,
        verificationStatus: VerificationStatus.pending,
        price: 5200000,
        isNegotiable: true,
        specifications: const PropertySpecificationsEntity(carpetArea: 1100),
        mediaList: const [],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        address: 'House #88',
        pincode: '590001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      formNotifier.initForEditing(draft);
      expect(formNotifier.state.id, equals('draft_rec_001'));
      expect(formNotifier.state.title, equals('Draft Recovered Flat'));
      expect(formNotifier.state.price, equals(5200000));
    });

    test('TEST 6: Validation -> Invalid input blocked with step error message', () {
      formNotifier.initForNewProperty(ownerId);
      formNotifier.updateBasicDetails(title: '', price: 0);

      final isValidStep2 = formNotifier.validateStep(1); // Step 2 (Index 1): Title required
      expect(isValidStep2, isFalse);
      expect(formNotifier.state.fieldErrors['title'], isNotNull);
    });

    test('TEST 7: Save draft -> Persists entity with DRAFT status', () async {
      formNotifier.initForNewProperty(ownerId);
      formNotifier.updateBasicDetails(title: 'Saved Draft Villa', price: 7500000);

      final success = await formNotifier.saveDraft(ownerId);
      expect(success, isTrue);
      expect(formNotifier.state.listingStatus, equals(ListingStatus.draft));
    });

    test('TEST 8: Submit -> Valid complete property enters SUBMITTED status', () async {
      formNotifier.initForNewProperty(ownerId);
      formNotifier.updateBasicDetails(title: 'Complete Villa Submission', price: 7500000);
      formNotifier.updateLocation(locality: 'Hindwadi', city: 'Belagavi');
      formNotifier.addMedia(const PropertyMediaEntity(id: 'm1', propertyId: 'p1', mediaUrl: 'u1', type: MediaType.image, isCover: true));

      final success = await formNotifier.submitProperty(ownerId);
      expect(success, isTrue);
      expect(formNotifier.state.listingStatus, equals(ListingStatus.submitted));
    });

    test('TEST 9 & 10: Edit existing property -> Retains SAME property ID without creating duplicate listing', () async {
      final existingProp = PropertyEntity(
        id: 'prop_exist_99',
        ownerId: ownerId,
        title: 'Original Title',
        description: 'Original Desc',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: ListingStatus.published,
        verificationStatus: VerificationStatus.verified,
        price: 4000000,
        isNegotiable: true,
        specifications: const PropertySpecificationsEntity(),
        mediaList: const [],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        address: 'Old Address',
        pincode: '590001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeRepository.createProperty(existingProp, authenticatedUserId: ownerId);

      formNotifier.initForEditing(existingProp);
      formNotifier.updateBasicDetails(title: 'Edited Title', price: 4500000);

      final success = await formNotifier.saveDraft(ownerId);
      expect(success, isTrue);
      expect(formNotifier.state.id, equals('prop_exist_99')); // RETAINS SAME PROPERTY ID

      final listResult = await fakeRepository.getProperties();
      final allProps = listResult.toOption().toNullable() ?? [];
      final matchingProps = allProps.where((p) => p.id == 'prop_exist_99').toList();
      expect(matchingProps.length, equals(1)); // NO DUPLICATE CREATED
      expect(matchingProps.first.title, equals('Edited Title'));
    });

    test('TEST 11: Pause -> Transitions published listing to PAUSED status', () async {
      await fakeRepository.createProperty(
        PropertyEntity(
          id: 'p_pub_01',
          ownerId: ownerId,
          title: 'Active Listing',
          description: '',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          verificationStatus: VerificationStatus.verified,
          price: 5000000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Plot 10',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: ownerId,
      );

      await myPropertiesNotifier.fetchMyProperties(ownerId);
      final success = await myPropertiesNotifier.updateListingStatus(
        authenticatedUserId: ownerId,
        propertyId: 'p_pub_01',
        targetStatus: ListingStatus.paused,
      );

      expect(success, isTrue);
      expect(myPropertiesNotifier.state.allProperties.first.status, equals(ListingStatus.paused));
    });

    test('TEST 12: Resume -> Transitions paused listing back to PUBLISHED status', () async {
      await fakeRepository.createProperty(
        PropertyEntity(
          id: 'p_paused_01',
          ownerId: ownerId,
          title: 'Paused Listing',
          description: '',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.paused,
          verificationStatus: VerificationStatus.verified,
          price: 5000000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Plot 10',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: ownerId,
      );

      await myPropertiesNotifier.fetchMyProperties(ownerId);
      final success = await myPropertiesNotifier.updateListingStatus(
        authenticatedUserId: ownerId,
        propertyId: 'p_paused_01',
        targetStatus: ListingStatus.published,
      );

      expect(success, isTrue);
      expect(myPropertiesNotifier.state.allProperties.first.status, equals(ListingStatus.published));
    });

    test('TEST 13: Archive -> Soft archives listing to ARCHIVED status', () async {
      await fakeRepository.createProperty(
        PropertyEntity(
          id: 'p_arch_01',
          ownerId: ownerId,
          title: 'Property to Archive',
          description: '',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          verificationStatus: VerificationStatus.verified,
          price: 5000000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Plot 10',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: ownerId,
      );

      await myPropertiesNotifier.fetchMyProperties(ownerId);
      final success = await myPropertiesNotifier.updateListingStatus(
        authenticatedUserId: ownerId,
        propertyId: 'p_arch_01',
        targetStatus: ListingStatus.archived,
      );

      expect(success, isTrue);
      expect(myPropertiesNotifier.state.allProperties.first.status, equals(ListingStatus.archived));
    });

    test('TEST 14: Rejected -> Edit -> Resubmit workflow', () async {
      await fakeRepository.createProperty(
        PropertyEntity(
          id: 'p_rej_01',
          ownerId: ownerId,
          title: 'Rejected Listing',
          description: 'Initial rejected description',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.rejected,
          verificationStatus: VerificationStatus.rejected,
          price: 5000000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Plot 10',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: ownerId,
      );

      await myPropertiesNotifier.fetchMyProperties(ownerId);

      // Resubmit rejected listing
      final resubmitSuccess = await myPropertiesNotifier.updateListingStatus(
        authenticatedUserId: ownerId,
        propertyId: 'p_rej_01',
        targetStatus: ListingStatus.submitted,
      );

      expect(resubmitSuccess, isTrue);
      expect(myPropertiesNotifier.state.allProperties.first.status, equals(ListingStatus.submitted));
    });

    test('TEST 15: Ownership protection -> Attacker access DENIED', () async {
      await fakeRepository.createProperty(
        PropertyEntity(
          id: 'p_protected',
          ownerId: ownerId,
          title: 'Protected Property',
          description: '',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          verificationStatus: VerificationStatus.verified,
          price: 5000000,
          isNegotiable: true,
          specifications: const PropertySpecificationsEntity(),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Plot 10',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: ownerId,
      );

      await myPropertiesNotifier.fetchMyProperties(ownerId);

      // Attacker attempts status update
      expect(
        () async => await myPropertiesNotifier.updateListingStatus(
          authenticatedUserId: attackerId,
          propertyId: 'p_protected',
          targetStatus: ListingStatus.archived,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 16: Media retention -> Media items retained across edit saves', () async {
      const mediaItem = PropertyMediaEntity(id: 'm_ret_1', propertyId: 'p_ret', mediaUrl: 'https://img.com/1.jpg', type: MediaType.image, isCover: true);
      formNotifier.initForNewProperty(ownerId);
      formNotifier.addMedia(mediaItem);

      expect(formNotifier.state.mediaList.length, equals(1));
      expect(formNotifier.state.mediaList.first.id, equals('m_ret_1'));
    });

    test('TEST 17: Location privacy -> Public listing masks private address and GPS', () {
      final prop = PropertyEntity(
        id: 'p_priv',
        ownerId: ownerId,
        title: 'Private Home',
        description: '',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.published,
        verificationStatus: VerificationStatus.verified,
        price: 9000000,
        isNegotiable: true,
        specifications: const PropertySpecificationsEntity(),
        mediaList: const [],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        address: 'Secret House #123, Private Lane',
        pincode: '590001',
        latitude: 15.8497,
        longitude: 74.4977,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final publicEntity = LocationPrivacyHelper.toPublicPropertyEntity(prop);
      expect(publicEntity.address, isEmpty);
      expect(publicEntity.locality, equals('Camp'));
      expect(publicEntity.city, equals('Belagavi'));
    });
  });
}
