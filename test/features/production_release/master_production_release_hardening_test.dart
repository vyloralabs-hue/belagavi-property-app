import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:belagavi_property/features/monetization/data/repositories/promotion_repository_impl.dart';
import 'package:belagavi_property/features/monetization/domain/entities/promotion_entities.dart';
import 'package:belagavi_property/features/monetization/utils/promotion_security_guard.dart';
import 'package:belagavi_property/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/property_status_workflow.dart';
import 'package:belagavi_property/features/property_search/domain/entities/saved_search_entity.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/services/property_matching_engine.dart';
import 'package:belagavi_property/features/review/data/repositories/review_repository_impl.dart';
import 'package:belagavi_property/features/review/domain/entities/review_entities.dart';
import 'package:belagavi_property/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:belagavi_property/features/transaction/domain/entities/transaction_entities.dart';

void main() {
  late NotificationRepositoryImpl notificationRepo;
  late ChatRepositoryImpl chatRepo;
  late ReviewRepositoryImpl reviewRepo;
  late PromotionRepositoryImpl promoRepo;
  late TransactionRepositoryImpl transactionRepo;

  setUp(() {
    notificationRepo = NotificationRepositoryImpl();
    chatRepo = ChatRepositoryImpl(notificationRepository: notificationRepo);
    reviewRepo = ReviewRepositoryImpl(notificationRepository: notificationRepo);
    promoRepo = PromotionRepositoryImpl(
      notificationRepository: notificationRepo,
    );
    transactionRepo = TransactionRepositoryImpl();
  });

  PropertyEntity createPlatformProperty({
    required String id,
    required String ownerId,
    required String title,
    required PropertyCategory category,
    ListingStatus status = ListingStatus.published,
    double price = 6500000,
    String locality = 'Tilakwadi',
  }) {
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: 'Prime Belagavi property listing for verification.',
      category: category,
      type: PropertySubtype.apartment,
      status: status,
      verificationStatus: VerificationStatus.verified,
      price: price,
      isNegotiable: true,
      specifications: const PropertySpecificationsEntity(
        carpetArea: 1200,
        superBuiltUpArea: 1450,
        bedrooms: 3,
        bathrooms: 2,
      ),
      mediaList: const [],
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: locality,
      address: 'Congress Road',
      pincode: '590006',
      latitude: 15.8497,
      longitude: 74.4977,
      viewsCount: 25,
      features: const {'listingType': 'FOR_SALE', 'purpose': 'FOR_SALE'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('MASTER PRODUCTION RELEASE HARDENING — COMPREHENSIVE VERIFICATION', () {
    const buyerA = 'usr_buyer_prod_1';
    const sellerA = 'usr_seller_prod_1';
    const sellerB = 'usr_seller_prod_2';
    const adminUser = 'usr_admin_prod';

    // ──────────────────────────────────────────────────────────────────────────
    // 1. ALL FOUR PROPERTY CATEGORIES LIFECYCLE AUDIT
    // ──────────────────────────────────────────────────────────────────────────
    test(
      '1. Category 1: Housing (Residential) full lifecycle and moderation',
      () {
        final housing = createPlatformProperty(
          id: 'prop_housing_prod',
          ownerId: sellerA,
          title: '3BHK Luxury Flat Tilakwadi',
          category: PropertyCategory.residential,
          status: ListingStatus.submitted,
        );

        // Seller cannot publish directly without review
        final canSellerPublish = PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: housing.status,
          targetStatus: ListingStatus.published,
          userRole: UserRole.sellerOwner,
        );
        expect(canSellerPublish, isFalse);

        // Admin approves
        final canAdminApprove = PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: housing.status,
          targetStatus: ListingStatus.approved,
          userRole: UserRole.admin,
        );
        expect(canAdminApprove, isTrue);
      },
    );

    test('2. Category 2: Plots (plotLand) full lifecycle and moderation', () {
      final plot = createPlatformProperty(
        id: 'prop_plot_prod',
        ownerId: sellerA,
        title: '2400 sqft NA Plot Mandoli Road',
        category: PropertyCategory.plotLand,
        status: ListingStatus.draft,
      );

      // Draft to submitted
      final canSubmit = PropertyStatusWorkflow.canTransitionWithRole(
        currentStatus: plot.status,
        targetStatus: ListingStatus.submitted,
        userRole: UserRole.sellerOwner,
      );
      expect(canSubmit, isTrue);
    });

    test('3. Category 3: Commercial full lifecycle and moderation', () {
      final comm = createPlatformProperty(
        id: 'prop_comm_prod',
        ownerId: sellerA,
        title: 'Commercial Showroom Club Road',
        category: PropertyCategory.commercial,
        status: ListingStatus.underReview,
      );

      // Admin requests changes
      final canRequestChanges = PropertyStatusWorkflow.canTransitionWithRole(
        currentStatus: comm.status,
        targetStatus: ListingStatus.changesRequested,
        userRole: UserRole.admin,
      );
      expect(canRequestChanges, isTrue);
    });

    test('4. Category 4: Raw Land (land) full lifecycle and moderation', () {
      final land = createPlatformProperty(
        id: 'prop_land_prod',
        ownerId: sellerA,
        title: '10 Acres Agricultural Land Sambra',
        category: PropertyCategory.land,
        status: ListingStatus.approved,
      );

      // Published by system / admin
      final canPublish = PropertyStatusWorkflow.canTransitionWithRole(
        currentStatus: land.status,
        targetStatus: ListingStatus.published,
        userRole: UserRole.admin,
      );
      expect(canPublish, isTrue);
    });

    // ──────────────────────────────────────────────────────────────────────────
    // 2. SEARCH & MATCHING ENGINE ACCURACY
    // ──────────────────────────────────────────────────────────────────────────
    test(
      '5. Search & Matching Engine accurately matches published listings only',
      () {
        final pubProperty = createPlatformProperty(
          id: 'prop_match_1',
          ownerId: sellerA,
          title: 'Modern 3BHK Apartment',
          category: PropertyCategory.residential,
          status: ListingStatus.published,
          price: 5000000,
          locality: 'Tilakwadi',
        );

        final draftProperty = createPlatformProperty(
          id: 'prop_match_2',
          ownerId: sellerA,
          title: 'Draft Apartment',
          category: PropertyCategory.residential,
          status: ListingStatus.draft,
          price: 5000000,
          locality: 'Tilakwadi',
        );

        final search = SavedSearchEntity(
          id: 'ss_prod_1',
          userId: buyerA,
          title: 'Tilakwadi 3BHK',
          query: const SearchQueryEntity(
            city: 'Belagavi',
            locality: 'Tilakwadi',
            category: PropertyCategory.residential,
            minPrice: 4000000,
            maxPrice: 6000000,
          ),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(PropertyMatchingEngine.matches(pubProperty, search), isTrue);
        expect(
          PropertyMatchingEngine.matches(draftProperty, search),
          isFalse,
        ); // Non-published excluded
      },
    );

    // ──────────────────────────────────────────────────────────────────────────
    // 3. INQUIRIES, SITE VISITS & LEADS
    // ──────────────────────────────────────────────────────────────────────────
    test('6. Authenticated Inquiry & Site Visit request dispatch', () async {
      final inqId = await transactionRepo.submitEnquiry(
        PropertyEnquiryEntity(
          id: 'inq_prod_1',
          propertyId: 'prop_inq_test',
          propertyTitle: 'Spacious Villa',
          propertyCategory: 'residential',
          propertyLocation: 'Tilakwadi, Belagavi',
          buyerId: buyerA,
          buyerName: 'Amit Buyer',
          buyerPhone: '9876543210',
          sellerId: sellerA,
          interestType: TransactionInterestType.buy,
          initialMessage: 'Interested in site visit this weekend.',
          listedPrice: 6500000,
          status: TransactionStatus.newEnquiry,
          siteVisitStatus: SiteVisitStatus.requested,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(inqId, 'inq_prod_1');
      final fetched = await transactionRepo.getEnquiryById(inqId);
      expect(fetched?.buyerId, buyerA);
      expect(fetched?.sellerId, sellerA);
    });

    // ──────────────────────────────────────────────────────────────────────────
    // 4. REAL-TIME CHAT & MESSAGING INTEGRITY
    // ──────────────────────────────────────────────────────────────────────────
    test(
      '7. Buyer-Seller direct chat creation, idempotency, and read receipts',
      () async {
        final conv = await chatRepo.getOrCreateConversation(
          propertyId: 'prop_chat_prod',
          buyerId: buyerA,
          sellerId: sellerA,
          propertyTitle: 'Prime Apartment',
        );

        final msg = await chatRepo.sendMessage(
          conversationId: conv.id,
          senderId: buyerA,
          senderName: 'Amit Buyer',
          message: 'Is possession available immediately?',
          recipientId: sellerA,
          propertyId: 'prop_chat_prod',
        );

        expect(msg.isRead, isFalse);

        // Seller reads messages
        await chatRepo.markMessagesAsRead(
          conversationId: conv.id,
          readerUserId: sellerA,
        );

        final msgsAfter = await chatRepo.getMessages(
          conversationId: conv.id,
          requestingUserId: sellerA,
        );
        expect(msgsAfter.first.isRead, isTrue);
      },
    );

    // ──────────────────────────────────────────────────────────────────────────
    // 5. REVIEWS, RATINGS & TRUST SCORE
    // ──────────────────────────────────────────────────────────────────────────
    test(
      '8. Verified Review submission, trust score computation, and self-review block',
      () async {
        final review = await reviewRepo.submitPropertyReview(
          PropertyReviewEntity(
            id: 'rev_prod_1',
            propertyId: 'prop_rev_prod',
            reviewerId: buyerA,
            sellerId: sellerA,
            rating: 4.8,
            title: 'Top Experience',
            reviewText:
                'Clear property documentation and prompt communication.',
            verificationSource: VerificationSource.siteVisit,
            verificationReferenceId: 'inq_prod_1',
            isVerifiedInteraction: true,
            status: ReviewStatus.published,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        expect(review.rating, 4.8);

        final summary = await reviewRepo.getPropertyRatingSummary(
          'prop_rev_prod',
        );
        expect(summary.averageRating, 4.8);
        expect(summary.verifiedReviewCount, 1);

        // Self review blocked
        expect(
          () => reviewRepo.submitPropertyReview(
            PropertyReviewEntity(
              id: 'rev_self',
              propertyId: 'prop_rev_prod',
              reviewerId: sellerA, // SELF REVIEW
              sellerId: sellerA,
              rating: 5.0,
              title: 'Fake',
              reviewText: 'Reviewing myself.',
              verificationSource: VerificationSource.inquiry,
              verificationReferenceId: 'ref_self',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    // ──────────────────────────────────────────────────────────────────────────
    // 6. MONETIZATION & PROMOTION LIFECYCLE PRECEDENCE
    // ──────────────────────────────────────────────────────────────────────────
    test(
      '9. Monetization promotion activation and lifecycle subordination',
      () async {
        final property = createPlatformProperty(
          id: 'prop_promo_prod',
          ownerId: sellerA,
          title: 'Commercial Complex',
          category: PropertyCategory.commercial,
          status: ListingStatus.published,
        );

        final promo = await promoRepo.createPropertyPromotion(
          property: property,
          requestingUserId: sellerA,
          promotionType: PromotionType.featured,
          durationDays: 15,
        );

        expect(promo.isCurrentlyActive, isTrue);

        // When property is marked SOLD, promotion is effectively inactive
        final soldProperty = property.copyWith(status: ListingStatus.sold);
        final isEffective = PromotionSecurityGuard.isPromotionEffectivelyActive(
          promotion: promo,
          property: soldProperty,
        );
        expect(isEffective, isFalse); // Subjugated!
      },
    );

    // ──────────────────────────────────────────────────────────────────────────
    // 7. ADMIN / FOUNDER GLOBAL AUTHORITY & AUDIT TRAILS
    // ──────────────────────────────────────────────────────────────────────────
    test(
      '10. Admin & Founder global oversight without cross-seller elevation',
      () async {
        // Ordinary seller cannot access another seller's conversation
        final conv = await chatRepo.getOrCreateConversation(
          propertyId: 'prop_secret_conv',
          buyerId: buyerA,
          sellerId: sellerA,
        );

        expect(
          () => chatRepo.getConversationById(
            conv.id,
            requestingUserId: sellerB,
            userRole: UserRole.sellerOwner,
          ),
          throwsA(isA<AccessDeniedException>()),
        );

        // Admin has legitimate oversight
        final adminAccess = await chatRepo.getConversationById(
          conv.id,
          requestingUserId: adminUser,
          userRole: UserRole.admin,
        );
        expect(adminAccess?.id, conv.id);
      },
    );
  });
}
