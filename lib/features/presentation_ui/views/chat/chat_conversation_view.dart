import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/chat/domain/entities/chat_entities.dart';
import 'package:belagavi_property/features/chat/presentation/providers/chat_providers.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

class ChatConversationView extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatConversationView({super.key, required this.conversationId});

  @override
  ConsumerState<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends ConsumerState<ChatConversationView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatNotifierProvider.notifier).loadMessages(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final success = await ref.read(chatNotifierProvider.notifier).sendMessage(message: text);
    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _messageController.clear();
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(chatNotifierProvider).errorMessage ?? 'Failed to send message')),
        );
      }
    }
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final conv = chatState.activeConversation;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? conv?.buyerId;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131922),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFDFCF4)),
          onPressed: () => context.canPop() ? context.pop() : context.go('/messages'),
        ),
        title: conv != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.propertyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFDFCF4),
                    ),
                  ),
                  Text(
                    '${conv.propertyLocality} • ${conv.propertyPrice > 0 ? "₹${(conv.propertyPrice / 100000).toStringAsFixed(1)}L" : "Verified"}',
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 11,
                      color: Color(0xFFB39037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Property Chat',
                style: TextStyle(color: Color(0xFFFDFCF4), fontSize: 16, fontWeight: FontWeight.w700),
              ),
        actions: [
          if (conv != null)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF94A3B8), size: 20),
              tooltip: 'View Property',
              onPressed: () => context.push('/property/${conv.propertyId}'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2D3748), height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Property Context Banner
            if (conv != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF18202B),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Direct verified communication between ${conv.buyerName} and Owner (${conv.sellerName})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Message Stream Area
            Expanded(
              child: chatState.isLoading && chatState.currentMessages.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFB39037)))
                  : chatState.currentMessages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF131922),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: Color(0xFFB39037)),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Start the Conversation',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFDFCF4), fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Inquire about pricing, documentation, or schedule visits.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: chatState.currentMessages.length,
                          itemBuilder: (context, index) {
                            final msg = chatState.currentMessages[index];
                            final isMe = msg.senderId == currentUserId;

                            return _buildMessageBubble(msg, isMe);
                          },
                        ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF131922),
                border: Border(top: BorderSide(color: Color(0xFF2D3748))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0D11),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF2D3748)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Color(0xFFFDFCF4), fontSize: 14),
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _handleSend,
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: const BoxDecoration(
                        color: Color(0xFFB39037),
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0D11)),
                            )
                          : const Icon(Icons.send_rounded, color: Color(0xFF0A0D11), size: 18),
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

  Widget _buildMessageBubble(PropertyMessageEntity msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFB39037) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: TextStyle(
                color: isMe ? const Color(0xFF0A0D11) : const Color(0xFFFDFCF4),
                fontSize: 14,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimestamp(msg.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? const Color(0xFF0A0D11).withValues(alpha: 0.6) : const Color(0xFF94A3B8),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 13,
                    color: msg.isRead ? const Color(0xFF0A0D11) : const Color(0xFF0A0D11).withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
