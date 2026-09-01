import '../domain/entities/crm_entities.dart';

class AILeadScoringEngine {
  AILeadScoringEngine._();

  /// Calculates AI lead conversion probability score (0.0 to 100.0)
  static double calculateScore(CRMLeadEntity lead) {
    double score = 50.0;
    if (lead.buyerEmail != null && lead.buyerEmail!.isNotEmpty) score += 10.0;
    if (lead.budgetMax >= 5000000) score += 15.0;

    score += switch (lead.stage) {
      KanbanStageEnum.newLead => 0.0,
      KanbanStageEnum.contacted => 10.0,
      KanbanStageEnum.siteVisitScheduled => 25.0,
      KanbanStageEnum.negotiation => 35.0,
      KanbanStageEnum.closedWon => 50.0,
      KanbanStageEnum.closedLost => -40.0,
    };

    return score.clamp(0.0, 100.0);
  }
}
