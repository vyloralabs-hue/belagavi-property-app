import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/routing/app_routes.dart';
import '../../../theme/app_design_system.dart';

/// Property Protection Section — Production Dual-Theme Architecture
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// Elements: Disputed Property & Property Legal Notices Cards
class HomePropertyProtectionSection extends StatelessWidget {
  const HomePropertyProtectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);
    final cardBg = isDark ? const Color(0xFF131B2A) : Colors.white;
    final borderCol = AppDesignSystem.borderCol(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Shield Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: AppDesignSystem.brandGold,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Property Protection',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.disputedProperties),
                child: const Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppDesignSystem.brandGold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppDesignSystem.brandGold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Two Side-by-Side Cards (Responsive on Mobile & Tablet)
          Row(
            children: [
              // Card 1: Disputed Property
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.disputedProperties),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol, width: 1.1),
                      boxShadow: isDark ? null : AppDesignSystem.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A2436)
                                    : const Color(
                                        0xFFFEF3C7,
                                      ).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppDesignSystem.brandGold.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.verified_user_outlined,
                                  size: 20,
                                  color: AppDesignSystem.brandGold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppDesignSystem.brandGold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Disputed Property',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textP,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Check litigation & dispute information',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 10.5,
                            color: textS,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Card 2: Property Legal Notices
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.legalNotices),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol, width: 1.1),
                      boxShadow: isDark ? null : AppDesignSystem.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A2436)
                                    : const Color(
                                        0xFFFEF3C7,
                                      ).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppDesignSystem.brandGold.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.gavel_rounded,
                                  size: 20,
                                  color: AppDesignSystem.brandGold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppDesignSystem.brandGold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Property Legal Notices',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textP,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Verify legal notices & ensure safe transactions',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 10.5,
                            color: textS,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
