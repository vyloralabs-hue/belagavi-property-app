import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import '../domain/entities/review_entities.dart';

class ReviewSecurityGuard {
  ReviewSecurityGuard._();

  /// Verifies review submission eligibility constraints.
  static void verifyReviewEligibility({
    required String? reviewerId,
    required String? sellerId,
    required String? propertyId,
    required bool hasVerifiedInteraction,
  }) {
    if (reviewerId == null || reviewerId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required to submit a review.');
    }
    if (sellerId == null || sellerId.trim().isEmpty) {
      throw const AccessDeniedException('Invalid seller information.');
    }
    if (reviewerId == sellerId) {
      throw const AccessDeniedException('Self-review violation: You cannot review your own property or profile.');
    }
    if (!hasVerifiedInteraction) {
      throw const AccessDeniedException(
        'Verified interaction required: You can only review properties or sellers you have genuinely interacted with.',
      );
    }
  }

  /// Validates 1.0 to 5.0 star rating bounds.
  static double validateRating(double? rating) {
    if (rating == null || rating < 1.0 || rating > 5.0) {
      throw const AccessDeniedException('Rating must be between 1.0 and 5.0 stars.');
    }
    return double.parse(rating.toStringAsFixed(1));
  }

  /// Validates review text content.
  static void validateReviewContent({required String title, required String reviewText}) {
    final trimmedTitle = title.trim();
    final trimmedText = reviewText.trim();

    if (trimmedText.isEmpty) {
      throw const AccessDeniedException('Review content cannot be empty.');
    }
    if (trimmedText.length < 5) {
      throw const AccessDeniedException('Review text must contain at least 5 characters.');
    }
    if (trimmedText.length > 2000) {
      throw const AccessDeniedException('Review text cannot exceed 2000 characters.');
    }
    if (trimmedTitle.length > 150) {
      throw const AccessDeniedException('Review title cannot exceed 150 characters.');
    }
  }

  /// Verifies reviewer authorization for edit or deletion.
  static void verifyReviewModification({
    required String? requestingUserId,
    required String reviewerId,
    UserRole? userRole,
    String actionName = 'modify this review',
  }) {
    if (requestingUserId == null || requestingUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required.');
    }
    if (userRole != null && userRole.isAdminOrFounder) {
      return;
    }
    if (requestingUserId != reviewerId) {
      throw AccessDeniedException('Access Denied: You cannot $actionName authored by another user.');
    }
  }

  /// Deterministically computes seller trust score and trust level from published verified reviews only.
  static SellerTrustScoreEntity calculateSellerTrustScore({
    required String sellerId,
    required List<SellerReviewEntity> reviews,
  }) {
    // Only published and verified reviews count towards trust score
    final validReviews = reviews
        .where((r) => r.status == ReviewStatus.published && r.isVerifiedInteraction)
        .toList();

    if (validReviews.isEmpty) {
      return SellerTrustScoreEntity(
        sellerId: sellerId,
        averageRating: 0.0,
        totalReviews: 0,
        verifiedReviewCount: 0,
        ratingBreakdown: const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        trustLevel: TrustLevel.newSeller,
      );
    }

    final totalCount = validReviews.length;
    double sum = 0;
    final breakdown = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final r in validReviews) {
      sum += r.rating;
      final roundedStar = r.rating.round().clamp(1, 5);
      breakdown[roundedStar] = (breakdown[roundedStar] ?? 0) + 1;
    }

    final avg = double.parse((sum / totalCount).toStringAsFixed(1));

    TrustLevel level;
    if (totalCount >= 10 && avg >= 4.5) {
      level = TrustLevel.exemplary;
    } else if (totalCount >= 5 && avg >= 4.0) {
      level = TrustLevel.trusted;
    } else if (totalCount >= 1) {
      level = TrustLevel.verified;
    } else {
      level = TrustLevel.newSeller;
    }

    return SellerTrustScoreEntity(
      sellerId: sellerId,
      averageRating: avg,
      totalReviews: totalCount,
      verifiedReviewCount: totalCount,
      ratingBreakdown: breakdown,
      trustLevel: level,
    );
  }

  /// Calculates property rating summary from published reviews only.
  static PropertyRatingSummaryEntity calculatePropertyRatingSummary({
    required String propertyId,
    required List<PropertyReviewEntity> reviews,
  }) {
    final validReviews = reviews
        .where((r) => r.status == ReviewStatus.published && r.isVerifiedInteraction)
        .toList();

    if (validReviews.isEmpty) {
      return PropertyRatingSummaryEntity(
        propertyId: propertyId,
        averageRating: 0.0,
        reviewCount: 0,
        verifiedReviewCount: 0,
        ratingBreakdown: const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }

    final totalCount = validReviews.length;
    double sum = 0;
    final breakdown = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final r in validReviews) {
      sum += r.rating;
      final roundedStar = r.rating.round().clamp(1, 5);
      breakdown[roundedStar] = (breakdown[roundedStar] ?? 0) + 1;
    }

    final avg = double.parse((sum / totalCount).toStringAsFixed(1));

    return PropertyRatingSummaryEntity(
      propertyId: propertyId,
      averageRating: avg,
      reviewCount: totalCount,
      verifiedReviewCount: totalCount,
      ratingBreakdown: breakdown,
    );
  }
}
