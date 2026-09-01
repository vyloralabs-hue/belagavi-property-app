import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

class HomeBusinessZone extends StatelessWidget {
  const HomeBusinessZone({super.key});

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
                  decoration: BoxDecoration(
                    color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: AppDesignSystem.brandGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Broker, Builder & Founder Zone',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textP,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CRM Lead Kanban, Subscriptions & Ad Control',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          color: textS,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.push('/crm'),
                    child: const Text(
                      'CRM Kanban',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppDesignSystem.brandGold,
                      side: const BorderSide(color: AppDesignSystem.brandGold),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.push('/subscriptions'),
                    child: const Text(
                      'Subscriptions',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
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
