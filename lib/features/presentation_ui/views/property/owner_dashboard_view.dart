import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/config/brand_config.dart';
import 'package:belagavi_property/features/property/domain/entities/owner_analytics_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/owner_analytics_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import '../../theme/app_design_system.dart';
import '../monetization/promote_property_modal.dart';

class OwnerDashboardView extends ConsumerStatefulWidget {
  final String ownerId;

  const OwnerDashboardView({super.key, required this.ownerId});

  @override
  ConsumerState<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends ConsumerState<OwnerDashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedTimeframe = '7D';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? widget.ownerId;
      ref
          .read(ownerAnalyticsNotifierProvider.notifier)
          .fetchOwnerDashboardData(
            authenticatedUserId: currentUserId,
            targetOwnerId: widget.ownerId,
            timeframe: _selectedTimeframe,
          );
      ref
          .read(myPropertiesNotifierProvider.notifier)
          .fetchMyProperties(currentUserId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? widget.ownerId;

    // Security Check: Route protection against unauthorized access
    if (currentUserId != widget.ownerId) {
      return Scaffold(
        backgroundColor: AppDesignSystem.backgroundWhite,
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text(
            'Access Denied: You do not have permission to view this owner dashboard.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final analyticsState = ref.watch(ownerAnalyticsNotifierProvider);
    final myPropertiesState = ref.watch(myPropertiesNotifierProvider);
    final analytics = analyticsState.analytics;

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
              'Owner Private Dashboard',
              style: const TextStyle(
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
                fontWeight: FontWeight.w600,
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
            Tab(text: 'My Listings'),
            Tab(text: 'Leads & Inquiries'),
            Tab(text: 'Daily Performance'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timeframe Selector & Key Metric Summary Cards
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PRIVATE INSIGHTS',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.textSecondary,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedTimeframe,
                        isDense: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'today',
                            child: Text(
                              'Today',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'yesterday',
                            child: Text(
                              'Yesterday',
                              style: TextStyle(fontSize: 12),
                            ),
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
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedTimeframe = val);
                            ref
                                .read(ownerAnalyticsNotifierProvider.notifier)
                                .fetchOwnerDashboardData(
                                  authenticatedUserId: currentUserId,
                                  targetOwnerId: widget.ownerId,
                                  timeframe: val,
                                );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricTile(
                        'Properties',
                        '${myPropertiesState.allProperties.length}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricTile(
                        'Views',
                        '${analytics?.totalViews ?? 0}',
                        Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricTile(
                        'Buyer Leads',
                        '${analytics?.buyerLeads ?? 0}',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricTile(
                        'Seller Leads',
                        '${analytics?.sellerLeads ?? 0}',
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: My Listings Private Table
                  _buildMyListingsTab(context, myPropertiesState.allProperties),

                  // Tab 2: Leads & Inquiries Table
                  _buildLeadsTab(context, analyticsState.leads),

                  // Tab 3: Daily Performance Analytics
                  _buildPerformanceTab(context, analytics),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
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

  Widget _buildMyListingsTab(BuildContext context, List properties) {
    if (properties.isEmpty) {
      return const Center(child: Text('No owned properties found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final prop = properties[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppDesignSystem.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      prop.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppDesignSystem.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.primaryNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      prop.status.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '₹${prop.price.toStringAsFixed(0)} • ${prop.locality}, ${prop.city}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Owner ID: ${prop.ownerId}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => PromotePropertyModal.show(context, prop),
                    icon: const Icon(Icons.rocket_launch_rounded, size: 12),
                    label: const Text('Promote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeadsTab(BuildContext context, List<OwnerLeadEntity> leads) {
    if (leads.isEmpty) {
      return const Center(child: Text('No leads or inquiries received yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        final isBuyer = lead.actorRole == 'BUYER';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppDesignSystem.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isBuyer
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lead.actorRole,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isBuyer
                                ? Colors.green.shade900
                                : Colors.orange.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lead.contactMethod,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${lead.createdAt.hour}:${lead.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Lead Name: ${lead.name}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              if (lead.phoneNumber != null)
                Text(
                  'Phone: ${lead.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignSystem.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (lead.email != null)
                Text(
                  'Email: ${lead.email}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                'Property: ${lead.propertyTitle} (${lead.location})',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTab(
    BuildContext context,
    OwnerDailyAnalyticsEntity? analytics,
  ) {
    if (analytics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAFFIC & AUDIENCE BREAKDOWN',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          _buildPerformanceRow(
            'Total Property Views',
            '${analytics.totalViews}',
            Icons.visibility_rounded,
          ),
          _buildPerformanceRow(
            'Search Appearances',
            '${analytics.searchAppearances}',
            Icons.search_rounded,
          ),
          _buildPerformanceRow(
            'Detail Page Opens',
            '${analytics.detailOpens}',
            Icons.open_in_new_rounded,
          ),
          _buildPerformanceRow(
            'Phone Call Clicks',
            '${analytics.callClicks}',
            Icons.call_rounded,
          ),
          _buildPerformanceRow(
            'WhatsApp Inquiry Clicks',
            '${analytics.whatsAppClicks}',
            Icons.chat_rounded,
          ),
          _buildPerformanceRow(
            'Direct Messages',
            '${analytics.messagesCount}',
            Icons.email_rounded,
          ),
          _buildPerformanceRow(
            'Favorites Saved',
            '${analytics.favoritesCount}',
            Icons.favorite_rounded,
          ),
          _buildPerformanceRow(
            'Promotion Impressions',
            '${analytics.promotionImpressions}',
            Icons.campaign_rounded,
          ),
          _buildPerformanceRow(
            'Promotion Clicks',
            '${analytics.promotionClicks}',
            Icons.ads_click_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String title, String count, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppDesignSystem.primaryNavy),
              const SizedBox(width: 10),
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
            count,
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
}
