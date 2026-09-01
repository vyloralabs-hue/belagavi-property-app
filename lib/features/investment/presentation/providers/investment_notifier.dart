import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';

class InvestmentState extends Equatable {
  final ComplianceContentConfig config;
  final List<InvestmentProjectEntity> projects;
  final List<InvestmentDocumentEntity> documents;
  final List<InvestmentInterestLeadEntity> leads;
  final List<InvestmentPaymentEntity> payments;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const InvestmentState({
    required this.config,
    this.projects = const [],
    this.documents = const [],
    this.leads = const [],
    this.payments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  List<InvestmentProjectEntity> get openProjects =>
      projects.where((p) => p.isPublic && p.status == InvestmentProjectStatus.open).toList();

  List<InvestmentProjectEntity> get upcomingProjects =>
      projects.where((p) => p.isPublic && p.status == InvestmentProjectStatus.upcoming).toList();

  bool get hasOpenProjects => openProjects.isNotEmpty;
  bool get hasUpcomingProjects => upcomingProjects.isNotEmpty;

  InvestmentState copyWith({
    ComplianceContentConfig? config,
    List<InvestmentProjectEntity>? projects,
    List<InvestmentDocumentEntity>? documents,
    List<InvestmentInterestLeadEntity>? leads,
    List<InvestmentPaymentEntity>? payments,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return InvestmentState(
      config: config ?? this.config,
      projects: projects ?? this.projects,
      documents: documents ?? this.documents,
      leads: leads ?? this.leads,
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        config,
        projects,
        documents,
        leads,
        payments,
        isLoading,
        errorMessage,
        successMessage,
      ];
}

final investmentNotifierProvider =
    NotifierProvider<InvestmentNotifier, InvestmentState>(
  InvestmentNotifier.new,
);

class InvestmentNotifier extends Notifier<InvestmentState> {
  @override
  InvestmentState build() {
    final now = DateTime.now();
    final defaultConfig = ComplianceContentConfig(updatedAt: now);

    final standardDocs = [
      InvestmentDocumentEntity(
        id: 'doc_001',
        title: 'Belagavi Property LLP Corporate Overview',
        documentType: 'PDF Document',
        fileUrl: 'https://belagaviproperty.com/docs/corporate_overview.pdf',
        isPublic: true,
        approvedBy: 'Belagavi Property LLP',
        createdAt: now,
      ),
      InvestmentDocumentEntity(
        id: 'doc_002',
        title: 'Project Investment Framework & Disclosures',
        documentType: 'PDF Disclosure',
        fileUrl: 'https://belagaviproperty.com/docs/investment_framework.pdf',
        isPublic: true,
        approvedBy: 'Belagavi Property LLP',
        createdAt: now,
      ),
    ];

    return InvestmentState(
      config: defaultConfig,
      projects: const [], // Zero fake projects in production
      documents: standardDocs,
    );
  }

  /// Request Callback submission
  Future<InvestmentInterestLeadEntity> requestCallback({
    required String name,
    required String phone,
    String? preferredTime,
    String? message,
    String? projectId,
    String? projectName,
    String? userId,
    String? email,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      throw const FormatException('Please enter a valid 10-digit mobile number.');
    }

    state = state.copyWith(isLoading: true);
    final now = DateTime.now();

    final newLead = InvestmentInterestLeadEntity(
      id: 'cb_${now.millisecondsSinceEpoch}',
      projectId: projectId,
      projectName: projectName,
      userId: userId,
      name: name.trim(),
      phone: cleanPhone.length == 10 ? '+91$cleanPhone' : '+$cleanPhone',
      email: email?.trim(),
      preferredContactTime: preferredTime,
      message: message?.trim(),
      preferredContactMethod: 'Call / WhatsApp',
      consentTimestamp: now,
      status: InvestmentLeadStatus.newLead,
      createdAt: now,
    );

    final updatedLeads = [newLead, ...state.leads];
    state = state.copyWith(
      isLoading: false,
      leads: updatedLeads,
      successMessage: 'Callback request received. Belagavi Property LLP will contact you.',
    );

    return newLead;
  }

  /// Submit Investment Interest
  Future<InvestmentInterestLeadEntity> submitInvestmentInterest({
    required String name,
    required String phone,
    String? email,
    required String city,
    required String stateName,
    String? projectId,
    String? projectName,
    double? indicativeInterestAmount,
    required String preferredContactMethod,
    String? message,
    String? userId,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      throw const FormatException('Please enter a valid 10-digit mobile number.');
    }

    state = state.copyWith(isLoading: true);
    final now = DateTime.now();

    final newLead = InvestmentInterestLeadEntity(
      id: 'inv_lead_${now.millisecondsSinceEpoch}',
      projectId: projectId,
      projectName: projectName,
      userId: userId,
      name: name.trim(),
      phone: cleanPhone.length == 10 ? '+91$cleanPhone' : '+$cleanPhone',
      email: email?.trim(),
      city: city.trim().isNotEmpty ? city.trim() : 'Belagavi',
      state: stateName.trim().isNotEmpty ? stateName.trim() : 'Karnataka',
      indicativeInterestAmount: indicativeInterestAmount,
      preferredContactMethod: preferredContactMethod,
      message: message?.trim(),
      consentVersion: 'v1.0_2026',
      consentTimestamp: now,
      status: InvestmentLeadStatus.newLead,
      createdAt: now,
    );

    final updatedLeads = [newLead, ...state.leads];
    state = state.copyWith(
      isLoading: false,
      leads: updatedLeads,
      successMessage: 'Interest submitted successfully to Belagavi Property LLP.',
    );

    return newLead;
  }

  /// Admin-Only: Add new Investment Project
  Future<InvestmentProjectEntity> createInvestmentProject({
    required String authenticatedUserId,
    required UserRole role,
    required String name,
    String? shortDescription,
    required String description,
    required String location,
    required String propertyType,
    InvestmentProjectStatus status = InvestmentProjectStatus.open,
    double? minimumInvestment,
    double? maximumInvestment,
    DateTime? investmentOpenDate,
    DateTime? investmentCloseDate,
    String? coverImage,
    List<String> gallery = const [],
    List<String> disclosableDocuments = const [],
  }) async {
    // Security check: ONLY Founder or Admin can create investment projects
    if (role != UserRole.founder && role != UserRole.admin) {
      throw const AccessDeniedException('Access Denied: Public users cannot create investment projects.');
    }

    final now = DateTime.now();
    final newProject = InvestmentProjectEntity(
      id: 'inv_proj_${now.millisecondsSinceEpoch}',
      name: name.trim(),
      shortDescription: shortDescription?.trim(),
      description: description.trim(),
      location: location.trim(),
      propertyType: propertyType.trim(),
      status: status,
      minimumInvestment: minimumInvestment,
      maximumInvestment: maximumInvestment,
      investmentOpenDate: investmentOpenDate,
      investmentCloseDate: investmentCloseDate,
      coverImage: coverImage,
      gallery: gallery,
      disclosableDocuments: disclosableDocuments,
      createdBy: authenticatedUserId,
      createdAt: now,
      updatedAt: now,
    );

    final updatedProjects = [newProject, ...state.projects];
    state = state.copyWith(projects: updatedProjects);
    return newProject;
  }

  /// Admin-Only: Update Investment Project Status
  void updateProjectStatus({
    required String authenticatedUserId,
    required UserRole role,
    required String projectId,
    required InvestmentProjectStatus newStatus,
  }) {
    if (role != UserRole.founder && role != UserRole.admin) {
      throw const AccessDeniedException('Access Denied: Only admins can update project status.');
    }

    final updated = state.projects.map((p) {
      if (p.id == projectId) {
        return InvestmentProjectEntity(
          id: p.id,
          name: p.name,
          shortDescription: p.shortDescription,
          description: p.description,
          location: p.location,
          propertyType: p.propertyType,
          status: newStatus,
          minimumInvestment: p.minimumInvestment,
          maximumInvestment: p.maximumInvestment,
          investmentOpenDate: p.investmentOpenDate,
          investmentCloseDate: p.investmentCloseDate,
          coverImage: p.coverImage,
          gallery: p.gallery,
          disclosableDocuments: p.disclosableDocuments,
          isPublic: p.isPublic,
          isFeatured: p.isFeatured,
          createdBy: p.createdBy,
          createdAt: p.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();

    state = state.copyWith(projects: updated);
  }

  /// Fetch leads for Admin
  Future<void> fetchFounderInvestmentLeads({
    required String authenticatedUserId,
    required UserRole role,
  }) async {
    if (role != UserRole.founder && role != UserRole.admin) {
      throw const AccessDeniedException('Access Denied: Investment lead access unauthorized.');
    }
  }

  void updateComplianceStatus(InvestmentModuleStatus newStatus) {
    final updatedConfig = ComplianceContentConfig(
      legalEntityName: state.config.legalEntityName,
      moduleStatus: newStatus,
      indicativeProfitSharingRange: state.config.indicativeProfitSharingRange,
      legalDisclaimer: state.config.legalDisclaimer,
      primaryPhone: state.config.primaryPhone,
      secondaryPhone: state.config.secondaryPhone,
      primaryWhatsApp: state.config.primaryWhatsApp,
      secondaryWhatsApp: state.config.secondaryWhatsApp,
      companyEmail: state.config.companyEmail,
      isProductionPaymentEnabled: false,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(config: updatedConfig);
  }
}

