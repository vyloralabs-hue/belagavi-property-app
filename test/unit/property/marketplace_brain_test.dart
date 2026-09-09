import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/data/models/property_models.dart';
import 'package:belagavi_property/features/property_search/utils/india_location_directory.dart';
import 'package:belagavi_property/features/property/services/media_location_resolver.dart';

void main() {
  group('Central Marketplace Brain & E2E Validation Tests', () {
    // 1. Status Mapping: All 13 Dart enums must map strictly to the 6 live Postgres enum strings
    test('ListingStatus.dbValue maps strictly to valid live Postgres enums', () {
      const allowedDbEnums = {
        'draft',
        'pending_verification',
        'active',
        'rejected',
        'archived',
        'sold',
      };

      for (final status in ListingStatus.values) {
        final dbVal = status.dbValue;
        expect(
          allowedDbEnums.contains(dbVal),
          isTrue,
          reason: 'Status ${status.name} mapped to invalid DB enum string: $dbVal',
        );
      }

      // Check key transitions
      expect(ListingStatus.submitted.dbValue, 'pending_verification');
      expect(ListingStatus.underReview.dbValue, 'pending_verification');
      expect(ListingStatus.published.dbValue, 'active');
      expect(ListingStatus.approved.dbValue, 'active');
      expect(ListingStatus.paused.dbValue, 'archived');
      expect(ListingStatus.changesRequested.dbValue, 'archived');
      expect(ListingStatus.rented.dbValue, 'sold');
      expect(ListingStatus.leased.dbValue, 'sold');
    });

    // 2. Location Alias Canonicalization: Belgaum->Belagavi, Tilakvadi->Tilakwadi, Hubli->Hubballi
    test('Location directory canonicalizes Belgaum and Tilakvadi aliases', () {
      expect(IndiaLocationDirectory.normalizeCityName('belgaum'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('BGM'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('belagaon'), 'Belagavi');
      expect(IndiaLocationDirectory.normalizeCityName('hubli'), 'Hubballi');
      expect(IndiaLocationDirectory.normalizeCityName('Dharwad'), 'Dharwad');

      expect(
        IndiaLocationDirectory.normalizeLocalityName('tilakvadi', 'Belagavi'),
        'Tilakwadi',
      );
      expect(
        IndiaLocationDirectory.normalizeLocalityName('shahpur', 'Belagavi'),
        'Shahapur',
      );
      expect(
        IndiaLocationDirectory.normalizeLocalityName('piranvadi', 'Belagavi'),
        'Piranwadi',
      );
    });

    // 3. Search Isolation: Bengaluru query must NEVER match Belagavi property
    test('Search location isolation: Bengaluru strictly isolated from Belagavi', () {
      final belagaviResolved = MediaLocationResolver.resolve(
        selectedCity: 'belgaum',
        selectedLocality: 'tilakvadi',
      );
      expect(belagaviResolved.canonicalCity, 'Belagavi');

      final bengaluruResolved = MediaLocationResolver.resolve(
        selectedCity: 'bangalore',
      );
      expect(bengaluruResolved.canonicalCity, 'Bengaluru');

      // They must not match
      expect(
        belagaviResolved.canonicalCity.toLowerCase() ==
            bengaluruResolved.canonicalCity.toLowerCase(),
        isFalse,
      );
    });

    // 4. Admin Moderation Status Transition: pending_verification -> active
    test('Admin moderation transition updates status to active', () {
      final pendingProperty = PropertyModel(
        id: 'prop_live_e2e_001',
        ownerId: 'usr_seller_123',
        title: 'BELAGAVI LIVE E2E PROPERTY',
        description: 'Prime verified property in Tilakwadi',
        category: PropertyCategory.residential,
        type: PropertySubtype.independentHouse,
        status: ListingStatus.pendingVerification,
        verificationStatus: VerificationStatus.pending,
        price: 9500000.0,
        specifications: const PropertySpecificationsEntity(
          carpetArea: 1800.0,
          superBuiltUpArea: 2200.0,
          bedrooms: 3,
          bathrooms: 3,
        ),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Congress Road, Tilakwadi',
        pincode: '590006',
        latitude: 15.8450,
        longitude: 74.5020,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(pendingProperty.status.dbValue, 'pending_verification');

      // Admin approves listing
      final approvedProperty = pendingProperty.copyWith(
        status: ListingStatus.published,
        verificationStatus: VerificationStatus.verified,
      );

      expect(approvedProperty.status.dbValue, 'active');
      expect(approvedProperty.verificationStatus.dbValue, 'verified');
      expect(approvedProperty.id, pendingProperty.id);
      expect(approvedProperty.city, 'Belagavi');
      expect(approvedProperty.locality, 'Tilakwadi');
    });

    // 5. Property Payload Security: toDatabaseJson excludes virtual media to prevent Postgres schema errors
    test('toDatabaseJson ensures strict database schema compliance', () {
      final propertyWithMedia = PropertyModel(
        id: 'prop_live_e2e_001',
        ownerId: 'usr_seller_123',
        title: 'BELAGAVI LIVE E2E PROPERTY',
        description: 'Prime verified property in Tilakwadi',
        category: PropertyCategory.residential,
        type: PropertySubtype.independentHouse,
        status: ListingStatus.pendingVerification,
        price: 9500000.0,
        specifications: const PropertySpecificationsEntity(
          carpetArea: 1800.0,
          bedrooms: 3,
        ),
        mediaList: [
          PropertyMediaModel(
            id: 'med_001',
            propertyId: 'prop_live_e2e_001',
            mediaUrl: 'https://example.com/photo1.jpg',
            isCover: true,
          ),
          PropertyMediaModel(
            id: 'med_002',
            propertyId: 'prop_live_e2e_001',
            mediaUrl: 'https://example.com/photo2.jpg',
            isCover: false,
          ),
        ],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Congress Road, Tilakwadi',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dbJson = propertyWithMedia.toDatabaseJson();
      expect(dbJson.containsKey('property_media'), isFalse);
      expect(dbJson.containsKey('media_list'), isFalse);
      expect(dbJson['status'], 'pending_verification');
      expect(dbJson['city'], 'Belagavi');
      expect(dbJson['locality'], 'Tilakwadi');

      // But toJson for local draft preserves property_media
      final localJson = propertyWithMedia.toJson();
      expect(localJson.containsKey('property_media'), isTrue);
      expect((localJson['property_media'] as List).length, 2);
    });

    // 6. Hold / Resume Architecture: is_paused boolean without touching enum
    test('Hold and Resume controls mutate is_paused while status remains active', () {
      final activeListing = PropertyModel(
        id: 'prop_hold_test_001',
        ownerId: 'usr_seller_123',
        title: 'HOLD TEST PROPERTY',
        description: 'Testing hold functionality',
        category: PropertyCategory.residential,
        type: PropertySubtype.independentHouse,
        status: ListingStatus.active,
        isPaused: false,
        price: 5000000.0,
        specifications: const PropertySpecificationsEntity(carpetArea: 1200.0),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Congress Road',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(activeListing.status.dbValue, 'active');
      expect(activeListing.isPaused, isFalse);

      // Seller puts property on hold
      final pausedListing = activeListing.copyWith(isPaused: true);
      expect(pausedListing.isPaused, isTrue);
      expect(pausedListing.status.dbValue, 'active'); // Remains active in DB enum!

      // Seller resumes property
      final resumedListing = pausedListing.copyWith(isPaused: false);
      expect(resumedListing.isPaused, isFalse);
      expect(resumedListing.status.dbValue, 'active');
    });

    // 7. Belagavi 15 Administrative Taluks
    test('IndiaLocationDirectory defines and recognizes 15 Belagavi taluks', () {
      expect(IndiaLocationDirectory.belagaviTaluks.length, 15);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Gokak'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('chikkodi'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Bailhongal'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Athani'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Savadatti'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Ramdurg'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Hukkeri'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Khanapur'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Raybag'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Kagawad'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Kittur'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Mudalgi'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Nippani'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Yaragatti'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Belagavi'), isTrue);
      expect(IndiaLocationDirectory.isBelagaviTaluk('Panaji'), isFalse);
    });
  });
}
