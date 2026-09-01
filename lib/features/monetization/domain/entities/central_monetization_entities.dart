import 'package:equatable/equatable.dart';

enum ProductType { property, shop, builder, broker, ad, subscription, premium }

enum ProductCategory {
  consumerProperty,
  builderProject,
  landDeveloperProject,
  brokerService,
  localShop,
  promotionAddon,
  advertisement,
}

enum ListingCategoryMode { free, paid, freemium }

enum PaymentLifecycleState {
  created,
  initiated,
  pending,
  authorized,
  captured,
  success,
  failed,
  cancelled,
  expired,
  refunded,
  partiallyRefunded,
  disputed,
  verificationRequired,
}

enum OrderLifecycleState {
  draft,
  created,
  paymentPending,
  paymentProcessing,
  paymentSuccess,
  paymentFailed,
  paymentCancelled,
  fulfilled,
  refundPending,
  refunded,
  partiallyRefunded,
  disputed,
  expired,
}

enum SubscriptionLifecycleState {
  active,
  expiring,
  expired,
  cancelled,
  paymentFailed,
  gracePeriod,
}

enum RefundLifecycleState {
  requested,
  processing,
  success,
  failed,
  rejected,
}

enum BillingCycleType { free, monthly, yearly, oneTime }

enum PremiumBoostType {
  freeListing,
  featuredListing,
  topPlacement,
  verifiedBusiness,
  premiumBusiness,
  boostedSearchVisibility,
  promotedProperty,
  promotedShop,
}

enum AdPlacementType {
  homeFeed,
  propertySearch,
  propertyDetails,
  shopSearch,
  shopDetails,
  locationDiscovery,
  unifiedSearch,
  contentFeed,
}

enum AdProviderType { adMob, adManager, directSponsor }

enum DirectAdProductType {
  localSponsoredAd,
  featuredShop,
  featuredProperty,
  areaPromotion,
  categoryPromotion,
}

class PricingPlanEntity extends Equatable {
  final String planId;
  final ProductType productType;
  final String planName;
  final BillingCycleType billingCycle;
  final int amountInPaise;
  final String currency;
  final int discountAmountInPaise;
  final int taxAmountInPaise;
  final int finalAmountInPaise;
  final int durationDays;
  final int listingLimit;
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;

  PricingPlanEntity({
    required this.planId,
    required this.productType,
    required this.planName,
    required this.billingCycle,
    int? amountInPaise,
    double? amount,
    this.currency = 'INR',
    int? discountAmountInPaise,
    double? discountAmount,
    int? taxAmountInPaise,
    double? taxAmount,
    int? finalAmountInPaise,
    double? finalAmount,
    required this.durationDays,
    this.listingLimit = 1,
    this.isActive = true,
    required this.effectiveFrom,
    this.effectiveUntil,
  })  : amountInPaise = amountInPaise ?? (amount != null ? (amount * 100).round() : 0),
        discountAmountInPaise = discountAmountInPaise ?? (discountAmount != null ? (discountAmount * 100).round() : 0),
        taxAmountInPaise = taxAmountInPaise ?? (taxAmount != null ? (taxAmount * 100).round() : 0),
        finalAmountInPaise = finalAmountInPaise ?? (finalAmount != null ? (finalAmount * 100).round() : (amountInPaise ?? (amount != null ? (amount * 100).round() : 0)));

  double get amount => amountInPaise / 100.0;
  double get amountInRupees => amount;
  double get discountAmount => discountAmountInPaise / 100.0;
  double get taxAmount => taxAmountInPaise / 100.0;
  double get finalAmount => finalAmountInPaise / 100.0;
  double get finalAmountInRupees => finalAmount;

