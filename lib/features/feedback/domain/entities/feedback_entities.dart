import 'package:equatable/equatable.dart';

enum FeedbackCategory {
  bug,
  uiUxIssue,
  propertyListingIssue,
  searchDiscoveryIssue,
  performanceIssue,
  authenticationIssue,
  paymentSubscriptionIssue,
  moderationIssue,
  disputeIssue,
  featureRequest,
  other,
}

enum FeedbackPriority {
  low,
  medium,
  high,
  critical,
}

enum FeedbackStatus {
  newFeedback,
  acknowledged,
  investigating,
  planned,
  inProgress,
  resolved,
  rejected,
}

class ClosedBetaFeedbackEntity extends Equatable {
  final String id;
  final FeedbackCategory category;
  final FeedbackPriority priority;
  final FeedbackStatus status;
  final String description;
  final String appVersion;
  final String platform;
  final DateTime timestamp;
  final String? screenContext;
  final String? founderNotes;
  final bool isDuplicate;

  const ClosedBetaFeedbackEntity({
    required this.id,
    required this.category,
    required this.priority,
    required this.status,
    required this.description,
    required this.appVersion,
    required this.platform,
    required this.timestamp,
    this.screenContext,
    this.founderNotes,
    this.isDuplicate = false,
  });

  bool canTransitionTo(FeedbackStatus newStatus) {
    if (status == newStatus) return true;
    if (status == FeedbackStatus.resolved && newStatus == FeedbackStatus.newFeedback) {
      return false;
    }
    return true;
  }

  ClosedBetaFeedbackEntity copyWith({
    FeedbackStatus? status,
    FeedbackPriority? priority,
    String? founderNotes,
    bool? isDuplicate,
  }) {
    return ClosedBetaFeedbackEntity(
      id: id,
      category: category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      description: description,
      appVersion: appVersion,
      platform: platform,
      timestamp: timestamp,
      screenContext: screenContext,
      founderNotes: founderNotes ?? this.founderNotes,
      isDuplicate: isDuplicate ?? this.isDuplicate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        priority,
        status,
        description,
        appVersion,
        platform,
        timestamp,
        screenContext,
        founderNotes,
        isDuplicate,
      ];
}
