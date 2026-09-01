import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../widgets/dispute_property_image.dart';
import '../../domain/entities/dispute_entities.dart';
import '../providers/dispute_providers.dart';

class DisputedPropertyDetailView extends ConsumerStatefulWidget {
  final String disputeId;
  final PropertyDisputeEntity? initialDispute;

  const DisputedPropertyDetailView({
    super.key,
    required this.disputeId,
    this.initialDispute,
  });

  @override
  ConsumerState<DisputedPropertyDetailView> createState() =>
      _DisputedPropertyDetailViewState();
}

class _DisputedPropertyDetailViewState
    extends ConsumerState<DisputedPropertyDetailView> {
  PropertyDisputeEntity? _dispute;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDispute != null) {
      _dispute = widget.initialDispute;
    } else {
      _fetchDispute();
    }
  }

  Future<void> _fetchDispute() async {
    setState(() => _isLoading = true);
    final repo = ref.read(disputeRepositoryProvider);
    final result = await repo.getDisputeById(
      widget.disputeId,
      requestingUserId: '',
    );
    result.fold(
      (_) => setState(() => _isLoading = false),
      (data) => setState(() {
        _dispute = data;
        _isLoading = false;
      }),
    );
  }

  void _showSubmitResponseModal(BuildContext context) {
    final statementController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'Interested Party / Co-owner';
    String responseType = 'response';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDesignSystem.surfaceBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final textP = AppDesignSystem.textP(ctx);
          final borderCol = AppDesignSystem.borderCol(ctx);

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Response or Correction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Counterparties, advocates, or co-owners may submit factual clarifications or documents.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppDesignSystem.textS(ctx),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameController,
                    style: TextStyle(fontSize: 13, color: textP),
                    decoration: InputDecoration(
                      hintText: 'Your Name or Law Firm Name',
                      filled: true,
                      fillColor: AppDesignSystem.inputBg(ctx),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderCol),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: statementController,
                    maxLines: 4,
                    style: TextStyle(fontSize: 13, color: textP),
                    decoration: InputDecoration(
                      hintText:
                          'Provide neutral factual statement or correction request...',
                      filled: true,
                      fillColor: AppDesignSystem.inputBg(ctx),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderCol),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (statementController.text.trim().isEmpty) return;
                        String currentUserId =
                            AuthSessionStorageHelper.getUserUid() ?? 'usr_anon';
                        try {
                          final fbUid = FirebaseAuth.instance.currentUser?.uid;
                          if (fbUid != null && fbUid.isNotEmpty) {
                            currentUserId = fbUid;
                          }
                        } catch (_) {}
                        final repo = ref.read(disputeRepositoryProvider);
                        await repo.submitDisputeResponse(
                          disputeId: widget.disputeId,
                          respondentId: currentUserId,
                          respondentName: nameController.text.trim().isNotEmpty
                              ? nameController.text.trim()
                              : 'Interested Party',
                          respondentRole: selectedRole,
                          responseType: responseType,
                          statement: statementController.text.trim(),
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Response submitted for platform review successfully!',
                              ),
                            ),
                          );
                          _fetchDispute();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Submit Response',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: surfaceBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textP),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.disputedProperties),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
        ),
      );
    }

    final dispute = _dispute;
    if (dispute == null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: surfaceBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textP),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.disputedProperties),
          ),
          title: const Text('Dispute Record Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text('Dispute listing could not be loaded.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.disputedProperties),
                child: const Text('Return to Dispute Registry'),
              ),
            ],
          ),
        ),
      );
    }

    final coverMediaUrl = dispute.photoUrls.isNotEmpty
        ? dispute.photoUrls.first
        : (dispute.documentUrls.isNotEmpty ? dispute.documentUrls.first : null);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          dispute.disputeCategory,
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
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
              context.go(AppRoutes.disputedProperties);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Submit Response',
            icon: const Icon(
              Icons.reply_rounded,
              color: AppDesignSystem.brandGold,
            ),
            onPressed: () => _showSubmitResponseModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image / Property Placeholder with Persistent DISPUTED Overlay
            DisputePropertyImage(
              imageUrl: coverMediaUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(14),
            ),
            const SizedBox(height: 14),

            // 2. Title & Status Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dispute.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textP,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppDesignSystem.brandGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dispute.locality}, ${dispute.city}',
                            style: TextStyle(fontSize: 12, color: textS),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dispute.verificationStatus.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Property Overview Section
            _buildSectionHeader('PROPERTY IDENTIFICATION'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Property Type', dispute.propertyType),
                  _buildDetailRow('Locality', dispute.locality),
                  if (dispute.surveyCtsNumber != null &&
                      dispute.surveyCtsNumber!.isNotEmpty)
                    _buildDetailRow(
                      'Survey / CTS No.',
                      dispute.surveyCtsNumber!,
                    ),
                  if (dispute.propertyNumber != null &&
                      dispute.propertyNumber!.isNotEmpty)
                    _buildDetailRow('Property Number', dispute.propertyNumber!),
                  if (dispute.plotFlatShopNumber != null &&
                      dispute.plotFlatShopNumber!.isNotEmpty)
                    _buildDetailRow(
                      'Plot/Flat/Shop',
                      dispute.plotFlatShopNumber!,
                    ),
                  if (dispute.propertyArea != null)
                    _buildDetailRow(
                      'Area',
                      '${dispute.propertyArea} ${dispute.areaUnit}',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Reported Dispute Details
            _buildSectionHeader('REPORTED DISPUTE STATEMENT'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Dispute Category', dispute.disputeCategory),
                  _buildDetailRow('Current Stage', dispute.currentStage),
                  _buildDetailRow(
                    'Claiming Party Role',
                    dispute.claimingPartyRole,
                  ),
                  if (dispute.disputeStartDate != null)
                    _buildDetailRow(
                      'Reported Start Date',
                      dispute.disputeStartDate!,
                    ),
                  const Divider(height: 16),
                  Text(
                    'Factual Summary:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dispute.effectiveFactualSummary,
                    style: TextStyle(fontSize: 12, color: textS, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Case / Authority Reference
            if (dispute.caseNumber != null ||
                dispute.courtAuthority != null) ...[
              _buildSectionHeader('COURT / AUTHORITY REFERENCE'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    if (dispute.caseNumber != null)
                      _buildDetailRow('Case Number', dispute.caseNumber!),
                    if (dispute.courtAuthority != null)
                      _buildDetailRow('Court / Forum', dispute.courtAuthority!),
                    if (dispute.caseFilingDate != null)
                      _buildDetailRow('Filing Date', dispute.caseFilingDate!),
                    if (dispute.caseOrdersNotes != null) ...[
                      const Divider(height: 16),
                      Text(
                        'Orders / Relief Notes:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textP,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dispute.caseOrdersNotes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: textS,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 6. Attached Documents
            _buildSectionHeader(
              'ATTACHED SUPPORTING DOCUMENTS (${dispute.documents.length + dispute.documentUrls.length})',
            ),
            if (dispute.documents.isEmpty && dispute.documentUrls.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                ),
                child: Text(
                  'No public documents attached to this record.',
                  style: TextStyle(fontSize: 11, color: textS),
                ),
              )
            else
              ...dispute.documents.map(
                (doc) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppDesignSystem.brandGold,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.documentType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textP,
                              ),
                            ),
                            Text(
                              'Document Attached • Redacted for Privacy',
                              style: TextStyle(fontSize: 10, color: textS),
                            ),
                          ],
                        ),
                      ),
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
                        child: const Text(
                          'REDACTED',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.brandGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // 7. Counterparty Responses
            _buildSectionHeader(
              'RESPONSES & CLARIFICATIONS (${dispute.responses.length})',
            ),
            if (dispute.responses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'No counterparty responses or clarifications filed yet.',
                        style: TextStyle(fontSize: 11, color: textS),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showSubmitResponseModal(context),
                      child: const Text(
                        '+ Respond',
                        style: TextStyle(
                          color: AppDesignSystem.brandGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...dispute.responses.map(
                (resp) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            resp.respondentName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textP,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${resp.respondentRole})',
                            style: TextStyle(fontSize: 10, color: textS),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resp.statement,
                        style: TextStyle(fontSize: 11, color: textS),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // 8. Legal Safety Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol),
              ),
              child: Text(
                'Information on this page is submitted by users or publishers. Belagavi Property does not determine ownership, title validity, liability, or the merits of a dispute. Users should independently verify official records and obtain appropriate professional advice before acting.',
                style: TextStyle(fontSize: 10, color: textS, height: 1.3),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: AppDesignSystem.brandGold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 11, color: textS)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textP,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
