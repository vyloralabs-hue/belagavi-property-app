import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../advertising/domain/entities/direct_ad_entities.dart';
import '../../../advertising/presentation/providers/advertising_providers.dart';
import '../../theme/app_design_system.dart';

class AdsManagementView extends ConsumerStatefulWidget {
  const AdsManagementView({super.key});

  @override
  ConsumerState<AdsManagementView> createState() => _AdsManagementViewState();
}

class _AdsManagementViewState extends ConsumerState<AdsManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['ALL', 'SUBMITTED', 'ACTIVE', 'PAUSED', 'REJECTED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    Future.microtask(() {
      ref.read(adminAdsNotifierProvider.notifier).fetchCampaigns();
    });
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
        title: const Text(
          'Sponsored Advertising',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFFF59E0B),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          onTap: (index) {
            final filter = index == 0 ? null : _tabs[index];
            ref.read(adminAdsNotifierProvider.notifier).fetchCampaigns(filterStatus: filter);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: AppDesignSystem.primaryNavy,
              size: 28,
            ),
            onPressed: () => context.push('/advertise-with-us'),
          ),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            final adminAdsState = ref.watch(adminAdsNotifierProvider);
            if (adminAdsState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
              );
            }

            final campaigns = tab == 'ALL'
                ? adminAdsState.campaigns
                : adminAdsState.campaigns.where((c) => c.status.toUpperCase() == tab).toList();

            if (campaigns.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.campaign_outlined, size: 54, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(
                      'No $tab campaigns found',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                final c = campaigns[index];
                return _buildDirectCampaignCard(c);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDirectCampaignCard(DirectAdCampaignEntity c) {
    Color badgeColor = Colors.grey;
    switch (c.status.toUpperCase()) {
      case 'ACTIVE':
        badgeColor = Colors.green;
        break;
      case 'SUBMITTED':
        badgeColor = Colors.orange;
        break;
      case 'PAUSED':
        badgeColor = Colors.amber.shade700;
        break;
      case 'REJECTED':
        badgeColor = Colors.red;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor),
                ),
                child: Text(
                  c.status.toUpperCase(),
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                c.placement,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            c.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Advertiser: ${c.businessName} (${c.contactPhone ?? 'No phone'})',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Headline: "${c.headline}"',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          if (c.targetLocality != null && c.targetLocality!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Locality: ${c.targetLocality}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 10),
          // Analytics Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('Impressions', '${c.impressions}'),
                _buildMetric('Clicks', '${c.clicks}'),
                _buildMetric('CTR', '${c.ctr}%'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Moderation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (c.status.toUpperCase() == 'SUBMITTED' || c.status.toUpperCase() == 'PAUSED') ...[
                ElevatedButton(
                  onPressed: () => _moderate(c.id, 'APPROVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    elevation: 0,
                  ),
                  child: const Text('Approve & Activate', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
              ],
              if (c.status.toUpperCase() == 'SUBMITTED') ...[
                OutlinedButton(
                  onPressed: () => _moderate(c.id, 'REJECT', reason: 'Non-compliant or incomplete details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Reject', style: TextStyle(fontSize: 12)),
                ),
              ],
              if (c.status.toUpperCase() == 'ACTIVE') ...[
                OutlinedButton(
                  onPressed: () => _moderate(c.id, 'PAUSE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade800,
                    side: BorderSide(color: Colors.orange.shade800),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Pause', style: TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  void _moderate(String campaignId, String action, {String? reason}) async {
    final success = await ref.read(adminAdsNotifierProvider.notifier).moderateCampaign(
      campaignId: campaignId,
      action: action,
      reason: reason,
    );
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Campaign action "$action" completed.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }
}
