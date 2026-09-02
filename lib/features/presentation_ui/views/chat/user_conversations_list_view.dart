import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/chat/domain/entities/chat_entities.dart';
import 'package:belagavi_property/features/chat/presentation/providers/chat_providers.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

class UserConversationsListView extends ConsumerStatefulWidget {
  const UserConversationsListView({super.key});

  @override
  ConsumerState<UserConversationsListView> createState() =>
      _UserConversationsListViewState();
}

class _UserConversationsListViewState
    extends ConsumerState<UserConversationsListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatNotifierProvider.notifier).loadUserConversations();
    });
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131922),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFDFCF4)),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFDFCF4),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFDFCF4)),
            onPressed: () =>
                ref.read(chatNotifierProvider.notifier).loadUserConversations(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2D3748), height: 1),
        ),
      ),
      body: SafeArea(
        child: chatState.isLoading && chatState.conversations.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB39037)),
              )
            : chatState.conversations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF131922),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.forum_outlined,
                        size: 44,
                        color: Color(0xFFB39037),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Conversations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFDFCF4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Inquire on properties to chat directly with owners.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: chatState.conversations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final conv = chatState.conversations[index];
                  final isBuyer = conv.buyerId == currentUserId;
                  final otherPartyName = isBuyer
                      ? 'Owner: ${conv.sellerName}'
                      : 'Buyer: ${conv.buyerName}';

                  return _buildConversationCard(conv, otherPartyName);
                },
              ),
      ),
    );
  }

  Widget _buildConversationCard(
    PropertyConversationEntity conv,
    String otherPartyName,
  ) {
    return InkWell(
      onTap: () => context.push('/chat/${conv.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF131922),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D3748)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF18202B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB39037).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: Color(0xFFB39037),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conv.propertyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFFFDFCF4),
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(conv.lastMessageAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    otherPartyName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB39037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conv.lastMessagePreview ?? 'No messages yet.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
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
