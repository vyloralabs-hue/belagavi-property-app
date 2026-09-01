import '../../../core/security/user_role.dart';
import '../domain/entities/property_entities.dart';

class PropertyStatusWorkflow {
  PropertyStatusWorkflow._();

  /// State Machine transition validator for property listing lifecycle
  static bool canTransition({
    required ListingStatus currentStatus,
    required ListingStatus targetStatus,
  }) {
    if (currentStatus == targetStatus) return true;

    // Founder emergency moderation can place any status into disputed or archived
    if (targetStatus == ListingStatus.disputed || targetStatus == ListingStatus.archived) {
      return true;
    }

    return switch (currentStatus) {
      ListingStatus.draft => targetStatus == ListingStatus.submitted ||
          targetStatus == ListingStatus.pendingVerification ||
          targetStatus == ListingStatus.archived,
      ListingStatus.submitted => targetStatus == ListingStatus.underReview ||
          targetStatus == ListingStatus.approved ||
          targetStatus == ListingStatus.published ||
          targetStatus == ListingStatus.rejected ||
          targetStatus == ListingStatus.changesRequested ||
          targetStatus == ListingStatus.disputed ||
          targetStatus == ListingStatus.draft,
      ListingStatus.pendingVerification => targetStatus == ListingStatus.underReview ||
          targetStatus == ListingStatus.approved ||
          targetStatus == ListingStatus.active ||
          targetStatus == ListingStatus.published ||
          targetStatus == ListingStatus.changesRequested ||
          targetStatus == ListingStatus.disputed ||
          targetStatus == ListingStatus.rejected,
      ListingStatus.underReview => targetStatus == ListingStatus.approved ||
          targetStatus == ListingStatus.rejected ||
          targetStatus == ListingStatus.changesRequested ||
          targetStatus == ListingStatus.disputed ||
          targetStatus == ListingStatus.draft,
      ListingStatus.changesRequested => targetStatus == ListingStatus.draft ||
          targetStatus == ListingStatus.submitted,
      ListingStatus.approved => targetStatus == ListingStatus.published ||
          targetStatus == ListingStatus.active ||
          targetStatus == ListingStatus.disputed ||
          targetStatus == ListingStatus.paused,
      ListingStatus.published || ListingStatus.active => targetStatus == ListingStatus.paused ||
          targetStatus == ListingStatus.sold ||
          targetStatus == ListingStatus.rented ||
          targetStatus == ListingStatus.disputed ||
          targetStatus == ListingStatus.archived,
      ListingStatus.paused => targetStatus == ListingStatus.published ||
          targetStatus == ListingStatus.active ||
          targetStatus == ListingStatus.disputed ||
          targetStatus == ListingStatus.archived,
      ListingStatus.rejected => targetStatus == ListingStatus.draft ||
          targetStatus == ListingStatus.submitted,
      ListingStatus.disputed => targetStatus == ListingStatus.draft ||
          targetStatus == ListingStatus.underReview ||
          targetStatus == ListingStatus.archived,
      ListingStatus.sold => targetStatus == ListingStatus.archived,
      ListingStatus.rented => targetStatus == ListingStatus.archived,
      ListingStatus.leased => targetStatus == ListingStatus.archived,
      ListingStatus.archived => targetStatus == ListingStatus.draft,
    };
  }

  /// Validates both state machine transition rules AND actor role permissions
  static bool canTransitionWithRole({
    required ListingStatus currentStatus,
    required ListingStatus targetStatus,
    required UserRole userRole,
  }) {
    // 1. Basic state machine validity
    if (!canTransition(currentStatus: currentStatus, targetStatus: targetStatus)) {
      return false;
    }

    // 2. Founder has full administrative & emergency authority
    if (userRole == UserRole.founder) return true;

    // 3. Admin moderation authority
    if (userRole == UserRole.admin || userRole == UserRole.moderator) {
      // Admin cannot perform owner-only status mutations like sold/rented
      if (targetStatus == ListingStatus.sold || targetStatus == ListingStatus.rented) {
        return false;
      }
      return true;
    }

    // 4. Owner / Builder / Seller permissions
    if (userRole == UserRole.sellerOwner || userRole == UserRole.builder || userRole == UserRole.agent || userRole == UserRole.user) {
      // Owners CANNOT self-approve or un-dispute listings
      if (targetStatus == ListingStatus.approved || targetStatus == ListingStatus.published || targetStatus == ListingStatus.active) {
        // Can only resume if currently paused
        if (currentStatus == ListingStatus.paused) return true;
        return false;
      }

      // Owner can submit, pause, archive, or edit after changes requested/rejected
      if (currentStatus == ListingStatus.draft && (targetStatus == ListingStatus.submitted || targetStatus == ListingStatus.archived)) {
        return true;
      }
      if (currentStatus == ListingStatus.changesRequested && (targetStatus == ListingStatus.draft || targetStatus == ListingStatus.submitted)) {
        return true;
      }
      if (currentStatus == ListingStatus.rejected && (targetStatus == ListingStatus.draft || targetStatus == ListingStatus.submitted)) {
        return true;
      }
      if ((currentStatus == ListingStatus.published || currentStatus == ListingStatus.active) && (targetStatus == ListingStatus.paused || targetStatus == ListingStatus.archived)) {
        return true;
      }
      if (currentStatus == ListingStatus.paused && (targetStatus == ListingStatus.published || targetStatus == ListingStatus.active || targetStatus == ListingStatus.archived)) {
        return true;
      }
      if (currentStatus == ListingStatus.archived && targetStatus == ListingStatus.draft) {
        return true;
      }

      return false;
    }

    return false;
  }
}
