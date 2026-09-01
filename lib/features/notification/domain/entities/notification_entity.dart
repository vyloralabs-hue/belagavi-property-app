import 'package:equatable/equatable.dart';

enum NotificationType {
  newPropertyInquiry,
  newSiteVisitRequest,
  siteVisitConfirmed,
  siteVisitRejected,
  siteVisitRescheduled,
  inquiryClosed,
  newSavedSearchMatch,
  priceDropMatch,
  newChatMessage,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName => switch (this) {
        NotificationType.newPropertyInquiry => 'New Property Inquiry',
        NotificationType.newSiteVisitRequest => 'New Site Visit Request',
        NotificationType.siteVisitConfirmed => 'Site Visit Confirmed',
        NotificationType.siteVisitRejected => 'Site Visit Update',
        NotificationType.siteVisitRescheduled => 'Site Visit Rescheduled',
        NotificationType.inquiryClosed => 'Inquiry Closed',
        NotificationType.newSavedSearchMatch => 'New Property Match',
        NotificationType.priceDropMatch => 'Price Drop Alert',
        NotificationType.newChatMessage => 'New Chat Message',
        NotificationType.system => 'System Alert',
      };

  static NotificationType fromString(String? val) {
    if (val == null) return NotificationType.system;
    return NotificationType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == val.toLowerCase() ||
          e.name.toLowerCase() == val.replaceAll('_', '').toLowerCase(),
      orElse: () {
        final normalized = val.toUpperCase();
        if (normalized == 'NEW_PROPERTY_INQUIRY') return NotificationType.newPropertyInquiry;
        if (normalized == 'NEW_SITE_VISIT_REQUEST') return NotificationType.newSiteVisitRequest;
        if (normalized == 'SITE_VISIT_CONFIRMED') return NotificationType.siteVisitConfirmed;
        if (normalized == 'SITE_VISIT_REJECTED') return NotificationType.siteVisitRejected;
        if (normalized == 'SITE_VISIT_RESCHEDULED') return NotificationType.siteVisitRescheduled;
        if (normalized == 'INQUIRY_CLOSED') return NotificationType.inquiryClosed;
        if (normalized == 'NEW_SAVED_SEARCH_MATCH') return NotificationType.newSavedSearchMatch;
        if (normalized == 'PRICE_DROP_MATCH') return NotificationType.priceDropMatch;
        if (normalized == 'NEW_CHAT_MESSAGE') return NotificationType.newChatMessage;
        return NotificationType.system;
      },
    );
  }
}

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String body;
  final String? propertyId;
  final String? inquiryId;
  final String? siteVisitId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.propertyId,
    this.inquiryId,
    this.siteVisitId,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    NotificationType? type,
    String? title,
    String? body,
    String? propertyId,
    String? inquiryId,
    String? siteVisitId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      propertyId: propertyId ?? this.propertyId,
      inquiryId: inquiryId ?? this.inquiryId,
      siteVisitId: siteVisitId ?? this.siteVisitId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'type': type.name,
      'title': title,
      'body': body,
      'property_id': propertyId,
      'inquiry_id': inquiryId,
      'site_visit_id': siteVisitId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] as String,
      recipientId: (map['recipient_id'] ?? map['recipientId'] ?? '') as String,
      type: NotificationTypeExtension.fromString((map['type']) as String?),
      title: (map['title'] as String?) ?? 'Notification',
      body: (map['body'] as String?) ?? '',
      propertyId: (map['property_id'] ?? map['propertyId']) as String?,
      inquiryId: (map['inquiry_id'] ?? map['inquiryId']) as String?,
      siteVisitId: (map['site_visit_id'] ?? map['siteVisitId']) as String?,
      isRead: (map['is_read'] ?? map['isRead'] ?? false) as bool,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : (map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : (map['updatedAt'] != null
              ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  @override
  List<Object?> get props => [
        id,
        recipientId,
        type,
        title,
        body,
        propertyId,
        inquiryId,
        siteVisitId,
        isRead,
        createdAt,
        updatedAt,
      ];
}
