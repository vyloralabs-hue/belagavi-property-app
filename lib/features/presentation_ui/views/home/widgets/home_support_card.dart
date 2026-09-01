import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

class HomeSupportCard extends StatelessWidget {
  const HomeSupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppDesignSystem.borderRadiusL,
          boxShadow: AppDesignSystem.cardShadow,
          border: Border.all(color: borderCol, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.headset_mic_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help or Legal Support?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '24/7 Belagavi property assistance & legal guidance',
                    style: TextStyle(fontSize: 12, color: textS),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
