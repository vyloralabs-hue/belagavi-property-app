import '../../domain/entities/monetization_entities.dart';

class SubscriptionPlanModel extends SubscriptionPlanEntity {
  const SubscriptionPlanModel({
    required super.id,
    required super.tier,
    required super.name,
    required super.description,
    required super.priceInr,
    required super.priceUsd,
    required super.cycle,
    required super.maxActiveListings,
    required super.featuredListingSlots,
    required super.teamSeats,
    required super.aiGenerationsPerMonth,
    super.hasCrmAccess = false,
    super.hasAnalyticsAccess = false,
    super.hasLegalAssistance = false,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String? ?? '',
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceInr: (json['price_inr'] as num?)?.toDouble() ?? 0.0,
      priceUsd: (json['price_usd'] as num?)?.toDouble() ?? 0.0,
      cycle: BillingCycle.values.firstWhere(
        (e) => e.name == json['cycle'],
        orElse: () => BillingCycle.monthly,
      ),
      maxActiveListings: json['max_active_listings'] as int? ?? 1,
      featuredListingSlots: json['featured_listing_slots'] as int? ?? 0,
      teamSeats: json['team_seats'] as int? ?? 0,
      aiGenerationsPerMonth: json['ai_generations_per_month'] as int? ?? 1,
      hasCrmAccess: json['has_crm_access'] as bool? ?? false,
      hasAnalyticsAccess: json['has_analytics_access'] as bool? ?? false,
      hasLegalAssistance: json['has_legal_assistance'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tier': tier.name,
        'name': name,
        'description': description,
        'price_inr': priceInr,
        'price_usd': priceUsd,
        'cycle': cycle.name,
        'max_active_listings': maxActiveListings,
        'featured_listing_slots': featuredListingSlots,
        'team_seats': teamSeats,
        'ai_generations_per_month': aiGenerationsPerMonth,
        'has_crm_access': hasCrmAccess,
        'has_analytics_access': hasAnalyticsAccess,
        'has_legal_assistance': hasLegalAssistance,
      };
}

class UserSubscriptionModel extends UserSubscriptionEntity {
  const UserSubscriptionModel({
    required super.id,
    required super.userId,
    required super.planId,
    required super.tier,
    required super.startDate,
    required super.endDate,
    super.autoRenew = true,
    super.usedListingQuota = 0,
    super.usedFeaturedSlots = 0,
    super.usedAiGenerations = 0,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      autoRenew: json['auto_renew'] as bool? ?? true,
      usedListingQuota: json['used_listing_quota'] as int? ?? 0,
      usedFeaturedSlots: json['used_featured_slots'] as int? ?? 0,
      usedAiGenerations: json['used_ai_generations'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'plan_id': planId,
        'tier': tier.name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'auto_renew': autoRenew,
        'used_listing_quota': usedListingQuota,
        'used_featured_slots': usedFeaturedSlots,
        'used_ai_generations': usedAiGenerations,
      };
}

class AddOnPackageModel extends AddOnPackageEntity {
  const AddOnPackageModel({
    required super.id,
    required super.name,
    required super.description,
    required super.priceInr,
    required super.packageType,
  });

  factory AddOnPackageModel.fromJson(Map<String, dynamic> json) {
    return AddOnPackageModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceInr: (json['price_inr'] as num?)?.toDouble() ?? 0.0,
      packageType: json['package_type'] as String? ?? 'featured_boost',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price_inr': priceInr,
        'package_type': packageType,
      };
}

class PaymentTransactionModel extends PaymentTransactionEntity {
  const PaymentTransactionModel({
    required super.id,
    required super.userId,
    required super.paymentId,
    required super.orderId,
    required super.amount,
    required super.currency,
    required super.status,
    required super.paymentProvider,
    required super.createdAt,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      paymentId: json['payment_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.completed,
      ),
      paymentProvider: json['payment_provider'] as String? ?? 'razorpay',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'payment_id': paymentId,
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'status': status.name,
        'payment_provider': paymentProvider,
        'created_at': createdAt.toIso8601String(),
      };
}
