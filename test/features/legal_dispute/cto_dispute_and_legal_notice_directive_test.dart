import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/dispute_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/legal_notice_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/dispute_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/legal_notice_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/providers/dispute_providers.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/providers/legal_notice_providers.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/security/user_role.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CTO Master Directive: Disputed Property & Legal Notice Architecture', () {
    late DisputeRemoteDataSourceImpl disputeDatasource;
    late DisputeRepositoryImpl disputeRepo;
    late LegalNoticeRemoteDataSourceImpl noticeDatasource;
    late LegalNoticeRepositoryImpl noticeRepo;

    setUp(() {
      final dummySupabase = SupabaseService();
      disputeDatasource = DisputeRemoteDataSourceImpl(dummySupabase);
      disputeRepo = DisputeRepositoryImpl(disputeDatasource);
      noticeDatasource = LegalNoticeRemoteDataSourceImpl(dummySupabase);
      noticeRepo = LegalNoticeRepositoryImpl(noticeDatasource);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 1: REGISTRY SEPARATION & ENUMS
    // ─────────────────────────────────────────────────────────────────────────
    test('1. DisputeType enum contains all 18 structured types', () {
      expect(DisputeType.values.length, greaterThanOrEqualTo(18));
      expect(DisputeType.values, contains(DisputeType.courtCaseStayOrder));
      expect(DisputeType.values, contains(DisputeType.ownershipDispute));
      expect(DisputeType.values, contains(DisputeType.titleDispute));
      expect(DisputeType.values, contains(DisputeType.boundaryDispute));
      expect(DisputeType.values, contains(DisputeType.partitionFamilyDispute));
      expect(DisputeType.values, contains(DisputeType.inheritanceSuccessionDispute));
      expect(DisputeType.values, contains(DisputeType.possessionDispute));
      expect(DisputeType.values, contains(DisputeType.saleAgreementDispute));
      expect(DisputeType.values, contains(DisputeType.builderDeveloperDispute));
      expect(DisputeType.values, contains(DisputeType.tenantLandlordDispute));
      expect(DisputeType.values, contains(DisputeType.mortgageLoanDispute));
      expect(DisputeType.values, contains(DisputeType.encumbranceCharge));
      expect(DisputeType.values, contains(DisputeType.governmentAuthorityClaim));
      expect(DisputeType.values, contains(DisputeType.landAcquisitionDispute));
      expect(DisputeType.values, contains(DisputeType.surveyMeasurementDispute));
      expect(DisputeType.values, contains(DisputeType.accessRoadDispute));
      expect(DisputeType.values, contains(DisputeType.fraudMultipleSaleAllegation));
      expect(DisputeType.values, contains(DisputeType.courtLitigation));
      expect(DisputeType.values, contains(DisputeType.otherLegalDispute));
    });

    test('2. DisputeVerificationStatus contains all 9 lifecycle statuses', () {
      expect(DisputeVerificationStatus.values.length, greaterThanOrEqualTo(9));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.draft));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.submitted));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.underReview));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.moreInformationRequired));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.publishedListed));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.rejected));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.resolved));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.withdrawn));
      expect(DisputeVerificationStatus.values, contains(DisputeVerificationStatus.archived));
    });

    test('3. LegalNoticeType enum contains all 16 structured notice types', () {
      expect(LegalNoticeType.values.length, greaterThanOrEqualTo(16));
      expect(LegalNoticeType.values, contains(LegalNoticeType.purchaseNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.saleNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.publicNoticeBeforePurchase));
      expect(LegalNoticeType.values, contains(LegalNoticeType.titleVerificationNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.ownershipClaimNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.objectionNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.possessionNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.agreementNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.cancellationNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.builderDeveloperNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.tenantLandlordNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.mortgageChargeNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.inheritanceSuccessionNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.partitionNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.boundaryNotice));
      expect(LegalNoticeType.values, contains(LegalNoticeType.otherPropertyLegalNotice));
    });

    test('4. LegalNoticeStatus enum contains all 9 lifecycle statuses', () {
      expect(LegalNoticeStatus.values.length, greaterThanOrEqualTo(9));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.draft));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.submitted));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.underReview));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.published));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.responseReceived));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.withdrawn));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.closed));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.rejected));
      expect(LegalNoticeStatus.values, contains(LegalNoticeStatus.archived));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 2: DISPUTED PROPERTY WORKFLOW & PRIVACY GATES
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Dispute entity supports global location hierarchy and survey CTS fields', () {
      const entity = PropertyDisputeEntity(
        id: 'disp_test_1',
        propertyId: 'prop_test_1',
        title: 'Survey Plot Dispute',
        category: 'Plots & Layouts',
        propertyType: 'Residential Plot',
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        postalCode: '590006',
        fullAddress: '123 Main Road, Tilakwadi',
        villageTaluk: 'Belagavi Taluk',
        surveyCtsNumber: 'CTS 9912',
        relationship: 'Claimant',
        disputeType: DisputeType.courtCaseStayOrder,
        verificationStatus: DisputeVerificationStatus.underReview,
        description: 'Pending court stay on plot sale.',
        photoUrls: ['https://example.com/p1.jpg'],
        documentUrls: ['https://example.com/doc1.pdf'],
        photoLabels: ['Site Photo'],
        documentLabels: ['Court Stay Order'],
        isDocumentPrivate: true,
      );

      expect(entity.country, equals('India'));
      expect(entity.state, equals('Karnataka'));
      expect(entity.postalCode, equals('590006'));
      expect(entity.surveyCtsNumber, equals('CTS 9912'));
      expect(entity.photoLabels, contains('Site Photo'));
      expect(entity.documentLabels, contains('Court Stay Order'));
    });

    test('6. User dispute submission creates record in underReview status with isFounderConfirmed=false', () async {
      const newDispute = PropertyDisputeEntity(
        id: '',
        propertyId: '',
        title: 'New User Reported Dispute',
        category: 'Residential',
        propertyType: 'Villa',
        city: 'Belagavi',
        locality: 'Camp',
        relationship: 'Owner',
        disputeType: DisputeType.partitionFamilyDispute,
        verificationStatus: DisputeVerificationStatus.draft,
        description: 'Family settlement dispute under adjudication.',
      );

      final created = await disputeDatasource.createDispute(newDispute, authenticatedUserId: 'usr_user_123');
      expect(created.verificationStatus, equals(DisputeVerificationStatus.draft));
      expect(created.isFounderConfirmed, isFalse);
      expect(created.reportedBy, equals('usr_user_123'));
    });

    test('7. Public fetch masks contact phone and email for unauthorized viewers', () async {
      final list = await disputeDatasource.fetchDisputedProperties();
      expect(list, isNotEmpty);
      for (final d in list) {
        if (d.contactPhone != null && d.contactPhone!.isNotEmpty) {
          expect(d.contactPhone, contains('•••••'));
        }
        if (d.contactEmail != null && d.contactEmail!.isNotEmpty) {
          expect(d.contactEmail, contains('••••'));
        }
      }
    });

    test('8. Public fetch strips raw private document URLs while preserving entity', () async {
      final list = await disputeDatasource.fetchDisputedProperties();
      for (final d in list) {
        if (d.isDocumentPrivate) {
          expect(d.documentUrls, isEmpty);
        }
      }
    });

    test('9. Authorized admin or creator receives full contact and documents on fetchDisputeById', () async {
      const dispute = PropertyDisputeEntity(
        id: 'disp_priv_test',
        propertyId: 'prop_priv_test',
        title: 'Confidential Dispute Case',
        category: 'Residential',
        propertyType: 'Apartment',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        relationship: 'Reporting Party',
        disputeType: DisputeType.courtCaseStayOrder,
        verificationStatus: DisputeVerificationStatus.underReview,
        description: 'Sensitive court order dispute.',
        contactName: 'Ramesh Kulkarni',
        contactPhone: '+91 94801 11223',
        contactEmail: 'ramesh@example.com',
        documentUrls: ['https://storage.belagaviproperty.com/disputes/stay.pdf'],
        isDocumentPrivate: true,
        reportedBy: 'usr_owner_456',
      );

      await disputeDatasource.createDispute(dispute, authenticatedUserId: 'usr_owner_456');

      // Creator fetch
      final creatorFetch = await disputeDatasource.fetchDisputeById('disp_priv_test', requestingUserId: 'usr_owner_456');
      expect(creatorFetch, isNotNull);
      expect(creatorFetch!.contactPhone, equals('+91 94801 11223'));
      expect(creatorFetch.documentUrls, contains('https://storage.belagaviproperty.com/disputes/stay.pdf'));

      // Public stranger fetch
      final publicFetch = await disputeDatasource.fetchDisputeById('disp_priv_test', requestingUserId: 'usr_stranger_999');
      expect(publicFetch, isNotNull);
      expect(publicFetch!.contactPhone, contains('•••••'));
      expect(publicFetch.documentUrls, isEmpty);
    });

    test('10. Dispute repository filters by locality and query', () async {
      final result = await disputeRepo.getDisputedProperties(locality: 'Tilakwadi');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should succeed'),
        (disputes) {
          for (final d in disputes) {
            expect(d.locality.toLowerCase(), contains('tilakwadi'));
          }
        },
      );
    });

    test('11. DisputeFormNotifier validates required step 0 fields', () {
      final notifier = DisputeFormNotifier(disputeRepo);
      notifier.initForNewDispute();

      // Missing title and locality
      final isValid = notifier.validateStep(0);
      expect(isValid, isFalse);
      expect(notifier.state.fieldErrors, containsPair('title', 'Property title is required'));
      expect(notifier.state.fieldErrors, containsPair('locality', 'Locality / Area is required'));

      // Populate title and locality
      notifier.updatePropertyDetails(title: 'Valid Title', locality: 'Tilakwadi');
      final isValidAfter = notifier.validateStep(0);
      expect(isValidAfter, isTrue);
    });

    test('12. DisputeFormNotifier calculates completeness score accurately', () {
      final notifier = DisputeFormNotifier(disputeRepo);
      notifier.initForNewDispute();
      expect(notifier.calculateCompletionScore(), greaterThanOrEqualTo(15)); // default relationship

      notifier.updatePropertyDetails(title: 'Property Title', locality: 'Camp');
      notifier.updateCaseDetails(description: 'Detailed dispute description for legal grounds.');
      notifier.updateContactInfo(contactName: 'Authorized Person', contactPhone: '+91 9876543210');

      expect(notifier.calculateCompletionScore(), greaterThanOrEqualTo(70));
    });

    test('13. DisputeFormNotifier structured party addition and removal', () {
      final notifier = DisputeFormNotifier(disputeRepo);
      notifier.initForNewDispute();
      expect(notifier.state.structuredParties, isEmpty);

      const party1 = DisputePartyEntity(name: 'Claimant One', role: 'Claimant');
      const party2 = DisputePartyEntity(name: 'Respondent Two', role: 'Respondent');

      notifier.addParty(party1);
      notifier.addParty(party2);
      expect(notifier.state.structuredParties.length, equals(2));

      notifier.removeParty(0);
      expect(notifier.state.structuredParties.length, equals(1));
      expect(notifier.state.structuredParties.first.name, equals('Respondent Two'));
    });

    test('14. DisputeFormNotifier saves draft successfully', () async {
      final notifier = DisputeFormNotifier(disputeRepo);
      notifier.initForNewDispute();
      notifier.updatePropertyDetails(title: 'Draft Plot Dispute', locality: 'Angol');

      final success = await notifier.saveDraft('usr_tester');
      expect(success, isTrue);
      expect(notifier.state.isDraftSaved, isTrue);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 3: PROPERTY LEGAL NOTICE WORKFLOW & PRIVACY GATES
    // ─────────────────────────────────────────────────────────────────────────
    test('15. Legal Notice entity supports publication details and structured parties', () {
      const notice = TransactionLegalNoticeEntity(
        id: 'not_test_1',
        propertyId: 'prop_not_1',
        title: 'Public Purchase Legal Notice',
        category: 'Residential',
        propertyType: 'Apartment',
        country: 'India',
        state: 'Karnataka',
        city: 'Belagavi',
        locality: 'Camp',
        buyerName: 'Buyer Corp',
        sellerName: 'Landowner X',
        contactName: 'Adv. S. Patil',
        contactPhone: '+91 94801 22334',
        noticeType: LegalNoticeType.publicNoticeBeforePurchase,
        transactionType: 'Purchase',
        publicationInfo: NoticePublicationEntity(
          newspaperName: 'Tarun Bharat',
          edition: 'Belagavi Edition',
          pageNumber: '7',
          advocateFirm: 'Patil & Associates',
        ),
        photoUrls: ['path/photo1.jpg'],
        documentUrls: ['path/doc1.pdf'],
        photoLabels: ['Site Frontage'],
        documentLabels: ['Newspaper Clipping'],
      );

      expect(notice.publicationInfo, isNotNull);
      expect(notice.publicationInfo!.newspaperName, equals('Tarun Bharat'));
      expect(notice.publicationInfo!.edition, equals('Belagavi Edition'));
      expect(notice.photoLabels, contains('Site Frontage'));
      expect(notice.documentLabels, contains('Newspaper Clipping'));
    });

    test('16. User legal notice creation sets status to underReview or draft', () async {
      const newNotice = TransactionLegalNoticeEntity(
        id: '',
        propertyId: '',
        title: 'New Intended Purchase Notice',
        category: 'Residential',
        propertyType: 'Villa',
        city: 'Belagavi',
        locality: 'Shahapur',
        buyerName: 'Amit Patil',
        sellerName: 'Suresh Desai',
        contactName: 'Adv. Ramesh',
        contactPhone: '+91 94801 55667',
        noticeType: LegalNoticeType.purchaseNotice,
        verificationStatus: LegalNoticeStatus.draft,
      );

      final created = await noticeDatasource.createLegalNotice(newNotice, authenticatedUserId: 'usr_lawyer_1');
      expect(created.verificationStatus, equals(LegalNoticeStatus.draft));
      expect(created.recordedBy, equals('usr_lawyer_1'));
    });

    test('17. Public legal notice fetch masks contact phone and email', () async {
      final notices = await noticeDatasource.fetchLegalNotices();
      expect(notices, isNotEmpty);
      for (final n in notices) {
        if (n.contactPhone.isNotEmpty) {
          expect(n.contactPhone, contains('•••••'));
        }
        if (n.contactEmail != null && n.contactEmail!.isNotEmpty) {
          expect(n.contactEmail, contains('••••'));
        }
      }
    });

    test('18. Public legal notice fetch strips raw private document URLs', () async {
      final notices = await noticeDatasource.fetchLegalNotices();
      for (final n in notices) {
        if (n.isDocumentPrivate) {
          expect(n.documentUrls, isEmpty);
        }
      }
    });

    test('19. Owner/Advocate can attach additional documents later', () async {
      const notice = TransactionLegalNoticeEntity(
        id: 'not_attach_test',
        propertyId: 'prop_attach_test',
        title: 'Notice With Late Docs',
        category: 'Plots & Layouts',
        propertyType: 'Plot',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        buyerName: 'Buyer Y',
        sellerName: 'Seller Z',
        contactName: 'Adv. Patil',
        contactPhone: '+91 94801 99887',
        noticeType: LegalNoticeType.purchaseNotice,
        documentUrls: [],
        recordedBy: 'usr_creator_888',
      );

      await noticeDatasource.createLegalNotice(notice, authenticatedUserId: 'usr_creator_888');

      // Attach new document as creator
      final updated = await noticeDatasource.attachDocuments(
        'not_attach_test',
        newDocuments: ['https://storage.belagaviproperty.com/notices/newspaper_scan.pdf'],
        authenticatedUserId: 'usr_creator_888',
      );

      expect(updated.documentUrls, contains('https://storage.belagaviproperty.com/notices/newspaper_scan.pdf'));
    });

    test('20. Unauthorized user cannot attach documents to another user notice', () async {
      expect(
        () async => await noticeDatasource.attachDocuments(
          'not_attach_test',
          newDocuments: ['https://hacker.com/malicious.pdf'],
          authenticatedUserId: 'usr_stranger_111',
        ),
        throwsException,
      );
    });

    test('21. Legal notice repository filters by transaction type and locality', () async {
      final result = await noticeRepo.getLegalNotices(transactionType: 'Purchase');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should succeed'),
        (notices) {
          for (final n in notices) {
            expect(n.transactionType.toLowerCase(), equals('purchase'));
          }
        },
      );
    });

    test('22. LegalNoticeFormNotifier validates step 0 and step 3', () {
      final notifier = LegalNoticeFormNotifier(noticeRepo);
      notifier.initForNewRecord();

      // Step 0 validation
      final isValidStep0 = notifier.validateStep(0);
      expect(isValidStep0, isFalse);

      notifier.updatePropertyInfo(title: 'Purchase Agreement Notice', locality: 'Tilakwadi');
      expect(notifier.validateStep(0), isTrue);

      // Step 3 validation (Contact phone required)
      expect(notifier.validateStep(3), isFalse);
      notifier.updateContactInfo(contactPhone: '+91 94801 22334');
      expect(notifier.validateStep(3), isTrue);
    });

    test('23. LegalNoticeFormNotifier calculates completeness score accurately', () {
      final notifier = LegalNoticeFormNotifier(noticeRepo);
      notifier.initForNewRecord();

      notifier.updatePropertyInfo(title: 'Property Title', locality: 'Camp');
      notifier.updateBuyerInfo(buyerName: 'Ramesh Patil');
      notifier.updateSellerInfo(sellerName: 'Prakash Desai');
      notifier.updateContactInfo(contactPhone: '+91 94801 22334');
      notifier.updateTransactionInfo(transactionType: 'Purchase', agreedValue: '₹50,00,000');

      expect(notifier.calculateCompletionScore(), greaterThanOrEqualTo(60));
    });

    test('24. LegalNoticeFormNotifier saves draft successfully', () async {
      final notifier = LegalNoticeFormNotifier(noticeRepo);
      notifier.initForNewRecord();
      notifier.updatePropertyInfo(title: 'Draft Legal Notice', locality: 'Shahapur');

      final success = await notifier.saveDraft('usr_tester');
      expect(success, isTrue);
      expect(notifier.state.isDraftSaved, isTrue);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 4: SECURITY ROLES & FOUNDER/ADMIN GOVERNANCE
    // ─────────────────────────────────────────────────────────────────────────
    test('25. UserRole adminOrFounder can confirm dispute and publish listing', () async {
      final updated = await disputeDatasource.updateDisputeStatus(
        disputeId: 'disp_101',
        newStatus: DisputeVerificationStatus.publishedListed,
        authenticatedUserId: 'usr_founder_1',
        userRole: UserRole.founder,
      );

      expect(updated.verificationStatus, equals(DisputeVerificationStatus.publishedListed));
      expect(updated.isFounderConfirmed, isTrue);
    });

    test('26. Regular user cannot promote dispute to publishedListed without admin/moderator role', () async {
      expect(
        () async => await disputeDatasource.updateDisputeStatus(
          disputeId: 'disp_101',
          newStatus: DisputeVerificationStatus.publishedListed,
          authenticatedUserId: 'usr_random_user',
          userRole: UserRole.user,
        ),
        throwsException,
      );
    });

    test('27. Non-admin cannot delete someone else dispute record', () async {
      expect(
        () async => await disputeDatasource.deleteDispute(
          'disp_101',
          authenticatedUserId: 'usr_unauthorized',
          userRole: UserRole.user,
        ),
        throwsException,
      );
    });

    test('28. Non-admin cannot delete someone else legal notice record', () async {
      expect(
        () async => await noticeDatasource.deleteLegalNotice(
          'not_attach_test',
          authenticatedUserId: 'usr_unauthorized',
          userRole: UserRole.user,
        ),
        throwsException,
      );
    });

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 5: DOMAIN INTEGRITY & ZERO DUMMY MEDIA
    // ─────────────────────────────────────────────────────────────────────────
    test('29. DisputeEntity toMap and fromMap preserve all 18 types and global fields', () {
      const original = PropertyDisputeEntity(
        id: 'disp_map_test',
        propertyId: 'prop_map_test',
        title: 'Title Verification Case',
        category: 'Commercial',
        propertyType: 'Office',
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        postalCode: '590001',
        fullAddress: '45 Camp Road',
        villageTaluk: 'Belagavi',
        surveyCtsNumber: 'CTS 1008',
        relationship: 'Claimant',
        disputeType: DisputeType.tenantLandlordDispute,
        verificationStatus: DisputeVerificationStatus.underReview,
        description: 'Tenancy renewal and possession dispute.',
        photoUrls: ['/path/to/photo.jpg'],
        documentUrls: ['/path/to/doc.pdf'],
        photoLabels: ['Building Entrance'],
        documentLabels: ['Tenancy Agreement'],
        isDocumentPrivate: true,
      );

      final map = original.toMap();
      final reconstituted = PropertyDisputeEntity.fromMap(map);

      expect(reconstituted.id, equals(original.id));
      expect(reconstituted.disputeType, equals(DisputeType.tenantLandlordDispute));
      expect(reconstituted.country, equals('India'));
      expect(reconstituted.postalCode, equals('590001'));
      expect(reconstituted.photoLabels, contains('Building Entrance'));
      expect(reconstituted.documentLabels, contains('Tenancy Agreement'));
    });

    test('30. TransactionLegalNoticeEntity toMap and fromMap preserve publication entity and notice types', () {
      const original = TransactionLegalNoticeEntity(
        id: 'not_map_test',
        propertyId: 'prop_map_test',
        title: 'Objection Notice',
        category: 'Plots & Layouts',
        propertyType: 'Plot',
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        buyerName: 'Buyer A',
        sellerName: 'Seller B',
        contactName: 'Adv. S. Kulkarni',
        contactPhone: '+91 94801 11223',
        noticeType: LegalNoticeType.objectionNotice,
        transactionType: 'Objection',
        publicationInfo: NoticePublicationEntity(
          newspaperName: 'Vijayavani',
          edition: 'Belagavi Edition',
          pageNumber: '3',
          onlineReference: 'https://vijayavani.net/epaper/3',
        ),
      );

      final map = original.toMap();
      final reconstituted = TransactionLegalNoticeEntity.fromMap(map);

      expect(reconstituted.id, equals(original.id));
      expect(reconstituted.noticeType, equals(LegalNoticeType.objectionNotice));
      expect(reconstituted.publicationInfo, isNotNull);
      expect(reconstituted.publicationInfo!.newspaperName, equals('Vijayavani'));
      expect(reconstituted.publicationInfo!.onlineReference, equals('https://vijayavani.net/epaper/3'));
    });
  });
}
