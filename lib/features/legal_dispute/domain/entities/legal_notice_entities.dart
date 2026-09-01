import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Structured selectable Legal Notice Types per CTO Master Directive
enum LegalNoticeType {
  purchaseNotice,
  saleNotice,
  publicNoticeBeforePurchase,
  titleVerificationNotice,
  ownershipClaimNotice,
  objectionNotice,
  possessionNotice,
  agreementNotice,
  cancellationNotice,
  builderDeveloperNotice,
  tenantLandlordNotice,
  mortgageChargeNotice,
  inheritanceSuccessionNotice,
  partitionNotice,
  boundaryNotice,
  otherPropertyLegalNotice,
  // Legacy aliases for backward compatibility
  purchaseLegalNotice,
  saleLegalNotice,
  documentVerificationNotice,
  disputeLitigationWarning,
  dueDiligenceNotice,
  registrationNotice,
  agreementToSellNotice,
  publicCaveatNotice,
}

extension LegalNoticeTypeExtension on LegalNoticeType {
  String get title => switch (this) {
        LegalNoticeType.purchaseNotice || LegalNoticeType.purchaseLegalNotice => 'Property Purchase Legal Notice',
        LegalNoticeType.saleNotice || LegalNoticeType.saleLegalNotice => 'Property Sale Legal Notice',
        LegalNoticeType.publicNoticeBeforePurchase => 'Public Notice Before Purchase',
        LegalNoticeType.titleVerificationNotice || LegalNoticeType.documentVerificationNotice => 'Title Search & Verification Notice',
        LegalNoticeType.ownershipClaimNotice => 'Ownership Claim Notice',
        LegalNoticeType.objectionNotice || LegalNoticeType.publicCaveatNotice => 'Objection & Caveat Notice',
        LegalNoticeType.possessionNotice => 'Possession Notice',
        LegalNoticeType.agreementNotice || LegalNoticeType.agreementToSellNotice => 'Agreement & Contract Notice',
        LegalNoticeType.cancellationNotice => 'Agreement / Deed Cancellation Notice',
        LegalNoticeType.builderDeveloperNotice => 'Builder / Developer Notice',
        LegalNoticeType.tenantLandlordNotice => 'Tenant / Landlord Notice',
        LegalNoticeType.mortgageChargeNotice => 'Mortgage / Charge Notice',
        LegalNoticeType.inheritanceSuccessionNotice => 'Inheritance / Succession Notice',
        LegalNoticeType.partitionNotice => 'Partition / Family Share Notice',
        LegalNoticeType.boundaryNotice => 'Boundary & Demarcation Notice',
        LegalNoticeType.disputeLitigationWarning => 'Litigation Caution Warning',
        LegalNoticeType.dueDiligenceNotice => 'Legal Due Diligence Notice',
        LegalNoticeType.registrationNotice => 'Sub-Registrar Registration Notice',
        LegalNoticeType.otherPropertyLegalNotice => 'Other Property Legal Notice',
      };

  IconData get icon => switch (this) {
        LegalNoticeType.purchaseNotice || LegalNoticeType.purchaseLegalNotice => Icons.shopping_bag_outlined,
        LegalNoticeType.saleNotice || LegalNoticeType.saleLegalNotice => Icons.storefront_outlined,
        LegalNoticeType.publicNoticeBeforePurchase => Icons.campaign_outlined,
        LegalNoticeType.titleVerificationNotice || LegalNoticeType.documentVerificationNotice => Icons.verified_user_outlined,
        LegalNoticeType.ownershipClaimNotice => Icons.account_balance_outlined,
        LegalNoticeType.objectionNotice || LegalNoticeType.publicCaveatNotice => Icons.gavel_outlined,
        LegalNoticeType.possessionNotice => Icons.key_outlined,
        LegalNoticeType.agreementNotice || LegalNoticeType.agreementToSellNotice => Icons.description_outlined,
        LegalNoticeType.cancellationNotice => Icons.cancel_outlined,
        LegalNoticeType.builderDeveloperNotice => Icons.apartment_outlined,
        LegalNoticeType.tenantLandlordNotice => Icons.people_outline,
        LegalNoticeType.mortgageChargeNotice => Icons.assured_workload_outlined,
        LegalNoticeType.inheritanceSuccessionNotice => Icons.family_restroom_outlined,
        LegalNoticeType.partitionNotice => Icons.pie_chart_outline,
        LegalNoticeType.boundaryNotice => Icons.square_foot_outlined,
        LegalNoticeType.disputeLitigationWarning => Icons.warning_amber_rounded,
        LegalNoticeType.dueDiligenceNotice => Icons.fact_check_outlined,
        LegalNoticeType.registrationNotice => Icons.how_to_reg_outlined,
        LegalNoticeType.otherPropertyLegalNotice => Icons.article_outlined,
      };

  Color get accentColor => switch (this) {
        LegalNoticeType.purchaseNotice || LegalNoticeType.purchaseLegalNotice => const Color(0xFF0284C7),
        LegalNoticeType.saleNotice || LegalNoticeType.saleLegalNotice => const Color(0xFF16A34A),
        LegalNoticeType.publicNoticeBeforePurchase => const Color(0xFFEA580C),
        LegalNoticeType.titleVerificationNotice || LegalNoticeType.documentVerificationNotice => const Color(0xFFB39037),
        LegalNoticeType.ownershipClaimNotice => const Color(0xFF4F46E5),
        LegalNoticeType.objectionNotice || LegalNoticeType.publicCaveatNotice => const Color(0xFFDC2626),
        LegalNoticeType.possessionNotice => const Color(0xFF0D9488),
        LegalNoticeType.agreementNotice || LegalNoticeType.agreementToSellNotice => const Color(0xFF0891B2),
        LegalNoticeType.cancellationNotice => const Color(0xFFBE123C),
        LegalNoticeType.builderDeveloperNotice => const Color(0xFF8B5CF6),
        LegalNoticeType.tenantLandlordNotice => const Color(0xFF65A30D),
        LegalNoticeType.mortgageChargeNotice => const Color(0xFF9333EA),
        LegalNoticeType.inheritanceSuccessionNotice => const Color(0xFFD97706),
        LegalNoticeType.partitionNotice => const Color(0xFF0284C7),
        LegalNoticeType.boundaryNotice => const Color(0xFF059669),
        LegalNoticeType.disputeLitigationWarning => const Color(0xFFD97706),
        LegalNoticeType.dueDiligenceNotice => const Color(0xFF7C3AED),
        LegalNoticeType.registrationNotice => const Color(0xFF2563EB),
        LegalNoticeType.otherPropertyLegalNotice => const Color(0xFF475569),
      };

  static LegalNoticeType fromString(String? val) {
    if (val == null) return LegalNoticeType.purchaseNotice;
    final normalized = val.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
    for (final type in LegalNoticeType.values) {
      final typeNorm = type.name.toLowerCase().replaceAll('_', '');
      final titleNorm = type.title.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
      if (typeNorm == normalized || titleNorm == normalized) {
        return type;
      }
    }
    if (val.contains('purchase')) return LegalNoticeType.purchaseNotice;
    if (val.contains('sale')) return LegalNoticeType.saleNotice;
    if (val.contains('caveat') || val.contains('objection')) return LegalNoticeType.objectionNotice;
    if (val.contains('agreement')) return LegalNoticeType.agreementNotice;
    if (val.contains('title') || val.contains('verification')) return LegalNoticeType.titleVerificationNotice;
    if (val.contains('possession')) return LegalNoticeType.possessionNotice;
    if (val.contains('cancel')) return LegalNoticeType.cancellationNotice;
    if (val.contains('builder')) return LegalNoticeType.builderDeveloperNotice;
    if (val.contains('tenant')) return LegalNoticeType.tenantLandlordNotice;
    if (val.contains('mortgage')) return LegalNoticeType.mortgageChargeNotice;
    if (val.contains('inheritance')) return LegalNoticeType.inheritanceSuccessionNotice;
    if (val.contains('partition')) return LegalNoticeType.partitionNotice;
    if (val.contains('boundary')) return LegalNoticeType.boundaryNotice;
    return LegalNoticeType.otherPropertyLegalNotice;
  }
}

