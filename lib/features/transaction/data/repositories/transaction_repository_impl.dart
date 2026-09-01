import 'package:belagavi_property/core/errors/security_exceptions.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final Map<String, PropertyEnquiryEntity> _enquiries = {};

  TransactionRepositoryImpl() {
    _seedInitialEnquiries();
  }

  void _seedInitialEnquiries() {
    final now = DateTime.now();

    // ─── 1. Residential Villa (For Sale) with Multi-Round Negotiation ────────
    final offerEvent1 = NegotiationOfferEvent(
      id: 'off_event_1',
      enquiryId: 'enq_101',
      submittedByUserId: 'usr_buyer_1',
      submittedByName: 'Rahul Deshmukh',
      isBuyerOffer: true,
      offerAmount: 7800000,
      termsAndConditions: 'Subject to clean 30-year title chain and bank loan sanction.',
      status: OfferLifecycleStatus.countered,
      createdAt: now.subtract(const Duration(days: 2)),
    );

    final offerEvent2 = NegotiationOfferEvent(
      id: 'off_event_2',
      enquiryId: 'enq_101',
      submittedByUserId: 'usr_seller_101',
      submittedByName: 'Anand Patil (Owner)',
      isBuyerOffer: false,
      offerAmount: 8200000,
      termsAndConditions: 'Includes all modular fittings and covered car parking.',
      status: OfferLifecycleStatus.submitted,
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final enq1 = PropertyEnquiryEntity(
      id: 'enq_101',
      propertyId: 'prop_1',
      propertyTitle: '3 BHK Luxury Villa in Tilakwadi',
      propertyCategory: 'Residential Housing',
      propertyLocation: 'Tilakwadi, Belagavi',
      buyerId: 'usr_buyer_1',
      buyerName: 'Rahul Deshmukh',
      buyerPhone: '+91 98450 12345',
      buyerEmail: 'rahul.deshmukh@example.com',
      sellerId: 'usr_seller_101',
      interestType: TransactionInterestType.buy,
      initialMessage: 'Hi, I am interested in this 3BHK villa. Can we schedule an on-site visit this Saturday?',
      preferredContactMethod: 'Phone Call',
      preferredVisitDate: '2026-08-22',
      preferredVisitTime: 'Morning (10:00 AM - 1:00 PM)',
      financingStatus: 'Pre-Approved Loan',
      listedPrice: 8500000,
      buyerOfferPrice: 7800000,
      sellerCounterOfferPrice: 8200000,
      currentNegotiatedAmount: 8200000,
      offerStatus: OfferLifecycleStatus.countered,
      negotiationHistory: [offerEvent1, offerEvent2],
      status: TransactionStatus.negotiation,
      siteVisitStatus: SiteVisitStatus.confirmed,
      scheduledVisitDateTime: now.add(const Duration(days: 2)),
      siteVisitNotes: 'Confirmed for Saturday 11:30 AM with site caretaker.',
      docVerificationStatus: DocVerificationStatus.underReview,
      docVerificationNotes: 'Sale Deed and EC Form 15 shared with buyer advocate.',
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    // ─── 2. Commercial Showroom (For Lease/Rent) ─────────────────────────────
    final rentEvent1 = NegotiationOfferEvent(
      id: 'off_event_3',
      enquiryId: 'enq_102',
      submittedByUserId: 'usr_buyer_2',
      submittedByName: 'Priya Kulkarni',
      isBuyerOffer: true,
      offerAmount: 40000,
      monthlyRent: 40000,
      depositAmount: 200000,
      leaseDurationMonths: 36,
      maintenanceCharges: 3000,
      termsAndConditions: 'Seeking 3-year commercial lease with 5% annual escalation.',
      status: OfferLifecycleStatus.submitted,
      createdAt: now.subtract(const Duration(hours: 6)),
    );

    final enq2 = PropertyEnquiryEntity(
      id: 'enq_102',
      propertyId: 'prop_2',
      propertyTitle: 'Prime Commercial Showroom on Khanapur Road',
      propertyCategory: 'Commercial',
      propertyLocation: 'Khanapur Road, Belagavi',
      buyerId: 'usr_buyer_2',
      buyerName: 'Priya Kulkarni',
      buyerPhone: '+91 94812 67890',
      buyerEmail: 'priya.kulkarni@retail.com',
      sellerId: 'usr_seller_101',
      interestType: TransactionInterestType.lease,
      initialMessage: 'Looking to set up a boutique electronics retail store.',
      preferredContactMethod: 'WhatsApp',
      financingStatus: 'Self-Funded',
      listedPrice: 45000,
      monthlyRent: 40000,
      depositAmount: 200000,
      leaseDurationMonths: 36,
      maintenanceCharges: 3000,
      buyerOfferPrice: 40000,
      currentNegotiatedAmount: 40000,
      offerStatus: OfferLifecycleStatus.submitted,
      negotiationHistory: [rentEvent1],
      status: TransactionStatus.siteVisit,
      siteVisitStatus: SiteVisitStatus.requested,
      preferredVisitDate: '2026-08-23',
      preferredVisitTime: 'Afternoon (2:00 PM - 5:00 PM)',
      docVerificationStatus: DocVerificationStatus.notStarted,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 6)),
    );

    // ─── 3. Residential Plot (For Sale) ─────────────────────────────────────
    final enq3 = PropertyEnquiryEntity(
      id: 'enq_103',
      propertyId: 'prop_3',
      propertyTitle: 'BUDA Approved Residential Plot in Bhagya Nagar',
      propertyCategory: 'Plot / Land',
      propertyLocation: 'Bhagya Nagar, Belagavi',
      buyerId: 'usr_buyer_1',
      buyerName: 'Rahul Deshmukh',
      buyerPhone: '+91 98450 12345',
      sellerId: 'usr_seller_102',
      interestType: TransactionInterestType.buy,
      initialMessage: 'Please confirm if layout demarcation pillars are in place.',
      preferredContactMethod: 'Phone Call',
      preferredVisitDate: '2026-08-24',
      preferredVisitTime: 'Morning (10:00 AM - 1:00 PM)',
      financingStatus: 'Self-Funded',
      listedPrice: 4200000,
      status: TransactionStatus.newEnquiry,
      siteVisitStatus: SiteVisitStatus.requested,
      docVerificationStatus: DocVerificationStatus.notStarted,
      createdAt: now.subtract(const Duration(hours: 18)),
      updatedAt: now.subtract(const Duration(hours: 18)),
    );

    // ─── 4. Raw Land (For Sale) ─────────────────────────────────────────────
    final enq4 = PropertyEnquiryEntity(
      id: 'enq_104',
      propertyId: 'prop_4',
      propertyTitle: '2.5 Acre Agricultural Raw Land near Sambra Airport',
      propertyCategory: 'Raw Land / Agri',
      propertyLocation: 'Sambra, Belagavi',
      buyerId: 'usr_buyer_3',
      buyerName: 'Vijay Hiremath',
      buyerPhone: '+91 97400 33445',
      sellerId: 'usr_seller_103',
      interestType: TransactionInterestType.buy,
      initialMessage: 'Interested in agricultural development. Please share latest RTC Pahani.',
      preferredContactMethod: 'WhatsApp',
      financingStatus: 'Self-Funded',
      listedPrice: 6500000,
      status: TransactionStatus.newEnquiry,
      siteVisitStatus: SiteVisitStatus.none,
      docVerificationStatus: DocVerificationStatus.notStarted,
      createdAt: now.subtract(const Duration(hours: 8)),
      updatedAt: now.subtract(const Duration(hours: 8)),
    );

    _enquiries[enq1.id] = enq1;
    _enquiries[enq2.id] = enq2;
    _enquiries[enq3.id] = enq3;
    _enquiries[enq4.id] = enq4;
  }

  @override
  Future<String> submitEnquiry(PropertyEnquiryEntity enquiry) async {
    _enquiries[enquiry.id] = enquiry;
    return enquiry.id;
  }

  @override
  Future<List<PropertyEnquiryEntity>> getBuyerEnquiries(String buyerId) async {
    return _enquiries.values.where((e) => e.buyerId == buyerId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<List<PropertyEnquiryEntity>> getSellerEnquiries(String sellerId) async {
    return _enquiries.values
        .where((e) => e.sellerId == sellerId || (sellerId == 'owner_1' && e.sellerId == 'usr_seller_101'))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<PropertyEnquiryEntity?> getEnquiryById(String enquiryId) async {
    return _enquiries[enquiryId];
  }

  @override
  Future<void> updateEnquiryStatus(String enquiryId, TransactionStatus status) async {
    final existing = _enquiries[enquiryId];
    if (existing != null) {
      _enquiries[enquiryId] = existing.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> requestSiteVisit({
    required String enquiryId,
    required String preferredDate,
    required String preferredTime,
    String? message,
  }) async {
    final existing = _enquiries[enquiryId];
    if (existing != null) {
      _enquiries[enquiryId] = existing.copyWith(
        preferredVisitDate: preferredDate,
        preferredVisitTime: preferredTime,
        siteVisitStatus: SiteVisitStatus.requested,
        status: TransactionStatus.siteVisit,
        siteVisitNotes: message ?? existing.siteVisitNotes,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> respondToSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
    String? respondingUserId,
  }) async {
    final existing = _enquiries[enquiryId];
    if (existing != null) {
      if (respondingUserId != null &&
          respondingUserId != existing.sellerId &&
          respondingUserId != 'owner_1' &&
          respondingUserId != 'usr_seller_101' &&
          respondingUserId != 'admin' &&
          respondingUserId != 'founder') {
        throw const AccessDeniedException('Access Denied: Only the property seller or admin can respond to site visits.');
      }

      _enquiries[enquiryId] = existing.copyWith(
        siteVisitStatus: status,
        scheduledVisitDateTime: scheduledDateTime ?? existing.scheduledVisitDateTime,
        siteVisitNotes: notes ?? existing.siteVisitNotes,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> submitOfferEvent(NegotiationOfferEvent offerEvent) async {
    final existing = _enquiries[offerEvent.enquiryId];
    if (existing != null) {
      final updatedHistory = List<NegotiationOfferEvent>.from(existing.negotiationHistory)..add(offerEvent);

      final isBuyer = offerEvent.isBuyerOffer;

      _enquiries[offerEvent.enquiryId] = existing.copyWith(
        buyerOfferPrice: isBuyer ? offerEvent.offerAmount : existing.buyerOfferPrice,
        sellerCounterOfferPrice: !isBuyer ? offerEvent.offerAmount : existing.sellerCounterOfferPrice,
        currentNegotiatedAmount: offerEvent.offerAmount,
        monthlyRent: offerEvent.monthlyRent ?? existing.monthlyRent,
        depositAmount: offerEvent.depositAmount ?? existing.depositAmount,
        leaseDurationMonths: offerEvent.leaseDurationMonths ?? existing.leaseDurationMonths,
        maintenanceCharges: offerEvent.maintenanceCharges ?? existing.maintenanceCharges,
        offerStatus: isBuyer ? OfferLifecycleStatus.submitted : OfferLifecycleStatus.countered,
        negotiationHistory: updatedHistory,
        status: TransactionStatus.negotiation,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateOfferStatus({
    required String enquiryId,
    required OfferLifecycleStatus status,
    String? notes,
  }) async {
    final existing = _enquiries[enquiryId];
    if (existing != null) {
      _enquiries[enquiryId] = existing.copyWith(
        offerStatus: status,
        status: status == OfferLifecycleStatus.accepted ? TransactionStatus.documents : existing.status,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateDocVerification({
    required String enquiryId,
    required DocVerificationStatus status,
    String? notes,
  }) async {
    final existing = _enquiries[enquiryId];
    if (existing != null) {
      _enquiries[enquiryId] = existing.copyWith(
        docVerificationStatus: status,
        docVerificationNotes: notes ?? existing.docVerificationNotes,
        status: status == DocVerificationStatus.verificationComplete ? TransactionStatus.closed : TransactionStatus.documents,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
  }) async {
    final existing = _enquiries[enquiryId];
    if (existing != null) {
      _enquiries[enquiryId] = existing.copyWith(
        siteVisitStatus: status,
        scheduledVisitDateTime: scheduledDateTime ?? existing.scheduledVisitDateTime,
        siteVisitNotes: notes ?? existing.siteVisitNotes,
        status: status == SiteVisitStatus.completed
            ? TransactionStatus.negotiation
            : (status == SiteVisitStatus.scheduled || status == SiteVisitStatus.confirmed
                ? TransactionStatus.siteVisitScheduled
                : existing.status),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> submitNegotiationOffer({
    required String enquiryId,
    double? buyerOffer,
    double? sellerCounterOffer,
    double? agreedAmount,
  }) async {
    final existing = _enquiries[enquiryId];
    if (existing != null) {
      final isBuyer = buyerOffer != null;
      final offerAmount = agreedAmount ?? (isBuyer ? buyerOffer : (sellerCounterOffer ?? existing.listedPrice));

      final event = NegotiationOfferEvent(
        id: 'off_${DateTime.now().millisecondsSinceEpoch}',
        enquiryId: enquiryId,
        submittedByUserId: isBuyer ? existing.buyerId : existing.sellerId,
        submittedByName: isBuyer ? existing.buyerName : 'Seller/Agent',
        isBuyerOffer: isBuyer,
        offerAmount: offerAmount,
        status: agreedAmount != null ? OfferLifecycleStatus.accepted : (isBuyer ? OfferLifecycleStatus.submitted : OfferLifecycleStatus.countered),
        createdAt: DateTime.now(),
      );

      final updatedHistory = List<NegotiationOfferEvent>.from(existing.negotiationHistory)..add(event);

      _enquiries[enquiryId] = existing.copyWith(
        buyerOfferPrice: isBuyer ? buyerOffer : existing.buyerOfferPrice,
        sellerCounterOfferPrice: sellerCounterOffer ?? existing.sellerCounterOfferPrice,
        currentNegotiatedAmount: agreedAmount ?? offerAmount,
        offerStatus: agreedAmount != null ? OfferLifecycleStatus.accepted : (isBuyer ? OfferLifecycleStatus.submitted : OfferLifecycleStatus.countered),
        negotiationHistory: updatedHistory,
        status: agreedAmount != null ? TransactionStatus.documentVerification : TransactionStatus.negotiation,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<bool> hasActiveInquiry({required String propertyId, required String buyerId}) async {
    return _enquiries.values.any((e) =>
        e.propertyId == propertyId &&
        e.buyerId == buyerId &&
        e.status != TransactionStatus.closed &&
        e.status != TransactionStatus.rejected);
  }

  @override
  Future<List<PropertyEnquiryEntity>> getAllEnquiries() async {
    return _enquiries.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
