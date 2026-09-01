import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/domain/repositories/notification_repository.dart';
import '../../domain/entities/review_entities.dart';
import '../../domain/repositories/review_repository.dart';
import '../../utils/review_security_guard.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final SupabaseService? _supabaseService;
  final NotificationRepository? _notificationRepository;

  final Map<String, PropertyReviewEntity> _propertyReviews = {};
  final Map<String, SellerReviewEntity> _sellerReviews = {};
  final Map<String, ReviewReportEntity> _reports = {};

  ReviewRepositoryImpl({
    this._supabaseService,
    NotificationRepository? notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<PropertyReviewEntity> submitPropertyReview(
    PropertyReviewEntity review,
  ) async {
    // 1. Guard & Eligibility validation
    ReviewSecurityGuard.verifyReviewEligibility(
      reviewerId: review.reviewerId,
      sellerId: review.sellerId,
      propertyId: review.propertyId,
      hasVerifiedInteraction: review.isVerifiedInteraction,
    );
    final validatedRating = ReviewSecurityGuard.validateRating(review.rating);
    ReviewSecurityGuard.validateReviewContent(
      title: review.title,
      reviewText: review.reviewText,
    );

    // 2. Duplicate Check: One review per (propertyId, reviewerId)
    final existing = _propertyReviews.values.any(
      (r) =>
          r.propertyId == review.propertyId &&
          r.reviewerId == review.reviewerId &&
          r.status != ReviewStatus.removed,
    );

    if (existing) {
      throw const AccessDeniedException(
        'Duplicate review: You have already submitted a review for this property.',
      );
    }

    final entity = review.copyWith(
      rating: validatedRating,
      title: review.title.trim(),
      reviewText: review.reviewText.trim(),
    );

    // 3. Supabase persistence
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService.from('property_reviews').insert(entity.toJson());
      } catch (_) {}
    }

    _propertyReviews[entity.id] = entity;

    // 4. Send notification to seller
    if (_notificationRepository != null &&
        entity.sellerId.isNotEmpty &&
        entity.sellerId != entity.reviewerId) {
      try {
        final notif = NotificationEntity(
          id: 'notif_rev_${entity.id}',
          recipientId: entity.sellerId,
          type: NotificationType.system,
          title: 'New Property Review (${entity.rating}★)',
          body:
              '${entity.reviewerName} reviewed your property: "${entity.title.isNotEmpty ? entity.title : entity.reviewText}"',
          propertyId: entity.propertyId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _notificationRepository.sendNotification(notif);
      } catch (_) {}
    }

    return entity;
  }

  @override
  Future<SellerReviewEntity> submitSellerReview(
    SellerReviewEntity review,
  ) async {
    // 1. Guard validation
    ReviewSecurityGuard.verifyReviewEligibility(
      reviewerId: review.reviewerId,
      sellerId: review.sellerId,
      propertyId: review.propertyId,
      hasVerifiedInteraction: review.isVerifiedInteraction,
    );
    final validatedRating = ReviewSecurityGuard.validateRating(review.rating);
    ReviewSecurityGuard.validateReviewContent(
      title: 'Seller Review',
      reviewText: review.reviewText,
    );

    // 2. Duplicate Check
    final existing = _sellerReviews.values.any(
      (r) =>
          r.sellerId == review.sellerId &&
          r.reviewerId == review.reviewerId &&
          r.status != ReviewStatus.removed,
    );

    if (existing) {
      throw const AccessDeniedException(
        'Duplicate review: You have already submitted a review for this seller.',
      );
    }

    final entity = review.copyWith(
      rating: validatedRating,
      reviewText: review.reviewText.trim(),
    );

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService.from('seller_reviews').insert(entity.toJson());
      } catch (_) {}
    }

    _sellerReviews[entity.id] = entity;

    return entity;
  }

  @override
  Future<List<PropertyReviewEntity>> getPropertyReviews(
    String propertyId, {
    int limit = 20,
    int offset = 0,
    bool includeUnpublished = false,
  }) async {
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        var query = _supabaseService
            .from('property_reviews')
            .select()
            .eq('property_id', propertyId);
        if (!includeUnpublished) {
          query = query.eq('status', 'PUBLISHED');
        }
        final response = await query
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
        return (response as List)
            .map((json) => PropertyReviewEntity.fromJson(json))
            .toList();
      } catch (_) {}
    }

    final list = _propertyReviews.values.where((r) {
      if (r.propertyId != propertyId) return false;
      if (!includeUnpublished && r.status != ReviewStatus.published)
        return false;
      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list.skip(offset).take(limit).toList();
  }

  @override
  Future<List<SellerReviewEntity>> getSellerReviews(
    String sellerId, {
    int limit = 20,
    int offset = 0,
    bool includeUnpublished = false,
  }) async {
    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        var query = _supabaseService
            .from('seller_reviews')
            .select()
            .eq('seller_id', sellerId);
        if (!includeUnpublished) {
          query = query.eq('status', 'PUBLISHED');
        }
        final response = await query
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
        return (response as List)
            .map((json) => SellerReviewEntity.fromJson(json))
            .toList();
      } catch (_) {}
    }

    final list = _sellerReviews.values.where((r) {
      if (r.sellerId != sellerId) return false;
      if (!includeUnpublished && r.status != ReviewStatus.published)
        return false;
      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list.skip(offset).take(limit).toList();
  }

  @override
  Future<PropertyRatingSummaryEntity> getPropertyRatingSummary(
    String propertyId,
  ) async {
    final reviews = await getPropertyReviews(
      propertyId,
      limit: 1000,
      includeUnpublished: false,
    );
    return ReviewSecurityGuard.calculatePropertyRatingSummary(
      propertyId: propertyId,
      reviews: reviews,
    );
  }

  @override
  Future<SellerTrustScoreEntity> getSellerTrustScore(String sellerId) async {
    final reviews = await getSellerReviews(
      sellerId,
      limit: 1000,
      includeUnpublished: false,
    );
    return ReviewSecurityGuard.calculateSellerTrustScore(
      sellerId: sellerId,
      reviews: reviews,
    );
  }

  @override
  Future<bool> checkUserReviewEligibility({
    required String userId,
    required String propertyId,
    required String sellerId,
  }) async {
    if (userId.trim().isEmpty || userId == sellerId) return false;
    // Check if user already reviewed
    final alreadyReviewed = _propertyReviews.values.any(
      (r) =>
          r.propertyId == propertyId &&
          r.reviewerId == userId &&
          r.status != ReviewStatus.removed,
    );
    return !alreadyReviewed;
  }

  @override
  Future<PropertyReviewEntity> updatePropertyReview({
    required String reviewId,
    required String requestingUserId,
    double? newRating,
    String? newTitle,
    String? newReviewText,
    UserRole? userRole,
  }) async {
    final existing = _propertyReviews[reviewId];
    if (existing == null) {
      throw const AccessDeniedException('Review not found.');
    }

    ReviewSecurityGuard.verifyReviewModification(
      requestingUserId: requestingUserId,
      reviewerId: existing.reviewerId,
      userRole: userRole,
      actionName: 'update this review',
    );

    if (newRating != null) {
      ReviewSecurityGuard.validateRating(newRating);
    }
    if (newReviewText != null) {
      ReviewSecurityGuard.validateReviewContent(
        title: newTitle ?? existing.title,
        reviewText: newReviewText,
      );
    }

    final updated = existing.copyWith(
      rating: newRating ?? existing.rating,
      title: newTitle ?? existing.title,
      reviewText: newReviewText ?? existing.reviewText,
      updatedAt: DateTime.now(),
    );

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('property_reviews')
            .update(updated.toJson())
            .eq('id', reviewId);
      } catch (_) {}
    }

    _propertyReviews[reviewId] = updated;
    return updated;
  }

  @override
  Future<void> deletePropertyReview({
    required String reviewId,
    required String requestingUserId,
    UserRole? userRole,
  }) async {
    final existing = _propertyReviews[reviewId];
    if (existing == null) {
      throw const AccessDeniedException('Review not found.');
    }

    ReviewSecurityGuard.verifyReviewModification(
      requestingUserId: requestingUserId,
      reviewerId: existing.reviewerId,
      userRole: userRole,
      actionName: 'delete this review',
    );

    // Soft delete to preserve moderation audit trails
    final softDeleted = existing.copyWith(
      status: ReviewStatus.removed,
      updatedAt: DateTime.now(),
    );

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('property_reviews')
            .update({'status': 'REMOVED'})
            .eq('id', reviewId);
      } catch (_) {}
    }

    _propertyReviews[reviewId] = softDeleted;
  }

  @override
  Future<ReviewReportEntity> reportReview(ReviewReportEntity report) async {
    if (report.reporterId.trim().isEmpty) {
      throw const AccessDeniedException(
        'Authentication required to report a review.',
      );
    }

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService.from('review_reports').insert({
          'id': report.id,
          'review_id': report.reviewId,
          'review_type': report.reviewType,
          'reporter_id': report.reporterId,
          'reason': report.reason.name.toUpperCase(),
          'details': report.details,
          'status': 'PENDING',
          'created_at': report.createdAt.toIso8601String(),
        });
      } catch (_) {}
    }

    _reports[report.id] = report;

    // Mark review status as reported
    final existingPropRev = _propertyReviews[report.reviewId];
    if (existingPropRev != null) {
      _propertyReviews[report.reviewId] = existingPropRev.copyWith(
        status: ReviewStatus.reported,
      );
    }

    return report;
  }

  @override
  Future<void> moderateReview({
    required String reviewId,
    required ReviewStatus newStatus,
    required String moderatorId,
    required UserRole userRole,
    String? notes,
  }) async {
    if (!userRole.isAdminOrFounder) {
      throw const AccessDeniedException(
        'Access Denied: Only application Admins or Founders can moderate reviews.',
      );
    }

    final propReview = _propertyReviews[reviewId];
    if (propReview != null) {
      _propertyReviews[reviewId] = propReview.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }

    final sellerReview = _sellerReviews[reviewId];
    if (sellerReview != null) {
      _sellerReviews[reviewId] = sellerReview.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    }

    if (_supabaseService != null && _supabaseService.isInitialized) {
      try {
        await _supabaseService
            .from('property_reviews')
            .update({'status': newStatus.name.toUpperCase()})
            .eq('id', reviewId);
        await _supabaseService
            .from('seller_reviews')
            .update({'status': newStatus.name.toUpperCase()})
            .eq('id', reviewId);
      } catch (_) {}
    }
  }
}
