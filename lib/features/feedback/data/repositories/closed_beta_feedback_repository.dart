import 'package:injectable/injectable.dart';
import '../../domain/entities/feedback_entities.dart';
import '../models/feedback_models.dart';

@lazySingleton
class ClosedBetaFeedbackRepository {
  final List<ClosedBetaFeedbackModel> _feedbackStore = [];

  Future<void> submitFeedback(ClosedBetaFeedbackModel feedback) async {
    _feedbackStore.add(feedback);
  }

  Future<List<ClosedBetaFeedbackModel>> getAllFeedback() async {
    return List.unmodifiable(_feedbackStore);
  }

  Future<bool> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus newStatus,
    String? founderNotes,
    bool? isDuplicate,
  }) async {
    final index = _feedbackStore.indexWhere((item) => item.id == feedbackId);
    if (index == -1) return false;

    final existing = _feedbackStore[index];
    if (!existing.canTransitionTo(newStatus)) return false;

    _feedbackStore[index] = ClosedBetaFeedbackModel(
      id: existing.id,
      category: existing.category,
      priority: existing.priority,
      status: newStatus,
      description: existing.description,
      appVersion: existing.appVersion,
      platform: existing.platform,
      timestamp: existing.timestamp,
      screenContext: existing.screenContext,
      founderNotes: founderNotes ?? existing.founderNotes,
      isDuplicate: isDuplicate ?? existing.isDuplicate,
    );
    return true;
  }
}
