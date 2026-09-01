import 'package:equatable/equatable.dart';

enum VerificationSource {
  inquiry,
  siteVisit,
  chat,
  dealClosed,
}

extension VerificationSourceExtension on VerificationSource {
  String get displayName => switch (this) {
        VerificationSource.inquiry => 'Verified Inquiry',
        VerificationSource.siteVisit => 'Verified Site Visit',
        VerificationSource.chat => 'Verified Direct Chat',
        VerificationSource.dealClosed => 'Verified Deal Completed',
      };

  static VerificationSource fromString(String? val) {
    if (val == null) return VerificationSource.inquiry;
    return VerificationSource.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == val.toLowerCase() ||
          e.name.toLowerCase() == val.replaceAll('_', '').toLowerCase(),
      orElse: () => VerificationSource.inquiry,
    );
  }
}

enum ReviewStatus {
  published,
  pending,
  hidden,
  reported,
  removed,
  disputed,
}

extension ReviewStatusExtension on ReviewStatus {
  String get displayName => switch (this) {
        ReviewStatus.published => 'Published',
        ReviewStatus.pending => 'Pending Moderation',
        ReviewStatus.hidden => 'Hidden',
        ReviewStatus.reported => 'Reported',
        ReviewStatus.removed => 'Removed',
        ReviewStatus.disputed => 'Under Dispute',
      };

  static ReviewStatus fromString(String? val) {
    if (val == null) return ReviewStatus.published;
    return ReviewStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ReviewStatus.published,
    );
  }
}

enum ReportReason {
  spam,
  fakeReview,
  abuse,
  harassment,
  falseInformation,
  other,
}

enum ReportStatus {
  pending,
  investigating,
  resolved,
  dismissed,
}

enum TrustLevel {
  exemplary,
  trusted,
  verified,
  newSeller,
  underReview,
}

extension TrustLevelExtension on TrustLevel {
  String get displayName => switch (this) {
        TrustLevel.exemplary => 'Top Rated • Exemplary Trust',
        TrustLevel.trusted => 'Highly Trusted Seller',
        TrustLevel.verified => 'Verified Seller',
        TrustLevel.newSeller => 'New Seller',
        TrustLevel.underReview => 'Trust Score Under Review',
      };
}

class PropertyReviewEntity extends Equatable {
  final String id;
  final String propertyId;
  final String reviewerId;
  final String reviewerName;
  final String sellerId;
  final double rating;
  final String title;
  final String reviewText;
  final VerificationSource verificationSource;
  final String verificationReferenceId;
  final bool isVerifiedInteraction;
  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyReviewEntity({
    required this.id,
    required this.propertyId,
    required this.reviewerId,
    this.reviewerName = 'Verified Buyer',
    required this.sellerId,
    required this.rating,
    required this.title,
    required this.reviewText,
    required this.verificationSource,
    required this.verificationReferenceId,
    this.isVerifiedInteraction = true,
    this.status = ReviewStatus.published,
    required this.createdAt,
    required this.updatedAt,
  });

