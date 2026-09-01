import 'package:equatable/equatable.dart';
import 'property_entities.dart' show PropertyCategory;

enum PropertyDocumentCategoryType {
  saleDeed,
  previousSaleDeedTitleChain,
  encumbranceCertificate,
  propertyTaxReceipt,
  mutationRevenueRecord,
  surveyRecordDemarcation,
  rtcPahani,
  conversionNaOrder,
  layoutApproval,
  buildingApproval,
  reraDoc,
  khataMunicipalExtract,
  identityOwnershipProof,
  possessionCertificate,
  otherSupportingDoc,
}

extension PropertyDocumentCategoryTypeExtension on PropertyDocumentCategoryType {
  String get displayName => switch (this) {
        PropertyDocumentCategoryType.saleDeed => 'Registered Sale Deed',
        PropertyDocumentCategoryType.previousSaleDeedTitleChain => '30-Year Title Chain / Prior Deeds',
        PropertyDocumentCategoryType.encumbranceCertificate => 'Encumbrance Certificate (EC Form 15/16)',
        PropertyDocumentCategoryType.propertyTaxReceipt => 'Property Tax Receipt & Paid Challan',
        PropertyDocumentCategoryType.mutationRevenueRecord => 'Mutation Register Extract (MR)',
        PropertyDocumentCategoryType.surveyRecordDemarcation => 'Survey Map / Demarcation / 11E Sketch',
        PropertyDocumentCategoryType.rtcPahani => 'RTC / Pahani (Form 16/17)',
        PropertyDocumentCategoryType.conversionNaOrder => 'NA Conversion Order (DC Order)',
        PropertyDocumentCategoryType.layoutApproval => 'Layout Approval (BUDA / Gram Panchayat)',
        PropertyDocumentCategoryType.buildingApproval => 'Building Plan Sanction / Comm. Cert.',
        PropertyDocumentCategoryType.reraDoc => 'RERA Project Registration Certificate',
        PropertyDocumentCategoryType.khataMunicipalExtract => 'Khata Certificate & Extract (Form 3)',
        PropertyDocumentCategoryType.identityOwnershipProof => 'Seller Identity & KYC Proof (Aadhaar/PAN)',
        PropertyDocumentCategoryType.possessionCertificate => 'Possession Certificate / Handover Letter',
        PropertyDocumentCategoryType.otherSupportingDoc => 'Other Supporting Legal Document',
      };

  /// Returns whether this document type is standard/mandatory for the given category
  bool isRelevantForCategory(PropertyCategory category) {
    return switch (category) {
      PropertyCategory.residential => [
          PropertyDocumentCategoryType.saleDeed,
          PropertyDocumentCategoryType.previousSaleDeedTitleChain,
          PropertyDocumentCategoryType.encumbranceCertificate,
          PropertyDocumentCategoryType.propertyTaxReceipt,
          PropertyDocumentCategoryType.khataMunicipalExtract,
          PropertyDocumentCategoryType.buildingApproval,
          PropertyDocumentCategoryType.identityOwnershipProof,
          PropertyDocumentCategoryType.otherSupportingDoc,
        ].contains(this),
      PropertyCategory.plotLand => [
          PropertyDocumentCategoryType.saleDeed,
          PropertyDocumentCategoryType.previousSaleDeedTitleChain,
          PropertyDocumentCategoryType.encumbranceCertificate,
          PropertyDocumentCategoryType.conversionNaOrder,
          PropertyDocumentCategoryType.layoutApproval,
          PropertyDocumentCategoryType.surveyRecordDemarcation,
          PropertyDocumentCategoryType.propertyTaxReceipt,
          PropertyDocumentCategoryType.identityOwnershipProof,
          PropertyDocumentCategoryType.otherSupportingDoc,
        ].contains(this),
      PropertyCategory.commercial || PropertyCategory.industrial || PropertyCategory.builderProject => [
          PropertyDocumentCategoryType.saleDeed,
          PropertyDocumentCategoryType.previousSaleDeedTitleChain,
          PropertyDocumentCategoryType.encumbranceCertificate,
          PropertyDocumentCategoryType.conversionNaOrder,
          PropertyDocumentCategoryType.buildingApproval,
          PropertyDocumentCategoryType.propertyTaxReceipt,
          PropertyDocumentCategoryType.khataMunicipalExtract,
          PropertyDocumentCategoryType.identityOwnershipProof,
          PropertyDocumentCategoryType.otherSupportingDoc,
        ].contains(this),
      PropertyCategory.land || PropertyCategory.other => [
          PropertyDocumentCategoryType.saleDeed,
          PropertyDocumentCategoryType.previousSaleDeedTitleChain,
          PropertyDocumentCategoryType.rtcPahani,
          PropertyDocumentCategoryType.mutationRevenueRecord,
          PropertyDocumentCategoryType.surveyRecordDemarcation,
          PropertyDocumentCategoryType.encumbranceCertificate,
          PropertyDocumentCategoryType.propertyTaxReceipt,
          PropertyDocumentCategoryType.identityOwnershipProof,
          PropertyDocumentCategoryType.otherSupportingDoc,
        ].contains(this),
    };
  }
}

