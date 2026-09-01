import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

class NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool unreadOnly;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.unreadOnly = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? unreadOnly,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      errorMessage: errorMessage,
    );
  }
}

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(NotificationNotifier.new);

class NotificationNotifier extends Notifier<NotificationState> {
  late final NotificationRepository _repo;
  static const int _pageSize = 20;

  @override
  NotificationState build() {
    _repo = ref.watch(notificationRepositoryProvider);
    Future.microtask(() => loadNotifications());
    return const NotificationState();
  }

  String get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ??
      AuthSessionStorageHelper.getUserUid() ??
      'usr_authenticated';

  Future<void> loadNotifications({String? recipientId, bool? unreadOnly}) async {
    final effectiveRecipientId = recipientId ?? _currentUserId;
    final filter = unreadOnly ?? state.unreadOnly;
    state = state.copyWith(isLoading: true, unreadOnly: filter);

    try {
      final list = await _repo.getNotifications(
        recipientId: effectiveRecipientId,
        limit: _pageSize,
        offset: 0,
        unreadOnly: filter,
      );
      final count = await _repo.getUnreadCount(effectiveRecipientId);

      state = state.copyWith(
        notifications: list,
        unreadCount: count,
        isLoading: false,
        hasMore: list.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore({String? recipientId}) async {
    if (state.isLoadingMore || !state.hasMore) return;
    final effectiveRecipientId = recipientId ?? _currentUserId;
    state = state.copyWith(isLoadingMore: true);

    try {
      final more = await _repo.getNotifications(
        recipientId: effectiveRecipientId,
        limit: _pageSize,
        offset: state.notifications.length,
        unreadOnly: state.unreadOnly,
      );

      state = state.copyWith(
        notifications: [...state.notifications, ...more],
        isLoadingMore: false,
        hasMore: more.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> setUnreadFilter(bool unreadOnly) async {
    if (state.unreadOnly == unreadOnly) return;
    await loadNotifications(unreadOnly: unreadOnly);
  }

  Future<void> markAsRead(String notificationId, {String? recipientId}) async {
    await _repo.markAsRead(notificationId);
    final updatedList = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final count = await _repo.getUnreadCount(recipientId ?? _currentUserId);
    state = state.copyWith(notifications: updatedList, unreadCount: count);
  }

  Future<void> markAllAsRead({String? recipientId}) async {
    final effectiveRecipientId = recipientId ?? _currentUserId;
    await _repo.markAllAsRead(effectiveRecipientId);
    final updatedList = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updatedList, unreadCount: 0);
  }

  Future<String> dispatchNotification(NotificationEntity notification) async {
    final id = await _repo.sendNotification(notification);
    // If the notification belongs to current user, refresh
    if (notification.recipientId == _currentUserId) {
      await loadNotifications();
    }
    return id;
  }
}
