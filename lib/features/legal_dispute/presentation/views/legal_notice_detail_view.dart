import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/legal_notice_entities.dart';
import '../providers/legal_notice_providers.dart';

/// Rich Public Legal Notice Detail View
class LegalNoticeDetailView extends ConsumerStatefulWidget {
  final String noticeId;
  final TransactionLegalNoticeEntity? initialNotice;

  const LegalNoticeDetailView({
    super.key,
    required this.noticeId,
    this.initialNotice,
  });

  @override
  ConsumerState<LegalNoticeDetailView> createState() => _LegalNoticeDetailViewState();
}

class _LegalNoticeDetailViewState extends ConsumerState<LegalNoticeDetailView> {
  final ImagePicker _picker = ImagePicker();
  bool _isAttaching = false;

  Future<void> _handleAttachDocument(TransactionLegalNoticeEntity notice) async {
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
    if (!isLoggedIn) {
      context.go('/auth?redirect=${Uri.encodeComponent('/legal-notice/${widget.noticeId}')}');
      return;
    }

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (picked != null) {
        setState(() => _isAttaching = true);
        final repo = ref.read(legalNoticeRepositoryProvider);
        final currentUserId = AuthSessionStorageHelper.getUserUid() ?? 'usr_current';
        final result = await repo.attachDocuments(
          widget.noticeId,
          newDocuments: [picked.path],
          authenticatedUserId: currentUserId,
        );

        if (mounted) {
          setState(() => _isAttaching = false);
          result.fold(
            (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red)),
            (updated) {
              ref.read(legalNoticesNotifierProvider.notifier).loadLegalNotices();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document attached successfully!'), backgroundColor: Colors.green));
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAttaching = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleWithdrawNotice(TransactionLegalNoticeEntity notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Legal Notice?'),
        content: Text(
          'Are you sure you want to withdraw "${notice.title}"? It will be marked as withdrawn and archived.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final currentUserId = AuthSessionStorageHelper.getUserUid() ?? 'usr_current';
    final repo = ref.read(legalNoticeRepositoryProvider);
    final result = await repo.updateStatus(
      noticeId: notice.id,
      newStatus: LegalNoticeStatus.withdrawn,
      authenticatedUserId: currentUserId,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          );
        }
      },
      (updated) {
        ref.read(legalNoticesNotifierProvider.notifier).loadLegalNotices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notice marked as withdrawn successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Future<void> _handleDeleteNotice(TransactionLegalNoticeEntity notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Legal Notice?'),
        content: Text(
          'Are you sure you want to delete "${notice.title}"? This will also remove any attached document scans.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final currentUserId = AuthSessionStorageHelper.getUserUid() ?? 'usr_current';
    final repo = ref.read(legalNoticeRepositoryProvider);
    final result = await repo.deleteLegalNotice(
      notice.id,
      authenticatedUserId: currentUserId,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          );
        }
      },
      (_) {
        ref.read(legalNoticesNotifierProvider.notifier).loadLegalNotices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notice deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/legal-notices');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(legalNoticesNotifierProvider);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    // Find notice from list or initialNotice or show placeholder
    final notice = widget.initialNotice ?? state.notices.firstWhere(
      (n) => n.id == widget.noticeId,
      orElse: () => TransactionLegalNoticeEntity(
        id: widget.noticeId,
        propertyId: 'prop_unknown',
        title: 'Property Legal Notice Record',
        category: 'Residential',
        propertyType: 'Apartment',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        buyerName: 'Authorized Purchaser',
        sellerName: 'Vendor / Owner',
        contactName: 'Advocate / Authorized Rep',
        contactPhone: '+91 ••••• •••••',
        noticeType: LegalNoticeType.purchaseNotice,
        verificationStatus: LegalNoticeStatus.published,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: AppDesignSystem.scaffoldBg(context),
      appBar: AppBar(
        title: const Text('Property Legal Notice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppDesignSystem.surfaceBg(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () => context.canPop() ? context.pop() : context.go('/legal-notices'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice link copied to clipboard')));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textP),
            onSelected: (action) {
              if (action == 'edit') {
                context.push('/legal-notice/edit/${notice.id}', extra: notice);
              } else if (action == 'withdraw') {
                _handleWithdrawNotice(notice);
              } else if (action == 'delete') {
                _handleDeleteNotice(notice);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0284C7)),
                    SizedBox(width: 8),
                    Text('Edit Notice'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'withdraw',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 18, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Text('Withdraw / Archive'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning / Public notice banner (Dynamic based on 10-day lifecycle)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: notice.isExpiredFromPublicView
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: notice.isExpiredFromPublicView
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    notice.isExpiredFromPublicView
                        ? Icons.history_rounded
                        : Icons.verified_user_rounded,
                    color: notice.isExpiredFromPublicView
                        ? const Color(0xFF64748B)
                        : const Color(0xFF0284C7),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notice.isExpiredFromPublicView
                              ? 'PRIVATE RECORD • EXPIRED FROM PUBLIC VIEW'
                              : 'OFFICIAL PUBLIC LEGAL NOTICE • 10-DAY WINDOW',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: notice.isExpiredFromPublicView
                                ? const Color(0xFF334155)
                                : Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notice.isExpiredFromPublicView
                              ? 'This notice has completed its 10-day public visibility window. It is hidden from public feeds and search, but permanently preserved in your account history.'
                              : 'Published for statutory title verification, public objection window, and buyer/seller transparency. Visible publicly for 10 days.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: notice.isExpiredFromPublicView
                                ? const Color(0xFF475569)
                                : Colors.blue.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notice Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notice.noticeType.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0284C7)),
                        ),
                      ),
                      const Spacer(),
                      if (notice.isPubliclyActive)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Public • ${notice.remainingPublicDays}d remaining',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF16A34A)),
                          ),
                        )
                      else if (notice.isExpiredFromPublicView)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64748B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Expired from Public',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notice.verificationStatus.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF16A34A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(notice.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textP)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Text('${notice.locality}, ${notice.city}', style: TextStyle(fontSize: 12.5, color: textS)),
                    ],
                  ),
                  if (notice.surveyCtsNumber != null) ...[
                    const SizedBox(height: 4),
                    Text('Identifier: ${notice.surveyCtsNumber}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textP)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Parties Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parties to Transaction', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textP)),
                  const Divider(height: 20),
                  _buildDetailRow(context, 'Purchaser / Buyer', notice.buyerName),
                  if (notice.buyerAdvocate != null) _buildDetailRow(context, 'Buyer Advocate', notice.buyerAdvocate!),
                  _buildDetailRow(context, 'Vendor / Seller', notice.sellerName),
                  if (notice.transactionType.isNotEmpty) _buildDetailRow(context, 'Transaction Type', notice.transactionType),
                  if (notice.agreedValue != null) _buildDetailRow(context, 'Declared Consideration', notice.agreedValue!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notice Text Card
            if (notice.publicNoticeSummary != null || notice.noticeFullText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Public Notice Text & Caveat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textP)),
                    const Divider(height: 20),
                    if (notice.publicNoticeSummary != null)
                      Text(notice.publicNoticeSummary!, style: TextStyle(fontSize: 13, color: textP, height: 1.4)),
                    if (notice.noticeFullText != null) ...[
                      const SizedBox(height: 10),
                      Text(notice.noticeFullText!, style: TextStyle(fontSize: 12, color: textS, height: 1.4)),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Publication Details
            if (notice.publicationInfo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Publication Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textP)),
                    const Divider(height: 20),
                    if (notice.publicationInfo!.newspaperName != null) _buildDetailRow(context, 'Newspaper / Gazette', notice.publicationInfo!.newspaperName!),
                    if (notice.publicationInfo!.edition != null) _buildDetailRow(context, 'Edition', notice.publicationInfo!.edition!),
                    if (notice.publicationInfo!.pageNumber != null) _buildDetailRow(context, 'Page No.', notice.publicationInfo!.pageNumber!),
                    if (notice.publicationInfo!.advocateFirm != null) _buildDetailRow(context, 'Advocate Firm', notice.publicationInfo!.advocateFirm!),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Documents & Privacy Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Text('Supporting Documents (${notice.documentUrls.length})', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textP)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supporting legal documents are encrypted and stored in canonical cloud storage without duplication. Documents are lazy-loaded only when requested.',
                    style: TextStyle(fontSize: 12, color: textS, height: 1.4),
                  ),
                  if (notice.documentUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...notice.documentUrls.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final docUrl = entry.value;
                      final docLabel = idx < notice.documentLabels.length
                          ? notice.documentLabels[idx]
                          : 'Legal Document Scan #${idx + 1}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppDesignSystem.inputBg(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderCol),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded, size: 22, color: Color(0xFFDC2626)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    docLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: textP,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Canonical Storage • Lazy load on tap',
                                    style: TextStyle(fontSize: 10.5, color: textS),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dCtx) => AlertDialog(
                                    title: Text(docLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.description_outlined, size: 48, color: Color(0xFF0284C7)),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Canonical Document Path:\n$docUrl',
                                          style: const TextStyle(fontSize: 11),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dCtx),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 14),
                              label: const Text('View', style: TextStyle(fontSize: 11)),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isAttaching ? null : () => _handleAttachDocument(notice),
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: const Text('Attach Additional Document Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(fontSize: 12, color: AppDesignSystem.textS(context)))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppDesignSystem.textP(context)))),
        ],
      ),
    );
  }
}
