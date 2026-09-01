import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

class HomeBuilderProjects extends StatelessWidget {
  const HomeBuilderProjects({super.key});

  @override
  Widget build(BuildContext context) {
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppDesignSystem.borderRadiusL,
          boxShadow: AppDesignSystem.cardShadow,
          border: Border.all(color: borderCol, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.domain_rounded,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belagavi Builder Projects',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textP,
                        ),
                      ),
                      Text(
                        'RERA-approved township & villa launches',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          color: textS,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDesignSystem.borderRadiusM,
                      ),
                      side: BorderSide(color: borderCol),
                      foregroundColor: textP,
                    ),
                    onPressed: () => context.push('/projects'),
                    child: Text(
                      'View Projects',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: AppDesignSystem.brandGold,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDesignSystem.borderRadiusM,
                      ),
                    ),
                    onPressed: () => context.push('/builders'),
                    child: const Text(
                      'Top Builders',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontWeight: FontWeight.w700,
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
