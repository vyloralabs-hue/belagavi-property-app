import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import 'package:belagavi_property/features/property/presentation/providers/vault_notifier.dart';
import 'package:belagavi_property/features/property/presentation/widgets/app_property_image.dart';
import 'package:belagavi_property/features/property/services/property_media_resolver.dart';
import '../../theme/app_design_system.dart';

/// Permanent Owner Vault Screen ("MY PROPERTY VAULT").
/// Guaranteed permanent retention of:
/// - Active Listings
/// - Expired Listings (safe in private vault, not public)
/// - Drafts
/// - Sold / Closed Properties
/// - Legal Notices
/// - Disputed Records
class PropertyVaultView extends ConsumerStatefulWidget {
  const PropertyVaultView({super.key});

  @override
  ConsumerState<PropertyVaultView> createState() => _PropertyVaultViewState();
}

class _PropertyVaultViewState extends ConsumerState<PropertyVaultView> {
  @override
  void initState() {
    super.initState();
    _loadVaultData();
  }

  void _loadVaultData() {
    Future.microtask(() {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        ref.read(vaultNotifierProvider.notifier).loadVault(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultNotifierProvider);
    final user = FirebaseAuth.instance.currentUser;

    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    final tabs = [
      {'label': 'Active', 'count': state.activeCount},
      {'label': 'Expired', 'count': state.expiredCount},
      {'label': 'Drafts', 'count': state.draftCount},
      {'label': 'Sold', 'count': state.soldCount},
      {'label': 'Legal Notices', 'count': state.legalNoticeCount},
      {'label': 'Disputes', 'count': state.disputeCount},
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Property Vault',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: textP,
              ),
            ),
            const Text(
              'Permanent Owner Storage',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                color: AppDesignSystem.brandGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Pricing Plans',
            icon: const Icon(Icons.workspace_premium_outlined, color: AppDesignSystem.brandGold),
            onPressed: () => context.push('/pricing-plans'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderCol, height: 1),
        ),
      ),
      body: user == null
          ? _buildUnauthenticatedState(context)
          : Column(
              children: [
                // Vault Tab Selector
                Container(
                  height: 52,
                  color: surfaceBg,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      final tab = tabs[index];
                      final label = tab['label'] as String;
                      final count = tab['count'] as int;
                      final isSelected = state.activeTab == label;

                      return GestureDetector(
                        onTap: () => ref.read(vaultNotifierProvider.notifier).setActiveTab(label),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppDesignSystem.brandGold
                                : (isDark ? const Color(0xFF131922) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppDesignSystem.brandGold : borderCol,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? Colors.black : textS,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black.withValues(alpha: 0.2)
                                        : AppDesignSystem.brandGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black : AppDesignSystem.brandGold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Divider(height: 1, color: borderCol),

                // Vault Tab Content
                Expanded(
                  child: RefreshIndicator(
                    color: AppDesignSystem.brandGold,
                    backgroundColor: surfaceBg,
                    onRefresh: () async => _loadVaultData(),
                    child: _buildTabContent(context, state),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabContent(BuildContext context, VaultState state) {
    if (state.activeTab == 'Legal Notices') {
      return _buildLegalNoticesList(context, state);
    }
    if (state.activeTab == 'Disputes') {
      return _buildDisputesList(context, state);
    }

    List<PropertyEntity> items;
    switch (state.activeTab) {
      case 'Expired':
        items = state.expiredProperties;
        break;
      case 'Drafts':
        items = state.draftProperties;
        break;
      case 'Sold':
        items = state.soldProperties;
        break;
      case 'Active':
      default:
        items = state.activeProperties;
        break;
    }

    if (items.isEmpty) {
      return _buildEmptyState(
        context,
        title: 'No ${state.activeTab} Records',
        message: state.activeTab == 'Expired'
            ? 'You have no expired listings. All your active listings remain publicly visible.'
            : 'No items currently in this section of your vault.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final prop = items[index];
        return _buildPropertyVaultCard(context, prop);
      },
    );
  }

  Widget _buildPropertyVaultCard(BuildContext context, PropertyEntity property) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: property.isListingExpired ? Colors.orange.shade400 : borderCol,
          width: property.isListingExpired ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Media
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppPropertyImage(
                    imageUrl: PropertyMediaResolver.getCoverUrl(property),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Expiry Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: property.isListingExpired
                            ? Colors.orange.shade900
                            : (property.isPaused
                                ? Colors.amber.shade900
                                : const Color(0xFF10B981)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        property.isListingExpired
                            ? 'Expired / Not Public'
                            : (property.isPaused ? 'On Hold' : 'Active'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${property.locality}, ${property.city}',
                  style: TextStyle(fontSize: 12, color: textS),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${property.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppDesignSystem.brandGold,
                  ),
                ),

                // Reactivation banner if expired
                if (property.isListingExpired) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A1B0E) : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Listing Expired — Safely Preserved in Vault',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? Colors.orange.shade300 : Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This property is hidden from public discovery. Choose a plan to restore public visibility.',
                          style: TextStyle(fontSize: 11, color: textS),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/pricing-plans', extra: {
                                'propertyId': property.id,
                                'productFamily': property.isCommercial
                                    ? 'commercial_listing'
                                    : 'residential_listing',
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text('Reactivate Listing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppDesignSystem.brandGold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalNoticesList(BuildContext context, VaultState state) {
    if (state.legalNotices.isEmpty) {
      return _buildEmptyState(
        context,
        title: 'No Saved Legal Notices',
        message: 'Your published and expired legal notices are permanently kept in this vault.',
      );
    }

    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.legalNotices.length,
      itemBuilder: (context, index) {
        final notice = state.legalNotices[index];
        final title = notice['title'] as String? ?? 'Legal Notice';
        final status = notice['status'] as String? ?? 'published';
        final publicUntil = notice['public_until'] != null
            ? DateTime.tryParse(notice['public_until'].toString())
            : null;
        final isExpired = publicUntil != null && DateTime.now().isAfter(publicUntil);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isExpired ? Colors.orange.shade300 : borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textP),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.orange.shade900 : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isExpired ? 'Expired — Not Public' : status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (isExpired) ...[
                const SizedBox(height: 8),
                Text(
                  '10-Day Public Visibility Expired. Permanent record preserved.',
                  style: TextStyle(fontSize: 11, color: textS),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.push('/pricing-plans', extra: {
                    'productFamily': 'legal_notice_publication',
                  }),
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Reactivate for 10 Days — ₹999'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppDesignSystem.brandGold,
                    side: const BorderSide(color: AppDesignSystem.brandGold),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisputesList(BuildContext context, VaultState state) {
    if (state.disputes.isEmpty) {
      return _buildEmptyState(
        context,
        title: 'No Dispute Records',
        message: 'Your dispute filings and evidence are permanently kept in this vault.',
      );
    }

    final textP = AppDesignSystem.textP(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.disputes.length,
      itemBuilder: (context, index) {
        final d = state.disputes[index];
        final title = d['title'] as String? ?? 'Dispute Record';
        final caseNo = d['case_number'] as String? ?? 'N/A';
        final status = d['status'] as String? ?? 'published';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textP),
              ),
              const SizedBox(height: 4),
              Text(
                'Case: $caseNo | Status: $status',
                style: const TextStyle(fontSize: 11, color: AppDesignSystem.brandGold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required String title, required String message}) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 48, color: AppDesignSystem.brandGold),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textP,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textS),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 48, color: AppDesignSystem.brandGold),
            const SizedBox(height: 16),
            Text(
              'Sign In Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textP),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access your permanent Property Vault.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textS),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/auth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Sign In Now'),
            ),
          ],
        ),
      ),
    );
  }
}
