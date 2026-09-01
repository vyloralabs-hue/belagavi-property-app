import 'package:equatable/equatable.dart';

enum SubscriptionTier { free, premiumSeller, brokerPro, builderPro, enterpriseBuilder }

enum BillingCycle { monthly, quarterly, annual }

enum PaymentStatus { pending, completed, failed, refunded }

class SubscriptionPlanEntity extends Equatable {
  final String id;
  final SubscriptionTier tier;
  final String name;
  final String description;
  final double priceInr;
  final double priceUsd;
  final BillingCycle cycle;
  final int maxActiveListings;
  final int featuredListingSlots;
  final int teamSeats;
  final int aiGenerationsPerMonth;
  final bool hasCrmAccess;
  final bool hasAnalyticsAccess;
  final bool hasLegalAssistance;

  const SubscriptionPlanEntity({
    required this.id,
    required this.tier,
    required this.name,
    required this.description,
    required this.priceInr,
    required this.priceUsd,
    required this.cycle,
    required this.maxActiveListings,
    required this.featuredListingSlots,
    required this.teamSeats,
    required this.aiGenerationsPerMonth,
    this.hasCrmAccess = false,
    this.hasAnalyticsAccess = false,
    this.hasLegalAssistance = false,
  });

  @override
  List<Object?> get props => [
        id,
        tier,
        name,
        description,
        priceInr,
        priceUsd,
        cycle,
        maxActiveListings,
        featuredListingSlots,
        teamSeats,
        aiGenerationsPerMonth,
        hasCrmAccess,
        hasAnalyticsAccess,
        hasLegalAssistance,
      ];
}

class UserSubscriptionEntity extends Equatable {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionTier tier;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final int usedListingQuota;
  final int usedFeaturedSlots;
  final int usedAiGenerations;

  const UserSubscriptionEntity({
    required this.id,
    required this.userId,
    required this.planId,
    required this.tier,
    required this.startDate,
    required this.endDate,
    this.autoRenew = true,
    this.usedListingQuota = 0,
    this.usedFeaturedSlots = 0,
    this.usedAiGenerations = 0,
  });

  bool get isActive => DateTime.now().isBefore(endDate);

  @override
  List<Object?> get props => [
        id,
        userId,
        planId,
        tier,
        startDate,
        endDate,
        autoRenew,
        usedListingQuota,
        usedFeaturedSlots,
        usedAiGenerations,
      ];
}

class AddOnPackageEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double priceInr;
  final String packageType; // 'featured_boost', 'ai_unlimited', 'legal_package', 'banner_ad'

  const AddOnPackageEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.priceInr,
    required this.packageType,
  });

  @override
  List<Object?> get props => [id, name, description, priceInr, packageType];
}

class PaymentTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String paymentId; // Provider reference ID
  final String orderId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String paymentProvider; // 'razorpay', 'stripe'
  final DateTime createdAt;

  const PaymentTransactionEntity({
    required this.id,
    required this.userId,
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentProvider,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        paymentId,
        orderId,
        amount,
        currency,
        status,
        paymentProvider,
        createdAt,
      ];
}
