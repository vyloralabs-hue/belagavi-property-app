import '../domain/entities/media_upload_entities.dart';

class MediaValidationException implements Exception {
  final String message;
  const MediaValidationException(this.message);

  @override
  String toString() => 'MediaValidationException: $message';
}

class MediaFileValidator {
  MediaFileValidator._();

  static const int maxImageSizeBytes = 15 * 1024 * 1024; // 15 MB
  static const int maxVideoSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const int maxDocumentSizeBytes = 25 * 1024 * 1024; // 25 MB

  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoExtensions = ['mp4', 'mov'];
  static const List<String> allowedDocumentExtensions = ['pdf'];

  /// Validates an image file before upload
  static void validateImage({
    required String fileName,
    required int fileSizeBytes,
  }) {
    final ext = _getExtension(fileName);
    if (!allowedImageExtensions.contains(ext)) {
      throw MediaValidationException(
        'Invalid image format (.$ext). Allowed formats: ${allowedImageExtensions.join(', ')}.',
      );
    }
    if (fileSizeBytes > maxImageSizeBytes) {
      throw const MediaValidationException(
        'Image file size exceeds maximum limit of 15MB.',
      );
    }
  }

  /// Validates a video file before upload
  static void validateVideo({
    required String fileName,
    required int fileSizeBytes,
  }) {
    final ext = _getExtension(fileName);
    if (!allowedVideoExtensions.contains(ext)) {
      throw MediaValidationException(
        'Invalid video format (.$ext). Allowed formats: ${allowedVideoExtensions.join(', ')}.',
      );
    }
    if (fileSizeBytes > maxVideoSizeBytes) {
      throw const MediaValidationException(
        'Video file size exceeds maximum limit of 100MB.',
      );
    }
  }

  /// Validates a document file (PDF) before upload
  static void validateDocument({
    required String fileName,
    required int fileSizeBytes,
  }) {
    final ext = _getExtension(fileName);
    if (!allowedDocumentExtensions.contains(ext)) {
      throw MediaValidationException(
        'Invalid document format (.$ext). Allowed formats: ${allowedDocumentExtensions.join(', ')}.',
      );
    }
    if (fileSizeBytes > maxDocumentSizeBytes) {
      throw const MediaValidationException(
        'Document file size exceeds maximum limit of 25MB.',
      );
    }
  }

  /// Helper to determine media category from file extension
  static MediaCategory getCategoryFromFileName(String fileName) {
    final ext = _getExtension(fileName);
    if (allowedImageExtensions.contains(ext)) return MediaCategory.image;
    if (allowedVideoExtensions.contains(ext)) return MediaCategory.video;
    if (allowedDocumentExtensions.contains(ext)) return MediaCategory.document;
    throw MediaValidationException('Unsupported file extension: .$ext');
  }

  static String _getExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase().trim();
  }
}
