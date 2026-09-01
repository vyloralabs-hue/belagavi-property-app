import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart'
    show PropertyCategory;
import '../../domain/entities/property_document_entity.dart';
import '../providers/property_document_notifier.dart';
import '../widgets/secure_document_viewer_modal.dart';

extension PropertyCategoryDiligenceExtension on PropertyCategory {
  String get diligenceDisplayName => switch (this) {
    PropertyCategory.residential => 'Residential Housing',
    PropertyCategory.plotLand => 'Plot / Land',
    PropertyCategory.commercial => 'Commercial Space',
    PropertyCategory.industrial => 'Industrial Property',
    PropertyCategory.land => 'Raw Land / Agricultural',
    PropertyCategory.builderProject => 'Builder Project',
    PropertyCategory.other => 'Property',
  };
}

class PropertyDueDiligenceView extends ConsumerStatefulWidget {
  final String propertyId;
  final PropertyCategory category;
  final String propertyTitle;
  final bool isDisputed;

  const PropertyDueDiligenceView({
    super.key,
    required this.propertyId,
    this.category = PropertyCategory.residential,
    this.propertyTitle = 'Property Listing',
    this.isDisputed = false,
  });

  @override
  ConsumerState<PropertyDueDiligenceView> createState() =>
      _PropertyDueDiligenceViewState();
}

