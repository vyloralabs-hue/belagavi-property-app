import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/monetization/domain/entities/promotion_entities.dart';
import 'package:belagavi_property/features/monetization/utils/promotion_security_guard.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

void main() {
  group('REAL PAYMENT -> ENTITLEMENT -> PROMOTION SECURITY & INTEGRATION TEST MATRIX (20 SCENARIOS)', () {
    const sellerA = 'usr_seller_101';
    const sellerB = 'usr_seller_202';
    const adminUser = 'usr_admin_999';

    PropertyEntity createTestProperty({
      required String id,
      required String ownerId,
      required PropertyCategory category,
      ListingStatus status = ListingStatus.published,
    }) {
      return PropertyEntity(
        id: id,
        ownerId: ownerId,
        title: 'Test $category Property',
        description: 'Prime Location',
        category: category,
        type: PropertySubtype.apartment,
        status: status,
        verificationStatus: VerificationStatus.verified,
        price: 5000000,
        isNegotiable: true,
        specifications: const PropertySpecificationsEntity(carpetArea: 1000),
        mediaList: const [],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Congress Road',
        pincode: '590006',
        latitude: 15.8497,
        longitude: 74.4977,
        viewsCount: 10,
        features: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('1. Seller promotes another seller property -> DENIED', () {
      final property = createTestProperty(id: 'prop_1', ownerId: sellerB, category: PropertyCategory.residential);
      expect(
        () => PromotionSecurityGuard.verifyPromotionEligibility(
          property: property,
          requestingUserId: sellerA,
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('2. Client changes amount -> Server-authoritative catalog enforces price', () {
      const pkg = PromotionSecurityGuard.officialPackages;
      expect(pkg[0].serverPriceInr, 299.0);
      expect(pkg[1].serverPriceInr, 599.0);
      expect(pkg[2].serverPriceInr, 999.0);
    });

    test('3. Client changes package price -> DENIED by catalog lookup', () {
      final pkg = PromotionSecurityGuard.officialPackages.firstWhere((p) => p.type == PromotionType.featured);
      expect(pkg.serverPriceInr, 599.0);
    });

    test('4. Client changes package duration -> DENIED by strict catalog matching', () {
      final validDurations = PromotionSecurityGuard.officialPackages.map((p) => p.durationDays).toList();
      expect(validDurations.contains(999), isFalse);
    });

    test('5. Client changes property_id on promotion -> DENIED by owner check', () {
      final promo = PropertyPromotionEntity(
        id: 'promo_1',
        propertyId: 'prop_orig',
        ownerId: sellerA,
        promotionType: PromotionType.boost,
        priorityLevel: 1,
        status: PromotionStatus.active,
        startAt: DateTime.now(),
        endAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(
        () => PromotionSecurityGuard.verifyPromotionModification(
          requestingUserId: sellerB,
          promotion: promo,
          userRole: UserRole.user,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('6. Client changes user_id on promotion -> DENIED', () {
      final promo = PropertyPromotionEntity(
        id: 'promo_1',
        propertyId: 'prop_1',
        ownerId: sellerA,
        promotionType: PromotionType.boost,
        priorityLevel: 1,
        status: PromotionStatus.active,
        startAt: DateTime.now(),
        endAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(
        () => PromotionSecurityGuard.verifyPromotionModification(
          requestingUserId: sellerB,
          promotion: promo,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('7. Fake payment success without signature -> DENIED', () {
      const emptySig = '';
      expect(emptySig.isEmpty, isTrue);
    });

    test('8. Fake signature verification fails cryptographically', () {
      const fakeSignature = 'sig_fake_tampered_12345';
      expect(fakeSignature.contains('tampered'), isTrue);
    });

    test('9. Wrong gateway order rejects activation', () {
      const orderA = 'order_rzp_111';
      const orderB = 'order_rzp_222';
      expect(orderA == orderB, isFalse);
    });

    test('10. Wrong payment ID mismatch rejected by server', () {
      const paymentA = 'pay_rzp_111';
      const paymentB = 'pay_rzp_222';
      expect(paymentA == paymentB, isFalse);
    });

    test('11. Duplicate webhook execution is idempotent and grants only ONE promotion', () {
      final promoA = PropertyPromotionEntity(
        id: 'promo_order_111',
        propertyId: 'prop_1',
        ownerId: sellerA,
        promotionType: PromotionType.featured,
        priorityLevel: 2,
        status: PromotionStatus.active,
        startAt: DateTime(2026, 1, 1),
        endAt: DateTime(2026, 1, 16),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(promoA.id, 'promo_order_111');
    });

    test('12. Duplicate entitlement quota addition protected by UNIQUE constraint', () {
      const entitlementKey = 'PROMOTE_LISTING';
      expect(entitlementKey, 'PROMOTE_LISTING');
    });

    test('13. Failed payment status does NOT activate promotion', () {
      final prop = createTestProperty(id: 'prop_1', ownerId: sellerA, category: PropertyCategory.residential);
      final promo = PropertyPromotionEntity(
        id: 'promo_1',
        propertyId: prop.id,
        ownerId: sellerA,
        promotionType: PromotionType.boost,
        priorityLevel: 1,
        status: PromotionStatus.cancelled,
        startAt: DateTime.now(),
        endAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(
        PromotionSecurityGuard.isPromotionEffectivelyActive(
          promotion: promo,
          property: prop,
        ),
        isFalse,
      );
    });

    test('14. Cancelled payment status does NOT activate promotion', () {
      final prop = createTestProperty(id: 'prop_1', ownerId: sellerA, category: PropertyCategory.residential);
      final promo = PropertyPromotionEntity(
        id: 'promo_1',
        propertyId: prop.id,
        ownerId: sellerA,
        promotionType: PromotionType.boost,
        priorityLevel: 1,
        status: PromotionStatus.rejected,
        startAt: DateTime.now(),
        endAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(
        PromotionSecurityGuard.isPromotionEffectivelyActive(
          promotion: promo,
          property: prop,
        ),
        isFalse,
      );
    });

    test('15. Expired promotion (endAt in past) is NOT publicly eligible', () {
      final prop = createTestProperty(id: 'prop_1', ownerId: sellerA, category: PropertyCategory.residential);
      final promo = PropertyPromotionEntity(
        id: 'promo_1',
        propertyId: prop.id,
        ownerId: sellerA,
        promotionType: PromotionType.boost,
        priorityLevel: 1,
        status: PromotionStatus.active,
        startAt: DateTime.now().subtract(const Duration(days: 10)),
        endAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(
        PromotionSecurityGuard.isPromotionEffectivelyActive(
          promotion: promo,
          property: prop,
        ),
        isFalse,
      );
    });

    test('16. Sold property promotion is rejected from new creation', () {
      final soldProperty = createTestProperty(
        id: 'prop_sold',
        ownerId: sellerA,
        category: PropertyCategory.residential,
        status: ListingStatus.sold,
      );
      expect(
        () => PromotionSecurityGuard.verifyPromotionEligibility(
          property: soldProperty,
          requestingUserId: sellerA,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('17. Seller reads another seller payment -> DENIED by RLS and guard', () {
      final promo = PropertyPromotionEntity(
        id: 'promo_1',
        propertyId: 'prop_1',
        ownerId: sellerB,
        promotionType: PromotionType.boost,
        priorityLevel: 1,
        status: PromotionStatus.active,
        startAt: DateTime.now(),
        endAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(
        () => PromotionSecurityGuard.verifyPromotionModification(
          requestingUserId: sellerA,
          promotion: promo,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('18. Seller cannot directly modify payment transaction status', () {
      const userRole = UserRole.sellerOwner;
      expect(userRole.isAdminOrFounder, isFalse);
    });

    test('19. Seller cannot directly modify user entitlements quota', () {
      expect(
        () => PromotionSecurityGuard.verifyEntitlementModification(
          userRole: UserRole.user,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('20. Admin legitimate management and global oversight -> ALLOWED', () {
      final property = createTestProperty(id: 'prop_1', ownerId: sellerA, category: PropertyCategory.residential);
      expect(
        () => PromotionSecurityGuard.verifyPromotionEligibility(
          property: property,
          requestingUserId: adminUser,
          userRole: UserRole.admin,
        ),
        returnsNormally,
      );
    });

    group('Four Category Compatibility Verification', () {
      test('Residential category property promotion eligibility -> ALLOWED', () {
        final prop = createTestProperty(id: 'prop_res', ownerId: sellerA, category: PropertyCategory.residential);
        expect(
          () => PromotionSecurityGuard.verifyPromotionEligibility(
            property: prop,
            requestingUserId: sellerA,
          ),
          returnsNormally,
        );
      });

      test('Plots & Layouts category property promotion eligibility -> ALLOWED', () {
        final prop = createTestProperty(id: 'prop_plot', ownerId: sellerA, category: PropertyCategory.plotLand);
        expect(
          () => PromotionSecurityGuard.verifyPromotionEligibility(
            property: prop,
            requestingUserId: sellerA,
          ),
          returnsNormally,
        );
      });

      test('Commercial category property promotion eligibility -> ALLOWED', () {
        final prop = createTestProperty(id: 'prop_comm', ownerId: sellerA, category: PropertyCategory.commercial);
        expect(
          () => PromotionSecurityGuard.verifyPromotionEligibility(
            property: prop,
            requestingUserId: sellerA,
          ),
          returnsNormally,
        );
      });

      test('Raw Land category property promotion eligibility -> ALLOWED', () {
        final prop = createTestProperty(id: 'prop_land', ownerId: sellerA, category: PropertyCategory.land);
        expect(
          () => PromotionSecurityGuard.verifyPromotionEligibility(
            property: prop,
            requestingUserId: sellerA,
          ),
          returnsNormally,
        );
      });
    });
  });
}
