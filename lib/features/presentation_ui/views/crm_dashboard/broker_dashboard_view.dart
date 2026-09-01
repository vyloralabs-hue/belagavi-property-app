import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../crm/presentation/providers/crm_leads_notifier.dart';
import '../../../crm/presentation/providers/crm_analytics_notifier.dart';
import '../../../crm/domain/entities/crm_entities.dart';
import '../../theme/app_design_system.dart';
import 'widgets/dashboard_metric_card.dart';
import 'widgets/dashboard_section_header.dart';
import 'widgets/crm_lead_card.dart';
import 'widgets/performance_bar_chart.dart';
import 'widgets/team_member_card.dart';

/// Premium Broker Dashboard with leads pipeline, team management, and analytics
class BrokerDashboardView extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  final bool isTeamMember;

  const BrokerDashboardView({
    super.key,
    required this.userId,
    required this.userName,
    this.isTeamMember = false,
  });

  @override
  ConsumerState<BrokerDashboardView> createState() =>
      _BrokerDashboardViewState();
}

class _BrokerDashboardViewState extends ConsumerState<BrokerDashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isTeamMember ? 2 : 4,
      vsync: this,
    );
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
            _buildPipelineTab(leadsState),
            _buildAnalyticsTab(analyticsState),
            if (!widget.isTeamMember) ...[
              _buildTeamTab(),
              _buildSubscriptionTab(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppDesignSystem.primaryNavy,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'Add Lead',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
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
                  widget.isTeamMember ? 'Team Member' : 'Broker Dashboard',
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
              widget.userName.split(' ').first,
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
              colors: [Color(0xFFEFF6FF), Colors.white],
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
      convRate = '—';
      salesValue = '—';
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
              trend: '+15%',
            ),
            DashboardMetricCard(
              title: 'Deals Closed',
              value: '$closedDeals',
              icon: Icons.check_circle_rounded,
              iconColor: AppDesignSystem.accentEmerald,
              iconBg: const Color(0xFFD1FAE5),
              trend: '+10%',
            ),
            DashboardMetricCard(
              title: 'Conv. Rate',
              value: convRate,
              icon: Icons.percent_rounded,
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFEF3C7),
            ),
            DashboardMetricCard(
              title: 'Brokerage',
              value: salesValue,
              icon: Icons.monetization_on_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFEDE9FE),
              trend: '+28%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverTabBar() {
    final tabs = widget.isTeamMember
        ? const [Tab(text: 'My Leads'), Tab(text: 'Analytics')]
        : const [
            Tab(text: 'Pipeline'),
            Tab(text: 'Analytics'),
            Tab(text: 'Team'),
            Tab(text: 'Subscription'),
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
          isScrollable: !widget.isTeamMember,
          tabAlignment: widget.isTeamMember
              ? TabAlignment.fill
              : TabAlignment.start,
          tabs: tabs,
        ),
      ),
    );
  }

  Widget _buildPipelineTab(CRMLeadsState leadsState) {
    return switch (leadsState) {
      CRMLeadsInitial() => const Center(
        child: CircularProgressIndicator(color: AppDesignSystem.primaryNavy),
      ),
      CRMLeadsLoading() => const Center(
        child: CircularProgressIndicator(color: AppDesignSystem.primaryNavy),
      ),
      CRMLeadsError(message: final msg) => Center(child: Text('Error: $msg')),
      CRMLeadsLoaded(leads: final leads) => _buildLeadsListView(leads),
    };
  }

  Widget _buildLeadsListView(List<CRMLeadEntity> leads) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildKanbanSummaryRow(leads),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DashboardSectionHeader(
              title: 'All Leads (${leads.length})',
              actionLabel: 'Sort',
              onAction: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final lead = leads[index];
              return CRMLeadCard(
                buyerName: lead.buyerName,
                buyerPhone: lead.buyerPhone,
                buyerEmail: lead.buyerEmail,
                budgetMax: lead.budgetMax,
                aiScore: lead.aiConversionScore,
                stage: lead.stage.name,
                source: lead.source.name,
                onTap: () {},
                onCallTap: () {},
              );
            }, childCount: leads.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildKanbanSummaryRow(List<CRMLeadEntity> leads) {
    final stages = {
      'New': leads.where((l) => l.stage == KanbanStageEnum.newLead).length,
      'Contacted': leads
          .where((l) => l.stage == KanbanStageEnum.contacted)
          .length,
      'Site Visit': leads
          .where((l) => l.stage == KanbanStageEnum.siteVisitScheduled)
          .length,
      'Won': leads.where((l) => l.stage == KanbanStageEnum.closedWon).length,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stages.entries.map((e) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppDesignSystem.cardWhite,
              borderRadius: AppDesignSystem.borderRadiusL,
              border: Border.all(color: AppDesignSystem.borderSubtle),
              boxShadow: AppDesignSystem.softShadow,
            ),
            child: Column(
              children: [
                Text(
                  '${e.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
                Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalyticsTab(CRMAnalyticsState analyticsState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DashboardSectionHeader(title: 'Brokerage Performance'),
        const SizedBox(height: 14),
        const PerformanceBarChart(
          title: 'Leads by Month',
          maxValue: 60,
          data: [
            BarChartData(label: 'Mar', label2: '22', value: 22),
            BarChartData(
              label: 'Apr',
              label2: '38',
              value: 38,
              isHighlight: true,
            ),
            BarChartData(
              label: 'May',
              label2: '45',
              value: 45,
              isHighlight: true,
            ),
            BarChartData(label: 'Jun', label2: '41', value: 41),
            BarChartData(
              label: 'Jul',
              label2: '55',
              value: 55,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        const PerformanceBarChart(
          title: 'Site Visits Arranged',
          maxValue: 25,
          data: [
            BarChartData(label: 'Mar', label2: '8', value: 8),
            BarChartData(
              label: 'Apr',
              label2: '12',
              value: 12,
              isHighlight: true,
            ),
            BarChartData(
              label: 'May',
              label2: '18',
              value: 18,
              isHighlight: true,
            ),
            BarChartData(label: 'Jun', label2: '15', value: 15),
            BarChartData(
              label: 'Jul',
              label2: '22',
              value: 22,
              isHighlight: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildConversionCard(analyticsState),
      ],
    );
  }

  Widget _buildConversionCard(CRMAnalyticsState analyticsState) {
    final convRate = analyticsState is CRMAnalyticsLoaded
        ? analyticsState.analytics.conversionRate
        : 0.0;

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
            'Conversion Funnel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFunnelRow(
            'Leads Received',
            55,
            55,
            const Color(0xFFEFF6FF),
            AppDesignSystem.primaryNavy,
          ),
          const SizedBox(height: 8),
          _buildFunnelRow(
            'Site Visits',
            22,
            55,
            const Color(0xFFFEF3C7),
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 8),
          _buildFunnelRow(
            'Negotiations',
            12,
            55,
            const Color(0xFFEDE9FE),
            const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 8),
          _buildFunnelRow(
            'Closed Won',
            8,
            55,
            const Color(0xFFD1FAE5),
            AppDesignSystem.accentEmerald,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              borderRadius: AppDesignSystem.borderRadiusM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Conversion Rate',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                Text(
                  '${convRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppDesignSystem.accentEmerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelRow(String label, int value, int max, Color bg, Color fg) {
    final fraction = max > 0 ? value / max : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              '$value',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(height: 8, color: const Color(0xFFE2E8F0)),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(height: 8, color: fg),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamTab() {
    // Demo team members
    final members = [
      const _TeamMember(
        'Rahul Desai',
        'Senior Broker',
        '+91 98765 43210',
        true,
        12,
      ),
      const _TeamMember('Priya Kulkarni', 'Broker', '+91 87654 32109', true, 8),
      const _TeamMember(
        'Anil Patil',
        'Junior Broker',
        '+91 76543 21098',
        false,
        5,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAddMemberBanner(),
        const SizedBox(height: 16),
        DashboardSectionHeader(
          title: 'Team Members (${members.length})',
          actionLabel: 'Manage',
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
            onRemove: () {},
          ),
        ),
        const SizedBox(height: 16),
        _buildRoleAccessCard(),
      ],
    );
  }

  Widget _buildAddMemberBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppDesignSystem.accentEmerald, Color(0xFF34D399)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          const Icon(Icons.group_add_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Team Members',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Assign leads and track performance',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppDesignSystem.accentEmerald,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusPill,
              ),
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleAccessCard() {
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
            'Role-Based Access Control',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            ('Lead Management', true, true),
            ('Analytics View', true, false),
            ('Team Management', true, false),
            ('Subscription Control', true, false),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppDesignSystem.textPrimary,
                      ),
                    ),
                  ),
                  _buildAccessBadge('Broker', item.$2),
                  const SizedBox(width: 8),
                  _buildAccessBadge('Member', item.$3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessBadge(String label, bool hasAccess) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: hasAccess ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
        borderRadius: AppDesignSystem.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasAccess
                ? Icons.check_circle_rounded
                : Icons.remove_circle_outline_rounded,
            size: 10,
            color: hasAccess
                ? AppDesignSystem.accentEmerald
                : AppDesignSystem.textSecondary,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: hasAccess
                  ? AppDesignSystem.accentEmerald
                  : AppDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DashboardSectionHeader(title: 'Subscription & Billing'),
        const SizedBox(height: 16),
        _buildActivePlanCard(),
        const SizedBox(height: 14),
        _buildFeatureGrid(),
        const SizedBox(height: 14),
        _buildUpgradeBanner(),
      ],
    );
  }

  Widget _buildActivePlanCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppDesignSystem.primaryNavy, Color(0xFF1E40AF)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amber,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PropertyHub Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Broker Plan • Active',
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
                  color: Colors.white.withAlpha(30),
                  borderRadius: AppDesignSystem.borderRadiusPill,
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlanStat('Leads / Month', '200'),
              _buildPlanStat('Team Members', '5'),
              _buildPlanStat('Listings', 'Unlimited'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: AppDesignSystem.borderRadiusM,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'Renews on 26 Aug 2026',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Spacer(),
                Text(
                  'Manage',
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
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      (Icons.trending_up_rounded, 'Market Insights', true),
      (Icons.priority_high_rounded, 'Priority Listing', true),
      (Icons.people_rounded, 'Team Management', true),
      (Icons.analytics_rounded, 'Advanced Analytics', true),
      (Icons.verified_rounded, 'Verified Badge', false),
      (Icons.support_agent_rounded, 'Dedicated Support', false),
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: features.map((f) {
              return Row(
                children: [
                  Icon(
                    f.$1,
                    size: 16,
                    color: f.$3
                        ? AppDesignSystem.accentEmerald
                        : AppDesignSystem.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 12,
                        color: f.$3
                            ? AppDesignSystem.textPrimary
                            : AppDesignSystem.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: const Row(
        children: [
          Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Enterprise',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Unlimited team + dedicated account manager',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white70,
            size: 14,
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
