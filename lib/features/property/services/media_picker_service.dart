import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_logger.dart';
import '../domain/entities/property_entities.dart';

/// Representation of a picked device media file
class SelectedMediaFile {
  final String fileName;
  final Uint8List bytes;
  final String path;
  final MediaType type;

  const SelectedMediaFile({
    required this.fileName,
    required this.bytes,
    required this.path,
    required this.type,
  });
}

/// Service for picking real device photos & videos via ImagePicker
class MediaPickerService {
  final ImagePicker _picker;

  MediaPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Opens device gallery for multi-photo selection
  Future<List<SelectedMediaFile>> pickPhotosFromGallery({
    int maxImages = 15,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: maxImages,
        imageQuality: imageQuality,
      );

      final List<SelectedMediaFile> results = [];
      for (final file in pickedFiles) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          results.add(
            SelectedMediaFile(
              fileName: file.name.isNotEmpty
                  ? file.name
                  : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
              bytes: bytes,
              path: file.path,
              type: MediaType.image,
            ),
          );
        }
      }
      return results;
    } catch (e, stack) {
      AppLogger.w('Failed to pick photos from gallery: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stack);
      }
      return [];
    }
  }

  /// Opens device camera to take a real photo
  Future<SelectedMediaFile?> takePhotoWithCamera({
    int imageQuality = 85,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
      );

      if (photo == null) return null;
      final bytes = await photo.readAsBytes();
      if (bytes.isEmpty) return null;

      return SelectedMediaFile(
        fileName: photo.name.isNotEmpty
            ? photo.name
            : 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
        bytes: bytes,
        path: photo.path,
        type: MediaType.image,
      );
    } catch (e, stack) {
      AppLogger.w('Failed to take photo with camera: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stack);
      }
      return null;
    }
  }

  /// Opens device gallery to pick a real video
  Future<SelectedMediaFile?> pickVideoFromGallery({
    Duration maxDuration = const Duration(minutes: 3),
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (video == null) return null;
      final bytes = await video.readAsBytes();
      if (bytes.isEmpty) return null;

      return SelectedMediaFile(
        fileName: video.name.isNotEmpty
            ? video.name
            : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
        bytes: bytes,
        path: video.path,
        type: MediaType.video,
      );
    } catch (e, stack) {
      AppLogger.w('Failed to pick video from gallery: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stack);
      }
      return null;
    }
  }

  /// Opens device camera to record a real video
  Future<SelectedMediaFile?> recordVideoWithCamera({
    Duration maxDuration = const Duration(minutes: 3),
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
      );

      if (video == null) return null;
      final bytes = await video.readAsBytes();
      if (bytes.isEmpty) return null;

      return SelectedMediaFile(
        fileName: video.name.isNotEmpty
            ? video.name
            : 'recorded_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
        bytes: bytes,
        path: video.path,
        type: MediaType.video,
      );
    } catch (e, stack) {
      AppLogger.w('Failed to record video with camera: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stack);
      }
      return null;
    }
  }
}