/// Scalable Legal Notice Statuses per CTO Master Directive
enum LegalNoticeStatus {
  draft,
  submitted,
  underReview,
  published,
  responseReceived,
  withdrawn,
  closed,
  rejected,
  archived,
  // Legacy aliases
  verified,
  recorded,
}

extension LegalNoticeStatusExtension on LegalNoticeStatus {
  String get displayName => switch (this) {
        LegalNoticeStatus.draft => 'Draft (Unsubmitted)',
        LegalNoticeStatus.submitted => 'Submitted (Pending Review)',
        LegalNoticeStatus.underReview => 'Under Legal Review',
        LegalNoticeStatus.published || LegalNoticeStatus.recorded || LegalNoticeStatus.verified => 'Published Legal Notice',
        LegalNoticeStatus.responseReceived => 'Response / Objection Received',
        LegalNoticeStatus.withdrawn => 'Withdrawn by Issuer',
        LegalNoticeStatus.closed => 'Notice Closed / Expired',
        LegalNoticeStatus.rejected => 'Rejected / Incomplete',
        LegalNoticeStatus.archived => 'Archived Record',
      };

  static LegalNoticeStatus fromString(String? val) {
    if (val == null) return LegalNoticeStatus.underReview;
    final normalized = val.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
    for (final status in LegalNoticeStatus.values) {
      final statusNorm = status.name.toLowerCase().replaceAll('_', '');
      final displayNorm = status.displayName.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('/', '');
      if (statusNorm == normalized || displayNorm == normalized) {
        return status;
      }
    }
    if (val.contains('draft')) return LegalNoticeStatus.draft;
    if (val.contains('submit')) return LegalNoticeStatus.submitted;
    if (val.contains('publish') || val.contains('record') || val.contains('verify')) return LegalNoticeStatus.published;
    if (val.contains('response')) return LegalNoticeStatus.responseReceived;
    if (val.contains('withdraw')) return LegalNoticeStatus.withdrawn;
    if (val.contains('close')) return LegalNoticeStatus.closed;
    if (val.contains('reject')) return LegalNoticeStatus.rejected;
    if (val.contains('archive')) return LegalNoticeStatus.archived;
    return LegalNoticeStatus.underReview;
  }
}

/// Structured Party Entity for Legal Notice
class NoticePartyEntity extends Equatable {
  final String name;
  final String role; // 'Notice Issued By', 'Issued To', 'Buyer', 'Seller', 'Owner', 'Claimant', 'Respondent', 'Builder', 'Agent', 'Bank', 'Authority', 'Other'
  final String? address;
  final String? contact;
  final String? advocateName;

  const NoticePartyEntity({
    required this.name,
    required this.role,
    this.address,
    this.contact,
    this.advocateName,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        if (address != null) 'address': address,
        if (contact != null) 'contact': contact,
        if (advocateName != null) 'advocateName': advocateName,
      };

  factory NoticePartyEntity.fromMap(Map<String, dynamic> map) => NoticePartyEntity(
        name: (map['name'] as String?) ?? '',
        role: (map['role'] as String?) ?? 'Notice Issued By',
        address: map['address'] as String?,
        contact: map['contact'] as String?,
        advocateName: map['advocateName'] as String?,
      );

  @override
  List<Object?> get props => [name, role, address, contact, advocateName];
}

/// Publication / Gazette / Newspaper Details
class NoticePublicationEntity extends Equatable {
  final bool isPublishedPublicly;
  final String? publicationDate;
  final String? publicationSource; // 'Newspaper', 'Gazette', 'Online Portal', 'Direct Service'
  final String? newspaperName;
  final String? edition;
  final String? pageNumber;
  final String? onlineReference;
  final String? advocateFirm;

  const NoticePublicationEntity({
    this.isPublishedPublicly = true,
    this.publicationDate,
    this.publicationSource,
    this.newspaperName,
    this.edition,
    this.pageNumber,
    this.onlineReference,
    this.advocateFirm,
  });

  Map<String, dynamic> toMap() => {
        'isPublishedPublicly': isPublishedPublicly,
        if (publicationDate != null) 'publicationDate': publicationDate,
        if (publicationSource != null) 'publicationSource': publicationSource,
        if (newspaperName != null) 'newspaperName': newspaperName,
        if (edition != null) 'edition': edition,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (onlineReference != null) 'onlineReference': onlineReference,
        if (advocateFirm != null) 'advocateFirm': advocateFirm,
      };

  factory NoticePublicationEntity.fromMap(Map<String, dynamic> map) => NoticePublicationEntity(
        isPublishedPublicly: (map['isPublishedPublicly'] as bool?) ?? true,
        publicationDate: map['publicationDate'] as String?,
        publicationSource: map['publicationSource'] as String?,
        newspaperName: map['newspaperName'] as String?,
        edition: map['edition'] as String?,
        pageNumber: map['pageNumber'] as String?,
        onlineReference: map['onlineReference'] as String?,
        advocateFirm: map['advocateFirm'] as String?,
      );

  @override
  List<Object?> get props => [
        isPublishedPublicly,
        publicationDate,
        publicationSource,
        newspaperName,
        edition,
        pageNumber,
        onlineReference,
        advocateFirm,
      ];
}

/// Comprehensive Property Purchase / Sale Legal Notice Entity (Phase 3 & Phase 6)
class TransactionLegalNoticeEntity extends Equatable {
  final String id;
  final String propertyId;
  final String title;
  final String category;
  final String propertyType;
  
  // Location Hierarchy
  final String country;
  final String state;
  final String? district;
  final String city;
  final String locality;
  final String? postalCode;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  
  // Property Identifiers
  final String? villageTaluk;
  final String? surveyCtsNumber;
  final String? khataNumber;
  final String? plotNumber;
  final String? flatUnitNumber;
  final String? buildingProjectName;
  final String? landArea;
  final String? areaUnit;

  // Primary Parties
  final String buyerName;
  final String? buyerAddress;
  final String? buyerAdvocate;
  final String sellerName;
  final String? sellerAddress;
  final List<NoticePartyEntity> structuredParties;

  // Contact Information (Private)
  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final String contactRole; // 'Buyer', 'Seller', 'Legal Advocate', 'Authorized Agent'

  // Transaction Context
  final String transactionType; // 'Purchase', 'Sale', 'Agreement to Sell', 'Lease', 'Partition', 'Gift Deed'
  final String? agreedValue;
  final String? agreementDate;
  final String? executionDate;
  final String transactionStatus; // 'Under Negotiation', 'Agreement Executed', 'Registration Scheduled', 'Completed'
  final String? transactionDescription;

  // Legal Notice Information & Text
  final LegalNoticeType noticeType;
  final String? issuingAuthority; // 'Sub-Registrar Office Belagavi', 'Civil Court', 'Self Notice'
  final String? referenceNumber;
  final String? noticeDate;
  final String? effectiveDate;
  final String? responseDeadline;
  final String? objectionPeriod;
  final String? publicNoticeSummary;
  final String? noticeFullText;
  final String? dueDiligenceNotes;

  // Publication Info
  final NoticePublicationEntity? publicationInfo;

  // Documents & Media
  final List<String> photoUrls;
  final List<String> documentUrls;
  final List<String> photoLabels;
  final List<String> documentLabels;
  final bool isDocumentPrivate;
  final bool canAddDocumentsLater;

