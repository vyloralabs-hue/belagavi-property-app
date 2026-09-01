import '../domain/entities/monetization_entities.dart';

class SubscriptionFeatureGate {
  SubscriptionFeatureGate._();

  /// Validates if user can post a new property under current plan limits
  static bool canPostProperty(UserSubscriptionEntity subscription, SubscriptionPlanEntity plan) {
    if (!subscription.isActive) return false;
    return subscription.usedListingQuota < plan.maxActiveListings;
  }

  /// Validates if user can request an AI property description generation
  static bool canUseAiGeneration(UserSubscriptionEntity subscription, SubscriptionPlanEntity plan) {
    if (!subscription.isActive) return false;
    return subscription.usedAiGenerations < plan.aiGenerationsPerMonth;
  }

  /// Validates if user has CRM & Lead Pipeline access
  static bool hasCrmAccess(SubscriptionPlanEntity plan) => plan.hasCrmAccess;

  /// Validates if user has Analytics access
  static bool hasAnalyticsAccess(SubscriptionPlanEntity plan) => plan.hasAnalyticsAccess;
}
