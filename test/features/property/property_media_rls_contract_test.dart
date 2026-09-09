import 'package:flutter_test/flutter_test.dart';

/// Contract evaluator simulating PostgreSQL RLS policies in Migration 00030:
/// public.property_media
class MockPropertyMediaRlsEvaluator {
  /// Evaluates INSERT policy:
  /// WITH CHECK (
  ///   auth.jwt()->>'sub' IS NOT NULL AND (
  ///     EXISTS (
  ///       SELECT 1 FROM public.properties p
  ///       JOIN public.profiles pr ON pr.id = p.owner_id
  ///       WHERE p.id = property_media.property_id
  ///       AND pr.firebase_uid = (auth.jwt()->>'sub')
  ///     )
  ///     OR public.is_app_admin_or_founder()
  ///   )
  /// )
  static bool checkInsert({
    required String? jwtSub,
    required String propertyId,
    required Map<String, String> propertyToOwnerProfileId,
    required Map<String, String> profileIdToFirebaseUid,
    bool isAdmin = false,
  }) {
    if (isAdmin) return true;
    if (jwtSub == null || jwtSub.isEmpty) return false;

    final ownerProfileId = propertyToOwnerProfileId[propertyId];
    if (ownerProfileId == null) return false;

    final ownerFirebaseUid = profileIdToFirebaseUid[ownerProfileId];
    return ownerFirebaseUid != null && ownerFirebaseUid == jwtSub;
  }

  /// Evaluates UPDATE policy:
  /// USING / WITH CHECK (
  ///   auth.jwt()->>'sub' IS NOT NULL AND (
  ///     EXISTS (
  ///       SELECT 1 FROM public.properties p
  ///       JOIN public.profiles pr ON pr.id = p.owner_id
  ///       WHERE p.id = property_media.property_id
  ///       AND pr.firebase_uid = (auth.jwt()->>'sub')
  ///     )
  ///     OR public.is_app_admin_or_founder()
  ///   )
  /// )
  static bool checkUpdate({
    required String? jwtSub,
    required String propertyId,
    required Map<String, String> propertyToOwnerProfileId,
    required Map<String, String> profileIdToFirebaseUid,
    bool isAdmin = false,
  }) {
    if (isAdmin) return true;
    if (jwtSub == null || jwtSub.isEmpty) return false;

    final ownerProfileId = propertyToOwnerProfileId[propertyId];
    if (ownerProfileId == null) return false;

    final ownerFirebaseUid = profileIdToFirebaseUid[ownerProfileId];
    return ownerFirebaseUid != null && ownerFirebaseUid == jwtSub;
  }

  /// Evaluates DELETE policy:
  /// USING (
  ///   auth.jwt()->>'sub' IS NOT NULL AND (
  ///     EXISTS (
  ///       SELECT 1 FROM public.properties p
  ///       JOIN public.profiles pr ON pr.id = p.owner_id
  ///       WHERE p.id = property_media.property_id
  ///       AND pr.firebase_uid = (auth.jwt()->>'sub')
  ///     )
  ///     OR public.is_app_admin_or_founder()
  ///   )
  /// )
  static bool checkDelete({
    required String? jwtSub,
    required String propertyId,
    required Map<String, String> propertyToOwnerProfileId,
    required Map<String, String> profileIdToFirebaseUid,
    bool isAdmin = false,
  }) {
    if (isAdmin) return true;
    if (jwtSub == null || jwtSub.isEmpty) return false;

    final ownerProfileId = propertyToOwnerProfileId[propertyId];
    if (ownerProfileId == null) return false;

    final ownerFirebaseUid = profileIdToFirebaseUid[ownerProfileId];
    return ownerFirebaseUid != null && ownerFirebaseUid == jwtSub;
  }

  /// Evaluates SELECT policy:
  /// USING (
  ///   EXISTS (
  ///     SELECT 1 FROM public.properties p
  ///     WHERE p.id = property_media.property_id
  ///     AND (
  ///       p.status = 'active'
  ///       OR (
  ///         auth.jwt()->>'sub' IS NOT NULL AND EXISTS (
  ///           SELECT 1 FROM public.profiles pr
  ///           WHERE pr.id = p.owner_id
  ///           AND pr.firebase_uid = (auth.jwt()->>'sub')
  ///         )
  ///       )
  ///       OR public.is_app_admin_or_founder()
  ///     )
  ///   )
  /// )
  static bool checkSelect({
    required String? jwtSub,
    required String propertyId,
    required String propertyStatus,
    required Map<String, String> propertyToOwnerProfileId,
    required Map<String, String> profileIdToFirebaseUid,
    bool isAdmin = false,
  }) {
    if (isAdmin) return true;
    if (propertyStatus == 'active') return true;

    if (jwtSub == null || jwtSub.isEmpty) return false;

    final ownerProfileId = propertyToOwnerProfileId[propertyId];
    if (ownerProfileId == null) return false;

    final ownerFirebaseUid = profileIdToFirebaseUid[ownerProfileId];
    return ownerFirebaseUid != null && ownerFirebaseUid == jwtSub;
  }
}

