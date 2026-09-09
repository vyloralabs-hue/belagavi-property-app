import 'package:flutter_test/flutter_test.dart';

class MockRlsEvaluator {
  // Simulates PostgreSQL RLS for public.profiles and public.properties
  static bool checkProfileInsert({
    required String? jwtSub,
    required String insertedFirebaseUid,
  }) {
    // Policy: WITH CHECK (auth.jwt()->>'sub' IS NOT NULL AND firebase_uid = (auth.jwt()->>'sub'))
    if (jwtSub == null || jwtSub.isEmpty) return false;
    return insertedFirebaseUid == jwtSub;
  }

  static bool checkProfileSelect({
    required String? jwtSub,
    required String rowFirebaseUid,
    bool isAdmin = false,
  }) {
    // Policy: USING (firebase_uid = (auth.jwt()->>'sub') OR is_app_admin_or_founder())
    if (isAdmin) return true;
    if (jwtSub == null || jwtSub.isEmpty) return false;
    return rowFirebaseUid == jwtSub;
  }

  static bool checkPropertyOwner({
    required String? jwtSub,
    required String propertyOwnerId,
    required Map<String, String> profileIdToFirebaseUid,
    bool isAdmin = false,
  }) {
    // Policy: USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = properties.owner_id AND profiles.firebase_uid = auth.jwt()->>'sub'))
    if (isAdmin) return true;
    if (jwtSub == null || jwtSub.isEmpty) return false;
    final rowFirebaseUid = profileIdToFirebaseUid[propertyOwnerId];
    return rowFirebaseUid != null && rowFirebaseUid == jwtSub;
  }
}

void main() {
  group('Profile RLS Contract Tests', () {
    const callerJwtSub = 'p4fZZLm8a6SKngVRe4r46rd5aaA2';
    const otherUserSub = 'attacker_or_other_user_uid_999';
    const profileUuid = '4d91cf6e-f52a-48d2-9250-920a1d81eac2';

    test('Own profile insert is allowed when firebase_uid matches JWT sub', () {
      final allowed = MockRlsEvaluator.checkProfileInsert(
        jwtSub: callerJwtSub,
        insertedFirebaseUid: callerJwtSub,
      );
      expect(allowed, isTrue);
    });

    test('Inserting profile for different firebase_uid is strictly denied by RLS', () {
      final allowed = MockRlsEvaluator.checkProfileInsert(
        jwtSub: callerJwtSub,
        insertedFirebaseUid: otherUserSub,
      );
      expect(allowed, isFalse);
    });

    test('Unauthenticated insert without JWT sub is strictly denied by RLS', () {
      final allowed = MockRlsEvaluator.checkProfileInsert(
        jwtSub: null,
        insertedFirebaseUid: callerJwtSub,
      );
      expect(allowed, isFalse);
    });

    test('Own profile select is allowed', () {
      final allowed = MockRlsEvaluator.checkProfileSelect(
        jwtSub: callerJwtSub,
        rowFirebaseUid: callerJwtSub,
      );
      expect(allowed, isTrue);
    });

    test('Selecting another users profile is denied to standard users', () {
      final allowed = MockRlsEvaluator.checkProfileSelect(
        jwtSub: callerJwtSub,
        rowFirebaseUid: otherUserSub,
      );
      expect(allowed, isFalse);
    });

    test('Admin can select any profile', () {
      final allowed = MockRlsEvaluator.checkProfileSelect(
        jwtSub: callerJwtSub,
        rowFirebaseUid: otherUserSub,
        isAdmin: true,
      );
      expect(allowed, isTrue);
    });

    test('Property ownership RLS resolves correctly through profiles.id -> profiles.firebase_uid', () {
      final profileRegistry = {profileUuid: callerJwtSub};
      final allowed = MockRlsEvaluator.checkPropertyOwner(
        jwtSub: callerJwtSub,
        propertyOwnerId: profileUuid,
        profileIdToFirebaseUid: profileRegistry,
      );
      expect(allowed, isTrue);
    });
  });
}
