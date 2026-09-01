import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/data/repositories/notification_repository_impl.dart';

void main() {
  late NotificationRepositoryImpl notificationRepository;

  setUp(() {
    notificationRepository = NotificationRepositoryImpl();
  });

  group('REAL-TIME NOTIFICATIONS + NOTIFICATION CENTER WORKFLOW TESTS', () {
    const ownerId = 'usr_owner_belagavi_101';
    const buyerId = 'usr_buyer_sneha_202';
    const propertyId = 'prop_tilakwadi_3bhk';

    test('1. Owner receives exactly one notification when buyer expresses interest', () async {
      final notification = NotificationEntity(
        id: 'notif_inq_1',
        recipientId: ownerId,
        type: NotificationType.newPropertyInquiry,
        title: 'New Property Inquiry',
        body: 'Sneha Patil is interested in your property "Tilakwadi 3BHK".',
        propertyId: propertyId,
        inquiryId: 'enq_101',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await notificationRepository.sendNotification(notification);
      expect(id, 'notif_inq_1');

      final ownerNotifications = await notificationRepository.getNotifications(recipientId: ownerId);
      expect(ownerNotifications.length, 1);
      expect(ownerNotifications.first.type, NotificationType.newPropertyInquiry);
      expect(ownerNotifications.first.isRead, isFalse);

      final unreadCount = await notificationRepository.getUnreadCount(ownerId);
      expect(unreadCount, 1);
    });

    test('2. Duplicate Notification Protection prevents rapid duplicate spam', () async {
      final now = DateTime.now();
      final notification1 = NotificationEntity(
        id: 'notif_dup_1',
        recipientId: ownerId,
        type: NotificationType.newPropertyInquiry,
        title: 'New Property Inquiry',
        body: 'Sneha Patil is interested in your property.',
        propertyId: propertyId,
        inquiryId: 'enq_101',
        createdAt: now,
        updatedAt: now,
      );
      final notification2 = NotificationEntity(
        id: 'notif_dup_2',
        recipientId: ownerId,
        type: NotificationType.newPropertyInquiry,
        title: 'New Property Inquiry',
        body: 'Sneha Patil is interested in your property.',
        propertyId: propertyId,
        inquiryId: 'enq_101',
        createdAt: now.add(const Duration(milliseconds: 500)),
        updatedAt: now.add(const Duration(milliseconds: 500)),
      );

      await notificationRepository.sendNotification(notification1);
      await notificationRepository.sendNotification(notification2);

      final ownerNotifications = await notificationRepository.getNotifications(recipientId: ownerId);
      // Deduplication preserves only 1 notification for same recipient + type + inquiry within 60s
      expect(ownerNotifications.length, 1);
    });

    test('3. Owner receives Site Visit notification when customer books a visit', () async {
      final visitNotification = NotificationEntity(
        id: 'notif_visit_req_1',
        recipientId: ownerId,
        type: NotificationType.newSiteVisitRequest,
        title: 'New Site Visit Request',
        body: 'Sneha Patil requested an on-site visit for Saturday 11:00 AM.',
        propertyId: propertyId,
        inquiryId: 'enq_101',
        siteVisitId: 'sv_101',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await notificationRepository.sendNotification(visitNotification);

      final notifications = await notificationRepository.getNotifications(recipientId: ownerId);
      expect(notifications.any((n) => n.type == NotificationType.newSiteVisitRequest), isTrue);
    });

    test('4. Customer receives confirmation notification when owner confirms site visit', () async {
      final confirmNotification = NotificationEntity(
        id: 'notif_visit_conf_1',
        recipientId: buyerId,
        type: NotificationType.siteVisitConfirmed,
        title: 'Site Visit Confirmed',
        body: 'Your site visit for "Tilakwadi 3BHK" has been confirmed by the owner.',
        propertyId: propertyId,
        inquiryId: 'enq_101',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await notificationRepository.sendNotification(confirmNotification);

      final buyerNotifications = await notificationRepository.getNotifications(recipientId: buyerId);
      expect(buyerNotifications.length, 1);
      expect(buyerNotifications.first.type, NotificationType.siteVisitConfirmed);
      expect(buyerNotifications.first.recipientId, buyerId);
    });

    test('5. Customer receives rejection notification when owner cancels site visit', () async {
      final rejectNotification = NotificationEntity(
        id: 'notif_visit_rej_1',
        recipientId: buyerId,
        type: NotificationType.siteVisitRejected,
        title: 'Site Visit Update',
        body: 'Your site visit request could not be accommodated.',
        propertyId: propertyId,
        inquiryId: 'enq_101',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await notificationRepository.sendNotification(rejectNotification);

      final buyerNotifications = await notificationRepository.getNotifications(recipientId: buyerId);
      expect(buyerNotifications.any((n) => n.type == NotificationType.siteVisitRejected), isTrue);
    });

    test('6. Multi-Party RBAC Isolation: Buyer cannot read Owner notifications', () async {
      // Owner has private notification
      final ownerNotif = NotificationEntity(
        id: 'notif_owner_private',
        recipientId: ownerId,
        type: NotificationType.newPropertyInquiry,
        title: 'Owner Private Lead',
        body: 'Private lead data',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notificationRepository.sendNotification(ownerNotif);

      // Buyer queries their notifications
      final buyerNotifications = await notificationRepository.getNotifications(recipientId: buyerId);
      expect(buyerNotifications.any((n) => n.id == 'notif_owner_private'), isFalse);
    });

    test('7. Multi-Party RBAC Isolation: Seller A cannot read Seller B notifications', () async {
      const sellerBId = 'usr_seller_b_999';
      final sellerBNotif = NotificationEntity(
        id: 'notif_seller_b_lead',
        recipientId: sellerBId,
        type: NotificationType.newPropertyInquiry,
        title: 'Lead for Seller B',
        body: 'Confidential inquiry for Seller B listing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notificationRepository.sendNotification(sellerBNotif);

      final sellerANotifications = await notificationRepository.getNotifications(recipientId: ownerId);
      expect(sellerANotifications.any((n) => n.id == 'notif_seller_b_lead'), isFalse);

      final sellerBNotifications = await notificationRepository.getNotifications(recipientId: sellerBId);
      expect(sellerBNotifications.any((n) => n.id == 'notif_seller_b_lead'), isTrue);
    });

    test('8. Mark notification as read decreases unread count correctly', () async {
      final notif = NotificationEntity(
        id: 'notif_read_test',
        recipientId: 'usr_read_test_user',
        type: NotificationType.system,
        title: 'System Alert',
        body: 'Verification complete',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await notificationRepository.sendNotification(notif);

      expect(await notificationRepository.getUnreadCount('usr_read_test_user'), 1);

      await notificationRepository.markAsRead('notif_read_test');

      expect(await notificationRepository.getUnreadCount('usr_read_test_user'), 0);
      final list = await notificationRepository.getNotifications(recipientId: 'usr_read_test_user');
      expect(list.first.isRead, isTrue);
    });

    test('9. Mark all as read resets recipient unread count to zero', () async {
      const multiUser = 'usr_multi_notif_user';
      for (int i = 1; i <= 5; i++) {
        await notificationRepository.sendNotification(NotificationEntity(
          id: 'notif_bulk_$i',
          recipientId: multiUser,
          type: NotificationType.system,
          title: 'Alert $i',
          body: 'Message $i',
          isRead: false,
          createdAt: DateTime.now().subtract(Duration(minutes: i)),
          updatedAt: DateTime.now().subtract(Duration(minutes: i)),
        ));
      }

      expect(await notificationRepository.getUnreadCount(multiUser), 5);

      await notificationRepository.markAllAsRead(multiUser);

      expect(await notificationRepository.getUnreadCount(multiUser), 0);
      final unreadList = await notificationRepository.getNotifications(
        recipientId: multiUser,
        unreadOnly: true,
      );
      expect(unreadList.isEmpty, isTrue);
    });

    test('10. Pagination: Limit and offset load notifications in chunks (newest first)', () async {
      const pageUser = 'usr_pagination_user';
      final now = DateTime.now();
      for (int i = 1; i <= 25; i++) {
        await notificationRepository.sendNotification(NotificationEntity(
          id: 'notif_page_$i',
          recipientId: pageUser,
          type: NotificationType.system,
          title: 'Notification #$i',
          body: 'Body #$i',
          createdAt: now.add(Duration(minutes: i)),
          updatedAt: now.add(Duration(minutes: i)),
        ));
      }

      // Page 1 (10 items)
      final page1 = await notificationRepository.getNotifications(
        recipientId: pageUser,
        limit: 10,
        offset: 0,
      );
      expect(page1.length, 10);
      expect(page1.first.id, 'notif_page_25'); // Newest first

      // Page 2 (10 items)
      final page2 = await notificationRepository.getNotifications(
        recipientId: pageUser,
        limit: 10,
        offset: 10,
      );
      expect(page2.length, 10);
      expect(page2.first.id, 'notif_page_15');

      // Page 3 (5 items remaining)
      final page3 = await notificationRepository.getNotifications(
        recipientId: pageUser,
        limit: 10,
        offset: 20,
      );
      expect(page3.length, 5);
      expect(page3.last.id, 'notif_page_1');
    });
  });
}
