import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:belagavi_property/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:belagavi_property/features/transaction/domain/entities/transaction_entities.dart';

void main() {
  late NotificationRepositoryImpl notificationRepository;
  late TransactionRepositoryImpl transactionRepository;

  setUp(() {
    notificationRepository = NotificationRepositoryImpl();
    transactionRepository = TransactionRepositoryImpl();
  });

  group('NOTIFICATION + INQUIRY + SITE VISIT SECURITY & INTEGRITY ATTACK TESTS', () {
    const customerA = 'usr_customer_A_111';
    const customerB = 'usr_customer_B_222';
    const sellerA = 'usr_seller_A_333';
    const sellerB = 'usr_seller_B_444';

    test('TEST 1: Customer A attempts notification with empty recipient_id -> DENIED', () async {
      final invalidNotif = NotificationEntity(
        id: 'notif_invalid_1',
        recipientId: '   ',
        type: NotificationType.newPropertyInquiry,
        title: 'Fake Notification',
        body: 'Malicious payload',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        () => notificationRepository.sendNotification(invalidNotif),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 2: Customer A cannot read Customer B notifications', () async {
      final notifB = NotificationEntity(
        id: 'notif_b_private',
        recipientId: customerB,
        type: NotificationType.system,
        title: 'Customer B Private OTP',
        body: 'Confidential message',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notificationRepository.sendNotification(notifB);

      final customerANotifications = await notificationRepository.getNotifications(recipientId: customerA);
      expect(customerANotifications.any((n) => n.id == 'notif_b_private'), isFalse);
    });

    test('TEST 3: Seller A cannot read Seller B inbound inquiries', () async {
      final sellerBInquiry = PropertyEnquiryEntity(
        id: 'enq_seller_b_secret',
        propertyId: 'prop_seller_b_1',
        propertyTitle: 'Seller B Private Villa',
        propertyCategory: 'residential',
        propertyLocation: 'Belagavi',
        buyerId: customerA,
        buyerName: 'Customer A',
        buyerPhone: '+91 98888 77777',
        sellerId: sellerB,
        interestType: TransactionInterestType.buy,
        initialMessage: 'Private inquiry for Seller B',
        listedPrice: 15000000,
        status: TransactionStatus.newEnquiry,
        siteVisitStatus: SiteVisitStatus.none,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await transactionRepository.submitEnquiry(sellerBInquiry);

      final sellerALeads = await transactionRepository.getSellerEnquiries(sellerA);
      expect(sellerALeads.any((e) => e.id == 'enq_seller_b_secret'), isFalse);
    });

    test('TEST 4: Seller A attempts site visit confirmation on Seller B listing -> DENIED', () async {
      final inquirySellerB = PropertyEnquiryEntity(
        id: 'enq_visit_seller_b',
        propertyId: 'prop_b_estate',
        propertyTitle: 'Seller B Commercial Complex',
        propertyCategory: 'commercial',
        propertyLocation: 'Belagavi',
        buyerId: customerA,
        buyerName: 'Customer A',
        buyerPhone: '+91 98888 77777',
        sellerId: sellerB,
        interestType: TransactionInterestType.buy,
        initialMessage: 'Requesting visit',
        listedPrice: 25000000,
        status: TransactionStatus.siteVisit,
        siteVisitStatus: SiteVisitStatus.requested,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await transactionRepository.submitEnquiry(inquirySellerB);

      // Seller A attempts to confirm Seller B's site visit
      expect(
        () => transactionRepository.respondToSiteVisit(
          enquiryId: 'enq_visit_seller_b',
          status: SiteVisitStatus.confirmed,
          respondingUserId: sellerA, // Malicious unauthorized caller
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 5: Seller B (Legitimate Owner) can confirm site visit successfully', () async {
      final inquirySellerB = PropertyEnquiryEntity(
        id: 'enq_visit_seller_b_legit',
        propertyId: 'prop_b_estate',
        propertyTitle: 'Seller B Commercial Complex',
        propertyCategory: 'commercial',
        propertyLocation: 'Belagavi',
        buyerId: customerA,
        buyerName: 'Customer A',
        buyerPhone: '+91 98888 77777',
        sellerId: sellerB,
        interestType: TransactionInterestType.buy,
        initialMessage: 'Requesting visit',
        listedPrice: 25000000,
        status: TransactionStatus.siteVisit,
        siteVisitStatus: SiteVisitStatus.requested,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await transactionRepository.submitEnquiry(inquirySellerB);

      await transactionRepository.respondToSiteVisit(
        enquiryId: 'enq_visit_seller_b_legit',
        status: SiteVisitStatus.confirmed,
        respondingUserId: sellerB, // Legitimate owner
      );

      final updated = await transactionRepository.getEnquiryById('enq_visit_seller_b_legit');
      expect(updated?.siteVisitStatus, SiteVisitStatus.confirmed);
    });

    test('TEST 6: Customer A attempts to mark Customer B notification as read -> DENIED', () async {
      final notifB = NotificationEntity(
        id: 'notif_b_unread',
        recipientId: customerB,
        type: NotificationType.system,
        title: 'Customer B Message',
        body: 'Important notification',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notificationRepository.sendNotification(notifB);

      // Customer A tries to mark it as read
      expect(
        () => notificationRepository.markAsRead('notif_b_unread', requesterUserId: customerA),
        throwsA(isA<AccessDeniedException>()),
      );

      // Verify it remains unread for Customer B
      expect(await notificationRepository.getUnreadCount(customerB), 1);
    });

    test('TEST 7: Customer A attempts to delete Customer B notification -> DENIED', () async {
      final notifB = NotificationEntity(
        id: 'notif_b_delete_target',
        recipientId: customerB,
        type: NotificationType.system,
        title: 'Customer B Record',
        body: 'Do not delete',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notificationRepository.sendNotification(notifB);

      // Customer A tries to delete it
      expect(
        () => notificationRepository.deleteNotification('notif_b_delete_target', requesterUserId: customerA),
        throwsA(isA<AccessDeniedException>()),
      );

      // Verify it still exists for Customer B
      final listB = await notificationRepository.getNotifications(recipientId: customerB);
      expect(listB.any((n) => n.id == 'notif_b_delete_target'), isTrue);
    });

    test('TEST 8: Customer A attempts to mark all Customer B notifications as read -> DENIED', () async {
      expect(
        () => notificationRepository.markAllAsRead(customerB, requesterUserId: customerA),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 9: Admin/Founder has legitimate oversight and management permissions', () async {
      final notif = NotificationEntity(
        id: 'notif_admin_managed',
        recipientId: customerB,
        type: NotificationType.system,
        title: 'System Notice',
        body: 'Notice',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notificationRepository.sendNotification(notif);

      // Admin marks as read on behalf of system
      await notificationRepository.markAsRead('notif_admin_managed', requesterUserId: 'admin');
      final listB = await notificationRepository.getNotifications(recipientId: customerB);
      expect(listB.firstWhere((n) => n.id == 'notif_admin_managed').isRead, isTrue);
    });

    test('TEST 10: Property seller/owner does not receive admin privileges over other listings', () async {
      // Seller A is an owner of property A, but must NOT have admin rights over Seller B's leads
      final leadsB = await transactionRepository.getSellerEnquiries(sellerB);
      expect(leadsB.every((e) => e.sellerId == sellerB), isTrue);

      final leadsA = await transactionRepository.getSellerEnquiries(sellerA);
      expect(leadsA.any((e) => e.sellerId == sellerB), isFalse);
    });
  });
}
