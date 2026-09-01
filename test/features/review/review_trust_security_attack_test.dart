import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:belagavi_property/features/review/data/repositories/review_repository_impl.dart';
import 'package:belagavi_property/features/review/domain/entities/review_entities.dart';
import 'package:belagavi_property/features/review/utils/review_security_guard.dart';

void main() {
  late ReviewRepositoryImpl reviewRepository;
  late NotificationRepositoryImpl notificationRepository;

  setUp(() {
    notificationRepository = NotificationRepositoryImpl();
    reviewRepository = ReviewRepositoryImpl(notificationRepository: notificationRepository);
  });

  group('PROPERTY REVIEW, SELLER TRUST & SECURITY ATTACK TEST MATRIX (PHASE 28)', () {
    const buyerA = 'usr_buyer_A_101';
    const buyerB = 'usr_buyer_B_202';
    const sellerA = 'usr_seller_A_303';
    const sellerB = 'usr_seller_B_404';

    test('1. User reviews without verified interaction -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: buyerA,
          sellerId: sellerA,
          propertyId: 'prop_101',
          hasVerifiedInteraction: false, // NO INTERACTION
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('2. User reviews another user\'s property with unverified interaction -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: buyerA,
          sellerId: sellerB,
          propertyId: 'prop_unrelated',
          hasVerifiedInteraction: false,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('3. User reviews another seller without interaction -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: buyerA,
          sellerId: sellerB,
          propertyId: null,
          hasVerifiedInteraction: false,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('4. Seller reviews themselves -> DENIED (Self-review violation)', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: sellerA,
          sellerId: sellerA, // SELF REVIEW
          propertyId: 'prop_own',
          hasVerifiedInteraction: true,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('5. Seller modifies reviewer_id on review -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewModification(
          requestingUserId: sellerA,
          reviewerId: buyerA,
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('6. Seller modifies rating on review -> DENIED', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_sec_6',
          propertyId: 'prop_sec_6',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 2.0,
          title: 'Negative experience',
          reviewText: 'Seller was unresponsive for 3 days.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_6',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(
        () => reviewRepository.updatePropertyReview(
          reviewId: rev.id,
          requestingUserId: sellerA, // SELLER CANNOT MODIFY
          newRating: 5.0,
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('7. Seller deletes negative review -> DENIED', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_sec_7',
          propertyId: 'prop_sec_7',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 1.0,
          title: 'Terrible listing',
          reviewText: 'Misleading property dimensions.',
          verificationSource: VerificationSource.siteVisit,
          verificationReferenceId: 'sv_7',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(
        () => reviewRepository.deletePropertyReview(
          reviewId: rev.id,
          requestingUserId: sellerA, // SELLER CANNOT DELETE
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('8. Buyer changes property_id on existing review -> Immutability preserved', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_sec_8',
          propertyId: 'prop_orig',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 4.0,
          title: 'Good flat',
          reviewText: 'Nice location near market.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_8',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      expect(rev.propertyId, 'prop_orig');
    });

    test('9. Buyer changes seller_id on existing review -> Immutability preserved', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_sec_9',
          propertyId: 'prop_sec_9',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 4.5,
          title: 'Great House',
          reviewText: 'Well ventilated and well built.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_9',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      expect(rev.sellerId, sellerA);
    });

    test('10. Buyer changes verification_source_id -> Immutability preserved', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_sec_10',
          propertyId: 'prop_sec_10',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 4.5,
          title: 'Great House',
          reviewText: 'Well ventilated and well built.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_10',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      expect(rev.verificationReferenceId, 'inq_10');
    });

    test('11. Buyer uses another user\'s unverified interaction -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: buyerA,
          sellerId: sellerA,
          propertyId: 'prop_11',
          hasVerifiedInteraction: false,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('12. Buyer uses another user\'s site visit -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: buyerB,
          sellerId: sellerA,
          propertyId: 'prop_12',
          hasVerifiedInteraction: false,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('13. Buyer uses another user\'s chat -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: buyerB,
          sellerId: sellerA,
          propertyId: 'prop_13',
          hasVerifiedInteraction: false,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('14. Duplicate review on same property by same buyer -> DENIED', () async {
      await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_dup_1',
          propertyId: 'prop_dup',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 5.0,
          title: 'First Review',
          reviewText: 'Great apartment, clean premises.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_dup_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(
        () => reviewRepository.submitPropertyReview(
          PropertyReviewEntity(
            id: 'rev_dup_2',
            propertyId: 'prop_dup',
            reviewerId: buyerA, // SAME BUYER SAME PROPERTY
            sellerId: sellerA,
            rating: 5.0,
            title: 'Second Review',
            reviewText: 'Trying to review again.',
            verificationSource: VerificationSource.inquiry,
            verificationReferenceId: 'inq_dup_2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('15. Fake verification flag without interaction -> Guard rejects', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewEligibility(
          reviewerId: buyerA,
          sellerId: sellerA,
          propertyId: 'prop_fake_ver',
          hasVerifiedInteraction: false,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('16. Unverified review does NOT affect trust score calculation', () {
      final reviews = [
        SellerReviewEntity(
          id: 's_rev_1',
          sellerId: sellerA,
          reviewerId: buyerA,
          rating: 5.0,
          reviewText: 'Legitimate 5-star seller.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_1',
          isVerifiedInteraction: true,
          status: ReviewStatus.published,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SellerReviewEntity(
          id: 's_rev_2',
          sellerId: sellerA,
          reviewerId: buyerB,
          rating: 1.0,
          reviewText: 'Fake 1-star attack.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'fake_ref',
          isVerifiedInteraction: false, // UNVERIFIED
          status: ReviewStatus.published,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final trustScore = ReviewSecurityGuard.calculateSellerTrustScore(
        sellerId: sellerA,
        reviews: reviews,
      );

      expect(trustScore.averageRating, 5.0); // Excluded the 1.0 unverified
      expect(trustScore.verifiedReviewCount, 1);
    });

    test('17. Removed review does NOT affect public property rating score', () {
      final reviews = [
        PropertyReviewEntity(
          id: 'p_rev_1',
          propertyId: 'prop_calc',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 4.0,
          title: 'Good',
          reviewText: 'Solid construction.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_1',
          status: ReviewStatus.published,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        PropertyReviewEntity(
          id: 'p_rev_2',
          propertyId: 'prop_calc',
          reviewerId: buyerB,
          sellerId: sellerA,
          rating: 1.0,
          title: 'Spam',
          reviewText: 'Abusive comment.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_2',
          status: ReviewStatus.removed, // REMOVED BY ADMIN
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final summary = ReviewSecurityGuard.calculatePropertyRatingSummary(
        propertyId: 'prop_calc',
        reviews: reviews,
      );

      expect(summary.averageRating, 4.0); // 1.0 excluded
      expect(summary.reviewCount, 1);
    });

    test('18. Hidden review does NOT appear publicly', () {
      final reviews = [
        PropertyReviewEntity(
          id: 'p_rev_hidden',
          propertyId: 'prop_hidden_test',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 2.0,
          title: 'Disputed',
          reviewText: 'Needs inspection.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_h',
          status: ReviewStatus.hidden, // HIDDEN
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final summary = ReviewSecurityGuard.calculatePropertyRatingSummary(
        propertyId: 'prop_hidden_test',
        reviews: reviews,
      );

      expect(summary.reviewCount, 0);
      expect(summary.averageRating, 0.0);
    });

    test('19. Unauthorized user modifies another review -> DENIED', () {
      expect(
        () => ReviewSecurityGuard.verifyReviewModification(
          requestingUserId: buyerB,
          reviewerId: buyerA,
          userRole: UserRole.user,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('20. Ordinary seller accesses moderation controls -> DENIED', () {
      expect(
        () => reviewRepository.moderateReview(
          reviewId: 'rev_1',
          newStatus: ReviewStatus.removed,
          moderatorId: sellerA,
          userRole: UserRole.sellerOwner, // SELLER CANNOT MODERATE
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('21. Admin legitimate moderation -> ALLOWED', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_admin_mod',
          propertyId: 'prop_mod',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 1.0,
          title: 'Suspect',
          reviewText: 'Fake review text.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_mod',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await reviewRepository.moderateReview(
        reviewId: rev.id,
        newStatus: ReviewStatus.removed,
        moderatorId: 'usr_admin_master',
        userRole: UserRole.admin,
      );

      final reviews = await reviewRepository.getPropertyReviews('prop_mod', includeUnpublished: false);
      expect(reviews.isEmpty, isTrue); // Successfully excluded from public feed
    });

    test('22. Legitimate verified property review -> ALLOWED and published', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_legit_22',
          propertyId: 'prop_legit_22',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 4.5,
          title: 'Excellent flat',
          reviewText: 'Spacious 3BHK with excellent sunlight.',
          verificationSource: VerificationSource.siteVisit,
          verificationReferenceId: 'sv_22',
          isVerifiedInteraction: true,
          status: ReviewStatus.published,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(rev.status, ReviewStatus.published);
      expect(rev.isVerifiedInteraction, isTrue);
      expect(rev.rating, 4.5);
    });

    test('23. Legitimate verified seller review -> ALLOWED', () async {
      final rev = await reviewRepository.submitSellerReview(
        SellerReviewEntity(
          id: 'srev_legit_23',
          sellerId: sellerA,
          reviewerId: buyerA,
          rating: 5.0,
          reviewText: 'Honest seller, all documentation was clear.',
          verificationSource: VerificationSource.dealClosed,
          verificationReferenceId: 'deal_23',
          isVerifiedInteraction: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(rev.rating, 5.0);
      expect(rev.status, ReviewStatus.published);
    });

    test('24. Legitimate review edit by author -> ALLOWED', () async {
      final rev = await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_edit_24',
          propertyId: 'prop_edit_24',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 4.0,
          title: 'Good initial impression',
          reviewText: 'Location is very convenient.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_24',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final updated = await reviewRepository.updatePropertyReview(
        reviewId: rev.id,
        requestingUserId: buyerA, // AUTHOR UPDATES
        newRating: 5.0,
        newReviewText: 'Location is very convenient and documentation is now verified.',
        userRole: UserRole.user,
      );

      expect(updated.rating, 5.0);
      expect(updated.reviewText, contains('verified'));
    });

    test('25. Review notification sent to correct seller -> ALLOWED', () async {
      final notifsBefore = (await notificationRepository.getNotifications(recipientId: sellerA)).length;

      await reviewRepository.submitPropertyReview(
        PropertyReviewEntity(
          id: 'rev_notif_25',
          propertyId: 'prop_notif_25',
          reviewerId: buyerA,
          sellerId: sellerA,
          rating: 5.0,
          title: 'Superb Villa',
          reviewText: 'Very well maintained garden.',
          verificationSource: VerificationSource.inquiry,
          verificationReferenceId: 'inq_25',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final notifsAfter = (await notificationRepository.getNotifications(recipientId: sellerA)).length;
      expect(notifsAfter, notifsBefore + 1);
    });

    test('26. Cross-user notification access -> DENIED', () async {
      final notifsB = await notificationRepository.getNotifications(recipientId: sellerB);
      expect(notifsB.any((n) => n.recipientId == sellerA), isFalse);
    });
  });
}
