import 'package:equatable/equatable.dart';

/// Structured selectable dispute types per CTO Master Directive
enum DisputeType {
  ownershipDispute,
  titleDispute,
  boundaryDispute,
  partitionFamilyDispute,
  inheritanceSuccessionDispute,
  possessionDispute,
  saleAgreementDispute,
  builderDeveloperDispute,
  tenantLandlordDispute,
  mortgageLoanDispute,
  encumbranceCharge,
  governmentAuthorityClaim,
  landAcquisitionDispute,
  surveyMeasurementDispute,
  accessRoadDispute,
  encroachmentAllegation,
  developmentJdaDispute,
  paymentDispute,
  revenueRecordDispute,
  registrationDocumentDispute,
  fraudMultipleSaleAllegation,
  courtLitigation,
  courtCaseStayOrder,
  otherLegalDispute,
}

extension DisputeTypeExtension on DisputeType {
  String get displayName => switch (this) {
        DisputeType.ownershipDispute => 'Ownership / Title',
        DisputeType.titleDispute => 'Title Defect / Dispute',
        DisputeType.boundaryDispute => 'Boundary Dispute',
        DisputeType.partitionFamilyDispute => 'Partition / Family',
        DisputeType.inheritanceSuccessionDispute => 'Inheritance / Succession',
        DisputeType.possessionDispute => 'Possession',
        DisputeType.saleAgreementDispute => 'Sale Agreement',
        DisputeType.builderDeveloperDispute => 'Builder / Developer',
        DisputeType.tenantLandlordDispute => 'Tenancy / Lease',
        DisputeType.mortgageLoanDispute => 'Mortgage / Charge',
        DisputeType.encumbranceCharge => 'Encumbrance / Charge',
        DisputeType.governmentAuthorityClaim => 'Government / Authority Claim',
        DisputeType.landAcquisitionDispute => 'Land Acquisition Notice',
        DisputeType.surveyMeasurementDispute => 'Survey / Measurement',
        DisputeType.accessRoadDispute => 'Access / Road',
        DisputeType.encroachmentAllegation => 'Encroachment Allegation',
        DisputeType.developmentJdaDispute => 'Development / JDA',
        DisputeType.paymentDispute => 'Payment',
        DisputeType.revenueRecordDispute => 'Revenue Record',
        DisputeType.registrationDocumentDispute => 'Registration / Document',
        DisputeType.fraudMultipleSaleAllegation => 'Fraud / Multiple Sale Allegation',
        DisputeType.courtLitigation => 'Court Case',
        DisputeType.courtCaseStayOrder => 'Court Case / Stay Order',
        DisputeType.otherLegalDispute => 'Other Reported Legal Dispute',
      };

  static const List<String> categories = [
    'Ownership / Title',
    'Boundary',
    'Partition / Family',
    'Inheritance / Succession',
    'Sale Agreement',
    'Possession',
    'Tenancy / Lease',
    'Mortgage / Charge',
    'Encroachment Allegation',
    'Access / Road',
    'Development / JDA',
    'Payment',
    'Court Case',
    'Revenue Record',
    'Registration / Document',
    'Other',
  ];

  static DisputeType fromString(String? val) {
    if (val == null) return DisputeType.otherLegalDispute;
    final normalized = val.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
    for (final type in DisputeType.values) {
      final typeNorm = type.name.toLowerCase().replaceAll('_', '');
      final displayNorm = type.displayName.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
      if (typeNorm == normalized || displayNorm == normalized) {
        return type;
      }
    }
    final lower = val.toLowerCase();
    if (lower.contains('boundary')) return DisputeType.boundaryDispute;
    if (lower.contains('ownership') || lower.contains('title')) return DisputeType.ownershipDispute;
    if (lower.contains('family') || lower.contains('inheritance') || lower.contains('partition') || lower.contains('succession')) return DisputeType.partitionFamilyDispute;
    if (lower.contains('court') || lower.contains('stay') || lower.contains('litigation') || lower.contains('case')) return DisputeType.courtLitigation;
    if (lower.contains('sale') || lower.contains('agreement')) return DisputeType.saleAgreementDispute;
    if (lower.contains('possession')) return DisputeType.possessionDispute;
    if (lower.contains('tenant') || lower.contains('lease') || lower.contains('tenancy')) return DisputeType.tenantLandlordDispute;
    if (lower.contains('mortgage') || lower.contains('encumbrance') || lower.contains('charge') || lower.contains('loan')) return DisputeType.mortgageLoanDispute;
    if (lower.contains('encroachment')) return DisputeType.encroachmentAllegation;
    if (lower.contains('access') || lower.contains('road')) return DisputeType.accessRoadDispute;
    if (lower.contains('development') || lower.contains('jda') || lower.contains('builder')) return DisputeType.developmentJdaDispute;
    if (lower.contains('payment')) return DisputeType.paymentDispute;
    if (lower.contains('revenue') || lower.contains('rtc') || lower.contains('mutation')) return DisputeType.revenueRecordDispute;
    if (lower.contains('registration') || lower.contains('document')) return DisputeType.registrationDocumentDispute;
    if (lower.contains('government') || lower.contains('authority')) return DisputeType.governmentAuthorityClaim;
    if (lower.contains('acquisition')) return DisputeType.landAcquisitionDispute;
    if (lower.contains('survey') || lower.contains('measurement')) return DisputeType.surveyMeasurementDispute;
    return DisputeType.otherLegalDispute;
  }
}

