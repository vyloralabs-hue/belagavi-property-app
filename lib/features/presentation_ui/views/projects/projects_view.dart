import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

class PremiumProjectsView extends StatelessWidget {
  const PremiumProjectsView({super.key});

  static const List<Map<String, String>> _projects = [
    {
      'title': 'Suvarna Heights - Luxury Apartments',
      'developer': 'Suvarna Developers',
      'price': '₹68,00,000 Onwards',
      'location': 'Tilakwadi 1st Railway Gate, Belagavi',
      'status': 'Under Construction (Possession Dec 2026)',
      'rera': 'PRM/KA/RERA/1259/309/PR/241026/006120',
      'type': '2 & 3 BHK Premium Flats',
    },
    {
      'title': 'Renaissance Grandeur Villa Enclave',
      'developer': 'Renaissance Realty',
      'price': '₹1,45,00,000 Onwards',
      'location': 'Hindwadi Near Club Road, Belagavi',
      'status': 'Ready to Move',
      'rera': 'PRM/KA/RERA/1259/309/PR/241115/007421',
      'type': '4 BHK Independent Villas',
    },
    {
      'title': 'Kamat Commercial Hub',
      'developer': 'Kamat Construction',
      'price': '₹42,00,000 Onwards',
      'location': 'Camp Main Road, Belagavi',
      'status': 'New Launch',
      'rera': 'PRM/KA/RERA/1259/309/PR/250102/008101',
      'type': 'Commercial Retail & Office Suites',
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
          'Premium Projects',
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
          itemCount: _projects.length,
          itemBuilder: (context, index) {
            final project = _projects[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppDesignSystem.cardShadow,
                border: Border.all(color: AppDesignSystem.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppDesignSystem.primaryBlue.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.apartment_rounded,
                            size: 48,
                            color: AppDesignSystem.primaryBlue,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppDesignSystem.brandGold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'RERA APPROVED PROJECT',
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['title']!,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppDesignSystem.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By ${project['developer']}',
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            color: AppDesignSystem.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          project['price']!,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppDesignSystem.brandGold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppDesignSystem.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project['location']!,
                                style: const TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 12,
                                  color: AppDesignSystem.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: AppDesignSystem.accentEmerald,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project['type']!,
                                style: const TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppDesignSystem.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Site Visit Inquiry Sent to Builder',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppDesignSystem.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Book Site Visit',
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
