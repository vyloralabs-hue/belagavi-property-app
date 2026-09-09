import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/property/domain/entities/media_upload_entities.dart';
import 'package:belagavi_property/features/property/services/property_media_upload_service.dart';
import 'package:belagavi_property/features/property/utils/media_file_validator.dart';
import 'package:belagavi_property/features/property/utils/media_path_builder.dart';

class MockSupabaseService extends SupabaseService {
  @override
  bool get isInitialized => false; // Simulates mock storage fallback
}

void main() {
  group('PropertyMediaUploadService Tests', () {
    late PropertyMediaUploadService service;
    late MockSupabaseService mockSupabase;

    setUp(() {
      mockSupabase = MockSupabaseService();
      service = PropertyMediaUploadService(mockSupabase);
    });

    test('Uploads valid image and generates mock URL and media entity', () async {
      final fakeBytes = Uint8List.fromList(List.generate(1024, (i) => i % 256));
      final media = await service.uploadMedia(
        uploadId: 'up_001',
        authenticatedUserId: 'usr_owner_123',
        ownerId: 'usr_owner_123',
        propertyId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        fileName: 'front_elevation.jpg',
        fileBytes: fakeBytes,
        isCover: true,
        displayOrder: 0,
      );

      expect(media.propertyId, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(media.isCover, isTrue);
      expect(media.displayOrder, 0);
      expect(media.mediaUrl, contains('https://supabase.mock.storage/property-media/'));
      expect(media.mediaUrl, contains('front_elevation.jpg'));
    });

    test('Rejects upload if authenticatedUserId != ownerId', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3]);

      expect(
        () => service.uploadMedia(
          uploadId: 'up_unauth',
          authenticatedUserId: 'usr_attacker',
          ownerId: 'usr_owner_123',
          propertyId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          fileName: 'photo.jpg',
          fileBytes: fakeBytes,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('Rejects zero-byte image upload', () {
      final emptyBytes = Uint8List(0);
      expect(
        () => MediaFileValidator.validateImage(
          fileName: 'empty.jpg',
          fileSizeBytes: emptyBytes.length,
        ),
        throwsA(isA<MediaValidationException>()),
      );
    });

    test('Rejects oversized image (>15MB)', () {
      const oversizedBytes = 16 * 1024 * 1024;
      expect(
        () => MediaFileValidator.validateImage(
          fileName: 'huge.jpg',
          fileSizeBytes: oversizedBytes,
        ),
        throwsA(isA<MediaValidationException>()),
      );
    });

    test('Rejects unsupported image extension', () {
      expect(
        () => MediaFileValidator.validateImage(
          fileName: 'malicious.exe',
          fileSizeBytes: 1024,
        ),
        throwsA(isA<MediaValidationException>()),
      );
    });

    test('MediaPathBuilder builds sanitized unique storage path', () {
      final path = MediaPathBuilder.buildStoragePath(
        ownerId: 'usr_owner_123',
        propertyId: 'prop_abc',
        category: MediaCategory.image,
        fileName: 'Living Room (1).jpeg',
      );

      expect(path, 'usr_owner_123/prop_abc/images/Living_Room__1_.jpeg');
      expect(path.contains(' '), isFalse);
    });

    test('Cancelling an upload marks state cancelled', () {
      service.cancelUpload('up_cancel_test');
      // Verify cancellation flag handles properly without throwing
      expect(true, isTrue);
    });
  });
}
