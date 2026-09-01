import 'package:flutter/material.dart';
import 'package:belagavi_property/core/config/app_brand_config.dart';
import '../../../theme/app_design_system.dart';
import '../../investment/invest_with_us_view.dart';

/// Invest Banner — Production Dual-Theme Architecture
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// Elements: "Invest with Belgaum Property LLP", Subtext, Gold "Explore Investments →" CTA, Building Graphic
class InvestWithUsHomeCard extends StatelessWidget {
  const InvestWithUsHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppDesignSystem.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => InvestWithUsView.show(context),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2A364F) : const Color(0xFF334155),
              width: 1.1,
            ),
            boxShadow: AppDesignSystem.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Subtle background geometric art / building illustration on the right
              const Positioned(
                right: -10,
                top: -10,
                bottom: -10,
                width: 130,
                child: const Opacity(
                  opacity: 0.15,
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 140,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left Content
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Subhead
                          const Text(
                            'Invest with',
                            style: const TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppDesignSystem.brandGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Brand Title
                          const Text(
                            AppBrandConfig.brandLegalName,
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Description Subtitle
                          const Text(
                            'Curated project-based opportunities for smart & secure real-estate investment.',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 11,
                              color: Color(0xFFCBD5E1),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // CTA Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppDesignSystem.brandGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore Investments',
                                  style: TextStyle(
                                    fontFamily: AppDesignSystem.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: Color(0xFF0F172A),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Building Icon / Graphic Shield
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppDesignSystem.brandGold.withValues(
                              alpha: 0.4,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 48,
                              color: AppDesignSystem.brandGold.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: const Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: AppDesignSystem.brandGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
