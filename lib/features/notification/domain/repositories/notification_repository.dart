import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({
    required String recipientId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  });

  Future<int> getUnreadCount(String recipientId);

  Future<void> markAsRead(String notificationId, {String? requesterUserId});

  Future<void> markAllAsRead(String recipientId, {String? requesterUserId});

  Future<String> sendNotification(NotificationEntity notification, {String? callerUserId});

  Future<void> deleteNotification(String notificationId, {String? requesterUserId});
}
