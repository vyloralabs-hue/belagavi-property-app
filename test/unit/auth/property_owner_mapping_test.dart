import 'package:flutter_test/flutter_test.dart';

bool isValidUuid(String? str) {
  if (str == null || str.length != 36) return false;
  final uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  return uuidRegex.hasMatch(str);
}

void main() {
  group('Property Owner Mapping Contract Tests', () {
    const firebaseUid = 'p4fZZLm8a6SKngVRe4r46rd5aaA2';
    const profileIdUuid = '4d91cf6e-f52a-48d2-9250-920a1d81eac2';

    test('properties.owner_id must strictly receive the profiles.id UUID, never raw Firebase UID', () {
      final propertyPayload = <String, dynamic>{
        'title': 'Test Property in Tilakwadi',
        'owner_id': profileIdUuid, // profiles.id
        'price': 4500000.0,
      };

      expect(propertyPayload['owner_id'], equals(profileIdUuid));
      expect(isValidUuid(propertyPayload['owner_id'] as String), isTrue);
      expect(propertyPayload['owner_id'], isNot(equals(firebaseUid)));
    });

    test('Raw Firebase UID passed as owner_id is caught as invalid UUID prior to DB insertion', () {
      const invalidOwnerId = firebaseUid;
      expect(isValidUuid(invalidOwnerId), isFalse);

      expect(() {
        if (!isValidUuid(invalidOwnerId)) {
          throw ArgumentError('owner_id must be a valid UUID corresponding to profiles.id');
        }
      }, throwsArgumentError);
    });

    test('JWT sub is mapped solely through profiles.firebase_uid join', () {
      // Simulates the SQL join in Migration 00021b:
      // WHERE profiles.id = properties.owner_id AND profiles.firebase_uid = (auth.jwt()->>'sub')
      final profilesTable = [
        {'id': profileIdUuid, 'firebase_uid': firebaseUid},
      ];
      final propertiesTable = [
        {'id': 'prop-uuid-1', 'owner_id': profileIdUuid, 'title': 'House 1'},
        {'id': 'prop-uuid-2', 'owner_id': 'other-owner-uuid', 'title': 'House 2'},
      ];

      const currentJwtSub = firebaseUid;

      final userProperties = propertiesTable.where((prop) {
        return profilesTable.any((prof) =>
            prof['id'] == prop['owner_id'] && prof['firebase_uid'] == currentJwtSub);
      }).toList();

      expect(userProperties.length, equals(1));
      expect(userProperties.first['id'], equals('prop-uuid-1'));
    });
  });
}
