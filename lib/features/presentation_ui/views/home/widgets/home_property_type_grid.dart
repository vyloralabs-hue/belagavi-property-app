import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

/// 4 Primary Property Types Discovery Grid — Production Dual-Theme Architecture
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// Types: Residential (Homes & Apartments), Plot (Layouts & Sites),
/// Commercial (Shops & Offices), Raw Land (Agricultural Land)
class HomePropertyTypeGrid extends StatelessWidget {
  const HomePropertyTypeGrid({super.key});

  static const List<_CategoryItem> _items = [
    _CategoryItem(
      title: 'Residential',
      subtitle: 'Homes & Apartments',
      icon: Icons.apartment_rounded,
      categoryKey: 'residential',
    ),
    _CategoryItem(
      title: 'Plot',
      subtitle: 'Layouts & Sites',
      icon: Icons.grid_goldenratio_rounded,
      categoryKey: 'plotLand',
    ),
    _CategoryItem(
      title: 'Commercial',
      subtitle: 'Shops & Offices',
      icon: Icons.domain_rounded,
      categoryKey: 'commercial',
    ),
    _CategoryItem(
      title: 'Raw Land',
      subtitle: 'Agricultural Land',
      icon: Icons.terrain_rounded,
      categoryKey: 'land',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final isDark = AppDesignSystem.isDark(context);
    final cardBg = isDark ? const Color(0xFF131B2A) : Colors.white;
    final borderCol = AppDesignSystem.borderCol(context);
    final textS = AppDesignSystem.textS(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Categories',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textP,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/search'),
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

          // 4 Category Cards in a responsive Row or Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              return Row(
                children: _items.map((item) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => context.push('/category/${item.categoryKey}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderCol, width: 1.1),
                            boxShadow: isDark ? null : AppDesignSystem.softShadow,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon container
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1A2436) : const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppDesignSystem.brandGold.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    size: 22,
                                    color: AppDesignSystem.brandGold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Title
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: isNarrow ? 11 : 12,
                                  fontWeight: FontWeight.w700,
                                  color: textP,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),

                              // Subtitle
                              Text(
                                item.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: isNarrow ? 8.5 : 9.5,
                                  color: textS,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String categoryKey;

  const _CategoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.categoryKey,
  });
}
