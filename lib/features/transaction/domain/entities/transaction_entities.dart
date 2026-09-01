import 'package:equatable/equatable.dart';

enum TransactionInterestType { buy, rent, lease }

extension TransactionInterestTypeExtension on TransactionInterestType {
  String get displayName => switch (this) {
        TransactionInterestType.buy => 'Purchase / Buy',
        TransactionInterestType.rent => 'Rental',
        TransactionInterestType.lease => 'Commercial Lease',
      };

  static TransactionInterestType fromString(String? val) {
    if (val == null) return TransactionInterestType.buy;
    return TransactionInterestType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.displayName.toLowerCase() == val.toLowerCase(),
      orElse: () => TransactionInterestType.buy,
    );
  }
}

enum TransactionStatus {
  newEnquiry,
  contacted,
  inDiscussion,
  siteVisit,
  siteVisitRequested,
  siteVisitScheduled,
  negotiation,
  documents,
  documentVerification,
  closed,
  rejected,
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName => switch (this) {
        TransactionStatus.newEnquiry => 'New Enquiry',
        TransactionStatus.contacted => 'Contacted',
        TransactionStatus.inDiscussion => 'In Discussion',
        TransactionStatus.siteVisit || TransactionStatus.siteVisitRequested || TransactionStatus.siteVisitScheduled => 'Site Visit Stage',
        TransactionStatus.negotiation => 'Offer / Negotiation',
        TransactionStatus.documents || TransactionStatus.documentVerification => 'Document Due Diligence',
        TransactionStatus.closed => 'Deal Closed / Completed',
        TransactionStatus.rejected => 'Enquiry Closed / Inactive',
      };

  static TransactionStatus fromString(String? val) {
    if (val == null) return TransactionStatus.newEnquiry;
    return TransactionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.displayName.toLowerCase() == val.toLowerCase(),
      orElse: () => TransactionStatus.newEnquiry,
    );
  }
}

enum SiteVisitStatus {
  none,
  requested,
  confirmed,
  scheduled,
  rescheduleRequested,
  rescheduled,
  cancelled,
  completed,
}

extension SiteVisitStatusExtension on SiteVisitStatus {
  String get displayName => switch (this) {
        SiteVisitStatus.none => 'Not Scheduled',
        SiteVisitStatus.requested => 'Visit Requested by Buyer',
        SiteVisitStatus.confirmed || SiteVisitStatus.scheduled => 'Visit Confirmed',
        SiteVisitStatus.rescheduleRequested || SiteVisitStatus.rescheduled => 'Reschedule Requested',
        SiteVisitStatus.cancelled => 'Visit Cancelled',
        SiteVisitStatus.completed => 'Visit Completed',
      };

  static SiteVisitStatus fromString(String? val) {
    if (val == null) return SiteVisitStatus.none;
    return SiteVisitStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SiteVisitStatus.none,
    );
  }
}

enum OfferLifecycleStatus {
  submitted,
  viewed,
  accepted,
  countered,
  rejected,
  withdrawn,
  expired,
}

extension OfferLifecycleStatusExtension on OfferLifecycleStatus {
  String get displayName => switch (this) {
        OfferLifecycleStatus.submitted => 'Offer Submitted',
        OfferLifecycleStatus.viewed => 'Offer Viewed by Owner',
        OfferLifecycleStatus.accepted => 'Offer Accepted (Subject to Diligence)',
        OfferLifecycleStatus.countered => 'Counter Offer Proposed',
        OfferLifecycleStatus.rejected => 'Offer Declined',
        OfferLifecycleStatus.withdrawn => 'Offer Withdrawn by Buyer',
        OfferLifecycleStatus.expired => 'Offer Expired',
      };

  static OfferLifecycleStatus fromString(String? val) {
    if (val == null) return OfferLifecycleStatus.submitted;
    return OfferLifecycleStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => OfferLifecycleStatus.submitted,
    );
  }
}

enum DocVerificationStatus {
  notStarted,
  documentsRequested,
  documentsSubmitted,
  underReview,
  verificationComplete,
  issueFound,
}

extension DocVerificationStatusExtension on DocVerificationStatus {
  String get displayName => switch (this) {
        DocVerificationStatus.notStarted => 'Not Started',
        DocVerificationStatus.documentsRequested => 'Documents Requested',
        DocVerificationStatus.documentsSubmitted => 'Documents Submitted',
        DocVerificationStatus.underReview => 'Under Legal Review',
        DocVerificationStatus.verificationComplete => 'Verification Complete (Platform Review)',
        DocVerificationStatus.issueFound => 'Discrepancy / Issue Flagged',
      };

