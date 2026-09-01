import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/transaction/domain/entities/transaction_entities.dart';
import 'package:belagavi_property/features/transaction/data/repositories/transaction_repository_impl.dart';

void main() {
  late TransactionRepositoryImpl repository;

  setUp(() {
    repository = TransactionRepositoryImpl();
  });

  group('Phase 9: Property Enquiry + Site Visit + Offer / Negotiation Flow Tests', () {
    test('1. Buyer Enquiry Submission with Listing-Aware Purpose across 4 Categories', () async {
      // 1.1 Housing (For Sale)
      final saleEnquiry = PropertyEnquiryEntity(
        id: 'test_enq_sale',
        propertyId: 'prop_villa_101',
        propertyTitle: 'Luxury 4BHK Villa in Tilakwadi',
        propertyCategory: 'Residential Housing',
        propertyLocation: 'Tilakwadi, Belagavi',
        buyerId: 'usr_buyer_alpha',
        buyerName: 'Rahul Deshmukh',
        buyerPhone: '+91 98450 12345',
        sellerId: 'usr_seller_patil',
        interestType: TransactionInterestType.buy,
        initialMessage: 'Interested in purchasing this villa. Requesting a site visit.',
        listedPrice: 9500000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final idSale = await repository.submitEnquiry(saleEnquiry);
      expect(idSale, 'test_enq_sale');

      // 1.2 Commercial (For Rent / Lease)
      final leaseEnquiry = PropertyEnquiryEntity(
        id: 'test_enq_lease',
        propertyId: 'prop_comm_202',
        propertyTitle: 'Commercial Retail Shop on Khanapur Road',
        propertyCategory: 'Commercial',
        propertyLocation: 'Khanapur Road, Belagavi',
        buyerId: 'usr_buyer_alpha',
        buyerName: 'Rahul Deshmukh',
        buyerPhone: '+91 98450 12345',
        sellerId: 'usr_seller_patil',
        interestType: TransactionInterestType.lease,
        initialMessage: 'Looking for 3-year retail lease.',
        listedPrice: 50000,
        monthlyRent: 45000,
        depositAmount: 250000,
        leaseDurationMonths: 36,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final idLease = await repository.submitEnquiry(leaseEnquiry);
      expect(idLease, 'test_enq_lease');

      // 1.3 Plot / Land (For Sale)
      final plotEnquiry = PropertyEnquiryEntity(
        id: 'test_enq_plot',
        propertyId: 'prop_plot_303',
        propertyTitle: 'BUDA Approved Plot in Bhagya Nagar',
        propertyCategory: 'Plot / Land',
        propertyLocation: 'Bhagya Nagar, Belagavi',
        buyerId: 'usr_buyer_alpha',
        buyerName: 'Rahul Deshmukh',
        buyerPhone: '+91 98450 12345',
        sellerId: 'usr_seller_patil',
        interestType: TransactionInterestType.buy,
        initialMessage: 'Interested in plot purchase.',
        listedPrice: 3800000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.submitEnquiry(plotEnquiry);

      // 1.4 Raw Land (For Sale)
      final rawLandEnquiry = PropertyEnquiryEntity(
        id: 'test_enq_rawland',
        propertyId: 'prop_raw_404',
        propertyTitle: '3 Acre Agricultural Land in Sambra',
        propertyCategory: 'Raw Land / Agri',
        propertyLocation: 'Sambra, Belagavi',
        buyerId: 'usr_buyer_alpha',
        buyerName: 'Rahul Deshmukh',
        buyerPhone: '+91 98450 12345',
        sellerId: 'usr_seller_patil',
        interestType: TransactionInterestType.buy,
        initialMessage: 'Interested in agricultural development.',
        listedPrice: 7000000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.submitEnquiry(rawLandEnquiry);

      final sellerList = await repository.getSellerEnquiries('usr_seller_patil');
      expect(sellerList.length, 4);
    });

    test('2. Site Visit Request, Confirmation, Reschedule & Completion Workflow', () async {
      const enquiryId = 'enq_103';

      // Buyer requests site visit
      await repository.requestSiteVisit(
        enquiryId: enquiryId,
        preferredDate: '2026-08-25',
        preferredTime: 'Morning (10 AM - 1 PM)',
        message: 'Requesting morning slot for boundary pillar inspection.',
      );

      var enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.siteVisitStatus, SiteVisitStatus.requested);
      expect(enq.status, TransactionStatus.siteVisit);

      // Seller confirms site visit
      final visitDate = DateTime.now().add(const Duration(days: 2));
      await repository.respondToSiteVisit(
        enquiryId: enquiryId,
        status: SiteVisitStatus.confirmed,
        scheduledDateTime: visitDate,
        notes: 'Confirmed with site caretaker.',
      );

      enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.siteVisitStatus, SiteVisitStatus.confirmed);
      expect(enq.scheduledVisitDateTime, isNotNull);

      // Reschedule visit
      await repository.respondToSiteVisit(
        enquiryId: enquiryId,
        status: SiteVisitStatus.rescheduleRequested,
        notes: 'Requested Sunday 3:00 PM instead.',
      );
      enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.siteVisitStatus, SiteVisitStatus.rescheduleRequested);

      // Complete visit
      await repository.respondToSiteVisit(
        enquiryId: enquiryId,
        status: SiteVisitStatus.completed,
        notes: 'Site visit completed successfully.',
      );
      enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.siteVisitStatus, SiteVisitStatus.completed);
    });

    test('3. Offer Submission, Counter Offer & Immutable Negotiation History', () async {
      const enquiryId = 'enq_101';

      // Round 1: Buyer submits offer
      final buyerOffer = NegotiationOfferEvent(
        id: 'off_r1',
        enquiryId: enquiryId,
        submittedByUserId: 'usr_buyer_1',
        submittedByName: 'Rahul Deshmukh',
        isBuyerOffer: true,
        offerAmount: 7900000,
        termsAndConditions: 'Subject to bank loan sanction and clear EC.',
        status: OfferLifecycleStatus.submitted,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      );
      await repository.submitOfferEvent(buyerOffer);

      var enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.buyerOfferPrice, 7900000);
      expect(enq.currentNegotiatedAmount, 7900000);
      expect(enq.offerStatus, OfferLifecycleStatus.submitted);
      expect(enq.negotiationHistory.length, 3); // 2 seeded + 1 new

      // Round 2: Seller counters offer
      final sellerCounter = NegotiationOfferEvent(
        id: 'off_r2',
        enquiryId: enquiryId,
        submittedByUserId: 'usr_seller_101',
        submittedByName: 'Anand Patil (Owner)',
        isBuyerOffer: false,
        offerAmount: 8100000,
        termsAndConditions: 'Includes all woodwork and kitchen cabinets.',
        status: OfferLifecycleStatus.countered,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      await repository.submitOfferEvent(sellerCounter);

      enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.sellerCounterOfferPrice, 8100000);
      expect(enq.currentNegotiatedAmount, 8100000);
      expect(enq.offerStatus, OfferLifecycleStatus.countered);
      expect(enq.negotiationHistory.length, 4);

      // Verify immutable history integrity
      expect(enq.negotiationHistory.first.offerAmount, 7800000);
      expect(enq.negotiationHistory.last.offerAmount, 8100000);

      // Round 3: Offer Accepted
      await repository.updateOfferStatus(
        enquiryId: enquiryId,
        status: OfferLifecycleStatus.accepted,
        notes: 'Agreed at ₹81,00,000. Proceeding to legal due diligence.',
      );

      enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.offerStatus, OfferLifecycleStatus.accepted);
      expect(enq.status, TransactionStatus.documents);
    });

    test('4. Multi-Party Security & RLS Isolation', () async {
      final buyer1Enquiries = await repository.getBuyerEnquiries('usr_buyer_1');
      final buyer2Enquiries = await repository.getBuyerEnquiries('usr_buyer_2');

      // Buyer 1 cannot see Buyer 2's enquiries
      expect(buyer1Enquiries.any((e) => e.buyerId == 'usr_buyer_2'), isFalse);
      expect(buyer2Enquiries.any((e) => e.buyerId == 'usr_buyer_1'), isFalse);

      // Seller isolation
      final seller101Enquiries = await repository.getSellerEnquiries('usr_seller_101');
      final seller102Enquiries = await repository.getSellerEnquiries('usr_seller_102');

      expect(seller101Enquiries.any((e) => e.sellerId == 'usr_seller_102'), isFalse);
      expect(seller102Enquiries.any((e) => e.sellerId == 'usr_seller_101'), isFalse);

      // canUserAccess verification
      final enq = await repository.getEnquiryById('enq_101');
      expect(enq!.canUserAccess('usr_buyer_1'), isTrue);
      expect(enq.canUserAccess('usr_seller_101'), isTrue);
      expect(enq.canUserAccess('usr_random_intruder'), isFalse);
    });

    test('5. Proceeding to Due Diligence & Deal Completion', () async {
      const enquiryId = 'enq_101';

      await repository.updateDocVerification(
        enquiryId: enquiryId,
        status: DocVerificationStatus.documentsRequested,
        notes: 'Requested 30-year title chain and tax paid receipts.',
      );

      var enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.docVerificationStatus, DocVerificationStatus.documentsRequested);
      expect(enq.status, TransactionStatus.documents);

      await repository.updateDocVerification(
        enquiryId: enquiryId,
        status: DocVerificationStatus.verificationComplete,
        notes: 'Advocate search report clear. Ready for registration.',
      );

      enq = await repository.getEnquiryById(enquiryId);
      expect(enq!.docVerificationStatus, DocVerificationStatus.verificationComplete);
      expect(enq.status, TransactionStatus.closed);
    });
  });
}
