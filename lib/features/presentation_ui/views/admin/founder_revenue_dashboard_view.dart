import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/config/brand_config.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/monetization/presentation/providers/central_monetization_notifier.dart';
import '../../theme/app_design_system.dart';

class FounderRevenueDashboardView extends ConsumerStatefulWidget {
  final UserRole userRole;

  const FounderRevenueDashboardView({super.key, required this.userRole});

  @override
  ConsumerState<FounderRevenueDashboardView> createState() =>
      _FounderRevenueDashboardViewState();
}

class _FounderRevenueDashboardViewState
    extends ConsumerState<FounderRevenueDashboardView> {
  String _selectedTimeframe = '30D';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? 'usr_founder';
      ref
          .read(centralMonetizationNotifierProvider.notifier)
          .fetchFounderRevenueMetrics(
            authenticatedUserId: currentUserId,
            timeframe: _selectedTimeframe,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Platform Governance Check: Restricted to Founder / Admin
    if (!widget.userRole.isAdminOrFounder) {
      return Scaffold(
        backgroundColor: AppDesignSystem.backgroundWhite,
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text(
            'Access Denied: Founder or Admin authorization required to view Revenue Dashboard.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final state = ref.watch(centralMonetizationNotifierProvider);

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
              'Founder Revenue Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            Text(
              'BELAGAVI PROPERTY LLP • ${BrandConfig.brandName}',
              style: const TextStyle(
                fontSize: 11,
                color: AppDesignSystem.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PLATFORM FINANCIAL METRICS',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.primaryNavy,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedTimeframe,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'today',
                        child: Text('Today', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: '7D',
                        child: Text(
                          'Last 7 Days',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '30D',
                        child: Text(
                          'Last 30 Days',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '90D',
                        child: Text(
                          'Last 90 Days',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '1Y',
                        child: Text(
                          'Last 1 Year',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTimeframe = val);
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid ??
                            'usr_founder';
                        ref
                            .read(centralMonetizationNotifierProvider.notifier)
                            .fetchFounderRevenueMetrics(
                              authenticatedUserId: currentUserId,
                              timeframe: val,
                            );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Total Revenue Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppDesignSystem.primaryNavy, Colors.blue.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppDesignSystem.primaryNavy.withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL GROSS REVENUE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${state.totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All product categories • Sandbox Environment',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppDesignSystem.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Revenue Breakdown Cards
              const Text(
                'REVENUE BY PRODUCT CATEGORY',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              _buildRevenueTile(
                'Property Premium Promotions',
                '₹${state.propertyRevenue.toStringAsFixed(2)}',
                Icons.home_work_rounded,
                Colors.teal,
              ),
              _buildRevenueTile(
                'Local Shop Subscriptions',
                '₹${state.shopRevenue.toStringAsFixed(2)}',
                Icons.storefront_rounded,
                Colors.purple,
              ),
              _buildRevenueTile(
                'Builder Pro Enterprise Tiers',
                '₹${state.builderRevenue.toStringAsFixed(2)}',
                Icons.apartment_rounded,
                Colors.blue,
              ),
              _buildRevenueTile(
                'Broker Pro Agent Plans',
                '₹${state.brokerRevenue.toStringAsFixed(2)}',
                Icons.badge_rounded,
                Colors.amber.shade900,
              ),

              const SizedBox(height: 20),

              // Transaction Status Breakdown
              const Text(
                'TRANSACTION HEALTH & COMPLIANCE',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatusTile('Successful', '142', Colors.green),
                  const SizedBox(width: 8),
                  _buildStatusTile('Pending', '3', Colors.amber.shade900),
                  const SizedBox(width: 8),
                  _buildStatusTile('Failed', '2', Colors.red),
                  const SizedBox(width: 8),
                  _buildStatusTile('Refunds', '0', Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueTile(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppDesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
