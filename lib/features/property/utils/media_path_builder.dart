import '../domain/entities/media_upload_entities.dart';

class MediaPathBuilder {
  MediaPathBuilder._();

  static const String mediaBucket = 'property-media';
  static const String documentsBucket = 'property-documents';

  /// Generates predictable storage path based on ownerId and propertyId
  static String buildStoragePath({
    required String ownerId,
    required String propertyId,
    required MediaCategory category,
    required String fileName,
  }) {
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final folder = switch (category) {
      MediaCategory.image => 'images',
      MediaCategory.video => 'videos',
      MediaCategory.document => 'documents',
    };
    return '$ownerId/$propertyId/$folder/$sanitizedFileName';
  }

  /// Resolves the storage bucket for a given media category
  static String resolveBucket(MediaCategory category) {
    return category == MediaCategory.document ? documentsBucket : mediaBucket;
  }
}
