import 'package:equatable/equatable.dart';

enum InvestmentModuleStatus {
  disabled,
  informationOnly,
  interestCollection,
  complianceApproved,
  productionEnabled,
}

enum InvestmentLeadStatus {
  newLead,
  contacted,
  inDiscussion,
  documentsShared,
  referredToOfflineProcess,
  closed,
  notEligible,
  withdrawn,
}

enum InvestmentProjectStatus {
  draft,
  upcoming,
  open,
  paused,
  closed,
  fullySubscribed,
  archived,
}

enum InvestmentPaymentStatus {
  initiated,
  awaitingPayment,
  paymentSubmitted,
  underVerification,
  confirmed,
  rejected,
  cancelled,
}

class InvestmentInterestLeadEntity extends Equatable {
  final String id;
  final String? projectId;
  final String? projectName;
  final String? userId;
  final String name;
  final String phone;
  final String? email;
  final String city;
  final String state;
  final String? preferredContactTime;
  final double? indicativeInterestAmount;
  final String preferredContactMethod;
  final String? message;
  final String consentVersion;
  final DateTime consentTimestamp;
  final InvestmentLeadStatus status;
  final DateTime createdAt;

  const InvestmentInterestLeadEntity({
    required this.id,
    this.projectId,
    this.projectName,
    this.userId,
    required this.name,
    required this.phone,
    this.email,
    this.city = 'Belagavi',
    this.state = 'Karnataka',
    this.preferredContactTime,
    this.indicativeInterestAmount,
    this.preferredContactMethod = 'WhatsApp',
    this.message,
    this.consentVersion = 'v1.0_2026',
    required this.consentTimestamp,
    this.status = InvestmentLeadStatus.newLead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        projectName,
        userId,
        name,
        phone,
        email,
        city,
        state,
        preferredContactTime,
        indicativeInterestAmount,
        preferredContactMethod,
        message,
        consentVersion,
        consentTimestamp,
        status,
        createdAt,
      ];
}

class InvestmentProjectEntity extends Equatable {
  final String id;
  final String name;
  final String? shortDescription;
  final String description;
  final String location;
  final String propertyType;
  final InvestmentProjectStatus status;
  final double? minimumInvestment;
  final double? maximumInvestment;
  final DateTime? investmentOpenDate;
  final DateTime? investmentCloseDate;
  final String? coverImage;
  final List<String> gallery;
  final List<String> disclosableDocuments;
  final bool isPublic;
  final bool isFeatured;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvestmentProjectEntity({
    required this.id,
    required this.name,
    this.shortDescription,
    required this.description,
    required this.location,
    required this.propertyType,
    this.status = InvestmentProjectStatus.open,
    this.minimumInvestment,
    this.maximumInvestment,
    this.investmentOpenDate,
    this.investmentCloseDate,
    this.coverImage,
    this.gallery = const [],
    this.disclosableDocuments = const [],
    this.isPublic = true,
    this.isFeatured = false,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen => status == InvestmentProjectStatus.open;
  bool get isUpcoming => status == InvestmentProjectStatus.upcoming;
  bool get canAcceptEnquiries =>
      status == InvestmentProjectStatus.open ||
      status == InvestmentProjectStatus.upcoming;

  @override
  List<Object?> get props => [
        id,
        name,
        shortDescription,
        description,
        location,
        propertyType,
        status,
        minimumInvestment,
        maximumInvestment,
        investmentOpenDate,
        investmentCloseDate,
        coverImage,
        gallery,
        disclosableDocuments,
        isPublic,
        isFeatured,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

class InvestmentDocumentEntity extends Equatable {
  final String id;
  final String title;
  final String documentType;
  final String fileUrl;
  final bool isPublic;
  final String approvedBy;
  final DateTime createdAt;

  const InvestmentDocumentEntity({
    required this.id,
    required this.title,
    required this.documentType,
    required this.fileUrl,
    this.isPublic = true,
    required this.approvedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        documentType,
        fileUrl,
        isPublic,
        approvedBy,
        createdAt,
      ];
}

class InvestmentPaymentEntity extends Equatable {
  final String id;
  final String projectId;
  final String? projectName;
  final String investorUserId;
  final String? investmentInterestId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String transactionReference;
  final String? paymentProofPath;
  final InvestmentPaymentStatus status;
  final DateTime submittedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  const InvestmentPaymentEntity({
    required this.id,
    required this.projectId,
    this.projectName,
    required this.investorUserId,
    this.investmentInterestId,
    required this.amount,
    this.currency = 'INR',
    this.paymentMethod = 'Bank Transfer',
    required this.transactionReference,
    this.paymentProofPath,
    this.status = InvestmentPaymentStatus.paymentSubmitted,
    required this.submittedAt,
    this.verifiedAt,
    this.verifiedBy,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        projectName,
        investorUserId,
        investmentInterestId,
        amount,
        currency,
        paymentMethod,
        transactionReference,
        paymentProofPath,
        status,
        submittedAt,
        verifiedAt,
        verifiedBy,
      ];
}

class ComplianceContentConfig extends Equatable {
  final String legalEntityName;
  final InvestmentModuleStatus moduleStatus;
  final String indicativeProfitSharingRange;
  final String legalDisclaimer;
  final String primaryPhone;
  final String secondaryPhone;
  final String primaryWhatsApp;
  final String secondaryWhatsApp;
  final String companyEmail;
  final bool isProductionPaymentEnabled;
  final DateTime updatedAt;

  const ComplianceContentConfig({
    this.legalEntityName = 'BELAGAVI PROPERTY LLP',
    this.moduleStatus = InvestmentModuleStatus.informationOnly,
    this.indicativeProfitSharingRange = '10%–30%',
    this.legalDisclaimer =
        'Information provided on this page is for general informational purposes only and does not by itself constitute an offer, invitation, solicitation, recommendation or commitment to accept any investment. Any project-specific arrangement, if legally permitted, will be subject to applicable laws, eligibility requirements, disclosures and executed documentation. Property and land-related activities involve risks and outcomes are not guaranteed.',
    this.primaryPhone = '9113219906',
    this.secondaryPhone = '9886615159',
    this.primaryWhatsApp = '9113219906',
    this.secondaryWhatsApp = '9886615159',
    this.companyEmail = 'invest@belagaviproperty.com',
    this.isProductionPaymentEnabled = false,
    required this.updatedAt,
  });

  String get formattedPrimaryPhone => '+91 9113219906';
  String get formattedSecondaryPhone => '+91 9886615159';

  // Backward compatibility getters
  String get whatsappNumber => '+91$primaryWhatsApp';
  String get companyPhoneNumber => '+91$primaryPhone';

  @override
  List<Object?> get props => [
        legalEntityName,
        moduleStatus,
        indicativeProfitSharingRange,
        legalDisclaimer,
        primaryPhone,
        secondaryPhone,
        primaryWhatsApp,
        secondaryWhatsApp,
        companyEmail,
        isProductionPaymentEnabled,
        updatedAt,
      ];
}

