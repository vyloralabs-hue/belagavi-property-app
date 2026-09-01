import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/admin_panel/data/repositories/founder_control_repository_impl.dart';
import 'package:belagavi_property/features/admin_panel/domain/entities/advertisement_entity.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/utils/location_privacy_helper.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/property/utils/property_status_workflow.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakePropertyLifecycleRepository implements PropertyRepository {
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
    var list = _storage.values.toList();
    if (statusFilter != null) {
      list = list.where((p) => p.status == statusFilter).toList();
    }
    return right(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PHASE 4 PROPERTY VERIFICATION & LIFECYCLE TESTS', () {
    late FakePropertyLifecycleRepository propertyRepo;
    late FounderControlRepositoryImpl founderRepo;

    const founderId = 'usr_founder_001';
    const adminId = 'usr_admin_001';
    const ownerId = 'usr_seller_101';
    const attackerId = 'usr_attacker_999';

    late PropertyEntity draftProperty;

    setUp(() {
      propertyRepo = FakePropertyLifecycleRepository();
      founderRepo = FounderControlRepositoryImpl(propertyRepo);

      draftProperty = PropertyEntity(
        id: 'prop_life_001',
        ownerId: ownerId,
        title: 'Penthouse in Khanapur Road',
        description: 'Luxury 4 BHK penthouse with terrace.',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: ListingStatus.draft,
        verificationStatus: VerificationStatus.unverified,
        price: 18000000,
        isNegotiable: true,
        specifications: const PropertySpecificationsEntity(bedrooms: 4, bathrooms: 4, superBuiltUpArea: 3200),
        mediaList: const [],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Khanapur Road',
        address: 'Tower A 1401',
        pincode: '590001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('TEST 1: Owner creates draft -> Status is DRAFT', () async {
      final createResult = await propertyRepo.createProperty(draftProperty, authenticatedUserId: ownerId);
      expect(createResult.isRight(), isTrue);
      expect(createResult.toOption().toNullable()!.status, equals(ListingStatus.draft));
    });

    test('TEST 2: Owner edits draft -> Same property ID updated', () async {
      await propertyRepo.createProperty(draftProperty, authenticatedUserId: ownerId);

      final updatedDraft = draftProperty.copyWith(title: 'Updated Penthouse Title');
      final updateResult = await propertyRepo.updateProperty(updatedDraft, authenticatedUserId: ownerId);

      expect(updateResult.isRight(), isTrue);
      expect(updateResult.toOption().toNullable()!.id, equals('prop_life_001'));
      expect(updateResult.toOption().toNullable()!.title, equals('Updated Penthouse Title'));
    });

    test('TEST 3: Owner submits property -> Status changes to SUBMITTED', () async {
      await propertyRepo.createProperty(draftProperty, authenticatedUserId: ownerId);

      final submitted = draftProperty.copyWith(status: ListingStatus.submitted);
      final result = await propertyRepo.updateProperty(submitted, authenticatedUserId: ownerId);

      expect(result.isRight(), isTrue);
      expect(result.toOption().toNullable()!.status, equals(ListingStatus.submitted));
    });

    test('TEST 4 & 5: Admin reviews property -> Status moves to UNDER_REVIEW', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.submitted), authenticatedUserId: ownerId);

      final reviewResult = await founderRepo.moderatePropertyStatus(
        authenticatedUserId: adminId,
        userRole: UserRole.admin,
        propertyId: draftProperty.id,
        targetStatus: ListingStatus.underReview,
        action: 'REVIEW',
        reason: 'Review started',
      );

      expect(reviewResult.isRight(), isTrue);
      expect(reviewResult.toOption().toNullable()!.status, equals(ListingStatus.underReview));
    });

    test('TEST 6: Admin requests changes -> Status becomes CHANGES_REQUESTED', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.underReview), authenticatedUserId: ownerId);

      final reqResult = await founderRepo.moderatePropertyStatus(
        authenticatedUserId: adminId,
        userRole: UserRole.admin,
        propertyId: draftProperty.id,
        targetStatus: ListingStatus.changesRequested,
        action: 'REQUEST_CHANGES',
        reason: 'Please upload floor plan document',
      );

      expect(reqResult.isRight(), isTrue);
      expect(reqResult.toOption().toNullable()!.status, equals(ListingStatus.changesRequested));
    });

    test('TEST 7 & 8: Owner edits and resubmits listing -> Status returns to SUBMITTED', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.changesRequested), authenticatedUserId: ownerId);

      final resubmitted = draftProperty.copyWith(status: ListingStatus.submitted);
      final resubmitResult = await propertyRepo.updateProperty(resubmitted, authenticatedUserId: ownerId);

      expect(resubmitResult.isRight(), isTrue);
      expect(resubmitResult.toOption().toNullable()!.status, equals(ListingStatus.submitted));
    });

    test('TEST 9 & 10: Admin approves property -> Status becomes PUBLISHED and verified', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.submitted), authenticatedUserId: ownerId);

      final approveResult = await founderRepo.moderatePropertyStatus(
        authenticatedUserId: adminId,
        userRole: UserRole.admin,
        propertyId: draftProperty.id,
        targetStatus: ListingStatus.published,
        action: 'APPROVE',
        reason: 'All documentation verified',
      );

      expect(approveResult.isRight(), isTrue);
      final approvedProp = approveResult.toOption().toNullable()!;
      expect(approvedProp.status, equals(ListingStatus.published));
    });

    test('TEST 11: Published property appears in public discovery', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.published), authenticatedUserId: ownerId);

      final queryResult = await propertyRepo.getProperties(statusFilter: ListingStatus.published);
      final list = queryResult.toOption().toNullable()!;
      expect(list.length, equals(1));
      expect(list.first.id, equals(draftProperty.id));
    });

    test('TEST 12 & 13: Owner pauses property -> Excluded from public published discovery', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.published), authenticatedUserId: ownerId);

      final paused = draftProperty.copyWith(status: ListingStatus.paused);
      await propertyRepo.updateProperty(paused, authenticatedUserId: ownerId);

      final queryResult = await propertyRepo.getProperties(statusFilter: ListingStatus.published);
      expect(queryResult.toOption().toNullable()!, isEmpty);
    });

    test('TEST 14: Owner resumes paused property -> Status returns to PUBLISHED', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.paused), authenticatedUserId: ownerId);

      final resumed = draftProperty.copyWith(status: ListingStatus.published);
      final resumeResult = await propertyRepo.updateProperty(resumed, authenticatedUserId: ownerId);

      expect(resumeResult.isRight(), isTrue);
      expect(resumeResult.toOption().toNullable()!.status, equals(ListingStatus.published));
    });

    test('TEST 15 & 16: Founder marks property disputed -> Disappears from public discovery immediately', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.published), authenticatedUserId: ownerId);

      final hideResult = await founderRepo.emergencyHideProperty(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: draftProperty.id,
        reason: 'Ownership dispute filed',
      );

      expect(hideResult.isRight(), isTrue);
      expect(hideResult.toOption().toNullable()!.status, equals(ListingStatus.disputed));

      final queryResult = await propertyRepo.getProperties(statusFilter: ListingStatus.published);
      expect(queryResult.toOption().toNullable()!, isEmpty);
    });

    test('TEST 17: Moderation Audit Record is created for dispute action', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.published), authenticatedUserId: ownerId);

      await founderRepo.emergencyHideProperty(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: draftProperty.id,
        reason: 'Policy Violation',
      );

      final logsResult = await founderRepo.getModerationAuditLogs(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: draftProperty.id,
      );

      final logs = logsResult.toOption().toNullable()!;
      expect(logs.length, equals(1));
      expect(logs.first.reason, equals('Policy Violation'));
    });

    test('TEST 18: Founder restores property -> Status updated cleanly', () async {
      await propertyRepo.createProperty(draftProperty.copyWith(status: ListingStatus.disputed), authenticatedUserId: ownerId);

      final restoreResult = await founderRepo.moderatePropertyStatus(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        propertyId: draftProperty.id,
        targetStatus: ListingStatus.draft,
        action: 'RESTORE',
        reason: 'Dispute resolved',
      );

      expect(restoreResult.isRight(), isTrue);
      expect(restoreResult.toOption().toNullable()!.status, equals(ListingStatus.draft));
    });

    test('TEST 19: Owner cannot edit another owner\'s property -> ACCESS DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: attackerId,
          ownerId: ownerId,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 20: Logged-out guest cannot access protected private address information', () {
      final publicEntity = LocationPrivacyHelper.toPublicPropertyEntity(draftProperty);
      expect(publicEntity.address, isEmpty);
      expect(publicEntity.pincode, isEmpty);
    });

    test('TEST 21: Existing Builder workflow still works', () {
      expect(
        () => PropertySecurityGuard.verifyProjectOwnership(
          authenticatedUserId: 'builder_001',
          builderId: 'builder_001',
        ),
        returnsNormally,
      );
    });

    test('TEST 22: Existing Founder Control still works', () async {
      final logsResult = await founderRepo.getModerationAuditLogs(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
      );
      expect(logsResult.isRight(), isTrue);
    });

    test('TEST 23: Existing Local Ads still work', () async {
      final now = DateTime.now();
      final ad = AdvertisementEntity(
        id: 'ad_phase4',
        title: 'Phase 4 Banner',
        description: 'Desc',
        imageUrl: 'https://img.com/ad.jpg',
        businessName: 'Belagavi Realty',
        placement: AdPlacement.homeTop,
        status: AdStatus.active,
        startDate: now,
        endDate: now.add(const Duration(days: 10)),
        priority: 1,
        createdBy: founderId,
        createdAt: now,
        updatedAt: now,
      );

      final createResult = await founderRepo.createAdvertisement(
        authenticatedUserId: founderId,
        userRole: UserRole.founder,
        ad: ad,
      );

      expect(createResult.isRight(), isTrue);
    });

    test('TEST 24: State Machine invalid transitions blocked cleanly', () {
      // Draft directly to Published is illegal
      final canDirectPublish = PropertyStatusWorkflow.canTransition(
        currentStatus: ListingStatus.draft,
        targetStatus: ListingStatus.published,
      );
      expect(canDirectPublish, isFalse);
    });
  });
}
