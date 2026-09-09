import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/monetization/domain/entities/pricing_plan_entity.dart';
import 'package:belagavi_property/features/monetization/presentation/providers/pricing_providers.dart';
import '../../theme/app_design_system.dart';

/// Server-Authoritative Pricing Plans Catalog View.
/// Displays dynamic plans from Supabase backend.
/// Strictly adheres to:
/// - Zero hardcoded Rupee amounts (all fetched from backend pricing_plans)
/// - Strict product family separation
/// - Payment placeholder only (NO fake client-side entitlement activation)
class PricingPlansView extends ConsumerStatefulWidget {
  final String? initialProductFamily;
  final String? propertyId;

  const PricingPlansView({
    super.key,
    this.initialProductFamily,
    this.propertyId,
  });

  @override
  ConsumerState<PricingPlansView> createState() => _PricingPlansViewState();
}

class _PricingPlansViewState extends ConsumerState<PricingPlansView> {
  late String _selectedFamily;

  final List<Map<String, String>> _families = [
    {'key': 'residential_listing', 'label': 'Residential'},
    {'key': 'commercial_listing', 'label': 'Commercial'},
    {'key': 'legal_notice_publication', 'label': 'Legal Notice'},
    {'key': 'dispute_publication', 'label': 'Disputes'},
    {'key': 'property_watch', 'label': 'Property Watch'},
    {'key': 'survey_monitoring', 'label': 'Survey Watch'},
    {'key': 'buyer_unlock', 'label': 'Buyer Unlock'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFamily = widget.initialProductFamily ?? 'residential_listing';
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(activePricingPlansProvider);

    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plans & Pricing',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: textP,
              ),
            ),
            const Text(
              'Server-Authoritative Catalog',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                color: AppDesignSystem.brandGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderCol, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Family Filter Pills
          Container(
            height: 52,
            color: surfaceBg,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _families.length,
              itemBuilder: (context, index) {
                final family = _families[index];
                final isSelected = _selectedFamily == family['key'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFamily = family['key']!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppDesignSystem.brandGold
                          : (isDark ? const Color(0xFF131922) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppDesignSystem.brandGold : borderCol,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      family['label']!,
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? Colors.black : textS,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: borderCol),

          // Family Banner Info / Disclaimers
          _buildFamilyBanner(context, _selectedFamily),

          // Plans List
          Expanded(
            child: plansAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load pricing catalog: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              data: (plans) {
                final filtered = plans
                    .where((p) => p.productFamily == _selectedFamily)
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No active plans found for this category.',
                      style: TextStyle(color: textS),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final plan = filtered[index];
                    return _buildPlanCard(context, plan);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyBanner(BuildContext context, String family) {
    String message = '';
    Color iconColor = AppDesignSystem.brandGold;
    IconData icon = Icons.info_outline_rounded;

    switch (family) {
      case 'residential_listing':
        message = 'New residential listings receive 15 Days FREE. Choose a plan to extend or reactivate.';
        break;
      case 'commercial_listing':
        message = 'Commercial listings require a paid plan from Day 1. No free period applies.';
        iconColor = Colors.amber.shade800;
        break;
      case 'legal_notice_publication':
        message = 'Platform publication only. Does NOT establish statutory court service or legal validity.';
        icon = Icons.gavel_outlined;
        break;
      case 'dispute_publication':
        message = 'Dispute watch is 100% FREE. Publication does not establish that allegations are legally proven.';
        icon = Icons.warning_amber_rounded;
        break;
      case 'property_watch':
        message = 'Normal property watch requires paid entitlement from watch #1. No free trial.';
        break;
      case 'survey_monitoring':
        message = 'Continuous survey number tracking. Paid monitoring quota from first watch.';
        break;
      case 'buyer_unlock':
        message = 'Access verified owner direct contact & exact address. Choose credits below.';
        icon = Icons.lock_open_rounded;
        break;
    }

    final isDark = AppDesignSystem.isDark(context);
    final textS = AppDesignSystem.textS(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? const Color(0xFF131922) : const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                color: textS,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PricingPlanEntity plan) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppDesignSystem.brandGold, width: 0.8),
                ),
                child: Text(
                  plan.durationLabel,
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                plan.formattedPrice,
                style: const TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppDesignSystem.brandGold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                plan.isBuyerUnlock
                    ? '/ ${plan.creditCount} ${plan.creditCount == 1 ? 'Property' : 'Properties'}'
                    : '/ ${plan.durationLabel}',
                style: TextStyle(
                  fontSize: 12,
                  color: textS,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _handleChoosePlan(context, plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Choose Plan — ${plan.formattedPrice}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChoosePlan(BuildContext context, PricingPlanEntity plan) {
    // STRICT SECURITY RULE:
    // Payment gateway is NOT IMPLEMENTED in this task.
    // DO NOT grant fake entitlements or activate client-side.
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment_outlined, color: AppDesignSystem.brandGold, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payment Gateway Coming Soon',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppDesignSystem.textP(modalContext),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'You selected ${plan.name} for ${plan.formattedPrice}.',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Online payments (Razorpay/UPI) will be enabled in the upcoming release. No charge has been made and no fake entitlement is granted.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textS(modalContext),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(modalContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
