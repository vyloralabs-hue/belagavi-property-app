import 'package:flutter/material.dart';
import '../../theme/app_design_system.dart';
import 'widgets/home_header_bar.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_property_type_grid.dart';
import 'widgets/invest_with_us_home_card.dart';
import 'widgets/home_property_protection_section.dart';
import 'widgets/home_real_property_feed.dart';

/// Global Premium Responsive Home Screen
/// Unified Production UI Architecture supporting System, Light & Dark Themes
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// Hierarchy:
/// 1. Top Bar (Brand Monogram, Location Pill, Language Pill, Profile)
/// 2. Universal Search (Search input + Filter)
/// 3. 4 Primary Categories (Residential, Plot, Commercial, Raw Land)
/// 4. Invest with Belgaum Property LLP Banner
/// 5. Property Protection (Disputed Property & Property Legal Notices)
/// 6. Real Property Feed / Empty State (Zero Fake Listings)
class PremiumHomeView extends StatelessWidget {
  const PremiumHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundPrimary(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: const SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeaderBar(),
                  HomeSearchBar(),
                  HomePropertyTypeGrid(),
                  InvestWithUsHomeCard(),
                  HomePropertyProtectionSection(),
                  HomeRealPropertyFeed(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
