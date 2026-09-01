import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/property_entities.dart' show PropertyCategory;
import '../../domain/entities/property_document_entity.dart';
import '../../domain/repositories/property_document_repository.dart';
import '../../data/repositories/property_document_repository_impl.dart';

final propertyDocumentRepositoryProvider = Provider<PropertyDocumentRepository>((ref) {
  return PropertyDocumentRepositoryImpl();
});

class PropertyDocumentState {
  final List<PropertyDocumentEntity> documents;
  final List<DueDiligenceCheckItem> dueDiligenceChecklist;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const PropertyDocumentState({
    this.documents = const [],
    this.dueDiligenceChecklist = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  PropertyDocumentState copyWith({
    List<PropertyDocumentEntity>? documents,
    List<DueDiligenceCheckItem>? dueDiligenceChecklist,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return PropertyDocumentState(
      documents: documents ?? this.documents,
      dueDiligenceChecklist: dueDiligenceChecklist ?? this.dueDiligenceChecklist,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final propertyDocumentNotifierProvider =
    NotifierProvider<PropertyDocumentNotifier, PropertyDocumentState>(PropertyDocumentNotifier.new);

class PropertyDocumentNotifier extends Notifier<PropertyDocumentState> {
  late final PropertyDocumentRepository _repo;

  @override
  PropertyDocumentState build() {
    _repo = ref.watch(propertyDocumentRepositoryProvider);
    return const PropertyDocumentState();
  }

  Future<void> loadPropertyDocuments(String propertyId, {PropertyCategory category = PropertyCategory.residential}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final docs = await _repo.getDocumentsForProperty(propertyId);
      final checklist = await _repo.getDueDiligenceChecklist(propertyId: propertyId, category: category);
      state = state.copyWith(
        documents: docs,
        dueDiligenceChecklist: checklist,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> uploadDocument(PropertyDocumentEntity doc, {PropertyCategory category = PropertyCategory.residential}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.uploadDocument(doc);
      await loadPropertyDocuments(doc.propertyId, category: category);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Document uploaded successfully to private storage.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> replaceDocument({
    required String propertyId,
    required String documentId,
    required String newUrl,
    required String newName,
    required String fileFormat,
    PropertyCategory category = PropertyCategory.residential,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.replaceDocument(
        documentId: documentId,
        newUrl: newUrl,
        newName: newName,
        fileFormat: fileFormat,
      );
      await loadPropertyDocuments(propertyId, category: category);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Document replaced successfully.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteDocument(String propertyId, String documentId, {PropertyCategory category = PropertyCategory.residential}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.deleteDocument(documentId);
      await loadPropertyDocuments(propertyId, category: category);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Document removed from repository.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> requestDocumentAccess({
    required String propertyId,
    required String documentId,
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
    PropertyCategory category = PropertyCategory.residential,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.requestDocumentAccess(
        propertyId: propertyId,
        documentId: documentId,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
      );
      await loadPropertyDocuments(propertyId, category: category);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Access request sent to property owner.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> grantDocumentAccess({
    required String propertyId,
    required String documentId,
    required String buyerId,
    PropertyCategory category = PropertyCategory.residential,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.grantDocumentAccess(documentId: documentId, buyerId: buyerId);
      await loadPropertyDocuments(propertyId, category: category);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Document access granted to buyer.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateDocumentStatus({
    required String propertyId,
    required String documentId,
    required DocumentLifecycleStatus status,
    String? notes,
    PropertyCategory category = PropertyCategory.residential,
  }) async {
    try {
      await _repo.updateDocumentStatus(documentId: documentId, status: status, notes: notes);
      await loadPropertyDocuments(propertyId, category: category);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateDueDiligenceStatus({
    required String propertyId,
    required String checkItemId,
    required DueDiligenceCheckStatus status,
    String? notes,
    PropertyCategory category = PropertyCategory.residential,
  }) async {
    try {
      await _repo.updateDueDiligenceStatus(
        propertyId: propertyId,
        checkItemId: checkItemId,
        status: status,
        notes: notes,
      );
      await loadPropertyDocuments(propertyId, category: category);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
