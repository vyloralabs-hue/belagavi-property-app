import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/crm_entities.dart';
import '../../domain/repositories/crm_repository.dart';
import '../datasources/crm_remote_datasource.dart';
import '../models/crm_models.dart';

@LazySingleton(as: CRMRepository)
class CRMRepositoryImpl extends BaseRepository implements CRMRepository {
  final CRMRemoteDataSource _remoteDataSource;

  CRMRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<CRMLeadEntity>> getLeadsForUser(String userId) async {
    return safeCall(() => _remoteDataSource.fetchLeadsForUser(userId));
  }

  @override
  FutureEither<CRMLeadEntity> updateLeadStage({
    required String leadId,
    required KanbanStageEnum newStage,
  }) async {
    return safeCall(
      () => _remoteDataSource.updateLeadStage(
        leadId: leadId,
        newStage: newStage,
      ),
    );
  }

  @override
  FutureEither<CRMLeadEntity> createLead(CRMLeadEntity lead) async {
    return safeCall(() async {
      final model = CRMLeadModel(
        id: lead.id,
        propertyId: lead.propertyId,
        assignedToUserId: lead.assignedToUserId,
        buyerName: lead.buyerName,
        buyerPhone: lead.buyerPhone,
        buyerEmail: lead.buyerEmail,
        budgetMax: lead.budgetMax,
        stage: lead.stage,
        source: lead.source,
        aiConversionScore: lead.aiConversionScore,
        createdAt: lead.createdAt,
        updatedAt: lead.updatedAt,
      );
      return await _remoteDataSource.createLead(model);
    });
  }

  @override
  FutureEither<LeadActivityLogEntity> logActivity(LeadActivityLogEntity activity) async {
    return safeCall(() async {
      final model = LeadActivityLogModel(
        id: activity.id,
        leadId: activity.leadId,
        performedByUserId: activity.performedByUserId,
        activityType: activity.activityType,
        note: activity.note,
        timestamp: activity.timestamp,
      );
      return await _remoteDataSource.logActivity(model);
    });
  }

  @override
  FutureEither<List<CRMTaskEntity>> getTasksForUser(String userId) async {
    return safeCall(() => _remoteDataSource.fetchTasksForUser(userId));
  }

  @override
  FutureEither<CRMTaskEntity> createTask(CRMTaskEntity task) async {
    return safeCall(() async {
      final model = CRMTaskModel(
        id: task.id,
        leadId: task.leadId,
        assignedToUserId: task.assignedToUserId,
        title: task.title,
        description: task.description,
        priority: task.priority,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted,
      );
      return await _remoteDataSource.createTask(model);
    });
  }

  @override
  FutureEither<BuilderProjectSalesEntity> getProjectSalesMetrics(String projectId) async {
    return safeCall(() => _remoteDataSource.fetchProjectSalesMetrics(projectId));
  }

  @override
  FutureEither<PerformanceAnalyticsEntity> getPerformanceAnalytics(String userId) async {
    return safeCall(() => _remoteDataSource.fetchPerformanceAnalytics(userId));
  }
}
