import '../../domain/entities/property_document_entity.dart';

class PropertyDocumentModel extends PropertyDocumentEntity {
  const PropertyDocumentModel({
    required super.id,
    required super.propertyId,
    required super.documentType,
    required super.documentName,
    required super.documentUrl,
    required super.uploadedBy,
    super.fileFormat = 'PDF',
    super.fileSizeBytes = 1048576,
    super.status = DocumentLifecycleStatus.submitted,
    super.notes,
    super.grantedBuyerIds = const [],
    super.accessRequests = const [],
    required super.uploadedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory PropertyDocumentModel.fromJson(Map<String, dynamic> json) {
    return PropertyDocumentModel(
      id: json['id'] as String? ?? '',
      propertyId: (json['property_id'] ?? json['propertyId']) as String? ?? '',
      documentType: PropertyDocumentCategoryType.values.firstWhere(
        (e) => e.name == (json['document_type'] ?? json['documentType']),
        orElse: () => PropertyDocumentCategoryType.otherSupportingDoc,
      ),
      documentName: (json['document_name'] ?? json['documentName']) as String? ?? 'Document',
      documentUrl: (json['document_url'] ?? json['documentUrl']) as String? ?? '',
      uploadedBy: (json['uploaded_by'] ?? json['uploadedBy']) as String? ?? '',
      fileFormat: (json['file_format'] ?? json['fileFormat']) as String? ?? 'PDF',
      fileSizeBytes: (json['file_size_bytes'] ?? json['fileSizeBytes']) as int? ?? 1048576,
      status: DocumentLifecycleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentLifecycleStatus.submitted,
      ),
      notes: json['notes'] as String?,
      grantedBuyerIds: (json['granted_buyer_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      accessRequests: (json['access_requests'] as List<dynamic>?)
              ?.map((e) => DocumentAccessRequest.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      uploadedAt: json['uploaded_at'] != null ? DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now() : DateTime.now(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
