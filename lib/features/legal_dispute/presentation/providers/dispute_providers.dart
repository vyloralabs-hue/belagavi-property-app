import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/dispute_entities.dart';
import '../../domain/repositories/dispute_repository.dart';
import '../../data/datasources/dispute_remote_datasource.dart';
import '../../data/repositories/dispute_repository_impl.dart';

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  if (getIt.isRegistered<DisputeRepository>()) {
    return getIt<DisputeRepository>();
  }
  final supabase = getIt.isRegistered<SupabaseService>()
      ? getIt<SupabaseService>()
      : SupabaseService();
  return DisputeRepositoryImpl(DisputeRemoteDataSourceImpl(supabase));
});

// ==============================================================================
// 1. PUBLIC DISPUTED PROPERTIES BROWSE NOTIFIER
// ==============================================================================

class DisputedPropertiesState {
  final List<PropertyDisputeEntity> disputes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final DisputeType? selectedType;
  final String? selectedCategory;
  final String selectedLocality;
  final String searchQuery;
  final int offset;
  final int limit;

  const DisputedPropertiesState({
    this.disputes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.selectedType,
    this.selectedCategory,
    this.selectedLocality = 'All Localities',
    this.searchQuery = '',
    this.offset = 0,
    this.limit = 20,
  });

  DisputedPropertiesState copyWith({
    List<PropertyDisputeEntity>? disputes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    DisputeType? selectedType,
    bool clearType = false,
    String? selectedCategory,
    bool clearCategory = false,
    String? selectedLocality,
    String? searchQuery,
    int? offset,
    int? limit,
  }) {
    return DisputedPropertiesState(
      disputes: disputes ?? this.disputes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedLocality: selectedLocality ?? this.selectedLocality,
      searchQuery: searchQuery ?? this.searchQuery,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }
}

class DisputedPropertiesNotifier extends StateNotifier<DisputedPropertiesState> {
  final DisputeRepository _repository;

  DisputedPropertiesNotifier(this._repository) : super(const DisputedPropertiesState()) {
    loadDisputes();
  }

  Future<void> loadDisputes() async {
    state = state.copyWith(isLoading: true, errorMessage: null, offset: 0, hasMore: true);
    final result = await _repository.getDisputedProperties(
      type: state.selectedType,
      category: state.selectedCategory,
      locality: state.selectedLocality,
      query: state.searchQuery,
      status: 'published',
      limit: state.limit,
      offset: 0,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (data) => state = state.copyWith(
        isLoading: false,
        disputes: data,
        offset: data.length,
        hasMore: data.length >= state.limit,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final result = await _repository.getDisputedProperties(
      type: state.selectedType,
      category: state.selectedCategory,
      locality: state.selectedLocality,
      query: state.searchQuery,
      status: 'published',
      limit: state.limit,
      offset: state.offset,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoadingMore: false),
      (data) => state = state.copyWith(
        isLoadingMore: false,
        disputes: [...state.disputes, ...data],
        offset: state.offset + data.length,
        hasMore: data.length >= state.limit,
      ),
    );
  }

  void setDisputeType(DisputeType? type) {
    if (state.selectedType == type) {
      state = state.copyWith(clearType: true, clearCategory: true);
    } else {
      state = state.copyWith(selectedType: type, selectedCategory: type?.displayName);
    }
    loadDisputes();
  }

  void setCategory(String? category) {
    if (category == null || category == 'All' || state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true, clearType: true);
    } else {
      state = state.copyWith(selectedCategory: category, selectedType: DisputeTypeExtension.fromString(category));
    }
    loadDisputes();
  }

  void setLocality(String locality) {
    state = state.copyWith(selectedLocality: locality);
    loadDisputes();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadDisputes();
  }

