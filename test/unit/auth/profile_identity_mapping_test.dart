import 'package:flutter_test/flutter_test.dart';

bool isValidUuid(String? str) {
  if (str == null || str.length != 36) return false;
  final uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  return uuidRegex.hasMatch(str);
}

void main() {
  group('Profile Identity Mapping Contract Tests', () {
    const firebaseUid = 'p4fZZLm8a6SKngVRe4r46rd5aaA2';
    const profileIdUuid = '4d91cf6e-f52a-48d2-9250-920a1d81eac2';

    test('Firebase UID is preserved as external identity key string without UUID corruption', () {
      expect(firebaseUid, isA<String>());
      expect(firebaseUid.length, greaterThan(20));
      // Firebase UID must NEVER be assumed or forced to be a valid UUID
      expect(isValidUuid(firebaseUid), isFalse);
    });

    test('profiles.id is an independent, valid UUID v4', () {
      expect(isValidUuid(profileIdUuid), isTrue);
      expect(profileIdUuid, isNot(equals(firebaseUid)));
    });

    test('Firebase UID must not be directly cast to UUID in database payloads', () {
      // Simulate attempting to cast Firebase UID directly as a PostgreSQL UUID
      expect(() {
        if (!isValidUuid(firebaseUid)) {
          throw const FormatException('Invalid UUID format for Firebase UID');
        }
      }, throwsFormatException);
    });

    test('Duplicate firebase_uid is rejected by unique identity constraint model', () {
      final registry = <String, String>{}; // firebase_uid -> profile_id
      registry[firebaseUid] = profileIdUuid;

      expect(registry.containsKey(firebaseUid), isTrue);

      // Attempting to register another profile with same firebase_uid must be blocked
      const duplicateFirebaseUid = 'p4fZZLm8a6SKngVRe4r46rd5aaA2';
      const secondProfileUuid = '5dc889f2-550b-4dc7-88f0-4c060473c410';

      expect(registry.containsKey(duplicateFirebaseUid), isTrue);
      expect(
        () {
          if (registry.containsKey(duplicateFirebaseUid)) {
            throw Exception('UNIQUE constraint violation: idx_profiles_firebase_uid');
          }
          registry[duplicateFirebaseUid] = secondProfileUuid;
        },
        throwsA(predicate((e) => e.toString().contains('UNIQUE constraint violation'))),
      );
    });
  });
}
