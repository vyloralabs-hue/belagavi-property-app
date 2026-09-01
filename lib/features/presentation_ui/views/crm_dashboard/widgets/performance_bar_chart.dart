import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

/// Premium analytics bar chart widget for performance visualization
class PerformanceBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final String title;
  final double maxValue;

  const PerformanceBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.maxValue,
  });

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
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppDesignSystem.textPrimary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final heightFraction = maxValue > 0 ? d.value / maxValue : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          d.label2 ?? '',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppDesignSystem.textPrimary),
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: 90 * heightFraction,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: d.isHighlight
                                    ? [AppDesignSystem.primaryNavy, const Color(0xFF3B82F6)]
                                    : [AppDesignSystem.accentEmerald, const Color(0xFF34D399)],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.label,
                          style: const TextStyle(fontSize: 10, color: AppDesignSystem.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartData {
  final String label;
  final String? label2;
  final double value;
  final bool isHighlight;

  const BarChartData({
    required this.label,
    this.label2,
    required this.value,
    this.isHighlight = false,
  });
}
