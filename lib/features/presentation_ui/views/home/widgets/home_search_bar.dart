import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

/// Universal Search Bar for Home Screen — Production Dual-Theme Architecture
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// Placeholder: Search locality, project, plot, office, survey no...
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final borderCol = AppDesignSystem.borderCol(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);
    final searchBg = isDark ? const Color(0xFF131B2A) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Search input field
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderCol, width: 1.1),
                  boxShadow: isDark ? null : AppDesignSystem.softShadow,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark ? AppDesignSystem.brandGold : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search locality, project, plot, office, survey no...',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          color: textS,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Filter Button
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol, width: 1.1),
                boxShadow: isDark ? null : AppDesignSystem.softShadow,
              ),
              child: const Center(
                child: Icon(
                  Icons.tune_rounded,
                  color: AppDesignSystem.brandGold,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