enum DocumentLifecycleStatus {
  notSubmitted,
  submitted,
  accessRequested,
  accessGranted,
  underReview,
  issueFound,
  reviewComplete,
}

extension DocumentLifecycleStatusExtension on DocumentLifecycleStatus {
  String get displayName => switch (this) {
        DocumentLifecycleStatus.notSubmitted => 'Not Submitted',
        DocumentLifecycleStatus.submitted => 'Submitted (Private)',
        DocumentLifecycleStatus.accessRequested => 'Access Requested by Buyer',
        DocumentLifecycleStatus.accessGranted => 'Access Granted to Buyer',
        DocumentLifecycleStatus.underReview => 'Under Legal Review',
        DocumentLifecycleStatus.issueFound => 'Issue / Discrepancy Found',
        DocumentLifecycleStatus.reviewComplete => 'Review Complete (Platform Inspection)',
      };
}

enum DueDiligenceCheckStatus { pending, reviewed, issueFound }

extension DueDiligenceCheckStatusExtension on DueDiligenceCheckStatus {
  String get displayName => switch (this) {
        DueDiligenceCheckStatus.pending => 'Pending Verification',
        DueDiligenceCheckStatus.reviewed => 'Reviewed & Verified',
        DueDiligenceCheckStatus.issueFound => 'Discrepancy / Issue Flagged',
      };
}

class DueDiligenceCheckItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final PropertyDocumentCategoryType requiredDocumentType;
  final DueDiligenceCheckStatus status;
  final String? notes;
  final DateTime? lastCheckedDate;

  const DueDiligenceCheckItem({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredDocumentType,
    this.status = DueDiligenceCheckStatus.pending,
    this.notes,
    this.lastCheckedDate,
  });

  DueDiligenceCheckItem copyWith({
    String? id,
    String? title,
    String? description,
    PropertyDocumentCategoryType? requiredDocumentType,
    DueDiligenceCheckStatus? status,
    String? notes,
    DateTime? lastCheckedDate,
  }) {
    return DueDiligenceCheckItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredDocumentType: requiredDocumentType ?? this.requiredDocumentType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      lastCheckedDate: lastCheckedDate ?? this.lastCheckedDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'requiredDocumentType': requiredDocumentType.name,
        'status': status.name,
        'notes': notes,
        'lastCheckedDate': lastCheckedDate?.toIso8601String(),
      };

  factory DueDiligenceCheckItem.fromMap(Map<String, dynamic> map) => DueDiligenceCheckItem(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        requiredDocumentType: PropertyDocumentCategoryType.values.firstWhere(
          (e) => e.name == map['requiredDocumentType'],
          orElse: () => PropertyDocumentCategoryType.otherSupportingDoc,
        ),
        status: DueDiligenceCheckStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => DueDiligenceCheckStatus.pending,
        ),
        notes: map['notes'] as String?,
        lastCheckedDate: map['lastCheckedDate'] != null ? DateTime.tryParse(map['lastCheckedDate'].toString()) : null,
      );

  @override
  List<Object?> get props => [id, title, description, requiredDocumentType, status, notes, lastCheckedDate];
}

class DocumentAccessRequest extends Equatable {
  final String id;
  final String propertyId;
  final String documentId;
  final String documentName;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final DateTime requestedAt;
  final bool isGranted;
  final DateTime? grantedAt;
  final String? rejectionReason;

  const DocumentAccessRequest({
    required this.id,
    required this.propertyId,
    required this.documentId,
    required this.documentName,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.requestedAt,
    this.isGranted = false,
    this.grantedAt,
    this.rejectionReason,
  });

