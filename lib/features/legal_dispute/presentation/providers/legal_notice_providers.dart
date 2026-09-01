import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/legal_notice_entities.dart';
import '../../domain/repositories/legal_notice_repository.dart';
import '../../data/datasources/legal_notice_remote_datasource.dart';
import '../../data/repositories/legal_notice_repository_impl.dart';

final legalNoticeRepositoryProvider = Provider<LegalNoticeRepository>((ref) {
  if (getIt.isRegistered<LegalNoticeRepository>()) {
    return getIt<LegalNoticeRepository>();
  }
  final supabase = getIt.isRegistered<SupabaseService>()
      ? getIt<SupabaseService>()
      : SupabaseService();
  return LegalNoticeRepositoryImpl(LegalNoticeRemoteDataSourceImpl(supabase));
});

class LegalNoticesState {
  final List<TransactionLegalNoticeEntity> notices;
  final bool isLoading;
  final String? errorMessage;
  final LegalNoticeType? selectedType;
  final String selectedTransactionType;
  final String selectedLocality;
  final String searchQuery;

  const LegalNoticesState({
    this.notices = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType,
    this.selectedTransactionType = 'All Types',
    this.selectedLocality = 'All Localities',
    this.searchQuery = '',
  });

  LegalNoticesState copyWith({
    List<TransactionLegalNoticeEntity>? notices,
    bool? isLoading,
    String? errorMessage,
    LegalNoticeType? selectedType,
    bool clearType = false,
    String? selectedTransactionType,
    String? selectedLocality,
    String? searchQuery,
  }) {
    return LegalNoticesState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedTransactionType: selectedTransactionType ?? this.selectedTransactionType,
      selectedLocality: selectedLocality ?? this.selectedLocality,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LegalNoticesNotifier extends StateNotifier<LegalNoticesState> {
  final LegalNoticeRepository _repository;

  LegalNoticesNotifier(this._repository) : super(const LegalNoticesState()) {
    loadNotices();
  }

  Future<void> loadNotices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getLegalNotices(
      type: state.selectedType,
      transactionType: state.selectedTransactionType,
      locality: state.selectedLocality,
      query: state.searchQuery,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (data) => state = state.copyWith(isLoading: false, notices: data),
    );
  }

  Future<void> loadLegalNotices() => loadNotices();

  void setNoticeType(LegalNoticeType? type) {
    if (state.selectedType == type) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
    loadNotices();
  }

  void setTransactionType(String txType) {
    state = state.copyWith(selectedTransactionType: txType);
    loadNotices();
  }

  void setLocality(String locality) {
    state = state.copyWith(selectedLocality: locality);
    loadNotices();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadNotices();
  }

  void addNoticeLocally(TransactionLegalNoticeEntity notice) {
    final updated = [notice, ...state.notices.where((n) => n.id != notice.id)];
    state = state.copyWith(notices: updated);
  }
}

final legalNoticesNotifierProvider =
    StateNotifierProvider<LegalNoticesNotifier, LegalNoticesState>((ref) {
  final repo = ref.watch(legalNoticeRepositoryProvider);
  return LegalNoticesNotifier(repo);
});

class LegalNoticeFormState {
  final String id;
  final String propertyId;
  final String title;
  final String category;
  final String propertyType;
  final String country;
  final String state;
  final String district;
  final String city;
  final String locality;
  final String postalCode;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final String villageTaluk;
  final String surveyCtsNumber;
  final String khataNumber;
  final String plotNumber;
  final String flatUnitNumber;
  final String buildingProjectName;
  final String landArea;
  final String areaUnit;

  final String buyerName;
  final String buyerAddress;
  final String buyerAdvocate;

  final String sellerName;
  final String sellerAddress;
  final List<NoticePartyEntity> structuredParties;

  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String contactRole;

  final String transactionType;
  final String agreedValue;
  final String agreementDate;
  final String executionDate;
  final String transactionStatus;
  final String transactionDescription;

  final LegalNoticeType noticeType;
  final String issuingAuthority;
  final String referenceNumber;
  final String noticeDate;
  final String effectiveDate;
  final String responseDeadline;
  final String objectionPeriod;
  final String publicNoticeSummary;
  final String noticeFullText;
  final String dueDiligenceNotes;