  void addDisputeLocally(PropertyDisputeEntity dispute) {
    final updated = [dispute, ...state.disputes.where((d) => d.id != dispute.id)];
    state = state.copyWith(disputes: updated);
  }
}

final disputedPropertiesNotifierProvider = StateNotifierProvider<DisputedPropertiesNotifier, DisputedPropertiesState>((ref) {
  final repo = ref.watch(disputeRepositoryProvider);
  return DisputedPropertiesNotifier(repo);
});

// ==============================================================================
// 2. MY DISPUTED PROPERTIES (OWNER DASHBOARD) NOTIFIER
// ==============================================================================

class MyDisputedPropertiesState {
  final List<PropertyDisputeEntity> disputes;
  final bool isLoading;
  final String? errorMessage;
  final String activeTab; // ALL, DRAFT, SUBMITTED, UNDER_REVIEW, PUBLISHED, RESOLVED, REJECTED_WITHDRAWN

  const MyDisputedPropertiesState({
    this.disputes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeTab = 'ALL',
  });

  MyDisputedPropertiesState copyWith({
    List<PropertyDisputeEntity>? disputes,
    bool? isLoading,
    String? errorMessage,
    String? activeTab,
  }) {
    return MyDisputedPropertiesState(
      disputes: disputes ?? this.disputes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class MyDisputedPropertiesNotifier extends StateNotifier<MyDisputedPropertiesState> {
  final DisputeRepository _repository;

  MyDisputedPropertiesNotifier(this._repository) : super(const MyDisputedPropertiesState());

  Future<void> fetchMyDisputes(String userId, {String? tab}) async {
    if (userId.isEmpty) {
      state = state.copyWith(disputes: const [], isLoading: false);
      return;
    }

    final currentTab = tab ?? state.activeTab;
    state = state.copyWith(isLoading: true, errorMessage: null, activeTab: currentTab);

    final result = await _repository.getMyDisputedProperties(
      authenticatedUserId: userId,
      statusFilter: currentTab == 'ALL' ? null : currentTab,
      limit: 50,
      offset: 0,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (data) => state = state.copyWith(isLoading: false, disputes: data),
    );
  }

  void setActiveTab(String tab, String userId) {
    state = state.copyWith(activeTab: tab);
    fetchMyDisputes(userId, tab: tab);
  }

  void prependDispute(PropertyDisputeEntity dispute) {
    final updated = [dispute, ...state.disputes.where((d) => d.id != dispute.id)];
    state = state.copyWith(disputes: updated);
  }
}

final myDisputedPropertiesNotifierProvider = StateNotifierProvider<MyDisputedPropertiesNotifier, MyDisputedPropertiesState>((ref) {
  final repo = ref.watch(disputeRepositoryProvider);
  return MyDisputedPropertiesNotifier(repo);
});

// ==============================================================================
// 3. ADD / EDIT DISPUTED PROPERTY WIZARD NOTIFIER
// ==============================================================================

class SelectedDisputeDocument {
  final String fileName;
  final String documentType;
  final Uint8List bytes;
  final String localPath;
  String? uploadedUrl;
  String uploadStatus; // SELECTED, UPLOADING, UPLOADED, FAILED

  SelectedDisputeDocument({
    required this.fileName,
    required this.documentType,
    required this.bytes,
    this.localPath = '',
    this.uploadedUrl,
    this.uploadStatus = 'SELECTED',
  });
}

class AddDisputeWizardState {
  final int currentStep; // 0..4 (Steps 1..5)
  final bool isSubmitting;
  final bool isUploadingDoc;
  final String? errorMessage;
  final String? createdDisputeId;

  // Step 1: Property Details
  final String title;
  final String propertyType;
  final String state;
  final String district;
  final String taluk;
  final String city;
  final String locality;
  final String village;
  final String surveyNumber;
  final String propertyNumber;
  final String plotFlatShopNumber;
  final String projectBuildingName;
  final double? propertyArea;
  final String areaUnit;

  // Step 2: Dispute Details
  final String disputeCategory;
  final String factualSummary;
  final String claimedDisputeNature;
  final String claimingPartyRole;
  final String respondingPartyRole;
  final String currentStage;
  final String disputeStartDate;

  // Step 3: Case / Authority Reference
  final String caseNumber;
  final String courtAuthorityName;
  final String caseFilingDate;
  final String nextHearingDate;
  final String caseOrdersNotes;

  // Step 4: Documents
  final List<SelectedDisputeDocument> documents;

  // Step 5: Duplicate candidates & confirmation
  final List<DisputeDuplicateCandidate> duplicateCandidates;
  final bool isCheckingDuplicates;
  final bool agreedToDisclaimer;

  const AddDisputeWizardState({
    this.currentStep = 0,
    this.isSubmitting = false,
    this.isUploadingDoc = false,
    this.errorMessage,
    this.createdDisputeId,
    this.title = '',
    this.propertyType = 'House',
    this.state = 'Karnataka',
    this.district = 'Belagavi',
    this.taluk = 'Belagavi',
    this.city = 'Belagavi',
    this.locality = 'Tilakwadi',
    this.village = '',
    this.surveyNumber = '',
    this.propertyNumber = '',
    this.plotFlatShopNumber = '',
    this.projectBuildingName = '',
    this.propertyArea,
    this.areaUnit = 'sqft',
    this.disputeCategory = 'Ownership / Title',
    this.factualSummary = '',
    this.claimedDisputeNature = 'Title defect and conflicting ownership claims',
    this.claimingPartyRole = 'Owner / Claimant',
    this.respondingPartyRole = 'Respondent',
    this.currentStage = 'Reported / Notice Issued',
    this.disputeStartDate = '',
    this.caseNumber = '',
    this.courtAuthorityName = '',
    this.caseFilingDate = '',
    this.nextHearingDate = '',
    this.caseOrdersNotes = '',
    this.documents = const [],
    this.duplicateCandidates = const [],
    this.isCheckingDuplicates = false,
    this.agreedToDisclaimer = false,
  });

  AddDisputeWizardState copyWith({
    int? currentStep,
    bool? isSubmitting,
    bool? isUploadingDoc,
    String? errorMessage,
    String? createdDisputeId,
    String? title,
    String? propertyType,
    String? state,
    String? district,
    String? taluk,
    String? city,
    String? locality,
    String? village,
    String? surveyNumber,
    String? propertyNumber,
    String? plotFlatShopNumber,
    String? projectBuildingName,
    double? propertyArea,
    String? areaUnit,
    String? disputeCategory,
    String? factualSummary,
    String? claimedDisputeNature,
    String? claimingPartyRole,
    String? respondingPartyRole,
    String? currentStage,
    String? disputeStartDate,
    String? caseNumber,
    String? courtAuthorityName,
    String? caseFilingDate,
    String? nextHearingDate,
    String? caseOrdersNotes,
    List<SelectedDisputeDocument>? documents,
    List<DisputeDuplicateCandidate>? duplicateCandidates,
    bool? isCheckingDuplicates,
    bool? agreedToDisclaimer,
  }) {
    return AddDisputeWizardState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingDoc: isUploadingDoc ?? this.isUploadingDoc,
      errorMessage: errorMessage,
      createdDisputeId: createdDisputeId ?? this.createdDisputeId,
      title: title ?? this.title,
      propertyType: propertyType ?? this.propertyType,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      village: village ?? this.village,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      propertyNumber: propertyNumber ?? this.propertyNumber,
      plotFlatShopNumber: plotFlatShopNumber ?? this.plotFlatShopNumber,
      projectBuildingName: projectBuildingName ?? this.projectBuildingName,
      propertyArea: propertyArea ?? this.propertyArea,
      areaUnit: areaUnit ?? this.areaUnit,
      disputeCategory: disputeCategory ?? this.disputeCategory,
      factualSummary: factualSummary ?? this.factualSummary,
      claimedDisputeNature: claimedDisputeNature ?? this.claimedDisputeNature,
      claimingPartyRole: claimingPartyRole ?? this.claimingPartyRole,
      respondingPartyRole: respondingPartyRole ?? this.respondingPartyRole,
      currentStage: currentStage ?? this.currentStage,
      disputeStartDate: disputeStartDate ?? this.disputeStartDate,
      caseNumber: caseNumber ?? this.caseNumber,
      courtAuthorityName: courtAuthorityName ?? this.courtAuthorityName,
      caseFilingDate: caseFilingDate ?? this.caseFilingDate,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      caseOrdersNotes: caseOrdersNotes ?? this.caseOrdersNotes,
      documents: documents ?? this.documents,
      duplicateCandidates: duplicateCandidates ?? this.duplicateCandidates,
      isCheckingDuplicates: isCheckingDuplicates ?? this.isCheckingDuplicates,
      agreedToDisclaimer: agreedToDisclaimer ?? this.agreedToDisclaimer,
    );
  }
}

class AddDisputeWizardNotifier extends StateNotifier<AddDisputeWizardState> {
  final DisputeRepository _repository;

  AddDisputeWizardNotifier(this._repository) : super(const AddDisputeWizardState());

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
      if (step == 4) {
        checkDuplicates();
      }
    }
  }

