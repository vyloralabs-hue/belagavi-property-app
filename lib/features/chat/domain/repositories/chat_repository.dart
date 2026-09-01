import 'package:belagavi_property/core/security/user_role.dart';
import '../entities/chat_entities.dart';

abstract class ChatRepository {
  Future<PropertyConversationEntity> getOrCreateConversation({
    required String propertyId,
    required String buyerId,
    required String sellerId,
    String propertyTitle = 'Property',
    String propertyLocality = 'Belagavi',
    double propertyPrice = 0,
    String buyerName = 'Buyer',
    String sellerName = 'Seller',
  });

  Future<List<PropertyConversationEntity>> getConversationsForUser({
    required String userId,
    UserRole? userRole,
  });

  Future<PropertyConversationEntity?> getConversationById(
    String conversationId, {
    required String requestingUserId,
    UserRole? userRole,
  });

  Future<List<PropertyMessageEntity>> getMessages({
    required String conversationId,
    required String requestingUserId,
    int limit = 50,
    int offset = 0,
    UserRole? userRole,
  });

  Future<PropertyMessageEntity> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String message,
    MessageType messageType = MessageType.text,
    required String recipientId,
    required String propertyId,
    String propertyTitle = 'Property',
  });

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String readerUserId,
  });

  Future<int> getUnreadCount(String userId);

  Stream<List<PropertyMessageEntity>> streamMessages(String conversationId);
}
