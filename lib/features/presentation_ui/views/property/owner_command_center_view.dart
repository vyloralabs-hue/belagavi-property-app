import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/config/brand_config.dart';
import 'package:belagavi_property/features/property/domain/entities/owner_command_center_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/my_properties_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/owner_command_center_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import '../../theme/app_design_system.dart';
import '../monetization/promote_property_modal.dart';

class OwnerCommandCenterView extends ConsumerStatefulWidget {
  final String ownerId;

  const OwnerCommandCenterView({super.key, required this.ownerId});

  @override
  ConsumerState<OwnerCommandCenterView> createState() =>
      _OwnerCommandCenterViewState();
}

class _OwnerCommandCenterViewState extends ConsumerState<OwnerCommandCenterView>
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
          .read(ownerCommandCenterNotifierProvider.notifier)
          .fetchCommandCenterData(
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
            'Access Denied: You do not have permission to view this Owner Command Center.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final state = ref.watch(ownerCommandCenterNotifierProvider);
    final summary = state.summary;

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
              'Owner Command Center',
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
            Tab(text: 'Properties'),
            Tab(text: 'Leads & Pipeline'),
            Tab(text: 'Daily Traffic'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Row & Timeframe Selector
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BUSINESS INTELLIGENCE',
                        style: TextStyle(
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
                                .read(
                                  ownerCommandCenterNotifierProvider.notifier,
                                )
                                .fetchCommandCenterData(
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
                      _buildSummaryTile(
                        'Active',
                        '${summary.activeListings}',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryTile(
                        'Hidden',
                        '${summary.hiddenListings}',
                        Colors.amber.shade900,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryTile(
                        'Views',
                        '${summary.totalViews}',
                        Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryTile(
                        'Enquiries',
                        '${summary.totalEnquiries}',
                        Colors.blue,
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
                  _buildPropertyPerformanceTab(
                    context,
                    state.propertyPerformances,
                  ),
                  _buildLeadsPipelineTab(context, state.leads, currentUserId),
                  _buildDailyTrafficTab(context, summary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color color) {
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

  Widget _buildPropertyPerformanceTab(
    BuildContext context,
    List<OwnerPropertyPerformanceEntity> performances,
  ) {
    if (performances.isEmpty) {
      return const Center(child: Text('No owned property listings found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: performances.length,
      itemBuilder: (context, index) {
        final item = performances[index];
        final isLive =
            item.status == 'PUBLISHED' ||
            item.status == 'APPROVED' ||
            item.status == 'ACTIVE';

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
                      item.title,
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
                      color: isLive ? Colors.green : Colors.amber.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLive ? '● LIVE' : '● HIDDEN',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${item.propertyType} • ${item.location}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricStat('Views', '${item.views}'),
                  _buildMetricStat('Enquiries', '${item.enquiriesCount}'),
                  _buildMetricStat('Calls', '${item.contactRequestsCount}'),
                  _buildMetricStat('Search Boost', item.premiumStatus),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Edit Listing',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Open promotion modal for target property
                      },
                      icon: const Icon(Icons.rocket_launch_rounded, size: 12),
                      label: const Text('Promote'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildMetricStat(String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.primaryNavy,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppDesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsPipelineTab(
    BuildContext context,
    List<OwnerCommandLeadEntity> leads,
    String currentUserId,
  ) {
    if (leads.isEmpty) {
      return const Center(child: Text('No leads or enquiries in pipeline.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
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
                  Text(
                    lead.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                  DropdownButton<OwnerCommandLeadStatus>(
                    value: lead.status,
                    isDense: true,
                    underline: const SizedBox(),
                    items: OwnerCommandLeadStatus.values.map((st) {
                      return DropdownMenuItem(
                        value: st,
                        child: Text(
                          st.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newSt) {
                      if (newSt != null) {
                        ref
                            .read(ownerCommandCenterNotifierProvider.notifier)
                            .updateLeadStatus(
                              authenticatedUserId: currentUserId,
                              leadId: lead.id,
                              newStatus: newSt,
                            );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (lead.phoneNumber != null)
                Text(
                  'Phone: ${lead.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
              Text(
                'Property: ${lead.propertyTitle}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              if (lead.notes != null)
                Text(
                  'Notes: ${lead.notes}',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyTrafficTab(
    BuildContext context,
    OwnerCommandCenterSummaryEntity summary,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AGGREGATE TRAFFIC METRICS',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          _buildTrafficRow(
            'Total Property Views',
            '${summary.totalViews}',
            Icons.visibility_rounded,
          ),
          _buildTrafficRow(
            'Total Enquiries Received',
            '${summary.totalEnquiries}',
            Icons.chat_rounded,
          ),
          _buildTrafficRow(
            'New Leads in Pipeline',
            '${summary.newLeadsCount}',
            Icons.person_add_rounded,
          ),
          _buildTrafficRow(
            'Active Listings',
            '${summary.activeListings}',
            Icons.check_circle_rounded,
          ),
          _buildTrafficRow(
            'Hidden Listings',
            '${summary.hiddenListings}',
            Icons.visibility_off_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficRow(String title, String val, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
            val,
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