  void updatePropertyDetails({
    String? title,
    String? propertyType,
    String? state,
    String? district,
    String? taluk,
    String? city,
    String? locality,
    String? village,
    String? surveyNumber,
    String? propertyNumber,
    String? plotFlatShopNumber,
    String? projectBuildingName,
    double? propertyArea,
    String? areaUnit,
  }) {
    this.state = this.state.copyWith(
      title: title,
      propertyType: propertyType,
      state: state,
      district: district,
      taluk: taluk,
      city: city,
      locality: locality,
      village: village,
      surveyNumber: surveyNumber,
      propertyNumber: propertyNumber,
      plotFlatShopNumber: plotFlatShopNumber,
      projectBuildingName: projectBuildingName,
      propertyArea: propertyArea,
      areaUnit: areaUnit,
    );
  }

  void updateDisputeDetails({
    String? disputeCategory,
    String? factualSummary,
    String? claimedDisputeNature,
    String? claimingPartyRole,
    String? respondingPartyRole,
    String? currentStage,
    String? disputeStartDate,
  }) {
    state = state.copyWith(
      disputeCategory: disputeCategory,
      factualSummary: factualSummary,
      claimedDisputeNature: claimedDisputeNature,
      claimingPartyRole: claimingPartyRole,
      respondingPartyRole: respondingPartyRole,
      currentStage: currentStage,
      disputeStartDate: disputeStartDate,
    );
  }

