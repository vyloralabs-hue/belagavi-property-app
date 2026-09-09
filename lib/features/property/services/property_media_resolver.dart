import '../domain/entities/property_entities.dart';

/// Resilient Canonical Property Cover Photo and Media Resolver
class PropertyMediaResolver {
  PropertyMediaResolver._();

  /// Professional property placeholder image used when no photos are uploaded
  static const String defaultPlaceholder =
      'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&auto=format&fit=crop&q=80';

  /// Resolves the primary cover image URL according to strict marketplace priority:
  /// 1. Explicit seller cover photo (isCover == true) with valid non-empty URL
  /// 2. Lowest sort order (displayOrder) with valid non-empty URL
  /// 3. First valid image in mediaList
  /// 4. Professional placeholder
  ///
  /// Never crashes on null or empty media.
  static String getCoverUrl(PropertyEntity? property) {
    if (property == null || property.mediaList.isEmpty) {
      return defaultPlaceholder;
    }

    // 1. Explicit seller cover photo
    final explicitCover = property.mediaList
        .where((m) => m.isCover && m.mediaUrl.trim().isNotEmpty)
        .firstOrNull;
    if (explicitCover != null) {
      return explicitCover.mediaUrl.trim();
    }

    // 2. Lowest sort order with non-empty URL
    final sorted = List<PropertyMediaEntity>.from(property.mediaList)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    for (final m in sorted) {
      if (m.mediaUrl.trim().isNotEmpty) {
        return m.mediaUrl.trim();
      }
    }

    // 3. Fallback placeholder
    return defaultPlaceholder;
  }

  /// Returns deterministically sorted media list with cover item first
  static List<PropertyMediaEntity> getOrderedMedia(PropertyEntity? property) {
    if (property == null || property.mediaList.isEmpty) {
      return const [];
    }

    final list = List<PropertyMediaEntity>.from(property.mediaList);
    list.sort((a, b) {
      if (a.isCover && !b.isCover) return -1;
      if (!a.isCover && b.isCover) return 1;
      return a.displayOrder.compareTo(b.displayOrder);
    });
    return list;
  }
}
