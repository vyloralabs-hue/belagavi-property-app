import 'package:belagavi_property/core/security/user_role.dart';
import '../entities/review_entities.dart';

abstract class ReviewRepository {
  Future<PropertyReviewEntity> submitPropertyReview(PropertyReviewEntity review);

  Future<SellerReviewEntity> submitSellerReview(SellerReviewEntity review);

  Future<List<PropertyReviewEntity>> getPropertyReviews(
    String propertyId, {
    int limit = 20,
    int offset = 0,
    bool includeUnpublished = false,
  });

  Future<List<SellerReviewEntity>> getSellerReviews(
    String sellerId, {
    int limit = 20,
    int offset = 0,
    bool includeUnpublished = false,
  });

  Future<PropertyRatingSummaryEntity> getPropertyRatingSummary(String propertyId);

  Future<SellerTrustScoreEntity> getSellerTrustScore(String sellerId);

  Future<bool> checkUserReviewEligibility({
    required String userId,
    required String propertyId,
    required String sellerId,
  });

  Future<PropertyReviewEntity> updatePropertyReview({
    required String reviewId,
    required String requestingUserId,
    double? newRating,
    String? newTitle,
    String? newReviewText,
    UserRole? userRole,
  });

  Future<void> deletePropertyReview({
    required String reviewId,
    required String requestingUserId,
    UserRole? userRole,
  });

  Future<ReviewReportEntity> reportReview(ReviewReportEntity report);

  Future<void> moderateReview({
    required String reviewId,
    required ReviewStatus newStatus,
    required String moderatorId,
    required UserRole userRole,
    String? notes,
  });
}
