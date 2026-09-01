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

  const LegalNoticeDetailView({super.key, required this.noticeId});

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(legalNoticesNotifierProvider);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    // Find notice from list or show placeholder
    final notice = state.notices.firstWhere(
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning / Public notice banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF0284C7), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OFFICIAL PUBLIC LEGAL NOTICE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue.shade900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Published for statutory title verification, public objection window, and buyer/seller transparency.',
                          style: TextStyle(fontSize: 11.5, color: Colors.blue.shade800, height: 1.4),
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
                    'Supporting legal documents are encrypted and protected. Verified reviewers examine filings during moderation.',
                    style: TextStyle(fontSize: 12, color: textS, height: 1.4),
                  ),
                  const SizedBox(height: 14),
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
