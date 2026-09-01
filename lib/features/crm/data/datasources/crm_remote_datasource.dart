import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/crm_entities.dart';
import '../models/crm_models.dart';

abstract class CRMRemoteDataSource {
  Future<List<CRMLeadModel>> fetchLeadsForUser(String userId);
  Future<CRMLeadModel> updateLeadStage({
    required String leadId,
    required KanbanStageEnum newStage,
  });
  Future<CRMLeadModel> createLead(CRMLeadModel lead);
  Future<LeadActivityLogModel> logActivity(LeadActivityLogModel activity);
  Future<List<CRMTaskModel>> fetchTasksForUser(String userId);
  Future<CRMTaskModel> createTask(CRMTaskModel task);
  Future<BuilderProjectSalesModel> fetchProjectSalesMetrics(String projectId);
  Future<PerformanceAnalyticsModel> fetchPerformanceAnalytics(String userId);
}

@LazySingleton(as: CRMRemoteDataSource)
class CRMRemoteDataSourceImpl extends BaseRemoteDataSource implements CRMRemoteDataSource {
  final SupabaseService _supabaseService;

  CRMRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<List<CRMLeadModel>> fetchLeadsForUser(String userId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockLeads;
      }
      final response = await _supabaseService
          .from('leads')
          .select()
          .eq('assigned_to_user_id', userId);
      return (response as List).map((json) => CRMLeadModel.fromJson(json)).toList();
    });
  }

  @override
  Future<CRMLeadModel> updateLeadStage({
    required String leadId,
    required KanbanStageEnum newStage,
  }) async {
    return safeQuery(() async {
      final current = _mockLeads.firstWhere((l) => l.id == leadId, orElse: () => _mockLeads.first);
      final updated = CRMLeadModel(
        id: current.id,
        propertyId: current.propertyId,
        assignedToUserId: current.assignedToUserId,
        buyerName: current.buyerName,
        buyerPhone: current.buyerPhone,
        buyerEmail: current.buyerEmail,
        budgetMax: current.budgetMax,
        stage: newStage,
        source: current.source,
        aiConversionScore: current.aiConversionScore,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );

      if (!_supabaseService.isInitialized) return updated;

      final response = await _supabaseService
          .from('leads')
          .update({'stage': newStage.name})
          .eq('id', leadId)
          .select()
          .single();
      return CRMLeadModel.fromJson(response);
    });
  }

  @override
  Future<CRMLeadModel> createLead(CRMLeadModel lead) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return lead;
      final response =
          await _supabaseService.from('leads').insert(lead.toJson()).select().single();
      return CRMLeadModel.fromJson(response);
    });
  }

  @override
  Future<LeadActivityLogModel> logActivity(LeadActivityLogModel activity) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return activity;
      final response = await _supabaseService
          .from('lead_activity_logs')
          .insert(activity.toJson())
          .select()
          .single();
      return LeadActivityLogModel.fromJson(response);
    });
  }

  @override
  Future<List<CRMTaskModel>> fetchTasksForUser(String userId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return const [];
      final response = await _supabaseService
          .from('crm_tasks')
          .select()
          .eq('assigned_to_user_id', userId);
      return (response as List).map((json) => CRMTaskModel.fromJson(json)).toList();
    });
  }

  @override
  Future<CRMTaskModel> createTask(CRMTaskModel task) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return task;
      final response =
          await _supabaseService.from('crm_tasks').insert(task.toJson()).select().single();
      return CRMTaskModel.fromJson(response);
    });
  }

  @override
  Future<BuilderProjectSalesModel> fetchProjectSalesMetrics(String projectId) async {
    return safeQuery(() async {
      return BuilderProjectSalesModel(
        projectId: projectId,
        projectName: 'PropertyHub Grand Residency',
        totalUnits: 120,
        availableUnits: 34,
        bookedUnits: 16,
        soldUnits: 70,
        totalRevenueInr: 525000000.0,
      );
    });
  }

  @override
  Future<PerformanceAnalyticsModel> fetchPerformanceAnalytics(String userId) async {
    return safeQuery(() async {
      return PerformanceAnalyticsModel(
        userId: userId,
        totalLeadsReceived: 45,
        totalDealsClosed: 8,
        conversionRate: 17.7,
        totalSalesValue: 64000000.0,
      );
    });
  }

  static final _mockLeads = [
    CRMLeadModel(
      id: 'lead_001',
      propertyId: 'prop_001',
      assignedToUserId: 'usr_broker_1',
      buyerName: 'Rahul Patil',
      buyerPhone: '+919876543210',
      buyerEmail: 'rahul.patil@example.com',
      budgetMax: 8000000.0,
      stage: KanbanStageEnum.siteVisitScheduled,
      source: LeadSource.websiteInquiry,
      aiConversionScore: 85.5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CRMLeadModel(
      id: 'lead_002',
      propertyId: 'prop_003',
      assignedToUserId: 'usr_broker_1',
      buyerName: 'Amit Deshmukh',
      buyerPhone: '+919812345678',
      budgetMax: 5000000.0,
      stage: KanbanStageEnum.newLead,
      source: LeadSource.whatsappCall,
      aiConversionScore: 62.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}
