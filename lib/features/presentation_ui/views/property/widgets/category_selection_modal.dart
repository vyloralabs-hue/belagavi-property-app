import 'package:belagavi_property/core/routing/app_routes.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategorySelectionModal extends StatelessWidget {
  const CategorySelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategorySelectionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final isDark = AppDesignSystem.isDark(context);
    final borderCol = AppDesignSystem.borderCol(context);

    final categories = [
      const _CategoryOption(
        title: 'Housing / Residential',
        subtitle:
            'Apartments, Independent Houses, Villas, Row Houses, Penthouses',
        icon: Icons.home_work_rounded,
        category: PropertyCategory.residential,
        badge: 'Recommended',
      ),
      const _CategoryOption(
        title: 'Plots & Layouts',
        subtitle: 'Residential Plots, Commercial Plots, NA Land, Gated Layouts',
        icon: Icons.landscape_rounded,
        category: PropertyCategory.plotLand,
        badge: 'Popular',
      ),
      const _CategoryOption(
        title: 'Commercial',
        subtitle: 'Shops, Showrooms, Office Spaces, Warehouses, Godowns',
        icon: Icons.business_rounded,
        category: PropertyCategory.commercial,
      ),
      const _CategoryOption(
        title: 'Raw Land',
        subtitle: 'Agricultural Land, Farmland, Non-NA Land, Plantations',
        icon: Icons.terrain_rounded,
        category: PropertyCategory.land,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: AppDesignSystem.brandGold, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Property Category',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textS),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose the category to list your property in Belagavi',
              style: TextStyle(fontSize: 13, color: textS),
            ),
            const SizedBox(height: 20),
            ...categories.map((cat) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    final target =
                        '/add-property?category=${cat.category.name}';
                    if (!AuthSessionStorageHelper.isLoggedIn()) {
                      context.push(
                        '/auth?redirect=${Uri.encodeComponent(target)}',
                      );
                    } else {
                      context.push(target);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B2330)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF131922)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppDesignSystem.brandGold.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Icon(
                            cat.icon,
                            color: AppDesignSystem.brandGold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    cat.title,
                                    style: TextStyle(
                                      fontFamily: AppDesignSystem.fontFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textP,
                                    ),
                                  ),
                                  if (cat.badge != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppDesignSystem.brandGold
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppDesignSystem.brandGold,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        cat.badge!,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppDesignSystem.brandGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.subtitle,
                                style: TextStyle(fontSize: 12, color: textS),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppDesignSystem.brandGold,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Divider(color: borderCol),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.disputedProperties);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.gavel_rounded,
                            size: 16,
                            color: Color(0xFFEF4444),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Disputed Register',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.legalNotices);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.policy_rounded,
                            size: 16,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Legal Due Diligence',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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
      ),
    );
  }
}

class _CategoryOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final PropertyCategory category;
  final String? badge;

  const _CategoryOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    this.badge,
  });
}
