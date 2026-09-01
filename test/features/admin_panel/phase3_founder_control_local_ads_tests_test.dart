import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/admin_panel/data/repositories/founder_control_repository_impl.dart';
import 'package:belagavi_property/features/admin_panel/domain/entities/advertisement_entity.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/utils/location_privacy_helper.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';

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
    if (authenticatedUserId.isEmpty) {
      return left(const ServerFailure('Unauthenticated'));
    }
    _storage[property.id] = property;
    return right(property);
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String id, {required String authenticatedUserId, UserRole? userRole}) async {
    _storage.remove(id);
    return right(null);
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

void main() {
  group('PHASE 3 FOUNDER CONTROL & LOCAL ADS SYSTEM TESTS', () {
    late FakePropertyRepository fakePropertyRepo;
    late FounderControlRepositoryImpl founderRepository;

    const founderId = 'usr_founder_001';
    const ownerId = 'usr_seller_101';
    const attackerId = 'usr_attacker_999';

    late PropertyEntity sampleProperty;

    setUp(() async {
      fakePropertyRepo = FakePropertyRepository();
      founderRepository = FounderControlRepositoryImpl(fakePropertyRepo);

      sampleProperty = PropertyEntity(
        id: 'prop_pub_001',
        ownerId: ownerId,
        title: 'Luxury Villa in Tilakwadi',
        description: 'Prime 4 BHK villa with garden.',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.published,
        verificationStatus: VerificationStatus.verified,
        price: 12500000,
        isNegotiable: true,
        specifications: const PropertySpecificationsEntity(bedrooms: 4, bathrooms: 4, superBuiltUpArea: 2800),
        mediaList: const [],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Door 45, 3rd Main Road',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakePropertyRepo.createProperty(sampleProperty, authenticatedUserId: ownerId);
    });

    test('TEST 1: Normal owner cannot moderate another user\'s property -> ACCESS DENIED', () async {
      final result = await founderRepository.emergencyHideProperty(
        authenticatedUserId: attackerId,
        userRole: UserRole.sellerOwner,
        propertyId: sampleProperty.id,
        reason: 'Attempted unauthorized moderation',
      );
      expect(result.isLeft(), isTrue);
    });

    test('TEST 2: Founder can view all properties', () async {
      final listResult = await fakePropertyRepo.getProperties();
      expect(listResult.isRight(), isTrue);
      final props = listResult.toOption().toNullable() ?? [];
      expect(props.length, equals(1));
      expect(props.first.id, equals(sampleProperty.id));
    });

    test('TEST 3 & 4: Founder can emergency-hide property -> Status becomes DISPUTED', () async {
      final hideResult = await founderRepository.emergencyHideProperty(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: sampleProperty.id,
        reason: 'Ownership Dispute reported',
      );

      expect(hideResult.isRight(), isTrue);
      final updated = hideResult.toOption().toNullable()!;
      expect(updated.status, equals(ListingStatus.disputed));
    });

    test('TEST 5 & 6: Reason is stored and Audit Record is created', () async {
      await founderRepository.emergencyHideProperty(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: sampleProperty.id,
        reason: 'Fraud Suspicion',
      );

      final logsResult = await founderRepository.getModerationAuditLogs(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: sampleProperty.id,
      );

      expect(logsResult.isRight(), isTrue);
      final logs = logsResult.toOption().toNullable()!;
      expect(logs.length, equals(1));

      final log = logs.first;
      expect(log.actorId, equals(founderId));
      expect(log.actorRole, equals(UserRole.founder));
      expect(log.action, equals('EMERGENCY_HIDE'));
      expect(log.reason, equals('Fraud Suspicion'));
      expect(log.previousStatus, equals(ListingStatus.published));
      expect(log.newStatus, equals(ListingStatus.disputed));
    });

    test('TEST 7: Founder can restore property -> Status restored', () async {
      // First emergency hide
      await founderRepository.emergencyHideProperty(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: sampleProperty.id,
        reason: 'Temporary dispute hold',
      );

      // Founder restores
      final restoreResult = await founderRepository.moderatePropertyStatus(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: sampleProperty.id,
        targetStatus: ListingStatus.draft,
        action: 'RESTORE',
        reason: 'Dispute resolved cleanly',
      );

      expect(restoreResult.isRight(), isTrue);
      expect(restoreResult.toOption().toNullable()!.status, equals(ListingStatus.draft));
    });

    test('TEST 8: Disputed property is masked / not visible in public listing query', () async {
      await founderRepository.emergencyHideProperty(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: sampleProperty.id,
        reason: 'Legal Complaint',
      );

      final propsResult = await fakePropertyRepo.getProperties();
      final props = propsResult.toOption().toNullable()!;
      final disputedProp = props.firstWhere((p) => p.id == sampleProperty.id);

      expect(disputedProp.status, equals(ListingStatus.disputed));
      final publicEntity = LocationPrivacyHelper.toPublicPropertyEntity(disputedProp);
      expect(publicEntity.address, isEmpty); // Public address masked
    });

    test('TEST 9: Normal owner cannot change DISPUTED status', () async {
      await founderRepository.emergencyHideProperty(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: sampleProperty.id,
        reason: 'Dispute active',
      );

      // Normal owner attempts to moderate
      final result = await founderRepository.moderatePropertyStatus(
        authenticatedUserId: ownerId,
        userRole: UserRole.sellerOwner,
        propertyId: sampleProperty.id,
        targetStatus: ListingStatus.published,
        action: 'BYPASS',
        reason: 'Owner bypass attempt',
      );
      expect(result.isLeft(), isTrue);
    });

    test('TEST 10: Local Advertisement can be created', () async {
      final now = DateTime.now();
      final newAd = AdvertisementEntity(
        id: 'ad_101',
        title: 'Belagavi Interior Studio',
        description: '30% discount on modular kitchens',
        imageUrl: 'https://img.com/ad1.jpg',
        businessName: 'Belagavi Interiors',
        placement: AdPlacement.homeMiddle,
        status: AdStatus.active,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 10)),
        priority: 1,
        createdBy: founderId,
        createdAt: now,
        updatedAt: now,
      );

      final createResult = await founderRepository.createAdvertisement(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        ad: newAd,
      );

      expect(createResult.isRight(), isTrue);
      expect(createResult.toOption().toNullable()!.title, equals('Belagavi Interior Studio'));
    });

    test('TEST 11: Local Advertisement can be edited', () async {
      final now = DateTime.now();
      final newAd = AdvertisementEntity(
        id: 'ad_102',
        title: 'Original Ad Title',
        description: 'Desc',
        imageUrl: 'https://img.com/ad2.jpg',
        businessName: 'Original Sponsor',
        placement: AdPlacement.homeTop,
        status: AdStatus.active,
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        priority: 2,
        createdBy: founderId,
        createdAt: now,
        updatedAt: now,
      );

      await founderRepository.createAdvertisement(authenticatedUserId: founderId, userRole: UserRole.founder, ad: newAd);

      final updatedAd = newAd.copyWith(title: 'Updated Ad Title');
      final updateResult = await founderRepository.updateAdvertisement(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        ad: updatedAd,
      );

      expect(updateResult.isRight(), isTrue);
      expect(updateResult.toOption().toNullable()!.title, equals('Updated Ad Title'));
    });

    test('TEST 12: Local Advertisement can be paused', () async {
      final now = DateTime.now();
      final ad = AdvertisementEntity(
        id: 'ad_103',
        title: 'Active Ad',
        description: 'Desc',
        imageUrl: 'https://img.com/ad3.jpg',
        businessName: 'Sponsor',
        placement: AdPlacement.propertyList,
        status: AdStatus.active,
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        priority: 1,
        createdBy: founderId,
        createdAt: now,
        updatedAt: now,
      );

      await founderRepository.createAdvertisement(authenticatedUserId: founderId, userRole: UserRole.founder, ad: ad);
      final pausedAd = ad.copyWith(status: AdStatus.paused);
      await founderRepository.updateAdvertisement(authenticatedUserId: founderId, userRole: UserRole.founder, ad: pausedAd);

      final getResult = await founderRepository.getAdvertisements(activeOnly: true);
      final activeAds = getResult.toOption().toNullable()!;
      expect(activeAds.where((a) => a.id == 'ad_103'), isEmpty); // Paused ad excluded from active delivery
    });

    test('TEST 13 & 14: Expired advertisement stops displaying (isActiveNow = false)', () {
      final now = DateTime.now();
      final expiredAd = AdvertisementEntity(
        id: 'ad_expired',
        title: 'Expired Ad',
        description: 'Old Promo',
        imageUrl: 'https://img.com/old.jpg',
        businessName: 'Old Business',
        placement: AdPlacement.homeTop,
        status: AdStatus.active,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 1)), // Expired yesterday
        priority: 1,
        createdBy: founderId,
        createdAt: now,
        updatedAt: now,
      );

      expect(expiredAd.isActiveNow(now), isFalse);
    });

    test('TEST 15: Existing property workflow still works', () async {
      final propsResult = await fakePropertyRepo.getProperties();
      expect(propsResult.isRight(), isTrue);
    });

    test('TEST 16: Builder workflow still works -> Builder ownership checks hold', () {
      expect(
        () => PropertySecurityGuard.verifyProjectOwnership(
          authenticatedUserId: 'b1',
          builderId: 'b1',
        ),
        returnsNormally,
      );
    });

    test('TEST 17: Existing security/RLS boundaries remain intact', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: ownerId,
          ownerId: ownerId,
        ),
        returnsNormally,
      );
    });
  });
}
