import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../entities/promotion_entities.dart';

abstract class PromotionRepository {
  Future<PropertyPromotionEntity> createPropertyPromotion({
    required PropertyEntity property,
    required String requestingUserId,
    required PromotionType promotionType,
    required int durationDays,
    UserRole? userRole,
  });

  Future<List<PropertyPromotionEntity>> getPromotionsForProperty(String propertyId);

  Future<List<PropertyPromotionEntity>> getPromotionsForOwner(String ownerId);

  Future<List<PropertyPromotionEntity>> getActivePromotions({
    int limit = 50,
    int offset = 0,
  });

  Future<UserEntitlementEntity?> getUserEntitlement({
    required String userId,
    required String entitlementKey,
  });

  Future<UserEntitlementEntity> grantEntitlement({
    required String userId,
    required String entitlementKey,
    required int quota,
    DateTime? expiresAt,
    required UserRole granterRole,
  });

  Future<PropertyPromotionEntity> updatePromotionStatus({
    required String promotionId,
    required PromotionStatus newStatus,
    required String requestingUserId,
    UserRole? userRole,
    String? reason,
  });
}
