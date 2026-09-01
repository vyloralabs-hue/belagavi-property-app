import '../domain/entities/payment_entities.dart';

class CouponValidator {
  CouponValidator._();

  /// Validates coupon active status, expiry, and minimum order threshold
  static bool isValid(PromoCouponEntity coupon, double orderAmount) {
    if (!coupon.isActive) return false;
    if (DateTime.now().isAfter(coupon.expiryDate)) return false;
    if (orderAmount < coupon.minimumOrderAmount) return false;
    return true;
  }
}
