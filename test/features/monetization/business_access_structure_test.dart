import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/security/business_access_policy.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/location_privacy_helper.dart';

void main() {
  group('Belagavi Property Business Access Structure & Policy Tests', () {
    test('Rule 1: Dispute Property Watch is 100% FREE without entitlement', () {
      expect(BusinessAccessPolicy.isDisputeWatchFree(), isTrue);
    });

    test('Rule 2: Property Legal Notice Watch is 100% FREE without entitlement', () {
      expect(BusinessAccessPolicy.isLegalNoticeWatchFree(), isTrue);
    });

    test('Rule 3: Normal Property Watch is 100% PAID-ONLY', () {
      expect(BusinessAccessPolicy.isNormalWatchPaid(), isTrue);
    });

    test('Rule 3: Survey Monitoring is 100% PAID-ONLY', () {
      expect(BusinessAccessPolicy.isSurveyMonitoringPaid(), isTrue);
    });

    test('Rule 5: Commercial categories identified correctly as Commercial', () {
      expect(
        BusinessAccessPolicy.isCommercialProperty(category: PropertyCategory.commercial),
        isTrue,
      );
      expect(
        BusinessAccessPolicy.isCommercialProperty(category: PropertyCategory.industrial),
        isTrue,
      );
      expect(
        BusinessAccessPolicy.isCommercialProperty(
          category: PropertyCategory.other,
          type: PropertySubtype.commercialOffice,
        ),
        isTrue,
      );
      expect(
        BusinessAccessPolicy.isCommercialProperty(
          category: PropertyCategory.other,
          type: PropertySubtype.commercialShop,
        ),
        isTrue,
      );
      expect(
        BusinessAccessPolicy.isCommercialProperty(
          category: PropertyCategory.other,
          type: PropertySubtype.warehouseGodown,
        ),
        isTrue,
      );
    });

    test('Rule 4: Residential, Plot, and Agricultural Land are eligible for 15-day free listing', () {
      expect(
        BusinessAccessPolicy.isEligibleFor15DayFreeListing(
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
        ),
        isTrue,
      );
      expect(
        BusinessAccessPolicy.isEligibleFor15DayFreeListing(
          category: PropertyCategory.plotLand,
          type: PropertySubtype.residentialPlot,
        ),
        isTrue,
      );
      expect(
        BusinessAccessPolicy.isEligibleFor15DayFreeListing(
          category: PropertyCategory.land,
          type: PropertySubtype.agriculturalLand,
        ),
        isTrue,
      );
    });

    test('Rule 4: calculateFreeListingExpiry sets exactly 15 days from start', () {
      final start = DateTime(2026, 9, 8, 12, 0);
      final expiry = BusinessAccessPolicy.calculateFreeListingExpiry(start);
      expect(expiry.difference(start).inDays, equals(15));
    });

    test('Rule 4: Grandfathered properties never expire via free-listing rule', () {
      final isExpired = BusinessAccessPolicy.isFreeListingExpired(
        listingAccessType: 'grandfathered',
        freeListingExpiresAt: DateTime.now().subtract(const Duration(days: 30)),
        isGrandfathered: true,
      );
      expect(isExpired, isFalse);

      final remainingDays = BusinessAccessPolicy.remainingFreeListingDays(
        listingAccessType: 'grandfathered',
        freeListingExpiresAt: DateTime.now().subtract(const Duration(days: 30)),
        isGrandfathered: true,
      );
      expect(remainingDays, isNull);
    });

    test('Rule 4: Active residential listing within 15 days calculates remaining days', () {
      final now = DateTime.now();
      final futureExpiry = now.add(const Duration(days: 10));

      final remaining = BusinessAccessPolicy.remainingFreeListingDays(
        listingAccessType: 'free_residential',
        freeListingExpiresAt: futureExpiry,
        isGrandfathered: false,
      );
      expect(remaining, greaterThanOrEqualTo(9));
      expect(remaining, lessThanOrEqualTo(11));

      final isExpired = BusinessAccessPolicy.isFreeListingExpired(
        listingAccessType: 'free_residential',
        freeListingExpiresAt: futureExpiry,
        isGrandfathered: false,
      );
      expect(isExpired, isFalse);
    });

    test('Rule 4: Expired residential listing detects expiration', () {
      final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
      final isExpired = BusinessAccessPolicy.isFreeListingExpired(
        listingAccessType: 'free_residential',
        freeListingExpiresAt: pastExpiry,
        isGrandfathered: false,
      );
      expect(isExpired, isTrue);

      final remaining = BusinessAccessPolicy.remainingFreeListingDays(
        listingAccessType: 'free_residential',
        freeListingExpiresAt: pastExpiry,
        isGrandfathered: false,
      );
      expect(remaining, equals(0));
    });

    test('Rule 6: Public Property projection masks exact address and contact fields', () {
      final rawProperty = PropertyEntity(
        id: 'prop_test_123',
        ownerId: 'owner_user_abc',
        title: 'Luxury Villa in Belagavi',
        description: 'Prime residential villa with lawn',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        price: 9500000.0,
        specifications: const PropertySpecificationsEntity(bedrooms: 4, carpetArea: 2500),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'House No 42, 3rd Cross, Tilakwadi, Belagavi 590006',
        pincode: '590006',
        latitude: 15.849721,
        longitude: 74.497712,
        features: const {
          'ownerPhone': '+919876543210',
          'ownerEmail': 'owner@belagavi.test',
          'ownerWhatsApp': '+919876543210',
          'exactAddress': 'House No 42, 3rd Cross',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final publicProjection = LocationPrivacyHelper.toPublicPropertyEntity(rawProperty);

      // Verify privacy masking
      expect(publicProjection.address, isEmpty);
      expect(publicProjection.pincode, isEmpty);
      expect(publicProjection.features.containsKey('ownerPhone'), isFalse);
      expect(publicProjection.features.containsKey('ownerEmail'), isFalse);
      expect(publicProjection.features.containsKey('ownerWhatsApp'), isFalse);
      expect(publicProjection.features.containsKey('exactAddress'), isFalse);

      // Verify public information remains intact
      expect(publicProjection.id, equals('prop_test_123'));
      expect(publicProjection.title, equals('Luxury Villa in Belagavi'));
      expect(publicProjection.city, equals('Belagavi'));
      expect(publicProjection.locality, equals('Tilakwadi'));
      expect(publicProjection.price, equals(9500000.0));
    });

    test('Rule 7: canViewFullDetails allows verified Owner and rejects unauthenticated caller', () {
      // Unauthenticated caller
      expect(
        BusinessAccessPolicy.canViewFullDetails(
          propertyOwnerId: 'owner_abc',
          requestingUserId: null,
          isOwnerOrAdmin: false,
          userUnlocks: const [],
          propertyId: 'prop_123',
        ),
        isFalse,
      );

      // Verified Owner
      expect(
        BusinessAccessPolicy.canViewFullDetails(
          propertyOwnerId: 'owner_abc',
          requestingUserId: 'owner_abc',
          isOwnerOrAdmin: true,
          userUnlocks: const [],
          propertyId: 'prop_123',
        ),
        isTrue,
      );
    });

    test('Rule 7 & 8: canViewFullDetails allows buyer with active unlock record', () {
      final activeUnlock = PropertyUnlockEntity(
        id: 'unlock_1',
        userId: 'buyer_xyz',
        propertyId: 'prop_123',
        status: UnlockStatus.active,
        unlockedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      final expiredUnlock = PropertyUnlockEntity(
        id: 'unlock_2',
        userId: 'buyer_expired',
        propertyId: 'prop_123',
        status: UnlockStatus.active,
        unlockedAt: DateTime.now().subtract(const Duration(days: 60)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Active unlock
      expect(
        BusinessAccessPolicy.canViewFullDetails(
          propertyOwnerId: 'owner_abc',
          requestingUserId: 'buyer_xyz',
          isOwnerOrAdmin: false,
          userUnlocks: [activeUnlock],
          propertyId: 'prop_123',
        ),
        isTrue,
      );

      // Expired unlock
      expect(
        BusinessAccessPolicy.canViewFullDetails(
          propertyOwnerId: 'owner_abc',
          requestingUserId: 'buyer_expired',
          isOwnerOrAdmin: false,
          userUnlocks: [expiredUnlock],
          propertyId: 'prop_123',
        ),
        isFalse,
      );
    });
  });
}