class _PropertyDueDiligenceViewState
    extends ConsumerState<PropertyDueDiligenceView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(propertyDocumentNotifierProvider.notifier)
          .loadPropertyDocuments(widget.propertyId, category: widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyDocumentNotifierProvider);
    final checklist = state.dueDiligenceChecklist;
    final docs = state.documents;

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Property Due Diligence Hub',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Card ───
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // ─── Disputed Caution Alert (if flagged) ───
            if (widget.isDisputed) ...[
              _buildDisputeAlert(),
              const SizedBox(height: 16),
            ],

            // ─── Legal Notice & Statutory Guidelines Link ───
            _buildLegalNoticeBanner(context),
            const SizedBox(height: 16),

            // ─── Available Legal Documents & Access Gate ───
            _buildAvailableDocumentsSection(context, docs),
            const SizedBox(height: 20),

            // ─── 10-Point Due Diligence Interactive Checklist ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due Diligence Checkpoints (${checklist.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                Text(
                  '${checklist.where((c) => c.status == DueDiligenceCheckStatus.reviewed).length}/${checklist.length} Completed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...checklist.map((item) => _buildChecklistItem(context, item)),
            const SizedBox(height: 24),

            // ─── Platform Due Diligence Disclaimer ───
            _buildDisclaimerBox(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(
          color: const Color(0xFFB39037).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39037).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.category.diligenceDisplayName.toUpperCase()} DUE DILIGENCE',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB39037),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '10-Step Scrutiny',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.propertyTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFDFCF4),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Follow this structured verification workflow before executing any financial agreement or earnest token payment.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeAlert() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_rounded, color: Color(0xFFB91C1C), size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISPUTE WARNING ON RECORD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'This property has reported ownership litigation or title objections. Legal clearance must be verified through official court records and title advocate before proceeding.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7F1D1D),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalNoticeBanner(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/legal-notices'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: Color(0xFF15803D), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Karnataka Property Purchase Legal Checklist',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                  Text(
                    'Read 13 mandatory buyer due diligence points before registration',
                    style: TextStyle(fontSize: 10, color: Color(0xFF15803D)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFF166534),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDocumentsSection(
    BuildContext context,
    List<PropertyDocumentEntity> docs,
  ) {
    const currentUserId = 'usr_buyer_1';
    const ownerId = 'owner_1';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seller Uploaded Documents (${docs.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 12, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Restricted Access',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          if (docs.isEmpty)
            const Text(
              'No legal documents uploaded yet by seller. You can request documents during negotiation.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          else
            ...docs.map((doc) {
              final isUnlocked = doc.canUserAccess(currentUserId, ownerId);
              final isRequested = doc.accessRequests.any(
                (r) => r.buyerId == currentUserId && !r.isGranted,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUnlocked
                        ? const Color(0xFFBBF7D0)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                      size: 16,
                      color: isUnlocked ? const Color(0xFF15803D) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.documentType.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? const Color(0xFF166534)
                                  : AppDesignSystem.textPrimary,
                            ),
                          ),
                          Text(
                            isUnlocked
                                ? 'Access Granted • Ready for inspection'
                                : (isRequested
                                      ? 'Access Request Pending with Seller'
                                      : 'Private File • Request access to inspect'),
                            style: TextStyle(
                              fontSize: 10,
                              color: isUnlocked
                                  ? const Color(0xFF15803D)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      ElevatedButton(
                        onPressed: () {
                          SecureDocumentViewerModal.show(
                            context: context,
                            document: doc,
                            currentUserId: currentUserId,
                            propertyOwnerId: ownerId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          minimumSize: const Size(60, 32),
                        ),
                        child: const Text('View'),
                      )
                    else if (isRequested)
                      OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: const Size(60, 32),
                        ),
                        child: const Text(
                          'Requested',
                          style: TextStyle(fontSize: 10),
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: () {
                          ref
                              .read(propertyDocumentNotifierProvider.notifier)
                              .requestDocumentAccess(
                                propertyId: widget.propertyId,
                                documentId: doc.id,
                                buyerId: currentUserId,
                                buyerName: 'Rahul Deshmukh',
                                buyerPhone: '+91 98450 12345',
                                category: widget.category,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✓ Document access requested from seller!',
                              ),
                              backgroundColor: Color(0xFF0284C7),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          minimumSize: const Size(60, 32),
                        ),
                        child: const Text('Request'),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(BuildContext context, DueDiligenceCheckItem item) {
    final statusColor = switch (item.status) {
      DueDiligenceCheckStatus.reviewed => const Color(0xFF15803D),
      DueDiligenceCheckStatus.issueFound => const Color(0xFFB91C1C),
      DueDiligenceCheckStatus.pending => const Color(0xFFD97706),
    };

    final statusBg = switch (item.status) {
      DueDiligenceCheckStatus.reviewed => const Color(0xFFDCFCE7),
      DueDiligenceCheckStatus.issueFound => const Color(0xFFFEE2E2),
      DueDiligenceCheckStatus.pending => const Color(0xFFFEF3C7),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.status.displayName,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 11,
                color: AppDesignSystem.textSecondary,
                height: 1.3,
              ),
            ),
            if (item.notes != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Verified Note: ${item.notes}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF334155),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ChoiceChip(
                  label: const Text('Pending', style: TextStyle(fontSize: 10)),
                  selected: item.status == DueDiligenceCheckStatus.pending,
                  onSelected: (s) {
                    if (s) {
                      ref
                          .read(propertyDocumentNotifierProvider.notifier)
                          .updateDueDiligenceStatus(
                            propertyId: widget.propertyId,
                            checkItemId: item.id,
                            status: DueDiligenceCheckStatus.pending,
                            category: widget.category,
                          );
                    }
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Reviewed', style: TextStyle(fontSize: 10)),
                  selected: item.status == DueDiligenceCheckStatus.reviewed,
                  selectedColor: const Color(0xFFDCFCE7),
                  onSelected: (s) {
                    if (s) {
                      ref
                          .read(propertyDocumentNotifierProvider.notifier)
                          .updateDueDiligenceStatus(
                            propertyId: widget.propertyId,
                            checkItemId: item.id,
                            status: DueDiligenceCheckStatus.reviewed,
                            notes: 'Checked and marked verified.',
                            category: widget.category,
                          );
                    }
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text(
                    'Issue Found',
                    style: TextStyle(fontSize: 10),
                  ),
                  selected: item.status == DueDiligenceCheckStatus.issueFound,
                  selectedColor: const Color(0xFFFEE2E2),
                  onSelected: (s) {
                    if (s) {
                      ref
                          .read(propertyDocumentNotifierProvider.notifier)
                          .updateDueDiligenceStatus(
                            propertyId: widget.propertyId,
                            checkItemId: item.id,
                            status: DueDiligenceCheckStatus.issueFound,
                            notes:
                                'Discrepancy flagged for seller clarification.',
                            category: widget.category,
                          );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Due Diligence Caveat: Belagavi Property provides checklist tracking tools. A "Reviewed" status reflects platform checklist completion and does not constitute a title guarantee or legal opinion. Buyers must independently verify original documents through a qualified advocate.',
        style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.4),
      ),
    );
  }
}
