import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart' show PropertyCategory;
import 'package:belagavi_property/features/property/domain/entities/property_document_entity.dart';
import 'package:belagavi_property/features/property/data/repositories/property_document_repository_impl.dart';

void main() {
  late PropertyDocumentRepositoryImpl repository;

  setUp(() {
    repository = PropertyDocumentRepositoryImpl();
  });

  group('Phase 8: Property Documents + Due Diligence Workflow Tests', () {
    test('1. Seller Document Upload with Format & Category Type', () async {
      final doc = PropertyDocumentEntity(
        id: 'test_doc_101',
        propertyId: 'prop_test_1',
        documentType: PropertyDocumentCategoryType.saleDeed,
        documentName: 'Registered_Sale_Deed_Test.pdf',
        documentUrl: 'https://storage.supabase.co/property-documents/owner_test/prop_test_1/deed.pdf',
        uploadedBy: 'owner_test',
        fileFormat: 'PDF',
        fileSizeBytes: 2048000,
        status: DocumentLifecycleStatus.submitted,
        notes: 'Original deed executed at Belagavi SRO.',
        uploadedAt: DateTime.now(),
      );

      final id = await repository.uploadDocument(doc);
      expect(id, 'test_doc_101');

      final fetched = await repository.getDocumentById('test_doc_101');
      expect(fetched, isNotNull);
      expect(fetched!.documentType, PropertyDocumentCategoryType.saleDeed);
      expect(fetched.fileFormat, 'PDF');
      expect(fetched.status, DocumentLifecycleStatus.submitted);
    });

    test('2. Private Access Control Isolation — Unauthorized Buyer Denied', () async {
      final doc = PropertyDocumentEntity(
        id: 'test_doc_private',
        propertyId: 'prop_test_1',
        documentType: PropertyDocumentCategoryType.encumbranceCertificate,
        documentName: 'EC_Form_15_Confidential.pdf',
        documentUrl: 'https://storage.supabase.co/property-documents/owner_test/prop_test_1/ec.pdf',
        uploadedBy: 'owner_test',
        grantedBuyerIds: const ['usr_authorized_buyer'],
        uploadedAt: DateTime.now(),
      );

      // Owner has access
      expect(doc.canUserAccess('owner_test', 'owner_test'), isTrue);

      // Authorized buyer has access
      expect(doc.canUserAccess('usr_authorized_buyer', 'owner_test'), isTrue);

      // Unauthorized buyer is strictly blocked
      expect(doc.canUserAccess('usr_random_stranger', 'owner_test'), isFalse);
    });

    test('3. Buyer Document Access Request & Seller Grant Workflow', () async {
      // Buyer requests access
      await repository.requestDocumentAccess(
        propertyId: 'prop_2',
        documentId: 'doc_comm_1',
        buyerId: 'usr_buyer_99',
        buyerName: 'Vikram Joshi',
        buyerPhone: '+91 98866 54321',
      );

      var doc = await repository.getDocumentById('doc_comm_1');
      expect(doc!.status, DocumentLifecycleStatus.accessRequested);
      expect(doc.accessRequests.any((r) => r.buyerId == 'usr_buyer_99'), isTrue);
      expect(doc.canUserAccess('usr_buyer_99', 'owner_1'), isFalse);

      // Seller grants access
      await repository.grantDocumentAccess(
        documentId: 'doc_comm_1',
        buyerId: 'usr_buyer_99',
      );

      doc = await repository.getDocumentById('doc_comm_1');
      expect(doc!.status, DocumentLifecycleStatus.accessGranted);
      expect(doc.grantedBuyerIds.contains('usr_buyer_99'), isTrue);
      expect(doc.canUserAccess('usr_buyer_99', 'owner_1'), isTrue);
    });

    test('4. Category-Specific Document Type Relevance', () {
      // Plot requires NA conversion & layout approval
      expect(PropertyDocumentCategoryType.conversionNaOrder.isRelevantForCategory(PropertyCategory.plotLand), isTrue);
      expect(PropertyDocumentCategoryType.layoutApproval.isRelevantForCategory(PropertyCategory.plotLand), isTrue);
      expect(PropertyDocumentCategoryType.rtcPahani.isRelevantForCategory(PropertyCategory.plotLand), isFalse);

      // Raw Land requires Bhoomi RTC & Mutation record
      expect(PropertyDocumentCategoryType.rtcPahani.isRelevantForCategory(PropertyCategory.land), isTrue);
      expect(PropertyDocumentCategoryType.mutationRevenueRecord.isRelevantForCategory(PropertyCategory.land), isTrue);
      expect(PropertyDocumentCategoryType.buildingApproval.isRelevantForCategory(PropertyCategory.land), isFalse);

      // Housing (Residential) requires Khata & Building sanction
      expect(PropertyDocumentCategoryType.khataMunicipalExtract.isRelevantForCategory(PropertyCategory.residential), isTrue);
      expect(PropertyDocumentCategoryType.buildingApproval.isRelevantForCategory(PropertyCategory.residential), isTrue);
      expect(PropertyDocumentCategoryType.rtcPahani.isRelevantForCategory(PropertyCategory.residential), isFalse);
    });

    test('5. 10-Point Due Diligence Checklist Generation & Status Updates', () async {
      final checklist = await repository.getDueDiligenceChecklist(
        propertyId: 'prop_test_dd',
        category: PropertyCategory.plotLand,
      );

      expect(checklist.length, 10);
      expect(checklist.any((c) => c.title.contains('NA) Conversion')), isTrue);
      expect(checklist.any((c) => c.title.contains('Layout Approval')), isTrue);

      // Update status
      await repository.updateDueDiligenceStatus(
        propertyId: 'prop_test_dd',
        checkItemId: 'dd_1',
        status: DueDiligenceCheckStatus.reviewed,
        notes: 'Title search confirmed by panel advocate.',
      );

      final updatedChecklist = await repository.getDueDiligenceChecklist(
        propertyId: 'prop_test_dd',
        category: PropertyCategory.plotLand,
      );

      final item1 = updatedChecklist.firstWhere((c) => c.id == 'dd_1');
      expect(item1.status, DueDiligenceCheckStatus.reviewed);
      expect(item1.notes, 'Title search confirmed by panel advocate.');
    });

    test('6. Document Replacement and Deletion', () async {
      await repository.replaceDocument(
        documentId: 'doc_res_3',
        newUrl: 'https://storage.supabase.co/property-documents/owner_1/prop_1/khata_2026_updated.pdf',
        newName: 'City_Corporation_Khata_Extract_2026.pdf',
        fileFormat: 'PDF',
      );

      var doc = await repository.getDocumentById('doc_res_3');
      expect(doc!.documentName, 'City_Corporation_Khata_Extract_2026.pdf');

      // Delete document
      await repository.deleteDocument('doc_res_3');
      doc = await repository.getDocumentById('doc_res_3');
      expect(doc, isNull);
    });
  });
}
