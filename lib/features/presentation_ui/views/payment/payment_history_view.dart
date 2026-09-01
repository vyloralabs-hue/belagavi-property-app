import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/monetization/presentation/providers/central_monetization_notifier.dart';
import 'package:belagavi_property/features/monetization/domain/entities/central_monetization_entities.dart';
import 'package:belagavi_property/core/localization/language_selector_modal.dart';

import 'package:belagavi_property/core/config/brand_config.dart';

class PaymentHistoryView extends ConsumerStatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  ConsumerState<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends ConsumerState<PaymentHistoryView> {
  static const String currentUserId = 'usr_current';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(centralMonetizationNotifierProvider.notifier)
          .fetchUserEntitlements(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(centralMonetizationNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: Text(
          '${BrandConfig.brandName} Monetization',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language_rounded,
              color: AppDesignSystem.primaryNavy,
            ),
            tooltip: 'Change Language',
            onPressed: () => LanguageSelectorModal.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Active Entitlements Header
                  const Text(
                    'Active Entitlements & Subscriptions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  if (state.activeEntitlements.isEmpty)
                    _buildEmptyState()
                  else
                    ...state.activeEntitlements.map(
                      (EntitlementEntity ent) => _buildEntitlementCard(ent),
                    ),

                  const SizedBox(height: 24),

                  // Free-First & Paid Plans Banner
                  const Text(
                    'Shop Listing Pricing Plans (Free Entry Configured)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPlanCard(
                          'Free Basic',
                          '₹0',
                          'Always Free Entry',
                          false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPlanCard(
                          'Monthly',
                          '₹500 / mo',
                          'Standard Monthly',
                          false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPlanCard(
                          'Yearly',
                          '₹5,000 / yr',
                          'Save ₹1,000',
                          true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Founder Revenue Streams Metric Summary
                  const Text(
                    'Platform Revenue Streams Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _buildRevenueSummaryCard(state),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Text(
          'No active subscriptions found.',
          style: TextStyle(color: AppDesignSystem.textSecondary),
        ),
      ),
    );
  }

  Widget _buildEntitlementCard(EntitlementEntity ent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: const RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppDesignSystem.primaryNavy.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: AppDesignSystem.primaryNavy,
          ),
        ),
        title: Text(
          '${ent.productType.name.toUpperCase()} (${ent.boostType.name})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'Expires: ${_formatDate(ent.expiresAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF059669),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    String badge,
    bool isRecommended,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRecommended ? AppDesignSystem.primaryNavy : Colors.white,
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(
          color: isRecommended
              ? AppDesignSystem.primaryNavy
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'BEST VALUE',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isRecommended ? Colors.white : AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isRecommended ? Colors.amber : AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge,
            style: TextStyle(
              fontSize: 10,
              color: isRecommended
                  ? Colors.white70
                  : AppDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummaryCard(CentralMonetizationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDesignSystem.borderRadiusL,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _revenueRow('Property Revenue', state.propertyRevenue),
          _revenueRow('Shop Revenue', state.shopRevenue),
          _revenueRow('Builder Revenue', state.builderRevenue),
          _revenueRow('Broker Revenue', state.brokerRevenue),
          _revenueRow('Google Ad Revenue', state.googleAdRevenue),
          _revenueRow('Direct Ad Revenue', state.directAdRevenue),
          const Divider(),
          _revenueRow(
            'Total Platform Revenue',
            state.totalRevenue,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _revenueRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isBold
                  ? AppDesignSystem.primaryNavy
                  : AppDesignSystem.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}
