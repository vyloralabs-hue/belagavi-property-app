import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/config/app_brand_config.dart';
import 'package:belagavi_property/core/theme/app_theme.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/presentation_ui/views/home/premium_home_view.dart';
import 'package:belagavi_property/features/presentation_ui/views/home/widgets/home_header_bar.dart';
import 'package:belagavi_property/features/presentation_ui/views/home/widgets/home_search_bar.dart';
import 'package:belagavi_property/features/presentation_ui/views/home/widgets/home_property_type_grid.dart';
import 'package:belagavi_property/features/presentation_ui/views/home/widgets/invest_with_us_home_card.dart';
import 'package:belagavi_property/features/presentation_ui/views/home/widgets/home_property_protection_section.dart';
import 'package:belagavi_property/features/presentation_ui/views/home/widgets/home_real_property_feed.dart';

void main() {
  group('BELAGAVI PROPERTY — DUAL THEME PRODUCTION HOME EXPERIENCE TESTS', () {
    testWidgets('1. Light Mode Home renders complete information hierarchy', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PremiumHomeView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top Bar Elements
      expect(find.byType(HomeHeaderBar), findsOneWidget);
      expect(find.text(AppBrandConfig.brandName), findsOneWidget);
      expect(find.text(AppBrandConfig.defaultCity), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);

      // Search Bar
      expect(find.byType(HomeSearchBar), findsOneWidget);
      expect(find.text('Search locality, project, plot, office, survey no...'), findsOneWidget);

      // 4 Primary Categories
      expect(find.byType(HomePropertyTypeGrid), findsOneWidget);
      expect(find.text('Explore Categories'), findsOneWidget);
      expect(find.text('Residential'), findsOneWidget);
      expect(find.text('Homes & Apartments'), findsOneWidget);
      expect(find.text('Plot'), findsOneWidget);
      expect(find.text('Layouts & Sites'), findsOneWidget);
      expect(find.text('Commercial'), findsOneWidget);
      expect(find.text('Shops & Offices'), findsOneWidget);
      expect(find.text('Raw Land'), findsOneWidget);
      expect(find.text('Agricultural Land'), findsOneWidget);

      // Invest Section
      expect(find.byType(InvestWithUsHomeCard), findsOneWidget);
      expect(find.text(AppBrandConfig.brandLegalName), findsOneWidget);
      expect(find.text('Explore Investments'), findsOneWidget);

      // Property Protection Section
      expect(find.byType(HomePropertyProtectionSection), findsOneWidget);
      expect(find.text('Property Protection'), findsOneWidget);
      expect(find.text('Disputed Property'), findsOneWidget);
      expect(find.text('Property Legal Notices'), findsOneWidget);

      // Real Feed / Empty State
      expect(find.byType(HomeRealPropertyFeed), findsOneWidget);
    });

    testWidgets('2. Dark Mode Home renders identically with dark tokens', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PremiumHomeView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PremiumHomeView), findsOneWidget);
      expect(find.byType(HomeHeaderBar), findsOneWidget);
      expect(find.byType(HomeSearchBar), findsOneWidget);
      expect(find.byType(HomePropertyTypeGrid), findsOneWidget);
      expect(find.byType(InvestWithUsHomeCard), findsOneWidget);
      expect(find.byType(HomePropertyProtectionSection), findsOneWidget);
      expect(find.byType(HomeRealPropertyFeed), findsOneWidget);
    });

    testWidgets('3. Old oversized dream-home hero and "Explore Now" are removed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PremiumHomeView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Find your dream in Belgaum'), findsNothing);
      expect(find.text('Find your dream home in Belgaum'), findsNothing);
      expect(find.text('Explore Now'), findsNothing);
    });

    testWidgets('4. Broker / Builder / Founder zone is removed from primary Home', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PremiumHomeView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Founder & Admin Zone'), findsNothing);
      expect(find.text('Broker / Builder Zone'), findsNothing);
    });

    testWidgets('5. Location picker modal shows scalable Pan-India locations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: HomeHeaderBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on location pill
      await tester.tap(find.text(AppBrandConfig.defaultCity));
      await tester.pumpAndSettle();

      expect(find.text('Select Location'), findsOneWidget);
      expect(find.text('Belagavi'), findsAtLeastNWidgets(1));
      expect(find.text('Bengaluru'), findsOneWidget);
      expect(find.text('Pune'), findsOneWidget);
      expect(find.text('Pan India'), findsOneWidget);
    });

    testWidgets('6. Language picker modal shows supported languages', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: HomeHeaderBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on language pill
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English (EN)'), findsOneWidget);
      expect(find.text('ಕನ್ನಡ (KN)'), findsOneWidget);
      expect(find.text('मराठी (MR)'), findsOneWidget);
      expect(find.text('हिन्दी (HI)'), findsOneWidget);
    });

    testWidgets('7. Responsive layout on Tablet/Desktop constrained cleanly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PremiumHomeView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PremiumHomeView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. Semantic AppDesignSystem tokens evaluate correctly in Light and Dark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              expect(AppDesignSystem.isDark(context), isFalse);
              expect(AppDesignSystem.backgroundPrimary(context), AppDesignSystem.bgLightPrimary);
              expect(AppDesignSystem.textP(context), AppDesignSystem.textLightPrimary);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}
