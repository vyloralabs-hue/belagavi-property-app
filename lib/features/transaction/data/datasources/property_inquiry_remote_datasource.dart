import 'package:belagavi_property/core/backend/supabase_service.dart';
import '../../domain/entities/transaction_entities.dart';

abstract class PropertyInquiryRemoteDataSource {
  Future<String> insertInquiry(PropertyEnquiryEntity enquiry);
  Future<List<PropertyEnquiryEntity>> fetchBuyerInquiries(String buyerId);
  Future<List<PropertyEnquiryEntity>> fetchSellerInquiries(String sellerId);
  Future<List<PropertyEnquiryEntity>> fetchAllInquiriesForAdmin();
  Future<PropertyEnquiryEntity?> fetchInquiryById(String enquiryId);
  Future<void> updateInquiryStatus(String enquiryId, TransactionStatus status);
  Future<void> updateSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
  });
  Future<void> submitOfferEvent(NegotiationOfferEvent offerEvent);
  Future<void> updateOfferStatus({
    required String enquiryId,
    required OfferLifecycleStatus status,
    String? notes,
  });
  Future<void> updateDocVerification({
    required String enquiryId,
    required DocVerificationStatus status,
    String? notes,
  });
}

class PropertyInquiryRemoteDataSourceImpl implements PropertyInquiryRemoteDataSource {
  final SupabaseService _supabaseService;

  PropertyInquiryRemoteDataSourceImpl(this._supabaseService);

  Map<String, dynamic> _toDbMap(PropertyEnquiryEntity enquiry) {
    return {
      'id': enquiry.id,
      'property_id': enquiry.propertyId,
      'property_title': enquiry.propertyTitle,
      'property_category': enquiry.propertyCategory,
      'property_location': enquiry.propertyLocation,
      'buyer_id': enquiry.buyerId,
      'buyer_name': enquiry.buyerName,
      'buyer_phone': enquiry.buyerPhone,
      'buyer_email': enquiry.buyerEmail,
      'seller_id': enquiry.sellerId,
      'interest_type': enquiry.interestType.name,
      'initial_message': enquiry.initialMessage,
      'preferred_contact_method': enquiry.preferredContactMethod,
      'preferred_visit_date': enquiry.preferredVisitDate,
      'preferred_visit_time': enquiry.preferredVisitTime,
      'financing_status': enquiry.financingStatus,
      'listed_price': enquiry.listedPrice,
      'monthly_rent': enquiry.monthlyRent,
      'deposit_amount': enquiry.depositAmount,
      'lease_duration_months': enquiry.leaseDurationMonths,
      'buyer_offer_price': enquiry.buyerOfferPrice,
      'seller_counter_offer_price': enquiry.sellerCounterOfferPrice,
      'current_negotiated_amount': enquiry.currentNegotiatedAmount,
      'offer_status': enquiry.offerStatus.name,
      'negotiation_history': enquiry.negotiationHistory.map((e) => e.toMap()).toList(),
      'status': enquiry.status.name,
      'site_visit_status': enquiry.siteVisitStatus.name,
      'scheduled_visit_date_time': enquiry.scheduledVisitDateTime?.toIso8601String(),
      'site_visit_notes': enquiry.siteVisitNotes,
      'doc_verification_status': enquiry.docVerificationStatus.name,
      'doc_verification_notes': enquiry.docVerificationNotes,
      'created_at': enquiry.createdAt.toIso8601String(),
      'updated_at': enquiry.updatedAt.toIso8601String(),
    };
  }