  static PricingPlanEntity get propertyBasicFree => PricingPlanEntity(
        planId: 'plan_prop_free',
        productType: ProductType.property,
        planName: 'Property Basic Free Listing',
        billingCycle: BillingCycleType.free,
        amountInPaise: 0,
        finalAmountInPaise: 0,
        durationDays: 3650,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get localShopFree => PricingPlanEntity(
        planId: 'plan_shop_free',
        productType: ProductType.shop,
        planName: 'Local Shop Basic Free Listing',
        billingCycle: BillingCycleType.free,
        amountInPaise: 0,
        finalAmountInPaise: 0,
        durationDays: 3650,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get localShopMonthly => PricingPlanEntity(
        planId: 'plan_shop_monthly',
        productType: ProductType.shop,
        planName: 'Local Shop Monthly Premium',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 50000, // ₹500
        finalAmountInPaise: 50000,
        durationDays: 30,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get localShopYearly => PricingPlanEntity(
        planId: 'plan_shop_yearly',
        productType: ProductType.shop,
        planName: 'Local Shop Yearly Premium (Save ₹1,000)',
        billingCycle: BillingCycleType.yearly,
        amountInPaise: 500000, // ₹5,000
        discountAmountInPaise: 100000, // Save ₹1,000 vs 12x ₹500
        finalAmountInPaise: 500000,
        durationDays: 365,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get builderStarterMonthly => PricingPlanEntity(
        planId: 'plan_builder_starter_1999',
        productType: ProductType.builder,
        planName: 'Builder Starter Plan',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 199900, // ₹1,999
        finalAmountInPaise: 199900,
        durationDays: 30,
        listingLimit: 3,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get builderProMonthly => PricingPlanEntity(
        planId: 'plan_builder_pro_3999',
        productType: ProductType.builder,
        planName: 'Builder Pro Plan',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 399900, // ₹3,999
        finalAmountInPaise: 399900,
        durationDays: 30,
        listingLimit: 10,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get builderPremiumMonthly => PricingPlanEntity(
        planId: 'plan_builder_premium_6999',
        productType: ProductType.builder,
        planName: 'Builder Premium Plan',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 699900, // ₹6,999
        finalAmountInPaise: 699900,
        durationDays: 30,
        listingLimit: 30,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get landDeveloperStarterMonthly => PricingPlanEntity(
        planId: 'plan_land_dev_starter_1999',
        productType: ProductType.builder,
        planName: 'Land Developer Starter Plan',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 199900, // ₹1,999
        finalAmountInPaise: 199900,
        durationDays: 30,
        listingLimit: 3,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get landDeveloperProMonthly => PricingPlanEntity(
        planId: 'plan_land_dev_pro_3999',
        productType: ProductType.builder,
        planName: 'Land Developer Pro Plan',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 399900, // ₹3,999
        finalAmountInPaise: 399900,
        durationDays: 30,
        listingLimit: 10,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get landDeveloperPremiumMonthly => PricingPlanEntity(
        planId: 'plan_land_dev_premium_6999',
        productType: ProductType.builder,
        planName: 'Land Developer Premium Plan',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 699900, // ₹6,999
        finalAmountInPaise: 699900,
        durationDays: 30,
        listingLimit: 30,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get builderProConfigurable => PricingPlanEntity(
        planId: 'plan_builder_pro',
        productType: ProductType.builder,
        planName: 'Builder Pro Enterprise Tier',
        billingCycle: BillingCycleType.yearly,
        amountInPaise: 2500000, // ₹25,000
        finalAmountInPaise: 2500000,
        durationDays: 365,
        listingLimit: 50,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  static PricingPlanEntity get brokerProConfigurable => PricingPlanEntity(
        planId: 'plan_broker_pro',
        productType: ProductType.broker,
        planName: 'Broker Pro Agent Tier',
        billingCycle: BillingCycleType.monthly,
        amountInPaise: 150000, // ₹1,500
        finalAmountInPaise: 150000,
        durationDays: 30,
        listingLimit: 15,
        effectiveFrom: DateTime(2026, 1, 1),
      );

  @override
  List<Object?> get props => [
        planId,
        productType,
        planName,
        billingCycle,
        amountInPaise,
        currency,
        discountAmountInPaise,
        taxAmountInPaise,
        finalAmountInPaise,
        durationDays,
        listingLimit,
        isActive,
        effectiveFrom,
        effectiveUntil,
      ];
}

class EntitlementEntity extends Equatable {
  final String id;
  final String userId;
  final ProductType productType;
  final PremiumBoostType boostType;
  final String referenceEntityId;
  final String planId;
  final bool isActive;
  final int priorityScore;
  final DateTime grantedAt;
  final DateTime expiresAt;

  const EntitlementEntity({
    required this.id,
    required this.userId,
    required this.productType,
    this.boostType = PremiumBoostType.freeListing,
    required this.referenceEntityId,
    required this.planId,
    this.isActive = true,
    this.priorityScore = 0,
    required this.grantedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
        id,
        userId,
        productType,
        boostType,
        referenceEntityId,
        planId,
        isActive,
        priorityScore,
        grantedAt,
        expiresAt,
      ];
}

class RefundEntity extends Equatable {
  final String refundId;
  final String paymentId;
  final int amountInPaise;
  final String refundType; // 'FULL', 'PARTIAL'
  final RefundLifecycleState state;
  final String reason;
  final DateTime createdAt;

  RefundEntity({
    required this.refundId,
    required this.paymentId,
    int? amountInPaise,
    double? amount,
    required this.refundType,
    this.state = RefundLifecycleState.requested,
    required this.reason,
    required this.createdAt,
  }) : amountInPaise = amountInPaise ?? (amount != null ? (amount * 100).round() : 0);

  double get amount => amountInPaise / 100.0;
  double get amountInRupees => amount;

  @override
  List<Object?> get props => [refundId, paymentId, amountInPaise, refundType, state, reason, createdAt];
}

class FinancialAuditLogEntity extends Equatable {
  final String id;
  final String actorId;
  final String actorRole;
  final String action;
  final String entityType;
  final String entityId;
  final String previousState;
  final String newState;
  final int amountInPaise;
  final String currency;
  final String reason;
  final DateTime timestamp;

  const FinancialAuditLogEntity({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.previousState,
    required this.newState,
    this.amountInPaise = 0,
    this.currency = 'INR',
    required this.reason,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        actorId,
        actorRole,
        action,
        entityType,
        entityId,
        previousState,
        newState,
        amountInPaise,
        currency,
        reason,
        timestamp,
      ];
}

class AdPlacementEntity extends Equatable {
  final String id;
  final AdPlacementType placementType;
  final AdProviderType providerType;
  final bool isEnabled;
  final int refreshRateSeconds;

  const AdPlacementEntity({
    required this.id,
    required this.placementType,
    required this.providerType,
    this.isEnabled = true,
    this.refreshRateSeconds = 30,
  });

  @override
  List<Object?> get props => [id, placementType, providerType, isEnabled, refreshRateSeconds];
}

class AdRevenueEventEntity extends Equatable {
  final String id;
  final AdPlacementType placementType;
  final AdProviderType providerType;
  final String eventType; // 'IMPRESSION', 'CLICK'
  final double estimatedRevenueInr;
  final DateTime timestamp;

  const AdRevenueEventEntity({
    required this.id,
    required this.placementType,
    required this.providerType,
    required this.eventType,
    required this.estimatedRevenueInr,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, placementType, providerType, eventType, estimatedRevenueInr, timestamp];
}

class PaymentStateTransitionValidator {
  static bool isValidTransition(PaymentLifecycleState from, PaymentLifecycleState to) {
    if (from == to) return true;

    switch (from) {
      case PaymentLifecycleState.created:
        return to == PaymentLifecycleState.initiated || to == PaymentLifecycleState.cancelled;
      case PaymentLifecycleState.initiated:
        return to == PaymentLifecycleState.pending || to == PaymentLifecycleState.failed || to == PaymentLifecycleState.cancelled;
      case PaymentLifecycleState.pending:
        return to == PaymentLifecycleState.authorized || to == PaymentLifecycleState.success || to == PaymentLifecycleState.failed || to == PaymentLifecycleState.verificationRequired;
      case PaymentLifecycleState.authorized:
        return to == PaymentLifecycleState.captured || to == PaymentLifecycleState.success || to == PaymentLifecycleState.failed;
      case PaymentLifecycleState.captured:
      case PaymentLifecycleState.success:
        return to == PaymentLifecycleState.refunded || to == PaymentLifecycleState.partiallyRefunded || to == PaymentLifecycleState.disputed;
      case PaymentLifecycleState.verificationRequired:
        return to == PaymentLifecycleState.success || to == PaymentLifecycleState.failed || to == PaymentLifecycleState.disputed;
      case PaymentLifecycleState.failed:
      case PaymentLifecycleState.cancelled:
      case PaymentLifecycleState.expired:
      case PaymentLifecycleState.refunded:
      case PaymentLifecycleState.partiallyRefunded:
      case PaymentLifecycleState.disputed:
        return false; // Terminal states
    }
  }
}
