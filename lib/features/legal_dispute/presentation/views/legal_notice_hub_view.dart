import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../../../features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/legal_notice_entities.dart';
import '../providers/legal_notice_providers.dart';

class LegalNoticeHubView extends ConsumerStatefulWidget {
  const LegalNoticeHubView({super.key});

  @override
  ConsumerState<LegalNoticeHubView> createState() => _LegalNoticeHubViewState();
}

class _LegalNoticeHubViewState extends ConsumerState<LegalNoticeHubView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noticesState = ref.watch(legalNoticesNotifierProvider);
    final userMattersState = ref.watch(legalMattersDashboardNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Legal Notice & Dispute Hub',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
              if (isLoggedIn) {
                context.push('/legal-notice/add');
              } else {
                context.push(
                  '/auth?redirect=${Uri.encodeComponent(AppRoutes.addLegalNotice)}',
                );
              }
            },
            icon: const Icon(Icons.gavel_outlined, size: 14),
            label: const Text('+ Start Notice / Dispute'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppDesignSystem.primaryNavy,
          unselectedLabelColor: AppDesignSystem.textSecondary,
          indicatorColor: AppDesignSystem.primaryNavy,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          tabs: const [
            Tab(text: 'Dispute Matters'),
            Tab(text: 'Public Notices'),
            Tab(text: 'Buyer Due Diligence'),
            Tab(text: 'Seller Compliance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDisputeMattersTab(userMattersState),
          _buildRecordedNoticesTab(noticesState),
          _buildBuyerTab(),
          _buildSellerTab(),
        ],
      ),
    );
  }

  Widget _buildDisputeMattersTab(LegalMattersDashboardState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF1E40AF), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legal Notice & Dispute Assistance Engine',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Draft statutory notices under TPA 106, Specific Relief, or RERA. Track RPAD service evidence & version history.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Legal Matters',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppDesignSystem.primaryNavy,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push('/legal-notice/add'),
                icon: const Icon(Icons.add, size: 14),
                label: const Text(
                  'New Dispute Wizard',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.matters.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    Icons.gavel_outlined,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Active Dispute Matters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Start a 16-step guided wizard for tenancy default, agreement default, deposit refund, or builder delay notice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/legal-notice/add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start Guided Dispute Wizard'),
                  ),
                ],
              ),
            )
          else
            ...state.matters.map((matter) => _buildMatterCard(matter)),
          const SizedBox(height: 24),
          _buildStatutoryDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildMatterCard(LegalMatterEntity matter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: matter.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  matter.status.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: matter.status.color,
                  ),
                ),
              ),
              Text(
                matter.matterReference,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            matter.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Category: ${matter.category} • Locality: ${matter.locality}',
            style: const TextStyle(
              fontSize: 11,
              color: AppDesignSystem.textSecondary,
            ),
          ),
          if (matter.financialClaimAmount > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Claim Amount: ₹ ${matter.financialClaimAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB39037),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Versions: ${matter.versionHistory.length} draft(s)',
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
              TextButton.icon(
                onPressed: () => context.push('/legal-notice/add'),
                icon: const Icon(Icons.arrow_forward, size: 12),
                label: const Text(
                  'Open Matter Details',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordedNoticesTab(LegalNoticesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (q) => ref
                      .read(legalNoticesNotifierProvider.notifier)
                      .setSearchQuery(q),
                  decoration: InputDecoration(
                    hintText: 'Search notices, party names, CTS No...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.notices.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Legal Notices Found',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Record a new property purchase, sale agreement, or public caveat notice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/legal-notice/add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('+ Record Transaction / Legal Notice'),
                  ),
                ],
              ),
            )
          else
            ...state.notices.map((notice) => _buildNoticeCard(notice)),
          const SizedBox(height: 24),
          _buildStatutoryDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(TransactionLegalNoticeEntity notice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: notice.noticeType.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  notice.noticeType.title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: notice.noticeType.accentColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  notice.transactionType,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notice.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppDesignSystem.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${notice.locality}, Belagavi ${notice.surveyCtsNumber != null ? 'â€¢ ${notice.surveyCtsNumber}' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
          if (notice.buyerName.isNotEmpty || notice.sellerName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (notice.buyerName.isNotEmpty) ...[
                    const Icon(
                      Icons.person_outline,
                      size: 13,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Buyer: ${notice.buyerName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0284C7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (notice.buyerName.isNotEmpty &&
                      notice.sellerName.isNotEmpty)
                    const Text(
                      '  |  ',
                      style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
                    ),
                  if (notice.sellerName.isNotEmpty) ...[
                    const Icon(
                      Icons.storefront,
                      size: 13,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Seller: ${notice.sellerName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (notice.referenceNumber != null) ...[
            const SizedBox(height: 6),
            Text(
              'Ref: ${notice.referenceNumber} â€¢ ${notice.issuingAuthority ?? ''}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notice.documentUrls.isNotEmpty
                    ? '🔒 ${notice.documentUrls.length} Private Docs'
                    : '📄 Notice Recorded',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => context.push('/legal-notice/${notice.id}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('View Notice →'),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: () => _showAttachModal(notice),
                    icon: const Icon(Icons.attach_file, size: 12),
                    label: const Text('Add Docs'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attach Supporting Documents',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Add agreements or deeds to "${notice.title}".',
              style: const TextStyle(
                fontSize: 11,
                color: AppDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. Sale_Agreement_Form15.pdf',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    final repo = ref.read(legalNoticeRepositoryProvider);
                    await repo.attachDocuments(
                      notice.id,
                      newDocuments: [controller.text.trim()],
                      authenticatedUserId: 'usr_current',
                    );
                    ref
                        .read(legalNoticesNotifierProvider.notifier)
                        .loadNotices();
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save & Attach Document'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'BUYER DUE DILIGENCE CHECKLIST',
            subtitle:
                'Essential 13-point legal and documentary verification roadmap before purchasing real estate in Belagavi / Karnataka.',
            icon: Icons.checklist_rtl_rounded,
            color: const Color(0xFF0284C7),
          ),
          const SizedBox(height: 16),
          ...LegalNoticeRepositoryData.buyerChecklist.map(
            (item) => _buildChecklistCard(item, isBuyer: true),
          ),
          const SizedBox(height: 20),
          _buildStatutoryDisclaimer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSellerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'SELLER LEGAL COMPLIANCE CHECKLIST',
            subtitle:
                'Recommended statutory documentation required for property owners and vendors before executing sale agreements.',
            icon: Icons.verified_user_outlined,
            color: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 16),
          ...LegalNoticeRepositoryData.sellerChecklist.map(
            (item) => _buildChecklistCard(item, isBuyer: false),
          ),
          const SizedBox(height: 20),
          _buildStatutoryDisclaimer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(
    DueDiligenceItemEntity item, {
    required bool isBuyer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isBuyer
                      ? const Color(0xFFE0F2FE)
                      : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBuyer ? Icons.check_circle_outline : Icons.task_alt,
                  size: 16,
                  color: isBuyer
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 11,
              color: AppDesignSystem.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Required: ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              Expanded(
                child: Text(
                  item.requiredDocument,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Statutory Due Diligence Notice: Belagavi Property LLP provides regulatory information for transparency. Official title search must be executed by an enrolled advocate.',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