  static DocVerificationStatus fromString(String? val) {
    if (val == null) return DocVerificationStatus.notStarted;
    return DocVerificationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => DocVerificationStatus.notStarted,
    );
  }
}

class NegotiationOfferEvent extends Equatable {
  final String id;
  final String enquiryId;
  final String submittedByUserId;
  final String submittedByName;
  final bool isBuyerOffer;
  final double offerAmount;
  final double? monthlyRent;
  final double? depositAmount;
  final int? leaseDurationMonths;
  final double? maintenanceCharges;
  final String? termsAndConditions;
  final OfferLifecycleStatus status;
  final DateTime createdAt;

  const NegotiationOfferEvent({
    required this.id,
    required this.enquiryId,
    required this.submittedByUserId,
    required this.submittedByName,
    required this.isBuyerOffer,
    required this.offerAmount,
    this.monthlyRent,
    this.depositAmount,
    this.leaseDurationMonths,
    this.maintenanceCharges,
    this.termsAndConditions,
    this.status = OfferLifecycleStatus.submitted,
    required this.createdAt,
  });

  NegotiationOfferEvent copyWith({
    String? id,
    String? enquiryId,
    String? submittedByUserId,
    String? submittedByName,
    bool? isBuyerOffer,
    double? offerAmount,
    double? monthlyRent,
    double? depositAmount,
    int? leaseDurationMonths,
    double? maintenanceCharges,
    String? termsAndConditions,
    OfferLifecycleStatus? status,
    DateTime? createdAt,
  }) {
    return NegotiationOfferEvent(
      id: id ?? this.id,
      enquiryId: enquiryId ?? this.enquiryId,
      submittedByUserId: submittedByUserId ?? this.submittedByUserId,
      submittedByName: submittedByName ?? this.submittedByName,
      isBuyerOffer: isBuyerOffer ?? this.isBuyerOffer,
      offerAmount: offerAmount ?? this.offerAmount,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      depositAmount: depositAmount ?? this.depositAmount,
      leaseDurationMonths: leaseDurationMonths ?? this.leaseDurationMonths,
      maintenanceCharges: maintenanceCharges ?? this.maintenanceCharges,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'enquiryId': enquiryId,
        'submittedByUserId': submittedByUserId,
        'submittedByName': submittedByName,
        'isBuyerOffer': isBuyerOffer,
        'offerAmount': offerAmount,
        'monthlyRent': monthlyRent,
        'depositAmount': depositAmount,
        'leaseDurationMonths': leaseDurationMonths,
        'maintenanceCharges': maintenanceCharges,
        'termsAndConditions': termsAndConditions,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NegotiationOfferEvent.fromMap(Map<String, dynamic> map) => NegotiationOfferEvent(
        id: map['id'] as String,
        enquiryId: map['enquiryId'] as String,
        submittedByUserId: map['submittedByUserId'] as String,
        submittedByName: map['submittedByName'] as String? ?? 'User',
        isBuyerOffer: map['isBuyerOffer'] as bool? ?? true,
        offerAmount: (map['offerAmount'] as num?)?.toDouble() ?? 0.0,
        monthlyRent: (map['monthlyRent'] as num?)?.toDouble(),
        depositAmount: (map['depositAmount'] as num?)?.toDouble(),
        leaseDurationMonths: (map['leaseDurationMonths'] as num?)?.toInt(),
        maintenanceCharges: (map['maintenanceCharges'] as num?)?.toDouble(),
        termsAndConditions: map['termsAndConditions'] as String?,
        status: OfferLifecycleStatusExtension.fromString(map['status'] as String?),
        createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now(),
      );

  @override
  List<Object?> get props => [
        id,
        enquiryId,
        submittedByUserId,
        isBuyerOffer,
        offerAmount,
        monthlyRent,
        depositAmount,
        status,
        createdAt,
      ];
}

class PropertyEnquiryEntity extends Equatable {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyCategory;
  final String propertyLocation;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String? buyerEmail;
  final String sellerId;
  final TransactionInterestType interestType;
  final String initialMessage;
  final String preferredContactMethod; // 'Phone Call', 'WhatsApp', 'Email'
  final String? preferredVisitDate;
  final String? preferredVisitTime;
  final String financingStatus; // 'Self-Funded', 'Pre-Approved Loan', 'Loan Needed'
  final double listedPrice;
  final double? monthlyRent;
  final double? depositAmount;
  final int? leaseDurationMonths;
  final double? maintenanceCharges;
  final double? buyerOfferPrice;
  final double? sellerCounterOfferPrice;
  final double? currentNegotiatedAmount;
  final OfferLifecycleStatus offerStatus;
  final List<NegotiationOfferEvent> negotiationHistory;
  final TransactionStatus status;
  final SiteVisitStatus siteVisitStatus;
  final DateTime? scheduledVisitDateTime;
  final String? siteVisitNotes;
  final DocVerificationStatus docVerificationStatus;
  final String? docVerificationNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyEnquiryEntity({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyCategory,
    required this.propertyLocation,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    this.buyerEmail,
    required this.sellerId,
    required this.interestType,
    required this.initialMessage,
    this.preferredContactMethod = 'Phone Call',
    this.preferredVisitDate,
    this.preferredVisitTime,
    this.financingStatus = 'Self-Funded',
    required this.listedPrice,
    this.monthlyRent,
    this.depositAmount,
    this.leaseDurationMonths,
    this.maintenanceCharges,
    this.buyerOfferPrice,
    this.sellerCounterOfferPrice,
    this.currentNegotiatedAmount,
    this.offerStatus = OfferLifecycleStatus.submitted,
    this.negotiationHistory = const [],
    this.status = TransactionStatus.newEnquiry,
    this.siteVisitStatus = SiteVisitStatus.none,
    this.scheduledVisitDateTime,
    this.siteVisitNotes,
    this.docVerificationStatus = DocVerificationStatus.notStarted,
    this.docVerificationNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool canUserAccess(String userId) {
    return userId == buyerId || userId == sellerId;
  }

  PropertyEnquiryEntity copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    String? propertyCategory,
    String? propertyLocation,
    String? buyerId,
    String? buyerName,
    String? buyerPhone,
    String? buyerEmail,
    String? sellerId,
    TransactionInterestType? interestType,
    String? initialMessage,
    String? preferredContactMethod,
    String? preferredVisitDate,
    String? preferredVisitTime,
    String? financingStatus,
    double? listedPrice,
    double? monthlyRent,
    double? depositAmount,
    int? leaseDurationMonths,
    double? maintenanceCharges,
    double? buyerOfferPrice,
    double? sellerCounterOfferPrice,
    double? currentNegotiatedAmount,
    OfferLifecycleStatus? offerStatus,
    List<NegotiationOfferEvent>? negotiationHistory,
    TransactionStatus? status,
    SiteVisitStatus? siteVisitStatus,
    DateTime? scheduledVisitDateTime,
    String? siteVisitNotes,
    DocVerificationStatus? docVerificationStatus,
    String? docVerificationNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyEnquiryEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyCategory: propertyCategory ?? this.propertyCategory,
      propertyLocation: propertyLocation ?? this.propertyLocation,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      sellerId: sellerId ?? this.sellerId,
      interestType: interestType ?? this.interestType,
      initialMessage: initialMessage ?? this.initialMessage,
      preferredContactMethod: preferredContactMethod ?? this.preferredContactMethod,
      preferredVisitDate: preferredVisitDate ?? this.preferredVisitDate,
      preferredVisitTime: preferredVisitTime ?? this.preferredVisitTime,
      financingStatus: financingStatus ?? this.financingStatus,
      listedPrice: listedPrice ?? this.listedPrice,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      depositAmount: depositAmount ?? this.depositAmount,
      leaseDurationMonths: leaseDurationMonths ?? this.leaseDurationMonths,
      maintenanceCharges: maintenanceCharges ?? this.maintenanceCharges,
      buyerOfferPrice: buyerOfferPrice ?? this.buyerOfferPrice,
      sellerCounterOfferPrice: sellerCounterOfferPrice ?? this.sellerCounterOfferPrice,
      currentNegotiatedAmount: currentNegotiatedAmount ?? this.currentNegotiatedAmount,
      offerStatus: offerStatus ?? this.offerStatus,
      negotiationHistory: negotiationHistory ?? this.negotiationHistory,
      status: status ?? this.status,
      siteVisitStatus: siteVisitStatus ?? this.siteVisitStatus,
      scheduledVisitDateTime: scheduledVisitDateTime ?? this.scheduledVisitDateTime,
      siteVisitNotes: siteVisitNotes ?? this.siteVisitNotes,
      docVerificationStatus: docVerificationStatus ?? this.docVerificationStatus,
      docVerificationNotes: docVerificationNotes ?? this.docVerificationNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'propertyCategory': propertyCategory,
      'propertyLocation': propertyLocation,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerEmail': buyerEmail,
      'sellerId': sellerId,
      'interestType': interestType.name,
      'initialMessage': initialMessage,
      'preferredContactMethod': preferredContactMethod,
      'preferredVisitDate': preferredVisitDate,
      'preferredVisitTime': preferredVisitTime,
      'financingStatus': financingStatus,
      'listedPrice': listedPrice,
      'monthlyRent': monthlyRent,
      'depositAmount': depositAmount,
      'leaseDurationMonths': leaseDurationMonths,
      'maintenanceCharges': maintenanceCharges,
      'buyerOfferPrice': buyerOfferPrice,
      'sellerCounterOfferPrice': sellerCounterOfferPrice,
      'currentNegotiatedAmount': currentNegotiatedAmount,
      'offerStatus': offerStatus.name,
      'negotiationHistory': negotiationHistory.map((e) => e.toMap()).toList(),
      'status': status.name,
      'siteVisitStatus': siteVisitStatus.name,
      'scheduledVisitDateTime': scheduledVisitDateTime?.toIso8601String(),
      'siteVisitNotes': siteVisitNotes,
      'docVerificationStatus': docVerificationStatus.name,
      'docVerificationNotes': docVerificationNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PropertyEnquiryEntity.fromMap(Map<String, dynamic> map) {
    return PropertyEnquiryEntity(
      id: map['id'] as String,
      propertyId: map['propertyId'] as String,
      propertyTitle: (map['propertyTitle'] as String?) ?? 'Property Listing',
      propertyCategory: (map['propertyCategory'] as String?) ?? 'Residential',
      propertyLocation: (map['propertyLocation'] as String?) ?? 'Belagavi',
      buyerId: map['buyerId'] as String,
      buyerName: (map['buyerName'] as String?) ?? 'Prospective Buyer',
      buyerPhone: (map['buyerPhone'] as String?) ?? '',
      buyerEmail: map['buyerEmail'] as String?,
      sellerId: (map['sellerId'] as String?) ?? 'owner_1',
      interestType: TransactionInterestTypeExtension.fromString(map['interestType'] as String?),
      initialMessage: (map['initialMessage'] as String?) ?? 'I am interested in this property.',
      preferredContactMethod: (map['preferredContactMethod'] as String?) ?? 'Phone Call',
      preferredVisitDate: map['preferredVisitDate'] as String?,
      preferredVisitTime: map['preferredVisitTime'] as String?,
      financingStatus: (map['financingStatus'] as String?) ?? 'Self-Funded',
      listedPrice: (map['listedPrice'] as num?)?.toDouble() ?? 0.0,
      monthlyRent: (map['monthlyRent'] as num?)?.toDouble(),
      depositAmount: (map['depositAmount'] as num?)?.toDouble(),
      leaseDurationMonths: (map['leaseDurationMonths'] as num?)?.toInt(),
      maintenanceCharges: (map['maintenanceCharges'] as num?)?.toDouble(),
      buyerOfferPrice: (map['buyerOfferPrice'] as num?)?.toDouble(),
      sellerCounterOfferPrice: (map['sellerCounterOfferPrice'] as num?)?.toDouble(),
      currentNegotiatedAmount: (map['currentNegotiatedAmount'] as num?)?.toDouble(),
      offerStatus: OfferLifecycleStatusExtension.fromString(map['offerStatus'] as String?),
      negotiationHistory: (map['negotiationHistory'] as List<dynamic>?)
              ?.map((e) => NegotiationOfferEvent.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: TransactionStatusExtension.fromString(map['status'] as String?),
      siteVisitStatus: SiteVisitStatusExtension.fromString(map['siteVisitStatus'] as String?),
      scheduledVisitDateTime: map['scheduledVisitDateTime'] != null ? DateTime.tryParse(map['scheduledVisitDateTime'].toString()) : null,
      siteVisitNotes: map['siteVisitNotes'] as String?,
      docVerificationStatus: DocVerificationStatusExtension.fromString(map['docVerificationStatus'] as String?),
      docVerificationNotes: map['docVerificationNotes'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyTitle,
        buyerId,
        buyerName,
        sellerId,
        interestType,
        listedPrice,
        monthlyRent,
        depositAmount,
        buyerOfferPrice,
        sellerCounterOfferPrice,
        currentNegotiatedAmount,
        offerStatus,
        negotiationHistory,
        status,
        siteVisitStatus,
        scheduledVisitDateTime,
        docVerificationStatus,
        createdAt,
        updatedAt,
      ];
}
