import '../domain/entities/crm_entities.dart';

class KanbanPipelineStateMachine {
  KanbanPipelineStateMachine._();

  /// Validates stage transitions for lead Kanban pipeline
  static bool canTransition({
    required KanbanStageEnum currentStage,
    required KanbanStageEnum targetStage,
  }) {
    if (currentStage == targetStage) return true;

    return switch (currentStage) {
      KanbanStageEnum.newLead => targetStage == KanbanStageEnum.contacted ||
          targetStage == KanbanStageEnum.closedLost,
      KanbanStageEnum.contacted => targetStage == KanbanStageEnum.siteVisitScheduled ||
          targetStage == KanbanStageEnum.closedLost,
      KanbanStageEnum.siteVisitScheduled => targetStage == KanbanStageEnum.negotiation ||
          targetStage == KanbanStageEnum.closedLost,
      KanbanStageEnum.negotiation => targetStage == KanbanStageEnum.closedWon ||
          targetStage == KanbanStageEnum.closedLost,
      KanbanStageEnum.closedWon => false,
      KanbanStageEnum.closedLost => targetStage == KanbanStageEnum.contacted,
    };
  }
}