  void updateCaseDetails({
    String? caseNumber,
    String? courtAuthorityName,
    String? caseFilingDate,
    String? nextHearingDate,
    String? caseOrdersNotes,
  }) {
    state = state.copyWith(
      caseNumber: caseNumber,
      courtAuthorityName: courtAuthorityName,
      caseFilingDate: caseFilingDate,
      nextHearingDate: nextHearingDate,
      caseOrdersNotes: caseOrdersNotes,
    );
  }

  void addDocument(SelectedDisputeDocument doc) {
    final updated = List<SelectedDisputeDocument>.from(state.documents)..add(doc);
    state = state.copyWith(documents: updated);
  }

  void removeDocument(int index) {
    if (index >= 0 && index < state.documents.length) {
      final updated = List<SelectedDisputeDocument>.from(state.documents)..removeAt(index);
      state = state.copyWith(documents: updated);
    }
  }

  void toggleDisclaimer(bool value) {
    state = state.copyWith(agreedToDisclaimer: value);
  }

  void setAgreedToDisclaimer(bool value) {
    state = state.copyWith(agreedToDisclaimer: value);
  }

  Future<void> checkDuplicates() async {
    state = state.copyWith(isCheckingDuplicates: true);
    final result = await _repository.checkPossibleDuplicates(
      locality: state.locality,
      surveyNumber: state.surveyNumber.isNotEmpty ? state.surveyNumber : null,
      propertyNumber: state.propertyNumber.isNotEmpty ? state.propertyNumber : null,
    );
    result.fold(
      (_) => state = state.copyWith(isCheckingDuplicates: false, duplicateCandidates: const []),
      (candidates) => state = state.copyWith(isCheckingDuplicates: false, duplicateCandidates: candidates),
    );
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        if (state.locality.trim().isEmpty) {
          state = state.copyWith(errorMessage: 'Locality is required');
          return false;
        }
        state = state.copyWith(errorMessage: null);
        return true;
      case 1:
        if (state.factualSummary.trim().isEmpty || state.factualSummary.trim().length < 15) {
          state = state.copyWith(errorMessage: 'Please enter a clear factual summary (at least 15 characters)');
          return false;
        }
        state = state.copyWith(errorMessage: null);
        return true;
      case 2:
      case 3:
      case 4:
        state = state.copyWith(errorMessage: null);
        return true;
      default:
        return true;
    }
  }

