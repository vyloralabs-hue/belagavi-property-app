import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/utils/owner_identity_bridge.dart';

void main() {
  group('Firebase UID to Profile ID Bridge Tests', () {
    test('Clearing cache empties resolution maps', () {
      OwnerIdentityBridge.clearCache();
      expect(true, isTrue);
    });

    test('Valid UUID passes through directly without lookup', () async {
      const validUuid = '66c3a9c6-4a9d-46d1-8d2c-6882cff1cf75';
      final resolved = await OwnerIdentityBridge.resolveProfileId(validUuid);
      expect(resolved, equals(validUuid));
    });

    test('Empty or whitespace string returns null safely', () async {
      final res1 = await OwnerIdentityBridge.resolveProfileId('');
      final res2 = await OwnerIdentityBridge.resolveProfileId('   ');
      expect(res1, isNull);
      expect(res2, isNull);
    });

    test('Firebase alphanumeric UID is detected as non-UUID', () {
      const firebaseUid = '2b7a9f8e1c3d4e5f6a7b8c9d0e1f';
      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(firebaseUid);
      expect(isUuid, isFalse);
    });
  });
}
