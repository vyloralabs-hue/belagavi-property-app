enum PropertyPromotionTier { free, featured, priority, premium }

class PropertyPromotionPlan {
  final PropertyPromotionTier tier;
  final String planId;
  final String title;
  final int amountInPaise;
  final int durationDays;
  final int priorityBoostScore;
  final String badgeLabel;
  final String description;

  const PropertyPromotionPlan({
    required this.tier,
    required this.planId,
    required this.title,
    required this.amountInPaise,
    required this.durationDays,
    required this.priorityBoostScore,
    required this.badgeLabel,
    required this.description,
  });

  double get amountInRupees => amountInPaise / 100.0;
}

class PropertyMonetizationConfig {
  static final Map<PropertyPromotionTier, PropertyPromotionPlan> _plans = {
    PropertyPromotionTier.free: const PropertyPromotionPlan(
      tier: PropertyPromotionTier.free,
      planId: 'plan_prop_free',
      title: 'Basic Free Listing',
      amountInPaise: 0,
      durationDays: 3650,
      priorityBoostScore: 0,
      badgeLabel: 'FREE',
      description: 'Standard organic search visibility across PropertyHub',
    ),
    PropertyPromotionTier.featured: const PropertyPromotionPlan(
      tier: PropertyPromotionTier.featured,
      planId: 'plan_prop_featured_99',
      title: 'Featured Listing',
      amountInPaise: 9900, // ₹99
      durationDays: 30,
      priorityBoostScore: 20,
      badgeLabel: 'FEATURED',
      description:
          'Highlighted card with +20 priority search boost for 30 days',
    ),
    PropertyPromotionTier.priority: const PropertyPromotionPlan(
      tier: PropertyPromotionTier.priority,
      planId: 'plan_prop_priority_199',
      title: 'Priority Listing',
      amountInPaise: 19900, // ₹199
      durationDays: 30,
      priorityBoostScore: 50,
      badgeLabel: 'PRIORITY',
      description:
          'Higher search priority with +50 priority search boost for 30 days',
    ),
    PropertyPromotionTier.premium: const PropertyPromotionPlan(
      tier: PropertyPromotionTier.premium,
      planId: 'plan_prop_premium_299',
      title: 'Premium Boosted',
      amountInPaise: 29900, // ₹299
      durationDays: 30,
      priorityBoostScore: 100,
      badgeLabel: 'PREMIUM',
      description:
          'Highest search priority with +100 priority boost & owner analytics',
    ),
  };

  static PropertyPromotionPlan getPlan(PropertyPromotionTier tier) {
    return _plans[tier] ?? _plans[PropertyPromotionTier.free]!;
  }

  static List<PropertyPromotionPlan> get allPromotionPlans => [
    _plans[PropertyPromotionTier.free]!,
    _plans[PropertyPromotionTier.featured]!,
    _plans[PropertyPromotionTier.priority]!,
    _plans[PropertyPromotionTier.premium]!,
  ];
}
