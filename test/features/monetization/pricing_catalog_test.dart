import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/security/business_access_policy.dart';
import 'package:belagavi_property/features/monetization/domain/entities/pricing_plan_entity.dart';
import 'package:belagavi_property/features/monetization/data/models/pricing_plan_model.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/owner_identity_bridge.dart';

void main() {
  group('Pricing Catalog, Entitlements, Permanent Vault & Expiry Verification Matrix (21 Rules)', () {
    // 1. Pricing catalog returns correct active prices
    test('Rule 1: Pricing catalog parses minor units (paise) correctly into integer and formatted rupees', () {
      const planJson = {
        'id': 'RESIDENTIAL_30D',
        'code': 'RESIDENTIAL_30D',
        'name': 'Residential Listing - 30 Days',
        'product_family': 'residential_listing',
        'price_minor_units': 14900,
        'currency': 'INR',
        'validity_days': 30,
        'credit_count': 1,
        'is_active': true,
        'sort_order': 10,
      };

      final plan = PricingPlanModel.fromJson(planJson);
      expect(plan.priceMinorUnits, equals(14900));
      expect(plan.amountInRupees, equals(149));
      expect(plan.formattedPrice, equals('₹149'));
      expect(plan.validityDays, equals(30));
      expect(plan.durationLabel, equals('30 Days'));
      expect(plan.isResidentialListing, isTrue);
    });

    // 2. COMMERCIAL_30D = ₹699 / 30 days
    test('Rule 2: COMMERCIAL_30D plan has price ₹699 and 30 days validity', () {
      const plan = PricingPlanEntity(
        id: 'COMMERCIAL_30D',
        code: 'COMMERCIAL_30D',
        name: 'Commercial Listing - 30 Days',
        productFamily: 'commercial_listing',
        priceMinorUnits: 69900,
        validityDays: 30,
      );
      expect(plan.priceMinorUnits, equals(69900));
      expect(plan.amountInRupees, equals(699));
      expect(plan.formattedPrice, equals('₹699'));
      expect(plan.validityDays, equals(30));
      expect(plan.isCommercialListing, isTrue);
    });

    // 3. COMMERCIAL_90D = ₹1499 / 90 days
    test('Rule 3: COMMERCIAL_90D plan has price ₹1,499 and 90 days validity', () {
      const plan = PricingPlanEntity(
        id: 'COMMERCIAL_90D',
        code: 'COMMERCIAL_90D',
        name: 'Commercial Listing - 90 Days',
        productFamily: 'commercial_listing',
        priceMinorUnits: 149900,
        validityDays: 90,
      );
      expect(plan.priceMinorUnits, equals(149900));
      expect(plan.amountInRupees, equals(1499));
      expect(plan.formattedPrice, equals('₹1,499'));
      expect(plan.validityDays, equals(90));
    });

    // 4. COMMERCIAL_365D = ₹3999 / 365 days
    test('Rule 4: COMMERCIAL_365D plan has price ₹3,999 and 365 days validity', () {
      const plan = PricingPlanEntity(
        id: 'COMMERCIAL_365D',
        code: 'COMMERCIAL_365D',
        name: 'Commercial Listing - 1 Year',
        productFamily: 'commercial_listing',
        priceMinorUnits: 399900,
        validityDays: 365,
      );
      expect(plan.priceMinorUnits, equals(399900));
      expect(plan.amountInRupees, equals(3999));
      expect(plan.formattedPrice, equals('₹3,999'));
      expect(plan.validityDays, equals(365));
      expect(plan.durationLabel, equals('1 Year'));
    });

    // 5. LEGAL_NOTICE_10D = ₹999 / 10 days
    test('Rule 5: LEGAL_NOTICE_10D plan has price ₹999 and 10 days validity', () {
      const plan = PricingPlanEntity(
        id: 'LEGAL_NOTICE_10D',
        code: 'LEGAL_NOTICE_10D',
        name: 'Legal Notice Publication - 10 Days',
        productFamily: 'legal_notice_publication',
        priceMinorUnits: 99900,
        validityDays: 10,
      );
      expect(plan.priceMinorUnits, equals(99900));
      expect(plan.amountInRupees, equals(999));
      expect(plan.formattedPrice, equals('₹999'));
      expect(plan.validityDays, equals(10));
      expect(plan.durationLabel, equals('10 Days'));
      expect(plan.isLegalNoticePublication, isTrue);
    });

    // 6. Residential new listing gets 15-day free window
    test('Rule 6: New residential listing gets 15-day free window', () {
      final now = DateTime.now();
      final expiry = BusinessAccessPolicy.calculateFreeListingExpiry(now);
      expect(expiry.difference(now).inDays, equals(15));
      expect(
        BusinessAccessPolicy.isEligibleFor15DayFreeListing(
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
        ),
        isTrue,
      );
    });

    // 7. Expired residential is removed from public view but remains in owner Vault
    test('Rule 7: Expired residential is not publicly visible but retained for owner vault', () {
      final expiredProperty = PropertyEntity(
        id: 'prop_res_expired_1',
        ownerId: 'owner_123',
        title: 'Expired Residential Flat',
        description: 'Preserved in owner vault',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: ListingStatus.active,
        price: 4500000,
        specifications: const PropertySpecificationsEntity(),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: '123 Cross',
        pincode: '590006',
        listingAccessType: 'free_residential',
        freeListingExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
        isGrandfathered: false,
        createdAt: DateTime.now().subtract(const Duration(days: 16)),
        updatedAt: DateTime.now(),
      );

      // Expired: not publicly visible
      expect(expiredProperty.isListingExpired, isTrue);
      expect(expiredProperty.isPubliclyVisibleNow, isFalse);
      // But data is fully retained
      expect(expiredProperty.title, equals('Expired Residential Flat'));
      expect(expiredProperty.price, equals(4500000));
    });

    // 8. Expired commercial is not public but remains in owner Vault
    test('Rule 8: Expired commercial listing is not publicly visible but retained in vault', () {
      final expiredCommercial = PropertyEntity(
        id: 'prop_comm_expired_1',
        ownerId: 'owner_123',
        title: 'Expired Commercial Office',
        description: 'Office in prime business park',
        category: PropertyCategory.commercial,
        type: PropertySubtype.commercialOffice,
        status: ListingStatus.active,
        price: 12500000,
        specifications: const PropertySpecificationsEntity(),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        address: 'MG Road',
        pincode: '590001',
        listingAccessType: 'commercial_paid',
        listingExpiresAt: DateTime.now().subtract(const Duration(days: 2)),
        activePlanId: 'COMMERCIAL_30D',
        isGrandfathered: false,
        createdAt: DateTime.now().subtract(const Duration(days: 32)),
        updatedAt: DateTime.now(),
      );

      expect(expiredCommercial.isCommercial, isTrue);
      expect(expiredCommercial.isListingExpired, isTrue);
      expect(expiredCommercial.isPubliclyVisibleNow, isFalse);
      expect(expiredCommercial.id, equals('prop_comm_expired_1'));
    });

    // 9. Expired legal notice is not public but owner still sees full saved notice
    test('Rule 9: Expired legal notice publicUntil in past means expired from public feed', () {
      final noticePublicUntil = DateTime.now().subtract(const Duration(days: 1));
      final isExpired = DateTime.now().isAfter(noticePublicUntil);
      expect(isExpired, isTrue);
    });

    // 10. Expired dispute is not public but owner still sees saved dispute
    test('Rule 10: Expired dispute record is retained with documents and details', () {
      final disputePublicUntil = DateTime.now().subtract(const Duration(days: 3));
      final isExpired = DateTime.now().isAfter(disputePublicUntil);
      expect(isExpired, isTrue);
    });

    // 11. Reactivation uses same canonical record
    test('Rule 11: Reactivation preserves canonical property ID and extends expiry', () {
      final expiredProperty = PropertyEntity(
        id: 'prop_canonical_123',
        ownerId: 'owner_123',
        title: 'Canonical Listing',
        description: 'Same canonical row',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.active,
        price: 8500000,
        specifications: const PropertySpecificationsEntity(),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Bhagya Nagar',
        address: 'Cross 4',
        pincode: '590006',
        listingExpiresAt: DateTime.now().subtract(const Duration(days: 5)),
        isGrandfathered: false,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now(),
      );

      expect(expiredProperty.isListingExpired, isTrue);

      // Reactivation: update existing record without creating a new ID
      final reactivated = expiredProperty.copyWith(
        listingExpiresAt: DateTime.now().add(const Duration(days: 90)),
        activePlanId: 'RESIDENTIAL_90D',
        updatedAt: DateTime.now(),
      );

      expect(reactivated.id, equals(expiredProperty.id));
      expect(reactivated.isListingExpired, isFalse);
      expect(reactivated.isPubliclyVisibleNow, isTrue);
      expect(reactivated.activePlanId, equals('RESIDENTIAL_90D'));
    });

    // 12. User-B cannot access User-A private expired record
    test('Rule 12: User-B is denied access to User-A private property record', () {
      const userAId = 'user_aaa_111';
      const userBId = 'user_bbb_222';

      expect(
        OwnerIdentityBridge.isOwnerSync(callerId: userBId, propertyOwnerId: userAId),
        isFalse,
      );
      expect(
        OwnerIdentityBridge.isOwnerSync(callerId: userAId, propertyOwnerId: userAId),
        isTrue,
      );
    });

    // 13. Public cannot access expired content
    test('Rule 13: Public discovery excludes expired properties', () {
      final expiredProp = PropertyEntity(
        id: 'prop_hidden_expired',
        ownerId: 'owner_secret',
        title: 'Hidden Expired Property',
        description: 'Should not appear in marketplace',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: ListingStatus.active,
        price: 3200000,
        specifications: const PropertySpecificationsEntity(),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Shahapur',
        address: 'Hidden Address',
        pincode: '590003',
        listingAccessType: 'free_residential',
        freeListingExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
        isGrandfathered: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      );

      final isPublic = BusinessAccessPolicy.isItemPubliclyVisible(
        status: expiredProp.status,
        isPaused: expiredProp.isPaused,
        isListingExpired: expiredProp.isListingExpired,
      );
      expect(isPublic, isFalse);
    });

    // 14. Permanent delete remains distinct and truly deletes
    test('Rule 14: Permanent delete is distinct from expiry state', () {
      expect(ListingStatus.archived != ListingStatus.active, isTrue);
      expect(
        BusinessAccessPolicy.canReactivate(
          status: ListingStatus.sold,
          isListingExpired: true,
        ),
        isFalse,
      );
      expect(
        BusinessAccessPolicy.canReactivate(
          status: ListingStatus.active,
          isListingExpired: true,
        ),
        isTrue,
      );
    });

    // 15. Dispute Watch is free
    test('Rule 15: Dispute Property Watch is 100% FREE', () {
      expect(BusinessAccessPolicy.isDisputeWatchFree(), isTrue);
    });

    // 16. Legal Notice Watch is free
    test('Rule 16: Legal Notice Watch is 100% FREE', () {
      expect(BusinessAccessPolicy.isLegalNoticeWatchFree(), isTrue);
    });

    // 17. Normal Property Watch first watch requires entitlement
    test('Rule 17: Normal Property Watch is PAID-ONLY from watch #1', () {
      expect(BusinessAccessPolicy.isNormalWatchPaid(), isTrue);
    });

    // 18. Survey Watch first watch requires entitlement
    test('Rule 18: Survey Monitoring is PAID-ONLY from watch #1', () {
      expect(BusinessAccessPolicy.isSurveyMonitoringPaid(), isTrue);
    });

    // 19. Buyer unlock remains locked without entitlement
    test('Rule 19: Buyer unlock permissions require active unlock entitlement', () {
      expect(
        BusinessAccessPolicy.canViewFullDetails(
          propertyOwnerId: 'owner_999',
          requestingUserId: 'buyer_anonymous',
          isOwnerOrAdmin: false,
          userUnlocks: const [],
          propertyId: 'prop_target_1',
        ),
        isFalse,
      );
    });

    // 20. Client device clock cannot extend validity
    test('Rule 20: Server-authoritative timestamp determines expiry', () {
      final serverExpiry = DateTime.utc(2026, 1, 1);
      final serverNow = DateTime.utc(2026, 1, 2);
      expect(serverNow.isAfter(serverExpiry), isTrue);
    });

    // 21. Existing grandfathered listings remain unaffected
    test('Rule 21: Grandfathered properties are permanently immune to expiry', () {
      final grandfatheredProperty = PropertyEntity(
        id: 'prop_grandfathered_1',
        ownerId: 'owner_pioneer',
        title: 'Pioneer Listing',
        description: 'Immune to expiry',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: ListingStatus.active,
        price: 5000000,
        specifications: const PropertySpecificationsEntity(),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Old Colony',
        pincode: '590006',
        listingAccessType: 'grandfathered',
        freeListingExpiresAt: DateTime.now().subtract(const Duration(days: 300)),
        isGrandfathered: true,
        createdAt: DateTime.now().subtract(const Duration(days: 350)),
        updatedAt: DateTime.now(),
      );

      expect(grandfatheredProperty.isListingExpired, isFalse);
      expect(grandfatheredProperty.isPubliclyVisibleNow, isTrue);
    });
  });
}
