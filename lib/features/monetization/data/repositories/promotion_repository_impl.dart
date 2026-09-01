import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/domain/repositories/notification_repository.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../../domain/entities/promotion_entities.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../../utils/promotion_security_guard.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final SupabaseService? _supabaseService;
  final NotificationRepository? _notificationRepository;

  final Map<String, PropertyPromotionEntity> _promotions = {};
  final Map<String, UserEntitlementEntity> _entitlements = {};

  PromotionRepositoryImpl({
    this._supabaseService,
    NotificationRepository? notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<PropertyPromotionEntity> createPropertyPromotion({
    required PropertyEntity property,
    required String requestingUserId,
    required PromotionType promotionType,
    required int durationDays,
    UserRole? userRole,
  }) async {
    // 1. Guard & Eligibility Check
    PromotionSecurityGuard.verifyPromotionEligibility(
      requestingUserId: requestingUserId,
      property: property,
      userRole: userRole,
    );

    // 2. Duplicate Check: Prevent duplicate active promotion of the same type on the same property
    final now = DateTime.now();
    final hasActiveSameType = _promotions.values.any(
      (p) =>
          p.propertyId == property.id &&
          p.promotionType == promotionType &&
          p.status == PromotionStatus.active &&
          p.endAt.isAfter(now),
    );

    if (hasActiveSameType) {
      throw const AccessDeniedException(
        'Duplicate promotion: An active promotion of this type already exists for this property.',
      );
    }

    final promoId =
        'promo_${property.id}_${promotionType.name}_${now.millisecondsSinceEpoch}';
    final endAt = now.add(Duration(days: durationDays > 0 ? durationDays : 7));

    final entity = PropertyPromotionEntity(
      id: promoId,
      propertyId: property.id,
      ownerId: property.ownerId,
      promotionType: promotionType,
      priorityLevel: promotionType.defaultPriority,
      status: PromotionStatus.active,
      startAt: now,
      endAt: endAt,
      createdAt: now,
      updatedAt: now,
    );

    // 3. Supabase persistence
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('property_promotions')
            .insert(entity.toJson());
      } catch (_) {}
    }

    _promotions[entity.id] = entity;

    // 4. Send confirmation notification to owner
    if (_notificationRepository != null && property.ownerId.isNotEmpty) {
      try {
        final notif = NotificationEntity(
          id: 'notif_promo_${entity.id}',
          recipientId: property.ownerId,
          type: NotificationType.system,
          title: 'Promotion Activated (${promotionType.displayName})',
          body:
              'Your listing "${property.title}" has been promoted with priority boost until ${endAt.day}/${endAt.month}/${endAt.year}.',
          propertyId: property.id,
          createdAt: now,
          updatedAt: now,
        );
        await _notificationRepository.sendNotification(notif);
      } catch (_) {}
    }

    return entity;
  }

  @override
  Future<List<PropertyPromotionEntity>> getPromotionsForProperty(
    String propertyId,
  ) async {
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService
            .from('property_promotions')
            .select()
            .eq('property_id', propertyId)
            .order('created_at', ascending: false);
        return (response as List)
            .map((json) => PropertyPromotionEntity.fromJson(json))
            .toList();
      } catch (_) {}
    }

    return _promotions.values.where((p) => p.propertyId == propertyId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<PropertyPromotionEntity>> getPromotionsForOwner(
    String ownerId,
  ) async {
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService
            .from('property_promotions')
            .select()
            .eq('owner_id', ownerId)
            .order('created_at', ascending: false);
        return (response as List)
            .map((json) => PropertyPromotionEntity.fromJson(json))
            .toList();
      } catch (_) {}
    }

    return _promotions.values.where((p) => p.ownerId == ownerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<PropertyPromotionEntity>> getActivePromotions({
    int limit = 50,
    int offset = 0,
  }) async {
    final now = DateTime.now();

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService
            .from('property_promotions')
            .select()
            .eq('status', 'ACTIVE')
            .gt('end_at', now.toIso8601String())
            .order('priority_level', ascending: false)
            .range(offset, offset + limit - 1);
        return (response as List)
            .map((json) => PropertyPromotionEntity.fromJson(json))
            .toList();
      } catch (_) {}
    }

    final activeList =
        _promotions.values
            .where(
              (p) => p.status == PromotionStatus.active && p.endAt.isAfter(now),
            )
            .toList()
          ..sort((a, b) => b.priorityLevel.compareTo(a.priorityLevel));

    return activeList.skip(offset).take(limit).toList();
  }

  @override
  Future<UserEntitlementEntity?> getUserEntitlement({
    required String userId,
    required String entitlementKey,
  }) async {
    final compositeKey = '${userId}_$entitlementKey';
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService
            .from('user_entitlements')
            .select()
            .eq('user_id', userId)
            .eq('entitlement_key', entitlementKey)
            .maybeSingle();
        if (response != null) {
          return UserEntitlementEntity.fromJson(response);
        }
      } catch (_) {}
    }

    return _entitlements[compositeKey];
  }

  @override
  Future<UserEntitlementEntity> grantEntitlement({
    required String userId,
    required String entitlementKey,
    required int quota,
    DateTime? expiresAt,
    required UserRole granterRole,
  }) async {
    // Entitlement grant requires Admin or Founder role
    PromotionSecurityGuard.verifyEntitlementModification(userRole: granterRole);

    final compositeKey = '${userId}_$entitlementKey';
    final existing = _entitlements[compositeKey];

    final updated = UserEntitlementEntity(
      id:
          existing?.id ??
          'ent_${userId}_${entitlementKey}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      entitlementKey: entitlementKey,
      totalQuota: (existing?.totalQuota ?? 0) + quota,
      usedQuota: existing?.usedQuota ?? 0,
      expiresAt: expiresAt ?? existing?.expiresAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('user_entitlements')
            .upsert(updated.toJson());
      } catch (_) {}
    }

    _entitlements[compositeKey] = updated;
    return updated;
  }

  @override
  Future<PropertyPromotionEntity> updatePromotionStatus({
    required String promotionId,
    required PromotionStatus newStatus,
    required String requestingUserId,
    UserRole? userRole,
    String? reason,
  }) async {
    final existing = _promotions[promotionId];
    if (existing == null) {
      throw const AccessDeniedException('Promotion not found.');
    }

    PromotionSecurityGuard.verifyPromotionModification(
      requestingUserId: requestingUserId,
      promotion: existing,
      userRole: userRole,
      actionName: 'update this promotion',
    );

    final updated = existing.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('property_promotions')
            .update({
              'status': newStatus.name.toUpperCase(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', promotionId);
      } catch (_) {}
    }

    _promotions[promotionId] = updated;
    return updated;
  }
}