  DocumentAccessRequest copyWith({
    String? id,
    String? propertyId,
    String? documentId,
    String? documentName,
    String? buyerId,
    String? buyerName,
    String? buyerPhone,
    DateTime? requestedAt,
    bool? isGranted,
    DateTime? grantedAt,
    String? rejectionReason,
  }) {
    return DocumentAccessRequest(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      documentId: documentId ?? this.documentId,
      documentName: documentName ?? this.documentName,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      requestedAt: requestedAt ?? this.requestedAt,
      isGranted: isGranted ?? this.isGranted,
      grantedAt: grantedAt ?? this.grantedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'propertyId': propertyId,
        'documentId': documentId,
        'documentName': documentName,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerPhone': buyerPhone,
        'requestedAt': requestedAt.toIso8601String(),
        'isGranted': isGranted,
        'grantedAt': grantedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
      };

  factory DocumentAccessRequest.fromMap(Map<String, dynamic> map) => DocumentAccessRequest(
        id: map['id'] as String,
        propertyId: map['propertyId'] as String,
        documentId: map['documentId'] as String,
        documentName: map['documentName'] as String,
        buyerId: map['buyerId'] as String,
        buyerName: map['buyerName'] as String,
        buyerPhone: map['buyerPhone'] as String,
        requestedAt: map['requestedAt'] != null ? DateTime.parse(map['requestedAt'].toString()) : DateTime.now(),
        isGranted: map['isGranted'] as bool? ?? false,
        grantedAt: map['grantedAt'] != null ? DateTime.tryParse(map['grantedAt'].toString()) : null,
        rejectionReason: map['rejectionReason'] as String?,
      );

  @override
  List<Object?> get props => [id, propertyId, documentId, buyerId, isGranted, requestedAt];
}

class PropertyDocumentEntity extends Equatable {
  final String id;
  final String propertyId;
  final PropertyDocumentCategoryType documentType;
  final String documentName;
  final String documentUrl;
  final String uploadedBy;
  final String fileFormat; // 'PDF', 'JPG', 'PNG'
  final int fileSizeBytes;
  final DocumentLifecycleStatus status;
  final String? notes;
  final List<String> grantedBuyerIds;
  final List<DocumentAccessRequest> accessRequests;
  final DateTime uploadedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyDocumentEntity({
    required this.id,
    required this.propertyId,
    required this.documentType,
    required this.documentName,
    required this.documentUrl,
    required this.uploadedBy,
    this.fileFormat = 'PDF',
    this.fileSizeBytes = 1048576,
    this.status = DocumentLifecycleStatus.submitted,
    this.notes,
    this.grantedBuyerIds = const [],
    this.accessRequests = const [],
    required this.uploadedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool canUserAccess(String userId, String propertyOwnerId) {
    if (userId == propertyOwnerId || userId == uploadedBy) return true;
    if (grantedBuyerIds.contains(userId)) return true;
    return false;
  }

  PropertyDocumentEntity copyWith({
    String? id,
    String? propertyId,
    PropertyDocumentCategoryType? documentType,
    String? documentName,
    String? documentUrl,
    String? uploadedBy,
    String? fileFormat,
    int? fileSizeBytes,
    DocumentLifecycleStatus? status,
    String? notes,
    List<String>? grantedBuyerIds,
    List<DocumentAccessRequest>? accessRequests,
    DateTime? uploadedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyDocumentEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      documentType: documentType ?? this.documentType,
      documentName: documentName ?? this.documentName,
      documentUrl: documentUrl ?? this.documentUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      fileFormat: fileFormat ?? this.fileFormat,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      grantedBuyerIds: grantedBuyerIds ?? this.grantedBuyerIds,
      accessRequests: accessRequests ?? this.accessRequests,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'property_id': propertyId,
        'document_type': documentType.name,
        'document_name': documentName,
        'document_url': documentUrl,
        'uploaded_by': uploadedBy,
        'file_format': fileFormat,
        'file_size_bytes': fileSizeBytes,
        'status': status.name,
        'notes': notes,
        'granted_buyer_ids': grantedBuyerIds,
        'access_requests': accessRequests.map((r) => r.toMap()).toList(),
        'uploaded_at': uploadedAt.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory PropertyDocumentEntity.fromMap(Map<String, dynamic> map) => PropertyDocumentEntity(
        id: map['id'] as String,
        propertyId: (map['property_id'] ?? map['propertyId']) as String? ?? '',
        documentType: PropertyDocumentCategoryType.values.firstWhere(
          (e) => e.name == (map['document_type'] ?? map['documentType']),
          orElse: () => PropertyDocumentCategoryType.otherSupportingDoc,
        ),
        documentName: (map['document_name'] ?? map['documentName']) as String? ?? 'Document',
        documentUrl: (map['document_url'] ?? map['documentUrl']) as String? ?? '',
        uploadedBy: (map['uploaded_by'] ?? map['uploadedBy']) as String? ?? 'owner',
        fileFormat: (map['file_format'] ?? map['fileFormat']) as String? ?? 'PDF',
        fileSizeBytes: (map['file_size_bytes'] ?? map['fileSizeBytes']) as int? ?? 1048576,
        status: DocumentLifecycleStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => DocumentLifecycleStatus.submitted,
        ),
        notes: map['notes'] as String?,
        grantedBuyerIds: (map['granted_buyer_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        accessRequests: (map['access_requests'] as List<dynamic>?)
                ?.map((e) => DocumentAccessRequest.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
        uploadedAt: map['uploaded_at'] != null ? DateTime.tryParse(map['uploaded_at'].toString()) ?? DateTime.now() : DateTime.now(),
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
        updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
      );

  @override
  List<Object?> get props => [
        id,
        propertyId,
        documentType,
        documentName,
        documentUrl,
        uploadedBy,
        fileFormat,
        status,
        notes,
        grantedBuyerIds,
        accessRequests,
        uploadedAt,
      ];
}
