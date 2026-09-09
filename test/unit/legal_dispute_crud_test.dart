import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/dispute_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/legal_notice_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/dispute_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/legal_notice_repository_impl.dart';

void main() {
  group('Disputed Property & Legal Notice CRUD Contract Tests', () {
    late DisputeRepositoryImpl disputeRepo;
    late LegalNoticeRepositoryImpl legalNoticeRepo;

    setUp(() {
      final uninitSupabase = SupabaseService();
      final disputeDs = DisputeRemoteDataSourceImpl(uninitSupabase);
      final legalNoticeDs = LegalNoticeRemoteDataSourceImpl(uninitSupabase);
      disputeRepo = DisputeRepositoryImpl(disputeDs);
      legalNoticeRepo = LegalNoticeRepositoryImpl(legalNoticeDs);
    });

    test('Dispute CRUD: Create, Edit with exact same UUID, Withdraw, and Delete', () async {
      const testUserId = 'usr_test_firebase_123';
      const fixedUuid = 'd0000000-0000-4000-8000-000000000001';

      final initialDispute = PropertyDisputeEntity(
        id: fixedUuid,
        title: 'Original Disputed Property in Tilakwadi',
        propertyType: 'House',
        disputeType: DisputeType.ownershipDispute,
        disputeCategory: 'Ownership / Title',
        locality: 'Tilakwadi',
        city: 'Belagavi',
        state: 'Karnataka',
        verificationStatus: DisputeVerificationStatus.draft,
        creatorId: testUserId,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // 1. Create
      final createResult = await disputeRepo.createDispute(
        initialDispute,
        authenticatedUserId: testUserId,
      );
      expect(createResult.isRight(), isTrue);
      createResult.fold(
        (_) => fail('Create should succeed'),
        (created) {
          expect(created.id, fixedUuid);
          expect(created.title, 'Original Disputed Property in Tilakwadi');
          expect(created.verificationStatus, DisputeVerificationStatus.draft);
        },
      );

      // 2. Edit (MUST retain the exact same UUID)
      final editedDispute = initialDispute.copyWith(
        title: 'Updated Disputed Property Title After Review',
        verificationStatus: DisputeVerificationStatus.submitted,
      );
      final updateResult = await disputeRepo.updateDispute(
        editedDispute,
        authenticatedUserId: testUserId,
      );
      expect(updateResult.isRight(), isTrue);
      updateResult.fold(
        (_) => fail('Update should succeed'),
        (updated) {
          expect(updated.id, fixedUuid, reason: 'UUID must be strictly preserved on edit');
          expect(updated.title, 'Updated Disputed Property Title After Review');
          expect(updated.verificationStatus, DisputeVerificationStatus.submitted);
        },
      );

      // 3. Status Transition: Withdraw
      final withdrawResult = await disputeRepo.updateDisputeStatus(
        disputeId: fixedUuid,
        newStatus: DisputeVerificationStatus.withdrawn,
        authenticatedUserId: testUserId,
      );
      expect(withdrawResult.isRight(), isTrue);
      withdrawResult.fold(
        (_) => fail('Withdraw should succeed'),
        (withdrawn) {
          expect(withdrawn.id, fixedUuid);
          expect(withdrawn.verificationStatus, DisputeVerificationStatus.withdrawn);
        },
      );

      // 4. Delete
      final deleteResult = await disputeRepo.deleteDispute(
        fixedUuid,
        authenticatedUserId: testUserId,
      );
      expect(deleteResult.isRight(), isTrue);

      // Verify deletion from store
      final getAfterDelete = await disputeRepo.getDisputeById(
        fixedUuid,
        requestingUserId: testUserId,
      );
      getAfterDelete.fold(
        (_) => fail('Should return either null or not found'),
        (found) => expect(found, isNull),
      );
    });

    test('Legal Notice CRUD: Create, Edit with same UUID, Update Status, Delete', () async {
      const testPublisherId = 'usr_pub_firebase_456';
      const fixedNoticeUuid = 'n0000000-0000-4000-8000-000000000002';

      final initialNotice = TransactionLegalNoticeEntity(
        id: fixedNoticeUuid,
        propertyId: 'prop_999',
        title: 'Public Caveat Notice for Tilakwadi Plot',
        category: 'Plot',
        propertyType: 'Plot',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        buyerName: 'Amit Shah',
        sellerName: 'Ramesh Kulkarni',
        contactName: 'Adv. M. S. Patil',
        contactPhone: '+91 94481 00000',
        noticeType: LegalNoticeType.purchaseNotice,
        verificationStatus: LegalNoticeStatus.draft,
        recordedBy: testPublisherId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Create
      final createResult = await legalNoticeRepo.createLegalNotice(
        initialNotice,
        authenticatedUserId: testPublisherId,
      );
      expect(createResult.isRight(), isTrue);
      createResult.fold(
        (_) => fail('Create notice should succeed'),
        (created) {
          expect(created.id, fixedNoticeUuid);
          expect(created.title, 'Public Caveat Notice for Tilakwadi Plot');
          expect(created.verificationStatus, LegalNoticeStatus.draft);
        },
      );

      // 2. Edit (MUST retain the exact same UUID)
      final editedNotice = initialNotice.copyWith(
        title: 'Updated Public Caveat Notice: Clarified Boundaries',
        verificationStatus: LegalNoticeStatus.underReview,
      );
      final updateResult = await legalNoticeRepo.updateLegalNotice(
        editedNotice,
        authenticatedUserId: testPublisherId,
      );
      expect(updateResult.isRight(), isTrue);
      updateResult.fold(
        (_) => fail('Update notice should succeed'),
        (updated) {
          expect(updated.id, fixedNoticeUuid, reason: 'UUID must be strictly preserved on edit');
          expect(updated.title, 'Updated Public Caveat Notice: Clarified Boundaries');
        },
      );

      // 3. Status Transition: Withdrawn / Archived
      final statusResult = await legalNoticeRepo.updateStatus(
        noticeId: fixedNoticeUuid,
        newStatus: LegalNoticeStatus.withdrawn,
        authenticatedUserId: testPublisherId,
      );
      expect(statusResult.isRight(), isTrue);
      statusResult.fold(
        (_) => fail('Status update should succeed'),
        (statusUpdated) {
          expect(statusUpdated.id, fixedNoticeUuid);
          expect(statusUpdated.verificationStatus, LegalNoticeStatus.withdrawn);
        },
      );

      // 4. Delete
      final deleteResult = await legalNoticeRepo.deleteLegalNotice(
        fixedNoticeUuid,
        authenticatedUserId: testPublisherId,
      );
      expect(deleteResult.isRight(), isTrue);

      // Verify deletion
      final getAfterDelete = await legalNoticeRepo.getLegalNoticeById(
        fixedNoticeUuid,
        requestingUserId: testPublisherId,
      );
      getAfterDelete.fold(
        (_) => fail('Should return either null or not found'),
        (found) => expect(found, isNull),
      );
    });
  });
}
