import 'package:belagavi_property/core/errors/security_exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource? _remoteDataSource;
  final Map<String, NotificationEntity> _storage = {};

  NotificationRepositoryImpl([this._remoteDataSource]);

  @override
  Future<List<NotificationEntity>> getNotifications({
    required String recipientId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    if (_remoteDataSource != null) {
      final remoteList = await _remoteDataSource.fetchNotifications(
        recipientId: recipientId,
        limit: limit,
        offset: offset,
        unreadOnly: unreadOnly,
      );
      if (remoteList.isNotEmpty) {
        for (final n in remoteList) {
          _storage[n.id] = n;
        }
        return remoteList;
      }
    }

    var list = _storage.values.where((n) => n.recipientId == recipientId);
    if (unreadOnly) {
      list = list.where((n) => !n.isRead);
    }
    final sorted = list.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (offset >= sorted.length) return [];
    return sorted.skip(offset).take(limit).toList();
  }

  @override
  Future<int> getUnreadCount(String recipientId) async {
    if (_remoteDataSource != null) {
      try {
        final count = await _remoteDataSource.fetchUnreadCount(recipientId);
        if (count > 0) return count;
      } catch (_) {}
    }

    return _storage.values
        .where((n) => n.recipientId == recipientId && !n.isRead)
        .length;
  }

  @override
  Future<void> markAsRead(String notificationId, {String? requesterUserId}) async {
    final existing = _storage[notificationId];
    if (existing != null) {
      if (requesterUserId != null &&
          requesterUserId != existing.recipientId &&
          requesterUserId != 'admin' &&
          requesterUserId != 'founder') {
        throw const AccessDeniedException('Access Denied: You cannot mark another user\'s notification as read.');
      }
      _storage[notificationId] = existing.copyWith(isRead: true, updatedAt: DateTime.now());
    }
    if (_remoteDataSource != null) {
      await _remoteDataSource.markAsRead(notificationId);
    }
  }

  @override
  Future<void> markAllAsRead(String recipientId, {String? requesterUserId}) async {
    if (requesterUserId != null &&
        requesterUserId != recipientId &&
        requesterUserId != 'admin' &&
        requesterUserId != 'founder') {
      throw const AccessDeniedException('Access Denied: You cannot mark another user\'s notifications as read.');
    }

    for (final key in _storage.keys) {
      final n = _storage[key]!;
      if (n.recipientId == recipientId && !n.isRead) {
        _storage[key] = n.copyWith(isRead: true, updatedAt: DateTime.now());
      }
    }
    if (_remoteDataSource != null) {
      await _remoteDataSource.markAllAsRead(recipientId);
    }
  }

  @override
  Future<String> sendNotification(NotificationEntity notification, {String? callerUserId}) async {
    if (notification.recipientId.trim().isEmpty) {
      throw const AccessDeniedException('Access Denied: Recipient ID is required.');
    }

    // Deduplication check: prevent duplicate active notifications within 60s window for identical events
    final isDuplicate = _storage.values.any((n) =>
        n.recipientId == notification.recipientId &&
        n.type == notification.type &&
        n.title == notification.title &&
        (notification.inquiryId != null ? n.inquiryId == notification.inquiryId : true) &&
        (notification.propertyId != null ? n.propertyId == notification.propertyId : true) &&
        !n.isRead &&
        notification.createdAt.difference(n.createdAt).inSeconds.abs() < 60);

    if (isDuplicate) {
      return notification.id;
    }

    _storage[notification.id] = notification;

    if (_remoteDataSource != null) {
      await _remoteDataSource.insertNotification(notification);
    }

    return notification.id;
  }

  @override
  Future<void> deleteNotification(String notificationId, {String? requesterUserId}) async {
    final existing = _storage[notificationId];
    if (existing != null &&
        requesterUserId != null &&
        requesterUserId != existing.recipientId &&
        requesterUserId != 'admin' &&
        requesterUserId != 'founder') {
      throw const AccessDeniedException('Access Denied: You cannot delete another user\'s notification.');
    }

    _storage.remove(notificationId);
    if (_remoteDataSource != null) {
      await _remoteDataSource.deleteNotification(notificationId);
    }
  }
}
