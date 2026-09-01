import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

enum DeveloperClassification {
  normalOwner,
  builder,
  projectDeveloper,
  landDeveloper,
  layoutDeveloper,
  broker,
  agent,
  shopOwner,
  other,
}

class ProfessionalListingAccessPolicy {
  ProfessionalListingAccessPolicy._();

  /// Determines whether a paid developer subscription is required for the listing.
  static bool isSubscriptionRequired({
    required UserRole userRole,
    required PropertyCategory category,
    PropertySubtype? subtype,
    DeveloperClassification? classification,
  }) {
    // 1. Normal individual property owners & sellers are strictly FREE
    if (userRole == UserRole.sellerOwner ||
        userRole == UserRole.user ||
        classification == DeveloperClassification.normalOwner) {
      return false;
    }

    // 2. Builders & Project Developers are MANDATORY PAID
    if (userRole == UserRole.builder ||
        classification == DeveloperClassification.builder ||
        classification == DeveloperClassification.projectDeveloper ||
        category == PropertyCategory.builderProject ||
        subtype == PropertySubtype.builderProject ||
        subtype == PropertySubtype.builderApartmentProject ||
        subtype == PropertySubtype.builderGatedCommunity) {
      return true;
    }

    // 3. Land Developers & Layout Developers are MANDATORY PAID
    if (userRole == UserRole.landDeveloper ||
        classification == DeveloperClassification.landDeveloper ||
        classification == DeveloperClassification.layoutDeveloper) {
      return true;
    }

    return false;
  }

  /// Evaluates whether a professional listing is authorized for public LIVE publication.
  static bool canPublishProfessionalListing({
    required UserRole userRole,
    required PropertyCategory category,
    PropertySubtype? subtype,
    DeveloperClassification? classification,
    required bool hasActiveSubscription,
    required ListingStatus currentStatus,
  }) {
    final requiresSub = isSubscriptionRequired(
      userRole: userRole,
      category: category,
      subtype: subtype,
      classification: classification,
    );

    // If subscription is required but user has NO active subscription, public LIVE publication is BLOCKED
    if (requiresSub && !hasActiveSubscription) {
      return false;
    }

    // Must also satisfy standard moderation workflow
    final isApprovedState = currentStatus == ListingStatus.approved ||
        currentStatus == ListingStatus.published ||
        currentStatus == ListingStatus.active;

    return isApprovedState || currentStatus == ListingStatus.draft || currentStatus == ListingStatus.submitted;
  }
}