  // Moderation & Metadata
  final LegalNoticeStatus verificationStatus;
  final String recordedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransactionLegalNoticeEntity({
    this.id = '',
    this.propertyId = '',
    required this.title,
    this.category = 'Residential',
    this.propertyType = 'Apartment',
    this.country = 'India',
    this.state = 'Karnataka',
    this.district,
    this.city = 'Belagavi',
    required this.locality,
    this.postalCode,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.villageTaluk,
    this.surveyCtsNumber,
    this.khataNumber,
    this.plotNumber,
    this.flatUnitNumber,
    this.buildingProjectName,
    this.landArea,
    this.areaUnit = 'sq.ft',
    this.buyerName = '',
    this.buyerAddress,
    this.buyerAdvocate,
    this.sellerName = '',
    this.sellerAddress,
    this.structuredParties = const [],
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.contactRole = 'Buyer / Purchaser',
    this.transactionType = 'Purchase',
    this.agreedValue,
    this.agreementDate,
    this.executionDate,
    this.transactionStatus = 'Under Negotiation / Proposed',
    this.transactionDescription,
    this.noticeType = LegalNoticeType.purchaseNotice,
    this.issuingAuthority = 'Sub-Registrar Office Belagavi',
    this.referenceNumber,
    this.noticeDate,
    this.effectiveDate,
    this.responseDeadline,
    this.objectionPeriod,
    this.publicNoticeSummary,
    this.noticeFullText,
    this.dueDiligenceNotes,
    this.publicationInfo,
    this.photoUrls = const [],
    this.documentUrls = const [],
    this.photoLabels = const [],
    this.documentLabels = const [],
    this.isDocumentPrivate = true,
    this.canAddDocumentsLater = true,
    this.verificationStatus = LegalNoticeStatus.underReview,
    this.recordedBy = 'User',
    this.createdAt,
    this.updatedAt,
  });

  DateTime get safeCreatedAt => createdAt ?? DateTime.now();
  DateTime get safeUpdatedAt => updatedAt ?? DateTime.now();

  TransactionLegalNoticeEntity copyWith({
    String? id,
    String? propertyId,
    String? title,
    String? category,
    String? propertyType,
    String? country,
    String? state,
    String? district,
    String? city,
    String? locality,
    String? postalCode,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? villageTaluk,
    String? surveyCtsNumber,
    String? khataNumber,
    String? plotNumber,
    String? flatUnitNumber,
    String? buildingProjectName,
    String? landArea,
    String? areaUnit,
    String? buyerName,
    String? buyerAddress,
    String? buyerAdvocate,
    String? sellerName,
    String? sellerAddress,
    List<NoticePartyEntity>? structuredParties,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? contactRole,
    String? transactionType,
    String? agreedValue,
    String? agreementDate,
    String? executionDate,
    String? transactionStatus,
    String? transactionDescription,
    LegalNoticeType? noticeType,
    String? issuingAuthority,
    String? referenceNumber,
    String? noticeDate,
    String? effectiveDate,
    String? responseDeadline,
    String? objectionPeriod,
    String? publicNoticeSummary,
    String? noticeFullText,
    String? dueDiligenceNotes,
    NoticePublicationEntity? publicationInfo,
    List<String>? photoUrls,
    List<String>? documentUrls,
    List<String>? photoLabels,
    List<String>? documentLabels,
    bool? isDocumentPrivate,
    bool? canAddDocumentsLater,
    LegalNoticeStatus? verificationStatus,
    String? recordedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionLegalNoticeEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      title: title ?? this.title,
      category: category ?? this.category,
      propertyType: propertyType ?? this.propertyType,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      postalCode: postalCode ?? this.postalCode,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      villageTaluk: villageTaluk ?? this.villageTaluk,
      surveyCtsNumber: surveyCtsNumber ?? this.surveyCtsNumber,
      khataNumber: khataNumber ?? this.khataNumber,
      plotNumber: plotNumber ?? this.plotNumber,
      flatUnitNumber: flatUnitNumber ?? this.flatUnitNumber,
      buildingProjectName: buildingProjectName ?? this.buildingProjectName,
      landArea: landArea ?? this.landArea,
      areaUnit: areaUnit ?? this.areaUnit,
      buyerName: buyerName ?? this.buyerName,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      buyerAdvocate: buyerAdvocate ?? this.buyerAdvocate,
      sellerName: sellerName ?? this.sellerName,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      structuredParties: structuredParties ?? this.structuredParties,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      contactRole: contactRole ?? this.contactRole,
      transactionType: transactionType ?? this.transactionType,
      agreedValue: agreedValue ?? this.agreedValue,
      agreementDate: agreementDate ?? this.agreementDate,
      executionDate: executionDate ?? this.executionDate,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      transactionDescription: transactionDescription ?? this.transactionDescription,
      noticeType: noticeType ?? this.noticeType,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      noticeDate: noticeDate ?? this.noticeDate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      responseDeadline: responseDeadline ?? this.responseDeadline,
      objectionPeriod: objectionPeriod ?? this.objectionPeriod,
      publicNoticeSummary: publicNoticeSummary ?? this.publicNoticeSummary,
      noticeFullText: noticeFullText ?? this.noticeFullText,
      dueDiligenceNotes: dueDiligenceNotes ?? this.dueDiligenceNotes,
      publicationInfo: publicationInfo ?? this.publicationInfo,
      photoUrls: photoUrls ?? this.photoUrls,
      documentUrls: documentUrls ?? this.documentUrls,
      photoLabels: photoLabels ?? this.photoLabels,
      documentLabels: documentLabels ?? this.documentLabels,
      isDocumentPrivate: isDocumentPrivate ?? this.isDocumentPrivate,
      canAddDocumentsLater: canAddDocumentsLater ?? this.canAddDocumentsLater,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'title': title,
      'category': category,
      'propertyType': propertyType,
      'country': country,
      'state': state,
      if (district != null) 'district': district,
      'city': city,
      'locality': locality,
      if (postalCode != null) 'postalCode': postalCode,
      if (fullAddress != null) 'fullAddress': fullAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (villageTaluk != null) 'villageTaluk': villageTaluk,
      if (surveyCtsNumber != null) 'surveyCtsNumber': surveyCtsNumber,
      if (khataNumber != null) 'khataNumber': khataNumber,
      if (plotNumber != null) 'plotNumber': plotNumber,
      if (flatUnitNumber != null) 'flatUnitNumber': flatUnitNumber,
      if (buildingProjectName != null) 'buildingProjectName': buildingProjectName,
      if (landArea != null) 'landArea': landArea,
      if (areaUnit != null) 'areaUnit': areaUnit,
      'buyerName': buyerName,
      if (buyerAddress != null) 'buyerAddress': buyerAddress,
      if (buyerAdvocate != null) 'buyerAdvocate': buyerAdvocate,
      'sellerName': sellerName,
      if (sellerAddress != null) 'sellerAddress': sellerAddress,
      'structuredParties': structuredParties.map((p) => p.toMap()).toList(),
      'contactName': contactName,
      'contactPhone': contactPhone,
      if (contactEmail != null) 'contactEmail': contactEmail,
      'contactRole': contactRole,
      'transactionType': transactionType,
      if (agreedValue != null) 'agreedValue': agreedValue,
      if (agreementDate != null) 'agreementDate': agreementDate,
      if (executionDate != null) 'executionDate': executionDate,
      'transactionStatus': transactionStatus,
      if (transactionDescription != null) 'transactionDescription': transactionDescription,
      'noticeType': noticeType.name,
      if (issuingAuthority != null) 'issuingAuthority': issuingAuthority,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (noticeDate != null) 'noticeDate': noticeDate,
      if (effectiveDate != null) 'effectiveDate': effectiveDate,
      if (responseDeadline != null) 'responseDeadline': responseDeadline,
      if (objectionPeriod != null) 'objectionPeriod': objectionPeriod,
      if (publicNoticeSummary != null) 'publicNoticeSummary': publicNoticeSummary,
      if (noticeFullText != null) 'noticeFullText': noticeFullText,
      if (dueDiligenceNotes != null) 'dueDiligenceNotes': dueDiligenceNotes,
      if (publicationInfo != null) 'publicationInfo': publicationInfo!.toMap(),
      'photoUrls': photoUrls,
      'documentUrls': documentUrls,
      'photoLabels': photoLabels,
      'documentLabels': documentLabels,
      'isDocumentPrivate': isDocumentPrivate,
      'canAddDocumentsLater': canAddDocumentsLater,
      'verificationStatus': verificationStatus.name,
      'recordedBy': recordedBy,
      'createdAt': safeCreatedAt.toIso8601String(),
      'updatedAt': safeUpdatedAt.toIso8601String(),
    };
  }

