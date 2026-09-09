import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/dispute_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/legal_notice_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/dispute_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/legal_notice_repository_impl.dart';

void main() {
  group('Legal & Dispute Security and Storage Hardening Tests', () {
    late DisputeRepositoryImpl disputeRepo;
    late LegalNoticeRepositoryImpl legalNoticeRepo;

    const userA = 'firebase_user_A_111';
    const userB = 'firebase_user_B_222';
    const adminUser = 'firebase_admin_999';

    setUp(() {
      final uninitSupabase = SupabaseService();
      final disputeDs = DisputeRemoteDataSourceImpl(uninitSupabase);
      final legalNoticeDs = LegalNoticeRemoteDataSourceImpl(uninitSupabase);
      disputeRepo = DisputeRepositoryImpl(disputeDs);
      legalNoticeRepo = LegalNoticeRepositoryImpl(legalNoticeDs);
    });

    test('User-B cannot edit User-A dispute (Unauthorized check)', () async {
      const disputeId = 'd-sec-001';
      final dispute = PropertyDisputeEntity(
        id: disputeId,
        title: "User A's Dispute Listing",
        propertyType: 'Plot',
        disputeType: DisputeType.ownershipDispute,
        disputeCategory: 'Title Dispute',
        locality: 'Camp',
        city: 'Belagavi',
        state: 'Karnataka',
        verificationStatus: DisputeVerificationStatus.draft,
        creatorId: userA,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final created = await disputeRepo.createDispute(dispute, authenticatedUserId: userA);
      expect(created.isRight(), isTrue);

      // User-B attempts to update User-A's dispute
      final maliciousEdit = dispute.copyWith(title: "Hacked by User B");
      final editResult = await disputeRepo.updateDispute(
        maliciousEdit,
        authenticatedUserId: userB,
      );

      expect(editResult.isLeft(), isTrue, reason: 'Cross-owner update must fail');
      editResult.fold(
        (failure) => expect(failure.message.toLowerCase(), contains('unauthorized')),
        (_) => fail('User-B should not be able to update User-A dispute'),
      );
    });

    test('User-B cannot delete User-A dispute (Unauthorized check)', () async {
      const disputeId = 'd-sec-002';
      final dispute = PropertyDisputeEntity(
        id: disputeId,
        title: "User A's Dispute To Keep",
        propertyType: 'Apartment',
        disputeType: DisputeType.ownershipDispute,
        disputeCategory: 'Builder Dispute',
        locality: 'Tilakwadi',
        city: 'Belagavi',
        state: 'Karnataka',
        verificationStatus: DisputeVerificationStatus.draft,
        creatorId: userA,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await disputeRepo.createDispute(dispute, authenticatedUserId: userA);

      // User-B attempts to delete User-A's dispute
      final deleteResult = await disputeRepo.deleteDispute(
        disputeId,
        authenticatedUserId: userB,
      );

      expect(deleteResult.isLeft(), isTrue, reason: 'Cross-owner delete must fail');
      deleteResult.fold(
        (failure) => expect(failure.message.toLowerCase(), contains('unauthorized')),
        (_) => fail('User-B should not be able to delete User-A dispute'),
      );
    });

    test('Self-publish denial: Normal user cannot self-publish dispute without admin/moderator role', () async {
      const disputeId = 'd-sec-003';
      final dispute = PropertyDisputeEntity(
        id: disputeId,
        title: "Unreviewed Dispute",
        propertyType: 'House',
        disputeType: DisputeType.courtLitigation,
        disputeCategory: 'Court Order',
        locality: 'Shahapur',
        city: 'Belagavi',
        state: 'Karnataka',
        verificationStatus: DisputeVerificationStatus.draft,
        creatorId: userA,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await disputeRepo.createDispute(dispute, authenticatedUserId: userA);

      // Normal user attempts to self-publish
      final publishAttempt = await disputeRepo.updateDisputeStatus(
        disputeId: disputeId,
        newStatus: DisputeVerificationStatus.publishedListed,
        authenticatedUserId: userA,
        userRole: UserRole.user,
      );

      expect(publishAttempt.isLeft(), isTrue, reason: 'Self-publishing without admin role must be denied');
      publishAttempt.fold(
        (failure) => expect(failure.message.toLowerCase(), contains('admin')),
        (_) => fail('Normal user should not be able to self-publish dispute'),
      );

      // Admin user CAN publish
      final adminPublish = await disputeRepo.updateDisputeStatus(
        disputeId: disputeId,
        newStatus: DisputeVerificationStatus.publishedListed,
        authenticatedUserId: adminUser,
        userRole: UserRole.admin,
      );

      expect(adminPublish.isRight(), isTrue, reason: 'Admin must be able to publish dispute');
      adminPublish.fold(
        (_) => fail('Admin publish should succeed'),
        (published) => expect(published.verificationStatus, DisputeVerificationStatus.publishedListed),
      );
    });

    test('User-B cannot edit or delete User-A legal notice', () async {
      const noticeId = 'n-sec-001';
      final notice = TransactionLegalNoticeEntity(
        id: noticeId,
        propertyId: 'p-sec-001',
        title: "User A's Legal Notice",
        category: 'Residential',
        propertyType: 'House',
        city: 'Belagavi',
        locality: 'Hindwadi',
        buyerName: 'Priya Deshmukh',
        sellerName: 'Vikas Jadhav',
        contactName: 'Adv. Kulkarni',
        contactPhone: '+91 98860 11111',
        noticeType: LegalNoticeType.publicCaveatNotice,
        verificationStatus: LegalNoticeStatus.draft,
        recordedBy: userA,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await legalNoticeRepo.createLegalNotice(notice, authenticatedUserId: userA);

      // User-B attempts to edit
      final editNotice = notice.copyWith(title: "Unauthorized Edit");
      final editResult = await legalNoticeRepo.updateLegalNotice(
        editNotice,
        authenticatedUserId: userB,
      );
      expect(editResult.isLeft(), isTrue);

      // User-B attempts to delete
      final deleteResult = await legalNoticeRepo.deleteLegalNotice(
        noticeId,
        authenticatedUserId: userB,
      );
      expect(deleteResult.isLeft(), isTrue);
    });

    test('Public read privacy masking: contact phone and email masked for public viewers', () async {
      const disputeId = 'd-sec-004';
      final dispute = PropertyDisputeEntity(
        id: disputeId,
        title: "Dispute With Contact Info",
        propertyType: 'Commercial',
        disputeType: DisputeType.ownershipDispute,
        disputeCategory: 'Title Claim',
        locality: 'Angol',
        city: 'Belagavi',
        state: 'Karnataka',
        verificationStatus: DisputeVerificationStatus.publishedListed,
        creatorId: userA,
        contactName: 'Real Owner Name',
        contactPhone: '+91 98765 43210',
        contactEmail: 'confidential_owner@example.com',
        documentUrls: const ['https://supabase.co/storage/v1/object/public/property-media/disputes/userA/d-sec-004/court_order.pdf'],
        isDocumentPrivate: true,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await disputeRepo.createDispute(dispute, authenticatedUserId: userA);

      // Public anonymous viewer fetches dispute
      final publicView = await disputeRepo.getDisputeById(disputeId, requestingUserId: 'public_anon_viewer');
      expect(publicView.isRight(), isTrue);
      publicView.fold(
        (_) => fail('Fetch should succeed'),
        (item) {
          expect(item, isNotNull);
          // Phone should be masked
          expect(item!.contactPhone, contains('•••••'));
          expect(item.contactPhone, isNot(contains('43210')));
          // Email should be masked
          expect(item.contactEmail, contains('••••@••••.com'));
          expect(item.contactEmail, isNot(contains('confidential_owner')));
          // Private documents should be suppressed
          expect(item.documentUrls, isEmpty);
        },
      );

      // Owner fetches dispute: full info is accessible
      final ownerView = await disputeRepo.getDisputeById(disputeId, requestingUserId: userA);
      ownerView.fold(
        (_) => fail('Owner fetch should succeed'),
        (item) {
          expect(item, isNotNull);
          expect(item!.contactPhone, '+91 98765 43210');
          expect(item.contactEmail, 'confidential_owner@example.com');
          expect(item.documentUrls, isNotEmpty);
        },
      );
    });

    test('Canonical storage path generation adheres to migration 00034 structure', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4]);

      final disputeUploadUrl = await disputeRepo.uploadDisputeDocumentFile(
        disputeId: 'd-test-uuid',
        fileName: 'affidavit.pdf',
        fileBytes: dummyBytes,
        authenticatedUserId: userA,
      );

      expect(disputeUploadUrl.isRight(), isTrue);
      disputeUploadUrl.fold(
        (_) => fail('Upload should succeed'),
        (url) {
          // Verify segment 1: disputes, segment 2: userA, segment 3: d-test-uuid
          expect(url, contains('disputes/$userA/d-test-uuid/'));
          expect(url, contains('affidavit.pdf'));
        },
      );

      final noticeUploadUrl = await legalNoticeRepo.uploadLegalNoticeDocumentFile(
        noticeId: 'n-test-uuid',
        fileName: 'public_notice.png',
        fileBytes: dummyBytes,
        authenticatedUserId: userA,
      );

      expect(noticeUploadUrl.isRight(), isTrue);
      noticeUploadUrl.fold(
        (_) => fail('Notice upload should succeed'),
        (url) {
          // Verify segment 1: legal_notices, segment 2: userA, segment 3: n-test-uuid
          expect(url, contains('legal_notices/$userA/n-test-uuid/'));
          expect(url, contains('public_notice.png'));
        },
      );
    });
  });
}
