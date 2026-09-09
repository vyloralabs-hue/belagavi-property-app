import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../../../features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/legal_notice_entities.dart';
import '../providers/legal_notice_providers.dart';

/// Clean Single-Purpose Property Legal Notices Marketplace View
/// Fixes blank white screen and provides:
/// 1. Top Header with Title, Subtitle, Info modal & "+ Record Property Legal Notice" CTA
/// 2. Two Primary Tabs: "Public Notices" and "My Notices"
/// 3. Search Bar + Locality filter + Horizontal Notice Type Filter Chips
/// 4. Live remote listing cards with neutral badges, privacy masking, and full detail navigation
/// 5. Full Light & Dark theme support via AppDesignSystem
class LegalNoticeHubView extends ConsumerStatefulWidget {
  const LegalNoticeHubView({super.key});

  @override
  ConsumerState<LegalNoticeHubView> createState() => _LegalNoticeHubViewState();
}

class _LegalNoticeHubViewState extends ConsumerState<LegalNoticeHubView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  int _myNoticeSubTabIndex = 0; // 0: Active, 1: Expired/History, 2: Drafts
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

  static const List<({String label, LegalNoticeType? type})> _filterTypes = [
    (label: 'All', type: null),
    (label: 'Proposed Purchase', type: LegalNoticeType.purchaseNotice),
    (label: 'Proposed Sale', type: LegalNoticeType.saleNotice),
    (label: 'Public Notice', type: LegalNoticeType.publicNoticeBeforePurchase),
    (label: 'Title Verification', type: LegalNoticeType.titleVerificationNotice),
    (label: 'Objection / Caveat', type: LegalNoticeType.objectionNotice),
    (label: 'Possession Notice', type: LegalNoticeType.possessionNotice),
    (label: 'Agreement Notice', type: LegalNoticeType.agreementNotice),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddNotice(BuildContext context) {
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
    if (isLoggedIn) {
      context.push(AppRoutes.addLegalNotice);
    } else {
      context.push(
        '/auth?redirect=${Uri.encodeComponent(AppRoutes.addLegalNotice)}',
      );
    }
  }

  String _getCurrentUserId() {
    String userId = AuthSessionStorageHelper.getUserUid() ?? '';
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) {
        userId = fbUid;
      }
    } catch (_) {}
    return userId;
  }

  void _showDueDiligenceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDesignSystem.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppDesignSystem.borderCol(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Legal Due Diligence Guides',
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
              ),
              TabBar(
                labelColor: AppDesignSystem.brandGold,
                unselectedLabelColor: AppDesignSystem.textS(ctx),
                indicatorColor: AppDesignSystem.brandGold,
                indicatorWeight: 2.5,
                tabs: const [
                  Tab(text: 'Buyer Due Diligence'),
                  Tab(text: 'Seller Compliance'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: LegalNoticeRepositoryData.buyerChecklist.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final item = LegalNoticeRepositoryData.buyerChecklist[i];
                        return _buildChecklistTile(ctx, item, isBuyer: true);
                      },
                    ),
                    ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: LegalNoticeRepositoryData.sellerChecklist.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final item = LegalNoticeRepositoryData.sellerChecklist[i];
                        return _buildChecklistTile(ctx, item, isBuyer: false);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistTile(
    BuildContext context,
    DueDiligenceItemEntity item, {
    required bool isBuyer,
  }) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBuyer ? Icons.fact_check_outlined : Icons.verified_user_outlined,
                size: 18,
                color: isBuyer ? const Color(0xFF0284C7) : const Color(0xFF16A34A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textP,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: TextStyle(fontSize: 11.5, color: textS, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            'Required: ${item.requiredDocument}',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppDesignSystem.brandGold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachModal(TransactionLegalNoticeEntity notice) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDesignSystem.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 18,
          right: 18,
          top: 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attach Supporting Document',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textP(ctx),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add deed scan, paper notice publication clipping, or agreement for "${notice.title}".',
              style: TextStyle(
                fontSize: 11.5,
                color: AppDesignSystem.textS(ctx),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: TextStyle(color: AppDesignSystem.textP(ctx), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Sale_Agreement_Form15.pdf or image scan URL',
                hintStyle: TextStyle(color: AppDesignSystem.textS(ctx), fontSize: 12),
                filled: true,
                fillColor: AppDesignSystem.inputBg(ctx),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppDesignSystem.borderCol(ctx)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    final currentUserId = _getCurrentUserId();
                    final repo = ref.read(legalNoticeRepositoryProvider);
                    await repo.attachDocuments(
                      notice.id,
                      newDocuments: [controller.text.trim()],
                      authenticatedUserId: currentUserId.isNotEmpty ? currentUserId : 'usr_current',
                    );
                    ref.read(legalNoticesNotifierProvider.notifier).loadNotices();
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                icon: const Icon(Icons.attach_file_rounded, size: 16),
                label: const Text('Save & Attach Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.brandGold,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noticesState = ref.watch(legalNoticesNotifierProvider);
    final notifier = ref.read(legalNoticesNotifierProvider.notifier);

    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final currentUserId = _getCurrentUserId();
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Property Legal Notices',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            color: textP,
          ),
        ),
        backgroundColor: surfaceBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            tooltip: 'Due Diligence Guides',
            icon: Icon(Icons.info_outline_rounded, color: textP, size: 22),
            onPressed: () => _showDueDiligenceModal(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: surfaceBg,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              labelColor: AppDesignSystem.isDark(context)
                  ? AppDesignSystem.brandGold
                  : AppDesignSystem.primaryNavy,
              unselectedLabelColor: textS,
              indicatorColor: AppDesignSystem.brandGold,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Public Notices'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_shared_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('My Notices'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _currentTabIndex == 0
          ? _buildPublicNoticesTab(
              context: context,
              state: noticesState,
              notifier: notifier,
              surfaceBg: surfaceBg,
              borderCol: borderCol,
              textP: textP,
              textS: textS,
            )
          : _buildMyNoticesTab(
              context: context,
              state: noticesState,
              isLoggedIn: isLoggedIn,
              currentUserId: currentUserId,
              surfaceBg: surfaceBg,
              borderCol: borderCol,
              textP: textP,
              textS: textS,
            ),
    );
  }

  Widget _buildPublicNoticesTab({
    required BuildContext context,
    required LegalNoticesState state,
    required LegalNoticesNotifier notifier,
    required Color surfaceBg,
    required Color borderCol,
    required Color textP,
    required Color textS,
  }) {
    return RefreshIndicator(
      onRefresh: () async => notifier.loadNotices(),
      color: AppDesignSystem.brandGold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Banner with Primary CTA
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
                          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.gavel_rounded,
                          color: Color(0xFF0284C7),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Property Legal Notices',
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textP,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'View published legal notices, caveat disclosures, and record public property notices.',
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToAddNotice(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Record Property Legal Notice'),
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
                hintText: 'Search notice, area, survey no. or reference...',
                hintStyle: TextStyle(fontSize: 12, color: textS),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppDesignSystem.brandGold,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      )
                    : null,
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

            // 3. Locality Selector
            PopupMenuButton<String>(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppDesignSystem.inputBg(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_city_rounded,
                          size: 16,
                          color: AppDesignSystem.brandGold,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.selectedLocality,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textP,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_drop_down, size: 18, color: textS),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 4. Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterTypes.map((item) {
                  final isSelected = state.selectedType == item.type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : textP,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppDesignSystem.brandGold,
                      backgroundColor: AppDesignSystem.inputBg(context),
                      side: BorderSide(
                        color: isSelected ? AppDesignSystem.brandGold : borderCol,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: (_) => notifier.setNoticeType(item.type),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 5. Notice Listing Feed / Loading / Empty State
            if (state.isLoading && state.notices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              )
            else if (state.errorMessage != null && state.notices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load legal notices',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textP,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: textS),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => notifier.loadNotices(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.brandGold,
                          foregroundColor: const Color(0xFF0F172A),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (state.notices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Container(
                  width: double.infinity,
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
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.article_outlined,
                          size: 36,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No Public Legal Notices Found',
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
                        'No active public notices match your search or filter. Record a property purchase, sale, or caveat notice below.',
                        style: TextStyle(fontSize: 12, color: textS),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToAddNotice(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Record Property Legal Notice'),
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
                          textStyle: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...state.notices.map(
                (notice) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLegalNoticeCard(
                    context: context,
                    notice: notice,
                    isOwner: false,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 6. Statutory Disclaimer Banner
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
                      'Notices displayed here are records published through the platform. Publication does not by itself constitute court validation, title certification, legal advice, or proof of service.',
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

  Widget _buildMyNoticesTab({
    required BuildContext context,
    required LegalNoticesState state,
    required bool isLoggedIn,
    required String currentUserId,
    required Color surfaceBg,
    required Color borderCol,
    required Color textP,
    required Color textS,
  }) {
    if (!isLoggedIn) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
            boxShadow: AppDesignSystem.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 38,
                  color: AppDesignSystem.brandGold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sign In Required',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textP,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please sign in to view and manage your recorded property legal notices, track review status, or attach supporting documents.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textS, height: 1.35),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => context.push(
                  '/auth?redirect=${Uri.encodeComponent(AppRoutes.legalNotices)}',
                ),
                icon: const Icon(Icons.login_rounded, size: 16),
                label: const Text('Sign In to Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.brandGold,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final allMyNotices = state.notices.where((n) {
      if (currentUserId.isEmpty) return false;
      return n.recordedBy == currentUserId ||
          n.recordedBy.toLowerCase() == currentUserId.toLowerCase() ||
          n.recordedBy == 'usr_current';
    }).toList();

    // Partition into 3 distinct tabs:
    // Tab 0: ACTIVE (published with active public visibility window, or underReview/submitted)
    // Tab 1: EXPIRED / HISTORY (isExpiredFromPublicView, closed, withdrawn, or rejected)
    // Tab 2: DRAFTS (draft)
    final activeNotices = allMyNotices.where((n) {
      if (n.verificationStatus == LegalNoticeStatus.draft) return false;
      if (n.verificationStatus == LegalNoticeStatus.closed ||
          n.verificationStatus == LegalNoticeStatus.withdrawn ||
          n.verificationStatus == LegalNoticeStatus.archived ||
          n.verificationStatus == LegalNoticeStatus.rejected) {
        return false;
      }
      if (n.isExpiredFromPublicView) return false;
      return true;
    }).toList();

    final expiredHistoryNotices = allMyNotices.where((n) {
      if (n.verificationStatus == LegalNoticeStatus.draft) return false;
      if (n.verificationStatus == LegalNoticeStatus.closed ||
          n.verificationStatus == LegalNoticeStatus.withdrawn ||
          n.verificationStatus == LegalNoticeStatus.archived ||
          n.verificationStatus == LegalNoticeStatus.rejected) {
        return true;
      }
      return n.isExpiredFromPublicView;
    }).toList();

    final draftNotices = allMyNotices.where((n) {
      return n.verificationStatus == LegalNoticeStatus.draft;
    }).toList();

    final currentDisplayList = switch (_myNoticeSubTabIndex) {
      1 => expiredHistoryNotices,
      2 => draftNotices,
      _ => activeNotices,
    };

    return RefreshIndicator(
      onRefresh: () async => ref.read(legalNoticesNotifierProvider.notifier).loadNotices(),
      color: AppDesignSystem.brandGold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Notices History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textP,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddNotice(context),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Record New Notice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3-Segment Filter Selector for My Notices
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppDesignSystem.inputBg(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  _buildSubTabButton(
                    context: context,
                    title: 'Active (${activeNotices.length})',
                    isSelected: _myNoticeSubTabIndex == 0,
                    onTap: () => setState(() => _myNoticeSubTabIndex = 0),
                  ),
                  _buildSubTabButton(
                    context: context,
                    title: 'Expired / History (${expiredHistoryNotices.length})',
                    isSelected: _myNoticeSubTabIndex == 1,
                    onTap: () => setState(() => _myNoticeSubTabIndex = 1),
                  ),
                  _buildSubTabButton(
                    context: context,
                    title: 'Drafts (${draftNotices.length})',
                    isSelected: _myNoticeSubTabIndex == 2,
                    onTap: () => setState(() => _myNoticeSubTabIndex = 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (currentDisplayList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Container(
                  width: double.infinity,
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
                          color: AppDesignSystem.brandGold.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _myNoticeSubTabIndex == 0
                              ? Icons.public_rounded
                              : (_myNoticeSubTabIndex == 1
                                  ? Icons.history_edu_rounded
                                  : Icons.edit_note_rounded),
                          size: 36,
                          color: AppDesignSystem.brandGold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _myNoticeSubTabIndex == 0
                            ? 'No Active Public Notices'
                            : (_myNoticeSubTabIndex == 1
                                ? 'No Expired or Historical Notices'
                                : 'No Notice Drafts'),
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
                        _myNoticeSubTabIndex == 0
                            ? 'You have no live notices currently active in the public 10-day window.'
                            : (_myNoticeSubTabIndex == 1
                                ? 'Notices that complete their 10-day public cycle remain permanently preserved here in your private history.'
                                : 'You do not have any unfinished notice drafts.'),
                        style: TextStyle(fontSize: 12, color: textS),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToAddNotice(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Record Property Legal Notice'),
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
                          textStyle: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...currentDisplayList.map(
                (notice) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLegalNoticeCard(
                    context: context,
                    notice: notice,
                    isOwner: true,
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (AppDesignSystem.isDark(context)
                    ? AppDesignSystem.primaryNavy
                    : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? AppDesignSystem.softShadow : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (AppDesignSystem.isDark(context)
                      ? AppDesignSystem.brandGold
                      : AppDesignSystem.primaryNavy)
                  : AppDesignSystem.textS(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalNoticeCard({
    required BuildContext context,
    required TransactionLegalNoticeEntity notice,
    required bool isOwner,
  }) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    final statusText = notice.verificationStatus.displayName;
    final noticeTypeColor = notice.noticeType.accentColor;
    final isPubliclyActive = notice.isPubliclyActive;
    final isExpired = notice.isExpiredFromPublicView;
    final remainingDays = notice.remainingPublicDays;

    return InkWell(
      onTap: () => context.push('/legal-notice/${notice.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderCol),
          boxShadow: AppDesignSystem.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Badges: Neutral Status / Expiry Badge + Notice Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Lifecycle / Expiry Badge
                    if (isPubliclyActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.public_rounded, size: 11, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              'Public • $remainingDays ${remainingDays == 1 ? 'day' : 'days'} remaining',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64748B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_clock_rounded, size: 11, color: Color(0xFF64748B)),
                            SizedBox(width: 4),
                            Text(
                              'Expired from Public View',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Verification / Review Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.inputBg(context),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderCol),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: notice.verificationStatus == LegalNoticeStatus.published
                                  ? const Color(0xFF16A34A)
                                  : AppDesignSystem.brandGold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: textP,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: noticeTypeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(notice.noticeType.icon, size: 12, color: noticeTypeColor),
                      const SizedBox(width: 4),
                      Text(
                        notice.noticeType.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: noticeTypeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. Title
            Text(
              notice.title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: textP,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),

            // 3. Location & Property Identifiers
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppDesignSystem.brandGold,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${notice.locality}, ${notice.city}${notice.surveyCtsNumber != null && notice.surveyCtsNumber!.isNotEmpty ? ' • CTS: ${notice.surveyCtsNumber}' : ''}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textS,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // 4. Primary Parties (if available)
            if (notice.buyerName.isNotEmpty || notice.sellerName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppDesignSystem.inputBg(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderCol.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    if (notice.buyerName.isNotEmpty) ...[
                      const Icon(Icons.person_outline, size: 13, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Buyer: ${notice.buyerName}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0284C7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (notice.buyerName.isNotEmpty && notice.sellerName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('|', style: TextStyle(color: borderCol)),
                      ),
                    if (notice.sellerName.isNotEmpty) ...[
                      const Icon(Icons.storefront_outlined, size: 13, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Seller: ${notice.sellerName}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // 5. Reference & Issuing Authority
            if (notice.referenceNumber != null && notice.referenceNumber!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Ref: ${notice.referenceNumber}${notice.issuingAuthority != null ? ' • ${notice.issuingAuthority}' : ''}',
                style: TextStyle(fontSize: 10.5, color: textS),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // 6. Dates (Notice date & Objection deadline)
            if (notice.noticeDate != null || notice.responseDeadline != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (notice.noticeDate != null) ...[
                    Icon(Icons.calendar_today_outlined, size: 11, color: textS),
                    const SizedBox(width: 3),
                    Text(
                      'Dated: ${notice.noticeDate}',
                      style: TextStyle(fontSize: 10.5, color: textS),
                    ),
                  ],
                  if (notice.noticeDate != null && notice.responseDeadline != null)
                    const SizedBox(width: 10),
                  if (notice.responseDeadline != null) ...[
                    const Icon(Icons.timer_outlined, size: 11, color: Color(0xFFDC2626)),
                    const SizedBox(width: 3),
                    Text(
                      'Deadline: ${notice.responseDeadline}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 10),
            Divider(height: 1, color: borderCol),
            const SizedBox(height: 10),

            // 7. Footer: Documents indicator + Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      notice.documentUrls.isNotEmpty
                          ? '📄 ${notice.documentUrls.length} Document(s) Attached'
                          : '📄 Notice Document Scan',
                      style: TextStyle(fontSize: 11, color: textS),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => context.push('/legal-notice/${notice.id}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textP,
                        side: BorderSide(color: borderCol),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View Notice →'),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/legal-notice/edit/${notice.id}',
                          extra: notice,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 12),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textP,
                          side: BorderSide(color: borderCol),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        onPressed: () => _showAttachModal(notice),
                        icon: const Icon(Icons.attach_file, size: 12),
                        label: const Text('Add Docs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textP,
                          side: BorderSide(color: borderCol),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
