import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:belagavi_property/features/transaction/domain/entities/transaction_entities.dart';

void main() {
  late TransactionRepositoryImpl transactionRepository;

  setUp(() {
    transactionRepository = TransactionRepositoryImpl();
  });

  PropertyEntity createTestProperty({
    required String id,
    required String ownerId,
    required String title,
    ListingStatus status = ListingStatus.published,
    double price = 6500000,
  }) {
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: 'Test Property Description',
      category: PropertyCategory.residential,
      type: PropertySubtype.apartment,
      status: status,
      verificationStatus: VerificationStatus.verified,
      price: price,
      isNegotiable: true,
      specifications: const PropertySpecificationsEntity(carpetArea: 1200),
      mediaList: const [],
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      address: 'Congress Road, Tilakwadi',
      pincode: '590006',
      latitude: 15.8497,
      longitude: 74.4977,
      viewsCount: 50,
      features: const {'purpose': 'FOR_SALE', 'listingType': 'FOR_SALE'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('PROPERTY DETAILS → INQUIRY → SITE VISIT → OWNER WORKFLOW TESTS', () {
    const sellerAId = 'usr_seller_A_555';
    const sellerBId = 'usr_seller_B_777';
    const buyerId = 'usr_buyer_real_123';

    test('1. Customer creates Real Inquiry (I\'m Interested) linked to authenticated buyer session', () async {
      final prop = createTestProperty(id: 'prop_real_1', ownerId: sellerAId, title: 'Tilakwadi 2BHK');

      final enquiry = PropertyEnquiryEntity(
        id: 'enq_test_1',
        propertyId: prop.id,
        propertyTitle: prop.title,
        propertyCategory: prop.category.name,
        propertyLocation: '${prop.locality}, ${prop.city}',
        buyerId: buyerId,
        buyerName: 'Sneha Patil',
        buyerPhone: '+91 98450 11223',
        buyerEmail: 'sneha.patil@example.com',
        sellerId: prop.ownerId,
        interestType: TransactionInterestType.buy,
        initialMessage: 'I am interested in viewing this property.',
        preferredContactMethod: 'Phone Call',
        financingStatus: 'Pre-Approved Loan',
        listedPrice: prop.price,
        status: TransactionStatus.newEnquiry,
        siteVisitStatus: SiteVisitStatus.none,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final insertedId = await transactionRepository.submitEnquiry(enquiry);
      expect(insertedId, 'enq_test_1');

      // Verify buyer can view this enquiry
      final buyerEnquiries = await transactionRepository.getBuyerEnquiries(buyerId);
      expect(buyerEnquiries.any((e) => e.id == 'enq_test_1'), isTrue);
      expect(buyerEnquiries.firstWhere((e) => e.id == 'enq_test_1').buyerId, buyerId);
    });

    test('2. Customer creates Site Visit request with specific date/time slot', () async {
      final prop = createTestProperty(id: 'prop_real_2', ownerId: sellerAId, title: 'Camp Commercial Office');

      final visitEnquiry = PropertyEnquiryEntity(
        id: 'enq_visit_1',
        propertyId: prop.id,
        propertyTitle: prop.title,
        propertyCategory: prop.category.name,
        propertyLocation: '${prop.locality}, ${prop.city}',
        buyerId: buyerId,
        buyerName: 'Sneha Patil',
        buyerPhone: '+91 98450 11223',
        sellerId: prop.ownerId,
        interestType: TransactionInterestType.buy,
        initialMessage: 'Requesting on-site inspection.',
        preferredVisitDate: '2026-08-25',
        preferredVisitTime: 'Morning (10:00 AM - 1:00 PM)',
        listedPrice: prop.price,
        status: TransactionStatus.siteVisit,
        siteVisitStatus: SiteVisitStatus.requested,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await transactionRepository.submitEnquiry(visitEnquiry);

      // Verify seller receives site visit request
      final sellerLeads = await transactionRepository.getSellerEnquiries(sellerAId);
      expect(sellerLeads.any((e) => e.id == 'enq_visit_1'), isTrue);
      final lead = sellerLeads.firstWhere((e) => e.id == 'enq_visit_1');
      expect(lead.siteVisitStatus, SiteVisitStatus.requested);
      expect(lead.preferredVisitDate, '2026-08-25');
      expect(lead.preferredVisitTime, 'Morning (10:00 AM - 1:00 PM)');
    });

    test('3. Duplicate Inquiry Protection detects and blocks duplicate active inquiries', () async {
      final prop = createTestProperty(id: 'prop_real_3', ownerId: sellerAId, title: 'Khasbag Plot');

      // First inquiry
      final enquiry1 = PropertyEnquiryEntity(
        id: 'enq_dup_1',
        propertyId: prop.id,
        propertyTitle: prop.title,
        propertyCategory: prop.category.name,
        propertyLocation: 'Belagavi',
        buyerId: buyerId,
        buyerName: 'Sneha Patil',
        buyerPhone: '+91 98450 11223',
        sellerId: prop.ownerId,
        interestType: TransactionInterestType.buy,
        initialMessage: 'First enquiry',
        listedPrice: prop.price,
        status: TransactionStatus.newEnquiry,
        siteVisitStatus: SiteVisitStatus.none,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await transactionRepository.submitEnquiry(enquiry1);

      // Check duplicate status
      final hasActive = await transactionRepository.hasActiveInquiry(
        propertyId: prop.id,
        buyerId: buyerId,
      );
      expect(hasActive, isTrue);

      // Another property should return false
      final hasActiveOther = await transactionRepository.hasActiveInquiry(
        propertyId: 'prop_different_999',
        buyerId: buyerId,
      );
      expect(hasActiveOther, isFalse);
    });

    test('4. Seller responds to Site Visit -> Confirms slot and updates status', () async {
      final scheduledDate = DateTime.now().add(const Duration(days: 3));
      await transactionRepository.respondToSiteVisit(
        enquiryId: 'enq_101',
        status: SiteVisitStatus.confirmed,
        scheduledDateTime: scheduledDate,
        notes: 'Confirmed for Saturday 11:30 AM with keyholder.',
      );

      final updated = await transactionRepository.getEnquiryById('enq_101');
      expect(updated?.siteVisitStatus, SiteVisitStatus.confirmed);
      expect(updated?.scheduledVisitDateTime, scheduledDate);
      expect(updated?.siteVisitNotes, 'Confirmed for Saturday 11:30 AM with keyholder.');
    });

    test('5. Multi-Party RBAC Isolation: Seller A cannot see Seller B inbound inquiries', () async {
      final enqSellerB = PropertyEnquiryEntity(
        id: 'enq_seller_B_only',
        propertyId: 'prop_B_1',
        propertyTitle: 'Seller B Penthouse',
        propertyCategory: 'residential',
        propertyLocation: 'Belagavi',
        buyerId: 'usr_other_buyer',
        buyerName: 'Amit Shah',
        buyerPhone: '+91 99999 88888',
        sellerId: sellerBId,
        interestType: TransactionInterestType.buy,
        initialMessage: 'Private inquiry for Seller B',
        listedPrice: 12000000,
        status: TransactionStatus.newEnquiry,
        siteVisitStatus: SiteVisitStatus.none,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await transactionRepository.submitEnquiry(enqSellerB);

      // Seller A must NOT see Seller B lead
      final sellerALeads = await transactionRepository.getSellerEnquiries(sellerAId);
      expect(sellerALeads.any((e) => e.id == 'enq_seller_B_only'), isFalse);

      // Seller B MUST see Seller B lead
      final sellerBLeads = await transactionRepository.getSellerEnquiries(sellerBId);
      expect(sellerBLeads.any((e) => e.id == 'enq_seller_B_only'), isTrue);
    });

    test('6. Admin / Founder has global inquiry oversight across all sellers and buyers', () async {
      final allEnquiries = await transactionRepository.getAllEnquiries();
      expect(allEnquiries.isNotEmpty, isTrue);

      // Admin updates status globally
      await transactionRepository.updateEnquiryStatus('enq_102', TransactionStatus.inDiscussion);
      final updated = await transactionRepository.getEnquiryById('enq_102');
      expect(updated?.status, TransactionStatus.inDiscussion);
    });
  });
}
