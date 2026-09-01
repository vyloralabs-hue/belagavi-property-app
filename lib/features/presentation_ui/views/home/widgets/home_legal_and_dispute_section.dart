import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

/// Responsive Two-Column Legal Due Diligence & Disputed Property Section
/// Desktop/Tablet: Two columns side-by-side
/// Mobile: Vertically stacked cards
class HomeLegalAndDisputeSection extends StatelessWidget {
  const HomeLegalAndDisputeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Legal & Due Diligence Hub',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textP,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppDesignSystem.brandGold.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'Transparency',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDisputedPropertyCard(context)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildLegalNoticeCard(context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildDisputedPropertyCard(context),
                    const SizedBox(height: 12),
                    _buildLegalNoticeCard(context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisputedPropertyCard(BuildContext context) {
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: AppDesignSystem.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DISPUTED PROPERTY',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD97706),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Reported Litigation & Caveats',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 11,
                        color: textS,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explore properties with reported ownership, court litigation, family, or boundary claims. Independent verification required.',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 11,
              color: textS,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/disputed-properties'),
              icon: const Icon(Icons.warning_amber_rounded, size: 15),
              label: const Text('View Disputed Properties'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalNoticeCard(BuildContext context) {
    final cardBg = AppDesignSystem.cardBg(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppDesignSystem.brandGold.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: AppDesignSystem.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppDesignSystem.brandGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LEGAL DUE DILIGENCE',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppDesignSystem.brandGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Advisory & Statutory Guidelines',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 11,
                        color: textS,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Structured 13-point buyer verification, seller compliance guidelines, title chain checks, and statutory caution alerts.',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 11,
              color: textS,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/legal-notices'),
              icon: const Icon(Icons.fact_check_outlined, size: 15),
              label: const Text('View Legal Information'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
