import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/presentation/providers/notification_notifier.dart';

class NotificationCenterView extends ConsumerStatefulWidget {
  const NotificationCenterView({super.key});

  @override
  ConsumerState<NotificationCenterView> createState() => _NotificationCenterViewState();
}

class _NotificationCenterViewState extends ConsumerState<NotificationCenterView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(notificationNotifierProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationNotifierProvider.notifier).loadMore();
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _handleNotificationTap(NotificationEntity notification) {
    ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.newPropertyInquiry:
      case NotificationType.newSiteVisitRequest:
        context.push('/seller-enquiries');
        break;
      case NotificationType.siteVisitConfirmed:
      case NotificationType.siteVisitRejected:
      case NotificationType.siteVisitRescheduled:
      case NotificationType.inquiryClosed:
        context.push('/my-enquiries');
        break;
      case NotificationType.newSavedSearchMatch:
      case NotificationType.priceDropMatch:
        if (notification.propertyId != null && notification.propertyId!.isNotEmpty) {
          context.push('/property/${notification.propertyId}');
        } else {
          context.push('/saved-searches');
        }
        break;
      case NotificationType.newChatMessage:
        context.push('/user-messages');
        break;
      case NotificationType.system:
        if (notification.propertyId != null && notification.propertyId!.isNotEmpty) {
          context.push('/property/${notification.propertyId}');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFDFCF4)),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFDFCF4),
          ),
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFFB39037)),
              label: const Text(
                'Mark all read',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB39037),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs (All / Unread)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildTab(
                    label: 'All (${state.notifications.length})',
                    isSelected: !state.unreadOnly,
                    onTap: () => notifier.setUnreadFilter(false),
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    label: 'Unread (${state.unreadCount})',
                    isSelected: state.unreadOnly,
                    onTap: () => notifier.setUnreadFilter(true),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2D3748)),

            // Notifications List / Empty State
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFB39037)))
                  : state.notifications.isEmpty
                      ? _buildEmptyState(state.unreadOnly)
                      : RefreshIndicator(
                          color: const Color(0xFFB39037),
                          backgroundColor: const Color(0xFF131922),
                          onRefresh: () async => notifier.loadNotifications(),
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (index >= state.notifications.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(color: Color(0xFFB39037)),
                                  ),
                                );
                              }
                              final notification = state.notifications[index];
                              return _buildNotificationCard(notification);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB39037) : const Color(0xFF131922),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB39037) : const Color(0xFF2D3748),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF0A0D11) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool unreadOnly) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF131922),
                shape: BoxShape.circle,
              ),
              child: Icon(
                unreadOnly ? Icons.mark_email_read_outlined : Icons.notifications_off_outlined,
                size: 40,
                color: const Color(0xFFB39037),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              unreadOnly ? "You're all caught up!" : 'No notifications yet.',
              style: const TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFDFCF4),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              unreadOnly
                  ? 'There are no unread notifications.'
                  : 'Important updates regarding your properties, inquiries, and site visits will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    final iconData = switch (notification.type) {
      NotificationType.newPropertyInquiry => Icons.mail_outline_rounded,
      NotificationType.newSiteVisitRequest => Icons.calendar_month_rounded,
      NotificationType.siteVisitConfirmed => Icons.check_circle_outline_rounded,
      NotificationType.siteVisitRejected => Icons.cancel_outlined,
      NotificationType.siteVisitRescheduled => Icons.update_rounded,
      NotificationType.inquiryClosed => Icons.archive_outlined,
      NotificationType.newSavedSearchMatch => Icons.saved_search_rounded,
      NotificationType.priceDropMatch => Icons.trending_down_rounded,
      NotificationType.newChatMessage => Icons.chat_bubble_outline_rounded,
      NotificationType.system => Icons.info_outline_rounded,
    };

    final iconColor = switch (notification.type) {
      NotificationType.newPropertyInquiry => const Color(0xFFB39037),
      NotificationType.newSiteVisitRequest => const Color(0xFF38BDF8),
      NotificationType.siteVisitConfirmed => const Color(0xFF10B981),
      NotificationType.siteVisitRejected => const Color(0xFFEF4444),
      NotificationType.siteVisitRescheduled => const Color(0xFFF59E0B),
      NotificationType.inquiryClosed => const Color(0xFF94A3B8),
      NotificationType.newSavedSearchMatch => const Color(0xFF38BDF8),
      NotificationType.priceDropMatch => const Color(0xFF10B981),
      NotificationType.newChatMessage => const Color(0xFF38BDF8),
      NotificationType.system => const Color(0xFF6366F1),
    };

    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? const Color(0xFF131922) : const Color(0xFF18202B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? const Color(0xFF2D3748) : const Color(0xFFB39037).withValues(alpha: 0.5),
            width: notification.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: const Color(0xFFFDFCF4),
                          ),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB39037),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _formatTimeAgo(notification.createdAt),
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 12,
                      color: Color(0xFFCBD5E1),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
