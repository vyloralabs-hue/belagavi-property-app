import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../crm/presentation/providers/crm_leads_notifier.dart';
import '../../../crm/presentation/providers/crm_analytics_notifier.dart';
import '../../theme/app_design_system.dart';
import 'widgets/dashboard_metric_card.dart';
import 'widgets/dashboard_section_header.dart';
import 'widgets/crm_lead_card.dart';
import 'widgets/performance_bar_chart.dart';
import 'widgets/builder_project_sales_card.dart';
import 'widgets/team_member_card.dart';

/// Premium Builder Dashboard with project management, sales tracking, team, and analytics
class BuilderDashboardView extends ConsumerStatefulWidget {
  final String userId;
  final String builderName;
  final String? projectId;
  final bool isTeamMember;

  const BuilderDashboardView({
    super.key,
    required this.userId,
    required this.builderName,
    this.projectId,
    this.isTeamMember = false,
  });

  @override
  ConsumerState<BuilderDashboardView> createState() =>
      _BuilderDashboardViewState();
}

class _BuilderDashboardViewState extends ConsumerState<BuilderDashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isTeamMember ? 2 : 5,
      vsync: this,
    );
    Future.microtask(() {
      ref.read(crmLeadsNotifierProvider.notifier).fetchLeads(widget.userId);
      ref
          .read(crmAnalyticsNotifierProvider.notifier)
          .fetchAnalytics(widget.userId, widget.projectId);
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
            _buildProjectsTab(analyticsState),
            _buildLeadsTab(leadsState),
            if (!widget.isTeamMember) ...[
              _buildAnalyticsTab(analyticsState),
              _buildTeamTab(),
              _buildSubscriptionTab(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppDesignSystem.primaryNavy,
        icon: const Icon(Icons.domain_add_rounded, color: Colors.white),
        label: const Text(
          'New Project',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
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
            Row(
              children: [
                Text(
                  widget.isTeamMember
                      ? 'Builder Team Member'
                      : 'Builder Dashboard',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppDesignSystem.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (widget.isTeamMember) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      borderRadius: AppDesignSystem.borderRadiusPill,
                    ),
                    child: const Text(
                      'TEAM',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppDesignSystem.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              widget.builderName.split(' ').take(2).join(' '),
              style: const TextStyle(
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
              colors: [Color(0xFFF0F0FF), Colors.white],
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: AppDesignSystem.badgeBgGold,
                  borderRadius: AppDesignSystem.borderRadiusPill,
                ),
                child: const Text(
                  'VERIFIED BUILDER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.badgeTextGold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.search_rounded,
            color: AppDesignSystem.textPrimary,
          ),
        ),
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

  // ── Sliver Metrics ──────────────────────────────────────────────────────────

  Widget _buildSliverMetrics(CRMAnalyticsState analyticsState) {
    final int totalLeads;
    final int closedDeals;
    final String salesValue;
    final int totalUnits;
    final int soldUnits;

    if (analyticsState is CRMAnalyticsLoaded) {
      totalLeads = analyticsState.analytics.totalLeadsReceived;
      closedDeals = analyticsState.analytics.totalDealsClosed;
      final rev = analyticsState.analytics.totalSalesValue;
      salesValue = rev >= 10000000
          ? '₹${(rev / 10000000).toStringAsFixed(2)}Cr'
          : '₹${(rev / 100000).toStringAsFixed(0)}L';
      totalUnits = analyticsState.projectSales?.totalUnits ?? 0;
      soldUnits = analyticsState.projectSales?.soldUnits ?? 0;
    } else {
      totalLeads = 0;
      closedDeals = 0;
      salesValue = '—';
      totalUnits = 0;
      soldUnits = 0;
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
              title: 'Total Leads',
              value: '$totalLeads',
              icon: Icons.people_rounded,
              iconColor: AppDesignSystem.primaryNavy,
              iconBg: const Color(0xFFEFF6FF),
              trend: '+18%',
            ),
            DashboardMetricCard(
              title: 'Units Sold',
              value: '$soldUnits / $totalUnits',
              icon: Icons.apartment_rounded,
              iconColor: AppDesignSystem.accentEmerald,
              iconBg: const Color(0xFFD1FAE5),
              trend: '+22%',
            ),
            DashboardMetricCard(
              title: 'Bookings',
              value: '$closedDeals',
              icon: Icons.book_online_rounded,
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFEF3C7),
            ),
            DashboardMetricCard(
              title: 'Sales Revenue',
              value: salesValue,
              icon: Icons.currency_rupee_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFEDE9FE),
              trend: '+35%',
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver Tab Bar ──────────────────────────────────────────────────────────

  Widget _buildSliverTabBar() {
    final tabs = widget.isTeamMember
        ? const [Tab(text: 'Projects'), Tab(text: 'Leads')]
        : const [
            Tab(text: 'Projects'),
            Tab(text: 'Leads'),
            Tab(text: 'Analytics'),
            Tab(text: 'Team'),
            Tab(text: 'Plan'),
          ];

    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppDesignSystem.primaryNavy,
          unselectedLabelColor: AppDesignSystem.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          indicatorColor: AppDesignSystem.primaryNavy,
          indicatorWeight: 2.5,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: tabs,
        ),
      ),
    );
  }

  // ── Projects Tab ────────────────────────────────────────────────────────────

  Widget _buildProjectsTab(CRMAnalyticsState analyticsState) {
    // Demo builder projects
    final projects = [
      BuilderProjectSalesCard(
        projectName: 'Prestige Sky Gardens',
        totalUnits: 120,
        availableUnits: 42,
        bookedUnits: 28,
        soldUnits: 50,
        totalRevenueInr: analyticsState is CRMAnalyticsLoaded
            ? analyticsState.analytics.totalSalesValue
            : 42000000,
      ),
      const BuilderProjectSalesCard(
        projectName: 'Landmark Residency Phase 2',
        totalUnits: 80,
        availableUnits: 25,
        bookedUnits: 15,
        soldUnits: 40,
        totalRevenueInr: 28000000,
      ),
      const BuilderProjectSalesCard(
        projectName: 'Green Valley Villas',
        totalUnits: 45,
        availableUnits: 8,
        bookedUnits: 5,
        soldUnits: 32,
        totalRevenueInr: 19500000,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNewProjectBanner(),
        const SizedBox(height: 16),
        DashboardSectionHeader(
          title: 'Active Projects (${projects.length})',
          actionLabel: 'View All',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        ...projects,
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNewProjectBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          const Icon(Icons.add_business_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Launch New Project',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Instant listing + marketing ready',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppDesignSystem.primaryNavy,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusPill,
              ),
            ),
            child: const Text('Launch'),
          ),
        ],
      ),
    );
  }

  // ── Leads Tab ───────────────────────────────────────────────────────────────

  Widget _buildLeadsTab(CRMLeadsState leadsState) {
    return switch (leadsState) {
      CRMLeadsInitial() => const Center(
        child: CircularProgressIndicator(color: AppDesignSystem.primaryNavy),
      ),
      CRMLeadsLoading() => const Center(
        child: CircularProgressIndicator(color: AppDesignSystem.primaryNavy),
      ),
      CRMLeadsError(message: final msg) => Center(child: Text('Error: $msg')),
      CRMLeadsLoaded(leads: final leads) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLeadsFilterRow(),
          const SizedBox(height: 12),
          DashboardSectionHeader(title: 'Project Inquiries (${leads.length})'),
          const SizedBox(height: 12),
          if (leads.isEmpty)
            _buildEmptyState()
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

  Widget _buildLeadsFilterRow() {
    final filters = ['All', 'Sky Gardens', 'Landmark', 'Green Valley'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.asMap().entries.map((e) {
          final isFirst = e.key == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isFirst ? AppDesignSystem.primaryNavy : Colors.white,
              borderRadius: AppDesignSystem.borderRadiusPill,
              border: Border.all(
                color: isFirst
                    ? AppDesignSystem.primaryNavy
                    : AppDesignSystem.borderSubtle,
              ),
            ),
            child: Text(
              e.value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isFirst ? Colors.white : AppDesignSystem.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'No leads available',
          style: TextStyle(color: AppDesignSystem.textSecondary),
        ),
      ),
    );
  }

  // ── Analytics Tab ───────────────────────────────────────────────────────────

  Widget _buildAnalyticsTab(CRMAnalyticsState analyticsState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DashboardSectionHeader(title: 'Builder Analytics'),
        const SizedBox(height: 14),
        const PerformanceBarChart(
          title: 'Project Bookings by Month',
          maxValue: 30,
          data: [
            BarChartData(label: 'Mar', label2: '8', value: 8),
            BarChartData(
              label: 'Apr',
              label2: '14',
              value: 14,
              isHighlight: true,
            ),
            BarChartData(
              label: 'May',
              label2: '22',
              value: 22,
              isHighlight: true,
            ),
            BarChartData(label: 'Jun', label2: '18', value: 18),
            BarChartData(
              label: 'Jul',
              label2: '28',
              value: 28,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        const PerformanceBarChart(
          title: 'Revenue Generated (₹ Lakhs)',
          maxValue: 200,
          data: [
            BarChartData(label: 'Mar', label2: '82L', value: 82),
            BarChartData(
              label: 'Apr',
              label2: '130L',
              value: 130,
              isHighlight: true,
            ),
            BarChartData(
              label: 'May',
              label2: '175L',
              value: 175,
              isHighlight: true,
            ),
            BarChartData(label: 'Jun', label2: '155L', value: 155),
            BarChartData(
              label: 'Jul',
              label2: '190L',
              value: 190,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildInventoryOverviewCard(analyticsState),
      ],
    );
  }

  Widget _buildInventoryOverviewCard(CRMAnalyticsState analyticsState) {
    final totalUnits = analyticsState is CRMAnalyticsLoaded
        ? analyticsState.projectSales?.totalUnits ?? 245
        : 245;
    final soldUnits = analyticsState is CRMAnalyticsLoaded
        ? analyticsState.projectSales?.soldUnits ?? 122
        : 122;
    final bookedUnits = analyticsState is CRMAnalyticsLoaded
        ? analyticsState.projectSales?.bookedUnits ?? 48
        : 48;
    final available = totalUnits - soldUnits - bookedUnits;

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
          const Text(
            'Portfolio Inventory Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInventoryCircle(
                '$totalUnits',
                'Total',
                AppDesignSystem.primaryNavy,
              ),
              _buildInventoryCircle(
                '$soldUnits',
                'Sold',
                AppDesignSystem.accentEmerald,
              ),
              _buildInventoryCircle(
                '$bookedUnits',
                'Booked',
                const Color(0xFFF59E0B),
              ),
              _buildInventoryCircle(
                '$available',
                'Available',
                const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: soldUnits,
                  child: Container(
                    height: 12,
                    color: AppDesignSystem.accentEmerald,
                  ),
                ),
                Expanded(
                  flex: bookedUnits,
                  child: Container(height: 12, color: const Color(0xFFF59E0B)),
                ),
                Expanded(
                  flex: available > 0 ? available : 1,
                  child: Container(height: 12, color: const Color(0xFFE2E8F0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCircle(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Team Tab ────────────────────────────────────────────────────────────────

  Widget _buildTeamTab() {
    final members = [
      const _TeamMember(
        'Suresh Hegde',
        'Sales Manager',
        '+91 98765 11111',
        true,
        28,
      ),
      const _TeamMember(
        'Kavita Nair',
        'Site Sales Executive',
        '+91 87654 22222',
        true,
        14,
      ),
      const _TeamMember(
        'Mohan Patil',
        'Site Supervisor',
        '+91 76543 33333',
        true,
        6,
      ),
      const _TeamMember(
        'Anita Joshi',
        'Customer Relations',
        '+91 65432 44444',
        false,
        10,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAddTeamBanner(),
        const SizedBox(height: 16),
        DashboardSectionHeader(
          title: 'Builder Team (${members.length})',
          actionLabel: 'Manage Roles',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        ...members.map(
          (m) => TeamMemberCard(
            name: m.name,
            role: m.role,
            phone: m.phone,
            isActive: m.isActive,
            assignedLeads: m.leads,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildAddTeamBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF1565C0)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.business_center_rounded,
            color: Colors.white,
            size: 26,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grow Your Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Add sales executives and manage leads together',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F4C81),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusPill,
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ── Subscription Tab ────────────────────────────────────────────────────────

  Widget _buildSubscriptionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DashboardSectionHeader(title: 'Builder Subscription'),
        const SizedBox(height: 16),
        _buildBuilderPlanCard(),
        const SizedBox(height: 14),
        _buildPremiumFeaturesCard(),
        const SizedBox(height: 14),
        _buildEnterpriseBanner(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildBuilderPlanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.domain_rounded, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PropertyHub Builder Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Builder Plan • Active',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withAlpha(40),
                  borderRadius: AppDesignSystem.borderRadiusPill,
                  border: Border.all(
                    color: const Color(0xFF22C55E).withAlpha(80),
                  ),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlanStat('Projects', '10'),
              _buildPlanStat('Team Members', '20'),
              _buildPlanStat('Listing Credits', '500/mo'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: AppDesignSystem.borderRadiusM,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white54,
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'Renews 26 Aug 2026',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                Spacer(),
                Text(
                  'Manage Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildPremiumFeaturesCard() {
    final features = [
      (Icons.description_rounded, 'Detailed Property Description', true),
      (Icons.analytics_rounded, 'Advanced Analytics', true),
      (Icons.verified_rounded, 'Verified Builder Badge', true),
      (Icons.groups_rounded, 'Team Management', true),
      (Icons.auto_graph_rounded, 'Market Intelligence', false),
      (Icons.support_agent_rounded, 'Dedicated CRM', false),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Features',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    f.$1,
                    size: 18,
                    color: f.$3
                        ? AppDesignSystem.primaryNavy
                        : AppDesignSystem.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f.$2,
                    style: TextStyle(
                      fontSize: 13,
                      color: f.$3
                          ? AppDesignSystem.textPrimary
                          : AppDesignSystem.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    f.$3
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                    color: f.$3
                        ? AppDesignSystem.accentEmerald
                        : AppDesignSystem.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterpriseBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF92400E), Color(0xFFD97706)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.corporate_fare_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Go Enterprise',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Multi-city • Franchise • Channel Partners',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFD97706),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusPill,
              ),
            ),
            child: const Text('Contact Us'),
          ),
        ],
      ),
    );
  }
}

class _TeamMember {
  final String name, role, phone;
  final bool isActive;
  final int leads;
  const _TeamMember(
    this.name,
    this.role,
    this.phone,
    this.isActive,
    this.leads,
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
