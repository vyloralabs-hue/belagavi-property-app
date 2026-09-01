import '../../domain/entities/property_entities.dart' show PropertyCategory;
import '../../domain/entities/property_document_entity.dart';
import '../../domain/repositories/property_document_repository.dart';

class PropertyDocumentRepositoryImpl implements PropertyDocumentRepository {
  final Map<String, PropertyDocumentEntity> _documents = {};
  final Map<String, List<DueDiligenceCheckItem>> _checklists = {};

  PropertyDocumentRepositoryImpl() {
    _seedInitialDocuments();
  }

  void _seedInitialDocuments() {
    final now = DateTime.now();

    // ─── 1. Residential Housing Documents (prop_1) ───────────────────────────
    final d1 = PropertyDocumentEntity(
      id: 'doc_res_1',
      propertyId: 'prop_1',
      documentType: PropertyDocumentCategoryType.saleDeed,
      documentName: 'Registered_Sale_Deed_Tilakwadi_2018.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_1/prop_1/sale_deed_2018.pdf',
      uploadedBy: 'owner_1',
      fileFormat: 'PDF',
      fileSizeBytes: 2450000,
      status: DocumentLifecycleStatus.submitted,
      notes: 'Original registered deed executed at Belagavi Sub-Registrar Office.',
      grantedBuyerIds: const ['usr_buyer_1'],
      uploadedAt: now.subtract(const Duration(days: 10)),
    );

    final d2 = PropertyDocumentEntity(
      id: 'doc_res_2',
      propertyId: 'prop_1',
      documentType: PropertyDocumentCategoryType.encumbranceCertificate,
      documentName: 'EC_Form_15_Tilakwadi_15Years.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_1/prop_1/ec_form15.pdf',
      uploadedBy: 'owner_1',
      fileFormat: 'PDF',
      fileSizeBytes: 1850000,
      status: DocumentLifecycleStatus.reviewComplete,
      notes: 'Nil encumbrance certified from 2010 to 2026.',
      grantedBuyerIds: const ['usr_buyer_1'],
      uploadedAt: now.subtract(const Duration(days: 8)),
    );

    final d3 = PropertyDocumentEntity(
      id: 'doc_res_3',
      propertyId: 'prop_1',
      documentType: PropertyDocumentCategoryType.khataMunicipalExtract,
      documentName: 'City_Corporation_Khata_Extract_2025.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_1/prop_1/khata_2025.pdf',
      uploadedBy: 'owner_1',
      fileFormat: 'PDF',
      fileSizeBytes: 980000,
      status: DocumentLifecycleStatus.submitted,
      notes: 'Belagavi City Corporation Khata certificate in current owner name.',
      grantedBuyerIds: const ['usr_buyer_1'],
      uploadedAt: now.subtract(const Duration(days: 5)),
    );

    // ─── 2. Commercial Property Documents (prop_2) ───────────────────────────
    final d4 = PropertyDocumentEntity(
      id: 'doc_comm_1',
      propertyId: 'prop_2',
      documentType: PropertyDocumentCategoryType.conversionNaOrder,
      documentName: 'DC_Commercial_Conversion_Order_Khanapur_Rd.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_1/prop_2/comm_conversion.pdf',
      uploadedBy: 'owner_1',
      fileFormat: 'PDF',
      fileSizeBytes: 3200000,
      status: DocumentLifecycleStatus.submitted,
      notes: 'Deputy Commissioner commercial land conversion sanction order.',
      grantedBuyerIds: const [],
      accessRequests: [
        DocumentAccessRequest(
          id: 'req_101',
          propertyId: 'prop_2',
          documentId: 'doc_comm_1',
          documentName: 'DC_Commercial_Conversion_Order_Khanapur_Rd.pdf',
          buyerId: 'usr_buyer_2',
          buyerName: 'Priya Kulkarni',
          buyerPhone: '+91 94812 67890',
          requestedAt: now.subtract(const Duration(hours: 4)),
          isGranted: false,
        ),
      ],
      uploadedAt: now.subtract(const Duration(days: 12)),
    );

    final d5 = PropertyDocumentEntity(
      id: 'doc_comm_2',
      propertyId: 'prop_2',
      documentType: PropertyDocumentCategoryType.buildingApproval,
      documentName: 'Commercial_Building_Sanction_Plan.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_1/prop_2/sanction_plan.pdf',
      uploadedBy: 'owner_1',
      fileFormat: 'PDF',
      fileSizeBytes: 4100000,
      status: DocumentLifecycleStatus.submitted,
      notes: 'Approved blueprint & occupancy clearance for G+3 commercial complex.',
      grantedBuyerIds: const [],
      uploadedAt: now.subtract(const Duration(days: 12)),
    );

    // ─── 3. Plot / Land Documents (prop_3) ───────────────────────────────────
    final d6 = PropertyDocumentEntity(
      id: 'doc_plot_1',
      propertyId: 'prop_3',
      documentType: PropertyDocumentCategoryType.layoutApproval,
      documentName: 'BUDA_Approved_Layout_Plan_BhagyaNagar.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_2/prop_3/buda_layout.pdf',
      uploadedBy: 'owner_2',
      fileFormat: 'PDF',
      fileSizeBytes: 2800000,
      status: DocumentLifecycleStatus.reviewComplete,
      notes: 'BUDA approved layout LP/44/2021 with all open spaces released.',
      grantedBuyerIds: const ['usr_buyer_1'],
      uploadedAt: now.subtract(const Duration(days: 15)),
    );

    final d7 = PropertyDocumentEntity(
      id: 'doc_plot_2',
      propertyId: 'prop_3',
      documentType: PropertyDocumentCategoryType.surveyRecordDemarcation,
      documentName: 'Tahsildar_Demarcation_Sketch_11E.jpg',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_2/prop_3/sketch_11e.jpg',
      uploadedBy: 'owner_2',
      fileFormat: 'JPG',
      fileSizeBytes: 1200000,
      status: DocumentLifecycleStatus.submitted,
      notes: 'ADLR verified boundary demarcation map with stone markers.',
      grantedBuyerIds: const ['usr_buyer_1'],
      uploadedAt: now.subtract(const Duration(days: 14)),
    );

    // ─── 4. Raw Land Documents (prop_4) ──────────────────────────────────────
    final d8 = PropertyDocumentEntity(
      id: 'doc_raw_1',
      propertyId: 'prop_4',
      documentType: PropertyDocumentCategoryType.rtcPahani,
      documentName: 'RTC_Pahani_Survey_78_1_Sambra.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_3/prop_4/rtc_sambra.pdf',
      uploadedBy: 'owner_3',
      fileFormat: 'PDF',
      fileSizeBytes: 1540000,
      status: DocumentLifecycleStatus.submitted,
      notes: 'Form 16 Bhoomi RTC extract showing single owner in Column 9/10.',
      grantedBuyerIds: const [],
      uploadedAt: now.subtract(const Duration(days: 7)),
    );

    final d9 = PropertyDocumentEntity(
      id: 'doc_raw_2',
      propertyId: 'prop_4',
      documentType: PropertyDocumentCategoryType.mutationRevenueRecord,
      documentName: 'Mutation_Extract_MR_12_2020.pdf',
      documentUrl: 'https://storage.supabase.co/property-documents/owner_3/prop_4/mutation_extract.pdf',
      uploadedBy: 'owner_3',
      fileFormat: 'PDF',
      fileSizeBytes: 1100000,
      status: DocumentLifecycleStatus.underReview,
      notes: 'Inheritance partition mutation entry sanctioned by Village Accountant/RI.',
      grantedBuyerIds: const [],
      uploadedAt: now.subtract(const Duration(days: 6)),
    );

    for (final doc in [d1, d2, d3, d4, d5, d6, d7, d8, d9]) {
      _documents[doc.id] = doc;
    }
  }

