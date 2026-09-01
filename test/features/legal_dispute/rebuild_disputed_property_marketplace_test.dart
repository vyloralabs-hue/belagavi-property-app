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

  group('REBUILT DISPUTED PROPERTY MARKETPLACE MODULE TEST SUITE', () {
    test(
      '1. Main Listing-First Marketplace Interface Categories and Enums',
      () {
        expect(
          DisputeTypeExtension.categories.length,
          greaterThanOrEqualTo(16),
        );
        expect(
          DisputeTypeExtension.categories.contains('Ownership / Title'),
          isTrue,
        );
        expect(DisputeTypeExtension.categories.contains('Boundary'), isTrue);
        expect(
          DisputeTypeExtension.categories.contains('Partition / Family'),
          isTrue,
        );
        expect(
          DisputeTypeExtension.categories.contains('Inheritance / Succession'),
          isTrue,
        );
        expect(DisputeTypeExtension.categories.contains('Court Case'), isTrue);
      },
    );

    test(
      '2. DisputeVerificationStatus supports standard marketplace lifecycle statuses',
      () {
        expect(
          DisputeVerificationStatus.values.length,
          greaterThanOrEqualTo(10),
        );
        expect(DisputeVerificationStatus.draft.displayName, contains('Draft'));
        expect(
          DisputeVerificationStatus.submitted.displayName,
          contains('Submitted'),
        );
        expect(
          DisputeVerificationStatus.underReview.displayName,
          contains('Under'),
        );
        expect(
          DisputeVerificationStatus.publishedListed.displayName,
          contains('Published'),
        );
        expect(
          DisputeVerificationStatus.resolved.displayName,
          contains('Resolved'),
        );
        expect(
          DisputeVerificationStatus.withdrawn.displayName,
          contains('Withdrawn'),
        );
      },
    );

    test(
      '3. Create Disputed Property sets Firebase UID as creator_id and status to submitted',
      () async {
        const dispute = PropertyDisputeEntity(
          id: 'disp_test_501',
          propertyId: 'prop_501',
          title: 'Residential Plot in Tilakwadi with Title Defect',
          propertyType: 'Residential Plot',
          locality: 'Tilakwadi',
          surveyCtsNumber: 'CTS 9912',
          disputeCategory: 'Ownership / Title',
          factualSummary:
              'Conflicting partition claims between co-heirs registered on 2026-01-15.',
          claimingPartyRole: 'Owner / Claimant',
          currentStage: 'Reported / Notice Issued',
          verificationStatus: DisputeVerificationStatus.submitted,
        );

        final result = await repository.createDispute(
          dispute,
          authenticatedUserId: 'firebase_user_abc123',
        );
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Failed to create dispute'), (created) {
          expect(created.creatorId, equals('firebase_user_abc123'));
          expect(created.reportedBy, equals('firebase_user_abc123'));
          expect(
            created.verificationStatus,
            equals(DisputeVerificationStatus.submitted),
          );
          expect(
            created.isFounderConfirmed,
            isFalse,
          ); // User reports are never auto-confirmed
        });
      },
    );

    test(
      '4. DisputeDocumentEntity cleanly serializes to and from Supabase mapping',
      () {
        final doc = DisputeDocumentEntity(
          id: 'doc_123',
          disputeId: 'disp_501',
          documentType: 'Sale Deed',
          documentDate: DateTime(2024, 5, 10),
          issuingAuthority: 'Sub-Registrar Belagavi',
          referenceNumber: 'DOC-9021',
          storagePath: 'https://storage.belagavi.com/disputes/doc_123.pdf',
          publicRedactedUrl:
              'https://storage.belagavi.com/disputes/doc_123_redacted.pdf',
          visibility: 'public_redacted',
          isRedacted: true,
          badgeLabel: 'DOCUMENT ATTACHED',
          createdAt: DateTime(2026, 1, 1),
        );

        final map = doc.toSupabaseMap();
        expect(map['document_type'], equals('Sale Deed'));
        expect(map['is_redacted'], isTrue);
        expect(map['badge_label'], equals('DOCUMENT ATTACHED'));

        final restored = DisputeDocumentEntity.fromSupabaseMap(map);
        expect(restored.documentType, equals('Sale Deed'));
        expect(restored.referenceNumber, equals('DOC-9021'));
        expect(restored.isRedacted, isTrue);
      },
    );

    test(
      '5. DisputeResponseEntity cleanly serializes to and from Supabase mapping',
      () {
        final response = DisputeResponseEntity(
          id: 'resp_101',
          disputeId: 'disp_501',
          respondentId: 'resp_user_456',
          respondentName: 'Adv. Suresh Kulkarni',
          respondentRole: 'Advocate for Respondent',
          responseType: 'correction_request',
          statement:
              'The partition suit has already been amicably resolved by compromise decree dated 2025-11-20.',
          supportingDocumentUrls: const [
            'https://storage.belagavi.com/docs/compromise_decree.pdf',
          ],
          status: 'submitted',
          createdAt: DateTime(2026, 2, 1),
        );

        final map = response.toSupabaseMap();
        expect(map['response_type'], equals('correction_request'));
        expect(map['respondent_name'], equals('Adv. Suresh Kulkarni'));

        final restored = DisputeResponseEntity.fromSupabaseMap(map);
        expect(restored.respondentRole, equals('Advocate for Respondent'));
        expect(restored.statement, contains('compromise decree'));
      },
    );

    test(
      '6. Duplicate Candidate Search checks locality and survey/property number',
      () async {
        final result = await repository.checkPossibleDuplicates(
          locality: 'Tilakwadi',
          surveyNumber: 'CTS 9912',
          propertyNumber: '102/A',
        );
        expect(result.isRight(), isTrue);
      },
    );

    test(
      '7. AddDisputeWizardNotifier step validation works deterministically',
      () {
        final notifier = AddDisputeWizardNotifier(repository);

        // Step 0: Empty locality should fail
        notifier.updatePropertyDetails(locality: '');
        expect(notifier.validateStep(0), isFalse);

        // Step 0: Valid locality should pass
        notifier.updatePropertyDetails(locality: 'Tilakwadi');
        expect(notifier.validateStep(0), isTrue);

        // Step 1: Too short factual summary should fail
        notifier.updateDisputeDetails(factualSummary: 'Short');
        expect(notifier.validateStep(1), isFalse);

        // Step 1: Valid factual summary should pass
        notifier.updateDisputeDetails(
          factualSummary:
              'This is a valid factual summary explaining the reported boundary dispute clearly.',
        );
        expect(notifier.validateStep(1), isTrue);
      },
    );

    test(
      '8. AddDisputeWizardNotifier submitDispute blocks unauthenticated submission',
      () async {
        final notifier = AddDisputeWizardNotifier(repository);
        notifier.updatePropertyDetails(locality: 'Shahapur');
        notifier.updateDisputeDetails(
          factualSummary: 'Factual boundary dispute statement for review.',
        );

        final created = await notifier.submitDispute('');
        expect(created, isNull);
      },
    );

    test(
      '9. MyDisputedPropertiesNotifier handles status tabs and prepend update',
      () async {
        final notifier = MyDisputedPropertiesNotifier(repository);
        expect(notifier.state.activeTab, equals('ALL'));

        const testDispute = PropertyDisputeEntity(
          id: 'disp_my_1',
          propertyId: 'prop_my_1',
          creatorId: 'user_123',
          title: 'Dispute 1',
          locality: 'Camp',
          verificationStatus: DisputeVerificationStatus.submitted,
          disputeCategory: 'Ownership / Title',
          factualSummary: 'Test dispute description',
        );

        notifier.prependDispute(testDispute);
        expect(notifier.state.disputes.length, equals(1));
        expect(notifier.state.disputes.first.id, equals('disp_my_1'));
      },
    );

    test(
      '10. DisputedPropertiesNotifier supports search, locality, and category filtering',
      () async {
        final notifier = DisputedPropertiesNotifier(repository);

        notifier.setSearchQuery('Tilakwadi');
        expect(notifier.state.searchQuery, equals('Tilakwadi'));

        notifier.setLocality('Camp');
        expect(notifier.state.selectedLocality, equals('Camp'));

        notifier.setCategory('Boundary');
        expect(notifier.state.selectedCategory, equals('Boundary'));
        expect(
          notifier.state.selectedType,
          equals(DisputeType.boundaryDispute),
        );
      },
    );
  });
}
