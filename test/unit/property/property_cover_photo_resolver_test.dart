import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/services/property_media_resolver.dart';

void main() {
  group('PropertyMediaResolver Cover Photo Rules', () {
    PropertyEntity createTestProperty(List<PropertyMediaEntity> mediaList) {
      return PropertyEntity(
        id: 'prop_test_uuid',
        ownerId: 'usr_test_owner',
        title: 'Test Property',
        description: 'Description',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        price: 5000000.0,
        specifications: const PropertySpecificationsEntity(),
        mediaList: mediaList,
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Tilakwadi',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('Returns explicit cover photo when isCover is true', () {
      final property = createTestProperty([
        PropertyMediaEntity(
          id: 'med_001',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/photo1.jpg',
          type: MediaType.image,
          displayOrder: 0,
          isCover: false,
          uploadedAt: DateTime.now(),
        ),
        PropertyMediaEntity(
          id: 'med_002',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/cover.jpg',
          type: MediaType.image,
          displayOrder: 1,
          isCover: true,
          uploadedAt: DateTime.now(),
        ),
      ]);

      final coverUrl = PropertyMediaResolver.getCoverUrl(property);
      expect(coverUrl, 'https://example.com/cover.jpg');
    });

    test('Returns lowest displayOrder image when no explicit isCover is set', () {
      final property = createTestProperty([
        PropertyMediaEntity(
          id: 'med_003',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/second.jpg',
          type: MediaType.image,
          displayOrder: 2,
          isCover: false,
          uploadedAt: DateTime.now(),
        ),
        PropertyMediaEntity(
          id: 'med_001',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/first.jpg',
          type: MediaType.image,
          displayOrder: 0,
          isCover: false,
          uploadedAt: DateTime.now(),
        ),
      ]);

      final coverUrl = PropertyMediaResolver.getCoverUrl(property);
      expect(coverUrl, 'https://example.com/first.jpg');
    });

    test('Skips empty URL and falls back to first valid URL', () {
      final property = createTestProperty([
        PropertyMediaEntity(
          id: 'med_001',
          propertyId: 'prop_test_uuid',
          mediaUrl: '   ',
          type: MediaType.image,
          displayOrder: 0,
          isCover: true, // Empty URL cover
          uploadedAt: DateTime.now(),
        ),
        PropertyMediaEntity(
          id: 'med_002',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/valid_backup.jpg',
          type: MediaType.image,
          displayOrder: 1,
          isCover: false,
          uploadedAt: DateTime.now(),
        ),
      ]);

      final coverUrl = PropertyMediaResolver.getCoverUrl(property);
      expect(coverUrl, 'https://example.com/valid_backup.jpg');
    });

    test('Returns default placeholder when mediaList is empty', () {
      final property = createTestProperty([]);
      final coverUrl = PropertyMediaResolver.getCoverUrl(property);
      expect(coverUrl, PropertyMediaResolver.defaultPlaceholder);
    });

    test('Returns default placeholder when property is null', () {
      final coverUrl = PropertyMediaResolver.getCoverUrl(null);
      expect(coverUrl, PropertyMediaResolver.defaultPlaceholder);
    });

    test('getOrderedMedia puts cover photo first regardless of array position', () {
      final property = createTestProperty([
        PropertyMediaEntity(
          id: 'med_001',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/photo1.jpg',
          type: MediaType.image,
          displayOrder: 0,
          isCover: false,
          uploadedAt: DateTime.now(),
        ),
        PropertyMediaEntity(
          id: 'med_002',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/photo2.jpg',
          type: MediaType.image,
          displayOrder: 1,
          isCover: false,
          uploadedAt: DateTime.now(),
        ),
        PropertyMediaEntity(
          id: 'med_003',
          propertyId: 'prop_test_uuid',
          mediaUrl: 'https://example.com/cover.jpg',
          type: MediaType.image,
          displayOrder: 2,
          isCover: true,
          uploadedAt: DateTime.now(),
        ),
      ]);

      final ordered = PropertyMediaResolver.getOrderedMedia(property);
      expect(ordered.first.id, 'med_003');
      expect(ordered.first.isCover, isTrue);
      expect(ordered.length, 3);
    });
  });
}
