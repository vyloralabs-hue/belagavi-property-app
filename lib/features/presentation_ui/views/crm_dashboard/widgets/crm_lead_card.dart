import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

/// Premium lead card widget with AI conversion score and kanban stage badge
class CRMLeadCard extends StatelessWidget {
  final String buyerName;
  final String buyerPhone;
  final String? buyerEmail;
  final double budgetMax;
  final double aiScore;
  final String stage;
  final String source;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;

  const CRMLeadCard({
    super.key,
    required this.buyerName,
    required this.buyerPhone,
    this.buyerEmail,
    required this.budgetMax,
    required this.aiScore,
    required this.stage,
    required this.source,
    this.onTap,
    this.onCallTap,
  });

  Color get _scoreColor {
    if (aiScore >= 75) return AppDesignSystem.accentEmerald;
    if (aiScore >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  Color get _stageBgColor {
    switch (stage.toLowerCase()) {
      case 'closedwon':
        return const Color(0xFFD1FAE5);
      case 'closedlost':
        return const Color(0xFFFFE4E6);
      case 'negotiation':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color get _stageTextColor {
    switch (stage.toLowerCase()) {
      case 'closedwon':
        return AppDesignSystem.accentEmerald;
      case 'closedlost':
        return const Color(0xFFDC2626);
      case 'negotiation':
        return const Color(0xFFD97706);
      default:
        return AppDesignSystem.primaryNavy;
    }
  }

  String get _stageLabel {
    switch (stage.toLowerCase()) {
      case 'newlead':
        return 'New Lead';
      case 'contacted':
        return 'Contacted';
      case 'sitevisitscheduled':
        return 'Site Visit';
      case 'negotiation':
        return 'Negotiation';
      case 'closedwon':
        return 'Closed Won';
      case 'closedlost':
        return 'Closed Lost';
      default:
        return stage;
    }
  }

  String _formatBudget(double budget) {
    if (budget >= 10000000) return '₹${(budget / 10000000).toStringAsFixed(1)}Cr';
    if (budget >= 100000) return '₹${(budget / 100000).toStringAsFixed(0)}L';
    return '₹${budget.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppDesignSystem.cardWhite,
          borderRadius: AppDesignSystem.borderRadiusL,
          boxShadow: AppDesignSystem.softShadow,
          border: Border.all(color: AppDesignSystem.borderSubtle),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      buyerName.isNotEmpty ? buyerName[0].toUpperCase() : 'B',
                      style: const TextStyle(
                        color: AppDesignSystem.primaryNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
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
                              buyerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _stageBgColor,
                              borderRadius: AppDesignSystem.borderRadiusPill,
                            ),
                            child: Text(
                              _stageLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _stageTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        buyerPhone,
                        style: const TextStyle(fontSize: 12, color: AppDesignSystem.textSecondary),
                      ),
                      if (buyerEmail != null)
                        Text(
                          buyerEmail!,
                          style: const TextStyle(fontSize: 11, color: AppDesignSystem.textSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppDesignSystem.borderSubtle,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Budget
                _buildInfoChip(Icons.currency_rupee_rounded, _formatBudget(budgetMax), 'Budget'),
                const SizedBox(width: 12),
                // Source
                _buildInfoChip(Icons.source_rounded, source.replaceAll('_', ' '), 'Source'),
                const Spacer(),
                // Lead Quality Score
                Row(
                  children: [
                    Icon(Icons.trending_up_rounded, size: 14, color: _scoreColor),
                    const SizedBox(width: 4),
                    Text(
                      '${aiScore.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Call Button
                GestureDetector(
                  onTap: onCallTap,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.call_rounded, size: 16, color: AppDesignSystem.accentEmerald),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: const TextStyle(fontSize: 10, color: AppDesignSystem.textSecondary)),
        Row(
          children: [
            Icon(icon, size: 11, color: AppDesignSystem.textSecondary),
            const SizedBox(width: 3),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppDesignSystem.textPrimary)),
          ],
        ),
      ],
    );
  }
}
