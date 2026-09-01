import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/dispute_entities.dart';
import '../providers/dispute_providers.dart';
import '../widgets/dispute_property_image.dart';

/// Clean Single-Purpose Disputed Properties Marketplace View
/// Rules:
/// - Real Dispute Records Only (Zero Fake/Unverified Listings)
/// - "All Categories" marketplace strip REMOVED
/// - Header: Reported Property Disputes + Supporting text
/// - Primary CTA: + List Disputed Property, Secondary: My Disputed Properties
/// - Minimal Compact Filters: Location, Dispute Type, Property Type
/// - Universal DisputePropertyImage with DISPUTED overlay badge
class DisputedPropertiesListView extends ConsumerStatefulWidget {
  const DisputedPropertiesListView({super.key});

  @override
  ConsumerState<DisputedPropertiesListView> createState() =>
      _DisputedPropertiesListViewState();
}

class _DisputedPropertiesListViewState
    extends ConsumerState<DisputedPropertiesListView> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _localities = [
    'All Localities',
    'Tilakwadi',
    'Camp',
    'Khanapur Road',
    'Shahapur',
    'Hindwadi',
    'Udyambag',
    'Vadgaon',
    'Sambra',
    'Angol',
    'Ramanagar',
    'Bhagya Nagar',
    'Kuvempu Nagar',
    'Mandoli Road',
  ];

  static const List<String> _propertyTypes = [
    'All Property Types',
    'House',
    'Apartment / Flat',
    'Villa',
    'Plot',
    'Open Land',
    'Agricultural Land',
    'Commercial',
    'Shop',
    'Office',
    'Warehouse',
    'Industrial',
    'Building',
    'Other',
  ];

  String _selectedPropertyType = 'All Property Types';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddDispute(BuildContext context) {
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
    if (isLoggedIn) {
      context.push(AppRoutes.addDispute);
    } else {
      context.push(
        '/auth?redirect=${Uri.encodeComponent(AppRoutes.addDispute)}',
      );
    }
  }

  void _navigateToMyDisputes(BuildContext context) {
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
    if (isLoggedIn) {
      context.push(AppRoutes.myDisputedProperties);
    } else {
      context.push(
        '/auth?redirect=${Uri.encodeComponent(AppRoutes.myDisputedProperties)}',
      );
    }
  }

  void _showFilterModal(BuildContext context) {
    final state = ref.read(disputedPropertiesNotifierProvider);
    final notifier = ref.read(disputedPropertiesNotifierProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppDesignSystem.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Dispute Records',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppDesignSystem.textP(ctx),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppDesignSystem.textS(ctx),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Property Type Filter
                Text(
                  'Property Type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppDesignSystem.textS(ctx),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPropertyType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _propertyTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t, style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPropertyType = val);
                      setModalState(() => _selectedPropertyType = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Reset & Apply Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(
                            () => _selectedPropertyType = 'All Property Types',
                          );
                          notifier.setLocality('All Localities');
                          notifier.setCategory(null);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.brandGold,
                          foregroundColor: const Color(0xFF0F172A),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(disputedPropertiesNotifierProvider);
    final notifier = ref.read(disputedPropertiesNotifierProvider.notifier);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    // Apply client-side property type filter if selected
    var disputes = state.disputes;
    if (_selectedPropertyType != 'All Property Types') {
      disputes = disputes
          .where(
            (d) =>
                d.propertyType.toLowerCase() ==
                    _selectedPropertyType.toLowerCase() ||
                d.category.toLowerCase() == _selectedPropertyType.toLowerCase(),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Reported Property Disputes',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: textP,
          ),
        ),
        backgroundColor: surfaceBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'My Disputed Properties',
            icon: const Icon(
              Icons.folder_shared_outlined,
              color: AppDesignSystem.brandGold,
            ),
            onPressed: () => _navigateToMyDisputes(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner & Action CTAs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
                boxShadow: AppDesignSystem.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFDC2626,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFFDC2626),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reported Property Disputes',
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textP,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Browse property records that have a reported dispute associated with them.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: textS,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Primary CTA
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToAddDispute(context),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('List Disputed Property'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppDesignSystem.brandGold,
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Secondary Action
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateToMyDisputes(context),
                          icon: const Icon(Icons.folder_open_rounded, size: 16),
                          label: const Text('My Disputed Properties'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textP,
                            side: BorderSide(color: borderCol),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 11,
                            ),
                            textStyle: const TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Search Field
            TextField(
              controller: _searchController,
              onChanged: (val) => notifier.setSearchQuery(val),
              style: TextStyle(fontSize: 13, color: textP),
              decoration: InputDecoration(
                hintText: 'Search locality, survey no, case no...',
                hintStyle: TextStyle(fontSize: 12, color: textS),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppDesignSystem.brandGold,
                ),
                filled: true,
                fillColor: AppDesignSystem.inputBg(context),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderCol),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderCol),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppDesignSystem.brandGold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Locality Dropdown + Filter Button
            Row(
              children: [
                Expanded(
                  child: PopupMenuButton<String>(
                    initialValue: state.selectedLocality,
                    onSelected: (val) => notifier.setLocality(val),
                    color: surfaceBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (ctx) => _localities
                        .map(
                          (loc) => PopupMenuItem(
                            value: loc,
                            child: Text(
                              loc,
                              style: TextStyle(fontSize: 12, color: textP),
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.inputBg(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              state.selectedLocality,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textP,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, size: 18, color: textS),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Compact Filter Button
                GestureDetector(
                  onTap: () => _showFilterModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.inputBg(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedPropertyType != 'All Property Types'
                            ? AppDesignSystem.brandGold
                            : borderCol,
                        width: _selectedPropertyType != 'All Property Types'
                            ? 1.5
                            : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: _selectedPropertyType != 'All Property Types'
                              ? AppDesignSystem.brandGold
                              : textS,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedPropertyType != 'All Property Types'
                                ? AppDesignSystem.brandGold
                                : textP,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. Real Disputed Property Listing Feed / Clean Empty State
            if (state.isLoading && state.disputes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              )
            else if (disputes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 36,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No disputed property records found.',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textP,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All clear! Or be the first to report an active property dispute.',
                        style: TextStyle(fontSize: 12, color: textS),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToAddDispute(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('List Disputed Property'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.brandGold,
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...disputes.map(
                (dispute) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DisputeListingCard(dispute: dispute),
                ),
              ),

            const SizedBox(height: 20),

            // 4. Compact Informational Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol.withValues(alpha: 0.6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: textS),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Information on this page is submitted by users or publishers. Belagavi Property does not determine ownership, title validity, liability, or the merits of a dispute.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: textS,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _DisputeListingCard extends StatelessWidget {
  final PropertyDisputeEntity dispute;

  const _DisputeListingCard({required this.dispute});

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    final coverPhoto = dispute.photoUrls.isNotEmpty
        ? dispute.photoUrls.first
        : null;

    return GestureDetector(
      onTap: () => context.push('/disputed-properties/${dispute.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1.1),
          boxShadow: AppDesignSystem.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Persistent DISPUTED Overlay Badge
            DisputePropertyImage(
              imageUrl: coverPhoto,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Type + Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppDesignSystem.brandGold.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dispute.propertyType.isNotEmpty
                              ? dispute.propertyType
                              : dispute.category,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppDesignSystem.brandGold,
                          ),
                        ),
                      ),
                      if (dispute.reportDate != null)
                        Text(
                          _formatDate(dispute.reportDate!),
                          style: TextStyle(fontSize: 10, color: textS),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    dispute.title,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textP,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: textS),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${dispute.locality}, ${dispute.city}',
                          style: TextStyle(fontSize: 11, color: textS),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Reported Issue & Survey/Case Number
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.inputBg(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderCol.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.report_problem_outlined,
                              size: 13,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dispute.disputeType.displayName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFDC2626),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if ((dispute.surveyCtsNumber != null &&
                                dispute.surveyCtsNumber!.isNotEmpty) ||
                            dispute.caseNumber != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (dispute.surveyCtsNumber != null &&
                                  dispute.surveyCtsNumber!.isNotEmpty)
                                'Survey/CTS: ${dispute.surveyCtsNumber}',
                              if (dispute.caseNumber != null &&
                                  dispute.caseNumber!.isNotEmpty)
                                'Case: ${dispute.caseNumber}',
                            ].join(' • '),
                            style: TextStyle(fontSize: 10.5, color: textS),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Status Chip & Documents Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          dispute.verificationStatus.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                      if (dispute.hasDocuments ||
                          dispute.documentUrls.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.attachment_rounded,
                              size: 13,
                              color: textS,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${dispute.documentUrls.isNotEmpty ? dispute.documentUrls.length : 1} Doc(s)',
                              style: TextStyle(fontSize: 10.5, color: textS),
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
      ),
    );
  }
}
