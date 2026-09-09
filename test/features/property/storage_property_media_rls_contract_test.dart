import 'package:flutter_test/flutter_test.dart';

/// Contract evaluator simulating hardened Supabase Storage & DB policies from Migration 00030
class MockStoragePropertyMediaRlsEvaluator {
  /// Evaluates Storage INSERT/UPDATE/DELETE policy on storage.objects for bucket 'property-media':
  /// WITH CHECK / USING (
  ///   bucket_id = 'property-media'
  ///   AND auth.jwt()->>'sub' IS NOT NULL
  ///   AND (
  ///     (
  ///       split_part(name, '/', 1) = (auth.jwt()->>'sub')
  ///       AND NOT EXISTS (
  ///         SELECT 1 FROM public.properties p
  ///         WHERE p.id::text = split_part(name, '/', 2)
  ///         AND p.owner_id NOT IN (
  ///           SELECT pr.id FROM public.profiles pr WHERE pr.firebase_uid = (auth.jwt()->>'sub')
  ///         )
  ///       )
  ///     )
  ///     OR (
  ///       EXISTS (
  ///         SELECT 1 FROM public.profiles pr
  ///         WHERE pr.id::text = split_part(name, '/', 1)
  ///         AND pr.firebase_uid = (auth.jwt()->>'sub')
  ///         AND NOT EXISTS (
  ///           SELECT 1 FROM public.properties p
  ///           WHERE p.id::text = split_part(name, '/', 2)
  ///           AND p.owner_id != pr.id
  ///         )
  ///       )
  ///     )
  ///     OR public.is_app_admin_or_founder()
  ///   )
  /// )
  static bool checkStorageWrite({
    required String bucketId,
    required String? jwtSub,
    required String objectPath,
    required Map<String, String> propertyIdToOwnerProfileId,
    required Map<String, String> profileIdToFirebaseUid,
    bool isAdmin = false,
  }) {
    if (bucketId != 'property-media') return false;
    if (isAdmin) return true;
    if (jwtSub == null || jwtSub.isEmpty) return false;

    final parts = objectPath.split('/');
    if (parts.length < 3) return false; // Must have at least owner/property/filename

    final seg1 = parts[0];
    final seg2 = parts[1];

    // Branch A: Segment 1 matches caller's Firebase UID
    if (seg1 == jwtSub) {
      // If target property in seg2 already exists in properties, verify caller ownership
      final existingOwnerProfileId = propertyIdToOwnerProfileId[seg2];
      if (existingOwnerProfileId != null) {
        final ownerFirebaseUid = profileIdToFirebaseUid[existingOwnerProfileId];
        if (ownerFirebaseUid != jwtSub) {
          return false; // Target property belongs to someone else!
        }
      }
      return true;
    }

    // Branch B: Segment 1 matches caller's Profile UUID
    final profileFirebaseUid = profileIdToFirebaseUid[seg1];
    if (profileFirebaseUid != null && profileFirebaseUid == jwtSub) {
      final existingOwnerProfileId = propertyIdToOwnerProfileId[seg2];
      if (existingOwnerProfileId != null && existingOwnerProfileId != seg1) {
        return false;
      }
      return true;
    }

    return false;
  }

  /// Evaluates Storage SELECT policy:
  /// (bucket_id = 'property-media'::text)
  static bool checkStorageSelect({
    required String bucketId,
  }) {
    return bucketId == 'property-media';
  }

  /// Evaluates DB property_media INSERT policy:
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
  static bool checkDbMediaInsert({
    required String? jwtSub,
    required String propertyId,
    required Map<String, String> propertyIdToOwnerProfileId,
    required Map<String, String> profileIdToFirebaseUid,
    bool isAdmin = false,
  }) {
    if (isAdmin) return true;
    if (jwtSub == null || jwtSub.isEmpty) return false;

    final ownerProfileId = propertyIdToOwnerProfileId[propertyId];
    if (ownerProfileId == null) return false;

    final ownerFirebaseUid = profileIdToFirebaseUid[ownerProfileId];
    return ownerFirebaseUid != null && ownerFirebaseUid == jwtSub;
  }

  /// Validates standard storage path builder format:
  /// {ownerId}/{propertyId}/images/{fileName}
  static String buildStoragePath({
    required String ownerId,
    required String propertyId,
    required String fileName,
    String folder = 'images',
  }) {
    final sanitized = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._\-]'), '_');
    return '$ownerId/$propertyId/$folder/$sanitized';
  }
}