  @override
  Future<List<PropertyDocumentEntity>> getDocumentsForProperty(String propertyId) async {
    return _documents.values.where((d) => d.propertyId == propertyId).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  @override
  Future<PropertyDocumentEntity?> getDocumentById(String documentId) async {
    return _documents[documentId];
  }

  @override
  Future<String> uploadDocument(PropertyDocumentEntity document) async {
    _documents[document.id] = document;
    return document.id;
  }

  @override
  Future<void> replaceDocument({
    required String documentId,
    required String newUrl,
    required String newName,
    required String fileFormat,
  }) async {
    final existing = _documents[documentId];
    if (existing != null) {
      _documents[documentId] = existing.copyWith(
        documentUrl: newUrl,
        documentName: newName,
        fileFormat: fileFormat,
        uploadedAt: DateTime.now(),
        status: DocumentLifecycleStatus.submitted,
      );
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    _documents.remove(documentId);
  }

  @override
  Future<void> updateDocumentStatus({
    required String documentId,
    required DocumentLifecycleStatus status,
    String? notes,
  }) async {
    final existing = _documents[documentId];
    if (existing != null) {
      _documents[documentId] = existing.copyWith(
        status: status,
        notes: notes ?? existing.notes,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> requestDocumentAccess({
    required String propertyId,
    required String documentId,
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
  }) async {
    final doc = _documents[documentId];
    if (doc != null) {
      final req = DocumentAccessRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: propertyId,
        documentId: documentId,
        documentName: doc.documentName,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        requestedAt: DateTime.now(),
      );
      final updatedRequests = List<DocumentAccessRequest>.from(doc.accessRequests)..add(req);
      _documents[documentId] = doc.copyWith(
        status: DocumentLifecycleStatus.accessRequested,
        accessRequests: updatedRequests,
      );
    }
  }

  @override
  Future<void> grantDocumentAccess({required String documentId, required String buyerId}) async {
    final doc = _documents[documentId];
    if (doc != null) {
      final updatedGrants = Set<String>.from(doc.grantedBuyerIds)..add(buyerId);
      final updatedRequests = doc.accessRequests.map((r) {
        if (r.buyerId == buyerId) {
          return r.copyWith(isGranted: true, grantedAt: DateTime.now());
        }
        return r;
      }).toList();

      _documents[documentId] = doc.copyWith(
        grantedBuyerIds: updatedGrants.toList(),
        accessRequests: updatedRequests,
        status: DocumentLifecycleStatus.accessGranted,
      );
    }
  }

  @override
  Future<void> revokeDocumentAccess({required String documentId, required String buyerId}) async {
    final doc = _documents[documentId];
    if (doc != null) {
      final updatedGrants = Set<String>.from(doc.grantedBuyerIds)..remove(buyerId);
      _documents[documentId] = doc.copyWith(
        grantedBuyerIds: updatedGrants.toList(),
      );
    }
  }

  @override
  Future<List<DueDiligenceCheckItem>> getDueDiligenceChecklist({
    required String propertyId,
    required PropertyCategory category,
  }) async {
    if (_checklists.containsKey(propertyId)) {
      return _checklists[propertyId]!;
    }

    final checklist = _buildStandardChecklist(category);
    _checklists[propertyId] = checklist;
    return checklist;
  }

  List<DueDiligenceCheckItem> _buildStandardChecklist(PropertyCategory category) {
    return [
      const DueDiligenceCheckItem(
        id: 'dd_1',
        title: '1. Primary Title & Sale Deed Scrutiny',
        description: 'Verify current registered sale deed in seller name with official stamp & sub-registrar seal.',
        requiredDocumentType: PropertyDocumentCategoryType.saleDeed,
        status: DueDiligenceCheckStatus.reviewed,
        notes: 'Registered sale deed verified. Name matches government record.',
      ),
      const DueDiligenceCheckItem(
        id: 'dd_2',
        title: '2. 30-Year Prior Title Chain',
        description: 'Trace continuous ownership lineage from ancestral or prior sellers to prevent third-party claims.',
        requiredDocumentType: PropertyDocumentCategoryType.previousSaleDeedTitleChain,
        status: DueDiligenceCheckStatus.pending,
      ),
      const DueDiligenceCheckItem(
        id: 'dd_3',
        title: '3. Encumbrance Certificate (EC Form 15)',
        description: 'Ensure no active registered bank mortgage, court attachment, or lien on property.',
        requiredDocumentType: PropertyDocumentCategoryType.encumbranceCertificate,
        status: DueDiligenceCheckStatus.reviewed,
        notes: 'Form 15 issued by Sub-Registrar shows nil encumbrance.',
      ),
      if (category == PropertyCategory.plotLand) ...[
        const DueDiligenceCheckItem(
          id: 'dd_4_plot',
          title: '4. Non-Agricultural (NA) Conversion Order',
          description: 'Ensure land is legally converted from agricultural to residential/commercial by Deputy Commissioner.',
          requiredDocumentType: PropertyDocumentCategoryType.conversionNaOrder,
          status: DueDiligenceCheckStatus.reviewed,
        ),
        const DueDiligenceCheckItem(
          id: 'dd_5_plot',
          title: '5. BUDA / Gram Panchayat Layout Approval',
          description: 'Verify approved layout map with CA/park reservations released.',
          requiredDocumentType: PropertyDocumentCategoryType.layoutApproval,
          status: DueDiligenceCheckStatus.reviewed,
        ),
        const DueDiligenceCheckItem(
          id: 'dd_6_plot',
          title: '6. Survey Demarcation & Boundary Markers',
          description: 'Check official Mojini survey demarcation and physical stone markers on plot perimeter.',
          requiredDocumentType: PropertyDocumentCategoryType.surveyRecordDemarcation,
          status: DueDiligenceCheckStatus.reviewed,
        ),
      ],
      if (category == PropertyCategory.land) ...[
        const DueDiligenceCheckItem(
          id: 'dd_4_land',
          title: '4. Bhoomi RTC / Pahani (Current Year)',
          description: 'Verify Column 9 owner name, Column 10 rights, Column 11 liabilities, and Column 12 crop details.',
          requiredDocumentType: PropertyDocumentCategoryType.rtcPahani,
          status: DueDiligenceCheckStatus.reviewed,
        ),
        const DueDiligenceCheckItem(
          id: 'dd_5_land',
          title: '5. Mutation Register Extract (MR)',
          description: 'Verify government revenue mutation entry number for the title transfer.',
          requiredDocumentType: PropertyDocumentCategoryType.mutationRevenueRecord,
          status: DueDiligenceCheckStatus.pending,
        ),
        const DueDiligenceCheckItem(
          id: 'dd_6_land',
          title: '6. 11E Sketch / Survey Demarcation',
          description: 'Check official Mojini survey demarcation and physical boundary markers.',
          requiredDocumentType: PropertyDocumentCategoryType.surveyRecordDemarcation,
          status: DueDiligenceCheckStatus.pending,
        ),
      ],
      if (category == PropertyCategory.residential || category == PropertyCategory.commercial) ...[
        const DueDiligenceCheckItem(
          id: 'dd_4_building',
          title: '4. Municipal Khata Certificate (A-Khata)',
          description: 'Verify City Corporation / Municipal Khata extract and property assessment number.',
          requiredDocumentType: PropertyDocumentCategoryType.khataMunicipalExtract,
          status: DueDiligenceCheckStatus.reviewed,
        ),
        const DueDiligenceCheckItem(
          id: 'dd_5_building',
          title: '5. Building Plan Sanction / Comm. Certificate',
          description: 'Ensure constructed area complies with approved setback and FAR regulations.',
          requiredDocumentType: PropertyDocumentCategoryType.buildingApproval,
          status: DueDiligenceCheckStatus.pending,
        ),
      ],
      const DueDiligenceCheckItem(
        id: 'dd_tax',
        title: '7. Property Tax Paid Challan',
        description: 'Confirm latest financial year municipal or gram panchayat tax receipt.',
        requiredDocumentType: PropertyDocumentCategoryType.propertyTaxReceipt,
        status: DueDiligenceCheckStatus.reviewed,
      ),
      const DueDiligenceCheckItem(
        id: 'dd_dispute',
        title: '8. Litigation & Dispute Status Check',
        description: 'Verify property against court stay orders, partition suits, and platform dispute registry.',
        requiredDocumentType: PropertyDocumentCategoryType.otherSupportingDoc,
        status: DueDiligenceCheckStatus.reviewed,
        notes: 'No active litigation reported on public registry.',
      ),
      const DueDiligenceCheckItem(
        id: 'dd_kyc',
        title: '9. Seller Identity & KYC Verification',
        description: 'Verify Aadhaar/PAN of all legal heirs or co-owners signing the agreement.',
        requiredDocumentType: PropertyDocumentCategoryType.identityOwnershipProof,
        status: DueDiligenceCheckStatus.pending,
      ),
      const DueDiligenceCheckItem(
        id: 'dd_physical',
        title: '10. Physical On-Site Inspection & Possession',
        description: 'Inspect physical boundaries, road access, neighboring survey boundaries, and vacant possession.',
        requiredDocumentType: PropertyDocumentCategoryType.otherSupportingDoc,
        status: DueDiligenceCheckStatus.reviewed,
      ),
    ];
  }

  @override
  Future<void> updateDueDiligenceStatus({
    required String propertyId,
    required String checkItemId,
    required DueDiligenceCheckStatus status,
    String? notes,
  }) async {
    final list = _checklists[propertyId];
    if (list != null) {
      _checklists[propertyId] = list.map((item) {
        if (item.id == checkItemId) {
          return item.copyWith(
            status: status,
            notes: notes ?? item.notes,
            lastCheckedDate: DateTime.now(),
          );
        }
        return item;
      }).toList();
    }
  }
}