/// Scalable dispute verification and lifecycle status
enum DisputeVerificationStatus {
  draft,
  submitted,
  underReview,
  moreInformationRequired,
  verificationPending,
  documentVerified,
  publishedListed,
  rejected,
  paused,
  updated,
  resolved,
  withdrawn,
  archived,
}

extension DisputeVerificationStatusExtension on DisputeVerificationStatus {
  String get displayName => switch (this) {
        DisputeVerificationStatus.draft => 'Draft',
        DisputeVerificationStatus.submitted => 'Submitted',
        DisputeVerificationStatus.underReview => 'Under Platform Review',
        DisputeVerificationStatus.moreInformationRequired => 'More Information Required',
        DisputeVerificationStatus.verificationPending => 'Legal Verification Pending',
        DisputeVerificationStatus.documentVerified => 'Document Verified by Reviewer',
        DisputeVerificationStatus.publishedListed => 'Published / Listed Caveat',
        DisputeVerificationStatus.rejected => 'Report Rejected',
        DisputeVerificationStatus.paused => 'Paused',
        DisputeVerificationStatus.updated => 'Updated',
        DisputeVerificationStatus.resolved => 'Dispute Resolved / Settled',
        DisputeVerificationStatus.withdrawn => 'Withdrawn by Reporter',
        DisputeVerificationStatus.archived => 'Archived Record',
      };

  String get dbValue => switch (this) {
        DisputeVerificationStatus.draft => 'draft',
        DisputeVerificationStatus.submitted => 'submitted',
        DisputeVerificationStatus.underReview => 'under_review',
        DisputeVerificationStatus.moreInformationRequired => 'under_review',
        DisputeVerificationStatus.verificationPending => 'under_review',
        DisputeVerificationStatus.documentVerified => 'under_review',
        DisputeVerificationStatus.publishedListed => 'published',
        DisputeVerificationStatus.rejected => 'rejected',
        DisputeVerificationStatus.paused => 'paused',
        DisputeVerificationStatus.updated => 'updated',
        DisputeVerificationStatus.resolved => 'resolved',
        DisputeVerificationStatus.withdrawn => 'withdrawn',
        DisputeVerificationStatus.archived => 'archived',
      };

  static DisputeVerificationStatus fromString(String? val) {
    if (val == null) return DisputeVerificationStatus.underReview;
    final normalized = val.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
    for (final status in DisputeVerificationStatus.values) {
      final statusNorm = status.name.toLowerCase().replaceAll('_', '');
      final displayNorm = status.displayName.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
      final dbNorm = status.dbValue.toLowerCase().replaceAll('_', '');
      if (statusNorm == normalized || displayNorm == normalized || dbNorm == normalized) {
        return status;
      }
    }
    if (val.contains('draft')) return DisputeVerificationStatus.draft;
    if (val.contains('submit')) return DisputeVerificationStatus.submitted;
    if (val.contains('documentverified') || val.contains('document_verified') || val.contains('verified')) return DisputeVerificationStatus.documentVerified;
    if (val.contains('publish') || val.contains('list')) return DisputeVerificationStatus.publishedListed;
    if (val.contains('resolve') || val.contains('settle')) return DisputeVerificationStatus.resolved;
    if (val.contains('reject')) return DisputeVerificationStatus.rejected;
    if (val.contains('withdraw')) return DisputeVerificationStatus.withdrawn;
    if (val.contains('archive')) return DisputeVerificationStatus.archived;
    return DisputeVerificationStatus.underReview;
  }
}

/// Structured Party Involved in a Dispute
class DisputePartyEntity extends Equatable {
  final String name;
  final String role; // 'Claimant', 'Respondent', 'Owner', 'Co-owner', 'Builder', 'Buyer', 'Seller', 'Tenant', 'Bank', 'Government Authority', 'Other'
  final String? contact;
  final String? advocateName;

  const DisputePartyEntity({
    required this.name,
    required this.role,
    this.contact,
    this.advocateName,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        if (contact != null) 'contact': contact,
        if (advocateName != null) 'advocateName': advocateName,
      };

  factory DisputePartyEntity.fromMap(Map<String, dynamic> map) => DisputePartyEntity(
        name: (map['name'] as String?) ?? '',
        role: (map['role'] as String?) ?? 'Claimant',
        contact: map['contact'] as String?,
        advocateName: map['advocateName'] as String?,
      );

  @override
  List<Object?> get props => [name, role, contact, advocateName];
}

/// Document associated with a Disputed Property
class DisputeDocumentEntity extends Equatable {
  final String id;
  final String disputeId;
  final String documentType; // Sale Deed, RTC / 7-12, Property Card, Mutation, Court Order, etc.
  final DateTime? documentDate;
  final String? issuingAuthority;
  final String? referenceNumber;
  final String? description;
  final String storagePath;
  final String? publicRedactedUrl;
  final String visibility; // public_redacted, private, moderator_only
  final bool isRedacted;
  final String badgeLabel;
  final DateTime createdAt;

  const DisputeDocumentEntity({
    required this.id,
    required this.disputeId,
    required this.documentType,
    this.documentDate,
    this.issuingAuthority,
    this.referenceNumber,
    this.description,
    required this.storagePath,
    this.publicRedactedUrl,
    this.visibility = 'public_redacted',
    this.isRedacted = true,
    this.badgeLabel = 'DOCUMENT UPLOADED',
    required this.createdAt,
  });

