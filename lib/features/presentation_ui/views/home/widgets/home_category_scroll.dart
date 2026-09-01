import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

/// Property Category Grid — Master Design Blueprint
/// 4-column icon grid: Residential, Plots, Commercial, Land (Theme-aware card surface, gold accents)
class HomeCategoryScroll extends StatelessWidget {
  const HomeCategoryScroll({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      icon: Icons.home_rounded,
      title: 'Residential',
      subtitle: 'Houses, Flats, Villas',
      categoryKey: 'residential',
    ),
    _CategoryItem(
      icon: Icons.landscape_rounded,
      title: 'Plots',
      subtitle: 'Residential &\nCommercial Plots',
      categoryKey: 'plotLand',
    ),
    _CategoryItem(
      icon: Icons.storefront_rounded,
      title: 'Commercial',
      subtitle: 'Shops, Offices,\nShowrooms',
      categoryKey: 'commercial',
    ),
    _CategoryItem(
      icon: Icons.park_rounded,
      title: 'Raw Land',
      subtitle: 'Agricultural &\nRaw Land',
      categoryKey: 'land',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Property Categories',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/search'),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Category Cards
          SizedBox(
            height: 155,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () => context.push('/category/${cat.categoryKey}'),
                  child: Container(
                    width: 135,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderCol,
                        width: 1.2,
                      ),
                      boxShadow: AppDesignSystem.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular Icon Container with Gold Border
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0A0D11) : const Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppDesignSystem.brandGold,
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              cat.icon,
                              size: 22,
                              color: AppDesignSystem.brandGold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          cat.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textP,
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Subtitle
                        Text(
                          cat.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 9.5,
                            color: AppDesignSystem.textS(context),
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),

                        // Badge / CTA
                        const Text(
                          'Explore Properties',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String categoryKey;

  const _CategoryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.categoryKey,
  });
}
