import 'package:flutter_test/flutter_test.dart';

bool isValidUuid(String? str) {
  if (str == null || str.length != 36) return false;
  final uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  return uuidRegex.hasMatch(str);
}

class MockProfileStore {
  final Map<String, Map<String, dynamic>> _profilesByFirebaseUid = {};
  int insertCallCount = 0;
  int selectCallCount = 0;

  Future<String?> resolveOrCreateProfileUuid(String firebaseUid, {String? defaultUuid}) async {
    if (firebaseUid.isEmpty) return null;
    if (isValidUuid(firebaseUid)) return firebaseUid;

    // 1. Check existing
    selectCallCount++;
    if (_profilesByFirebaseUid.containsKey(firebaseUid)) {
      return _profilesByFirebaseUid[firebaseUid]!['id'] as String;
    }

    // 2. Auto-provision
    insertCallCount++;
    final generatedUuid = defaultUuid ?? '4d91cf6e-f52a-48d2-9250-920a1d81eac2';
    _profilesByFirebaseUid[firebaseUid] = {
      'id': generatedUuid,
      'firebase_uid': firebaseUid,
      'full_name': 'Belagavi Property User',
      'role': 'buyer',
    };
    return generatedUuid;
  }
}

void main() {
  group('Profile Provisioning Contract Tests', () {
    const firebaseUid = 'p4fZZLm8a6SKngVRe4r46rd5aaA2';
    const profileUuid = '4d91cf6e-f52a-48d2-9250-920a1d81eac2';

    test('Missing profile inserts under RLS and returns valid UUID', () async {
      final store = MockProfileStore();
      final resolved = await store.resolveOrCreateProfileUuid(firebaseUid, defaultUuid: profileUuid);

      expect(resolved, equals(profileUuid));
      expect(isValidUuid(resolved), isTrue);
      expect(store.insertCallCount, equals(1));
    });

    test('Existing profile resolves without re-inserting', () async {
      final store = MockProfileStore();
      // First call: inserts
      await store.resolveOrCreateProfileUuid(firebaseUid, defaultUuid: profileUuid);
      expect(store.insertCallCount, equals(1));

      // Second call: resolves directly from select
      final secondResolved = await store.resolveOrCreateProfileUuid(firebaseUid);
      expect(secondResolved, equals(profileUuid));
      expect(store.insertCallCount, equals(1)); // No duplicate insert
      expect(store.selectCallCount, equals(2));
    });

    test('Second call returns the exact same profile UUID (idempotency)', () async {
      final store = MockProfileStore();
      final id1 = await store.resolveOrCreateProfileUuid(firebaseUid, defaultUuid: profileUuid);
      final id2 = await store.resolveOrCreateProfileUuid(firebaseUid, defaultUuid: 'different-uuid-should-not-be-used');

      expect(id1, equals(id2));
      expect(id2, equals(profileUuid));
    });
  });
}