  Future<PropertyDisputeEntity?> submitDispute(String authenticatedUserId, {bool asDraft = false}) async {
    if (authenticatedUserId.isEmpty) {
      state = state.copyWith(errorMessage: 'Authentication required to submit dispute record.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final title = '${state.propertyType} in ${state.locality} (${state.disputeCategory})';

    final initialDocs = <DisputeDocumentEntity>[];
    for (final doc in state.documents) {
      initialDocs.add(DisputeDocumentEntity(
        id: '',
        disputeId: '',
        documentType: doc.documentType,
        storagePath: doc.uploadedUrl ?? (doc.localPath.isNotEmpty ? doc.localPath : doc.fileName),
        publicRedactedUrl: doc.uploadedUrl,
        visibility: 'public_redacted',
        isRedacted: true,
        badgeLabel: 'DOCUMENT ATTACHED',
        createdAt: DateTime.now(),
      ));
    }

    final dispute = PropertyDisputeEntity(
      creatorId: authenticatedUserId,
      title: title,
      propertyType: state.propertyType,
      state: state.state,
      district: state.district,
      taluk: state.taluk,
      city: state.city,
      locality: state.locality,
      village: state.village.isNotEmpty ? state.village : null,
      surveyCtsNumber: state.surveyNumber.isNotEmpty ? state.surveyNumber : null,
      propertyNumber: state.propertyNumber.isNotEmpty ? state.propertyNumber : null,
      plotFlatShopNumber: state.plotFlatShopNumber.isNotEmpty ? state.plotFlatShopNumber : null,
      propertyArea: state.propertyArea,
      areaUnit: state.areaUnit,
      disputeCategory: state.disputeCategory,
      disputeType: DisputeTypeExtension.fromString(state.disputeCategory),
      factualSummary: state.factualSummary,
      description: state.factualSummary,
      claimedDisputeNature: state.claimedDisputeNature,
      claimingPartyRole: state.claimingPartyRole,
      respondingPartyRole: state.respondingPartyRole.isNotEmpty ? state.respondingPartyRole : null,
      currentStage: state.currentStage,
      disputeStartDate: state.disputeStartDate.isNotEmpty ? state.disputeStartDate : null,
      caseNumber: state.caseNumber.isNotEmpty ? state.caseNumber : null,
      courtAuthority: state.courtAuthorityName.isNotEmpty ? state.courtAuthorityName : null,
      caseFilingDate: state.caseFilingDate.isNotEmpty ? state.caseFilingDate : null,
      nextHearingDate: state.nextHearingDate.isNotEmpty ? state.nextHearingDate : null,
      caseOrdersNotes: state.caseOrdersNotes.isNotEmpty ? state.caseOrdersNotes : null,
      verificationStatus: asDraft ? DisputeVerificationStatus.draft : DisputeVerificationStatus.submitted,
      isFounderConfirmed: false,
      reportedBy: authenticatedUserId,
      reportDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      hasDocuments: initialDocs.isNotEmpty,
    );

    final result = await _repository.createDispute(
      dispute,
      authenticatedUserId: authenticatedUserId,
      initialDocuments: initialDocs,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, errorMessage: failure.message);
        return null;
      },
      (created) {
        state = state.copyWith(isSubmitting: false, createdDisputeId: created.id);
        return created;
      },
    );
  }

  void reset() {
    state = const AddDisputeWizardState();
  }
}

final addDisputeWizardNotifierProvider = StateNotifierProvider<AddDisputeWizardNotifier, AddDisputeWizardState>((ref) {
  final repo = ref.watch(disputeRepositoryProvider);
  return AddDisputeWizardNotifier(repo);
});

