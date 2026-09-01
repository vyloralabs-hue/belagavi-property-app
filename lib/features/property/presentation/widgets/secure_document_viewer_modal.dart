import 'package:flutter/material.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/property_document_entity.dart';

class SecureDocumentViewerModal extends StatelessWidget {
  final PropertyDocumentEntity document;
  final String currentUserId;
  final String propertyOwnerId;

  const SecureDocumentViewerModal({
    super.key,
    required this.document,
    required this.currentUserId,
    required this.propertyOwnerId,
  });

  static void show({
    required BuildContext context,
    required PropertyDocumentEntity document,
    required String currentUserId,
    required String propertyOwnerId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SecureDocumentViewerModal(
        document: document,
        currentUserId: currentUserId,
        propertyOwnerId: propertyOwnerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAccess = document.canUserAccess(currentUserId, propertyOwnerId);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 560 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            document.fileFormat == 'PDF'
                                ? Icons.picture_as_pdf_rounded
                                : Icons.image_rounded,
                            color: const Color(0xFFB45309),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              document.documentType.displayName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppDesignSystem.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        document.documentName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppDesignSystem.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),

            // Access Verification
            if (!hasAccess) ...[
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_person_rounded,
                          size: 54,
                          color: Color(0xFFB45309),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Private Legal Document',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This document is strictly restricted to the property owner and authorized buyers with granted access.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Secure Preview Container with Watermark
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      // Document Placeholder / Visual Canvas
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                document.fileFormat == 'PDF'
                                    ? Icons.description_outlined
                                    : Icons.photo_size_select_actual_outlined,
                                size: 64,
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                document.documentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Format: ${document.fileFormat}  •  Size: ${(document.fileSizeBytes / 1024).toStringAsFixed(1)} KB',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              if (document.notes != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Seller Note: ${document.notes}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF334155),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Status: ${document.status.displayName}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Security Watermark
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: Transform.rotate(
                              angle: -0.3,
                              child: Text(
                                'PROPERTYHUB SECURE DUE DILIGENCE\nCONFIDENTIAL — ${DateTime.now().year}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black.withValues(alpha: 0.06),
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Statutory Disclaimer Footer
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Disclaimer: Digital copies provided for due diligence scrutiny only. Parties must verify original registered parchment before government Sub-Registrar.',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