  factory TransactionLegalNoticeEntity.fromMap(Map<String, dynamic> map, [String? defaultId]) {
    final recordId = (map['id'] as String?) ?? defaultId ?? 'notice_${DateTime.now().millisecondsSinceEpoch}';
    final propId = (map['propertyId'] as String?) ?? (map['property_id'] as String?) ?? recordId;
    return TransactionLegalNoticeEntity(
      id: recordId,
      propertyId: propId,
      title: (map['title'] as String?) ?? 'Purchase / Sale Legal Notice',
      category: (map['category'] as String?) ?? 'Residential',
      propertyType: (map['propertyType'] as String?) ?? (map['property_type'] as String?) ?? 'Apartment',
      country: (map['country'] as String?) ?? 'India',
      state: (map['state'] as String?) ?? 'Karnataka',
      district: map['district'] as String?,
      city: (map['city'] as String?) ?? 'Belagavi',
      locality: (map['locality'] as String?) ?? 'Belagavi',
      postalCode: (map['postalCode'] as String?) ?? (map['postal_code'] as String?),
      fullAddress: (map['fullAddress'] as String?) ?? (map['full_address'] as String?),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      villageTaluk: (map['villageTaluk'] as String?) ?? (map['village_taluk'] as String?),
      surveyCtsNumber: (map['surveyCtsNumber'] as String?) ?? (map['survey_cts_number'] as String?),
      khataNumber: (map['khataNumber'] as String?) ?? (map['khata_number'] as String?),
      plotNumber: (map['plotNumber'] as String?) ?? (map['plot_number'] as String?),
      flatUnitNumber: (map['flatUnitNumber'] as String?) ?? (map['flat_unit_number'] as String?),
      buildingProjectName: (map['buildingProjectName'] as String?) ?? (map['building_project_name'] as String?),
      landArea: (map['landArea'] as String?) ?? (map['land_area'] as String?),
      areaUnit: (map['areaUnit'] as String?) ?? (map['area_unit'] as String?) ?? 'sq.ft',
      buyerName: (map['buyerName'] as String?) ?? (map['buyer_name'] as String?) ?? '',
      buyerAddress: (map['buyerAddress'] as String?) ?? (map['buyer_address'] as String?),
      buyerAdvocate: (map['buyerAdvocate'] as String?) ?? (map['buyer_advocate'] as String?),
      sellerName: (map['sellerName'] as String?) ?? (map['seller_name'] as String?) ?? '',
      sellerAddress: (map['sellerAddress'] as String?) ?? (map['seller_address'] as String?),
      structuredParties: (map['structuredParties'] as List?)
              ?.map((p) => NoticePartyEntity.fromMap(p as Map<String, dynamic>))
              .toList() ??
          const [],
      contactName: (map['contactName'] as String?) ?? (map['contact_name'] as String?) ?? 'Authorized Contact',
      contactPhone: (map['contactPhone'] as String?) ?? (map['contact_phone'] as String?) ?? '',
      contactEmail: (map['contactEmail'] as String?) ?? (map['contact_email'] as String?),
      contactRole: (map['contactRole'] as String?) ?? (map['contact_role'] as String?) ?? 'Buyer / Purchaser',
      transactionType: (map['transactionType'] as String?) ?? (map['transaction_type'] as String?) ?? 'Purchase',
      agreedValue: (map['agreedValue'] as String?) ?? (map['agreed_value'] as String?),
      agreementDate: (map['agreementDate'] as String?) ?? (map['agreement_date'] as String?),
      executionDate: (map['executionDate'] as String?) ?? (map['execution_date'] as String?),
      transactionStatus: (map['transactionStatus'] as String?) ?? (map['transaction_status'] as String?) ?? 'Under Negotiation / Proposed',
      transactionDescription: (map['transactionDescription'] as String?) ?? (map['transaction_description'] as String?),
      noticeType: LegalNoticeTypeExtension.fromString((map['noticeType'] as String?) ?? (map['notice_type'] as String?)),
      issuingAuthority: (map['issuingAuthority'] as String?) ?? (map['issuing_authority'] as String?),
      referenceNumber: (map['referenceNumber'] as String?) ?? (map['reference_number'] as String?),
      noticeDate: (map['noticeDate'] as String?) ?? (map['notice_date'] as String?),
      effectiveDate: (map['effectiveDate'] as String?) ?? (map['effective_date'] as String?),
      responseDeadline: (map['responseDeadline'] as String?) ?? (map['response_deadline'] as String?),
      objectionPeriod: (map['objectionPeriod'] as String?) ?? (map['objection_period'] as String?),
      publicNoticeSummary: (map['publicNoticeSummary'] as String?) ?? (map['public_notice_summary'] as String?),
      noticeFullText: (map['noticeFullText'] as String?) ?? (map['notice_full_text'] as String?),
      dueDiligenceNotes: (map['dueDiligenceNotes'] as String?) ?? (map['due_diligence_notes'] as String?),
      publicationInfo: map['publicationInfo'] != null
          ? NoticePublicationEntity.fromMap(map['publicationInfo'] as Map<String, dynamic>)
          : null,
      photoUrls: (map['photoUrls'] as List?)?.map((e) => e.toString()).toList() ??
          (map['photo_urls'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      documentUrls: (map['documentUrls'] as List?)?.map((e) => e.toString()).toList() ??
          (map['document_urls'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      photoLabels: (map['photoLabels'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      documentLabels: (map['documentLabels'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isDocumentPrivate: (map['isDocumentPrivate'] as bool?) ?? (map['is_document_private'] as bool?) ?? true,
      canAddDocumentsLater: (map['canAddDocumentsLater'] as bool?) ?? (map['can_add_documents_later'] as bool?) ?? true,
      verificationStatus: LegalNoticeStatusExtension.fromString((map['verificationStatus'] as String?) ?? (map['verification_status'] as String?)),
      recordedBy: (map['recordedBy'] as String?) ?? (map['recorded_by'] as String?) ?? 'Platform User',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        title,
        category,
        propertyType,
        country,
        state,
        district,
        city,
        locality,
        postalCode,
        fullAddress,
        latitude,
        longitude,
        villageTaluk,
        surveyCtsNumber,
        khataNumber,
        plotNumber,
        flatUnitNumber,
        buildingProjectName,
        landArea,
        areaUnit,
        buyerName,
        buyerAddress,
        buyerAdvocate,
        sellerName,
        sellerAddress,
        structuredParties,
        contactName,
        contactPhone,
        contactEmail,
        contactRole,
        transactionType,
        agreedValue,
        agreementDate,
        executionDate,
        transactionStatus,
        transactionDescription,
        noticeType,
        issuingAuthority,
        referenceNumber,
        noticeDate,
        effectiveDate,
        responseDeadline,
        objectionPeriod,
        publicNoticeSummary,
        noticeFullText,
        dueDiligenceNotes,
        publicationInfo,
        photoUrls,
        documentUrls,
        photoLabels,
        documentLabels,
        isDocumentPrivate,
        canAddDocumentsLater,
        verificationStatus,
        recordedBy,
        createdAt,
        updatedAt,
      ];
}

class DueDiligenceItemEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String requiredDocument;
  final String verificationAuthority;
  final bool isCrucial;

  const DueDiligenceItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredDocument,
    required this.verificationAuthority,
    this.isCrucial = true,
  });

  @override
  List<Object?> get props => [id, title, description, requiredDocument, verificationAuthority, isCrucial];
}

class LegalNoticeRepositoryData {
  static const List<DueDiligenceItemEntity> buyerChecklist = [
    DueDiligenceItemEntity(
      id: 'b_1',
      title: 'Ownership & Original Title Verification',
      description: 'Confirm that the seller is the sole legal owner and holds clear title without co-owner disputes.',
      requiredDocument: 'Original Title Deed / Sale Deed / Partition Deed',
      verificationAuthority: 'Sub-Registrar Office & Legal Advocate',
    ),
    DueDiligenceItemEntity(
      id: 'b_2',
      title: '30-Year Prior Title Chain',
      description: 'Trace the continuous sequence of ownership transfers over the past 30 years to detect breaks in title.',
      requiredDocument: 'Previous Title Deeds & Link Documents',
      verificationAuthority: 'Sub-Registrar Search & Advocate Title Report',
    ),
    DueDiligenceItemEntity(
      id: 'b_3',
      title: 'Encumbrance Certificate (Form 15 & Form 16)',
      description: 'Verify there are no registered mortgages, liens, legal attachments, or third-party liabilities.',
      requiredDocument: 'EC for minimum 15 to 30 years',
      verificationAuthority: 'Kaveri Online / Sub-Registrar Office',
    ),
    DueDiligenceItemEntity(
      id: 'b_4',
      title: 'Mutation Register & Revenue Records',
      description: 'Confirm the seller name is updated in government land revenue records and mutation registers.',
      requiredDocument: 'Mutation Register Extract & RTC (Pahani) / Khata Certificate',
      verificationAuthority: 'Bhoomi Karnataka / Revenue Department',
    ),
    DueDiligenceItemEntity(
      id: 'b_5',
      title: 'Property Tax & Utility Dues Clearance',
      description: 'Verify up-to-date property municipal tax payments and absence of unpaid electricity/water arrears.',
      requiredDocument: 'Latest Tax Paid Receipts & Nil Dues Certificate',
      verificationAuthority: 'Belagavi City Corporation / Gram Panchayat / HESCOM',
    ),
    DueDiligenceItemEntity(
      id: 'b_6',
      title: 'Survey Records & Official Tippani / Akarband',
      description: 'Verify land boundaries, survey number, and physical sketch match government revenue maps.',
      requiredDocument: 'Survey Sketch / Tippani / Akarband / Form 11E',
      verificationAuthority: 'Survey Department / Bhoomi',
    ),
    DueDiligenceItemEntity(
      id: 'b_7',
      title: 'Land Conversion (NA Order) for Non-Agri Land',
      description: 'Verify valid Non-Agricultural conversion order under Karnataka Land Revenue Act where applicable.',
      requiredDocument: 'Official DC NA Conversion Order & Challan',
      verificationAuthority: 'Deputy Commissioner Office / Revenue Dept',
    ),
    DueDiligenceItemEntity(
      id: 'b_8',
      title: 'Layout & Building Plan Approvals',
      description: 'Verify layout sanctions from statutory urban planning authorities (BUDA / Town Planning).',
      requiredDocument: 'Approved Layout Plan & Sanctioned Building Plan',
      verificationAuthority: 'Belagavi Urban Development Authority (BUDA) / City Corp',
    ),
    DueDiligenceItemEntity(
      id: 'b_9',
      title: 'RERA Registration for Projects',
      description: 'For ongoing developer/builder projects, verify project RERA registration number and compliance.',
      requiredDocument: 'Karnataka RERA Registration Certificate',
      verificationAuthority: 'K-RERA Portal (rera.karnataka.gov.in)',
    ),
    DueDiligenceItemEntity(
      id: 'b_10',
      title: 'Existing Bank Mortgage / Loan Non-Encumbrance',
      description: 'Confirm the property is not mortgaged to any bank, housing finance corporation, or NBFC.',
      requiredDocument: 'Bank NOC / Nil-Encumbrance Letter / Original Deeds Possession',
      verificationAuthority: 'Seller Banker / CERSAI Search',
    ),
    DueDiligenceItemEntity(
      id: 'b_11',
      title: 'Litigation & Court Case Search',
      description: 'Conduct search in local civil courts to verify no pending suit, injunction, or partition litigation.',
      requiredDocument: 'Civil Court Search Report / Public Notice Publication',
      verificationAuthority: 'Belagavi District & Sessions Court',
    ),
    DueDiligenceItemEntity(
      id: 'b_12',
      title: 'Power of Attorney (POA) Scrutiny',
      description: 'If executed via POA, verify if GPA is registered, subsisting, not revoked, and principal is alive.',
      requiredDocument: 'Registered Power of Attorney & Life Certificate',
      verificationAuthority: 'Sub-Registrar Office',
    ),
    DueDiligenceItemEntity(
      id: 'b_13',
      title: 'Physical Site Inspection & Boundary Demarcation',
      description: 'Inspect physical possession, access roads, boundary markers, and ensure no unauthorized encroachment.',
      requiredDocument: 'Physical Site Verification & Boundary Demarcation',
      verificationAuthority: 'Buyer Physical Verification & Licensed Surveyor',
    ),
  ];

  static const List<DueDiligenceItemEntity> sellerChecklist = [
    DueDiligenceItemEntity(
      id: 's_1',
      title: 'Original Title Deeds & Possession Chain',
      description: 'Ensure original parent sale deeds and partition agreements are organized and readily available for buyer inspection.',
      requiredDocument: 'Original Registered Deeds',
      verificationAuthority: 'Self / Custodian Bank',
    ),
    DueDiligenceItemEntity(
      id: 's_2',
      title: 'Clear Encumbrance Certificate (Form 15)',
      description: 'Procure updated Encumbrance Certificate up to the current date showing nil third-party claims.',
      requiredDocument: 'Updated EC Certificate',
      verificationAuthority: 'Kaveri Sub-Registrar Portal',
    ),
    DueDiligenceItemEntity(
      id: 's_3',
      title: 'Updated Khata / RTC in Seller Name',
      description: 'Confirm property Khata (A Khata / E-Khata) or agricultural RTC strictly reflects the seller as registered title holder.',
      requiredDocument: 'E-Khata Extract / RTC / Mutation Certificate',
      verificationAuthority: 'Belagavi Corporation / Gram Panchayat / Bhoomi',
    ),
    DueDiligenceItemEntity(
      id: 's_4',
      title: 'Property Tax & Utility Dues Clearance',
      description: 'Clear all pending property tax, water supply, and electricity bills to obtain zero-dues receipt.',
      requiredDocument: 'Latest Tax & Utility Paid Receipts',
      verificationAuthority: 'Municipal Corp / HESCOM',
    ),
    DueDiligenceItemEntity(
      id: 's_5',
      title: 'Loan Closure & Bank NOC / Release Deed',
      description: 'If previously mortgaged, obtain formal Bank Loan Closure Certificate, NOC, and registered Discharge Deed.',
      requiredDocument: 'Bank Release Deed & Loan Closure NOC',
      verificationAuthority: 'Lending Bank / Sub-Registrar',
    ),
    DueDiligenceItemEntity(
      id: 's_6',
      title: 'Co-Owners / Legal Heirs Consent & NOC',
      description: 'In joint or ancestral properties, secure registered consent or signature of all co-owners and legal heirs.',
      requiredDocument: 'Co-owners Consent Deed / Family Tree Certificate',
      verificationAuthority: 'Revenue Authority / Notary / Sub-Registrar',
    ),
    DueDiligenceItemEntity(
      id: 's_7',
      title: 'Transparent Litigation & Dispute Disclosure',
      description: 'Disclose any past or pending litigation, revenue notices, or tenancy agreements in the draft sale agreement.',
      requiredDocument: 'Formal Legal Disclosure in Agreement to Sell',
      verificationAuthority: 'Draft Sale Agreement',
    ),
  ];
}

/// Advanced Workflow Status for End-to-End Legal Notice & Dispute Assistance Module
enum LegalMatterStatus {
  draft,
  informationRequired,
  draftReady,
  reviewRequested,
  underReview,
  changesRequested,
  reviewed,
  finalReady,
  finalized,
  servicePending,
  served,
  responseReceived,
  followUpDue,
  closed,
  archived,
}

extension LegalMatterStatusExtension on LegalMatterStatus {
  String get dbValue => switch (this) {
        LegalMatterStatus.draft => 'draft',
        LegalMatterStatus.informationRequired => 'information_required',
        LegalMatterStatus.draftReady => 'draft_ready',
        LegalMatterStatus.reviewRequested => 'review_requested',
        LegalMatterStatus.underReview => 'under_review',
        LegalMatterStatus.changesRequested => 'changes_requested',
        LegalMatterStatus.reviewed => 'reviewed',
        LegalMatterStatus.finalReady => 'final_ready',
        LegalMatterStatus.finalized => 'finalized',
        LegalMatterStatus.servicePending => 'service_pending',
        LegalMatterStatus.served => 'served',
        LegalMatterStatus.responseReceived => 'response_received',
        LegalMatterStatus.followUpDue => 'follow_up_due',
        LegalMatterStatus.closed => 'closed',
        LegalMatterStatus.archived => 'archived',
      };

  String get displayName => switch (this) {
        LegalMatterStatus.draft => 'Draft Matter',
        LegalMatterStatus.informationRequired => 'Needs Information',
        LegalMatterStatus.draftReady => 'Draft Ready',
        LegalMatterStatus.reviewRequested => 'Review Requested',
        LegalMatterStatus.underReview => 'Under Advocate Review',
        LegalMatterStatus.changesRequested => 'Changes Requested',
        LegalMatterStatus.reviewed => 'Review Completed',
        LegalMatterStatus.finalReady => 'Ready to Finalize',
        LegalMatterStatus.finalized => 'Finalized Notice',
        LegalMatterStatus.servicePending => 'Service Pending',
        LegalMatterStatus.served => 'Statutorily Served',
        LegalMatterStatus.responseReceived => 'Response Received',
        LegalMatterStatus.followUpDue => 'Follow-up Due',
        LegalMatterStatus.closed => 'Closed Matter',
        LegalMatterStatus.archived => 'Archived Matter',
      };

  Color get color => switch (this) {
        LegalMatterStatus.draft || LegalMatterStatus.informationRequired => Colors.orange,
        LegalMatterStatus.draftReady || LegalMatterStatus.finalReady => Colors.blue,
        LegalMatterStatus.reviewRequested || LegalMatterStatus.underReview => Colors.purple,
        LegalMatterStatus.changesRequested => Colors.deepOrange,
        LegalMatterStatus.reviewed || LegalMatterStatus.finalized => Colors.green,
        LegalMatterStatus.servicePending => Colors.amber.shade800,
        LegalMatterStatus.served => Colors.teal,
        LegalMatterStatus.responseReceived => Colors.indigo,
        LegalMatterStatus.followUpDue => Colors.redAccent,
        LegalMatterStatus.closed || LegalMatterStatus.archived => Colors.blueGrey,
      };

  static LegalMatterStatus fromString(String? val) {
    if (val == null) return LegalMatterStatus.draft;
    final norm = val.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    for (final s in LegalMatterStatus.values) {
      if (s.name.toLowerCase() == norm || s.dbValue.replaceAll('_', '') == norm) {
        return s;
      }
    }
    return LegalMatterStatus.draft;
  }
}

/// Structured Legal Fact / Chronology Entry
class LegalFactEntity extends Equatable {
  final String id;
  final String dateString;
  final String eventDescription;
  final String source; // 'USER_STATED', 'DOCUMENT_EXTRACTED', 'SYSTEM_DERIVED', 'REVIEWER_CONFIRMED'
  final bool isSupportedByDocument;

  const LegalFactEntity({
    required this.id,
    required this.dateString,
    required this.eventDescription,
    this.source = 'USER_STATED',
    this.isSupportedByDocument = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'dateString': dateString,
        'eventDescription': eventDescription,
        'source': source,
        'isSupportedByDocument': isSupportedByDocument,
      };

  factory LegalFactEntity.fromMap(Map<String, dynamic> map) => LegalFactEntity(
        id: (map['id'] as String?) ?? 'fact_${DateTime.now().millisecondsSinceEpoch}',
        dateString: (map['dateString'] as String?) ?? '',
        eventDescription: (map['eventDescription'] as String?) ?? '',
        source: (map['source'] as String?) ?? 'USER_STATED',
        isSupportedByDocument: (map['isSupportedByDocument'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [id, dateString, eventDescription, source, isSupportedByDocument];
}

/// Immutable Draft Version Entry
class LegalNoticeVersionEntity extends Equatable {
  final String id;
  final int versionNumber;
  final String contentMarkdown;
  final String generatedByType; // USER_STATED, SYSTEM_DERIVED, ADVOCATE_REVIEWED
  final String? reasonForChange;
  final String createdBy;
  final DateTime createdAt;

  const LegalNoticeVersionEntity({
    required this.id,
    required this.versionNumber,
    required this.contentMarkdown,
    this.generatedByType = 'USER_STATED',
    this.reasonForChange,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'versionNumber': versionNumber,
        'contentMarkdown': contentMarkdown,
        'generatedByType': generatedByType,
        if (reasonForChange != null) 'reasonForChange': reasonForChange,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LegalNoticeVersionEntity.fromMap(Map<String, dynamic> map) => LegalNoticeVersionEntity(
        id: (map['id'] as String?) ?? 'ver_${DateTime.now().millisecondsSinceEpoch}',
        versionNumber: (map['versionNumber'] as int?) ?? 1,
        contentMarkdown: (map['contentMarkdown'] as String?) ?? '',
        generatedByType: (map['generatedByType'] as String?) ?? 'USER_STATED',
        reasonForChange: map['reasonForChange'] as String?,
        createdBy: (map['createdBy'] as String?) ?? 'User',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [id, versionNumber, contentMarkdown, generatedByType, reasonForChange, createdBy, createdAt];
}

/// Postal / RPAD / Speed Post Service Attempt Entity
class LegalServiceAttemptEntity extends Equatable {
  final String id;
  final String serviceMethod; // 'Registered Post AD', 'Speed Post', 'Personal Delivery', 'Email', 'WhatsApp (Supplementary)'
  final String provider; // 'India Post', 'Professional Courier', etc.
  final String? trackingNumber;
  final String dispatchDate;
  final String? deliveryDate;
  final String serviceStatus; // 'Dispatched', 'Delivered', 'Returned Unclaimed', 'Refused', 'Pending'
  final String? proofDocumentId;

  const LegalServiceAttemptEntity({
    required this.id,
    this.serviceMethod = 'Registered Post AD',
    this.provider = 'India Post',
    this.trackingNumber,
    required this.dispatchDate,
    this.deliveryDate,
    this.serviceStatus = 'Dispatched',
    this.proofDocumentId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'serviceMethod': serviceMethod,
        'provider': provider,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        'dispatchDate': dispatchDate,
        if (deliveryDate != null) 'deliveryDate': deliveryDate,
        'serviceStatus': serviceStatus,
        if (proofDocumentId != null) 'proofDocumentId': proofDocumentId,
      };

  factory LegalServiceAttemptEntity.fromMap(Map<String, dynamic> map) => LegalServiceAttemptEntity(
        id: (map['id'] as String?) ?? 'service_${DateTime.now().millisecondsSinceEpoch}',
        serviceMethod: (map['serviceMethod'] as String?) ?? 'Registered Post AD',
        provider: (map['provider'] as String?) ?? 'India Post',
        trackingNumber: map['trackingNumber'] as String?,
        dispatchDate: (map['dispatchDate'] as String?) ?? '',
        deliveryDate: map['deliveryDate'] as String?,
        serviceStatus: (map['serviceStatus'] as String?) ?? 'Dispatched',
        proofDocumentId: map['proofDocumentId'] as String?,
      );

  @override
  List<Object?> get props => [id, serviceMethod, provider, trackingNumber, dispatchDate, deliveryDate, serviceStatus, proofDocumentId];
}

/// Counter-Notice / Reply Response Entity
class LegalResponseEntity extends Equatable {
  final String id;
  final String responseType; // 'Reply Notice', 'Settlement Offer', 'Rejection', 'Counter Demand'
  final String senderName;
  final String responseDate;
  final String summaryText;
  final String? documentId;

  const LegalResponseEntity({
    required this.id,
    this.responseType = 'Reply Notice',
    required this.senderName,
    required this.responseDate,
    required this.summaryText,
    this.documentId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'responseType': responseType,
        'senderName': senderName,
        'responseDate': responseDate,
        'summaryText': summaryText,
        if (documentId != null) 'documentId': documentId,
      };

  factory LegalResponseEntity.fromMap(Map<String, dynamic> map) => LegalResponseEntity(
        id: (map['id'] as String?) ?? 'resp_${DateTime.now().millisecondsSinceEpoch}',
        responseType: (map['responseType'] as String?) ?? 'Reply Notice',
        senderName: (map['senderName'] as String?) ?? '',
        responseDate: (map['responseDate'] as String?) ?? '',
        summaryText: (map['summaryText'] as String?) ?? '',
        documentId: map['documentId'] as String?,
      );

  @override
  List<Object?> get props => [id, responseType, senderName, responseDate, summaryText, documentId];
}

/// Immutable Timeline Audit Log Entity
class LegalAuditEventEntity extends Equatable {
  final String id;
  final String eventType;
  final String description;
  final String actorId;
  final DateTime createdAt;

  const LegalAuditEventEntity({
    required this.id,
    required this.eventType,
    required this.description,
    required this.actorId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'eventType': eventType,
        'description': description,
        'actorId': actorId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LegalAuditEventEntity.fromMap(Map<String, dynamic> map) => LegalAuditEventEntity(
        id: (map['id'] as String?) ?? 'audit_${DateTime.now().millisecondsSinceEpoch}',
        eventType: (map['eventType'] as String?) ?? 'EVENT',
        description: (map['description'] as String?) ?? '',
        actorId: (map['actorId'] as String?) ?? 'System',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [id, eventType, description, actorId, createdAt];
}

/// Complete End-to-End Property Legal Matter Model
class LegalMatterEntity extends Equatable {
  final String id;
  final String userId;
  final String? propertyId;
  final String matterReference;
  final String title;
  final String category;
  final LegalNoticeType noticeType;
  final LegalMatterStatus status;
  final bool isHighRisk;
  final bool requiresAdvocateReview;
  final String? assignedAdvocateId;

  // Location & Snapshot
  final String country;
  final String state;
  final String district;
  final String city;
  final String locality;
  final String? fullAddress;
  final String? surveyCtsNumber;
  final String? khataNumber;
  final String? plotFlatNumber;

  // Financial Context
  final double financialClaimAmount;
  final double agreedTotalConsideration;
  final double amountPaidSoFar;
  final double interestRateClaimed;

  // Key Dates
  final String? agreementDate;
  final String? breachDefaultDate;
  final String? noticeSentDate;
  final String? responseDueDate;

  // Desired Relief
  final String desiredRemedy;

  // Embedded Structured Lists
  final List<NoticePartyEntity> parties;
  final List<LegalFactEntity> chronology;
  final List<LegalNoticeVersionEntity> versionHistory;
  final List<LegalServiceAttemptEntity> serviceAttempts;
  final List<LegalResponseEntity> responses;
  final List<LegalAuditEventEntity> auditTimeline;

  final DateTime createdAt;
  final DateTime updatedAt;

  const LegalMatterEntity({
    required this.id,
    required this.userId,
    this.propertyId,
    required this.matterReference,
    required this.title,
    this.category = 'Tenancy / Lease Dispute',
    this.noticeType = LegalNoticeType.tenantLandlordNotice,
    this.status = LegalMatterStatus.draft,
    this.isHighRisk = false,
    this.requiresAdvocateReview = false,
    this.assignedAdvocateId,
    this.country = 'India',
    this.state = 'Karnataka',
    this.district = 'Belagavi',
    this.city = 'Belagavi',
    this.locality = 'Belagavi',
    this.fullAddress,
    this.surveyCtsNumber,
    this.khataNumber,
    this.plotFlatNumber,
    this.financialClaimAmount = 0.0,
    this.agreedTotalConsideration = 0.0,
    this.amountPaidSoFar = 0.0,
    this.interestRateClaimed = 0.0,
    this.agreementDate,
    this.breachDefaultDate,
    this.noticeSentDate,
    this.responseDueDate,
    this.desiredRemedy = 'Payment of arrears and possession of premises',
    this.parties = const [],
    this.chronology = const [],
    this.versionHistory = const [],
    this.serviceAttempts = const [],
    this.responses = const [],
    this.auditTimeline = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  LegalMatterEntity copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? matterReference,
    String? title,
    String? category,
    LegalNoticeType? noticeType,
    LegalMatterStatus? status,
    bool? isHighRisk,
    bool? requiresAdvocateReview,
    String? assignedAdvocateId,
    String? country,
    String? state,
    String? district,
    String? city,
    String? locality,
    String? fullAddress,
    String? surveyCtsNumber,
    String? khataNumber,
    String? plotFlatNumber,
    double? financialClaimAmount,
    double? agreedTotalConsideration,
    double? amountPaidSoFar,
    double? interestRateClaimed,
    String? agreementDate,
    String? breachDefaultDate,
    String? noticeSentDate,
    String? responseDueDate,
    String? desiredRemedy,
    List<NoticePartyEntity>? parties,
    List<LegalFactEntity>? chronology,
    List<LegalNoticeVersionEntity>? versionHistory,
    List<LegalServiceAttemptEntity>? serviceAttempts,
    List<LegalResponseEntity>? responses,
    List<LegalAuditEventEntity>? auditTimeline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LegalMatterEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      matterReference: matterReference ?? this.matterReference,
      title: title ?? this.title,
      category: category ?? this.category,
      noticeType: noticeType ?? this.noticeType,
      status: status ?? this.status,
      isHighRisk: isHighRisk ?? this.isHighRisk,
      requiresAdvocateReview: requiresAdvocateReview ?? this.requiresAdvocateReview,
      assignedAdvocateId: assignedAdvocateId ?? this.assignedAdvocateId,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      fullAddress: fullAddress ?? this.fullAddress,
      surveyCtsNumber: surveyCtsNumber ?? this.surveyCtsNumber,
      khataNumber: khataNumber ?? this.khataNumber,
      plotFlatNumber: plotFlatNumber ?? this.plotFlatNumber,
      financialClaimAmount: financialClaimAmount ?? this.financialClaimAmount,
      agreedTotalConsideration: agreedTotalConsideration ?? this.agreedTotalConsideration,
      amountPaidSoFar: amountPaidSoFar ?? this.amountPaidSoFar,
      interestRateClaimed: interestRateClaimed ?? this.interestRateClaimed,
      agreementDate: agreementDate ?? this.agreementDate,
      breachDefaultDate: breachDefaultDate ?? this.breachDefaultDate,
      noticeSentDate: noticeSentDate ?? this.noticeSentDate,
      responseDueDate: responseDueDate ?? this.responseDueDate,
      desiredRemedy: desiredRemedy ?? this.desiredRemedy,
      parties: parties ?? this.parties,
      chronology: chronology ?? this.chronology,
      versionHistory: versionHistory ?? this.versionHistory,
      serviceAttempts: serviceAttempts ?? this.serviceAttempts,
      responses: responses ?? this.responses,
      auditTimeline: auditTimeline ?? this.auditTimeline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        if (propertyId != null) 'property_id': propertyId,
        'matter_reference': matterReference,
        'title': title,
        'category': category,
        'notice_type': noticeType.name,
        'status': status.dbValue,
        'is_high_risk': isHighRisk,
        'requires_advocate_review': requiresAdvocateReview,
        if (assignedAdvocateId != null) 'assigned_advocate_id': assignedAdvocateId,
        'country': country,
        'state': state,
        'district': district,
        'city': city,
        'locality': locality,
        if (fullAddress != null) 'full_address': fullAddress,
        if (surveyCtsNumber != null) 'survey_cts_number': surveyCtsNumber,
        if (khataNumber != null) 'khata_number': khataNumber,
        if (plotFlatNumber != null) 'plot_flat_number': plotFlatNumber,
        'financial_claim_amount': financialClaimAmount,
        'agreed_total_consideration': agreedTotalConsideration,
        'amount_paid_so_far': amountPaidSoFar,
        'interest_rate_claimed': interestRateClaimed,
        if (agreementDate != null) 'agreement_date': agreementDate,
        if (breachDefaultDate != null) 'breach_default_date': breachDefaultDate,
        if (noticeSentDate != null) 'notice_sent_date': noticeSentDate,
        if (responseDueDate != null) 'response_due_date': responseDueDate,
        'desired_remedy': desiredRemedy,
        'parties': parties.map((p) => p.toMap()).toList(),
        'chronology': chronology.map((c) => c.toMap()).toList(),
        'versionHistory': versionHistory.map((v) => v.toMap()).toList(),
        'serviceAttempts': serviceAttempts.map((s) => s.toMap()).toList(),
        'responses': responses.map((r) => r.toMap()).toList(),
        'auditTimeline': auditTimeline.map((a) => a.toMap()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory LegalMatterEntity.fromMap(Map<String, dynamic> map) {
    final mId = (map['id'] as String?) ?? 'matter_${DateTime.now().millisecondsSinceEpoch}';
    return LegalMatterEntity(
      id: mId,
      userId: (map['user_id'] as String?) ?? (map['userId'] as String?) ?? '',
      propertyId: (map['property_id'] as String?) ?? (map['propertyId'] as String?),
      matterReference: (map['matter_reference'] as String?) ?? (map['matterReference'] as String?) ?? 'LGL-BEL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: (map['title'] as String?) ?? 'Property Legal Matter',
      category: (map['category'] as String?) ?? 'Tenancy / Lease Dispute',
      noticeType: LegalNoticeTypeExtension.fromString((map['notice_type'] as String?) ?? (map['noticeType'] as String?)),
      status: LegalMatterStatusExtension.fromString((map['status'] as String?)),
      isHighRisk: (map['is_high_risk'] as bool?) ?? (map['isHighRisk'] as bool?) ?? false,
      requiresAdvocateReview: (map['requires_advocate_review'] as bool?) ?? (map['requiresAdvocateReview'] as bool?) ?? false,
      assignedAdvocateId: (map['assigned_advocate_id'] as String?) ?? (map['assignedAdvocateId'] as String?),
      country: (map['country'] as String?) ?? 'India',
      state: (map['state'] as String?) ?? 'Karnataka',
      district: (map['district'] as String?) ?? 'Belagavi',
      city: (map['city'] as String?) ?? 'Belagavi',
      locality: (map['locality'] as String?) ?? 'Belagavi',
      fullAddress: (map['full_address'] as String?) ?? (map['fullAddress'] as String?),
      surveyCtsNumber: (map['survey_cts_number'] as String?) ?? (map['surveyCtsNumber'] as String?),
      khataNumber: (map['khata_number'] as String?) ?? (map['khataNumber'] as String?),
      plotFlatNumber: (map['plot_flat_number'] as String?) ?? (map['plotFlatNumber'] as String?),
      financialClaimAmount: (map['financial_claim_amount'] as num?)?.toDouble() ?? (map['financialClaimAmount'] as num?)?.toDouble() ?? 0.0,
      agreedTotalConsideration: (map['agreed_total_consideration'] as num?)?.toDouble() ?? (map['agreedTotalConsideration'] as num?)?.toDouble() ?? 0.0,
      amountPaidSoFar: (map['amount_paid_so_far'] as num?)?.toDouble() ?? (map['amountPaidSoFar'] as num?)?.toDouble() ?? 0.0,
      interestRateClaimed: (map['interest_rate_claimed'] as num?)?.toDouble() ?? (map['interestRateClaimed'] as num?)?.toDouble() ?? 0.0,
      agreementDate: (map['agreement_date'] as String?) ?? (map['agreementDate'] as String?),
      breachDefaultDate: (map['breach_default_date'] as String?) ?? (map['breachDefaultDate'] as String?),
      noticeSentDate: (map['notice_sent_date'] as String?) ?? (map['noticeSentDate'] as String?),
      responseDueDate: (map['response_due_date'] as String?) ?? (map['responseDueDate'] as String?),
      desiredRemedy: (map['desired_remedy'] as String?) ?? (map['desiredRemedy'] as String?) ?? 'Legal remedy and compliance demand',
      parties: (map['parties'] as List?)
              ?.map((p) => NoticePartyEntity.fromMap(p as Map<String, dynamic>))
              .toList() ??
          const [],
      chronology: (map['chronology'] as List?)
              ?.map((c) => LegalFactEntity.fromMap(c as Map<String, dynamic>))
              .toList() ??
          const [],
      versionHistory: (map['versionHistory'] as List?)
              ?.map((v) => LegalNoticeVersionEntity.fromMap(v as Map<String, dynamic>))
              .toList() ??
          const [],
      serviceAttempts: (map['serviceAttempts'] as List?)
              ?.map((s) => LegalServiceAttemptEntity.fromMap(s as Map<String, dynamic>))
              .toList() ??
          const [],
      responses: (map['responses'] as List?)
              ?.map((r) => LegalResponseEntity.fromMap(r as Map<String, dynamic>))
              .toList() ??
          const [],
      auditTimeline: (map['auditTimeline'] as List?)
              ?.map((a) => LegalAuditEventEntity.fromMap(a as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : map['updatedAt'] != null
              ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        propertyId,
        matterReference,
        title,
        category,
        noticeType,
        status,
        isHighRisk,
        requiresAdvocateReview,
        assignedAdvocateId,
        country,
        state,
        district,
        city,
        locality,
        fullAddress,
        surveyCtsNumber,
        khataNumber,
        plotFlatNumber,
        financialClaimAmount,
        agreedTotalConsideration,
        amountPaidSoFar,
        interestRateClaimed,
        agreementDate,
        breachDefaultDate,
        noticeSentDate,
        responseDueDate,
        desiredRemedy,
        parties,
        chronology,
        versionHistory,
        serviceAttempts,
        responses,
        auditTimeline,
        createdAt,
        updatedAt,
      ];
}