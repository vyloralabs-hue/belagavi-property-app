import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/notification/presentation/providers/notification_notifier.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final supabaseService = SupabaseService();
  final notificationRepo = ref.read(notificationRepositoryProvider);
  return ChatRepositoryImpl(
    supabaseService: supabaseService,
    notificationRepository: notificationRepo,
  );
});

class ChatState {
  final List<PropertyConversationEntity> conversations;
  final List<PropertyMessageEntity> currentMessages;
  final PropertyConversationEntity? activeConversation;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.activeConversation,
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<PropertyConversationEntity>? conversations,
    List<PropertyMessageEntity>? currentMessages,
    PropertyConversationEntity? activeConversation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      activeConversation: activeConversation ?? this.activeConversation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  late final ChatRepository _chatRepository;

  @override
  ChatState build() {
    _chatRepository = ref.read(chatRepositoryProvider);
    return const ChatState();
  }

  Future<void> loadUserConversations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'usr_buyer_default';
    final userRole = AuthSessionStorageHelper.getParsedUserRole();

    try {
      final list = await _chatRepository.getConversationsForUser(
        userId: userId,
        userRole: userRole,
      );
      state = state.copyWith(conversations: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<PropertyConversationEntity?> startOrOpenChat({
    required String propertyId,
    required String sellerId,
    required String propertyTitle,
    required String propertyLocality,
    required double propertyPrice,
    String sellerName = 'Seller',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final buyerId = user?.uid ?? 'usr_buyer_default';
    final buyerName = user?.displayName ?? 'Verified Buyer';

    try {
      final conv = await _chatRepository.getOrCreateConversation(
        propertyId: propertyId,
        buyerId: buyerId,
        sellerId: sellerId,
        propertyTitle: propertyTitle,
        propertyLocality: propertyLocality,
        propertyPrice: propertyPrice,
        buyerName: buyerName,
        sellerName: sellerName,
      );
      state = state.copyWith(activeConversation: conv);
      await loadMessages(conv.id);
      return conv;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'usr_buyer_default';
    final userRole = AuthSessionStorageHelper.getParsedUserRole();

    try {
      final conv = await _chatRepository.getConversationById(
        conversationId,
        requestingUserId: userId,
        userRole: userRole,
      );
      final messages = await _chatRepository.getMessages(
        conversationId: conversationId,
        requestingUserId: userId,
        userRole: userRole,
      );
      state = state.copyWith(
        activeConversation: conv,
        currentMessages: messages,
        isLoading: false,
      );

      await _chatRepository.markMessagesAsRead(
        conversationId: conversationId,
        readerUserId: userId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> sendMessage({
    required String message,
  }) async {
    final conv = state.activeConversation;
    if (conv == null) return false;

    final user = FirebaseAuth.instance.currentUser;
    final senderId = user?.uid ?? conv.buyerId;
    final senderName = user?.displayName ?? (senderId == conv.buyerId ? conv.buyerName : conv.sellerName);
    final recipientId = senderId == conv.buyerId ? conv.sellerId : conv.buyerId;

    try {
      final msg = await _chatRepository.sendMessage(
        conversationId: conv.id,
        senderId: senderId,
        senderName: senderName,
        message: message,
        recipientId: recipientId,
        propertyId: conv.propertyId,
        propertyTitle: conv.propertyTitle,
      );

      final updated = [...state.currentMessages, msg];
      state = state.copyWith(currentMessages: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
