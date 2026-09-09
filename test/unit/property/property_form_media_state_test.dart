import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';

class MockPropertyRepository implements PropertyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PropertyFormNotifier Media & Location State Preservation', () {
    late PropertyFormNotifier notifier;
    late MockPropertyRepository mockRepo;

    setUp(() {
      mockRepo = MockPropertyRepository();
      notifier = PropertyFormNotifier(mockRepo);
      notifier.initForNewProperty('usr_owner_123');
    });

    test('Adding photo strictly preserves location fields', () {
      // 1. Set explicit location
      notifier.updateLocation(
        country: 'India',
        stateName: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        pincode: '590006',
        latitude: 15.8450,
        longitude: 74.5020,
      );

      expect(notifier.state.city, 'Belagavi');
      expect(notifier.state.locality, 'Tilakwadi');
      expect(notifier.state.latitude, 15.8450);
      expect(notifier.state.longitude, 74.5020);

      // 2. Add first photo
      final photo1 = PropertyMediaEntity(
        id: 'med_001',
        propertyId: 'prop_001',
        mediaUrl: 'https://storage.example.com/photo1.jpg',
        type: MediaType.image,
        displayOrder: 0,
        isCover: true,
        uploadedAt: DateTime.now(),
      );
      notifier.addMedia(photo1);

      expect(notifier.state.mediaList.length, 1);
      expect(notifier.state.mediaList.first.isCover, isTrue);
      // Location must remain 100% intact
      expect(notifier.state.city, 'Belagavi');
      expect(notifier.state.locality, 'Tilakwadi');
      expect(notifier.state.latitude, 15.8450);
      expect(notifier.state.longitude, 74.5020);

      // 3. Add second photo
      final photo2 = PropertyMediaEntity(
        id: 'med_002',
        propertyId: 'prop_001',
        mediaUrl: 'https://storage.example.com/photo2.jpg',
        type: MediaType.image,
        displayOrder: 1,
        isCover: false,
        uploadedAt: DateTime.now(),
      );
      notifier.addMedia(photo2);

      expect(notifier.state.mediaList.length, 2);
      expect(notifier.state.mediaList[1].isCover, isFalse);
      expect(notifier.state.city, 'Belagavi');
      expect(notifier.state.locality, 'Tilakwadi');
      expect(notifier.state.latitude, 15.8450);
      expect(notifier.state.longitude, 74.5020);
    });

    test('Removing photo strictly preserves location fields', () {
      notifier.updateLocation(
        city: 'Belagavi',
        locality: 'Tilakwadi',
        latitude: 15.8450,
        longitude: 74.5020,
      );

      notifier.addMedia(PropertyMediaEntity(
        id: 'med_001',
        propertyId: 'prop_001',
        mediaUrl: 'https://storage.example.com/photo1.jpg',
        type: MediaType.image,
        displayOrder: 0,
        isCover: true,
        uploadedAt: DateTime.now(),
      ));

      notifier.addMedia(PropertyMediaEntity(
        id: 'med_002',
        propertyId: 'prop_001',
        mediaUrl: 'https://storage.example.com/photo2.jpg',
        type: MediaType.image,
        displayOrder: 1,
        isCover: false,
        uploadedAt: DateTime.now(),
      ));

      notifier.removeMedia('med_002');

      expect(notifier.state.mediaList.length, 1);
      expect(notifier.state.mediaList.first.id, 'med_001');
      expect(notifier.state.city, 'Belagavi');
      expect(notifier.state.locality, 'Tilakwadi');
      expect(notifier.state.latitude, 15.8450);
      expect(notifier.state.longitude, 74.5020);
    });

    test('5 consecutive async media additions preserve all 5 photos with stable ordering', () async {
      notifier.updateLocation(city: 'Belagavi', locality: 'Tilakwadi');

      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 5));
        notifier.addMedia(PropertyMediaEntity(
          id: 'med_00$i',
          propertyId: 'prop_001',
          mediaUrl: 'https://storage.example.com/photo$i.jpg',
          type: MediaType.image,
          displayOrder: i,
          isCover: i == 0,
          uploadedAt: DateTime.now(),
        ));
      }

      expect(notifier.state.mediaList.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(notifier.state.mediaList[i].id, 'med_00$i');
        expect(notifier.state.mediaList[i].displayOrder, i);
      }
      expect(notifier.state.mediaList.first.isCover, isTrue);
      expect(notifier.state.city, 'Belagavi');
      expect(notifier.state.locality, 'Tilakwadi');
    });

    test('Changing location strictly preserves all mediaList items', () {
      final photo = PropertyMediaEntity(
        id: 'med_001',
        propertyId: 'prop_001',
        mediaUrl: 'https://storage.example.com/photo1.jpg',
        type: MediaType.image,
        displayOrder: 0,
        isCover: true,
        uploadedAt: DateTime.now(),
      );
      notifier.addMedia(photo);

      // Change location
      notifier.updateLocation(
        city: 'Belagavi',
        locality: 'Hindwadi',
        latitude: 15.8420,
        longitude: 74.4980,
      );

      expect(notifier.state.mediaList.length, 1);
      expect(notifier.state.mediaList.first.id, 'med_001');
      expect(notifier.state.city, 'Belagavi');
      expect(notifier.state.locality, 'Hindwadi');
      expect(notifier.state.latitude, 15.8420);
      expect(notifier.state.longitude, 74.4980);
    });

    test('setPropertyId preserves form location and mediaList', () {
      notifier.updateLocation(city: 'Belagavi', locality: 'Tilakwadi');
      notifier.addMedia(PropertyMediaEntity(
        id: 'med_001',
        propertyId: '',
        mediaUrl: 'https://storage.example.com/photo1.jpg',
        type: MediaType.image,
        displayOrder: 0,
        isCover: true,
        uploadedAt: DateTime.now(),
      ));

      notifier.setPropertyId('3fa85f64-5717-4562-b3fc-2c963f66afa6');

      expect(notifier.state.id, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(notifier.state.city, 'Belagavi');
      expect(notifier.state.locality, 'Tilakwadi');
      expect(notifier.state.mediaList.length, 1);
    });

    test('Cover photo is reassigned to first photo when cover is removed', () {
      notifier.addMedia(PropertyMediaEntity(
        id: 'med_cover',
        propertyId: 'prop_001',
        mediaUrl: 'https://storage.example.com/photo1.jpg',
        type: MediaType.image,
        displayOrder: 0,
        isCover: true,
        uploadedAt: DateTime.now(),
      ));

      notifier.addMedia(PropertyMediaEntity(
        id: 'med_second',
        propertyId: 'prop_001',
        mediaUrl: 'https://storage.example.com/photo2.jpg',
        type: MediaType.image,
        displayOrder: 1,
        isCover: false,
        uploadedAt: DateTime.now(),
      ));

      notifier.removeMedia('med_cover');

      expect(notifier.state.mediaList.length, 1);
      expect(notifier.state.mediaList.first.id, 'med_second');
      expect(notifier.state.mediaList.first.isCover, isTrue);
      expect(notifier.state.mediaList.first.displayOrder, 0);
    });
  });
}
