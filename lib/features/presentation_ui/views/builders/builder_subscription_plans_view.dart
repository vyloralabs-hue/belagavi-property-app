import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/config/brand_config.dart';
import 'package:belagavi_property/features/monetization/domain/entities/central_monetization_entities.dart';
import '../../theme/app_design_system.dart';

class BuilderSubscriptionPlansView extends ConsumerStatefulWidget {
  final String? initialCategory; // 'builder' or 'landDeveloper'

  const BuilderSubscriptionPlansView({super.key, this.initialCategory});

  @override
  ConsumerState<BuilderSubscriptionPlansView> createState() =>
      _BuilderSubscriptionPlansViewState();
}

class _BuilderSubscriptionPlansViewState
    extends ConsumerState<BuilderSubscriptionPlansView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<PricingPlanEntity> _builderPlans = [
    PricingPlanEntity.builderStarterMonthly,
    PricingPlanEntity.builderProMonthly,
    PricingPlanEntity.builderPremiumMonthly,
  ];

  final List<PricingPlanEntity> _landDevPlans = [
    PricingPlanEntity.landDeveloperStarterMonthly,
    PricingPlanEntity.landDeveloperProMonthly,
    PricingPlanEntity.landDeveloperPremiumMonthly,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialCategory == 'landDeveloper' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Subscription Plans',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            Text(
              BrandConfig.brandName,
              style: const TextStyle(
                fontSize: 11,
                color: AppDesignSystem.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppDesignSystem.primaryNavy,
          unselectedLabelColor: AppDesignSystem.textSecondary,
          indicatorColor: AppDesignSystem.primaryNavy,
          tabs: const [
            Tab(text: 'Builder Projects'),
            Tab(text: 'Land Developments'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPlanList(context, _builderPlans, 'Builder'),
            _buildPlanList(context, _landDevPlans, 'Land Developer'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList(
    BuildContext context,
    List<PricingPlanEntity> plans,
    String segmentLabel,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isPro = index == 1;
        final isPremium = index == 2;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPremium
                  ? AppDesignSystem.accentGold
                  : isPro
                  ? AppDesignSystem.primaryNavy
                  : AppDesignSystem.borderSubtle,
              width: isPremium || isPro ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (isPremium || isPro)
                BoxShadow(
                  color:
                      (isPremium
                              ? AppDesignSystem.accentGold
                              : AppDesignSystem.primaryNavy)
                          .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.planName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.accentGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₹${plan.amountInRupees.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ month',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildFeatureRow(
                'Capacity',
                '${plan.listingLimit} Active Projects',
              ),
              _buildFeatureRow(
                'Priority Rank',
                isPremium
                    ? '+100 Priority Boost'
                    : isPro
                    ? '+50 Priority Boost'
                    : 'Standard Organic',
              ),
              _buildFeatureRow(
                'Featured Eligibility',
                isPremium || isPro ? 'Included' : 'Not Included',
              ),
              _buildFeatureRow('Owner Command Center', 'Full Access'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Subscribed to ${plan.planName} in Sandbox Mode. Subscription Active!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPremium
                        ? AppDesignSystem.accentGold
                        : AppDesignSystem.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Select ${plan.planName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppDesignSystem.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
