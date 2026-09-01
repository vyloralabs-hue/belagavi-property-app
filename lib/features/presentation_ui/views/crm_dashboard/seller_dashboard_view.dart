import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../crm/presentation/providers/crm_leads_notifier.dart';
import '../../../crm/presentation/providers/crm_analytics_notifier.dart';
import '../../theme/app_design_system.dart';
import 'widgets/dashboard_metric_card.dart';
import 'widgets/dashboard_section_header.dart';
import 'widgets/crm_lead_card.dart';
import 'widgets/performance_bar_chart.dart';

/// Premium Seller Dashboard with property listings, leads, and analytics
class SellerDashboardView extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const SellerDashboardView({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<SellerDashboardView> createState() =>
      _SellerDashboardViewState();
}

class _SellerDashboardViewState extends ConsumerState<SellerDashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(crmLeadsNotifierProvider.notifier).fetchLeads(widget.userId);
      ref
          .read(crmAnalyticsNotifierProvider.notifier)
          .fetchAnalytics(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadsState = ref.watch(crmLeadsNotifierProvider);
    final analyticsState = ref.watch(crmAnalyticsNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildSliverMetrics(analyticsState),
          _buildSliverTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyListingsTab(),
            _buildLeadsTab(leadsState),
            _buildAnalyticsTab(analyticsState),
          ],
        ),
      ),
      floatingActionButton: _buildAddListingFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, ${widget.userName.split(' ').first}',
              style: const TextStyle(
                fontSize: 11,
                color: AppDesignSystem.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Text(
              'Seller Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F7FF), Colors.white],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSliverMetrics(CRMAnalyticsState analyticsState) {
    final int totalLeads;
    final int closedDeals;
    final String convRate;
    final String salesValue;

    if (analyticsState is CRMAnalyticsLoaded) {
      totalLeads = analyticsState.analytics.totalLeadsReceived;
      closedDeals = analyticsState.analytics.totalDealsClosed;
      convRate =
          '${analyticsState.analytics.conversionRate.toStringAsFixed(1)}%';
      final rev = analyticsState.analytics.totalSalesValue;
      salesValue = rev >= 10000000
          ? '₹${(rev / 10000000).toStringAsFixed(1)}Cr'
          : '₹${(rev / 100000).toStringAsFixed(0)}L';
    } else {
      totalLeads = 0;
      closedDeals = 0;
      convRate = '0%';
      salesValue = '₹0';
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          children: [
            DashboardMetricCard(
              title: 'Active Inquiries',
              value: '$totalLeads',
              icon: Icons.people_alt_rounded,
              iconColor: AppDesignSystem.primaryNavy,
              iconBg: const Color(0xFFEFF6FF),
              trend: '+12%',
            ),
            DashboardMetricCard(
              title: 'Deals Closed',
              value: '$closedDeals',
              icon: Icons.handshake_rounded,
              iconColor: AppDesignSystem.accentEmerald,
              iconBg: const Color(0xFFD1FAE5),
              trend: '+8%',
            ),
            DashboardMetricCard(
              title: 'Conversion Rate',
              value: convRate,
              icon: Icons.show_chart_rounded,
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFEF3C7),
            ),
            DashboardMetricCard(
              title: 'Sales Value',
              value: salesValue,
              icon: Icons.currency_rupee_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFEDE9FE),
              trend: '+21%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppDesignSystem.primaryNavy,
          unselectedLabelColor: AppDesignSystem.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          indicatorColor: AppDesignSystem.primaryNavy,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'My Listings'),
            Tab(text: 'Inquiries'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
    );
  }

  Widget _buildMyListingsTab() {
    // Demonstration properties for seller
    final properties = [
      const _PropertyItem(
        '3 BHK Flat — Tilakwadi',
        'Belagavi, Karnataka',
        '₹68 L',
        '1,450 sq.ft',
        4,
        'For Sale',
        true,
      ),
      const _PropertyItem(
        '2 BHK Apartment — Camp',
        'Belagavi, Karnataka',
        '₹45 L',
        '980 sq.ft',
        2,
        'For Sale',
        false,
      ),
      const _PropertyItem(
        'Plot — Hindwadi',
        'Belagavi, Karnataka',
        '₹22 L',
        '1,200 sq.ft',
        0,
        'For Sale',
        true,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppDesignSystem.primaryNavy, Color(0xFF3B82F6)],
            ),
            borderRadius: AppDesignSystem.borderRadiusL,
          ),
          child: const Row(
            children: [
              Icon(Icons.add_home_rounded, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post a New Property',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Reach thousands of buyers instantly',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const DashboardSectionHeader(title: 'My Active Listings'),
        const SizedBox(height: 12),
        ...properties.map((p) => _buildPropertyListItem(p)),
      ],
    );
  }

  Widget _buildPropertyListItem(_PropertyItem p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Row(
        children: [
          // Property icon placeholder
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: AppDesignSystem.borderRadiusM,
            ),
            child: const Icon(
              Icons.home_rounded,
              color: AppDesignSystem.primaryNavy,
              size: 28,
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
                        p.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppDesignSystem.textPrimary,
                        ),
                      ),
                    ),
                    if (p.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: AppDesignSystem.badgeBgGold,
                          borderRadius: AppDesignSystem.borderRadiusPill,
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.badgeTextGold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  p.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      p.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppDesignSystem.primaryNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      p.area,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppDesignSystem.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.remove_red_eye_rounded,
                          size: 12,
                          color: AppDesignSystem.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${p.views} views',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppDesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsTab(CRMLeadsState leadsState) {
    return switch (leadsState) {
      CRMLeadsInitial() => const Center(
        child: Text(
          'Initializing...',
          style: TextStyle(color: AppDesignSystem.textSecondary),
        ),
      ),
      CRMLeadsLoading() => const Center(
        child: CircularProgressIndicator(color: AppDesignSystem.primaryNavy),
      ),
      CRMLeadsError(message: final msg) => Center(
        child: Text(
          'Error: $msg',
          style: const TextStyle(color: Color(0xFFDC2626)),
        ),
      ),
      CRMLeadsLoaded(leads: final leads) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DashboardSectionHeader(
            title: 'Active Inquiries (${leads.length})',
            actionLabel: 'Filter',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          if (leads.isEmpty)
            _buildEmptyLeadsState()
          else
            ...leads.map(
              (lead) => CRMLeadCard(
                buyerName: lead.buyerName,
                buyerPhone: lead.buyerPhone,
                buyerEmail: lead.buyerEmail,
                budgetMax: lead.budgetMax,
                aiScore: lead.aiConversionScore,
                stage: lead.stage.name,
                source: lead.source.name,
                onTap: () {},
                onCallTap: () {},
              ),
            ),
        ],
      ),
    };
  }

  Widget _buildEmptyLeadsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No inquiries yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upgrade to premium to get\npriority buyer inquiries',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppDesignSystem.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(CRMAnalyticsState analyticsState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DashboardSectionHeader(title: 'Performance Overview'),
        const SizedBox(height: 14),
        const PerformanceBarChart(
          title: 'Monthly Inquiries',
          maxValue: 40,
          data: [
            BarChartData(label: 'Mar', label2: '18', value: 18),
            BarChartData(
              label: 'Apr',
              label2: '24',
              value: 24,
              isHighlight: true,
            ),
            BarChartData(
              label: 'May',
              label2: '31',
              value: 31,
              isHighlight: true,
            ),
            BarChartData(label: 'Jun', label2: '28', value: 28),
            BarChartData(
              label: 'Jul',
              label2: '35',
              value: 35,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        const PerformanceBarChart(
          title: 'Property Views (Last 5 Months)',
          maxValue: 500,
          data: [
            BarChartData(label: 'Mar', label2: '210', value: 210),
            BarChartData(
              label: 'Apr',
              label2: '320',
              value: 320,
              isHighlight: true,
            ),
            BarChartData(
              label: 'May',
              label2: '420',
              value: 420,
              isHighlight: true,
            ),
            BarChartData(label: 'Jun', label2: '380', value: 380),
            BarChartData(
              label: 'Jul',
              label2: '465',
              value: 465,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildSubscriptionBanner(),
      ],
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Belagavi Property Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Get premium listing placement + market insights',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusPill,
              ),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddListingFAB() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: AppDesignSystem.primaryNavy,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Add Listing',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PropertyItem {
  final String title;
  final String location;
  final String price;
  final String area;
  final int views;
  final String status;
  final bool isPremium;

  const _PropertyItem(
    this.title,
    this.location,
    this.price,
    this.area,
    this.views,
    this.status,
    this.isPremium,
  );
}

// ─── Sliver Tab Bar Delegate ─────────────────────────────────────────────────

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          tabBar,
          Container(height: 1, color: AppDesignSystem.borderSubtle),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
