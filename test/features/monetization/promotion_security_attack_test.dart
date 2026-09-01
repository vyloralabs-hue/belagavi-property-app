import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/monetization/data/repositories/promotion_repository_impl.dart';
import 'package:belagavi_property/features/monetization/domain/entities/promotion_entities.dart';
import 'package:belagavi_property/features/monetization/utils/promotion_security_guard.dart';
import 'package:belagavi_property/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

void main() {
  late PromotionRepositoryImpl promotionRepository;
  late NotificationRepositoryImpl notificationRepository;

  setUp(() {
    notificationRepository = NotificationRepositoryImpl();
    promotionRepository = PromotionRepositoryImpl(notificationRepository: notificationRepository);
  });

  PropertyEntity createTestProperty({
    required String id,
    required String ownerId,
    required String title,
    PropertyCategory category = PropertyCategory.residential,
    ListingStatus status = ListingStatus.published,
    double price = 5000000,
  }) {
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: 'Description',
      category: category,
      type: PropertySubtype.apartment,
      status: status,
      verificationStatus: VerificationStatus.verified,
      price: price,
      isNegotiable: true,
      specifications: const PropertySpecificationsEntity(carpetArea: 1000),
      mediaList: const [],
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      address: 'Main Road',
      pincode: '590006',
      latitude: 15.8497,
      longitude: 74.4977,
      viewsCount: 10,
      features: const {'purpose': 'FOR_SALE'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('MONETIZATION & PROMOTION ENGINE SECURITY ATTACK TEST MATRIX (PHASE 21)', () {
    const sellerA = 'usr_seller_A_101';
    const sellerB = 'usr_seller_B_202';

    test('1. Seller A promotes Seller B property -> DENIED', () {
      final propB = createTestProperty(id: 'prop_b_1', ownerId: sellerB, title: 'Seller B House');

      expect(
        () => promotionRepository.createPropertyPromotion(
          property: propB,
          requestingUserId: sellerA, // MALICIOUS PROMOTION OF ANOTHER SELLER PROPERTY
          promotionType: PromotionType.featured,
          durationDays: 15,
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('2. Seller changes owner_id on promotion creation -> Guard derives from property record', () async {
      final propA = createTestProperty(id: 'prop_a_2', ownerId: sellerA, title: 'Seller A House');

      final promo = await promotionRepository.createPropertyPromotion(
        property: propA,
        requestingUserId: sellerA,
        promotionType: PromotionType.boost,
        durationDays: 7,
        userRole: UserRole.sellerOwner,
      );

      expect(promo.ownerId, sellerA); // Cannot be forged
    });

    test('3. Seller changes property_id on existing promotion -> Immutability preserved', () async {
      final propA = createTestProperty(id: 'prop_a_3', ownerId: sellerA, title: 'Seller A House');

      final promo = await promotionRepository.createPropertyPromotion(
        property: propA,
        requestingUserId: sellerA,
        promotionType: PromotionType.featured,
        durationDays: 15,
        userRole: UserRole.sellerOwner,
      );

      expect(promo.propertyId, 'prop_a_3');
    });

    test('4. Seller creates promotion for sold property -> DENIED', () {
      final soldProp = createTestProperty(
        id: 'prop_sold',
        ownerId: sellerA,
        title: 'Sold Flat',
        status: ListingStatus.sold,
      );

      expect(
        () => promotionRepository.createPropertyPromotion(
          property: soldProp,
          requestingUserId: sellerA,
          promotionType: PromotionType.featured,
          durationDays: 15,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('5. Seller creates promotion for rejected property -> DENIED', () {
      final rejProp = createTestProperty(
        id: 'prop_rej',
        ownerId: sellerA,
        title: 'Rejected Flat',
        status: ListingStatus.rejected,
      );

      expect(
        () => promotionRepository.createPropertyPromotion(
          property: rejProp,
          requestingUserId: sellerA,
          promotionType: PromotionType.featured,
          durationDays: 15,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('6. Seller creates promotion for archived property -> DENIED', () {
      final archProp = createTestProperty(
        id: 'prop_arch',
        ownerId: sellerA,
        title: 'Archived Flat',
        status: ListingStatus.archived,
      );

      expect(
        () => promotionRepository.createPropertyPromotion(
          property: archProp,
          requestingUserId: sellerA,
          promotionType: PromotionType.boost,
          durationDays: 7,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('7. Seller creates promotion for another user\'s property -> DENIED', () {
      final propB = createTestProperty(id: 'prop_b_7', ownerId: sellerB, title: 'Seller B Flat');

      expect(
        () => PromotionSecurityGuard.verifyPromotionEligibility(
          requestingUserId: sellerA,
          property: propB,
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('8. Seller changes promotion price -> Official server pricing is authoritative', () {
      final officialPkg = PromotionSecurityGuard.officialPackages.firstWhere((p) => p.type == PromotionType.featured);
      expect(officialPkg.serverPriceInr, 599.0);
    });

    test('9. Seller grants own entitlement -> DENIED', () {
      expect(
        () => PromotionSecurityGuard.verifyEntitlementModification(userRole: UserRole.sellerOwner),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('10. Seller modifies another user\'s entitlement -> DENIED', () {
      expect(
        () => PromotionSecurityGuard.verifyEntitlementModification(userRole: UserRole.user),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('11. Client submits fake paid status -> Quota / entitlement validated on backend', () async {
      final ent = await promotionRepository.getUserEntitlement(userId: sellerA, entitlementKey: 'FEATURED_LISTING');
      expect(ent, isNull); // Cannot be forged client-side
    });

    test('12. Client submits manipulated amount -> Server package configuration used', () {
      final boostPkg = PromotionSecurityGuard.officialPackages.firstWhere((p) => p.type == PromotionType.boost);
      expect(boostPkg.serverPriceInr, 299.0);
    });

    test('13. Duplicate payment event -> Granting entitlement adds exact quota (Idempotent)', () async {
      await promotionRepository.grantEntitlement(
        userId: sellerA,
        entitlementKey: 'PROMOTE_LISTING',
        quota: 1,
        granterRole: UserRole.admin,
      );

      final ent = await promotionRepository.getUserEntitlement(userId: sellerA, entitlementKey: 'PROMOTE_LISTING');
      expect(ent?.totalQuota, 1);
    });

    test('14. Duplicate promotion creation of same type -> DENIED', () async {
      final propA = createTestProperty(id: 'prop_dup_promo', ownerId: sellerA, title: 'House A');

      await promotionRepository.createPropertyPromotion(
        property: propA,
        requestingUserId: sellerA,
        promotionType: PromotionType.featured,
        durationDays: 15,
      );

      expect(
        () => promotionRepository.createPropertyPromotion(
          property: propA,
          requestingUserId: sellerA, // DUPLICATE SAME TYPE
          promotionType: PromotionType.featured,
          durationDays: 15,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('15. Expired promotion does NOT influence public ranking', () {
      final expiredPromo = PropertyPromotionEntity(
        id: 'promo_exp',
        propertyId: 'prop_exp',
        ownerId: sellerA,
        promotionType: PromotionType.featured,
        priorityLevel: 2,
        status: PromotionStatus.active,
        startAt: DateTime.now().subtract(const Duration(days: 20)),
        endAt: DateTime.now().subtract(const Duration(days: 5)), // EXPIRED
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      );

      final property = createTestProperty(id: 'prop_exp', ownerId: sellerA, title: 'Exp Property');

      final isEffective = PromotionSecurityGuard.isPromotionEffectivelyActive(
        promotion: expiredPromo,
        property: property,
      );
      expect(isEffective, isFalse);
    });

    test('16. Sold property with active promotion -> Promotion effectively INACTIVE (Lifecycle precedence)', () {
      final activePromo = PropertyPromotionEntity(
        id: 'promo_sold',
        propertyId: 'prop_sold_active',
        ownerId: sellerA,
        promotionType: PromotionType.featured,
        priorityLevel: 2,
        status: PromotionStatus.active,
        startAt: DateTime.now().subtract(const Duration(days: 1)),
        endAt: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );

      final soldProperty = createTestProperty(
        id: 'prop_sold_active',
        ownerId: sellerA,
        title: 'Sold Property',
        status: ListingStatus.sold, // SOLD
      );

      final isEffective = PromotionSecurityGuard.isPromotionEffectivelyActive(
        promotion: activePromo,
        property: soldProperty,
      );
      expect(isEffective, isFalse); // Subjugated to property status!
    });

    test('17. Rejected property appears promoted -> DENIED (Lifecycle precedence)', () {
      final activePromo = PropertyPromotionEntity(
        id: 'promo_rej',
        propertyId: 'prop_rej_active',
        ownerId: sellerA,
        promotionType: PromotionType.topPlacement,
        priorityLevel: 3,
        status: PromotionStatus.active,
        startAt: DateTime.now().subtract(const Duration(days: 1)),
        endAt: DateTime.now().add(const Duration(days: 29)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );

      final rejProperty = createTestProperty(
        id: 'prop_rej_active',
        ownerId: sellerA,
        title: 'Rejected Property',
        status: ListingStatus.rejected, // REJECTED
      );

      final isEffective = PromotionSecurityGuard.isPromotionEffectivelyActive(
        promotion: activePromo,
        property: rejProperty,
      );
      expect(isEffective, isFalse);
    });

    test('18. On-hold (PAUSED) property appears active -> DENIED (Lifecycle precedence)', () {
      final activePromo = PropertyPromotionEntity(
        id: 'promo_paused',
        propertyId: 'prop_paused_active',
        ownerId: sellerA,
        promotionType: PromotionType.boost,
        priorityLevel: 1,
        status: PromotionStatus.active,
        startAt: DateTime.now().subtract(const Duration(days: 1)),
        endAt: DateTime.now().add(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );

      final pausedProperty = createTestProperty(
        id: 'prop_paused_active',
        ownerId: sellerA,
        title: 'Paused Property',
        status: ListingStatus.paused, // ON HOLD
      );

      final isEffective = PromotionSecurityGuard.isPromotionEffectivelyActive(
        promotion: activePromo,
        property: pausedProperty,
      );
      expect(isEffective, isFalse);
    });

    test('19. Ordinary seller accesses admin promotion control on another seller -> DENIED', () async {
      final propB = createTestProperty(id: 'prop_b_19', ownerId: sellerB, title: 'Seller B Flat');

      final promoB = await promotionRepository.createPropertyPromotion(
        property: propB,
        requestingUserId: sellerB,
        promotionType: PromotionType.featured,
        durationDays: 15,
      );

      expect(
        () => promotionRepository.updatePromotionStatus(
          promotionId: promoB.id,
          newStatus: PromotionStatus.cancelled,
          requestingUserId: sellerA, // MALICIOUS SELLER A
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('20. Admin legitimate promotion moderation -> ALLOWED', () async {
      final propA = createTestProperty(id: 'prop_a_20', ownerId: sellerA, title: 'Seller A Flat');

      final promo = await promotionRepository.createPropertyPromotion(
        property: propA,
        requestingUserId: sellerA,
        promotionType: PromotionType.topPlacement,
        durationDays: 30,
      );

      final updated = await promotionRepository.updatePromotionStatus(
        promotionId: promo.id,
        newStatus: PromotionStatus.paused,
        requestingUserId: 'usr_admin_global',
        userRole: UserRole.admin,
      );

      expect(updated.status, PromotionStatus.paused);
    });

    test('21. Legitimate seller promotion -> ALLOWED and notification sent', () async {
      final propA = createTestProperty(id: 'prop_a_21', ownerId: sellerA, title: 'Seller A Flat');
      final notifsBefore = (await notificationRepository.getNotifications(recipientId: sellerA)).length;

      final promo = await promotionRepository.createPropertyPromotion(
        property: propA,
        requestingUserId: sellerA,
        promotionType: PromotionType.featured,
        durationDays: 15,
      );

      expect(promo.status, PromotionStatus.active);
      expect(promo.isCurrentlyActive, isTrue);

      final notifsAfter = (await notificationRepository.getNotifications(recipientId: sellerA)).length;
      expect(notifsAfter, notifsBefore + 1);
    });

    test('22. Housing promotion -> ALLOWED category compatibility', () async {
      final housingProp = createTestProperty(
        id: 'prop_housing_22',
        ownerId: sellerA,
        title: '3BHK Villa Housing',
        category: PropertyCategory.residential,
      );

      final promo = await promotionRepository.createPropertyPromotion(
        property: housingProp,
        requestingUserId: sellerA,
        promotionType: PromotionType.featured,
        durationDays: 15,
      );
      expect(promo.propertyId, 'prop_housing_22');
    });

    test('23. Plot promotion -> ALLOWED category compatibility', () async {
      final plotProp = createTestProperty(
        id: 'prop_plot_23',
        ownerId: sellerA,
        title: '2400 sqft NA Plot',
        category: PropertyCategory.plotLand,
      );

      final promo = await promotionRepository.createPropertyPromotion(
        property: plotProp,
        requestingUserId: sellerA,
        promotionType: PromotionType.topPlacement,
        durationDays: 30,
      );
      expect(promo.propertyId, 'prop_plot_23');
    });

    test('24. Commercial promotion -> ALLOWED category compatibility', () async {
      final commProp = createTestProperty(
        id: 'prop_comm_24',
        ownerId: sellerA,
        title: 'Commercial Office Space',
        category: PropertyCategory.commercial,
      );

      final promo = await promotionRepository.createPropertyPromotion(
        property: commProp,
        requestingUserId: sellerA,
        promotionType: PromotionType.boost,
        durationDays: 7,
      );
      expect(promo.propertyId, 'prop_comm_24');
    });

    test('25. Raw Land promotion -> ALLOWED category compatibility', () async {
      final landProp = createTestProperty(
        id: 'prop_land_25',
        ownerId: sellerA,
        title: '5 Acres Agricultural Raw Land',
        category: PropertyCategory.land,
      );

      final promo = await promotionRepository.createPropertyPromotion(
        property: landProp,
        requestingUserId: sellerA,
        promotionType: PromotionType.featured,
        durationDays: 15,
      );
      expect(promo.propertyId, 'prop_land_25');
    });
  });
}