  String get effectiveUrl => publicRedactedUrl ?? storagePath;

  DisputeDocumentEntity copyWith({
    String? id,
    String? disputeId,
    String? documentType,
    DateTime? documentDate,
    String? issuingAuthority,
    String? referenceNumber,
    String? description,
    String? storagePath,
    String? publicRedactedUrl,
    String? visibility,
    bool? isRedacted,
    String? badgeLabel,
    DateTime? createdAt,
  }) {
    return DisputeDocumentEntity(
      id: id ?? this.id,
      disputeId: disputeId ?? this.disputeId,
      documentType: documentType ?? this.documentType,
      documentDate: documentDate ?? this.documentDate,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      description: description ?? this.description,
      storagePath: storagePath ?? this.storagePath,
      publicRedactedUrl: publicRedactedUrl ?? this.publicRedactedUrl,
      visibility: visibility ?? this.visibility,
      isRedacted: isRedacted ?? this.isRedacted,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toSupabaseMap() => {
        'id': id,
        'dispute_id': disputeId,
        'document_type': documentType,
        if (documentDate != null) 'document_date': documentDate!.toIso8601String().split('T').first,
        if (issuingAuthority != null) 'issuing_authority': issuingAuthority,
        if (referenceNumber != null) 'reference_number': referenceNumber,
        if (description != null) 'description': description,
        'storage_path': storagePath,
        if (publicRedactedUrl != null) 'public_redacted_url': publicRedactedUrl,
        'visibility': visibility,
        'is_redacted': isRedacted,
        'badge_label': badgeLabel,
        'created_at': createdAt.toIso8601String(),
      };

  factory DisputeDocumentEntity.fromSupabaseMap(Map<String, dynamic> map) => DisputeDocumentEntity(
        id: (map['id'] as String?) ?? '',
        disputeId: (map['dispute_id'] as String?) ?? '',
        documentType: (map['document_type'] as String?) ?? 'Document',
        documentDate: map['document_date'] != null ? DateTime.tryParse(map['document_date'].toString()) : null,
        issuingAuthority: map['issuing_authority'] as String?,
        referenceNumber: map['reference_number'] as String?,
        description: map['description'] as String?,
        storagePath: (map['storage_path'] as String?) ?? '',
        publicRedactedUrl: map['public_redacted_url'] as String?,
        visibility: (map['visibility'] as String?) ?? 'public_redacted',
        isRedacted: (map['is_redacted'] as bool?) ?? true,
        badgeLabel: (map['badge_label'] as String?) ?? 'DOCUMENT UPLOADED',
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      );

  @override
  List<Object?> get props => [id, disputeId, documentType, documentDate, issuingAuthority, referenceNumber, description, storagePath, publicRedactedUrl, visibility, isRedacted, badgeLabel, createdAt];
}

/// Response / Counterparty Submission on a Disputed Property
class DisputeResponseEntity extends Equatable {
  final String id;
  final String disputeId;
  final String respondentId;
  final String respondentName;
  final String respondentRole;
  final String responseType; // response, correction_request, claim_record
  final String statement;
  final List<String> supportingDocumentUrls;
  final String status;
  final DateTime createdAt;

  const DisputeResponseEntity({
    required this.id,
    required this.disputeId,
    required this.respondentId,
    required this.respondentName,
    required this.respondentRole,
    this.responseType = 'response',
    required this.statement,
    this.supportingDocumentUrls = const [],
    this.status = 'submitted',
    required this.createdAt,
  });

  Map<String, dynamic> toSupabaseMap() => {
        'id': id,
        'dispute_id': disputeId,
        'respondent_id': respondentId,
        'respondent_name': respondentName,
        'respondent_role': respondentRole,
        'response_type': responseType,
        'statement': statement,
        'supporting_document_urls': supportingDocumentUrls,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  factory DisputeResponseEntity.fromSupabaseMap(Map<String, dynamic> map) => DisputeResponseEntity(
        id: (map['id'] as String?) ?? '',
        disputeId: (map['dispute_id'] as String?) ?? '',
        respondentId: (map['respondent_id'] as String?) ?? '',
        respondentName: (map['respondent_name'] as String?) ?? 'Respondent',
        respondentRole: (map['respondent_role'] as String?) ?? 'Interested Party',
        responseType: (map['response_type'] as String?) ?? 'response',
        statement: (map['statement'] as String?) ?? '',
        supportingDocumentUrls: (map['supporting_document_urls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        status: (map['status'] as String?) ?? 'submitted',
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      );

  @override
  List<Object?> get props => [id, disputeId, respondentId, respondentName, respondentRole, responseType, statement, supportingDocumentUrls, status, createdAt];
}

/// Audit Event / Timeline Event for a Disputed Property
class DisputeEventEntity extends Equatable {
  final String id;
  final String disputeId;
  final String eventType;
  final String actorId;
  final String actorRole;
  final String description;
  final DateTime createdAt;

  const DisputeEventEntity({
    required this.id,
    required this.disputeId,
    required this.eventType,
    required this.actorId,
    this.actorRole = 'user',
    required this.description,
    required this.createdAt,
  });

  factory DisputeEventEntity.fromSupabaseMap(Map<String, dynamic> map) => DisputeEventEntity(
        id: (map['id'] as String?) ?? '',
        disputeId: (map['dispute_id'] as String?) ?? '',
        eventType: (map['event_type'] as String?) ?? 'event',
        actorId: (map['actor_id'] as String?) ?? '',
        actorRole: (map['actor_role'] as String?) ?? 'user',
        description: (map['description'] as String?) ?? '',
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      );

  @override
  List<Object?> get props => [id, disputeId, eventType, actorId, actorRole, description, createdAt];
}

/// Potential Duplicate Candidate found before submission
class DisputeDuplicateCandidate extends Equatable {
  final String id;
  final String title;
  final String locality;
  final String? surveyNumber;
  final String? propertyNumber;
  final String status;
  final String disputeCategory;

  const DisputeDuplicateCandidate({
    required this.id,
    required this.title,
    required this.locality,
    this.surveyNumber,
    this.propertyNumber,
    required this.status,
    required this.disputeCategory,
  });

  @override
  List<Object?> get props => [id, title, locality, surveyNumber, propertyNumber, status, disputeCategory];
}

/// Comprehensive Disputed Property Entity
class PropertyDisputeEntity extends Equatable {
  final String id;
  final String propertyId;
  final String creatorId; // Firebase UID
  final String title;
  final String category;
  final String propertyType;

  // Indian Geography Hierarchy
  final String country;
  final String state;
  final String? district;
  final String? taluk;
  final String city;
  final String locality;
  final String? village;
  final String? postalCode;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;

  // Property Identifiers
  final String? villageTaluk;
  final String? surveyCtsNumber; // maps to survey_number
  final String? propertyNumber;
  final String? plotFlatShopNumber;
  final String? registrationReference;
  final String? khataNumber;
  final String? plotNumber;
  final String? flatUnitNumber;
  final String? buildingProjectName;
  final double? propertyArea;
  final String? landArea;
  final String areaUnit;
  final String? ownershipType;
  final String? possessionStatus;

  // Dispute Categorization & Information
  final String relationship;
  final DisputeType disputeType;
  final String disputeCategory;
  final DisputeVerificationStatus verificationStatus;
  final bool isFounderConfirmed;
  final String description; // factual_summary
  final String? factualSummary;
  final String? claimedDisputeNature;
  final String claimingPartyRole;
  final String? respondingPartyRole;
  final String? disputeStartDate;
  final String currentStage;

  // Court / Authority Information
  final String? courtAuthority; // court_authority_name
  final String? caseNumber;
  final String? caseType;
  final String? filingNumber;
  final String? caseYear;
  final String? caseFilingDate;
  final String? nextHearingDate;
  final String? caseOrdersNotes;
  final String? caseStatus;
  final String? litigatingParties;
  final List<DisputePartyEntity> structuredParties;

  // Assessment flags
  final String? disputeSummary;
  final bool isPossessionDisputed;
  final bool isOwnershipDisputed;
  final bool isCourtCasePending;
  final bool isStayInjunctionReported;
  final bool isRegistrationBlocked;
  final bool hasKnownEncumbrance;
  final String? previousSettlementAttempt;

  // Lifecycle & Metadata
  final bool isRedacted;
  final bool hasDocuments;
  final int viewsCount;

  // Authorized Contact (Private by default)
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;

  // Media & Documents
  final List<String> photoUrls;
  final List<String> documentUrls;
  final List<String> photoLabels;
  final List<String> documentLabels;
  final bool isDocumentPrivate;

  // Child collections
  final List<DisputeDocumentEntity> documents;
  final List<DisputeResponseEntity> responses;
  final List<DisputeEventEntity> events;

  // Audit metadata
  final String reportedBy;
  final DateTime? reportDate;
  final String? relevantNotes;
  final DateTime? lastUpdated;

  const PropertyDisputeEntity({
    this.id = '',
    this.propertyId = '',
    this.creatorId = '',
    this.title = 'Disputed Property Listing',
    this.category = 'Residential',
    this.propertyType = 'Residential Plot',
    this.country = 'India',
    this.state = 'Karnataka',
    this.district = 'Belagavi',
    this.taluk = 'Belagavi',
    this.city = 'Belagavi',
    this.locality = 'Belagavi',
    this.village,
    this.postalCode,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.villageTaluk,
    this.surveyCtsNumber,
    this.propertyNumber,
    this.plotFlatShopNumber,
    this.registrationReference,
    this.khataNumber,
    this.plotNumber,
    this.flatUnitNumber,
    this.buildingProjectName,
    this.propertyArea,
    this.landArea,
    this.areaUnit = 'sqft',
    this.ownershipType,
    this.possessionStatus,
    this.relationship = 'Reporting a dispute',
    this.disputeType = DisputeType.otherLegalDispute,
    this.disputeCategory = 'Ownership / Title',
    this.verificationStatus = DisputeVerificationStatus.underReview,
    this.isFounderConfirmed = false,
    this.courtAuthority,
    this.caseNumber,
    this.caseType,
    this.filingNumber,
    this.caseYear,
    this.caseFilingDate,
    this.nextHearingDate,
    this.caseOrdersNotes,
    this.caseStatus = 'Pending in Court',
    this.litigatingParties,
    this.structuredParties = const [],
    this.description = '',
    this.factualSummary,
    this.claimedDisputeNature,
    this.claimingPartyRole = 'owner',
    this.respondingPartyRole,
    this.disputeSummary,
    this.disputeStartDate,
    this.currentStage = 'Pending Review',
    this.isPossessionDisputed = false,
    this.isOwnershipDisputed = true,
    this.isCourtCasePending = false,
    this.isStayInjunctionReported = false,
    this.isRegistrationBlocked = false,
    this.hasKnownEncumbrance = false,
    this.previousSettlementAttempt,
    this.isRedacted = false,
    this.hasDocuments = false,
    this.viewsCount = 0,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.photoUrls = const [],
    this.documentUrls = const [],
    this.photoLabels = const [],
    this.documentLabels = const [],
    this.isDocumentPrivate = true,
    this.documents = const [],
    this.responses = const [],
    this.events = const [],
    this.reportedBy = 'User Reported',
    this.reportDate,
    this.relevantNotes,
    this.lastUpdated,
  });

  DateTime get safeReportDate => reportDate ?? DateTime.now();
  DateTime get safeLastUpdated => lastUpdated ?? DateTime.now();
  String get effectiveSurveyNumber => surveyCtsNumber ?? '';
  String get effectiveFactualSummary => (factualSummary != null && factualSummary!.isNotEmpty) ? factualSummary! : description;

  PropertyDisputeEntity copyWith({
    String? id,
    String? propertyId,
    String? creatorId,
    String? title,
    String? category,
    String? propertyType,
    String? country,
    String? state,
    String? district,
    String? taluk,
    String? city,
    String? locality,
    String? village,
    String? postalCode,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? villageTaluk,
    String? surveyCtsNumber,
    String? propertyNumber,
    String? plotFlatShopNumber,
    String? registrationReference,
    String? khataNumber,
    String? plotNumber,
    String? flatUnitNumber,
    String? buildingProjectName,
    double? propertyArea,
    String? landArea,
    String? areaUnit,
    String? ownershipType,
    String? possessionStatus,
    String? relationship,
    DisputeType? disputeType,
    String? disputeCategory,
    DisputeVerificationStatus? verificationStatus,
    bool? isFounderConfirmed,
    String? courtAuthority,
    String? caseNumber,
    String? caseType,
    String? filingNumber,
    String? caseYear,
    String? caseFilingDate,
    String? nextHearingDate,
    String? caseOrdersNotes,
    String? caseStatus,
    String? litigatingParties,
    List<DisputePartyEntity>? structuredParties,
    String? description,
    String? factualSummary,
    String? claimedDisputeNature,
    String? claimingPartyRole,
    String? respondingPartyRole,
    String? disputeSummary,
    String? disputeStartDate,
    String? currentStage,
    bool? isPossessionDisputed,
    bool? isOwnershipDisputed,
    bool? isCourtCasePending,
    bool? isStayInjunctionReported,
    bool? isRegistrationBlocked,
    bool? hasKnownEncumbrance,
    String? previousSettlementAttempt,
    bool? isRedacted,
    bool? hasDocuments,
    int? viewsCount,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    List<String>? photoUrls,
    List<String>? documentUrls,
    List<String>? photoLabels,
    List<String>? documentLabels,
    bool? isDocumentPrivate,
    List<DisputeDocumentEntity>? documents,
    List<DisputeResponseEntity>? responses,
    List<DisputeEventEntity>? events,
    String? reportedBy,
    DateTime? reportDate,
    String? relevantNotes,
    DateTime? lastUpdated,
  }) {
    return PropertyDisputeEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      category: category ?? this.category,
      propertyType: propertyType ?? this.propertyType,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      village: village ?? this.village,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      villageTaluk: villageTaluk ?? this.villageTaluk,
      surveyCtsNumber: surveyCtsNumber ?? this.surveyCtsNumber,
      propertyNumber: propertyNumber ?? this.propertyNumber,
      plotFlatShopNumber: plotFlatShopNumber ?? this.plotFlatShopNumber,
      registrationReference: registrationReference ?? this.registrationReference,
      khataNumber: khataNumber ?? this.khataNumber,
      plotNumber: plotNumber ?? this.plotNumber,
      flatUnitNumber: flatUnitNumber ?? this.flatUnitNumber,
      buildingProjectName: buildingProjectName ?? this.buildingProjectName,
      propertyArea: propertyArea ?? this.propertyArea,
      landArea: landArea ?? this.landArea,
      areaUnit: areaUnit ?? this.areaUnit,
      ownershipType: ownershipType ?? this.ownershipType,
      possessionStatus: possessionStatus ?? this.possessionStatus,
      relationship: relationship ?? this.relationship,
      disputeType: disputeType ?? this.disputeType,
      disputeCategory: disputeCategory ?? this.disputeCategory,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isFounderConfirmed: isFounderConfirmed ?? this.isFounderConfirmed,
      courtAuthority: courtAuthority ?? this.courtAuthority,
      caseNumber: caseNumber ?? this.caseNumber,
      caseType: caseType ?? this.caseType,
      filingNumber: filingNumber ?? this.filingNumber,
      caseYear: caseYear ?? this.caseYear,
      caseFilingDate: caseFilingDate ?? this.caseFilingDate,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      caseOrdersNotes: caseOrdersNotes ?? this.caseOrdersNotes,
      caseStatus: caseStatus ?? this.caseStatus,
      litigatingParties: litigatingParties ?? this.litigatingParties,
      structuredParties: structuredParties ?? this.structuredParties,
      description: description ?? this.description,
      factualSummary: factualSummary ?? this.factualSummary,
      claimedDisputeNature: claimedDisputeNature ?? this.claimedDisputeNature,
      claimingPartyRole: claimingPartyRole ?? this.claimingPartyRole,
      respondingPartyRole: respondingPartyRole ?? this.respondingPartyRole,
      disputeSummary: disputeSummary ?? this.disputeSummary,
      disputeStartDate: disputeStartDate ?? this.disputeStartDate,
      currentStage: currentStage ?? this.currentStage,
      isPossessionDisputed: isPossessionDisputed ?? this.isPossessionDisputed,
      isOwnershipDisputed: isOwnershipDisputed ?? this.isOwnershipDisputed,
      isCourtCasePending: isCourtCasePending ?? this.isCourtCasePending,
      isStayInjunctionReported: isStayInjunctionReported ?? this.isStayInjunctionReported,
      isRegistrationBlocked: isRegistrationBlocked ?? this.isRegistrationBlocked,
      hasKnownEncumbrance: hasKnownEncumbrance ?? this.hasKnownEncumbrance,
      previousSettlementAttempt: previousSettlementAttempt ?? this.previousSettlementAttempt,
      isRedacted: isRedacted ?? this.isRedacted,
      hasDocuments: hasDocuments ?? this.hasDocuments,
      viewsCount: viewsCount ?? this.viewsCount,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      photoUrls: photoUrls ?? this.photoUrls,
      documentUrls: documentUrls ?? this.documentUrls,
      photoLabels: photoLabels ?? this.photoLabels,
      documentLabels: documentLabels ?? this.documentLabels,
      isDocumentPrivate: isDocumentPrivate ?? this.isDocumentPrivate,
      documents: documents ?? this.documents,
      responses: responses ?? this.responses,
      events: events ?? this.events,
      reportedBy: reportedBy ?? this.reportedBy,
      reportDate: reportDate ?? this.reportDate,
      relevantNotes: relevantNotes ?? this.relevantNotes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (propertyId.isNotEmpty && propertyId.contains('-')) 'property_id': propertyId,
      'creator_id': creatorId.isNotEmpty ? creatorId : reportedBy,
      'title': title,
      'property_type': propertyType,
      'state': state,
      'district': district ?? 'Belagavi',
      'taluk': taluk ?? 'Belagavi',
      'city': city,
      'locality': locality,
      if (village != null) 'village': village,
      if (surveyCtsNumber != null) 'survey_number': surveyCtsNumber,
      if (propertyNumber != null) 'property_number': propertyNumber,
      if (plotFlatShopNumber != null) 'plot_flat_shop_number': plotFlatShopNumber,
      if (registrationReference != null) 'registration_reference': registrationReference,
      if (propertyArea != null) 'property_area': propertyArea,
      'area_unit': areaUnit,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (ownershipType != null) 'ownership_type': ownershipType,
      if (possessionStatus != null) 'possession_status': possessionStatus,
      'dispute_category': disputeCategory.isNotEmpty ? disputeCategory : disputeType.displayName,
      'factual_summary': effectiveFactualSummary.isNotEmpty ? effectiveFactualSummary : 'Reported dispute record.',
      if (claimedDisputeNature != null) 'claimed_dispute_nature': claimedDisputeNature,
      'claiming_party_role': claimingPartyRole,
      if (respondingPartyRole != null) 'responding_party_role': respondingPartyRole,
      if (disputeStartDate != null) 'dispute_start_date': disputeStartDate,
      'current_stage': currentStage,
      if (caseNumber != null) 'case_number': caseNumber,
      if (courtAuthority != null) 'court_authority_name': courtAuthority,
      if (caseFilingDate != null) 'case_filing_date': caseFilingDate,
      if (nextHearingDate != null) 'next_hearing_date': nextHearingDate,
      if (caseOrdersNotes != null) 'case_orders_notes': caseOrdersNotes,
      'status': verificationStatus.dbValue,
      'is_redacted': isRedacted,
      'has_documents': documents.isNotEmpty || documentUrls.isNotEmpty,
      'views_count': viewsCount,
      'created_at': safeReportDate.toIso8601String(),
      'updated_at': safeLastUpdated.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    final map = toSupabaseMap();
    if (postalCode != null) map['postalCode'] = postalCode;
    if (fullAddress != null) map['fullAddress'] = fullAddress;
    if (khataNumber != null) map['khataNumber'] = khataNumber;
    if (plotNumber != null) map['plotNumber'] = plotNumber;
    if (flatUnitNumber != null) map['flatUnitNumber'] = flatUnitNumber;
    if (buildingProjectName != null) map['buildingProjectName'] = buildingProjectName;
    if (landArea != null) map['landArea'] = landArea;
    if (caseNumber != null) map['caseNumber'] = caseNumber;
    if (caseYear != null) map['caseYear'] = caseYear;
    if (caseStatus != null) map['caseStatus'] = caseStatus;
    if (litigatingParties != null) map['litigatingParties'] = litigatingParties;
    if (surveyCtsNumber != null) map['surveyCtsNumber'] = surveyCtsNumber;
    if (courtAuthority != null) map['courtAuthority'] = courtAuthority;
    if (propertyId.isNotEmpty) map['propertyId'] = propertyId;
    map['disputeType'] = disputeType.name;
    map['verificationStatus'] = verificationStatus.name;
    map['isFounderConfirmed'] = isFounderConfirmed;
    map['structuredParties'] = structuredParties.map((p) => p.toMap()).toList();
    map['description'] = description;
    if (disputeSummary != null) map['disputeSummary'] = disputeSummary;
    if (contactName != null) map['contactName'] = contactName;
    if (contactPhone != null) map['contactPhone'] = contactPhone;
    if (contactEmail != null) map['contactEmail'] = contactEmail;
    map['photoUrls'] = photoUrls;
    map['documentUrls'] = documentUrls;
    map['photoLabels'] = photoLabels;
    map['documentLabels'] = documentLabels;
    map['isDocumentPrivate'] = isDocumentPrivate;
    map['reportedBy'] = reportedBy;
    if (relevantNotes != null) map['relevantNotes'] = relevantNotes;
    map['reportDate'] = safeReportDate.toIso8601String();
    map['lastUpdated'] = safeLastUpdated.toIso8601String();
    return map;
  }

  factory PropertyDisputeEntity.fromMap(Map<String, dynamic> map, [String? defaultId]) {
    final recordId = (map['id'] as String?) ?? defaultId ?? '';
    final propId = (map['propertyId'] as String?) ?? (map['property_id'] as String?) ?? recordId;
    final catStr = (map['dispute_category'] as String?) ?? (map['category'] as String?) ?? 'Ownership / Title';
    final dType = DisputeTypeExtension.fromString((map['disputeType'] as String?) ?? (map['dispute_type'] as String?) ?? catStr);

    final rawDocs = (map['dispute_documents'] as List?)
            ?.map((d) => DisputeDocumentEntity.fromSupabaseMap(d as Map<String, dynamic>))
            .toList() ??
        const [];

    final rawResponses = (map['dispute_responses'] as List?)
            ?.map((r) => DisputeResponseEntity.fromSupabaseMap(r as Map<String, dynamic>))
            .toList() ??
        const [];

    final rawEvents = (map['dispute_events'] as List?)
            ?.map((e) => DisputeEventEntity.fromSupabaseMap(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return PropertyDisputeEntity(
      id: recordId,
      propertyId: propId,
      creatorId: (map['creator_id'] as String?) ?? (map['reportedBy'] as String?) ?? '',
      title: (map['title'] as String?) ?? 'Disputed Property Listing',
      category: (map['category'] as String?) ?? 'Residential',
      propertyType: (map['property_type'] as String?) ?? (map['propertyType'] as String?) ?? 'Residential Plot',
      country: (map['country'] as String?) ?? 'India',
      state: (map['state'] as String?) ?? 'Karnataka',
      district: (map['district'] as String?) ?? 'Belagavi',
      taluk: (map['taluk'] as String?) ?? 'Belagavi',
      city: (map['city'] as String?) ?? 'Belagavi',
      locality: (map['locality'] as String?) ?? 'Belagavi',
      village: (map['village'] as String?),
      postalCode: (map['postalCode'] as String?) ?? (map['postal_code'] as String?),
      fullAddress: (map['fullAddress'] as String?) ?? (map['full_address'] as String?),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      villageTaluk: (map['villageTaluk'] as String?) ?? (map['village_taluk'] as String?),
      surveyCtsNumber: (map['survey_number'] as String?) ?? (map['surveyCtsNumber'] as String?) ?? (map['survey_cts_number'] as String?),
      propertyNumber: (map['property_number'] as String?) ?? (map['propertyNumber'] as String?),
      plotFlatShopNumber: (map['plot_flat_shop_number'] as String?) ?? (map['plotFlatShopNumber'] as String?),
      registrationReference: (map['registration_reference'] as String?) ?? (map['registrationReference'] as String?),
      khataNumber: (map['khataNumber'] as String?) ?? (map['khata_number'] as String?),
      plotNumber: (map['plotNumber'] as String?) ?? (map['plot_number'] as String?),
      flatUnitNumber: (map['flatUnitNumber'] as String?) ?? (map['flat_unit_number'] as String?),
      buildingProjectName: (map['buildingProjectName'] as String?) ?? (map['building_project_name'] as String?),
      propertyArea: (map['property_area'] as num?)?.toDouble(),
      landArea: (map['landArea'] as String?) ?? (map['land_area'] as String?),
      areaUnit: (map['area_unit'] as String?) ?? (map['areaUnit'] as String?) ?? 'sqft',
      ownershipType: (map['ownership_type'] as String?),
      possessionStatus: (map['possession_status'] as String?),
      relationship: (map['relationship'] as String?) ?? 'Reporting a dispute',
      disputeType: dType,
      disputeCategory: catStr,
      verificationStatus: DisputeVerificationStatusExtension.fromString((map['verificationStatus'] as String?) ?? (map['verification_status'] as String?) ?? (map['status'] as String?)),
      isFounderConfirmed: (map['isFounderConfirmed'] as bool?) ?? (map['is_founder_confirmed'] as bool?) ?? false,
      courtAuthority: (map['court_authority_name'] as String?) ?? (map['courtAuthority'] as String?) ?? (map['court_authority'] as String?),
      caseNumber: (map['case_number'] as String?) ?? (map['caseNumber'] as String?),
      caseType: (map['caseType'] as String?) ?? (map['case_type'] as String?),
      filingNumber: (map['filingNumber'] as String?) ?? (map['filing_number'] as String?),
      caseYear: (map['caseYear'] as String?) ?? (map['case_year'] as String?),
      caseFilingDate: (map['case_filing_date'] as String?),
      nextHearingDate: (map['next_hearing_date'] as String?),
      caseOrdersNotes: (map['case_orders_notes'] as String?),
      caseStatus: (map['caseStatus'] as String?) ?? (map['case_status'] as String?) ?? 'Pending in Court',
      litigatingParties: (map['litigatingParties'] as String?) ?? (map['litigating_parties'] as String?),
      structuredParties: (map['structuredParties'] as List?)
              ?.map((p) => DisputePartyEntity.fromMap(p as Map<String, dynamic>))
              .toList() ??
          const [],
      description: (map['factual_summary'] as String?) ?? (map['description'] as String?) ?? 'Dispute reported regarding this property.',
      factualSummary: (map['factual_summary'] as String?) ?? (map['description'] as String?),
      claimedDisputeNature: (map['claimed_dispute_nature'] as String?),
      claimingPartyRole: (map['claiming_party_role'] as String?) ?? 'owner',
      respondingPartyRole: (map['responding_party_role'] as String?),
      disputeSummary: (map['disputeSummary'] as String?) ?? (map['dispute_summary'] as String?),
      disputeStartDate: (map['dispute_start_date'] as String?) ?? (map['disputeStartDate'] as String?),
      currentStage: (map['current_stage'] as String?) ?? 'Pending Review',
      isPossessionDisputed: (map['isPossessionDisputed'] as bool?) ?? (map['is_possession_disputed'] as bool?) ?? false,
      isOwnershipDisputed: (map['isOwnershipDisputed'] as bool?) ?? (map['is_ownership_disputed'] as bool?) ?? true,
      isCourtCasePending: (map['isCourtCasePending'] as bool?) ?? (map['is_court_case_pending'] as bool?) ?? false,
      isStayInjunctionReported: (map['isStayInjunctionReported'] as bool?) ?? (map['is_stay_injunction_reported'] as bool?) ?? false,
      isRegistrationBlocked: (map['isRegistrationBlocked'] as bool?) ?? (map['is_registration_blocked'] as bool?) ?? false,
      hasKnownEncumbrance: (map['hasKnownEncumbrance'] as bool?) ?? (map['has_known_encumbrance'] as bool?) ?? false,
      previousSettlementAttempt: (map['previousSettlementAttempt'] as String?) ?? (map['previous_settlement_attempt'] as String?),
      isRedacted: (map['is_redacted'] as bool?) ?? false,
      hasDocuments: (map['has_documents'] as bool?) ?? rawDocs.isNotEmpty,
      viewsCount: (map['views_count'] as num?)?.toInt() ?? 0,
      contactName: (map['contactName'] as String?) ?? (map['contact_name'] as String?),
      contactPhone: (map['contactPhone'] as String?) ?? (map['contact_phone'] as String?),
      contactEmail: (map['contactEmail'] as String?) ?? (map['contact_email'] as String?),
      photoUrls: (map['photoUrls'] as List?)?.map((e) => e.toString()).toList() ??
          (map['photo_urls'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      documentUrls: (map['documentUrls'] as List?)?.map((e) => e.toString()).toList() ??
          (map['document_urls'] as List?)?.map((e) => e.toString()).toList() ??
          rawDocs.map((d) => d.effectiveUrl).toList(),
      photoLabels: (map['photoLabels'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      documentLabels: (map['documentLabels'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isDocumentPrivate: (map['isDocumentPrivate'] as bool?) ?? (map['is_document_private'] as bool?) ?? true,
      documents: rawDocs,
      responses: rawResponses,
      events: rawEvents,
      reportedBy: (map['creator_id'] as String?) ?? (map['reportedBy'] as String?) ?? (map['reported_by'] as String?) ?? 'Platform User',
      reportDate: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : map['reportDate'] != null
              ? DateTime.tryParse(map['reportDate'].toString()) ?? DateTime.now()
              : DateTime.now(),
      relevantNotes: (map['relevantNotes'] as String?) ?? (map['relevant_notes'] as String?),
      lastUpdated: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : map['lastUpdated'] != null
              ? DateTime.tryParse(map['lastUpdated'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        creatorId,
        title,
        category,
        propertyType,
        country,
        state,
        district,
        taluk,
        city,
        locality,
        village,
        postalCode,
        fullAddress,
        latitude,
        longitude,
        villageTaluk,
        surveyCtsNumber,
        propertyNumber,
        plotFlatShopNumber,
        registrationReference,
        khataNumber,
        plotNumber,
        flatUnitNumber,
        buildingProjectName,
        propertyArea,
        landArea,
        areaUnit,
        ownershipType,
        possessionStatus,
        relationship,
        disputeType,
        disputeCategory,
        verificationStatus,
        isFounderConfirmed,
        courtAuthority,
        caseNumber,
        caseType,
        filingNumber,
        caseYear,
        caseFilingDate,
        nextHearingDate,
        caseOrdersNotes,
        caseStatus,
        litigatingParties,
        structuredParties,
        description,
        factualSummary,
        claimedDisputeNature,
        claimingPartyRole,
        respondingPartyRole,
        disputeSummary,
        disputeStartDate,
        currentStage,
        isPossessionDisputed,
        isOwnershipDisputed,
        isCourtCasePending,
        isStayInjunctionReported,
        isRegistrationBlocked,
        hasKnownEncumbrance,
        previousSettlementAttempt,
        isRedacted,
        hasDocuments,
        viewsCount,
        contactName,
        contactPhone,
        contactEmail,
        photoUrls,
        documentUrls,
        photoLabels,
        documentLabels,
        isDocumentPrivate,
        documents,
        responses,
        events,
        reportedBy,
        reportDate,
        relevantNotes,
        lastUpdated,
      ];
}