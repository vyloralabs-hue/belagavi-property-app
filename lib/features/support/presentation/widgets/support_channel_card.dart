import 'package:flutter/material.dart';
import '../../../presentation_ui/theme/app_design_system.dart';

/// Premium support channel card — WhatsApp / Call / Chat
class SupportChannelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String availability;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
  final VoidCallback onTap;
  final String? badgeLabel;

  const SupportChannelCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.availability,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
    required this.onTap,
    this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppDesignSystem.cardWhite,
          borderRadius: AppDesignSystem.borderRadiusL,
          boxShadow: AppDesignSystem.softShadow,
          border: Border.all(color: borderColor.withAlpha(60), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppDesignSystem.borderRadiusM,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppDesignSystem.textPrimary,
                        ),
                      ),
                      if (badgeLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppDesignSystem.badgeBgGold,
                            borderRadius: AppDesignSystem.borderRadiusPill,
                          ),
                          child: Text(
                            badgeLabel!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppDesignSystem.badgeTextGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppDesignSystem.accentEmerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        availability,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppDesignSystem.accentEmerald,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: iconColor),
          ],
        ),
      ),
    );
  }
}
