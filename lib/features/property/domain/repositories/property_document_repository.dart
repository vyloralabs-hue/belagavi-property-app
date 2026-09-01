import '../entities/property_entities.dart' show PropertyCategory;
import '../entities/property_document_entity.dart';

abstract class PropertyDocumentRepository {
  Future<List<PropertyDocumentEntity>> getDocumentsForProperty(String propertyId);
  Future<PropertyDocumentEntity?> getDocumentById(String documentId);
  Future<String> uploadDocument(PropertyDocumentEntity document);
  Future<void> replaceDocument({required String documentId, required String newUrl, required String newName, required String fileFormat});
  Future<void> deleteDocument(String documentId);
  Future<void> updateDocumentStatus({required String documentId, required DocumentLifecycleStatus status, String? notes});
  Future<void> requestDocumentAccess({
    required String propertyId,
    required String documentId,
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
  });
  Future<void> grantDocumentAccess({required String documentId, required String buyerId});
  Future<void> revokeDocumentAccess({required String documentId, required String buyerId});
  Future<List<DueDiligenceCheckItem>> getDueDiligenceChecklist({required String propertyId, required PropertyCategory category});
  Future<void> updateDueDiligenceStatus({
    required String propertyId,
    required String checkItemId,
    required DueDiligenceCheckStatus status,
    String? notes,
  });
}
