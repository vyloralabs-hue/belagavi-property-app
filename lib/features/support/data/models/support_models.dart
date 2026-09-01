import '../../domain/entities/support_entities.dart';

// ─── SupportTicketModel ───────────────────────────────────────────────────────

class SupportTicketModel extends SupportTicketEntity {
  const SupportTicketModel({
    required super.id,
    required super.userId,
    required super.category,
    required super.subject,
    required super.message,
    super.status,
    required super.createdAt,
    super.resolvedAt,
    super.agentNote,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: SupportCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String? ?? 'general'),
        orElse: () => SupportCategory.general,
      ),
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: SupportTicketStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'open'),
        orElse: () => SupportTicketStatus.open,
      ),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'] as String)
          : null,
      agentNote: json['agent_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category': category.name,
        'subject': subject,
        'message': message,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        if (resolvedAt != null) 'resolved_at': resolvedAt!.toIso8601String(),
        if (agentNote != null) 'agent_note': agentNote,
      };
}

// ─── FAQModel ─────────────────────────────────────────────────────────────────

class FAQModel extends FAQEntity {
  const FAQModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.category,
    super.isPinned,
    super.helpfulCount,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'] as String,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      isPinned: json['is_pinned'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
    );
  }
}

// ─── AppointmentModel ─────────────────────────────────────────────────────────

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.slotDateTime,
    super.status,
    super.notes,
    super.meetLink,
    required super.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: AppointmentType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'propertyConsultation'),
        orElse: () => AppointmentType.propertyConsultation,
      ),
      slotDateTime: DateTime.tryParse(json['slot_datetime'] as String? ?? '') ?? DateTime.now(),
      status: AppointmentSlotStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'available'),
        orElse: () => AppointmentSlotStatus.available,
      ),
      notes: json['notes'] as String?,
      meetLink: json['meet_link'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'slot_datetime': slotDateTime.toIso8601String(),
        'status': status.name,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}

// ─── DocumentServiceModel ─────────────────────────────────────────────────────

class DocumentServiceModel extends DocumentServiceEntity {
  const DocumentServiceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.serviceType,
    super.fee,
    super.isFree,
    required super.turnaround,
    required super.iconEmoji,
    super.isPremiumOnly,
    super.partnerNetwork,
  });

  factory DocumentServiceModel.fromJson(Map<String, dynamic> json) {
    return DocumentServiceModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      isFree: json['is_free'] as bool? ?? true,
      turnaround: json['turnaround'] as String? ?? '3–5 working days',
      iconEmoji: json['icon_emoji'] as String? ?? '📄',
      isPremiumOnly: json['is_premium_only'] as bool? ?? false,
      partnerNetwork: json['partner_network'] as String?,
    );
  }
}
