import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

class AIListingQualityCard extends StatelessWidget {
  final double score; // 0-100
  final bool isDuplicate;

  const AIListingQualityCard({
    super.key,
    this.score = 92.5,
    this.isDuplicate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: AppDesignSystem.accentEmerald,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI Listing Quality Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppDesignSystem.accentEmerald.withValues(alpha: 0.1),
                  borderRadius: AppDesignSystem.borderRadiusPill,
                ),
                child: Text(
                  '${score.toStringAsFixed(1)} / 100',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.accentEmerald,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Duplicate Check: ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              Text(
                isDuplicate
                    ? 'Potential Duplicate Found'
                    : 'Clean & Unique Listing',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDuplicate
                      ? Colors.red
                      : AppDesignSystem.accentEmerald,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
