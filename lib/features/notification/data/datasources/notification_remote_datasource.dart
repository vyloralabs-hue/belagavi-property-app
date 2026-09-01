import 'package:belagavi_property/core/backend/supabase_service.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> fetchNotifications({
    required String recipientId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  });

  Future<int> fetchUnreadCount(String recipientId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String recipientId);

  Future<String> insertNotification(NotificationEntity notification);

  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseService _supabaseService;

  NotificationRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<List<NotificationEntity>> fetchNotifications({
    required String recipientId,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      var query = _supabaseService
          .from('notifications')
          .select()
          .eq('recipient_id', recipientId);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final list = (response as List)
          .map((row) => NotificationEntity.fromMap(row as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<int> fetchUnreadCount(String recipientId) async {
    try {
      final response = await _supabaseService
          .from('notifications')
          .select('id')
          .eq('recipient_id', recipientId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabaseService.from('notifications').update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (_) {}
  }

  @override
  Future<void> markAllAsRead(String recipientId) async {
    try {
      await _supabaseService.from('notifications').update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('recipient_id', recipientId).eq('is_read', false);
    } catch (_) {}
  }

  @override
  Future<String> insertNotification(NotificationEntity notification) async {
    try {
      await _supabaseService.from('notifications').insert(notification.toMap());
      return notification.id;
    } catch (_) {
      return notification.id;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabaseService.from('notifications').delete().eq('id', notificationId);
    } catch (_) {}
  }
}