// Single Dispute Detail Provider
final disputeDetailProvider = FutureProvider.family<PropertyDisputeEntity?, String>((ref, disputeId) async {
  final repo = ref.watch(disputeRepositoryProvider);
  final result = await repo.getDisputeById(disputeId, requestingUserId: '');
  return result.fold((_) => null, (entity) => entity);
});

// ==============================================================================
// 4. LEGACY DISPUTE FORM STATE & NOTIFIER (FOR BACKWARD COMPATIBILITY)
// ==============================================================================

class DisputeFormState {
  final String title;
  final String locality;
  final String category;
  final String propertyType;
  final String surveyCtsNumber;
  final String city;
  final String description;
  final String relationship;
  final DisputeType disputeType;
  final String? courtAuthority;
  final String? caseNumber;
  final String? caseYear;
  final String? caseStatus;
  final String? litigatingParties;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final List<String> photoUrls;
  final List<String> documentUrls;
  final List<DisputePartyEntity> structuredParties;
  final Map<String, String> fieldErrors;
  final bool isDraftSaved;
  final bool isSubmitting;

  const DisputeFormState({
    this.title = '',
    this.locality = '',
    this.city = 'Belagavi',
    this.category = 'Residential',
    this.propertyType = 'Apartment',
    this.surveyCtsNumber = '',
    this.description = '',
    this.relationship = 'Reporting a dispute',
    this.disputeType = DisputeType.otherLegalDispute,
    this.courtAuthority,
    this.caseNumber,
    this.caseYear,
    this.caseStatus,
    this.litigatingParties,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.photoUrls = const [],
    this.documentUrls = const [],
    this.structuredParties = const [],
    this.fieldErrors = const {},
    this.isDraftSaved = false,
    this.isSubmitting = false,
  });

