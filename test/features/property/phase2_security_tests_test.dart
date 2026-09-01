import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/location_privacy_helper.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/property/utils/property_unlock_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PHASE 2 LOCATION PRIVACY & SECURITY GUARDS TESTS', () {
    late PropertyEntity testProperty;

    setUp(() {
      testProperty = PropertyEntity(
        id: 'prop_999',
        ownerId: 'usr_owner_100',
        title: 'Luxury Villa in Tilakwadi',
        description: 'Exclusive 4 BHK villa near RPO Cross.',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.published,
        verificationStatus: VerificationStatus.verified,
        price: 12500000.0,
        specifications: const PropertySpecificationsEntity(
          superBuiltUpArea: 2500,
          bedrooms: 4,
          bathrooms: 4,
        ),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'House #42, 3rd Cross, Tilakwadi',
        pincode: '590006',
        latitude: 15.849712,
        longitude: 74.508934,
        features: const {
          'ownerPhone': '+91 98450 99999',
          'ownerEmail': 'owner@belagaviproperty.com',
          'ownerWhatsApp': '+91 98450 99999',
          'exactAddress': 'House #42, 3rd Cross, Tilakwadi',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('TEST 1: Guest opens property -> Area visible, exact address & GPS hidden', () {
      final publicView = LocationPrivacyHelper.toPublicPropertyEntity(testProperty);

      expect(publicView.locality, equals('Tilakwadi'));
      expect(publicView.city, equals('Belagavi'));
      expect(publicView.state, equals('Karnataka'));
      expect(publicView.address, isEmpty);
      expect(publicView.pincode, isEmpty);
      expect(publicView.latitude, equals(15.85)); // Fuzzed ~1.1km locality center
      expect(publicView.longitude, equals(74.51));
      expect(publicView.features.containsKey('ownerPhone'), isFalse);
      expect(publicView.features.containsKey('ownerEmail'), isFalse);
      expect(publicView.features.containsKey('ownerWhatsApp'), isFalse);
    });

    test('TEST 2: Authenticated Buyer without unlock opens property -> Information remains hidden', () {
      final isUnlocked = PropertyUnlockGuard.isUnlocked(
        requestingUserId: 'buyer_unlocked_false',
        property: testProperty,
        userUnlocks: const [],
      );

      expect(isUnlocked, isFalse);

      final publicView = LocationPrivacyHelper.toPublicPropertyEntity(testProperty);
      expect(publicView.address, isEmpty);
      expect(publicView.features.containsKey('ownerPhone'), isFalse);
    });

    test('TEST 3: Authenticated Buyer with valid PropertyUnlock opens property -> Protected info revealed', () {
      final activeUnlock = PropertyUnlockEntity(
        id: 'unl_001',
        propertyId: 'prop_999',
        userId: 'buyer_unlocked_true',
        unlockType: UnlockType.payPerProperty,
        unlockedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        status: UnlockStatus.active,
        createdAt: DateTime.now(),
      );

      final isUnlocked = PropertyUnlockGuard.isUnlocked(
        requestingUserId: 'buyer_unlocked_true',
        property: testProperty,
        userUnlocks: [activeUnlock],
      );

      expect(isUnlocked, isTrue);
      // When unlocked, exact address and coordinates are accessible
      expect(testProperty.address, equals('House #42, 3rd Cross, Tilakwadi'));
      expect(testProperty.latitude, equals(15.849712));
    });

    test('TEST 4: User attempts to edit another user\'s property -> ACCESS DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: 'attacker_user_id',
          ownerId: testProperty.ownerId,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 5: Broker attempts to edit another owner\'s property -> ACCESS DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyBrokerOwnership(
          authenticatedUserId: 'unauthorized_broker_id',
          brokerOrOwnerId: testProperty.ownerId,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 6: Builder attempts to edit another builder\'s project -> ACCESS DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyProjectOwnership(
          authenticatedUserId: 'unauthorized_builder_id',
          builderId: 'legitimate_builder_id',
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 7: Logged-out user attempts to access protected property info -> ACCESS DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: null,
          ownerId: testProperty.ownerId,
        ),
        throwsA(isA<AccessDeniedException>()),
      );

      final isUnlocked = PropertyUnlockGuard.isUnlocked(
        requestingUserId: null,
        property: testProperty,
        userUnlocks: const [],
      );
      expect(isUnlocked, isFalse);
    });

    test('TEST 8: Inspect query response -> Protected fields absent from public queries', () async {
      final publicView = LocationPrivacyHelper.toPublicPropertyEntity(testProperty);
      final json = publicView.features;

      expect(json['ownerPhone'], isNull);
      expect(json['ownerEmail'], isNull);
      expect(json['ownerWhatsApp'], isNull);
      expect(json['exactAddress'], isNull);
      expect(publicView.address, isEmpty);
      expect(publicView.pincode, isEmpty);
    });
  });
}
