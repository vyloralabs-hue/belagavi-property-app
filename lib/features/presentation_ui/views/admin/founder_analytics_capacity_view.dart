import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';
import '../../../admin_panel/presentation/providers/platform_capacity_notifier.dart';
import '../../../admin_panel/domain/entities/platform_analytics_capacity_entity.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/localization/language_selector_modal.dart';

class FounderAnalyticsCapacityView extends ConsumerStatefulWidget {
  const FounderAnalyticsCapacityView({super.key});

  @override
  ConsumerState<FounderAnalyticsCapacityView> createState() =>
      _FounderAnalyticsCapacityViewState();
}

class _FounderAnalyticsCapacityViewState
    extends ConsumerState<FounderAnalyticsCapacityView> {
  static const String currentUserId = 'usr_founder_001';
  static const UserRole currentUserRole = UserRole.founder;

  String _selectedRange = '30d';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(platformCapacityNotifierProvider.notifier)
          .fetchMetrics(
            authenticatedUserId: currentUserId,
            userRole: currentUserRole,
            timeRange: _selectedRange,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(platformCapacityNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Platform Analytics & Capacity',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : state.metrics == null
          ? const Center(child: Text('No capacity data available'))
          : _buildDashboard(state.metrics!, state.zeroResultDemands),
    );
  }

  Widget _buildDashboard(
    PlatformCapacityMetricsEntity metrics,
    List<ZeroResultQueryEntity> zeroResults,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Time Range Filter Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Time Horizon:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            DropdownButton<String>(
              value: _selectedRange,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'today', child: Text('Today')),
                DropdownMenuItem(value: '7d', child: Text('Last 7 Days')),
                DropdownMenuItem(value: '30d', child: Text('Last 30 Days')),
                DropdownMenuItem(value: '90d', child: Text('Last 90 Days')),
                DropdownMenuItem(value: '1y', child: Text('Last 1 Year')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedRange = val);
                  ref
                      .read(platformCapacityNotifierProvider.notifier)
                      .fetchMetrics(
                        authenticatedUserId: currentUserId,
                        userRole: currentUserRole,
                        timeRange: val,
                      );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Health Status Banner
        _buildHealthBanner(metrics.overallHealthStatus),
        const SizedBox(height: 20),

        // Property Lifecycle Metrics Grid
        const Text(
          'Property Lifecycle Counts (DB-Side Aggregated)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildStatCard(
              'Total Properties',
              metrics.totalProperties.toString(),
              AppDesignSystem.primaryNavy,
            ),
            _buildStatCard(
              'Published',
              metrics.publishedProperties.toString(),
              AppDesignSystem.accentEmerald,
            ),
            _buildStatCard(
              'Pending Verification',
              metrics.pendingProperties.toString(),
              Colors.orange.shade700,
            ),
            _buildStatCard(
              'Under Review',
              metrics.underReviewProperties.toString(),
              Colors.blue.shade700,
            ),
            _buildStatCard(
              'Disputed',
              metrics.disputedProperties.toString(),
              Colors.red.shade700,
            ),
            _buildStatCard(
              'Archived',
              metrics.archivedProperties.toString(),
              Colors.grey.shade700,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Ecosystem Breakdown
        const Text(
          'Ecosystem Users',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCompactStat(
                'Total Users',
                metrics.totalUsers.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactStat(
                'Builders',
                metrics.totalBuilders.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactStat(
                'Agents',
                metrics.totalAgents.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactStat(
                'Sellers',
                metrics.totalSellers.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Zero-Result Intelligence Section
        const Text(
          'Zero-Result Search Demand Areas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'High search demand with no matching properties available:',
          style: TextStyle(fontSize: 12, color: AppDesignSystem.textSecondary),
        ),
        const SizedBox(height: 10),
        ...zeroResults.map(
          (zr) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: const RoundedRectangleBorder(
              borderRadius: AppDesignSystem.borderRadiusM,
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  color: Colors.amber.shade800,
                ),
              ),
              title: Text(
                '${zr.locationName} (${zr.categoryName})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                'Search volume: ${zr.searchCount} queries',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.trending_up,
                color: AppDesignSystem.accentEmerald,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Local Ad Performance
        const Text(
          'Local Ads Overview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCompactStat(
                'Total Ads',
                metrics.totalAds.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCompactStat(
                'Active Ads',
                metrics.activeAds.toString(),
                color: AppDesignSystem.accentEmerald,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthBanner(HealthStatusLevel health) {
    Color bg;
    Color iconColor;
    String label;
    String desc;

    switch (health) {
      case HealthStatusLevel.green:
        bg = const Color(0xFFD1FAE5);
        iconColor = const Color(0xFF059669);
        label = 'PLATFORM HEALTH: OPTIMAL (GREEN)';
        desc =
            'All system metrics, verification queues, and dispute levels are within normal bounds.';
        break;
      case HealthStatusLevel.yellow:
        bg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        label = 'PLATFORM HEALTH: ATTENTION (YELLOW)';
        desc =
            'Moderation queue or dispute count approaching warning thresholds.';
        break;
      case HealthStatusLevel.red:
        bg = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        label = 'PLATFORM HEALTH: CRITICAL (RED)';
        desc =
            'Immediate Founder action required due to high dispute or backlog volume.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          Icon(Icons.health_and_safety_rounded, color: iconColor, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppDesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
