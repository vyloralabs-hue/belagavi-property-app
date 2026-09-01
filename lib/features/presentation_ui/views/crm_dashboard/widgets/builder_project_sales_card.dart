import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

/// Premium project sales progress card for builder dashboard
class BuilderProjectSalesCard extends StatelessWidget {
  final String projectName;
  final int totalUnits;
  final int availableUnits;
  final int bookedUnits;
  final int soldUnits;
  final double totalRevenueInr;

  const BuilderProjectSalesCard({
    super.key,
    required this.projectName,
    required this.totalUnits,
    required this.availableUnits,
    required this.bookedUnits,
    required this.soldUnits,
    required this.totalRevenueInr,
  });

  double get _soldFraction => totalUnits > 0 ? soldUnits / totalUnits : 0;
  double get _bookedFraction => totalUnits > 0 ? bookedUnits / totalUnits : 0;

  String _formatRevenue(double r) {
    if (r >= 10000000) return '₹${(r / 10000000).toStringAsFixed(2)} Cr';
    if (r >= 100000) return '₹${(r / 100000).toStringAsFixed(1)} L';
    return '₹${r.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  borderRadius: AppDesignSystem.borderRadiusM,
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppDesignSystem.primaryNavy,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppDesignSystem.textPrimary,
                      ),
                    ),
                    Text(
                      'Total Revenue: ${_formatRevenue(totalRevenueInr)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppDesignSystem.accentEmerald,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  borderRadius: AppDesignSystem.borderRadiusPill,
                ),
                child: Text(
                  '${(_soldFraction * 100).toStringAsFixed(0)}% Sold',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.accentEmerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Unit progress
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 10, color: const Color(0xFFE2E8F0)),
                FractionallySizedBox(
                  widthFactor: _soldFraction + _bookedFraction,
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3B82F6),
                          AppDesignSystem.primaryNavy,
                        ],
                      ),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: _soldFraction,
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppDesignSystem.accentEmerald,
                          Color(0xFF34D399),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildUnitBadge(
                'Available',
                availableUnits,
                const Color(0xFFE2E8F0),
                AppDesignSystem.textSecondary,
              ),
              const SizedBox(width: 8),
              _buildUnitBadge(
                'Booked',
                bookedUnits,
                const Color(0xFFDEEFFF),
                AppDesignSystem.primaryNavy,
              ),
              const SizedBox(width: 8),
              _buildUnitBadge(
                'Sold',
                soldUnits,
                const Color(0xFFD1FAE5),
                AppDesignSystem.accentEmerald,
              ),
              const Spacer(),
              Text(
                '$totalUnits Total Units',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitBadge(String label, int count, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDesignSystem.borderRadiusPill,
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
