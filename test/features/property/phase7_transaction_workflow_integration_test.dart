import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/transaction/domain/entities/transaction_entities.dart';
import 'package:belagavi_property/features/transaction/data/repositories/transaction_repository_impl.dart';

void main() {
  late TransactionRepositoryImpl repository;

  setUp(() {
    repository = TransactionRepositoryImpl();
  });

  group('Phase 7: Property Buyer / Seller Transaction Workflow Tests', () {
    test('1. Buyer Enquiry Submission with Listing-Aware Purpose', () async {
      final enquiry = PropertyEnquiryEntity(
        id: 'test_enq_1',
        propertyId: 'prop_villa_1',
        propertyTitle: '4 BHK Luxury Villa Tilakwadi',
        propertyCategory: 'Residential',
        propertyLocation: 'Tilakwadi, Belagavi',
        buyerId: 'usr_buyer_99',
        buyerName: 'Amit Patil',
        buyerPhone: '+91 98800 11223',
        buyerEmail: 'amit.patil@example.com',
        sellerId: 'owner_99',
        interestType: TransactionInterestType.buy,
        initialMessage: 'Interested in buying. Ready for weekend site inspection.',
        preferredContactMethod: 'WhatsApp',
        preferredVisitDate: 'Next Saturday',
        preferredVisitTime: 'Morning (10 AM - 1 PM)',
        financingStatus: 'Pre-Approved Loan',
        listedPrice: 12000000.0,
        buyerOfferPrice: 11500000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repository.submitEnquiry(enquiry);
      expect(id, 'test_enq_1');

      final retrieved = await repository.getEnquiryById('test_enq_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.propertyTitle, '4 BHK Luxury Villa Tilakwadi');
      expect(retrieved.interestType, TransactionInterestType.buy);
      expect(retrieved.buyerOfferPrice, 11500000.0);
      expect(retrieved.status, TransactionStatus.newEnquiry);
    });

    test('2. Seller Inbound Lead Discovery & Status Progression', () async {
      final sellerLeads = await repository.getSellerEnquiries('owner_1');
      expect(sellerLeads.isNotEmpty, isTrue);

      final lead = sellerLeads.first;
      await repository.updateEnquiryStatus(lead.id, TransactionStatus.contacted);

      final updated = await repository.getEnquiryById(lead.id);
      expect(updated!.status, TransactionStatus.contacted);
    });

    test('3. Site Visit Scheduling & Completion Workflow', () async {
      final scheduledDate = DateTime.now().add(const Duration(days: 2));

      await repository.updateSiteVisit(
        enquiryId: 'enq_101',
        status: SiteVisitStatus.scheduled,
        scheduledDateTime: scheduledDate,
        notes: 'Confirmed site inspection with buyer.',
      );

      var enquiry = await repository.getEnquiryById('enq_101');
      expect(enquiry!.siteVisitStatus, SiteVisitStatus.scheduled);
      expect(enquiry.status, TransactionStatus.siteVisitScheduled);

      // Complete visit
      await repository.updateSiteVisit(
        enquiryId: 'enq_101',
        status: SiteVisitStatus.completed,
        notes: 'Site visit completed. Proceeding to price discussion.',
      );

      enquiry = await repository.getEnquiryById('enq_101');
      expect(enquiry!.siteVisitStatus, SiteVisitStatus.completed);
      expect(enquiry.status, TransactionStatus.negotiation);
    });

    test('4. Price & Terms Negotiation Tracking', () async {
      // Buyer proposes initial offer
      await repository.submitNegotiationOffer(
        enquiryId: 'enq_102',
        buyerOffer: 68000.0,
      );

      var enquiry = await repository.getEnquiryById('enq_102');
      expect(enquiry!.buyerOfferPrice, 68000.0);
      expect(enquiry.status, TransactionStatus.negotiation);

      // Seller counter offer
      await repository.submitNegotiationOffer(
        enquiryId: 'enq_102',
        sellerCounterOffer: 72000.0,
      );

      enquiry = await repository.getEnquiryById('enq_102');
      expect(enquiry!.sellerCounterOfferPrice, 72000.0);

      // Agreed Deal Amount
      await repository.submitNegotiationOffer(
        enquiryId: 'enq_102',
        agreedAmount: 70000.0,
      );

      enquiry = await repository.getEnquiryById('enq_102');
      expect(enquiry!.currentNegotiatedAmount, 70000.0);
      expect(enquiry.status, TransactionStatus.documentVerification);
    });

    test('5. Document Verification & Deal Completion', () async {
      await repository.updateDocVerification(
        enquiryId: 'enq_103',
        status: DocVerificationStatus.documentsSubmitted,
        notes: 'Parent title deed and RTC uploaded.',
      );

      var enquiry = await repository.getEnquiryById('enq_103');
      expect(enquiry!.docVerificationStatus, DocVerificationStatus.documentsSubmitted);

      // Mark complete
      await repository.updateDocVerification(
        enquiryId: 'enq_103',
        status: DocVerificationStatus.verificationComplete,
        notes: 'Title search verified by advocate.',
      );

      enquiry = await repository.getEnquiryById('enq_103');
      expect(enquiry!.docVerificationStatus, DocVerificationStatus.verificationComplete);
      expect(enquiry.status, TransactionStatus.closed);
    });

    test('6. Rent and Commercial Lease Purpose Support', () {
      expect(TransactionInterestType.rent.displayName, 'Rental');
      expect(TransactionInterestType.lease.displayName, 'Commercial Lease');
      expect(TransactionInterestType.buy.displayName, 'Purchase / Buy');
    });
  });
}