  PropertyReviewEntity copyWith({
    double? rating,
    String? title,
    String? reviewText,
    ReviewStatus? status,
    DateTime? updatedAt,
  }) {
    return PropertyReviewEntity(
      id: id,
      propertyId: propertyId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      sellerId: sellerId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      reviewText: reviewText ?? this.reviewText,
      verificationSource: verificationSource,
      verificationReferenceId: verificationReferenceId,
      isVerifiedInteraction: isVerifiedInteraction,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'reviewer_id': reviewerId,
        'seller_id': sellerId,
        'rating': rating,
        'title': title,
        'review_text': reviewText,
        'verification_source': verificationSource.name,
        'verification_reference_id': verificationReferenceId,
        'is_verified_interaction': isVerifiedInteraction,
        'status': status.name.toUpperCase(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PropertyReviewEntity.fromJson(Map<String, dynamic> json) {
    return PropertyReviewEntity(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewerName: (json['reviewer_name'] ?? 'Verified Buyer') as String,
      sellerId: json['seller_id'] as String,
      rating: ((json['rating'] ?? 5.0) as num).toDouble(),
      title: (json['title'] ?? '') as String,
      reviewText: (json['review_text'] ?? '') as String,
      verificationSource: VerificationSourceExtension.fromString(json['verification_source'] as String?),
      verificationReferenceId: (json['verification_reference_id'] ?? '') as String,
      isVerifiedInteraction: (json['is_verified_interaction'] ?? true) as bool,
      status: ReviewStatusExtension.fromString(json['status'] as String?),
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        reviewerId,
        reviewerName,
        sellerId,
        rating,
        title,
        reviewText,
        verificationSource,
        verificationReferenceId,
        isVerifiedInteraction,
        status,
        createdAt,
        updatedAt,
      ];
}

class SellerReviewEntity extends Equatable {
  final String id;
  final String sellerId;
  final String reviewerId;
  final String reviewerName;
  final String? propertyId;
  final String propertyTitle;
  final double rating;
  final String reviewText;
  final VerificationSource verificationSource;
  final String verificationReferenceId;
  final bool isVerifiedInteraction;
  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerReviewEntity({
    required this.id,
    required this.sellerId,
    required this.reviewerId,
    this.reviewerName = 'Verified Customer',
    this.propertyId,
    this.propertyTitle = 'Property',
    required this.rating,
    required this.reviewText,
    required this.verificationSource,
    required this.verificationReferenceId,
    this.isVerifiedInteraction = true,
    this.status = ReviewStatus.published,
    required this.createdAt,
    required this.updatedAt,
  });

  SellerReviewEntity copyWith({
    double? rating,
    String? reviewText,
    ReviewStatus? status,
    DateTime? updatedAt,
  }) {
    return SellerReviewEntity(
      id: id,
      sellerId: sellerId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      verificationSource: verificationSource,
      verificationReferenceId: verificationReferenceId,
      isVerifiedInteraction: isVerifiedInteraction,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seller_id': sellerId,
        'reviewer_id': reviewerId,
        'property_id': propertyId,
        'rating': rating,
        'review_text': reviewText,
        'verification_source': verificationSource.name,
        'verification_reference_id': verificationReferenceId,
        'is_verified_interaction': isVerifiedInteraction,
        'status': status.name.toUpperCase(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory SellerReviewEntity.fromJson(Map<String, dynamic> json) {
    return SellerReviewEntity(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewerName: (json['reviewer_name'] ?? 'Verified Customer') as String,
      propertyId: json['property_id'] as String?,
      propertyTitle: (json['property_title'] ?? 'Property') as String,
      rating: ((json['rating'] ?? 5.0) as num).toDouble(),
      reviewText: (json['review_text'] ?? '') as String,
      verificationSource: VerificationSourceExtension.fromString(json['verification_source'] as String?),
      verificationReferenceId: (json['verification_reference_id'] ?? '') as String,
      isVerifiedInteraction: (json['is_verified_interaction'] ?? true) as bool,
      status: ReviewStatusExtension.fromString(json['status'] as String?),
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerId,
        reviewerId,
        reviewerName,
        propertyId,
        propertyTitle,
        rating,
        reviewText,
        verificationSource,
        verificationReferenceId,
        isVerifiedInteraction,
        status,
        createdAt,
        updatedAt,
      ];
}

class SellerTrustScoreEntity extends Equatable {
  final String sellerId;
  final double averageRating;
  final int totalReviews;
  final int verifiedReviewCount;
  final Map<int, int> ratingBreakdown; // 5: 10, 4: 2, etc.
  final TrustLevel trustLevel;

  const SellerTrustScoreEntity({
    required this.sellerId,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.verifiedReviewCount = 0,
    this.ratingBreakdown = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    this.trustLevel = TrustLevel.newSeller,
  });

  @override
  List<Object?> get props => [
        sellerId,
        averageRating,
        totalReviews,
        verifiedReviewCount,
        ratingBreakdown,
        trustLevel,
      ];
}

class PropertyRatingSummaryEntity extends Equatable {
  final String propertyId;
  final double averageRating;
  final int reviewCount;
  final int verifiedReviewCount;
  final Map<int, int> ratingBreakdown;

  const PropertyRatingSummaryEntity({
    required this.propertyId,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.verifiedReviewCount = 0,
    this.ratingBreakdown = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  });

  @override
  List<Object?> get props => [
        propertyId,
        averageRating,
        reviewCount,
        verifiedReviewCount,
        ratingBreakdown,
      ];
}

class ReviewReportEntity extends Equatable {
  final String id;
  final String reviewId;
  final String reviewType; // 'PROPERTY', 'SELLER'
  final String reporterId;
  final ReportReason reason;
  final String? details;
  final ReportStatus status;
  final String? moderatorNotes;
  final DateTime createdAt;

  const ReviewReportEntity({
    required this.id,
    required this.reviewId,
    required this.reviewType,
    required this.reporterId,
    required this.reason,
    this.details,
    this.status = ReportStatus.pending,
    this.moderatorNotes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        reviewId,
        reviewType,
        reporterId,
        reason,
        details,
        status,
        moderatorNotes,
        createdAt,
      ];
}
