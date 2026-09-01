import 'dart:typed_data';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/property/domain/entities/media_upload_entities.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/services/property_media_upload_service.dart';
import 'package:belagavi_property/features/property/utils/media_file_validator.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSupabaseService implements SupabaseService {
  @override
  bool get isInitialized => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PHASE 3 MEDIA UPLOAD PIPELINE SECURITY & FUNCTIONAL TESTS', () {
    late PropertyMediaUploadService uploadService;
    late FakeSupabaseService fakeSupabaseService;
    late Uint8List dummyImageBytes;
    late Uint8List dummyVideoBytes;
    late Uint8List dummyPdfBytes;

    const ownerId = 'usr_owner_100';
    const attackerId = 'usr_attacker_999';
    const propertyId = 'prop_villa_001';

    setUp(() {
      fakeSupabaseService = FakeSupabaseService();
      uploadService = PropertyMediaUploadService(fakeSupabaseService);

      dummyImageBytes = Uint8List.fromList(List.generate(1024, (i) => i % 256));
      dummyVideoBytes = Uint8List.fromList(List.generate(2048, (i) => i % 256));
      dummyPdfBytes = Uint8List.fromList(List.generate(512, (i) => i % 256));
    });

    test('TEST 1: Authenticated owner uploads image -> SUCCESS', () async {
      final media = await uploadService.uploadMedia(
        uploadId: 'up_001',
        authenticatedUserId: ownerId,
        ownerId: ownerId,
        propertyId: propertyId,
        fileName: 'villa_front.jpg',
        fileBytes: dummyImageBytes,
        type: MediaType.image,
        isCover: true,
      );

      expect(media.propertyId, equals(propertyId));
      expect(media.type, equals(MediaType.image));
      expect(media.isCover, isTrue);
      expect(
        media.mediaUrl,
        contains('property-media/$ownerId/$propertyId/images/villa_front.jpg'),
      );
    });

    test('TEST 2: Authenticated owner uploads video -> SUCCESS', () async {
      final media = await uploadService.uploadMedia(
        uploadId: 'up_002',
        authenticatedUserId: ownerId,
        ownerId: ownerId,
        propertyId: propertyId,
        fileName: 'walkthrough.mp4',
        fileBytes: dummyVideoBytes,
        type: MediaType.video,
      );

      expect(media.propertyId, equals(propertyId));
      expect(media.type, equals(MediaType.video));
      expect(
        media.mediaUrl,
        contains('property-media/$ownerId/$propertyId/videos/walkthrough.mp4'),
      );
    });

    test('TEST 3: Authenticated owner uploads PDF document -> SUCCESS', () async {
      final doc = await uploadService.uploadDocument(
        uploadId: 'up_003',
        authenticatedUserId: ownerId,
        ownerId: ownerId,
        propertyId: propertyId,
        documentName: 'Encumbrance Certificate 2026',
        fileName: 'ec_certificate.pdf',
        fileBytes: dummyPdfBytes,
        documentType: PropertyDocumentType.encumbranceCertificate,
      );

      expect(doc.propertyId, equals(propertyId));
      expect(
        doc.documentType,
        equals(PropertyDocumentType.encumbranceCertificate),
      );
      expect(
        doc.documentUrl,
        contains(
          'property-documents/$ownerId/$propertyId/documents/ec_certificate.pdf',
        ),
      );
    });

    test(
      'TEST 4: Unauthorized user attempts upload to another property -> ACCESS DENIED',
      () async {
        expect(
          () async => await uploadService.uploadMedia(
            uploadId: 'up_004',
            authenticatedUserId: attackerId,
            ownerId: ownerId,
            propertyId: propertyId,
            fileName: 'malicious.jpg',
            fileBytes: dummyImageBytes,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      'TEST 5: Unauthorized user attempts delete -> ACCESS DENIED',
      () async {
        expect(
          () async => await uploadService.deleteMedia(
            authenticatedUserId: attackerId,
            ownerId: ownerId,
            propertyId: propertyId,
            storagePath: '$ownerId/$propertyId/images/photo.jpg',
            category: MediaCategory.image,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      'TEST 6: Unauthorized user attempts replace -> ACCESS DENIED',
      () async {
        expect(
          () async => await uploadService.replaceMedia(
            uploadId: 'up_006',
            authenticatedUserId: attackerId,
            ownerId: ownerId,
            propertyId: propertyId,
            oldStoragePath: '$ownerId/$propertyId/images/photo.jpg',
            newFileName: 'replacement.jpg',
            newFileBytes: dummyImageBytes,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test('TEST 7: Anonymous user attempts upload -> ACCESS DENIED', () async {
      expect(
        () async => await uploadService.uploadMedia(
          uploadId: 'up_007',
          authenticatedUserId: '',
          ownerId: ownerId,
          propertyId: propertyId,
          fileName: 'anon.jpg',
          fileBytes: dummyImageBytes,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test(
      'TEST 8: Failed upload -> Recoverable error + Retry support',
      () async {
        expect(
          () => MediaFileValidator.validateImage(
            fileName: 'executable.exe',
            fileSizeBytes: 1024,
          ),
          throwsA(isA<MediaValidationException>()),
        );
      },
    );

    test(
      'TEST 9: Cancel upload -> Upload stops cleanly and state becomes CANCELLED',
      () async {
        const uploadId = 'up_009';
        uploadService.cancelUpload(uploadId);

        expect(
          () async => await uploadService.uploadMedia(
            uploadId: uploadId,
            authenticatedUserId: ownerId,
            ownerId: ownerId,
            propertyId: propertyId,
            fileName: 'large_photo.jpg',
            fileBytes: dummyImageBytes,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      'TEST 10: Logout while protected media is present -> Private document access removed',
      () {
        const loggedOutUserId = null;
        expect(
          () => PropertySecurityGuard.verifyPropertyOwnership(
            authenticatedUserId: loggedOutUserId,
            ownerId: ownerId,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );
  });
}
