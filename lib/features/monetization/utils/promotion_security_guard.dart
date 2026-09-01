import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../domain/entities/promotion_entities.dart';

class PromotionSecurityGuard {
  PromotionSecurityGuard._();

  /// Standard server-side package catalog (prevents client-side price tampering)
  static const List<PromotionPackageConfigEntity> officialPackages = [
    PromotionPackageConfigEntity(
      id: 'pkg_boost_7d',
      type: PromotionType.boost,
      title: '7-Day Search Boost',
      description: 'Highlight your listing in search results with increased visibility.',
      serverPriceInr: 299.0,
      durationDays: 7,
      priorityLevel: 1,
    ),
    PromotionPackageConfigEntity(
      id: 'pkg_featured_15d',
      type: PromotionType.featured,
      title: '15-Day Master Featured',
      description: 'Master Gold badge, top search placement, and priority inquiries.',
      serverPriceInr: 599.0,
      durationDays: 15,
      priorityLevel: 2,
    ),
    PromotionPackageConfigEntity(
      id: 'pkg_top_30d',
      type: PromotionType.topPlacement,
      title: '30-Day Top City Placement',
      description: 'Exclusive top-tier placement across Belagavi city discovery feeds.',
      serverPriceInr: 999.0,
      durationDays: 30,
      priorityLevel: 3,
    ),
  ];

  /// Verifies property eligibility for listing promotion.
  static void verifyPromotionEligibility({
    required String? requestingUserId,
    required PropertyEntity property,
    UserRole? userRole,
  }) {
    if (requestingUserId == null || requestingUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required to promote property.');
    }

    final isAdmin = userRole != null && userRole.isAdminOrFounder;
    if (!isAdmin && property.ownerId != requestingUserId) {
      throw const AccessDeniedException(
        'Access Denied: You can only promote properties owned by your account.',
      );
    }

    final isPubliclyEligible = property.status == ListingStatus.published ||
        property.status == ListingStatus.active ||
        property.status == ListingStatus.approved;

    if (!isPubliclyEligible) {
      throw AccessDeniedException(
        'Promotion unavailable: Listing "${property.id}" is in "${property.status.name}" status. Only active published listings are eligible.',
      );
    }
  }

  /// Verifies authorization for promotion modification or cancellation.
  static void verifyPromotionModification({
    required String? requestingUserId,
    required PropertyPromotionEntity promotion,
    UserRole? userRole,
    String actionName = 'modify this promotion',
  }) {
    if (requestingUserId == null || requestingUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required.');
    }
    if (userRole != null && userRole.isAdminOrFounder) {
      return;
    }
    if (requestingUserId != promotion.ownerId) {
      throw AccessDeniedException('Access Denied: You cannot $actionName for another seller\'s property.');
    }
  }

  /// Verifies entitlement grant / elevation authority.
  static void verifyEntitlementModification({
    required UserRole? userRole,
  }) {
    if (userRole == null || !userRole.isAdminOrFounder) {
      throw const AccessDeniedException(
        'Access Denied: Entitlement grants and quota modifications require Admin or Founder authority.',
      );
    }
  }

  /// Authoritatively determines if a promotion should influence public ranking.
  /// Subjugates promotion to property lifecycle (Property status is ALWAYS authoritative).
  static bool isPromotionEffectivelyActive({
    required PropertyPromotionEntity promotion,
    required PropertyEntity property,
  }) {
    if (!promotion.isCurrentlyActive) {
      return false;
    }

    final isPropertyActive = property.status == ListingStatus.published ||
        property.status == ListingStatus.active ||
        property.status == ListingStatus.approved;

    // Property lifecycle precedence: If property is sold, rejected, paused, or archived, promotion is inactive!
    return isPropertyActive;
  }
}
