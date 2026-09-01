import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

class PremiumBuildersView extends StatelessWidget {
  const PremiumBuildersView({super.key});

  static const List<Map<String, String>> _builders = [
    {
      'name': 'Suvarna Developers',
      'experience': '18+ Years Experience',
      'projects': '24 Delivered Projects',
      'rating': '4.9 ★',
      'location': 'Tilakwadi, Belagavi',
      'badge': 'VERIFIED BUILDER',
    },
    {
      'name': 'Renaissance Realty',
      'experience': '12+ Years Experience',
      'projects': '15 Delivered Projects',
      'rating': '4.8 ★',
      'location': 'Camp, Belagavi',
      'badge': 'PREMIUM PARTNER',
    },
    {
      'name': 'Kamat Construction',
      'experience': '25+ Years Experience',
      'projects': '40 Delivered Projects',
      'rating': '4.9 ★',
      'location': 'Hindwadi, Belagavi',
      'badge': 'TOP RATED',
    },
    {
      'name': 'Belgaum Infrastructure Ltd',
      'experience': '15+ Years Experience',
      'projects': '19 Delivered Projects',
      'rating': '4.7 ★',
      'location': 'Khanapur Road, Belagavi',
      'badge': 'RERA APPROVED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Premium Builders',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            color: AppDesignSystem.primaryBlue,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _builders.length,
          itemBuilder: (context, index) {
            final builder = _builders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppDesignSystem.cardShadow,
                border: Border.all(color: AppDesignSystem.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppDesignSystem.primaryBlue.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          builder['badge']!,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppDesignSystem.primaryBlue,
                          ),
                        ),
                      ),
                      Text(
                        builder['rating']!,
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontWeight: FontWeight.w700,
                          color: AppDesignSystem.brandGold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppDesignSystem.primaryBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.business_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              builder['name']!,
                              style: const TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              builder['location']!,
                              style: const TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 12,
                                color: AppDesignSystem.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        builder['experience']!,
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          color: AppDesignSystem.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        builder['projects']!,
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          color: AppDesignSystem.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