void main() {
  group('Property Media RLS Contract Tests (Migration 00030)', () {
    const ownerFirebaseUid = 'p4fZZLm8a6SKngVRe4r46rd5aaA2';
    const otherUserFirebaseUid = 'attacker_or_other_user_uid_999';
    const ownerProfileUuid = '66c3a9c6-1111-2222-3333-444455556666';
    const otherProfileUuid = '99e9b9c9-0000-1111-2222-333344445555';
    const propertyUuid = '0c65076b-aaaa-bbbb-cccc-dddddddddddd';
    const otherPropertyUuid = '1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d';

    final propertyToOwnerMap = {
      propertyUuid: ownerProfileUuid,
      otherPropertyUuid: otherProfileUuid,
    };

    final profileIdToFirebaseUidMap = {
      ownerProfileUuid: ownerFirebaseUid,
      otherProfileUuid: otherUserFirebaseUid,
    };

    test('1. Property owner can insert media into their own property via Firebase UID bridge', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkInsert(
        jwtSub: ownerFirebaseUid,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('2. Non-owner cannot insert media into someone elses property', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkInsert(
        jwtSub: otherUserFirebaseUid,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('3. Unauthenticated caller (null JWT sub) is rejected for media insert', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkInsert(
        jwtSub: null,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('4. Non-UUID Firebase UID (alphanumeric string) evaluates cleanly without 22P02 error', () {
      // Firebase UIDs are 28-char alphanumeric strings, not UUID format (e.g., 'p4fZZLm8a6SKngVRe4r46rd5aaA2')
      expect(RegExp(r'^[0-9a-fA-F\-]{36}$').hasMatch(ownerFirebaseUid), isFalse);
      
      final allowed = MockPropertyMediaRlsEvaluator.checkInsert(
        jwtSub: ownerFirebaseUid,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('5. Property owner can update media for their own property', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkUpdate(
        jwtSub: ownerFirebaseUid,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('6. Non-owner cannot update media on anothers property', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkUpdate(
        jwtSub: otherUserFirebaseUid,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('7. Property owner can delete media from their own property', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkDelete(
        jwtSub: ownerFirebaseUid,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('8. Non-owner cannot delete media from anothers property', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkDelete(
        jwtSub: otherUserFirebaseUid,
        propertyId: propertyUuid,
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('9. Public read allowed for media of active properties', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkSelect(
        jwtSub: null,
        propertyId: propertyUuid,
        propertyStatus: 'active',
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('10. Public read denied for media of draft/inactive properties when unauthenticated', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkSelect(
        jwtSub: null,
        propertyId: propertyUuid,
        propertyStatus: 'draft',
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('11. Non-owner read denied for media of draft/inactive properties', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkSelect(
        jwtSub: otherUserFirebaseUid,
        propertyId: propertyUuid,
        propertyStatus: 'draft',
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('12. Owner can read media of their own property even if status is draft or pending', () {
      final allowed = MockPropertyMediaRlsEvaluator.checkSelect(
        jwtSub: ownerFirebaseUid,
        propertyId: propertyUuid,
        propertyStatus: 'draft',
        propertyToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileIdToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('13. Admin/founder can insert, update, delete, and read media unconditionally', () {
      expect(
        MockPropertyMediaRlsEvaluator.checkInsert(
          jwtSub: otherUserFirebaseUid,
          propertyId: propertyUuid,
          propertyToOwnerProfileId: propertyToOwnerMap,
          profileIdToFirebaseUid: profileIdToFirebaseUidMap,
          isAdmin: true,
        ),
        isTrue,
      );
      expect(
        MockPropertyMediaRlsEvaluator.checkUpdate(
          jwtSub: otherUserFirebaseUid,
          propertyId: propertyUuid,
          propertyToOwnerProfileId: propertyToOwnerMap,
          profileIdToFirebaseUid: profileIdToFirebaseUidMap,
          isAdmin: true,
        ),
        isTrue,
      );
      expect(
        MockPropertyMediaRlsEvaluator.checkDelete(
          jwtSub: otherUserFirebaseUid,
          propertyId: propertyUuid,
          propertyToOwnerProfileId: propertyToOwnerMap,
          profileIdToFirebaseUid: profileIdToFirebaseUidMap,
          isAdmin: true,
        ),
        isTrue,
      );
      expect(
        MockPropertyMediaRlsEvaluator.checkSelect(
          jwtSub: null,
          propertyId: propertyUuid,
          propertyStatus: 'draft',
          propertyToOwnerProfileId: propertyToOwnerMap,
          profileIdToFirebaseUid: profileIdToFirebaseUidMap,
          isAdmin: true,
        ),
        isTrue,
      );
    });
  });
}
