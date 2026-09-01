import '../../../../core/utils/typedefs.dart';
import '../entities/crm_entities.dart';

abstract class CRMRepository {
  FutureEither<List<CRMLeadEntity>> getLeadsForUser(String userId);

  FutureEither<CRMLeadEntity> updateLeadStage({
    required String leadId,
    required KanbanStageEnum newStage,
  });

  FutureEither<CRMLeadEntity> createLead(CRMLeadEntity lead);

  FutureEither<LeadActivityLogEntity> logActivity(LeadActivityLogEntity activity);

  FutureEither<List<CRMTaskEntity>> getTasksForUser(String userId);

  FutureEither<CRMTaskEntity> createTask(CRMTaskEntity task);

  FutureEither<BuilderProjectSalesEntity> getProjectSalesMetrics(String projectId);

  FutureEither<PerformanceAnalyticsEntity> getPerformanceAnalytics(String userId);
}