  final NoticePublicationEntity? publicationInfo;

  final List<String> photoUrls;
  final List<String> documentUrls;
  final List<String> photoLabels;
  final List<String> documentLabels;
  final bool isDocumentPrivate;
  final bool canAddDocumentsLater;
  final int currentStep;
  final bool isSubmitting;
  final bool isDraftSaved;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const LegalNoticeFormState({
    this.id = '',
    this.propertyId = '',
    this.title = '',
    this.category = 'Residential',
    this.propertyType = 'Apartment',
    this.country = 'India',
    this.state = 'Karnataka',
    this.district = '',
    this.city = 'Belagavi',
    this.locality = '',
    this.postalCode = '',
    this.fullAddress = '',
    this.latitude,
    this.longitude,
    this.villageTaluk = '',
    this.surveyCtsNumber = '',
    this.khataNumber = '',
    this.plotNumber = '',
    this.flatUnitNumber = '',
    this.buildingProjectName = '',
    this.landArea = '',
    this.areaUnit = 'sq.ft',
    this.buyerName = '',
    this.buyerAddress = '',
    this.buyerAdvocate = '',
    this.sellerName = '',
    this.sellerAddress = '',
    this.structuredParties = const [],
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.contactRole = 'Buyer / Purchaser',
    this.transactionType = 'Purchase',
    this.agreedValue = '',
    this.agreementDate = '',
    this.executionDate = '',
    this.transactionStatus = 'Under Negotiation / Proposed',
    this.transactionDescription = '',
    this.noticeType = LegalNoticeType.purchaseNotice,
    this.issuingAuthority = 'Sub-Registrar Office Belagavi',
    this.referenceNumber = '',
    this.noticeDate = '',
    this.effectiveDate = '',
    this.responseDeadline = '',
    this.objectionPeriod = '',
    this.publicNoticeSummary = '',
    this.noticeFullText = '',
    this.dueDiligenceNotes = '',
    this.publicationInfo,
    this.photoUrls = const [],
    this.documentUrls = const [],
    this.photoLabels = const [],
    this.documentLabels = const [],
    this.isDocumentPrivate = true,
    this.canAddDocumentsLater = true,
    this.currentStep = 0,
    this.isSubmitting = false,
    this.isDraftSaved = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  LegalNoticeFormState copyWith({
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
    int? currentStep,
    bool? isSubmitting,
    bool? isDraftSaved,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return LegalNoticeFormState(
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
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  TransactionLegalNoticeEntity toEntity(String authenticatedUserId, {bool isDraft = false}) {
    return TransactionLegalNoticeEntity(
      id: id.isNotEmpty ? id : 'not_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId.isNotEmpty ? propertyId : 'prop_not_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isNotEmpty ? title.trim() : 'Draft Legal Notice',
      category: category,
      propertyType: propertyType,
      country: country,
      state: state,
      district: district.trim().isNotEmpty ? district.trim() : null,
      city: city,
      locality: locality.trim().isNotEmpty ? locality.trim() : 'Belagavi',
      postalCode: postalCode.trim().isNotEmpty ? postalCode.trim() : null,
      fullAddress: fullAddress.trim().isNotEmpty ? fullAddress.trim() : null,
      latitude: latitude,
      longitude: longitude,
      villageTaluk: villageTaluk.trim().isNotEmpty ? villageTaluk.trim() : null,
      surveyCtsNumber: surveyCtsNumber.trim().isNotEmpty ? surveyCtsNumber.trim() : null,
      khataNumber: khataNumber.trim().isNotEmpty ? khataNumber.trim() : null,
      plotNumber: plotNumber.trim().isNotEmpty ? plotNumber.trim() : null,
      flatUnitNumber: flatUnitNumber.trim().isNotEmpty ? flatUnitNumber.trim() : null,
      buildingProjectName: buildingProjectName.trim().isNotEmpty ? buildingProjectName.trim() : null,
      landArea: landArea.trim().isNotEmpty ? landArea.trim() : null,
      areaUnit: areaUnit,
      buyerName: buyerName.trim(),
      buyerAddress: buyerAddress.trim().isNotEmpty ? buyerAddress.trim() : null,
      buyerAdvocate: buyerAdvocate.trim().isNotEmpty ? buyerAdvocate.trim() : null,
      sellerName: sellerName.trim(),
      sellerAddress: sellerAddress.trim().isNotEmpty ? sellerAddress.trim() : null,
      structuredParties: structuredParties,
      contactName: contactName.trim().isNotEmpty ? contactName.trim() : 'Authorized Contact',
      contactPhone: contactPhone.trim(),
      contactEmail: contactEmail.trim().isNotEmpty ? contactEmail.trim() : null,
      contactRole: contactRole,
      transactionType: transactionType,
      agreedValue: agreedValue.trim().isNotEmpty ? agreedValue.trim() : null,
      agreementDate: agreementDate.trim().isNotEmpty ? agreementDate.trim() : null,
      executionDate: executionDate.trim().isNotEmpty ? executionDate.trim() : null,
      transactionStatus: transactionStatus,
      transactionDescription: transactionDescription.trim().isNotEmpty ? transactionDescription.trim() : null,
      noticeType: noticeType,
      issuingAuthority: issuingAuthority.trim().isNotEmpty ? issuingAuthority.trim() : null,
      referenceNumber: referenceNumber.trim().isNotEmpty ? referenceNumber.trim() : null,
      noticeDate: noticeDate.trim().isNotEmpty ? noticeDate.trim() : null,
      effectiveDate: effectiveDate.trim().isNotEmpty ? effectiveDate.trim() : null,
      responseDeadline: responseDeadline.trim().isNotEmpty ? responseDeadline.trim() : null,
      objectionPeriod: objectionPeriod.trim().isNotEmpty ? objectionPeriod.trim() : null,
      publicNoticeSummary: publicNoticeSummary.trim().isNotEmpty ? publicNoticeSummary.trim() : null,
      noticeFullText: noticeFullText.trim().isNotEmpty ? noticeFullText.trim() : null,
      dueDiligenceNotes: dueDiligenceNotes.trim().isNotEmpty ? dueDiligenceNotes.trim() : null,
      publicationInfo: publicationInfo,
      photoUrls: photoUrls,
      documentUrls: documentUrls,
      photoLabels: photoLabels,
      documentLabels: documentLabels,
      isDocumentPrivate: isDocumentPrivate,
      canAddDocumentsLater: canAddDocumentsLater,
      verificationStatus: isDraft ? LegalNoticeStatus.draft : LegalNoticeStatus.underReview,
      recordedBy: authenticatedUserId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class LegalNoticeFormNotifier extends StateNotifier<LegalNoticeFormState> {
  final LegalNoticeRepository _repository;

  LegalNoticeFormNotifier(this._repository) : super(const LegalNoticeFormState());

  void initForNewRecord() {
    state = const LegalNoticeFormState();
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void updatePropertyInfo({
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
    String? propertyId,
  }) {
    this.state = this.state.copyWith(
      title: title,
      category: category,
      propertyType: propertyType,
      country: country,
      state: state,
      district: district,
      city: city,
      locality: locality,
      postalCode: postalCode,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
      villageTaluk: villageTaluk,
      surveyCtsNumber: surveyCtsNumber,
      khataNumber: khataNumber,
      plotNumber: plotNumber,
      flatUnitNumber: flatUnitNumber,
      buildingProjectName: buildingProjectName,
      landArea: landArea,
      areaUnit: areaUnit,
      propertyId: propertyId,
    );
  }

  void updateBuyerInfo({
    String? buyerName,
    String? buyerAddress,
    String? buyerAdvocate,
  }) {
    state = state.copyWith(
      buyerName: buyerName,
      buyerAddress: buyerAddress,
      buyerAdvocate: buyerAdvocate,
    );
  }

  void updateSellerInfo({
    String? sellerName,
    String? sellerAddress,
  }) {
    state = state.copyWith(
      sellerName: sellerName,
      sellerAddress: sellerAddress,
    );
  }

  void addParty(NoticePartyEntity party) {
    final updated = List<NoticePartyEntity>.from(state.structuredParties)..add(party);
    state = state.copyWith(structuredParties: updated);
  }

  void removeParty(int index) {
    final updated = List<NoticePartyEntity>.from(state.structuredParties)..removeAt(index);
    state = state.copyWith(structuredParties: updated);
  }

  void updateContactInfo({
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? contactRole,
  }) {
    state = state.copyWith(
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      contactRole: contactRole,
    );
  }

  void updateTransactionInfo({
    String? transactionType,
    String? agreedValue,
    String? agreementDate,
    String? executionDate,
    String? transactionStatus,
    String? transactionDescription,
  }) {
    state = state.copyWith(
      transactionType: transactionType,
      agreedValue: agreedValue,
      agreementDate: agreementDate,
      executionDate: executionDate,
      transactionStatus: transactionStatus,
      transactionDescription: transactionDescription,
    );
  }

  void updateLegalNoticeInfo({
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
  }) {
    state = state.copyWith(
      noticeType: noticeType,
      issuingAuthority: issuingAuthority,
      referenceNumber: referenceNumber,
      noticeDate: noticeDate,
      effectiveDate: effectiveDate,
      responseDeadline: responseDeadline,
      objectionPeriod: objectionPeriod,
      publicNoticeSummary: publicNoticeSummary,
      noticeFullText: noticeFullText,
      dueDiligenceNotes: dueDiligenceNotes,
      publicationInfo: publicationInfo,
    );
  }

  void addPhoto(String photoUrl, {String label = 'Property Photo'}) {
    final updatedUrls = List<String>.from(state.photoUrls)..add(photoUrl);
    final updatedLabels = List<String>.from(state.photoLabels)..add(label);
    state = state.copyWith(photoUrls: updatedUrls, photoLabels: updatedLabels);
  }

  void removePhoto(int index) {
    final updatedUrls = List<String>.from(state.photoUrls)..removeAt(index);
    final updatedLabels = List<String>.from(state.photoLabels);
    if (index < updatedLabels.length) updatedLabels.removeAt(index);
    state = state.copyWith(photoUrls: updatedUrls, photoLabels: updatedLabels);
  }

  void addDocument(String docUrl, {String label = 'Legal Document'}) {
    final updatedDocs = List<String>.from(state.documentUrls)..add(docUrl);
    final updatedLabels = List<String>.from(state.documentLabels)..add(label);
    state = state.copyWith(documentUrls: updatedDocs, documentLabels: updatedLabels);
  }

  void removeDocument(int index) {
    final updatedDocs = List<String>.from(state.documentUrls)..removeAt(index);
    final updatedLabels = List<String>.from(state.documentLabels);
    if (index < updatedLabels.length) updatedLabels.removeAt(index);
    state = state.copyWith(documentUrls: updatedDocs, documentLabels: updatedLabels);
  }

  void setPrivateDocument(bool isPrivate) {
    state = state.copyWith(isDocumentPrivate: isPrivate);
  }

  int calculateCompletionScore() {
    int score = 0;
    // Property Details (+20)
    if (state.title.trim().isNotEmpty && state.locality.trim().isNotEmpty) score += 20;
    // Parties Info (+20)
    if (state.buyerName.trim().isNotEmpty || state.sellerName.trim().isNotEmpty || state.structuredParties.isNotEmpty) score += 20;
    // Contact Info (+20)
    if (state.contactPhone.trim().isNotEmpty) score += 20;
    // Transaction Details (+15)
    if (state.transactionType.isNotEmpty && state.agreedValue.trim().isNotEmpty) score += 15;
    // Legal Notice Info (+15)
    if (state.referenceNumber.trim().isNotEmpty || state.issuingAuthority.trim().isNotEmpty || state.publicNoticeSummary.trim().isNotEmpty) score += 15;
    // Media & Docs (+10)
    if (state.photoUrls.isNotEmpty || state.documentUrls.isNotEmpty) score += 10;
    return score.clamp(0, 100);
  }

  List<String> getMissingFields() {
    final missing = <String>[];
    if (state.title.trim().isEmpty) missing.add('Property Title');
    if (state.locality.trim().isEmpty) missing.add('Locality / Area');
    if (state.buyerName.trim().isEmpty && state.sellerName.trim().isEmpty && state.structuredParties.isEmpty) {
      missing.add('Party Name (Buyer, Seller or Parties)');
    }
    if (state.contactPhone.trim().isEmpty) missing.add('Authorized Contact Phone');
    return missing;
  }

  bool validateStep(int step) {
    final errors = <String, String>{};
    if (step == 0) {
      if (state.title.trim().isEmpty) errors['title'] = 'Property title is required';
      if (state.locality.trim().isEmpty) errors['locality'] = 'Locality / Area is required';
    } else if (step == 3) {
      if (state.contactPhone.trim().isEmpty) errors['contactPhone'] = 'Contact phone number is required';
    }
    state = state.copyWith(fieldErrors: errors);
    return errors.isEmpty;
  }

  Future<bool> saveDraft(String authenticatedUserId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final entity = state.toEntity(authenticatedUserId, isDraft: true);
    final result = await _repository.createLegalNotice(entity, authenticatedUserId: authenticatedUserId);
    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, errorMessage: failure.message);
        return false;
      },
      (created) {
        state = state.copyWith(isSubmitting: false, isDraftSaved: true, id: created.id);
        return true;
      },
    );
  }

  Future<bool> submitRecord(String authenticatedUserId, {bool saveWithoutDocuments = false}) async {
    final missing = getMissingFields();
    if (missing.isNotEmpty) {
      state = state.copyWith(errorMessage: 'Please fill required fields: ${missing.join(', ')}');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final entity = state.toEntity(authenticatedUserId, isDraft: false);
    final result = await _repository.createLegalNotice(entity, authenticatedUserId: authenticatedUserId);

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, errorMessage: failure.message);
        return false;
      },
      (created) {
        state = state.copyWith(isSubmitting: false, id: created.id);
        return true;
      },
    );
  }
}

final legalNoticeFormNotifierProvider =
    StateNotifierProvider<LegalNoticeFormNotifier, LegalNoticeFormState>((ref) {
  final repo = ref.watch(legalNoticeRepositoryProvider);
  return LegalNoticeFormNotifier(repo);
});

// Legal Matters Dashboard State & Provider
class LegalMattersDashboardState {
  final List<LegalMatterEntity> matters;
  final bool isLoading;
  final String? errorMessage;
  final LegalMatterStatus? statusFilter;
  final String searchQuery;

  const LegalMattersDashboardState({
    this.matters = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter,
    this.searchQuery = '',
  });

  LegalMattersDashboardState copyWith({
    List<LegalMatterEntity>? matters,
    bool? isLoading,
    String? errorMessage,
    LegalMatterStatus? statusFilter,
    bool clearStatus = false,
    String? searchQuery,
  }) {
    return LegalMattersDashboardState(
      matters: matters ?? this.matters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LegalMattersDashboardNotifier extends StateNotifier<LegalMattersDashboardState> {
  final LegalNoticeRepository _repository;

  LegalMattersDashboardNotifier(this._repository) : super(const LegalMattersDashboardState());

  Future<void> loadMatters(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repository.getUserLegalMatters(
      authenticatedUserId: userId,
      statusFilter: state.statusFilter,
      query: state.searchQuery,
    );
    res.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (data) => state = state.copyWith(isLoading: false, matters: data),
    );
  }

  void setStatusFilter(LegalMatterStatus? status, String userId) {
    if (state.statusFilter == status) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
    loadMatters(userId);
  }

  void setSearchQuery(String query, String userId) {
    state = state.copyWith(searchQuery: query);
    loadMatters(userId);
  }
}

final legalMattersDashboardNotifierProvider =
    StateNotifierProvider<LegalMattersDashboardNotifier, LegalMattersDashboardState>((ref) {
  final repo = ref.watch(legalNoticeRepositoryProvider);
  return LegalMattersDashboardNotifier(repo);
});

// Legal Notice Wizard State & Provider
class LegalMatterWizardState {
  final int currentStep;
  final String? propertyId;
  final String title;
  final String category;
  final LegalNoticeType noticeType;
  
  // Parties
  final String claimantName;
  final String claimantAddress;
  final String claimantPhone;
  final String respondentName;
  final String respondentAddress;
  final String respondentPhone;
  final String? advocateName;

  // Property snapshot
  final String locality;
  final String city;
  final String? fullAddress;
  final String? surveyCtsNumber;

  // Financials & Dates
  final double financialClaimAmount;
  final double agreedTotalConsideration;
  final double amountPaidSoFar;
  final double interestRateClaimed;
  final String agreementDate;
  final String breachDefaultDate;

  // Facts & Relief
  final String chronologyText;
  final String desiredRemedy;

  // Review & Draft
  final String generatedDraftMarkdown;
  final bool requiresAdvocateReview;
  final bool isHighRisk;
  final String? selectedServiceMethod;
  final String? trackingNumber;

  final bool isSubmitting;
  final String? errorMessage;
  final String? createdMatterId;

  const LegalMatterWizardState({
    this.currentStep = 0,
    this.propertyId,
    this.title = '',
    this.category = 'Lease / Tenancy Dispute',
    this.noticeType = LegalNoticeType.tenantLandlordNotice,
    this.claimantName = '',
    this.claimantAddress = '',
    this.claimantPhone = '',
    this.respondentName = '',
    this.respondentAddress = '',
    this.respondentPhone = '',
    this.advocateName,
    this.locality = 'Belagavi',
    this.city = 'Belagavi',
    this.fullAddress,
    this.surveyCtsNumber,
    this.financialClaimAmount = 0.0,
    this.agreedTotalConsideration = 0.0,
    this.amountPaidSoFar = 0.0,
    this.interestRateClaimed = 0.0,
    this.agreementDate = '',
    this.breachDefaultDate = '',
    this.chronologyText = '',
    this.desiredRemedy = 'Immediate payment of arrears and vacation of premises',
    this.generatedDraftMarkdown = '',
    this.requiresAdvocateReview = false,
    this.isHighRisk = false,
    this.selectedServiceMethod = 'Registered Post AD',
    this.trackingNumber,
    this.isSubmitting = false,
    this.errorMessage,
    this.createdMatterId,
  });

  LegalMatterWizardState copyWith({
    int? currentStep,
    String? propertyId,
    String? title,
    String? category,
    LegalNoticeType? noticeType,
    String? claimantName,
    String? claimantAddress,
    String? claimantPhone,
    String? respondentName,
    String? respondentAddress,
    String? respondentPhone,
    String? advocateName,
    String? locality,
    String? city,
    String? fullAddress,
    String? surveyCtsNumber,
    double? financialClaimAmount,
    double? agreedTotalConsideration,
    double? amountPaidSoFar,
    double? interestRateClaimed,
    String? agreementDate,
    String? breachDefaultDate,
    String? chronologyText,
    String? desiredRemedy,
    String? generatedDraftMarkdown,
    bool? requiresAdvocateReview,
    bool? isHighRisk,
    String? selectedServiceMethod,
    String? trackingNumber,
    bool? isSubmitting,
    String? errorMessage,
    String? createdMatterId,
  }) {
    return LegalMatterWizardState(
      currentStep: currentStep ?? this.currentStep,
      propertyId: propertyId ?? this.propertyId,
      title: title ?? this.title,
      category: category ?? this.category,
      noticeType: noticeType ?? this.noticeType,
      claimantName: claimantName ?? this.claimantName,
      claimantAddress: claimantAddress ?? this.claimantAddress,
      claimantPhone: claimantPhone ?? this.claimantPhone,
      respondentName: respondentName ?? this.respondentName,
      respondentAddress: respondentAddress ?? this.respondentAddress,
      respondentPhone: respondentPhone ?? this.respondentPhone,
      advocateName: advocateName ?? this.advocateName,
      locality: locality ?? this.locality,
      city: city ?? this.city,
      fullAddress: fullAddress ?? this.fullAddress,
      surveyCtsNumber: surveyCtsNumber ?? this.surveyCtsNumber,
      financialClaimAmount: financialClaimAmount ?? this.financialClaimAmount,
      agreedTotalConsideration: agreedTotalConsideration ?? this.agreedTotalConsideration,
      amountPaidSoFar: amountPaidSoFar ?? this.amountPaidSoFar,
      interestRateClaimed: interestRateClaimed ?? this.interestRateClaimed,
      agreementDate: agreementDate ?? this.agreementDate,
      breachDefaultDate: breachDefaultDate ?? this.breachDefaultDate,
      chronologyText: chronologyText ?? this.chronologyText,
      desiredRemedy: desiredRemedy ?? this.desiredRemedy,
      generatedDraftMarkdown: generatedDraftMarkdown ?? this.generatedDraftMarkdown,
      requiresAdvocateReview: requiresAdvocateReview ?? this.requiresAdvocateReview,
      isHighRisk: isHighRisk ?? this.isHighRisk,
      selectedServiceMethod: selectedServiceMethod ?? this.selectedServiceMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      createdMatterId: createdMatterId ?? this.createdMatterId,
    );
  }
}

class LegalMatterWizardNotifier extends StateNotifier<LegalMatterWizardState> {
  final LegalNoticeRepository _repository;

  LegalMatterWizardNotifier(this._repository) : super(const LegalMatterWizardState());

  void updateField({
    int? currentStep,
    String? propertyId,
    String? title,
    String? category,
    LegalNoticeType? noticeType,
    String? claimantName,
    String? claimantAddress,
    String? claimantPhone,
    String? respondentName,
    String? respondentAddress,
    String? respondentPhone,
    String? advocateName,
    String? locality,
    String? city,
    String? fullAddress,
    String? surveyCtsNumber,
    double? financialClaimAmount,
    double? agreedTotalConsideration,
    double? amountPaidSoFar,
    double? interestRateClaimed,
    String? agreementDate,
    String? breachDefaultDate,
    String? chronologyText,
    String? desiredRemedy,
    String? generatedDraftMarkdown,
    bool? requiresAdvocateReview,
    bool? isHighRisk,
    String? selectedServiceMethod,
    String? trackingNumber,
  }) {
    state = state.copyWith(
      currentStep: currentStep,
      propertyId: propertyId,
      title: title,
      category: category,
      noticeType: noticeType,
      claimantName: claimantName,
      claimantAddress: claimantAddress,
      claimantPhone: claimantPhone,
      respondentName: respondentName,
      respondentAddress: respondentAddress,
      respondentPhone: respondentPhone,
      advocateName: advocateName,
      locality: locality,
      city: city,
      fullAddress: fullAddress,
      surveyCtsNumber: surveyCtsNumber,
      financialClaimAmount: financialClaimAmount,
      agreedTotalConsideration: agreedTotalConsideration,
      amountPaidSoFar: amountPaidSoFar,
      interestRateClaimed: interestRateClaimed,
      agreementDate: agreementDate,
      breachDefaultDate: breachDefaultDate,
      chronologyText: chronologyText,
      desiredRemedy: desiredRemedy,
      generatedDraftMarkdown: generatedDraftMarkdown,
      requiresAdvocateReview: requiresAdvocateReview,
      isHighRisk: isHighRisk,
      selectedServiceMethod: selectedServiceMethod,
      trackingNumber: trackingNumber,
    );
  }

  void generateDraft() {
    final titleStr = state.title.isNotEmpty ? state.title : 'Property Legal Notice';
    final claimant = state.claimantName.isNotEmpty ? state.claimantName : 'Sender / Claimant';
    final respondent = state.respondentName.isNotEmpty ? state.respondentName : 'Opposite Party';
    final claimAmt = state.financialClaimAmount > 0 ? '₹ ${state.financialClaimAmount.toStringAsFixed(2)}' : 'as specified in the agreement';
    
    final draft = '''
# LEGAL NOTICE FOR STATUTORY DEMAND & COMPLIANCE

**DATE:** ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  
**MATTER REF:** LGL-BEL-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}  
**JURISDICTION:** Belagavi, Karnataka  

---

### **BY REGISTERED POST A.D. / SPEED POST**

**TO:**  
**${respondent.toUpperCase()}**  
${state.respondentAddress.isNotEmpty ? state.respondentAddress : 'Belagavi, Karnataka'}  
Contact: ${state.respondentPhone.isNotEmpty ? state.respondentPhone : 'N/A'}  

**FROM (SENDER):**  
**${claimant.toUpperCase()}**  
${state.claimantAddress.isNotEmpty ? state.claimantAddress : 'Belagavi, Karnataka'}  
Contact: ${state.claimantPhone.isNotEmpty ? state.claimantPhone : 'N/A'}  

---

### **SUBJECT:**  
LEGAL NOTICE UNDER APPLICABLE PROPERTY STATUTES FOR **${titleStr.toUpperCase()}** REGARDING DEFAULT, BREACH OF OBLIGATIONS, AND DEMAND FOR REMEDY.

---

### **1. PROPERTY IDENTIFICATION & HISTORICAL CONTEXT:**
The property subject matter of this notice is located at ${state.locality}, ${state.city}, Karnataka${state.surveyCtsNumber != null ? ', bearing Survey/CTS No. ${state.surveyCtsNumber}' : ''}.

### **2. STATEMENT OF FACTS & CHRONOLOGY:**
1. Our client states that an agreement/relationship was established on ${state.agreementDate.isNotEmpty ? state.agreementDate : 'the agreed date'}.
2. ${state.chronologyText.isNotEmpty ? state.chronologyText : 'The recipient has failed to perform their contractual/statutory obligations as agreed.'}
3. The breach/default occurred on or about ${state.breachDefaultDate.isNotEmpty ? state.breachDefaultDate : 'the date of default'}.

### **3. STATUTORY NOTICE & DEMAND:**
Notice is hereby given under applicable statutory provisions (including Transfer of Property Act, 1882 / Specific Relief Act, 1963 / RERA Act, 2016 where applicable) demanding:
- Immediate payment/remedy of **$claimAmt**.
- ${state.desiredRemedy} within 15 days of date of receipt of this notice.

### **4. RESERVATION OF RIGHTS & WITHOUT PREJUDICE:**
This notice is issued without prejudice to all other legal rights and remedies available to our client in law, equity, or statutory forums.

---
**${claimant.toUpperCase()}**  
*(Issued via Belagavi Property LLP Legal Assistance Platform — Advocate Review Recommended)*
''';

    state = state.copyWith(generatedDraftMarkdown: draft);
  }

  Future<bool> submitMatter(String userId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final matter = LegalMatterEntity(
      id: 'matter_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      propertyId: state.propertyId,
      matterReference: 'LGL-BEL-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      title: state.title.isNotEmpty ? state.title : 'Property Legal Notice',
      category: state.category,
      noticeType: state.noticeType,
      status: LegalMatterStatus.draftReady,
      isHighRisk: state.isHighRisk,
      requiresAdvocateReview: state.requiresAdvocateReview,
      locality: state.locality,
      city: state.city,
      fullAddress: state.fullAddress,
      surveyCtsNumber: state.surveyCtsNumber,
      financialClaimAmount: state.financialClaimAmount,
      agreedTotalConsideration: state.agreedTotalConsideration,
      amountPaidSoFar: state.amountPaidSoFar,
      interestRateClaimed: state.interestRateClaimed,
      agreementDate: state.agreementDate,
      breachDefaultDate: state.breachDefaultDate,
      desiredRemedy: state.desiredRemedy,
      parties: [
        NoticePartyEntity(name: state.claimantName, role: 'Claimant / Sender', address: state.claimantAddress, contact: state.claimantPhone),
        NoticePartyEntity(name: state.respondentName, role: 'Opposite Party / Recipient', address: state.respondentAddress, contact: state.respondentPhone),
      ],
      chronology: [
        LegalFactEntity(id: 'f1', dateString: state.breachDefaultDate, eventDescription: state.chronologyText, source: 'USER_STATED'),
      ],
      versionHistory: [
        LegalNoticeVersionEntity(
          id: 'v1',
          versionNumber: 1,
          contentMarkdown: state.generatedDraftMarkdown,
          generatedByType: 'USER_STATED',
          createdBy: userId,
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final res = await _repository.createLegalMatter(matter, authenticatedUserId: userId);
    return res.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, errorMessage: failure.message);
        return false;
      },
      (created) {
        state = state.copyWith(isSubmitting: false, createdMatterId: created.id);
        return true;
      },
    );
  }
}

final legalMatterWizardNotifierProvider =
    StateNotifierProvider<LegalMatterWizardNotifier, LegalMatterWizardState>((ref) {
  final repo = ref.watch(legalNoticeRepositoryProvider);
  return LegalMatterWizardNotifier(repo);
});