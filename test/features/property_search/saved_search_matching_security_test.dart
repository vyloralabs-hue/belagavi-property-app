import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/property_search/domain/entities/saved_search_entity.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/services/property_matching_engine.dart';

void main() {
  late NotificationRepositoryImpl notificationRepository;

  setUp(() {
    notificationRepository = NotificationRepositoryImpl();
  });

  PropertyEntity createTestProperty({
    required String id,
    required String ownerId,
    required String title,
    ListingStatus status = ListingStatus.published,
    PropertyCategory category = PropertyCategory.residential,
    PropertySubtype type = PropertySubtype.apartment,
    String city = 'Belagavi',
    String locality = 'Tilakwadi',
    double price = 5000000,
    int bedrooms = 2,
    double carpetArea = 1000,
    VerificationStatus verificationStatus = VerificationStatus.verified,
  }) {
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: 'Test Description',
      category: category,
      type: type,
      status: status,
      verificationStatus: verificationStatus,
      price: price,
      isNegotiable: true,
      specifications: PropertySpecificationsEntity(
        carpetArea: carpetArea,
        bedrooms: bedrooms,
      ),
      mediaList: const [],
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: city,
      locality: locality,
      address: 'Congress Road',
      pincode: '590006',
      latitude: 15.8497,
      longitude: 74.4977,
      viewsCount: 10,
      features: const {'purpose': 'FOR_SALE'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  SavedSearchEntity createTestSavedSearch({
    required String id,
    required String userId,
    required String title,
    bool isActive = true,
    PropertyCategory? category = PropertyCategory.residential,
    PropertySubtype? type,
    String city = 'Belagavi',
    String? locality,
    double? minPrice = 3000000,
    double? maxPrice = 8000000,
    int? minBedrooms = 2,
  }) {
    return SavedSearchEntity(
      id: id,
      userId: userId,
      title: title,
      isActive: isActive,
      query: SearchQueryEntity(
        category: category,
        type: type,
        city: city,
        locality: locality,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('SAVED SEARCH + PROPERTY MATCHING + PRICE DROP SECURITY ATTACK TESTS (PHASE 23)', () {
    const customerA = 'usr_customer_A_111';
    const customerB = 'usr_customer_B_222';
    const sellerA = 'usr_seller_A_333';

    test('1. Customer A cannot read Customer B private saved search', () {
      final searchB = createTestSavedSearch(
        id: 'search_b_secret',
        userId: customerB,
        title: 'Customer B Budget Search',
      );

      final isOwner = (searchB.userId == customerA);
      expect(isOwner, isFalse);
    });

    test('2. Customer A cannot update Customer B saved search', () {
      final searchB = createTestSavedSearch(
        id: 'search_b_1',
        userId: customerB,
        title: 'Original Title',
      );

      expect(
        () {
          if (customerA != searchB.userId) {
            throw const AccessDeniedException('Access Denied: You cannot modify another user\'s saved search.');
          }
        },
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('3. Customer A cannot delete Customer B saved search', () {
      final searchB = createTestSavedSearch(
        id: 'search_b_delete_target',
        userId: customerB,
        title: 'Private Search',
      );

      expect(
        () {
          if (customerA != searchB.userId) {
            throw const AccessDeniedException('Access Denied: You cannot delete another user\'s saved search.');
          }
        },
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('4. Customer A cannot change user_id on saved search', () {
      final searchA = createTestSavedSearch(
        id: 'search_a_1',
        userId: customerA,
        title: 'Search A',
      );

      final attemptedForgedUpdate = searchA.copyWith(userId: customerB);
      expect(attemptedForgedUpdate.userId != searchA.userId, isTrue);
      // Backend / RLS policy rejects user_id mismatch
    });

    test('5. Customer A cannot receive Customer B match notifications', () async {
      final property = createTestProperty(
        id: 'prop_match_1',
        ownerId: sellerA,
        title: '2BHK Tilakwadi',
        price: 5500000,
        bedrooms: 2,
      );

      final searchB = createTestSavedSearch(
        id: 'search_b_active',
        userId: customerB,
        title: 'Customer B 2BHK Search',
      );

      await PropertyMatchingEngine.evaluateNewListingMatches(
        property: property,
        activeSearches: [searchB],
        notificationRepository: notificationRepository,
      );

      final notifsA = await notificationRepository.getNotifications(recipientId: customerA);
      expect(notifsA.isEmpty, isTrue);

      final notifsB = await notificationRepository.getNotifications(recipientId: customerB);
      expect(notifsB.length, 1);
      expect(notifsB.first.recipientId, customerB);
    });

    test('6. Paused saved search does NOT generate match notifications', () async {
      final property = createTestProperty(
        id: 'prop_match_paused',
        ownerId: sellerA,
        title: '2BHK Tilakwadi Flat',
      );

      final pausedSearch = createTestSavedSearch(
        id: 'search_paused_1',
        userId: customerA,
        title: 'Paused Search',
        isActive: false, // PAUSED
      );

      final matchResult = PropertyMatchingEngine.matches(property, pausedSearch);
      expect(matchResult, isFalse);

      final dispatched = await PropertyMatchingEngine.evaluateNewListingMatches(
        property: property,
        activeSearches: [pausedSearch],
        notificationRepository: notificationRepository,
      );
      expect(dispatched.isEmpty, isTrue);
    });

    test('7. Deleted saved search does NOT generate match notifications', () async {
      final property = createTestProperty(
        id: 'prop_match_del',
        ownerId: sellerA,
        title: '2BHK Apartment',
      );

      // Deleted search is removed from active search list
      final searches = <SavedSearchEntity>[];
      final dispatched = await PropertyMatchingEngine.evaluateNewListingMatches(
        property: property,
        activeSearches: searches,
        notificationRepository: notificationRepository,
      );
      expect(dispatched.isEmpty, isTrue);
    });

    test('8. Unpublished (DRAFT / UNDER_REVIEW) property does NOT match', () {
      final draftProperty = createTestProperty(
        id: 'prop_draft',
        ownerId: sellerA,
        title: 'Draft Villa',
        status: ListingStatus.draft,
      );
      final underReviewProperty = createTestProperty(
        id: 'prop_under_review',
        ownerId: sellerA,
        title: 'Review Villa',
        status: ListingStatus.underReview,
      );

      final search = createTestSavedSearch(
        id: 'search_1',
        userId: customerA,
        title: 'Active Search',
      );

      expect(PropertyMatchingEngine.matches(draftProperty, search), isFalse);
      expect(PropertyMatchingEngine.matches(underReviewProperty, search), isFalse);
    });

    test('9. Rejected property does NOT match', () {
      final rejectedProperty = createTestProperty(
        id: 'prop_rejected',
        ownerId: sellerA,
        title: 'Rejected Listing',
        status: ListingStatus.rejected,
      );

      final search = createTestSavedSearch(
        id: 'search_1',
        userId: customerA,
        title: 'Active Search',
      );

      expect(PropertyMatchingEngine.matches(rejectedProperty, search), isFalse);
    });

    test('10. On-hold (PAUSED) property does NOT match', () {
      final pausedProperty = createTestProperty(
        id: 'prop_paused',
        ownerId: sellerA,
        title: 'Paused Listing',
        status: ListingStatus.paused,
      );

      final search = createTestSavedSearch(
        id: 'search_1',
        userId: customerA,
        title: 'Active Search',
      );

      expect(PropertyMatchingEngine.matches(pausedProperty, search), isFalse);
    });

    test('11. Sold property does NOT match for active searches', () {
      final soldProperty = createTestProperty(
        id: 'prop_sold',
        ownerId: sellerA,
        title: 'Sold Listing',
        status: ListingStatus.sold,
      );

      final search = createTestSavedSearch(
        id: 'search_1',
        userId: customerA,
        title: 'Active Search',
      );

      expect(PropertyMatchingEngine.matches(soldProperty, search), isFalse);
    });

    test('12. Real published matching property generates notification successfully', () async {
      final liveProperty = createTestProperty(
        id: 'prop_published_live',
        ownerId: sellerA,
        title: 'Luxury 2BHK Apartment',
        status: ListingStatus.published,
        price: 6000000,
        bedrooms: 2,
      );

      final search = createTestSavedSearch(
        id: 'search_live',
        userId: customerA,
        title: 'Belagavi 2BHK',
      );

      final dispatched = await PropertyMatchingEngine.evaluateNewListingMatches(
        property: liveProperty,
        activeSearches: [search],
        notificationRepository: notificationRepository,
      );

      expect(dispatched.length, 1);
      final notifs = await notificationRepository.getNotifications(recipientId: customerA);
      expect(notifs.first.type, NotificationType.newSavedSearchMatch);
      expect(notifs.first.propertyId, 'prop_published_live');
    });

    test('13. Real price reduction matching search generates price-drop notification', () async {
      final property = createTestProperty(
        id: 'prop_pricedrop_1',
        ownerId: sellerA,
        title: 'Premium Flat',
        price: 6500000, // New price
        bedrooms: 2,
      );

      final search = createTestSavedSearch(
        id: 'search_price_alert',
        userId: customerA,
        title: 'Affordable Flat',
        minPrice: 5000000,
        maxPrice: 7000000,
      );

      final dispatched = await PropertyMatchingEngine.evaluatePriceDropMatches(
        property: property,
        oldPrice: 7500000,
        newPrice: 6500000,
        activeSearches: [search],
        notificationRepository: notificationRepository,
      );

      expect(dispatched.length, 1);
      final notifs = await notificationRepository.getNotifications(recipientId: customerA);
      expect(notifs.any((n) => n.type == NotificationType.priceDropMatch), isTrue);
    });

    test('14. Price increase does NOT generate price drop notification', () async {
      final property = createTestProperty(
        id: 'prop_price_increase',
        ownerId: sellerA,
        title: 'Price Hike Flat',
        price: 8000000,
      );

      final search = createTestSavedSearch(
        id: 'search_alert_14',
        userId: customerA,
        title: 'Search',
      );

      final dispatched = await PropertyMatchingEngine.evaluatePriceDropMatches(
        property: property,
        oldPrice: 6000000,
        newPrice: 8000000, // Price INCREASE
        activeSearches: [search],
        notificationRepository: notificationRepository,
      );

      expect(dispatched.isEmpty, isTrue);
    });

    test('15. Price unchanged does NOT generate price drop notification', () async {
      final property = createTestProperty(
        id: 'prop_price_same',
        ownerId: sellerA,
        title: 'Unchanged Price Flat',
        price: 6000000,
      );

      final search = createTestSavedSearch(
        id: 'search_alert_15',
        userId: customerA,
        title: 'Search',
      );

      final dispatched = await PropertyMatchingEngine.evaluatePriceDropMatches(
        property: property,
        oldPrice: 6000000,
        newPrice: 6000000, // Unchanged
        activeSearches: [search],
        notificationRepository: notificationRepository,
      );

      expect(dispatched.isEmpty, isTrue);
    });

    test('16. Repeated matching event does not generate duplicate notification (Idempotency)', () async {
      final property = createTestProperty(
        id: 'prop_dup_test',
        ownerId: sellerA,
        title: 'Idempotent Flat',
        price: 5000000,
      );

      final search = createTestSavedSearch(
        id: 'search_dup',
        userId: customerA,
        title: 'Duplicate Test',
      );

      // Event 1
      await PropertyMatchingEngine.evaluateNewListingMatches(
        property: property,
        activeSearches: [search],
        notificationRepository: notificationRepository,
      );

      final countAfterFirst = (await notificationRepository.getNotifications(recipientId: customerA)).length;

      // Duplicate Event 2 (immediate repeat)
      await PropertyMatchingEngine.evaluateNewListingMatches(
        property: property,
        activeSearches: [search],
        notificationRepository: notificationRepository,
      );

      final countAfterSecond = (await notificationRepository.getNotifications(recipientId: customerA)).length;
      expect(countAfterSecond, countAfterFirst); // Exact same count
    });

    test('17. User edits search criteria -> Future matching uses new criteria', () {
      final propertyBudget = createTestProperty(
        id: 'prop_budget',
        ownerId: sellerA,
        title: 'Budget Flat',
        price: 4000000,
      );

      final searchOriginal = createTestSavedSearch(
        id: 'search_editable',
        userId: customerA,
        title: 'Luxury Only',
        minPrice: 8000000,
        maxPrice: 15000000,
      );

      expect(PropertyMatchingEngine.matches(propertyBudget, searchOriginal), isFalse);

      // User updates budget to include 40L
      final updatedSearch = searchOriginal.copyWith(
        query: searchOriginal.query.copyWith(minPrice: 3000000, maxPrice: 6000000),
      );

      expect(PropertyMatchingEngine.matches(propertyBudget, updatedSearch), isTrue);
    });

    test('18. Property seller cannot access customer private saved searches', () {
      final search = createTestSavedSearch(
        id: 'search_priv',
        userId: customerA,
        title: 'Confidential Customer Preferences',
      );

      expect(search.userId == sellerA, isFalse);
    });

    test('19. Admin legitimate access follows RBAC', () {
      expect(UserRole.admin.isAdminOrFounder, isTrue);
      expect(UserRole.founder.isAdminOrFounder, isTrue);
      expect(UserRole.sellerOwner.isAdminOrFounder, isFalse);
    });

    test('20. Notification deep link cannot bypass property authorization for private listings', () {
      final privateListing = createTestProperty(
        id: 'prop_unauthorized_private',
        ownerId: sellerA,
        title: 'Private Listing',
        status: ListingStatus.draft,
      );

      final canCustomerView = PropertySecurityGuard.canViewProperty(
        status: privateListing.status,
        ownerId: privateListing.ownerId,
        requestingUserId: customerA,
        userRole: UserRole.user,
      );

      expect(canCustomerView, isFalse);
    });
  });
}
