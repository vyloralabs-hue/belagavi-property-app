import 'dart:typed_data';
import 'media_file_validator.dart';

/// Local Device-Side Image Optimization & Inspection Helper
/// Zero AI API calls, Zero external paid service dependency.
/// Uses standard Dart/Flutter binary inspection and local byte processing.
class LocalImageOptimizer {
  LocalImageOptimizer._();

  /// Target max file size for automatic upload optimization (e.g. 5 MB)
  static const int targetMaxBytes = 5 * 1024 * 1024;

  /// Inspects image bytes and verifies integrity & basic metadata
  static ImageMetadataInfo inspectImageBytes(String fileName, Uint8List bytes) {
    MediaFileValidator.validateImage(fileName: fileName, fileSizeBytes: bytes.length);

    final extension = fileName.split('.').last.toLowerCase();
    final isPng = extension == 'png' || (bytes.length > 8 && bytes[0] == 0x89 && bytes[1] == 0x50);
    final isJpeg = extension == 'jpg' || extension == 'jpeg' || (bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8);
    final isWebp = extension == 'webp';

    return ImageMetadataInfo(
      fileName: fileName,
      fileSizeBytes: bytes.length,
      extension: extension,
      isPng: isPng,
      isJpeg: isJpeg,
      isWebp: isWebp,
      isOptimalSize: bytes.length <= targetMaxBytes,
    );
  }

  /// Formats byte size into human readable string (e.g., "2.4 MB", "450 KB")
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Validates media count limit for property listings (e.g., max 20 photos per listing)
  static void validateMediaLimit(int currentCount, int incomingCount, {int maxAllowed = 20}) {
    if (currentCount + incomingCount > maxAllowed) {
      throw MediaValidationException(
        'Maximum $maxAllowed photos allowed per property listing. Currently have $currentCount photos.',
      );
    }
  }
}

class ImageMetadataInfo {
  final String fileName;
  final int fileSizeBytes;
  final String extension;
  final bool isPng;
  final bool isJpeg;
  final bool isWebp;
  final bool isOptimalSize;

  const ImageMetadataInfo({
    required this.fileName,
    required this.fileSizeBytes,
    required this.extension,
    required this.isPng,
    required this.isJpeg,
    required this.isWebp,
    required this.isOptimalSize,
  });

  String get formattedSize => LocalImageOptimizer.formatFileSize(fileSizeBytes);
}
