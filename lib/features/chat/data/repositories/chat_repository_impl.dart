import 'dart:async';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/domain/repositories/notification_repository.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../utils/chat_security_guard.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseService? _supabaseService;
  final NotificationRepository? _notificationRepository;

  final Map<String, PropertyConversationEntity> _conversations = {};
  final Map<String, List<PropertyMessageEntity>> _messages = {};
  final Map<String, StreamController<List<PropertyMessageEntity>>>
  _streamControllers = {};

  ChatRepositoryImpl({
    SupabaseService? supabaseService,
    NotificationRepository? notificationRepository,
  })  : _supabaseService = supabaseService,
        _notificationRepository = notificationRepository;

  @override
  Future<PropertyConversationEntity> getOrCreateConversation({
    required String propertyId,
    required String buyerId,
    required String sellerId,
    String propertyTitle = 'Property',
    String propertyLocality = 'Belagavi',
    double propertyPrice = 0,
    String buyerName = 'Buyer',
    String sellerName = 'Seller',
  }) async {
    if (buyerId.trim().isEmpty) {
      throw const AccessDeniedException('Buyer authentication required.');
    }
    if (buyerId == sellerId) {
      throw const AccessDeniedException('Cannot create chat on own listing.');
    }

    // 1. Check local cache / existing in memory
    for (final conv in _conversations.values) {
      if (conv.propertyId == propertyId && conv.buyerId == buyerId) {
        return conv;
      }
    }

    // 2. Query Supabase if initialized
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        final existing = await _supabaseService
            .from('property_conversations')
            .select()
            .eq('property_id', propertyId)
            .eq('buyer_id', buyerId)
            .maybeSingle();

        if (existing != null) {
          final conv = PropertyConversationEntity.fromJson(existing);
          _conversations[conv.id] = conv;
          return conv;
        }

        // Insert new conversation in database
        final newId = 'conv_${propertyId}_$buyerId';
        final payload = {
          'id': newId,
          'property_id': propertyId,
          'buyer_id': buyerId,
          'seller_id': sellerId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now(),
          'last_message_at': DateTime.now().toIso8601String(),
          'status': 'ACTIVE',
        };
        final inserted = await _supabaseService
            .from('property_conversations')
            .insert(payload)
            .select()
            .single();

        final created = PropertyConversationEntity.fromJson(inserted).copyWith(
          propertyTitle: propertyTitle,
          propertyLocality: propertyLocality,
          propertyPrice: propertyPrice,
          buyerName: buyerName,
          sellerName: sellerName,
        );
        _conversations[created.id] = created;
        return created;
      } catch (_) {}
    }

    // 3. In-memory creation
    final newId = 'conv_${propertyId}_$buyerId';
    final created = PropertyConversationEntity(
      id: newId,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      propertyLocality: propertyLocality,
      propertyPrice: propertyPrice,
      buyerId: buyerId,
      buyerName: buyerName,
      sellerId: sellerId,
      sellerName: sellerName,
      lastMessageAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _conversations[newId] = created;
    return created;
  }

  @override
  Future<List<PropertyConversationEntity>> getConversationsForUser({
    required String userId,
    UserRole? userRole,
  }) async {
    if (userId.trim().isEmpty) return [];

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        var query = _supabaseService.from('property_conversations').select();
        if (userRole == null || !userRole.isAdminOrFounder) {
          query = query.or('buyer_id.eq.$userId,seller_id.eq.$userId');
        }
        final response = await query.order('last_message_at', ascending: false);
        final list = (response as List)
            .map((json) => PropertyConversationEntity.fromJson(json))
            .toList();
        for (final c in list) {
          _conversations[c.id] = c;
        }
        return list;
      } catch (_) {}
    }

    final list = _conversations.values.where((c) {
      if (userRole != null && userRole.isAdminOrFounder) return true;
      return c.buyerId == userId || c.sellerId == userId;
    }).toList()..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list;
  }

  @override
  Future<PropertyConversationEntity?> getConversationById(
    String conversationId, {
    required String requestingUserId,
    UserRole? userRole,
  }) async {
    PropertyConversationEntity? conv = _conversations[conversationId];

    if (conv == null &&
        _supabaseService != null &&
        _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService
            .from('property_conversations')
            .select()
            .eq('id', conversationId)
            .maybeSingle();
        if (response != null) {
          conv = PropertyConversationEntity.fromJson(response);
          _conversations[conv.id] = conv;
        }
      } catch (_) {}
    }

    if (conv == null) return null;

    // Participant Security Check
    ChatSecurityGuard.verifyParticipant(
      requestingUserId: requestingUserId,
      conversation: conv,
      userRole: userRole,
      actionName: 'view this conversation',
    );

    return conv;
  }

  @override
  Future<List<PropertyMessageEntity>> getMessages({
    required String conversationId,
    required String requestingUserId,
    int limit = 50,
    int offset = 0,
    UserRole? userRole,
  }) async {
    // 1. Verify participant permission
    final conv = await getConversationById(
      conversationId,
      requestingUserId: requestingUserId,
      userRole: userRole,
    );
    if (conv == null) {
      throw const AccessDeniedException(
        'Conversation not found or access denied.',
      );
    }

    // 2. Fetch from Supabase
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService
            .from('property_messages')
            .select()
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: true)
            .range(offset, offset + limit - 1);
        final list = (response as List)
            .map((json) => PropertyMessageEntity.fromJson(json))
            .toList();
        _messages[conversationId] = list;
        return list;
      } catch (_) {}
    }

    // 3. Memory storage
    final list = _messages[conversationId] ?? [];
    if (offset >= list.length) return [];
    return list.skip(offset).take(limit).toList();
  }

  @override
  Future<PropertyMessageEntity> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String message,
    MessageType messageType = MessageType.text,
    required String recipientId,
    required String propertyId,
    String propertyTitle = 'Property',
  }) async {
    // 1. Validate payload
    final validatedText = ChatSecurityGuard.validateMessageText(message);

    // 2. Verify participant authorization
    final conv = _conversations[conversationId];
    if (conv != null) {
      ChatSecurityGuard.verifyParticipant(
        requestingUserId: senderId,
        conversation: conv,
        actionName: 'send a message in this conversation',
      );
    }

    // 3. Idempotency & Deduplication: Prevent duplicate rapid identical message posts
    final currentList = _messages[conversationId] ?? [];
    final now = DateTime.now();
    final isDuplicate = currentList.any(
      (m) =>
          m.conversationId == conversationId &&
          m.senderId == senderId &&
          m.message == validatedText &&
          now.difference(m.createdAt).inSeconds.abs() < 3,
    );

    if (isDuplicate) {
      return currentList.lastWhere((m) => m.senderId == senderId);
    }

    final msgId =
        'msg_${now.millisecondsSinceEpoch}_${senderId.hashCode.abs()}';
    final entity = PropertyMessageEntity(
      id: msgId,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      message: validatedText,
      messageType: messageType,
      isRead: false,
      createdAt: now,
      updatedAt: now,
    );

    // 4. Save to database or memory
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('property_messages')
            .insert(entity.toJson());
        await _supabaseService
            .from('property_conversations')
            .update({
              'last_message_at': now.toIso8601String(),
              'last_message_preview': validatedText.length > 60
                  ? '${validatedText.substring(0, 57)}...'
                  : validatedText,
              'updated_at': now.toIso8601String(),
            })
            .eq('id', conversationId);
      } catch (_) {}
    }

    // Update in-memory storage
    final updatedList = [...currentList, entity];
    _messages[conversationId] = updatedList;

    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(
        lastMessageAt: now,
        lastMessagePreview: validatedText.length > 60
            ? '${validatedText.substring(0, 57)}...'
            : validatedText,
        updatedAt: now,
      );
    }

    // Notify stream controllers
    _getOrCreateController(conversationId).add(updatedList);

    // 5. Automated Notification to Recipient
    if (_notificationRepository != null &&
        recipientId.isNotEmpty &&
        recipientId != senderId) {
      final notifPreview = validatedText.length > 50
          ? '${validatedText.substring(0, 47)}...'
          : validatedText;
      final notif = NotificationEntity(
        id: 'notif_chat_${conversationId}_${now.millisecondsSinceEpoch}',
        recipientId: recipientId,
        type: NotificationType.newChatMessage,
        title: 'New Message from $senderName',
        body: '$senderName on "$propertyTitle": "$notifPreview"',
        propertyId: propertyId,
        inquiryId: conversationId,
        createdAt: now,
        updatedAt: now,
      );
      try {
        await _notificationRepository.sendNotification(notif);
      } catch (_) {}
    }

    return entity;
  }

  @override
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String readerUserId,
  }) async {
    final list = _messages[conversationId];
    if (list != null) {
      final updated = list.map((m) {
        if (m.senderId != readerUserId && !m.isRead) {
          return m.copyWith(isRead: true, updatedAt: DateTime.now());
        }
        return m;
      }).toList();
      _messages[conversationId] = updated;
      _getOrCreateController(conversationId).add(updated);
    }

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('property_messages')
            .update({
              'is_read': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('conversation_id', conversationId)
            .neq('sender_id', readerUserId);
      } catch (_) {}
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    int count = 0;
    for (final conv in _conversations.values) {
      if (conv.buyerId == userId || conv.sellerId == userId) {
        final msgs = _messages[conv.id] ?? [];
        count += msgs.where((m) => m.senderId != userId && !m.isRead).length;
      }
    }
    return count;
  }

  @override
  Stream<List<PropertyMessageEntity>> streamMessages(String conversationId) {
    final controller = _getOrCreateController(conversationId);
    final initialList = _messages[conversationId] ?? [];
    Future.microtask(() => controller.add(initialList));
    return controller.stream;
  }

  StreamController<List<PropertyMessageEntity>> _getOrCreateController(
    String conversationId,
  ) {
    if (!_streamControllers.containsKey(conversationId) ||
        _streamControllers[conversationId]!.isClosed) {
      _streamControllers[conversationId] =
          StreamController<List<PropertyMessageEntity>>.broadcast();
    }
    return _streamControllers[conversationId]!;
  }
}
