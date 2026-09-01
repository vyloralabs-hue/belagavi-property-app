import 'package:flutter/material.dart';
import '../../../presentation_ui/theme/app_design_system.dart';

/// Premium document service card with fee, turnaround, and CTA button
class DocumentServiceCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final double fee;
  final bool isFree;
  final String turnaround;
  final bool isPremiumOnly;
  final VoidCallback onRequest;

  const DocumentServiceCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.fee,
    required this.isFree,
    required this.turnaround,
    required this.onRequest,
    this.isPremiumOnly = false,
  });

  String get _feeLabel {
    if (isFree) return 'Free';
    return '₹${fee.toStringAsFixed(0)}';
  }

  Color get _feeBg =>
      isFree ? const Color(0xFFD1FAE5) : const Color(0xFFEFF6FF);
  Color get _feeColor =>
      isFree ? AppDesignSystem.accentEmerald : AppDesignSystem.primaryNavy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: AppDesignSystem.borderRadiusM,
                  border: Border.all(color: AppDesignSystem.borderSubtle),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppDesignSystem.textPrimary,
                            ),
                          ),
                        ),
                        if (isPremiumOnly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: AppDesignSystem.badgeBgGold,
                              borderRadius: AppDesignSystem.borderRadiusPill,
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppDesignSystem.badgeTextGold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppDesignSystem.textSecondary,
                        height: 1.5,
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
              // Fee badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _feeBg,
                  borderRadius: AppDesignSystem.borderRadiusPill,
                ),
                child: Text(
                  _feeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _feeColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Turnaround
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: AppDesignSystem.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    turnaround,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // CTA
              ElevatedButton(
                onPressed: onRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDesignSystem.borderRadiusPill,
                  ),
                  elevation: 0,
                ),
                child: const Text('Request'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
