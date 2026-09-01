import 'package:equatable/equatable.dart';

enum MessageType { text, image, document, systemEvent }

class PropertyConversationEntity extends Equatable {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyLocality;
  final double propertyPrice;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final DateTime lastMessageAt;
  final String? lastMessagePreview;
  final String status; // 'ACTIVE', 'BLOCKED', 'ARCHIVED'
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyConversationEntity({
    required this.id,
    required this.propertyId,
    this.propertyTitle = 'Property',
    this.propertyLocality = 'Belagavi',
    this.propertyPrice = 0,
    required this.buyerId,
    this.buyerName = 'Buyer',
    required this.sellerId,
    this.sellerName = 'Seller',
    required this.lastMessageAt,
    this.lastMessagePreview,
    this.status = 'ACTIVE',
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  PropertyConversationEntity copyWith({
    String? propertyTitle,
    String? propertyLocality,
    double? propertyPrice,
    String? buyerName,
    String? sellerName,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    String? status,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return PropertyConversationEntity(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyLocality: propertyLocality ?? this.propertyLocality,
      propertyPrice: propertyPrice ?? this.propertyPrice,
      buyerId: buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId,
      sellerName: sellerName ?? this.sellerName,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      status: status ?? this.status,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'last_message_at': lastMessageAt.toIso8601String(),
        'last_message_preview': lastMessagePreview,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PropertyConversationEntity.fromJson(Map<String, dynamic> json) {
    return PropertyConversationEntity(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      propertyTitle: (json['property_title'] ?? json['title'] ?? 'Property') as String,
      propertyLocality: (json['property_locality'] ?? json['locality'] ?? 'Belagavi') as String,
      propertyPrice: ((json['property_price'] ?? json['price'] ?? 0) as num).toDouble(),
      buyerId: json['buyer_id'] as String,
      buyerName: (json['buyer_name'] ?? 'Buyer') as String,
      sellerId: json['seller_id'] as String,
      sellerName: (json['seller_name'] ?? 'Seller') as String,
      lastMessageAt: DateTime.parse((json['last_message_at'] ?? DateTime.now().toIso8601String()) as String),
      lastMessagePreview: json['last_message_preview'] as String?,
      status: (json['status'] ?? 'ACTIVE') as String,
      unreadCount: (json['unread_count'] ?? 0) as int,
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyTitle,
        propertyLocality,
        propertyPrice,
        buyerId,
        buyerName,
        sellerId,
        sellerName,
        lastMessageAt,
        lastMessagePreview,
        status,
        unreadCount,
        createdAt,
        updatedAt,
      ];
}

class PropertyMessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String message;
  final MessageType messageType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName = '',
    required this.message,
    this.messageType = MessageType.text,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
  });

  PropertyMessageEntity copyWith({
    String? message,
    bool? isRead,
    DateTime? updatedAt,
  }) {
    return PropertyMessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      message: message ?? this.message,
      messageType: messageType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'message': message,
        'message_type': messageType.name.toUpperCase(),
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PropertyMessageEntity.fromJson(Map<String, dynamic> json) {
    return PropertyMessageEntity(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: (json['sender_name'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      messageType: _parseMessageType(json['message_type'] as String?),
      isRead: (json['is_read'] ?? false) as bool,
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  static MessageType _parseMessageType(String? typeStr) {
    if (typeStr == null) return MessageType.text;
    return switch (typeStr.toUpperCase()) {
      'IMAGE' => MessageType.image,
      'DOCUMENT' => MessageType.document,
      'SYSTEM_EVENT' => MessageType.systemEvent,
      _ => MessageType.text,
    };
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        message,
        messageType,
        isRead,
        createdAt,
        updatedAt,
      ];
}
