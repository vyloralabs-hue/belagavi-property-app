import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/config/brand_config.dart';
import 'package:belagavi_property/features/property/presentation/providers/owner_command_center_notifier.dart';
import '../../theme/app_design_system.dart';

class LandDeveloperDashboardView extends ConsumerStatefulWidget {
  final String developerId;

  const LandDeveloperDashboardView({super.key, required this.developerId});

  @override
  ConsumerState<LandDeveloperDashboardView> createState() =>
      _LandDeveloperDashboardViewState();
}

class _LandDeveloperDashboardViewState
    extends ConsumerState<LandDeveloperDashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? widget.developerId;
      ref
          .read(ownerCommandCenterNotifierProvider.notifier)
          .fetchCommandCenterData(
            authenticatedUserId: currentUserId,
            targetOwnerId: widget.developerId,
            timeframe: '30D',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? widget.developerId;

    // Security Check: Route protection against unauthorized access
    if (currentUserId != widget.developerId) {
      return Scaffold(
        backgroundColor: AppDesignSystem.backgroundWhite,
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text(
            'Access Denied: You do not have permission to view this Land Developer Dashboard.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final state = ref.watch(ownerCommandCenterNotifierProvider);

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
              'Land Developer Dashboard',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subscription Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEVELOPER PRO SUBSCRIPTION ACTIVE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Valid until: 2026-12-31 • 15 Plot Layout Capacity Available',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Stats Grid
              const Text(
                'LAYOUT PERFORMANCE & ANALYTICS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatTile(
                    'Active Layouts',
                    '${state.summary.activeListings}',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatTile(
                    'Total Views',
                    '${state.summary.totalViews}',
                    Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  _buildStatTile(
                    'Plot Enquiries',
                    '${state.summary.totalEnquiries}',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Managed Layout Projects List
              const Text(
                'MANAGED LAND LAYOUTS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              if (state.propertyPerformances.isEmpty)
                const Center(child: Text('No land layouts registered yet.'))
              else
                ...state.propertyPerformances.map((layout) {
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              layout.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            Text(
                              '${layout.propertyType} • ${layout.location}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppDesignSystem.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppDesignSystem.primaryNavy,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${layout.views} Views',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String val, Color color) {
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
              val,
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