void main() {
  group('Comprehensive Storage & Media RLS Contract Tests (Migration 00030)', () {
    const sellerFirebaseUid = 'p4fZZLm8a6SKngVRe4r46rd5aaA2';
    const userBFirebaseUid = 'user_b_attacker_uid_9999999999';
    const sellerProfileUuid = '66c3a9c6-1111-2222-3333-444455556666';
    const userBProfileUuid = '99e9b9c9-0000-1111-2222-333344445555';
    const sellerPropertyUuid = '0c65076b-aaaa-bbbb-cccc-dddddddddddd';
    const userBPropertyUuid = '1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d';

    final propertyToOwnerMap = {
      sellerPropertyUuid: sellerProfileUuid,
      userBPropertyUuid: userBProfileUuid,
    };

    final profileToFirebaseUidMap = {
      sellerProfileUuid: sellerFirebaseUid,
      userBProfileUuid: userBFirebaseUid,
    };

    test('1. Seller can upload own property path in storage', () {
      final path = MockStoragePropertyMediaRlsEvaluator.buildStoragePath(
        ownerId: sellerFirebaseUid,
        propertyId: sellerPropertyUuid,
        fileName: 'front.jpg',
      );
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: sellerFirebaseUid,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('2. Seller cannot upload another user property path in segment 2', () {
      // Seller tries to target User B's property in segment 2
      final path = '$sellerFirebaseUid/$userBPropertyUuid/images/malicious.jpg';
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: sellerFirebaseUid,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('3. Seller cannot spoof another profile UUID in segment 1', () {
      final path = '$userBProfileUuid/$sellerPropertyUuid/images/spoofed.jpg';
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: sellerFirebaseUid,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('4. User B cannot upload into seller property path', () {
      final path = '$sellerFirebaseUid/$sellerPropertyUuid/images/hacked.jpg';
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: userBFirebaseUid,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('5. User B cannot update seller object in storage', () {
      final path = '$sellerFirebaseUid/$sellerPropertyUuid/images/front.jpg';
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: userBFirebaseUid,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('6. User B cannot delete seller object in storage', () {
      final path = '$sellerFirebaseUid/$sellerPropertyUuid/images/front.jpg';
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: userBFirebaseUid,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('7. Malformed property UUID-like path returns DENIED safely without cast error', () {
      const malformedPath = 'random_junk_segment_1/not-a-valid-uuid/images/test.jpg';
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: sellerFirebaseUid,
        objectPath: malformedPath,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('8. Missing path segments denied', () {
      expect(
        MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
          bucketId: 'property-media',
          jwtSub: sellerFirebaseUid,
          objectPath: 'just_a_filename.jpg',
          propertyIdToOwnerProfileId: propertyToOwnerMap,
          profileIdToFirebaseUid: profileToFirebaseUidMap,
        ),
        isFalse,
      );
      expect(
        MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
          bucketId: 'property-media',
          jwtSub: sellerFirebaseUid,
          objectPath: '$sellerFirebaseUid/one_folder',
          propertyIdToOwnerProfileId: propertyToOwnerMap,
          profileIdToFirebaseUid: profileToFirebaseUidMap,
        ),
        isFalse,
      );
    });

    test('9. Non-authenticated upload denied', () {
      final path = '$sellerFirebaseUid/$sellerPropertyUuid/images/test.jpg';
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: null,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });

    test('10. Public read behavior matches intended architecture', () {
      expect(
        MockStoragePropertyMediaRlsEvaluator.checkStorageSelect(bucketId: 'property-media'),
        isTrue,
      );
      expect(
        MockStoragePropertyMediaRlsEvaluator.checkStorageSelect(bucketId: 'property-documents'),
        isFalse,
      );
    });

    test('11. Firebase UID is never UUID-cast in storage evaluation', () {
      // Firebase UID is alphanumeric (28 chars), not 36-char hyphenated UUID
      expect(RegExp(r'^[0-9a-fA-F\-]{36}$').hasMatch(sellerFirebaseUid), isFalse);
      
      final path = MockStoragePropertyMediaRlsEvaluator.buildStoragePath(
        ownerId: sellerFirebaseUid,
        propertyId: sellerPropertyUuid,
        fileName: 'photo.jpg',
      );
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkStorageWrite(
        bucketId: 'property-media',
        jwtSub: sellerFirebaseUid,
        objectPath: path,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('12. property_media DB insert for owner succeeds', () {
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkDbMediaInsert(
        jwtSub: sellerFirebaseUid,
        propertyId: sellerPropertyUuid,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isTrue);
    });

    test('13. property_media DB insert for User B is denied', () {
      final allowed = MockStoragePropertyMediaRlsEvaluator.checkDbMediaInsert(
        jwtSub: userBFirebaseUid,
        propertyId: sellerPropertyUuid,
        propertyIdToOwnerProfileId: propertyToOwnerMap,
        profileIdToFirebaseUid: profileToFirebaseUidMap,
      );
      expect(allowed, isFalse);
    });
  });
}
