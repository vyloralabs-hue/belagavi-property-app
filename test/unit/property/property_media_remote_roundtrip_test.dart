import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/data/models/property_models.dart';

void main() {
  group('Property & Media Remote Roundtrip Simulation', () {
    test('Simulated Supabase postgREST response with property_media(*) join deserializes correctly', () {
      final mockPostgrestResponse = {
        'id': 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
        'owner_id': 'f1e2d3c4-b5a6-4978-8123-abcdef123456',
        'title': '4BHK Independent Bungalow Mandoli Road',
        'description': 'Luxurious bungalow with landscaped garden and borewell',
        'category': 'residential',
        'type': 'independent_house',
        'status': 'active',
        'verification_status': 'verified',
        'price': 18500000.0,
        'is_negotiable': true,
        'city': 'Belagavi',
        'locality': 'Tilakwadi',
        'district': 'Belagavi',
        'taluk': 'Belagavi',
        'state': 'Karnataka',
        'address': 'Mandoli Road, Tilakwadi',
        'pincode': '590006',
        'latitude': 15.8412,
        'longitude': 74.4988,
        'created_at': '2026-09-01T10:00:00.000Z',
        'updated_at': '2026-09-04T12:00:00.000Z',
        'features': {
          'listingType': 'FOR_SALE',
          'purpose': 'FOR_SALE',
        },
        'property_media': [
          {
            'id': 'm2-uuid',
            'property_id': 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
            'media_url': 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-media/user1/prop1/images/garden.jpg',
            'type': 'image',
            'display_order': 1,
            'is_cover': false,
            'caption': 'Garden View',
            'created_at': '2026-09-01T10:05:00.000Z',
          },
          {
            'id': 'm1-uuid',
            'property_id': 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
            'media_url': 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-media/user1/prop1/images/front.jpg',
            'type': 'image',
            'display_order': 0,
            'is_cover': true,
            'caption': 'Front Elevation',
            'created_at': '2026-09-01T10:02:00.000Z',
          },
        ],
      };

      final model = PropertyModel.fromJson(mockPostgrestResponse);

      // Verify UUID association
      expect(model.id, 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d');
      expect(model.mediaList.length, 2);

      // Verify display_order sorting ascending
      expect(model.mediaList[0].id, 'm1-uuid');
      expect(model.mediaList[0].displayOrder, 0);
      expect(model.mediaList[0].isCover, isTrue);
      expect(model.mediaList[0].mediaUrl, contains('front.jpg'));

      expect(model.mediaList[1].id, 'm2-uuid');
      expect(model.mediaList[1].displayOrder, 1);
      expect(model.mediaList[1].isCover, isFalse);
      expect(model.mediaList[1].mediaUrl, contains('garden.jpg'));

      // Verify location fields
      expect(model.city, 'Belagavi');
      expect(model.locality, 'Tilakwadi');
      expect(model.latitude, 15.8412);
      expect(model.longitude, 74.4988);
    });

    test('toDatabaseJson strips property_media to prevent column error in properties table', () {
      final property = PropertyModel(
        id: 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
        ownerId: 'owner_123',
        title: 'Title',
        description: 'Desc',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        price: 5000000.0,
        specifications: const PropertySpecificationsEntity(),
        mediaList: [
          PropertyMediaModel(
            id: 'm1',
            propertyId: 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
            mediaUrl: 'https://example.com/photo.jpg',
            type: MediaType.image,
            displayOrder: 0,
            isCover: true,
            uploadedAt: DateTime.now(),
          ),
        ],
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

      final dbJson = property.toDatabaseJson();
      expect(dbJson.containsKey('property_media'), isFalse);
      expect(dbJson.containsKey('media_list'), isFalse);
      expect(dbJson['id'], 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d');
    });
  });
}
