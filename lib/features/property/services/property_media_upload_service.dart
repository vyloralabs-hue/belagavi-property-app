import 'dart:async';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/errors/security_exceptions.dart';
import '../domain/entities/media_upload_entities.dart';
import '../domain/entities/property_entities.dart';
import '../utils/media_file_validator.dart';
import '../utils/media_path_builder.dart';
import '../utils/property_security_guard.dart';

@lazySingleton
class PropertyMediaUploadService {
  final SupabaseService _supabaseService;
  final Map<String, StreamController<UploadProgressEntity>> _progressControllers = {};
  final Map<String, bool> _cancellationFlags = {};

  PropertyMediaUploadService(this._supabaseService);

  /// Get progress stream for an ongoing upload session
  Stream<UploadProgressEntity>? getProgressStream(String uploadId) {
    return _progressControllers[uploadId]?.stream;
  }

  /// Cancels an ongoing upload task
  void cancelUpload(String uploadId) {
    _cancellationFlags[uploadId] = true;
    final controller = _progressControllers[uploadId];
    if (controller != null && !controller.isClosed) {
      controller.add(
        const UploadProgressEntity(
          state: UploadState.cancelled,
          errorMessage: 'Upload cancelled by user.',
        ),
      );
      controller.close();
    }
  }

  /// Uploads property image or video file
  Future<PropertyMediaEntity> uploadMedia({
    required String uploadId,
    required String authenticatedUserId,
    required String ownerId,
    required String propertyId,
    required String fileName,
    required Uint8List fileBytes,
    MediaType type = MediaType.image,
    int displayOrder = 0,
    bool isCover = false,
    String? caption,
  }) async {
    // 1. Verify Ownership & Authentication Security Guard
    PropertySecurityGuard.verifyPropertyOwnership(
      authenticatedUserId: authenticatedUserId,
      ownerId: ownerId,
      actionName: 'upload property media',
    );

    // 2. Validate File Type and Size
    final category = type == MediaType.video ? MediaCategory.video : MediaCategory.image;
    if (category == MediaCategory.image) {
      MediaFileValidator.validateImage(fileName: fileName, fileSizeBytes: fileBytes.length);
    } else {
      MediaFileValidator.validateVideo(fileName: fileName, fileSizeBytes: fileBytes.length);
    }

    final controller = StreamController<UploadProgressEntity>.broadcast();
    _progressControllers[uploadId] = controller;
    _cancellationFlags[uploadId] = _cancellationFlags[uploadId] ?? false;

    try {
      if (_cancellationFlags[uploadId] == true) {
        throw const AccessDeniedException('Upload cancelled.');
      }

      controller.add(
        UploadProgressEntity(
          progressPercent: 10.0,
          bytesUploaded: (fileBytes.length * 0.1).round(),
          totalBytes: fileBytes.length,
          state: UploadState.uploading,
        ),
      );

      final path = MediaPathBuilder.buildStoragePath(
        ownerId: ownerId,
        propertyId: propertyId,
        category: category,
        fileName: fileName,
      );
      final bucket = MediaPathBuilder.resolveBucket(category);

      // Check cancellation flag
      if (_cancellationFlags[uploadId] == true) {
        throw const AccessDeniedException('Upload cancelled.');
      }

      String publicUrl = '';
      if (_supabaseService.isInitialized) {
        final storage = _supabaseService.storage(bucket);
        await storage.uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );
        publicUrl = storage.getPublicUrl(path);
      } else {
        publicUrl = 'https://supabase.mock.storage/$bucket/$path';
      }

      controller.add(
        UploadProgressEntity(
          progressPercent: 100.0,
          bytesUploaded: fileBytes.length,
          totalBytes: fileBytes.length,
          state: UploadState.success,
          uploadedPath: path,
          publicUrl: publicUrl,
        ),
      );

      final mediaId = 'med_${DateTime.now().millisecondsSinceEpoch}';
      return PropertyMediaEntity(
        id: mediaId,
        propertyId: propertyId,
        mediaUrl: publicUrl,
        type: type,
        displayOrder: displayOrder,
        isCover: isCover,
        caption: caption,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      final isCancelled = _cancellationFlags[uploadId] == true;
      controller.add(
        UploadProgressEntity(
          state: isCancelled ? UploadState.cancelled : UploadState.failed,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    } finally {
      await controller.close();
      _progressControllers.remove(uploadId);
      _cancellationFlags.remove(uploadId);
    }
  }

  /// Uploads a private property legal document (PDF)
  Future<PropertyDocumentEntity> uploadDocument({
    required String uploadId,
    required String authenticatedUserId,
    required String ownerId,
    required String propertyId,
    required String documentName,
    required String fileName,
    required Uint8List fileBytes,
    PropertyDocumentType documentType = PropertyDocumentType.other,
  }) async {
    // 1. Verify Ownership Security Guard
    PropertySecurityGuard.verifyPropertyOwnership(
      authenticatedUserId: authenticatedUserId,
      ownerId: ownerId,
      actionName: 'upload property document',
    );

    // 2. Validate PDF Document Format and Size Limit
    MediaFileValidator.validateDocument(fileName: fileName, fileSizeBytes: fileBytes.length);

    final path = MediaPathBuilder.buildStoragePath(
      ownerId: ownerId,
      propertyId: propertyId,
      category: MediaCategory.document,
      fileName: fileName,
    );
    final bucket = MediaPathBuilder.resolveBucket(MediaCategory.document);

    String documentUrl = '';
    if (_supabaseService.isInitialized) {
      final storage = _supabaseService.storage(bucket);
      await storage.uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      documentUrl = storage.getPublicUrl(path);
    } else {
      documentUrl = 'https://supabase.mock.storage/$bucket/$path';
    }

    final docId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    return PropertyDocumentEntity(
      id: docId,
      propertyId: propertyId,
      documentType: documentType,
      documentName: documentName,
      documentUrl: documentUrl,
      uploadedBy: authenticatedUserId,
      verificationStatus: VerificationStatus.pending,
      uploadedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Deletes media file from storage
  Future<void> deleteMedia({
    required String authenticatedUserId,
    required String ownerId,
    required String propertyId,
    required String storagePath,
    required MediaCategory category,
  }) async {
    PropertySecurityGuard.verifyPropertyOwnership(
      authenticatedUserId: authenticatedUserId,
      ownerId: ownerId,
      actionName: 'delete property media',
    );

    if (!_supabaseService.isInitialized) return;
    final bucket = MediaPathBuilder.resolveBucket(category);
    await _supabaseService.storage(bucket).remove([storagePath]);
  }

  /// Replaces existing media file
  Future<PropertyMediaEntity> replaceMedia({
    required String uploadId,
    required String authenticatedUserId,
    required String ownerId,
    required String propertyId,
    required String oldStoragePath,
    required String newFileName,
    required Uint8List newFileBytes,
    MediaType type = MediaType.image,
  }) async {
    PropertySecurityGuard.verifyPropertyOwnership(
      authenticatedUserId: authenticatedUserId,
      ownerId: ownerId,
      actionName: 'replace property media',
    );

    final category = type == MediaType.video ? MediaCategory.video : MediaCategory.image;
    await deleteMedia(
      authenticatedUserId: authenticatedUserId,
      ownerId: ownerId,
      propertyId: propertyId,
      storagePath: oldStoragePath,
      category: category,
    );

    return await uploadMedia(
      uploadId: uploadId,
      authenticatedUserId: authenticatedUserId,
      ownerId: ownerId,
      propertyId: propertyId,
      fileName: newFileName,
      fileBytes: newFileBytes,
      type: type,
    );
  }

  /// Reorders media list items and sets primary cover image
  List<PropertyMediaEntity> setPrimaryCoverImage({
    required String authenticatedUserId,
    required String ownerId,
    required List<PropertyMediaEntity> mediaList,
    required String primaryMediaId,
  }) {
    PropertySecurityGuard.verifyPropertyOwnership(
      authenticatedUserId: authenticatedUserId,
      ownerId: ownerId,
      actionName: 'set primary cover image',
    );

    return mediaList.map<PropertyMediaEntity>((media) {
      if (media.id == primaryMediaId) {
        return PropertyMediaEntity(
          id: media.id,
          propertyId: media.propertyId,
          mediaUrl: media.mediaUrl,
          type: media.type,
          displayOrder: 0,
          isCover: true,
          caption: media.caption,
          uploadedAt: media.uploadedAt,
        );
      } else {
        return PropertyMediaEntity(
          id: media.id,
          propertyId: media.propertyId,
          mediaUrl: media.mediaUrl,
          type: media.type,
          displayOrder: media.displayOrder + 1,
          isCover: false,
          caption: media.caption,
          uploadedAt: media.uploadedAt,
        );
      }
    }).toList();
  }
}
