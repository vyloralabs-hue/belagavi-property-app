import 'package:equatable/equatable.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum SupportTicketStatus { open, inProgress, resolved, closed }

enum SupportCategory {
  whatsapp,
  call,
  documentation,
  registration,
  verification,
  consultation,
  general,
  // Future reserved
  liveChat,
  aiAssistant,
  homeLoan,
}

enum AppointmentType {
  propertyConsultation,
  documentationReview,
  legalGuidance,
  siteVisit,
  // Future reserved
  videoConsultation,
}

enum AppointmentSlotStatus { available, booked, completed, cancelled }

// ─── Entities ─────────────────────────────────────────────────────────────────

class SupportTicketEntity extends Equatable {
  final String id;
  final String userId;
  final SupportCategory category;
  final String subject;
  final String message;
  final SupportTicketStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? agentNote;

  const SupportTicketEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.subject,
    required this.message,
    this.status = SupportTicketStatus.open,
    required this.createdAt,
    this.resolvedAt,
    this.agentNote,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        subject,
        message,
        status,
        createdAt,
        resolvedAt,
        agentNote,
      ];
}

class FAQEntity extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String category; // 'buying', 'selling', 'documentation', 'legal', 'general'
  final bool isPinned;
  final int helpfulCount;

  const FAQEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.isPinned = false,
    this.helpfulCount = 0,
  });

  @override
  List<Object?> get props => [id, question, answer, category, isPinned, helpfulCount];
}

class AppointmentEntity extends Equatable {
  final String id;
  final String userId;
  final AppointmentType type;
  final DateTime slotDateTime;
  final AppointmentSlotStatus status;
  final String? notes;
  final String? meetLink; // Future: video consultation link
  final DateTime createdAt;

  const AppointmentEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.slotDateTime,
    this.status = AppointmentSlotStatus.available,
    this.notes,
    this.meetLink,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, type, slotDateTime, status, notes, meetLink, createdAt];
}

class DocumentServiceEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String serviceType; // 'ec_report', 'khata', 'encumbrance', 'registration', 'rto', 'legal_opinion'
  final double fee; // 0.0 = free
  final bool isFree;
  final String turnaround; // e.g. '2–3 working days'
  final String iconEmoji;
  final bool isPremiumOnly; // Future: subscription gate
  final String? partnerNetwork; // Future: legal partner integration

  const DocumentServiceEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    this.fee = 0.0,
    this.isFree = true,
    required this.turnaround,
    required this.iconEmoji,
    this.isPremiumOnly = false,
    this.partnerNetwork,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        serviceType,
        fee,
        isFree,
        turnaround,
        iconEmoji,
        isPremiumOnly,
        partnerNetwork,
      ];
}