  DisputeFormState copyWith({
    String? title,
    String? locality,
    String? city,
    String? category,
    String? propertyType,
    String? surveyCtsNumber,
    String? description,
    String? relationship,
    DisputeType? disputeType,
    String? courtAuthority,
    String? caseNumber,
    String? caseYear,
    String? caseStatus,
    String? litigatingParties,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    List<String>? photoUrls,
    List<String>? documentUrls,
    List<DisputePartyEntity>? structuredParties,
    Map<String, String>? fieldErrors,
    bool? isDraftSaved,
    bool? isSubmitting,
  }) {
    return DisputeFormState(
      title: title ?? this.title,
      locality: locality ?? this.locality,
      city: city ?? this.city,
      category: category ?? this.category,
      propertyType: propertyType ?? this.propertyType,
      surveyCtsNumber: surveyCtsNumber ?? this.surveyCtsNumber,
      description: description ?? this.description,
      relationship: relationship ?? this.relationship,
      disputeType: disputeType ?? this.disputeType,
      courtAuthority: courtAuthority ?? this.courtAuthority,
      caseNumber: caseNumber ?? this.caseNumber,
      caseYear: caseYear ?? this.caseYear,
      caseStatus: caseStatus ?? this.caseStatus,
      litigatingParties: litigatingParties ?? this.litigatingParties,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      photoUrls: photoUrls ?? this.photoUrls,
      documentUrls: documentUrls ?? this.documentUrls,
      structuredParties: structuredParties ?? this.structuredParties,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class DisputeFormNotifier extends StateNotifier<DisputeFormState> {
  final DisputeRepository _repository;

  DisputeFormNotifier(this._repository) : super(const DisputeFormState());

  void initForNewDispute() {
    state = const DisputeFormState();
  }

  void updatePropertyDetails({
    String? title,
    String? locality,
    String? city,
    String? category,
    String? propertyType,
    String? surveyCtsNumber,
  }) {
    state = state.copyWith(
      title: title,
      locality: locality,
      city: city,
      category: category,
      propertyType: propertyType,
      surveyCtsNumber: surveyCtsNumber,
    );
  }

  void updateCaseDetails({
    String? description,
    DisputeType? disputeType,
    String? relationship,
    String? courtAuthority,
    String? caseNumber,
    String? caseYear,
    String? caseStatus,
    String? litigatingParties,
  }) {
    state = state.copyWith(
      description: description,
      disputeType: disputeType,
      relationship: relationship,
      courtAuthority: courtAuthority,
      caseNumber: caseNumber,
      caseYear: caseYear,
      caseStatus: caseStatus,
      litigatingParties: litigatingParties,
    );
  }

  void updateRelationship(String relationship) {
    state = state.copyWith(relationship: relationship);
  }

  void updateDisputeType(DisputeType type) {
    state = state.copyWith(disputeType: type);
  }

  void addPhoto(String url) {
    state = state.copyWith(photoUrls: [...state.photoUrls, url]);
  }

  void addDocument(String url) {
    state = state.copyWith(documentUrls: [...state.documentUrls, url]);
  }

  List<String> getMissingFields() {
    final list = <String>[];
    if (state.title.trim().isEmpty) list.add('Property Title');
    if (state.locality.trim().isEmpty) list.add('Locality / Area');
    return list;
  }

  void updateContactInfo({
    String? contactName,
    String? contactPhone,
    String? contactEmail,
  }) {
    state = state.copyWith(
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
    );
  }

  void addParty(DisputePartyEntity party) {
    final updated = List<DisputePartyEntity>.from(state.structuredParties)..add(party);
    state = state.copyWith(structuredParties: updated);
  }

  void removeParty(int index) {
    if (index >= 0 && index < state.structuredParties.length) {
      final updated = List<DisputePartyEntity>.from(state.structuredParties)..removeAt(index);
      state = state.copyWith(structuredParties: updated);
    }
  }

  bool validateStep(int step) {
    final errors = <String, String>{};
    if (step == 0) {
      if (state.title.trim().isEmpty) errors['title'] = 'Property title is required';
      if (state.locality.trim().isEmpty) errors['locality'] = 'Locality / Area is required';
    }
    state = state.copyWith(fieldErrors: errors);
    return errors.isEmpty;
  }

  int calculateCompletionScore() {
    int score = 0;
    if (state.relationship.isNotEmpty) score += 15;
    if (state.title.isNotEmpty) score += 15;
    if (state.locality.isNotEmpty) score += 10;
    if (state.description.isNotEmpty) score += 20;
    if (state.courtAuthority != null || state.caseNumber != null) score += 15;
    if (state.photoUrls.isNotEmpty) score += 10;
    if (state.documentUrls.isNotEmpty) score += 5;
    if (state.contactPhone != null && state.contactPhone!.isNotEmpty) score += 10;
    return score;
  }

  Future<bool> saveDraft(String userId) async {
    final dispute = PropertyDisputeEntity(
      creatorId: userId,
      title: state.title,
      locality: state.locality,
      description: state.description,
      relationship: state.relationship,
      disputeType: state.disputeType,
      verificationStatus: DisputeVerificationStatus.draft,
    );
    final res = await _repository.createDispute(dispute, authenticatedUserId: userId);
    final ok = res.isRight();
    if (ok) state = state.copyWith(isDraftSaved: true);
    return ok;
  }

  Future<bool> submitDispute(String userId) async {
    if (state.title.trim().isEmpty || state.locality.trim().isEmpty) {
      return false;
    }
    final dispute = PropertyDisputeEntity(
      creatorId: userId,
      title: state.title,
      locality: state.locality,
      category: state.category,
      propertyType: state.propertyType,
      surveyCtsNumber: state.surveyCtsNumber.isNotEmpty ? state.surveyCtsNumber : null,
      description: state.description,
      relationship: state.relationship,
      disputeType: state.disputeType,
      verificationStatus: DisputeVerificationStatus.submitted,
      structuredParties: state.structuredParties,
      contactName: state.contactName,
      contactPhone: state.contactPhone,
      contactEmail: state.contactEmail,
    );
    final res = await _repository.createDispute(dispute, authenticatedUserId: userId);
    return res.isRight();
  }
}