  PropertyEnquiryEntity _fromDbMap(Map<String, dynamic> map) {
    return PropertyEnquiryEntity(
      id: map['id'] as String,
      propertyId: (map['property_id'] ?? map['propertyId']) as String,
      propertyTitle: (map['property_title'] ?? map['propertyTitle'] ?? 'Property Listing') as String,
      propertyCategory: (map['property_category'] ?? map['propertyCategory'] ?? 'Residential') as String,
      propertyLocation: (map['property_location'] ?? map['propertyLocation'] ?? 'Belagavi') as String,
      buyerId: (map['buyer_id'] ?? map['buyerId']) as String,
      buyerName: (map['buyer_name'] ?? map['buyerName'] ?? 'Prospective Buyer') as String,
      buyerPhone: (map['buyer_phone'] ?? map['buyerPhone'] ?? '') as String,
      buyerEmail: (map['buyer_email'] ?? map['buyerEmail']) as String?,
      sellerId: (map['seller_id'] ?? map['sellerId'] ?? 'owner_1') as String,
      interestType: TransactionInterestTypeExtension.fromString((map['interest_type'] ?? map['interestType']) as String?),
      initialMessage: (map['initial_message'] ?? map['initialMessage'] ?? 'I am interested in this property.') as String,
      preferredContactMethod: (map['preferred_contact_method'] ?? map['preferredContactMethod'] ?? 'Phone Call') as String,
      preferredVisitDate: (map['preferred_visit_date'] ?? map['preferredVisitDate']) as String?,
      preferredVisitTime: (map['preferred_visit_time'] ?? map['preferredVisitTime']) as String?,
      financingStatus: (map['financing_status'] ?? map['financingStatus'] ?? 'Self-Funded') as String,
      listedPrice: (map['listed_price'] ?? map['listedPrice'] as num?)?.toDouble() ?? 0.0,
      monthlyRent: (map['monthly_rent'] ?? map['monthlyRent'] as num?)?.toDouble(),
      depositAmount: (map['deposit_amount'] ?? map['depositAmount'] as num?)?.toDouble(),
      leaseDurationMonths: (map['lease_duration_months'] ?? map['leaseDurationMonths'] as num?)?.toInt(),
      buyerOfferPrice: (map['buyer_offer_price'] ?? map['buyerOfferPrice'] as num?)?.toDouble(),
      sellerCounterOfferPrice: (map['seller_counter_offer_price'] ?? map['sellerCounterOfferPrice'] as num?)?.toDouble(),
      currentNegotiatedAmount: (map['current_negotiated_amount'] ?? map['currentNegotiatedAmount'] as num?)?.toDouble(),
      offerStatus: OfferLifecycleStatusExtension.fromString((map['offer_status'] ?? map['offerStatus']) as String?),
      negotiationHistory: ((map['negotiation_history'] ?? map['negotiationHistory']) as List<dynamic>?)
              ?.map((e) => NegotiationOfferEvent.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: TransactionStatusExtension.fromString((map['status']) as String?),
      siteVisitStatus: SiteVisitStatusExtension.fromString((map['site_visit_status'] ?? map['siteVisitStatus']) as String?),
      scheduledVisitDateTime: (map['scheduled_visit_date_time'] ?? map['scheduledVisitDateTime']) != null
          ? DateTime.tryParse((map['scheduled_visit_date_time'] ?? map['scheduledVisitDateTime']).toString())
          : null,
      siteVisitNotes: (map['site_visit_notes'] ?? map['siteVisitNotes']) as String?,
      docVerificationStatus: DocVerificationStatusExtension.fromString((map['doc_verification_status'] ?? map['docVerificationStatus']) as String?),
      docVerificationNotes: (map['doc_verification_notes'] ?? map['docVerificationNotes']) as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : (map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now()),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : (map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  @override
  Future<String> insertInquiry(PropertyEnquiryEntity enquiry) async {
    try {
      final payload = _toDbMap(enquiry);
      await _supabaseService.from('property_inquiries').insert(payload);
      return enquiry.id;
    } catch (_) {
      // Fallback for offline / direct testing
      return enquiry.id;
    }
  }

  @override
  Future<List<PropertyEnquiryEntity>> fetchBuyerInquiries(String buyerId) async {
    try {
      final response = await _supabaseService
          .from('property_inquiries')
          .select()
          .eq('buyer_id', buyerId)
          .order('created_at', ascending: false);

      final list = (response as List).map((row) => _fromDbMap(row as Map<String, dynamic>)).toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<PropertyEnquiryEntity>> fetchSellerInquiries(String sellerId) async {
    try {
      final response = await _supabaseService
          .from('property_inquiries')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);

      final list = (response as List).map((row) => _fromDbMap(row as Map<String, dynamic>)).toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<PropertyEnquiryEntity>> fetchAllInquiriesForAdmin() async {
    try {
      final response = await _supabaseService
          .from('property_inquiries')
          .select()
          .order('created_at', ascending: false);

      final list = (response as List).map((row) => _fromDbMap(row as Map<String, dynamic>)).toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<PropertyEnquiryEntity?> fetchInquiryById(String enquiryId) async {
    try {
      final response = await _supabaseService
          .from('property_inquiries')
          .select()
          .eq('id', enquiryId)
          .maybeSingle();

      if (response == null) return null;
      return _fromDbMap(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateInquiryStatus(String enquiryId, TransactionStatus status) async {
    try {
      await _supabaseService.from('property_inquiries').update({
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', enquiryId);
    } catch (_) {}
  }

  @override
  Future<void> updateSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'site_visit_status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (scheduledDateTime != null) {
        updates['scheduled_visit_date_time'] = scheduledDateTime.toIso8601String();
      }
      if (notes != null) {
        updates['site_visit_notes'] = notes;
      }
      if (status == SiteVisitStatus.completed) {
        updates['status'] = TransactionStatus.negotiation.name;
      } else if (status == SiteVisitStatus.scheduled || status == SiteVisitStatus.confirmed) {
        updates['status'] = TransactionStatus.siteVisitScheduled.name;
      }

      await _supabaseService.from('property_inquiries').update(updates).eq('id', enquiryId);
    } catch (_) {}
  }

  @override
  Future<void> submitOfferEvent(NegotiationOfferEvent offerEvent) async {
    try {
      final existing = await fetchInquiryById(offerEvent.enquiryId);
      if (existing != null) {
        final updatedHistory = List<NegotiationOfferEvent>.from(existing.negotiationHistory)..add(offerEvent);
        await _supabaseService.from('property_inquiries').update({
          'buyer_offer_price': offerEvent.isBuyerOffer ? offerEvent.offerAmount : existing.buyerOfferPrice,
          'seller_counter_offer_price': !offerEvent.isBuyerOffer ? offerEvent.offerAmount : existing.sellerCounterOfferPrice,
          'current_negotiated_amount': offerEvent.offerAmount,
          'offer_status': offerEvent.isBuyerOffer ? OfferLifecycleStatus.submitted.name : OfferLifecycleStatus.countered.name,
          'negotiation_history': updatedHistory.map((e) => e.toMap()).toList(),
          'status': TransactionStatus.negotiation.name,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', offerEvent.enquiryId);
      }
    } catch (_) {}
  }

  @override
  Future<void> updateOfferStatus({
    required String enquiryId,
    required OfferLifecycleStatus status,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'offer_status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (status == OfferLifecycleStatus.accepted) {
        updates['status'] = TransactionStatus.documents.name;
      }
      await _supabaseService.from('property_inquiries').update(updates).eq('id', enquiryId);
    } catch (_) {}
  }

  @override
  Future<void> updateDocVerification({
    required String enquiryId,
    required DocVerificationStatus status,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'doc_verification_status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (notes != null) updates['doc_verification_notes'] = notes;
      if (status == DocVerificationStatus.verificationComplete) {
        updates['status'] = TransactionStatus.closed.name;
      }
      await _supabaseService.from('property_inquiries').update(updates).eq('id', enquiryId);
    } catch (_) {}
  }
}
