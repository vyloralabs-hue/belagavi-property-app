import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart'
    show PropertyCategory;
import '../../domain/entities/property_document_entity.dart';
import '../providers/property_document_notifier.dart';
import '../widgets/secure_document_viewer_modal.dart';

extension PropertyCategoryVaultExtension on PropertyCategory {
  String get vaultDisplayName => switch (this) {
    PropertyCategory.residential => 'Residential Housing',
    PropertyCategory.plotLand => 'Plot / Land',
    PropertyCategory.commercial => 'Commercial Space',
    PropertyCategory.industrial => 'Industrial Property',
    PropertyCategory.land => 'Raw Land / Agricultural',
    PropertyCategory.builderProject => 'Builder Project',
    PropertyCategory.other => 'Property',
  };
}

class PropertyDocumentsManagementView extends ConsumerStatefulWidget {
  final String propertyId;
  final PropertyCategory category;
  final String propertyTitle;

  const PropertyDocumentsManagementView({
    super.key,
    required this.propertyId,
    this.category = PropertyCategory.residential,
    this.propertyTitle = 'Property Listing',
  });

  @override
  ConsumerState<PropertyDocumentsManagementView> createState() =>
      _PropertyDocumentsManagementViewState();
}

class _PropertyDocumentsManagementViewState
    extends ConsumerState<PropertyDocumentsManagementView> {
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
    final docs = state.documents;

    // Collect all inbound access requests across documents
    final allRequests = docs
        .expand((d) => d.accessRequests)
        .where((r) => !r.isGranted)
        .toList();

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Property Documents & Legal Vault',
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
              context.canPop() ? context.pop() : context.go('/my-properties'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context),
        backgroundColor: AppDesignSystem.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_rounded, size: 20),
        label: const Text(
          'Upload Legal Document',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Info Card ───
            Container(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB39037).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.category.vaultDisplayName.toUpperCase()} VAULT',
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
                            Icons.shield_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Private & Encrypted',
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
                    'Documents uploaded here are kept in private storage and only accessible to you and buyers you explicitly approve.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Inbound Buyer Access Requests (if any) ───
            if (allRequests.isNotEmpty) ...[
              Text(
                'Buyer Access Requests (${allRequests.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...allRequests.map(
                (req) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Color(0xFFF59E0B),
                      width: 1.2,
                    ),
                  ),
                  color: const Color(0xFFFFFBEB),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_open_rounded,
                          color: Color(0xFFB45309),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.documentName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Requested by: ${req.buyerName} (${req.buyerPhone})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(propertyDocumentNotifierProvider.notifier)
                                .grantDocumentAccess(
                                  propertyId: widget.propertyId,
                                  documentId: req.documentId,
                                  buyerId: req.buyerId,
                                  category: widget.category,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✓ Access granted to ${req.buyerName}!',
                                ),
                                backgroundColor: const Color(0xFF15803D),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Grant Access'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Uploaded Legal Documents ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uploaded Documents (${docs.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      context.push('/due-diligence/${widget.propertyId}'),
                  icon: const Icon(Icons.checklist_rounded, size: 16),
                  label: const Text(
                    'Due Diligence Checklist',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No legal documents uploaded yet.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Upload your Sale Deed, EC, Khata/RTC to expedite buyer due diligence and build buyer trust.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return _buildDocumentTile(context, doc);
                },
              ),

            const SizedBox(height: 24),

            // ─── Recommended Category Checklist ───
            _buildRecommendedChecklist(widget.category, docs),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, PropertyDocumentEntity doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.primaryNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    doc.fileFormat == 'PDF'
                        ? Icons.picture_as_pdf_rounded
                        : Icons.image_rounded,
                    color: AppDesignSystem.primaryNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.documentType.displayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doc.documentName} • ${(doc.fileSizeBytes / 1024).toStringAsFixed(0)} KB',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppDesignSystem.textSecondary,
                        ),
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
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    doc.status.displayName,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            if (doc.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${doc.notes}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475569),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Approved Buyers: ${doc.grantedBuyerIds.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: AppDesignSystem.primaryNavy,
                      ),
                      tooltip: 'View Document',
                      onPressed: () {
                        SecureDocumentViewerModal.show(
                          context: context,
                          document: doc,
                          currentUserId: 'owner_1',
                          propertyOwnerId: 'owner_1',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Remove Document',
                      onPressed: () {
                        ref
                            .read(propertyDocumentNotifierProvider.notifier)
                            .deleteDocument(
                              widget.propertyId,
                              doc.id,
                              category: widget.category,
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedChecklist(
    PropertyCategory category,
    List<PropertyDocumentEntity> uploaded,
  ) {
    final relevantTypes = PropertyDocumentCategoryType.values
        .where((t) => t.isRelevantForCategory(category))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_outlined,
                size: 18,
                color: Color(0xFF0284C7),
              ),
              const SizedBox(width: 8),
              Text(
                'Recommended Documents for ${category.vaultDisplayName}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...relevantTypes.map((type) {
            final isUploaded = uploaded.any((d) => d.documentType == type);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isUploaded
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: isUploaded ? const Color(0xFF15803D) : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isUploaded
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isUploaded
                            ? const Color(0xFF15803D)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    PropertyDocumentCategoryType selectedType =
        PropertyDocumentCategoryType.saleDeed;
    final nameController = TextEditingController(text: 'Title_Document.pdf');
    final notesController = TextEditingController();
    String fileFormat = 'PDF';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'Upload Property Document',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Document Type:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<PropertyDocumentCategoryType>(
                  initialValue: selectedType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  items: PropertyDocumentCategoryType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.displayName,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'File / Document Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Format: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('PDF', style: TextStyle(fontSize: 11)),
                      selected: fileFormat == 'PDF',
                      onSelected: (s) =>
                          setDialogState(() => fileFormat = 'PDF'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('JPG', style: TextStyle(fontSize: 11)),
                      selected: fileFormat == 'JPG',
                      onSelected: (s) =>
                          setDialogState(() => fileFormat = 'JPG'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('PNG', style: TextStyle(fontSize: 11)),
                      selected: fileFormat == 'PNG',
                      onSelected: (s) =>
                          setDialogState(() => fileFormat = 'PNG'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (e.g. SRO seal year, survey no)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newDoc = PropertyDocumentEntity(
                  id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
                  propertyId: widget.propertyId,
                  documentType: selectedType,
                  documentName: nameController.text.trim(),
                  documentUrl:
                      'https://storage.supabase.co/property-documents/owner_1/${widget.propertyId}/${nameController.text.trim()}',
                  uploadedBy: 'owner_1',
                  fileFormat: fileFormat,
                  status: DocumentLifecycleStatus.submitted,
                  notes: notesController.text.trim().isNotEmpty
                      ? notesController.text.trim()
                      : null,
                  uploadedAt: DateTime.now(),
                );
                ref
                    .read(propertyDocumentNotifierProvider.notifier)
                    .uploadDocument(newDoc, category: widget.category);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Document uploaded to secure vault!'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryNavy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
