import '../../domain/entities/crm_entities.dart';

class CRMLeadModel extends CRMLeadEntity {
  const CRMLeadModel({
    required super.id,
    required super.propertyId,
    required super.assignedToUserId,
    required super.buyerName,
    required super.buyerPhone,
    super.buyerEmail,
    required super.budgetMax,
    super.stage = KanbanStageEnum.newLead,
    super.source = LeadSource.websiteInquiry,
    super.aiConversionScore = 50.0,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CRMLeadModel.fromJson(Map<String, dynamic> json) {
    return CRMLeadModel(
      id: json['id'] as String? ?? '',
      propertyId: json['property_id'] as String? ?? '',
      assignedToUserId: json['assigned_to_user_id'] as String? ?? '',
      buyerName: json['buyer_name'] as String? ?? '',
      buyerPhone: json['buyer_phone'] as String? ?? '',
      buyerEmail: json['buyer_email'] as String?,
      budgetMax: (json['budget_max'] as num?)?.toDouble() ?? 0.0,
      stage: KanbanStageEnum.values.firstWhere(
        (e) => e.name == json['stage'],
        orElse: () => KanbanStageEnum.newLead,
      ),
      source: LeadSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => LeadSource.websiteInquiry,
      ),
      aiConversionScore: (json['ai_conversion_score'] as num?)?.toDouble() ?? 50.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'assigned_to_user_id': assignedToUserId,
        'buyer_name': buyerName,
        'buyer_phone': buyerPhone,
        'buyer_email': buyerEmail,
        'budget_max': budgetMax,
        'stage': stage.name,
        'source': source.name,
        'ai_conversion_score': aiConversionScore,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class LeadActivityLogModel extends LeadActivityLogEntity {
  const LeadActivityLogModel({
    required super.id,
    required super.leadId,
    required super.performedByUserId,
    required super.activityType,
    required super.note,
    required super.timestamp,
  });

  factory LeadActivityLogModel.fromJson(Map<String, dynamic> json) {
    return LeadActivityLogModel(
      id: json['id'] as String? ?? '',
      leadId: json['lead_id'] as String? ?? '',
      performedByUserId: json['performed_by_user_id'] as String? ?? '',
      activityType: json['activity_type'] as String? ?? 'note_added',
      note: json['note'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lead_id': leadId,
        'performed_by_user_id': performedByUserId,
        'activity_type': activityType,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };
}

class CRMTaskModel extends CRMTaskEntity {
  const CRMTaskModel({
    required super.id,
    required super.leadId,
    required super.assignedToUserId,
    required super.title,
    required super.description,
    super.priority = TaskPriority.medium,
    required super.dueDate,
    super.isCompleted = false,
  });

  factory CRMTaskModel.fromJson(Map<String, dynamic> json) {
    return CRMTaskModel(
      id: json['id'] as String? ?? '',
      leadId: json['lead_id'] as String? ?? '',
      assignedToUserId: json['assigned_to_user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : DateTime.now(),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lead_id': leadId,
        'assigned_to_user_id': assignedToUserId,
        'title': title,
        'description': description,
        'priority': priority.name,
        'due_date': dueDate.toIso8601String(),
        'is_completed': isCompleted,
      };
}

class BuilderProjectSalesModel extends BuilderProjectSalesEntity {
  const BuilderProjectSalesModel({
    required super.projectId,
    required super.projectName,
    required super.totalUnits,
    required super.availableUnits,
    required super.bookedUnits,
    required super.soldUnits,
    required super.totalRevenueInr,
  });

  factory BuilderProjectSalesModel.fromJson(Map<String, dynamic> json) {
    return BuilderProjectSalesModel(
      projectId: json['project_id'] as String? ?? '',
      projectName: json['project_name'] as String? ?? '',
      totalUnits: json['total_units'] as int? ?? 0,
      availableUnits: json['available_units'] as int? ?? 0,
      bookedUnits: json['booked_units'] as int? ?? 0,
      soldUnits: json['sold_units'] as int? ?? 0,
      totalRevenueInr: (json['total_revenue_inr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'project_name': projectName,
        'total_units': totalUnits,
        'available_units': availableUnits,
        'booked_units': bookedUnits,
        'sold_units': soldUnits,
        'total_revenue_inr': totalRevenueInr,
      };
}

class PerformanceAnalyticsModel extends PerformanceAnalyticsEntity {
  const PerformanceAnalyticsModel({
    required super.userId,
    required super.totalLeadsReceived,
    required super.totalDealsClosed,
    required super.conversionRate,
    required super.totalSalesValue,
  });

  factory PerformanceAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return PerformanceAnalyticsModel(
      userId: json['user_id'] as String? ?? '',
      totalLeadsReceived: json['total_leads_received'] as int? ?? 0,
      totalDealsClosed: json['total_deals_closed'] as int? ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0.0,
      totalSalesValue: (json['total_sales_value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'total_leads_received': totalLeadsReceived,
        'total_deals_closed': totalDealsClosed,
        'conversion_rate': conversionRate,
        'total_sales_value': totalSalesValue,
      };
}
