import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/my_properties_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import 'package:belagavi_property/features/property/presentation/widgets/app_property_image.dart';
import '../../theme/app_design_system.dart';
import 'add_property_wizard_view.dart';
import 'widgets/category_selection_modal.dart';
import 'package:belagavi_property/features/monetization/presentation/widgets/promote_property_modal.dart';

/// Secure "My Properties" Seller Management Screen
/// Displays only listings owned by the authenticated user.
/// Customer Permissions: LIST, HOLD, RESUME (if held), DELETE, VIEW.
class MyPropertiesListView extends ConsumerStatefulWidget {
  const MyPropertiesListView({super.key});

  @override
  ConsumerState<MyPropertiesListView> createState() => _MyPropertiesListViewState();
}

class _MyPropertiesListViewState extends ConsumerState<MyPropertiesListView> {
  @override
  void initState() {
    super.initState();
    _loadUserProperties();
  }

  void _loadUserProperties() {
    Future.microtask(() {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null && currentUserId.isNotEmpty) {
        ref.read(myPropertiesNotifierProvider.notifier).fetchMyProperties(currentUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPropertiesNotifierProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    final tabs = [
      'All',
      'Published',
      'Paused',
      'Submitted',
      'Drafts',
      'Archived',
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
        title: Text(
          'My Properties',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textP,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: borderCol,
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Inbound Enquiries',
            icon: const Icon(Icons.inbox_outlined, color: AppDesignSystem.brandGold, size: 24),
            onPressed: () => context.push('/seller-enquiries'),
          ),
          IconButton(
            tooltip: 'List New Property',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppDesignSystem.brandGold, size: 26),
            onPressed: () => CategorySelectionModal.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Minimal Temporary E2E Diagnostic Panel with Per-Property Provenance
            Builder(
              builder: (context) {
                final remoteRowsCount = state.allProperties.where((p) => state.remotePropertyIds.contains(p.id)).length;
                final localOnlyCount = state.allProperties.length - remoteRowsCount;
                final totalCount = state.allProperties.length;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withValues(alpha: 0.25),
                    border: Border.all(color: Colors.amber, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'E2E DIAGNOSTIC',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Authenticated: ${state.isAuthenticated ? 'YES' : 'NO'}',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Profile resolved: ${state.profileResolved ? 'YES' : 'NO'}',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Remote fetch succeeded: ${state.remoteFetchSucceeded ? 'YES' : 'NO'}',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Remote rows: $remoteRowsCount',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Local-only rows: $localOnlyCount',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Total displayed: $totalCount',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      if (state.allProperties.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        const Divider(color: Colors.amber, height: 1),
                        const SizedBox(height: 6),
                        ...state.allProperties.map((p) {
                          final isRemote = state.remotePropertyIds.contains(p.id);
                          final sourceStr = isRemote ? 'REMOTE' : (state.status == MyPropertiesStateStatus.loaded ? 'LOCAL' : 'UNKNOWN');
                          final sourceColor = isRemote ? Colors.greenAccent : Colors.orangeAccent;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Title: ${p.title}',
                                  style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                SelectableText(
                                  'UUID: ${p.id}',
                                  style: const TextStyle(color: Colors.cyan, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Status: ${p.status.dbValue}',
                                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Source: $sourceStr',
                                  style: TextStyle(color: sourceColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),

            // Filter Tabs
            Container(
              height: 48,
              color: surfaceBg,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  final isSelected = state.activeTab == tab;
                  return GestureDetector(
                    onTap: () => ref.read(myPropertiesNotifierProvider.notifier).setActiveTab(tab),
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
                      child: Text(
                        tab == 'Paused' ? 'On Hold' : tab,
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.black : textS,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1, color: borderCol),

            // Content List or Empty State
            Expanded(
              child: currentUserId == null
                  ? _buildUnauthenticatedState(context)
                  : state.status == MyPropertiesStateStatus.loading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
                        )
                      : state.filteredProperties.isEmpty
                          ? _buildEmptyState(context)
                          : RefreshIndicator(
                              color: AppDesignSystem.brandGold,
                              backgroundColor: surfaceBg,
                              onRefresh: () async => _loadUserProperties(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: state.filteredProperties.length,
                                itemBuilder: (context, index) {
                                  final property = state.filteredProperties[index];
                                  return _buildCustomerPropertyCard(context, property, currentUserId);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, size: 48, color: AppDesignSystem.brandGold),
            ),
            const SizedBox(height: 20),
            Text(
              'Sign In Required',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textP,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please sign in with your phone number or account to view and manage your properties.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 13,
                color: textS,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/auth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Sign In Now',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_work_outlined, size: 48, color: AppDesignSystem.brandGold),
            ),
            const SizedBox(height: 20),
            Text(
              'No Properties Listed Yet',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textP,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post your property in Belagavi to reach thousands of buyers, tenants, and investors.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 13,
                color: textS,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => CategorySelectionModal.show(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                '+ List Your Property',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerPropertyCard(
    BuildContext context,
    PropertyEntity property,
    String currentUserId,
  ) {
    final isOnHold = property.status == ListingStatus.paused;
    final isLive = property.status == ListingStatus.published ||
        property.status == ListingStatus.approved ||
        property.status == ListingStatus.active;

    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    final coverMedia = property.mediaList.where((m) => m.isCover).firstOrNull ??
        property.mediaList.firstOrNull;

    final areaSqft = property.specifications.carpetArea ??
        property.specifications.superBuiltUpArea ??
        property.specifications.plotArea ??
        '';

    final purpose = property.features['purpose'] ?? 'FOR SALE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOnHold
              ? Colors.amber.withValues(alpha: 0.5)
              : borderCol,
          width: 1.2,
        ),
        boxShadow: isDark ? null : AppDesignSystem.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Purpose and Status Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: AppPropertyImage(
                    imageUrl: coverMedia?.mediaUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Purpose Badge (Top Left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0D11).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppDesignSystem.brandGold, width: 0.8),
                  ),
                  child: Text(
                    purpose.toString().toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                ),
              ),
              // Status Badge (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: switch (property.status) {
                      ListingStatus.active || ListingStatus.published || ListingStatus.approved => const Color(0xFF10B981),
                      ListingStatus.pendingVerification || ListingStatus.submitted || ListingStatus.underReview => const Color(0xFFD97706),
                      ListingStatus.rejected => const Color(0xFFDC2626),
                      ListingStatus.sold => const Color(0xFF2563EB),
                      ListingStatus.paused => Colors.amber.shade900,
                      _ => const Color(0xFF64748B),
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    switch (property.status) {
                      ListingStatus.draft => 'Draft',
                      ListingStatus.pendingVerification || ListingStatus.submitted || ListingStatus.underReview => 'Pending Verification',
                      ListingStatus.active || ListingStatus.published || ListingStatus.approved => 'Active',
                      ListingStatus.rejected => 'Rejected',
                      ListingStatus.sold => 'Sold',
                      ListingStatus.archived => 'Archived',
                      ListingStatus.paused => 'On Hold',
                      _ => 'Pending Verification',
                    },
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Property Information
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: textS),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.locality}, ${property.city}',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          color: textS,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${_formatPrice(property.price)}',
                      style: const TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppDesignSystem.brandGold,
                      ),
                    ),
                    if (areaSqft.toString().isNotEmpty)
                      Text(
                        '$areaSqft SQFT',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textS,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Owner Status Explanation Banner ──────────────────────────
                // Replaces raw status text with human-friendly context message
                _buildOwnerStatusBanner(context, property),

                const SizedBox(height: 10),
                Divider(height: 1, color: borderCol),
                const SizedBox(height: 12),

                // Promote Listing Button (if eligible)
                if (property.status == ListingStatus.published || property.status == ListingStatus.active || property.status == ListingStatus.approved) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: () => PromotePropertyModal.show(context, property),
                      icon: const Icon(Icons.rocket_launch_outlined, color: AppDesignSystem.brandGold, size: 14),
                      label: const Text(
                        'Promote Listing (Featured / Boost)',
                        style: TextStyle(color: AppDesignSystem.brandGold, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppDesignSystem.brandGold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Customer Action Buttons tailored strictly to allowed lifecycle rules
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // 1. View Button (Always available)
                    OutlinedButton.icon(
                      onPressed: () => context.push('/property/${property.id}'),
                      icon: const Icon(Icons.visibility_outlined, size: 13),
                      label: const Text('View', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textP,
                        side: BorderSide(color: borderCol),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    // 2. Edit Button (Allowed if not Sold / Rented / Archived)
                    if (property.status != ListingStatus.sold &&
                        property.status != ListingStatus.rented &&
                        property.status != ListingStatus.leased &&
                        property.status != ListingStatus.archived)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPropertyWizardView(editProperty: property),
                            ),
                          ).then((_) => _loadUserProperties());
                        },
                        icon: const Icon(Icons.edit_outlined, size: 13),
                        label: Text(
                          property.status == ListingStatus.changesRequested || property.status == ListingStatus.rejected
                              ? 'Fix / Edit'
                              : property.status == ListingStatus.disputed
                                  ? 'Dispute Info'
                                  : 'Edit',
                          style: const TextStyle(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppDesignSystem.brandGold,
                          side: const BorderSide(color: AppDesignSystem.brandGold),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                    // 2b. Manage Media Button
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/property-documents/${property.id}');
                      },
                      icon: const Icon(Icons.photo_library_outlined, size: 13),
                      label: const Text('Media', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textS,
                        side: BorderSide(color: borderCol),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    // 3. Hold / Pause Button (Only if currently Live / Approved)
                    if (isLive)
                      OutlinedButton.icon(
                        onPressed: () => _handleHoldToggle(context, property, currentUserId),
                        icon: const Icon(Icons.pause_circle_outline_rounded, size: 13),
                        label: const Text('Hold', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber.shade700,
                          side: BorderSide(color: Colors.amber.shade700),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                    // 4. Resume Button (Only if currently On Hold / Paused)
                    if (isOnHold)
                      OutlinedButton.icon(
                        onPressed: () => _handleHoldToggle(context, property, currentUserId),
                        icon: const Icon(Icons.play_arrow_rounded, size: 13),
                        label: const Text('Resume', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                    // 5. Mark Sold Button (Only if Live or Paused)
                    if (isLive || isOnHold)
                      OutlinedButton.icon(
                        onPressed: () => _showMarkSoldConfirmation(context, property, currentUserId),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 13),
                        label: const Text('Mark Sold', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF38BDF8),
                          side: const BorderSide(color: Color(0xFF38BDF8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                    // 6. Delete Button (Allowed if Draft, Paused, Rejected, Archived; Forbidden if Disputed or Sold)
                    if (property.status != ListingStatus.disputed &&
                        property.status != ListingStatus.sold &&
                        property.status != ListingStatus.rented &&
                        property.status != ListingStatus.leased)
                      OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context, property, currentUserId),
                        icon: const Icon(Icons.delete_outline_rounded, size: 13),
                        label: const Text('Delete', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
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

  /// Returns a human-friendly status banner so owners understand the
  /// current lifecycle state of their listing without jargon.
  Widget _buildOwnerStatusBanner(BuildContext context, PropertyEntity property) {
    final isDark = AppDesignSystem.isDark(context);

    Color bgColor;
    Color iconColor;
    Color textColor;
    IconData icon;
    String headline;
    String subtext;

    switch (property.status) {
      case ListingStatus.draft:
        bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        iconColor = const Color(0xFF64748B);
        textColor = const Color(0xFF94A3B8);
        icon = Icons.edit_note_rounded;
        headline = 'Draft — Not Submitted';
        subtext = 'Finish editing and submit to start the review process.';
      case ListingStatus.submitted:
      case ListingStatus.pendingVerification:
      case ListingStatus.underReview:
        bgColor = isDark ? const Color(0xFF1C1400) : const Color(0xFFFFFBEB);
        iconColor = const Color(0xFFD97706);
        textColor = const Color(0xFF92400E);
        icon = Icons.hourglass_top_rounded;
        headline = 'Pending Review';
        subtext = 'Your property has been submitted and is awaiting admin review. It is not visible to the public yet.';
      case ListingStatus.changesRequested:
        bgColor = isDark ? const Color(0xFF1A1200) : const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFB45309);
        textColor = const Color(0xFF78350F);
        icon = Icons.edit_outlined;
        headline = 'Changes Requested';
        subtext = property.verificationNotes?.isNotEmpty == true
            ? 'Admin note: ${property.verificationNotes}'
            : 'Our team has requested changes. Please edit and resubmit.';
      case ListingStatus.published:
      case ListingStatus.active:
      case ListingStatus.approved:
        bgColor = isDark ? const Color(0xFF052E1B) : const Color(0xFFECFDF5);
        iconColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
        icon = Icons.check_circle_outline_rounded;
        headline = 'Live — Publicly Visible';
        subtext = 'Your property is published and visible in public search results.';
      case ListingStatus.paused:
        bgColor = isDark ? const Color(0xFF1C1000) : const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFF92400E);
        icon = Icons.pause_circle_outline_rounded;
        headline = 'On Hold';
        subtext = 'Your listing is temporarily hidden from public search. Resume anytime.';
      case ListingStatus.rejected:
        bgColor = isDark ? const Color(0xFF1F0000) : const Color(0xFFFEF2F2);
        iconColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF991B1B);
        icon = Icons.cancel_outlined;
        headline = 'Not Published — Rejected';
        subtext = property.rejectionReason?.isNotEmpty == true
            ? 'Reason: ${property.rejectionReason}'
            : 'This listing was not approved. Please contact support for details.';
      case ListingStatus.sold:
        bgColor = isDark ? const Color(0xFF0C1B2E) : const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF2563EB);
        textColor = const Color(0xFF1E40AF);
        icon = Icons.handshake_outlined;
        headline = 'Marked as Sold';
        subtext = 'This property has been marked sold and is no longer visible in search.';
      case ListingStatus.archived:
        bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        iconColor = const Color(0xFF64748B);
        textColor = const Color(0xFF475569);
        icon = Icons.archive_outlined;
        headline = 'Archived';
        subtext = 'This listing has been archived. It is not visible to the public.';
      default:
        bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        iconColor = const Color(0xFF64748B);
        textColor = const Color(0xFF475569);
        icon = Icons.info_outline_rounded;
        headline = property.status.humanLabel;
        subtext = 'Contact support for more information about your listing status.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleHoldToggle(
    BuildContext context,
    PropertyEntity property,
    String currentUserId,
  ) async {
    final isOnHold = property.status == ListingStatus.paused;
    final notifier = ref.read(myPropertiesNotifierProvider.notifier);

    final success = isOnHold
        ? await notifier.resumeProperty(authenticatedUserId: currentUserId, propertyId: property.id)
        : await notifier.holdProperty(authenticatedUserId: currentUserId, propertyId: property.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOnHold ? 'Property resumed & published.' : 'Property placed on hold.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: isOnHold ? const Color(0xFF10B981) : Colors.amber.shade800,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(myPropertiesNotifierProvider).errorMessage ?? 'Action could not be performed.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMarkSoldConfirmation(
    BuildContext context,
    PropertyEntity property,
    String currentUserId,
  ) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderCol),
        ),
        title: Text(
          'Mark Property as Sold?',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textP,
          ),
        ),
        content: Text(
          'This will mark your listing as SOLD and remove it from active public search while preserving transaction history.',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 13,
            color: textS,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: textS, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(myPropertiesNotifierProvider.notifier)
                  .updatePropertyStatus(
                    authenticatedUserId: currentUserId,
                    propertyId: property.id,
                    targetStatus: ListingStatus.sold,
                  );

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Property successfully marked as SOLD!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(myPropertiesNotifierProvider).errorMessage ?? 'Failed to update property status.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Mark Sold', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PropertyEntity property,
    String currentUserId,
  ) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderCol),
        ),
        title: Text(
          'Delete Property?',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textP,
          ),
        ),
        content: Text(
          'This property will be removed from your listings.',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 13,
            color: textS,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: textS, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(myPropertiesNotifierProvider.notifier)
                  .deleteProperty(authenticatedUserId: currentUserId, propertyId: property.id);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Property deleted successfully.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(myPropertiesNotifierProvider).errorMessage ?? 'Failed to delete property.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} Lakh';
    }
    return price.toStringAsFixed(0);
  }
}
