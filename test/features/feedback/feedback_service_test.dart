import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/feedback/domain/entities/feedback_entities.dart';
import 'package:belagavi_property/features/feedback/data/models/feedback_models.dart';
import 'package:belagavi_property/features/feedback/data/repositories/closed_beta_feedback_repository.dart';

void main() {
  late ClosedBetaFeedbackRepository repository;

  setUp(() {
    repository = ClosedBetaFeedbackRepository();
  });

  group('Phase 13 Closed Beta Feedback Tests', () {
    test('Feedback model serialization and deserialization', () {
      final feedback = ClosedBetaFeedbackModel(
        id: 'fb_101',
        category: FeedbackCategory.uiUxIssue,
        priority: FeedbackPriority.high,
        status: FeedbackStatus.newFeedback,
        description: 'Button alignment issue on search screen',
        appVersion: '1.0.50+50',
        platform: 'android',
        timestamp: DateTime(2026, 8, 16, 11, 0, 0),
        screenContext: 'PropertySearchView',
      );

      final json = feedback.toJson();
      expect(json['id'], equals('fb_101'));
      expect(json['category'], equals('uiUxIssue'));
      expect(json['priority'], equals('high'));

      final restored = ClosedBetaFeedbackModel.fromJson(json);
      expect(restored.id, equals(feedback.id));
      expect(restored.category, equals(feedback.category));
      expect(restored.priority, equals(feedback.priority));
    });

    test('Feedback status transition validation rules', () {
      final feedback = ClosedBetaFeedbackEntity(
        id: 'fb_102',
        category: FeedbackCategory.bug,
        priority: FeedbackPriority.critical,
        status: FeedbackStatus.resolved,
        description: 'Crash on app launch',
        appVersion: '1.0.50+50',
        platform: 'android',
        timestamp: DateTime.now(),
      );

      // Cannot revert from resolved directly to newFeedback
      expect(feedback.canTransitionTo(FeedbackStatus.newFeedback), isFalse);
      // Can transition to investigating or inProgress
      expect(feedback.canTransitionTo(FeedbackStatus.investigating), isTrue);
    });

    test('Repository submits and updates feedback cleanly', () async {
      final feedback = ClosedBetaFeedbackModel(
        id: 'fb_103',
        category: FeedbackCategory.featureRequest,
        priority: FeedbackPriority.low,
        status: FeedbackStatus.newFeedback,
        description: 'Add dark mode toggle',
        appVersion: '1.0.50+50',
        platform: 'android',
        timestamp: DateTime.now(),
      );

      await repository.submitFeedback(feedback);
      final all = await repository.getAllFeedback();
      expect(all.length, equals(1));
      expect(all.first.id, equals('fb_103'));

      final updated = await repository.updateFeedbackStatus(
        feedbackId: 'fb_103',
        newStatus: FeedbackStatus.inProgress,
        founderNotes: 'Scheduled for Phase 14',
      );
      expect(updated, isTrue);

      final reFetched = await repository.getAllFeedback();
      expect(reFetched.first.status, equals(FeedbackStatus.inProgress));
      expect(reFetched.first.founderNotes, equals('Scheduled for Phase 14'));
    });
  });
}
