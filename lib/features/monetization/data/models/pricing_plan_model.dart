import '../../domain/entities/pricing_plan_entity.dart';

class PricingPlanModel extends PricingPlanEntity {
  const PricingPlanModel({
    required super.id,
    required super.code,
    required super.name,
    required super.productFamily,
    required super.priceMinorUnits,
    super.currency,
    required super.validityDays,
    super.creditCount,
    super.isActive,
    super.sortOrder,
    super.metadata,
  });

  factory PricingPlanModel.fromJson(Map<String, dynamic> json) {
    final price = json['price_minor_units'] ?? json['amount_in_paise'] ?? 0;
    final validity = json['validity_days'] ?? json['duration_days'] ?? 30;

    return PricingPlanModel(
      id: (json['id'] ?? json['code'] ?? json['plan_id'] ?? '').toString(),
      code: (json['code'] ?? json['plan_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['plan_name'] ?? '').toString(),
      productFamily: (json['product_family'] ?? json['product_type'] ?? 'residential_listing').toString(),
      priceMinorUnits: (price is num) ? price.toInt() : int.tryParse(price.toString()) ?? 0,
      currency: (json['currency'] ?? 'INR').toString(),
      validityDays: (validity is num) ? validity.toInt() : int.tryParse(validity.toString()) ?? 30,
      creditCount: json['credit_count'] is num
          ? (json['credit_count'] as num).toInt()
          : (json['listing_limit'] is num ? (json['listing_limit'] as num).toInt() : 1),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] is num) ? (json['sort_order'] as num).toInt() : 0,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'plan_id': code,
      'name': name,
      'product_family': productFamily,
      'price_minor_units': priceMinorUnits,
      'amount_in_paise': priceMinorUnits,
      'currency': currency,
      'validity_days': validityDays,
      'duration_days': validityDays,
      'credit_count': creditCount,
      'is_active': isActive,
      'sort_order': sortOrder,
      'metadata': metadata,
    };
  }
}
