import '../../features/property/domain/entities/property_entities.dart';

/// Centralized, server-authoritative Business Access Policy for Belagavi Property.
/// Governs:
/// 1. Free vs Paid monitoring products (Dispute/Legal Notice = FREE, Normal/Survey = PAID).
/// 2. Commercial vs Residential listing access lifecycle (15-day free vs Paid from Day 1).
/// 3. Buyer full-details unlock permissions (privacy-protected by default).
class BusinessAccessPolicy {
  BusinessAccessPolicy._();

  /// Default public free listing duration for residential / non-commercial properties.
  static const int defaultFreeListingDays = 15;

  // --------------------------------------------------------------------------
  // WATCH / MONITORING ACCESS RULES (Rules 1, 2, 3, 8)
  // --------------------------------------------------------------------------

  /// Dispute Property Watch is 100% FREE for all registered users.
  /// No entitlement, payment, or subscription quota required.
  static bool isDisputeWatchFree() => true;

  /// Property Legal Notice Watch is 100% FREE for all registered users.
  /// No entitlement, payment, or subscription quota required.
  static bool isLegalNoticeWatchFree() => true;

  /// Normal Property / Survey Monitoring is 100% PAID-ONLY.
  /// Server enforces entitlement quota check from watch #1.
  static bool isNormalWatchPaid() => true;

  /// Survey Monitoring is 100% PAID-ONLY.
  static bool isSurveyMonitoringPaid() => true;

  // --------------------------------------------------------------------------
  // PROPERTY TAXONOMY & LISTING ACCESS RULES (Rules 4, 5)
  // --------------------------------------------------------------------------

  /// Determines whether a property category and subtype qualify as Commercial.
  /// Commercial properties are PAID from Day 1 (no 15-day free period).
  static bool isCommercialProperty({
    required PropertyCategory category,
    PropertySubtype? type,
  }) {
    if (category == PropertyCategory.commercial ||
        category == PropertyCategory.industrial) {
      return true;
    }

    if (type != null) {
      switch (type) {
        case PropertySubtype.commercialPlot:
        case PropertySubtype.commercialOffice:
        case PropertySubtype.commercialShop:
        case PropertySubtype.commercialShowroom:
        case PropertySubtype.warehouse:
        case PropertySubtype.warehouseGodown:
        case PropertySubtype.industrialLand:
          return true;
        default:
          break;
      }
    }

    return false;
  }

  /// Determines whether a property qualifies for the 15-Day Free Residential listing window.
  /// Non-commercial properties (residential, plots, agricultural land, builder projects) are eligible.
  static bool isEligibleFor15DayFreeListing({
    required PropertyCategory category,
    PropertySubtype? type,
  }) {
    return !isCommercialProperty(category: category, type: type);
  }

  /// Computes the free listing expiration date given a start time.
  static DateTime calculateFreeListingExpiry(DateTime startedAt, {int days = defaultFreeListingDays}) {
    return startedAt.add(Duration(days: days));
  }

  /// Computes remaining free listing days.
  /// Returns null for grandfathered or commercial properties.
  static int? remainingFreeListingDays({
    required String listingAccessType,
    required DateTime? freeListingExpiresAt,
    bool isGrandfathered = false,
  }) {
    if (isGrandfathered || listingAccessType == 'grandfathered') {
      return null;
    }
    if (listingAccessType == 'commercial_paid' || freeListingExpiresAt == null) {
      return 0;
    }
    final diff = freeListingExpiresAt.difference(DateTime.now()).inSeconds;
    if (diff <= 0) return 0;
    return (diff / 86400).ceil();
  }

  /// Returns true if a listing is past its 15-day free window and needs payment/renewal.
  static bool isFreeListingExpired({
    required String listingAccessType,
    required DateTime? freeListingExpiresAt,
    bool isGrandfathered = false,
  }) {
    if (isGrandfathered || listingAccessType == 'grandfathered') {
      return false; // Grandfathered listings never expire via free-window rule
    }
    if (listingAccessType == 'commercial_paid') {
      return false; // Commercial follows paid entitlement lifecycle
    }
    if (freeListingExpiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(freeListingExpiresAt);
  }

  /// General check: determines whether any property listing has expired.
  /// Grandfathered properties are permanently immune to expiry.
  static bool isListingExpired({
    required bool isGrandfathered,
    required String listingAccessType,
    required DateTime? freeListingExpiresAt,
    required DateTime? listingExpiresAt,
  }) {
    if (isGrandfathered || listingAccessType == 'grandfathered') {
      return false;
    }
    if (listingExpiresAt != null) {
      return DateTime.now().isAfter(listingExpiresAt);
    }
    return isFreeListingExpired(
      listingAccessType: listingAccessType,
      freeListingExpiresAt: freeListingExpiresAt,
      isGrandfathered: isGrandfathered,
    );
  }

  /// Checks whether an expired item can be reactivated.
  /// Sold or terminal states cannot be reactivated; active/expired can.
  static bool canReactivate({
    required ListingStatus status,
    required bool isListingExpired,
  }) {
    if (status == ListingStatus.sold ||
        status == ListingStatus.rented ||
        status == ListingStatus.leased ||
        status == ListingStatus.rejected) {
      return false;
    }
    return isListingExpired;
  }

  /// Evaluates whether an item qualifies for public marketplace visibility.
  static bool isItemPubliclyVisible({
    required ListingStatus status,
    required bool isPaused,
    required bool isListingExpired,
  }) {
    if (!status.isPubliclyVisible) return false;
    if (isPaused) return false;
    if (isListingExpired) return false;
    return true;
  }

  // --------------------------------------------------------------------------
  // PRIVACY & FULL-DETAILS UNLOCK RULES (Rules 6, 7, 8)
  // --------------------------------------------------------------------------

  /// Determines if a caller is authorized to view protected owner contact & exact address.
  /// Authorized if:
  /// 1. Caller is the verified listing owner, OR
  /// 2. Caller has an active 'property_full_details_unlock' entitlement/unlock record for this property, OR
  /// 3. Caller is an administrator.
  static bool canViewFullDetails({
    required String propertyOwnerId,
    required String? requestingUserId,
    required bool isOwnerOrAdmin,
    required List<PropertyUnlockEntity> userUnlocks,
    required String propertyId,
  }) {
    if (requestingUserId == null || requestingUserId.isEmpty) {
      return false;
    }

    if (isOwnerOrAdmin) {
      return true;
    }

    final now = DateTime.now();
    return userUnlocks.any((unlock) {
      if (unlock.propertyId != propertyId || unlock.userId != requestingUserId) {
        return false;
      }
      if (unlock.status != UnlockStatus.active) {
        return false;
      }
      if (unlock.expiresAt != null && unlock.expiresAt!.isBefore(now)) {
        return false;
      }
      return true;
    });
  }
}
