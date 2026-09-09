import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/data/models/property_models.dart';

void main() {
  group('Property Media & Location Serialization Tests', () {
    final testMedia = [
      PropertyMediaModel(
        id: 'med_001',
        propertyId: 'prop_test_123',
        mediaUrl: 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-images/photo1.jpg',
        type: MediaType.image,
        displayOrder: 0,
        isCover: true,
        caption: 'Front Elevation',
      ),
      PropertyMediaModel(
        id: 'med_002',
        propertyId: 'prop_test_123',
        mediaUrl: 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-images/photo2.jpg',
        type: MediaType.image,
        displayOrder: 1,
        isCover: false,
        caption: 'Master Bedroom',
      ),
    ];

    final testProperty = PropertyModel(
      id: 'prop_test_123',
      ownerId: 'usr_owner_456',
      title: '3BHK Luxury Villa Tilakwadi',
      description: 'Prime property in Tilakwadi with road frontage',
      category: PropertyCategory.residential,
      type: PropertySubtype.independentHouse,
      status: ListingStatus.draft,
      verificationStatus: VerificationStatus.unverified,
      price: 12500000.0,
      isNegotiable: true,
      specifications: const PropertySpecificationsEntity(
        carpetArea: 2200.0,
        superBuiltUpArea: 2600.0,
        bedrooms: 3,
        bathrooms: 3,
        balconies: 2,
      ),
      mediaList: testMedia,
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      address: 'Congress Road, Tilakwadi',
      pincode: '590006',
      latitude: 15.8450,
      longitude: 74.5020,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 4),
    );

    test('PropertyModel.toJson() includes property_media for local draft vault survival', () {
      final json = testProperty.toJson();

      expect(json['property_media'], isNotNull);
      expect((json['property_media'] as List).length, 2);
      expect(json['city'], 'Belagavi');
      expect(json['locality'], 'Tilakwadi');
      expect(json['latitude'], 15.8450);
      expect(json['longitude'], 74.5020);
    });

    test('PropertyModel.toDatabaseJson() excludes property_media to prevent column errors in Postgres', () {
      final dbJson = testProperty.toDatabaseJson();

      expect(dbJson.containsKey('property_media'), isFalse);
      expect(dbJson.containsKey('media_list'), isFalse);
      expect(dbJson['id'], 'prop_test_123');
      expect(dbJson['status'], 'draft');
      expect(dbJson['price'], 12500000.0);
    });

    test('PropertyModel roundtrip preserves media, coordinates, and canonical location', () {
      final json = testProperty.toJson();
      final reconstructed = PropertyModel.fromJson(json);

      expect(reconstructed.id, testProperty.id);
      expect(reconstructed.mediaList.length, 2);
      expect(reconstructed.mediaList.first.mediaUrl, testProperty.mediaList.first.mediaUrl);
      expect(reconstructed.mediaList.first.isCover, isTrue);
      expect(reconstructed.city, 'Belagavi');
      expect(reconstructed.locality, 'Tilakwadi');
      expect(reconstructed.latitude, 15.8450);
      expect(reconstructed.longitude, 74.5020);
    });

    test('CopyWith preserves both media and location coordinates', () {
      final updated = testProperty.copyWith(
        title: 'Updated Villa Title',
        locality: 'Hindwadi',
      );

      expect(updated.mediaList.length, 2);
      expect(updated.latitude, 15.8450);
      expect(updated.longitude, 74.5020);
      expect(updated.locality, 'Hindwadi');
      expect(updated.title, 'Updated Villa Title');
    });
  });
}
