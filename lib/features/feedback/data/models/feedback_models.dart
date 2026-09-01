import '../../domain/entities/feedback_entities.dart';

class ClosedBetaFeedbackModel extends ClosedBetaFeedbackEntity {
  const ClosedBetaFeedbackModel({
    required super.id,
    required super.category,
    required super.priority,
    required super.status,
    required super.description,
    required super.appVersion,
    required super.platform,
    required super.timestamp,
    super.screenContext,
    super.founderNotes,
    super.isDuplicate = false,
  });

  factory ClosedBetaFeedbackModel.fromJson(Map<String, dynamic> json) {
    return ClosedBetaFeedbackModel(
      id: json['id'] as String? ?? '',
      category: FeedbackCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FeedbackCategory.other,
      ),
      priority: FeedbackPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => FeedbackPriority.medium,
      ),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FeedbackStatus.newFeedback,
      ),
      description: json['description'] as String? ?? '',
      appVersion: json['app_version'] as String? ?? '1.0.50+50',
      platform: json['platform'] as String? ?? 'android',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      screenContext: json['screen_context'] as String?,
      founderNotes: json['founder_notes'] as String?,
      isDuplicate: json['is_duplicate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'priority': priority.name,
        'status': status.name,
        'description': description,
        'app_version': appVersion,
        'platform': platform,
        'timestamp': timestamp.toIso8601String(),
        'screen_context': screenContext,
        'founder_notes': founderNotes,
        'is_duplicate': isDuplicate,
      };
}
