import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/legal_notice_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/legal_notice_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/repositories/legal_notice_repository.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/providers/legal_notice_providers.dart';

void main() {
  late LegalNoticeRemoteDataSource remoteDataSource;
  late LegalNoticeRepository repository;

  setUp(() {
    final supabase = SupabaseService();
    remoteDataSource = LegalNoticeRemoteDataSourceImpl(supabase);
    repository = LegalNoticeRepositoryImpl(remoteDataSource);
  });

  group('Phase 3 â€” Legal Notice & Transaction Repository Tests', () {
    test(
      '1. Create Legal Notice / Transaction record without documents & underReview status',
      () async {
        const notice = TransactionLegalNoticeEntity(
          id: 'not_test_301',
          propertyId: 'prop_camp_plot_301',
          title: 'Agreement to Sell 30x50 Plot in Camp',
          category: 'Plots & Layouts',
          propertyType: 'Residential Plot',
          city: 'Belagavi',
          locality: 'Camp',
          surveyCtsNumber: 'CTS No. 892/1',
          buyerName: 'Mr. Ramesh Joshi',
          buyerAddress: 'Camp, Belagavi',
          buyerAdvocate: 'Adv. Suresh Kulkarni',
          sellerName: 'Mr. Anand Kulkarni',
          sellerAddress: 'Tilakwadi, Belagavi',
          contactName: 'Adv. Suresh Kulkarni',
          contactPhone: '+91 98801 12345',
          contactEmail: 'suresh.law@example.com',
          contactRole: 'Legal Advocate',
          transactionType: 'Purchase',
          agreedValue: 'â‚¹ 75 Lakhs',
          agreementDate: '20/08/2026',
          executionDate: '30/10/2026',
          transactionStatus: 'Agreement Executed / Token Advance Paid',
          transactionDescription:
              '20% token consideration paid under registered agreement to sell.',
          noticeType: LegalNoticeType.purchaseLegalNotice,
          issuingAuthority: 'Sub-Registrar Office Belagavi',
          referenceNumber: 'BGM/SR/NOTICE/2026/301',
          noticeDate: '21/08/2026',
          publicNoticeSummary:
              'Public caveat inviting objections within 15 days.',
          dueDiligenceNotes:
              'Form 15 Encumbrance Certificate obtained. Title chain clear.',
          photoUrls: const ['https://images.unsplash.com/photo-plot-301'],
          documentUrls: const [], // Saved without documents
          isDocumentPrivate: true,
          canAddDocumentsLater: true,
        );

        final result = await repository.createLegalNotice(
          notice,
          authenticatedUserId: 'usr_buyer_301',
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected creation success'), (created) {
          expect(created.id, equals('not_test_301'));
          expect(
            created.verificationStatus,
            equals(LegalNoticeStatus.underReview),
          );
          expect(created.documentUrls, isEmpty);
          expect(created.isDocumentPrivate, isTrue);
          expect(created.canAddDocumentsLater, isTrue);
        });
      },
    );

    test(
      '2. Attach documents later updates existing record successfully',
      () async {
        final attachResult = await repository.attachDocuments(
          'not_101',
          newDocuments: const [
            'https://storage.belagaviproperty.com/legal/additional_tax_receipt.pdf',
            'https://storage.belagaviproperty.com/legal/updated_ec_form15.pdf',
          ],
          authenticatedUserId: 'usr_buyer_joshi',
        );

        expect(attachResult.isRight(), isTrue);
        attachResult.fold((_) => fail('Expected attach success'), (updated) {
          expect(
            updated.documentUrls.any(
              (d) => d.contains('updated_ec_form15.pdf'),
            ),
            isTrue,
          );
          expect(
            updated.documentUrls.any(
              (d) => d.contains('additional_tax_receipt.pdf'),
            ),
            isTrue,
          );
        });
      },
    );

    test(
      '3. Public fetch masks private contact info and strips private legal documents',
      () async {
        final result = await repository.getLegalNoticeById(
          'not_101',
          requestingUserId: 'usr_anonymous_public',
          userRole: UserRole.user,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected notice to exist'), (notice) {
          expect(notice, isNotNull);
          // Public check: phone masked
          expect(notice!.contactPhone, contains('•••••'));
          // Public check: private documents stripped
          expect(notice.documentUrls, isEmpty);
        });
      },
    );

    test(
      '4. Admin / Creator fetch receives unmasked private contact & legal documents',
      () async {
        final result = await repository.getLegalNoticeById(
          'not_101',
          requestingUserId: 'usr_admin_1',
          userRole: UserRole.admin,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected notice to exist'), (notice) {
          expect(notice, isNotNull);
          // Admin sees unmasked phone and private documents
          expect(notice!.contactPhone, equals('+91 94481 44556'));
          expect(notice.documentUrls.isNotEmpty, isTrue);
        });
      },
    );

    test(
      '5. Filter notices by LegalNoticeType, TransactionType, and Locality',
      () async {
        // Filter by LegalNoticeType.purchaseLegalNotice
        final purchaseNotices = await repository.getLegalNotices(
          type: LegalNoticeType.purchaseLegalNotice,
        );
        purchaseNotices.fold((_) => fail('Failed to fetch purchase notices'), (
          list,
        ) {
          expect(
            list.every(
              (n) => n.noticeType == LegalNoticeType.purchaseLegalNotice,
            ),
            isTrue,
          );
        });

        // Filter by TransactionType 'Sale'
        final saleNotices = await repository.getLegalNotices(
          transactionType: 'Sale',
        );
        saleNotices.fold((_) => fail('Failed to fetch sale notices'), (list) {
          expect(list.any((n) => n.transactionType == 'Sale'), isTrue);
        });

        // Filter by Locality 'Tilakwadi'
        final tilakNotices = await repository.getLegalNotices(
          locality: 'Tilakwadi',
        );
        tilakNotices.fold((_) => fail('Failed to fetch Tilakwadi notices'), (
          list,
        ) {
          expect(list.any((n) => n.locality.contains('Tilakwadi')), isTrue);
        });
      },
    );
  });

  group('Phase 3 â€” LegalNoticeFormNotifier Wizard & Form Tests', () {
    test('6. Form state calculates completeness score accurately', () {
      final formNotifier = LegalNoticeFormNotifier(repository);
      formNotifier.initForNewRecord();

      // Initial score with default issuing authority
      expect(formNotifier.calculateCompletionScore(), equals(15));

      // Add Property title & locality (+20)
      formNotifier.updatePropertyInfo(
        title: 'Commercial Complex Khanapur Road Title Verification',
        locality: 'Khanapur Road',
      );
      expect(formNotifier.calculateCompletionScore(), equals(35));

      // Add Buyer or Seller name (+20)
      formNotifier.updateBuyerInfo(buyerName: 'Vijay Construction LLP');
      expect(formNotifier.calculateCompletionScore(), equals(55));

      // Add Contact Phone (+20)
      formNotifier.updateContactInfo(contactPhone: '+91 94481 00223');
      expect(formNotifier.calculateCompletionScore(), equals(75));

      // Add Transaction details (+15)
      formNotifier.updateTransactionInfo(
        transactionType: 'Purchase',
        agreedValue: '₹ 2.4 Crore',
      );
      expect(formNotifier.calculateCompletionScore(), equals(90));

      // Add Photo (+10)
      formNotifier.addPhoto('https://images.unsplash.com/commercial-site');
      expect(formNotifier.calculateCompletionScore(), equals(100));
    });

    test(
      '7. Form rejects submission when mandatory fields are missing',
      () async {
        final formNotifier = LegalNoticeFormNotifier(repository);
        formNotifier.initForNewRecord();

        // Submit without title, locality, party name or phone
        final success = await formNotifier.submitRecord('usr_test_1');
        expect(success, isFalse);
        expect(
          formNotifier.getMissingFields().contains('Property Title'),
          isTrue,
        );
        expect(
          formNotifier.getMissingFields().contains('Locality / Area'),
          isTrue,
        );
        expect(
          formNotifier.getMissingFields().contains('Authorized Contact Phone'),
          isTrue,
        );
      },
    );

    test(
      '8. Full end-to-end form completion and submission without documents',
      () async {
        final formNotifier = LegalNoticeFormNotifier(repository);
        formNotifier.initForNewRecord();

        formNotifier.updatePropertyInfo(
          title: 'Farm Land 5 Acres in Sambra Title Search Notice',
          category: 'Raw Land',
          propertyType: 'Agricultural Land',
          city: 'Belagavi',
          locality: 'Sambra',
          surveyCtsNumber: 'Sy No. 112/1B',
        );
        formNotifier.updateBuyerInfo(
          buyerName: 'Prakash Patil',
          buyerAddress: 'Sambra, Belagavi',
        );
        formNotifier.updateSellerInfo(
          sellerName: 'Basavaraj Desai',
          sellerAddress: 'Sambra, Belagavi',
        );
        formNotifier.updateContactInfo(
          contactName: 'Adv. M. S. Patil',
          contactPhone: '+91 94481 99887',
          contactEmail: 'patil.sambra@example.com',
          contactRole: 'Legal Advocate',
        );
        formNotifier.updateTransactionInfo(
          transactionType: 'Purchase',
          agreedValue: 'â‚¹ 1.25 Crore',
          agreementDate: '22/08/2026',
          transactionStatus: 'Agreement Executed / Token Advance Paid',
        );
        formNotifier.updateLegalNoticeInfo(
          noticeType: LegalNoticeType.purchaseLegalNotice,
          issuingAuthority: 'Sub-Registrar Belagavi',
          referenceNumber: 'SAMBRA/AGRI/2026/112',
        );

        // Submit without documents
        final success = await formNotifier.submitRecord(
          'usr_patil_sambra',
          saveWithoutDocuments: true,
        );
        expect(success, isTrue);

        // Verify newly created record in repository
        final searchResult = await repository.getLegalNotices(
          query: 'Farm Land 5 Acres in Sambra',
        );
        searchResult.fold(
          (_) => fail('Failed to retrieve newly created notice'),
          (list) {
            expect(
              list.any((n) => n.title.contains('Farm Land 5 Acres in Sambra')),
              isTrue,
            );
            expect(
              list
                  .firstWhere(
                    (n) => n.title.contains('Farm Land 5 Acres in Sambra'),
                  )
                  .documentUrls,
              isEmpty,
            );
          },
        );
      },
    );
  });
}
