import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/my_disputed_properties_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/disputed_property_detail_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/legal_notice_detail_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/legal_notice_hub_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/add_legal_notice_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/add_disputed_property_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/providers/dispute_providers.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/providers/legal_notice_providers.dart';

void main() {
  testWidgets('AddDisputedPropertyView renders edit mode with prefilled fields', (tester) async {
    const sampleDispute = PropertyDisputeEntity(
      id: 'disp-test-edit-101',
      title: 'Disputed Land at Tilakwadi Corner',
      propertyType: 'Plot',
      disputeCategory: 'Ownership / Title',
      locality: 'Tilakwadi',
      city: 'Belagavi',
      state: 'Karnataka',
      verificationStatus: DisputeVerificationStatus.draft,
      creatorId: 'usr_test_1',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddDisputedPropertyView(
            editDispute: sampleDispute,
            editDisputeId: sampleDispute.id,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AddDisputedPropertyView), findsOneWidget);
    expect(find.text('Disputed Land at Tilakwadi Corner'), findsOneWidget);
  });

  testWidgets('AddLegalNoticeView renders edit mode with prefilled fields', (tester) async {
    final sampleNotice = TransactionLegalNoticeEntity(
      id: 'not-test-edit-202',
      propertyId: 'prop_202',
      title: 'Caveat Notice for Commercial Complex',
      category: 'Commercial',
      propertyType: 'Shop',
      city: 'Belagavi',
      locality: 'Camp',
      buyerName: 'Vikram Mehta',
      sellerName: 'Sunil Jadhav',
      contactName: 'Vikram Mehta',
      contactPhone: '+91 98801 11223',
      noticeType: LegalNoticeType.purchaseNotice,
      verificationStatus: LegalNoticeStatus.draft,
      recordedBy: 'usr_test_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddLegalNoticeView(
            editNotice: sampleNotice,
            editNoticeId: sampleNotice.id,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AddLegalNoticeView), findsOneWidget);
  });

  testWidgets('MyDisputedPropertiesView renders action buttons on dispute card', (tester) async {
    const sampleDispute = PropertyDisputeEntity(
      id: 'disp-card-test-303',
      title: 'Sample Disputed Property Card',
      propertyType: 'House',
      disputeCategory: 'Ownership / Title',
      locality: 'Tilakwadi',
      city: 'Belagavi',
      state: 'Karnataka',
      verificationStatus: DisputeVerificationStatus.draft,
      creatorId: 'usr_test_1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myDisputedPropertiesNotifierProvider.overrideWith((ref) {
            final notifier = MyDisputedPropertiesNotifier(ref.watch(disputeRepositoryProvider));
            notifier.prependDispute(sampleDispute);
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: MyDisputedPropertiesView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sample Disputed Property Card'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('DisputedPropertyDetailView renders dispute details and neutral status badge', (tester) async {
    const sampleDispute = PropertyDisputeEntity(
      id: 'disp-detail-test-404',
      title: 'Disputed Commercial Plot in Camp',
      propertyType: 'Commercial',
      disputeCategory: 'Title Dispute',
      locality: 'Camp',
      city: 'Belagavi',
      state: 'Karnataka',
      verificationStatus: DisputeVerificationStatus.publishedListed,
      creatorId: 'usr_test_1',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DisputedPropertyDetailView(
            disputeId: sampleDispute.id,
            initialDispute: sampleDispute,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DisputedPropertyDetailView), findsOneWidget);
    expect(find.text('Disputed Commercial Plot in Camp'), findsOneWidget);
  });

  testWidgets('LegalNoticeDetailView renders notice card and status badge', (tester) async {
    final sampleNotice = TransactionLegalNoticeEntity(
      id: 'not-detail-test-505',
      propertyId: 'prop_505',
      title: 'Public Notice on Tilakwadi Shop',
      category: 'Commercial',
      propertyType: 'Shop',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      buyerName: 'Rohan Patil',
      sellerName: 'Suresh More',
      contactName: 'Adv. Suresh',
      contactPhone: '+91 94481 99999',
      noticeType: LegalNoticeType.purchaseNotice,
      verificationStatus: LegalNoticeStatus.published,
      recordedBy: 'usr_test_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          legalNoticesNotifierProvider.overrideWith((ref) {
            final notifier = LegalNoticesNotifier(ref.watch(legalNoticeRepositoryProvider));
            notifier.state = LegalNoticesState(notices: [sampleNotice], isLoading: false);
            return notifier;
          }),
        ],
        child: MaterialApp(
          home: LegalNoticeDetailView(
            noticeId: sampleNotice.id,
            initialNotice: sampleNotice,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LegalNoticeDetailView), findsOneWidget);
    expect(find.text('Public Notice on Tilakwadi Shop'), findsOneWidget);
  });

  testWidgets('LegalNoticeHubView renders public listing cards, search, and tabs without blank screen', (tester) async {
    final sampleNotice = TransactionLegalNoticeEntity(
      id: 'not-hub-test-606',
      propertyId: 'prop_606',
      title: 'Caveat Notice for Tilakwadi Commercial Complex',
      category: 'Commercial',
      propertyType: 'Shop',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      buyerName: 'Rohan Patil',
      sellerName: 'Suresh More',
      contactName: 'Adv. Suresh',
      contactPhone: '+91 94481 99999',
      noticeType: LegalNoticeType.purchaseNotice,
      verificationStatus: LegalNoticeStatus.published,
      recordedBy: 'usr_test_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          legalNoticesNotifierProvider.overrideWith((ref) {
            final notifier = _MockLegalNoticesNotifier(ref.watch(legalNoticeRepositoryProvider), sampleNotice);
            return notifier;
          }),
        ],
        child: const MaterialApp(
          home: LegalNoticeHubView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LegalNoticeHubView), findsOneWidget);
    expect(find.text('Property Legal Notices'), findsWidgets);
    expect(find.text('Record Property Legal Notice'), findsWidgets);
    expect(find.text('Public Notices'), findsOneWidget);
    expect(find.text('My Notices'), findsOneWidget);
    expect(find.text('Caveat Notice for Tilakwadi Commercial Complex'), findsOneWidget);
    expect(find.text('View Notice →'), findsOneWidget);

    // Switch to My Notices tab
    await tester.tap(find.text('My Notices'));
    await tester.pumpAndSettle();

    // In unauthenticated state, displays Sign In Required
    expect(find.text('Sign In Required'), findsOneWidget);
  });
}

class _MockLegalNoticesNotifier extends LegalNoticesNotifier {
  final TransactionLegalNoticeEntity _sample;

  _MockLegalNoticesNotifier(super.repository, this._sample) {
    state = LegalNoticesState(notices: [_sample], isLoading: false);
  }

  @override
  Future<void> loadNotices() async {
    state = LegalNoticesState(notices: [_sample], isLoading: false);
  }
}
