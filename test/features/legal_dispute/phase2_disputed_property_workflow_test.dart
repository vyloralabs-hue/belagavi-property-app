import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/dispute_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/dispute_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/repositories/dispute_repository.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/providers/dispute_providers.dart';

void main() {
  late DisputeRemoteDataSource remoteDataSource;
  late DisputeRepository repository;

  setUp(() {
    final supabase = SupabaseService();
    remoteDataSource = DisputeRemoteDataSourceImpl(supabase);
    repository = DisputeRepositoryImpl(remoteDataSource);
  });

  group('Phase 2 â€” Disputed Property Repository & Security Tests', () {
    test('1. Create Disputed Property Listing with private docs & underReview status', () async {
      final newDispute = PropertyDisputeEntity(
        id: 'disp_test_201',
        propertyId: 'prop_camp_house_201',
        title: 'Bungalow in Camp with Injunction Order',
        category: 'Residential',
        propertyType: 'Independent House',
        city: 'Belagavi',
        locality: 'Camp',
        surveyCtsNumber: 'CTS No. 892/1',
        relationship: 'I am claiming an interest',
        disputeType: DisputeType.courtCaseStayOrder,
        courtAuthority: 'Civil Court Senior Division, Belagavi',
        caseNumber: 'OS 440/2026',
        caseYear: '2026',
        caseStatus: 'Temporary Injunction Order in force',
        litigatingParties: 'Petitioner vs Vendor',
        description: 'Temporary injunction granted restraining alienation or creation of third-party rights.',
        contactName: 'Adv. Suresh Kulkarni',
        contactPhone: '+91 98801 12345',
        contactEmail: 'suresh.law@example.com',
        photoUrls: const ['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00'],
        documentUrls: const ['https://storage.belagaviproperty.com/disputes/injunction_order_440.pdf'],
        isDocumentPrivate: true,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final result = await repository.createDispute(newDispute, authenticatedUserId: 'usr_claimant_440');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected successful creation'),
        (created) {
          expect(created.id, equals('disp_test_201'));
          expect(created.verificationStatus, equals(DisputeVerificationStatus.underReview));
          expect(created.isDocumentPrivate, isTrue);
          expect(created.reportedBy, equals('usr_claimant_440'));
        },
      );
    });

    test('2. Public fetch masks private contact info and strips private legal documents', () async {
      final result = await repository.getDisputeById(
        'disp_101',
        requestingUserId: 'usr_anonymous_public',
        userRole: UserRole.user,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected dispute to exist'),
        (dispute) {
          expect(dispute, isNotNull);
          // Security check: Phone must be masked for public
          expect(dispute!.contactPhone, contains('•••••'));
          // Security check: Private documents must be stripped from public payload
          expect(dispute.documentUrls, isEmpty);
        },
      );
    });

    test('3. Admin / Moderator fetch receives unmasked private contact & legal documents', () async {
      final result = await repository.getDisputeById(
        'disp_101',
        requestingUserId: 'usr_admin_1',
        userRole: UserRole.admin,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected dispute to exist'),
        (dispute) {
          expect(dispute, isNotNull);
          // Admin sees full contact info and private document urls
          expect(dispute!.contactPhone, equals('+91 94801 22334'));
          expect(dispute.documentUrls.isNotEmpty, isTrue);
          expect(dispute.documentUrls.first, contains('stay_order_112.pdf'));
        },
      );
    });

    test('4. Filter disputes by DisputeType, Locality, and Query', () async {
      // Filter by DisputeType.courtCaseStayOrder
      final stayOrders = await repository.getDisputedProperties(type: DisputeType.courtCaseStayOrder);
      stayOrders.fold(
        (_) => fail('Failed to fetch stay orders'),
        (list) {
          expect(list.every((d) => d.disputeType == DisputeType.courtCaseStayOrder), isTrue);
        },
      );

      // Filter by Locality 'Sambra'
      final sambraList = await repository.getDisputedProperties(locality: 'Sambra');
      sambraList.fold(
        (_) => fail('Failed to fetch sambra disputes'),
        (list) {
          expect(list.any((d) => d.locality.contains('Sambra')), isTrue);
        },
      );

      // Search by Case Number 'WP 48291'
      final searchResult = await repository.getDisputedProperties(query: 'WP 48291');
      searchResult.fold(
        (_) => fail('Failed search'),
        (list) {
          expect(list.any((d) => d.caseNumber == 'WP 48291/2024'), isTrue);
        },
      );
    });

    test('5. Moderation workflow: Update dispute verification status', () async {
      final updateResult = await repository.updateDisputeStatus(
        disputeId: 'disp_101',
        newStatus: DisputeVerificationStatus.documentVerified,
        authenticatedUserId: 'usr_moderator_1',
        userRole: UserRole.admin,
      );

      expect(updateResult.isRight(), isTrue);
      updateResult.fold(
        (_) => fail('Expected update success'),
        (updated) {
          expect(updated.verificationStatus, equals(DisputeVerificationStatus.documentVerified));
        },
      );
    });
  });

  group('Phase 2 â€” DisputeFormNotifier Wizard & Form Tests', () {
    test('6. Form state calculates completeness score accurately', () {
      final formNotifier = DisputeFormNotifier(repository);

      // Initial empty score
      expect(formNotifier.calculateCompletionScore(), equals(15)); // Has default relationship

      // Add Title & Locality (+25)
      formNotifier.updatePropertyDetails(
        title: '30x50 Plot in Tilakwadi with Boundary Dispute',
        locality: 'Tilakwadi',
      );
      expect(formNotifier.calculateCompletionScore(), equals(40));

      // Add Description (+20)
      formNotifier.updateCaseDetails(
        description: 'Adjacent owner has filed boundary dispute regarding compound wall.',
        courtAuthority: 'Civil Court Belagavi',
        caseNumber: 'OS 55/2025',
      );
      expect(formNotifier.calculateCompletionScore(), equals(75));

      // Add Photo (+10), Document (+5), Contact (+10)
      formNotifier.addPhoto('https://images.unsplash.com/photo-site');
      formNotifier.addDocument('Survey_demarcation_notice.pdf');
      formNotifier.updateContactInfo(
        contactName: 'Mahesh Patil',
        contactPhone: '+91 98800 55443',
      );

      expect(formNotifier.calculateCompletionScore(), equals(100));
    });

    test('7. Form rejects submission when mandatory fields are missing', () async {
      final formNotifier = DisputeFormNotifier(repository);
      formNotifier.initForNewDispute();

      // Submit without title or locality
      final success = await formNotifier.submitDispute('usr_test_1');
      expect(success, isFalse);
      expect(formNotifier.getMissingFields().contains('Property Title'), isTrue);
      expect(formNotifier.getMissingFields().contains('Locality / Area'), isTrue);
    });

    test('8. Full end-to-end form completion and submission', () async {
      final formNotifier = DisputeFormNotifier(repository);
      formNotifier.initForNewDispute();

      formNotifier.updateRelationship('I own this property');
      formNotifier.updatePropertyDetails(
        title: 'Commercial Complex Khanapur Road Title Challenge',
        category: 'Commercial',
        propertyType: 'Commercial Showroom',
        city: 'Belagavi',
        locality: 'Khanapur Road',
        surveyCtsNumber: 'CTS 9081',
      );
      formNotifier.updateDisputeType(DisputeType.titleDispute);
      formNotifier.updateCaseDetails(
        description: 'Prior purchaser dispute regarding agreement to sell registration cancellation.',
        courtAuthority: 'Civil Judge Senior Division Belagavi',
        caseNumber: 'RA 18/2026',
        caseYear: '2026',
        caseStatus: 'Appeal Pending Adjudication',
        litigatingParties: 'Appellants vs Developer',
      );
      formNotifier.addPhoto('https://images.unsplash.com/commercial-site-1');
      formNotifier.addDocument('Appeal_Memorandum_RA18.pdf');
      formNotifier.updateContactInfo(
        contactName: 'Advocate V. Deshpande',
        contactPhone: '+91 94481 00223',
        contactEmail: 'deshpande.adv@example.com',
      );

      final success = await formNotifier.submitDispute('usr_owner_9081');
      expect(success, isTrue);

      // Verify the newly created dispute exists in registry
      final list = await repository.getDisputedProperties(query: 'Commercial Complex Khanapur Road');
      list.fold(
        (_) => fail('Failed to retrieve newly created dispute'),
        (disputes) {
          expect(disputes.any((d) => d.title.contains('Commercial Complex Khanapur Road')), isTrue);
        },
      );
    });
  });
}