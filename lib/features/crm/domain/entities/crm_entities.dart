import 'package:equatable/equatable.dart';

enum KanbanStageEnum { newLead, contacted, siteVisitScheduled, negotiation, closedWon, closedLost }

enum LeadSource { websiteInquiry, whatsappCall, aiAssistant, referral, walkIn }

enum TaskPriority { low, medium, high, urgent }

class CRMLeadEntity extends Equatable {
  final String id;
  final String propertyId;
  final String assignedToUserId; // Broker or Builder Team Member
  final String buyerName;
  final String buyerPhone;
  final String? buyerEmail;
  final double budgetMax;
  final KanbanStageEnum stage;
  final LeadSource source;
  final double aiConversionScore; // 0.0 to 100.0
  final DateTime createdAt;
  final DateTime updatedAt;

  const CRMLeadEntity({
    required this.id,
    required this.propertyId,
    required this.assignedToUserId,
    required this.buyerName,
    required this.buyerPhone,
    this.buyerEmail,
    required this.budgetMax,
    this.stage = KanbanStageEnum.newLead,
    this.source = LeadSource.websiteInquiry,
    this.aiConversionScore = 50.0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        assignedToUserId,
        buyerName,
        buyerPhone,
        buyerEmail,
        budgetMax,
        stage,
        source,
        aiConversionScore,
        createdAt,
        updatedAt,
      ];
}

class LeadActivityLogEntity extends Equatable {
  final String id;
  final String leadId;
  final String performedByUserId;
  final String activityType; // 'call_made', 'site_visit_done', 'note_added', 'stage_changed'
  final String note;
  final DateTime timestamp;

  const LeadActivityLogEntity({
    required this.id,
    required this.leadId,
    required this.performedByUserId,
    required this.activityType,
    required this.note,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, leadId, performedByUserId, activityType, note, timestamp];
}

class CRMTaskEntity extends Equatable {
  final String id;
  final String leadId;
  final String assignedToUserId;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;

  const CRMTaskEntity({
    required this.id,
    required this.leadId,
    required this.assignedToUserId,
    required this.title,
    required this.description,
    this.priority = TaskPriority.medium,
    required this.dueDate,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        leadId,
        assignedToUserId,
        title,
        description,
        priority,
        dueDate,
        isCompleted,
      ];
}

class BuilderProjectSalesEntity extends Equatable {
  final String projectId;
  final String projectName;
  final int totalUnits;
  final int availableUnits;
  final int bookedUnits;
  final int soldUnits;
  final double totalRevenueInr;

  const BuilderProjectSalesEntity({
    required this.projectId,
    required this.projectName,
    required this.totalUnits,
    required this.availableUnits,
    required this.bookedUnits,
    required this.soldUnits,
    required this.totalRevenueInr,
  });

  @override
  List<Object?> get props => [
        projectId,
        projectName,
        totalUnits,
        availableUnits,
        bookedUnits,
        soldUnits,
        totalRevenueInr,
      ];
}

class PerformanceAnalyticsEntity extends Equatable {
  final String userId; // Broker or Builder ID
  final int totalLeadsReceived;
  final int totalDealsClosed;
  final double conversionRate; // e.g. 18.5%
  final double totalSalesValue;

  const PerformanceAnalyticsEntity({
    required this.userId,
    required this.totalLeadsReceived,
    required this.totalDealsClosed,
    required this.conversionRate,
    required this.totalSalesValue,
  });

  @override
  List<Object?> get props => [
        userId,
        totalLeadsReceived,
        totalDealsClosed,
        conversionRate,
        totalSalesValue,
      ];
}
