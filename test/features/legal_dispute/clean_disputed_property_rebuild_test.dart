import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belagavi_property/core/theme/app_theme.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/disputed_properties_list_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/add_disputed_property_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/disputed_property_detail_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/views/my_disputed_properties_view.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/widgets/dispute_property_image.dart';
import 'package:belagavi_property/features/legal_dispute/presentation/providers/dispute_providers.dart';

class _FakeDisputedNotifier extends StateNotifier<DisputedPropertiesState>
    implements DisputedPropertiesNotifier {
  _FakeDisputedNotifier([List<PropertyDisputeEntity> items = const []])
      : super(DisputedPropertiesState(isLoading: false, disputes: items));

  @override
  Future<void> loadDisputes() async {}

  @override
  Future<void> loadMore() async {}

  @override
  void setDisputeType(DisputeType? type) {}

  @override
  void setCategory(String? category) {}

  @override
  void setLocality(String locality) {}

  @override
  void setSearchQuery(String query) {}

  @override
  void addDisputeLocally(PropertyDisputeEntity dispute) {}
}

void main() {
  group('BELAGAVI PROPERTY — CLEAN DISPUTED PROPERTY MODULE REBUILD TESTS', () {
    testWidgets('1. All Categories & marketplace category strip REMOVED from Disputed Property screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            disputedPropertiesNotifierProvider.overrideWith((ref) => _FakeDisputedNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DisputedPropertiesListView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure "All Categories" is removed
      expect(find.text('All Categories'), findsNothing);
      expect(find.text('Residential'), findsNothing);
      expect(find.text('Commercial'), findsNothing);
      expect(find.text('Agricultural'), findsNothing);
    });

    testWidgets('2. Header, supporting text, and primary/secondary CTAs render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            disputedPropertiesNotifierProvider.overrideWith((ref) => _FakeDisputedNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DisputedPropertiesListView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reported Property Disputes'), findsAtLeastNWidgets(1));
      expect(
        find.text('Browse property records that have a reported dispute associated with them.'),
        findsOneWidget,
      );
      expect(find.text('List Disputed Property'), findsAtLeastNWidgets(1));
      expect(find.text('My Disputed Properties'), findsOneWidget);
    });

    testWidgets('3. Clean empty state rendered when zero publishable dispute records exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            disputedPropertiesNotifierProvider.overrideWith((ref) => _FakeDisputedNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DisputedPropertiesListView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No disputed property records found.'), findsOneWidget);
      expect(find.text('List Disputed Property'), findsAtLeastNWidgets(1));
    });

    testWidgets('4. DisputePropertyImage renders persistent REPORTED DISPUTE warning overlay badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DisputePropertyImage(
              imageUrl: null,
              width: 200,
              height: 150,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DisputePropertyImage), findsOneWidget);
      expect(find.text('REPORTED DISPUTE'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('5. Add Disputed Property Wizard asks for Property Type on Step 1', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddDisputedPropertyView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('List Disputed Property'), findsOneWidget);
      expect(find.text('Step 1: Property Identity'), findsOneWidget);
      expect(find.text('What type of property is involved in this reported dispute?'), findsOneWidget);
      expect(find.text('Property Type *'), findsOneWidget);
      expect(find.text('Locality / Area *'), findsOneWidget);
    });

    testWidgets('6. Dynamic property fields adapt when Apartment / Flat is selected', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddDisputedPropertyView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open property type dropdown
      await tester.tap(find.text('House'));
      await tester.pumpAndSettle();

      // Select Apartment / Flat
      await tester.tap(find.text('Apartment / Flat').last);
      await tester.pumpAndSettle();

      expect(find.text('Flat / Unit Number'), findsOneWidget);
      expect(find.text('Building / Project Name'), findsOneWidget);
      expect(find.text('Floor'), findsOneWidget);
    });

    testWidgets('7. Dynamic property fields adapt when Open Land / Agricultural Land is selected', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddDisputedPropertyView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open property type dropdown
      await tester.tap(find.text('House'));
      await tester.pumpAndSettle();

      // Select Agricultural Land
      await tester.tap(find.text('Agricultural Land').last);
      await tester.pumpAndSettle();

      expect(find.text('Survey / CTS Number *'), findsOneWidget);
      expect(find.text('Plot / Hissa Number'), findsOneWidget);
      expect(find.text('Village / Taluk'), findsOneWidget);
    });

    testWidgets('8. DisputedPropertyDetailView displays dispute hero and legal disclaimer', (tester) async {
      final sample = PropertyDisputeEntity(
        id: 'disp_test_01',
        propertyId: 'prop_01',
        title: 'Title Dispute over Tilakwadi Bungalow',
        category: 'House',
        propertyType: 'House',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        surveyCtsNumber: 'CTS 1024',
        relationship: 'Claimant',
        disputeType: DisputeType.ownershipDispute,
        description: 'Litigation pending before Senior Civil Judge.',
        verificationStatus: DisputeVerificationStatus.publishedListed,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: DisputedPropertyDetailView(
              disputeId: 'disp_test_01',
              initialDispute: sample,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DisputedPropertyDetailView), findsOneWidget);
      expect(find.byType(DisputePropertyImage), findsOneWidget);
      expect(find.text('REPORTED DISPUTE'), findsOneWidget);
      expect(find.text('Title Dispute over Tilakwadi Bungalow'), findsOneWidget);
      expect(find.text('Tilakwadi, Belagavi'), findsOneWidget);
      expect(find.text('CTS 1024'), findsOneWidget);
      expect(find.textContaining('Information on this page is submitted by users or publishers'), findsOneWidget);
    });

    testWidgets('9. MyDisputedPropertiesView displays owner records with dispute overlay', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MyDisputedPropertiesView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MyDisputedPropertiesView), findsOneWidget);
      expect(find.text('My Disputed Properties'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('Under Review'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
    });
  });
}
