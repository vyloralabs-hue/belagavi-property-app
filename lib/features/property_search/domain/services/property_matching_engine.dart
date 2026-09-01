import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/domain/repositories/notification_repository.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../entities/saved_search_entity.dart';

class PropertyMatchingEngine {
  PropertyMatchingEngine._();

  /// Evaluates whether a PropertyEntity satisfies the criteria of a SavedSearchEntity.
  static bool matches(PropertyEntity property, SavedSearchEntity search) {
    // 1. Gating: Only active saved searches match
    if (!search.isActive) return false;

    // 2. Lifecycle Gating: Only publicly discoverable listings match
    final isPublic = property.status == ListingStatus.published ||
        property.status == ListingStatus.active ||
        property.status == ListingStatus.approved;
    if (!isPublic) return false;

    final q = search.query;

    // 3. Category match
    if (q.category != null && property.category != q.category) {
      return false;
    }

    // 4. Subtype / Property type match
    if (q.type != null && property.type != q.type) {
      return false;
    }

    // 5. Purpose match (FOR_SALE, FOR_RENT, etc.)
    if (q.purpose != null) {
      final propPurpose = property.features['purpose']?.toString().toUpperCase();
      if (propPurpose != null) {
        final queryPurposeName = q.purpose!.name.toUpperCase();
        if (!propPurpose.contains(queryPurposeName) &&
            !queryPurposeName.contains(propPurpose)) {
          return false;
        }
      }
    }

    // 6. City match (case-insensitive)
    if (q.city != null && q.city!.isNotEmpty) {
      if (property.city.trim().toLowerCase() != q.city!.trim().toLowerCase()) {
        return false;
      }
    }

    // 7. Locality match (case-insensitive contains)
    if (q.locality != null && q.locality!.isNotEmpty) {
      if (!property.locality.toLowerCase().contains(q.locality!.trim().toLowerCase())) {
        return false;
      }
    }

    // 8. Price range
    if (q.minPrice != null && property.price < q.minPrice!) {
      return false;
    }
    if (q.maxPrice != null && property.price > q.maxPrice!) {
      return false;
    }

    // 9. Area range
    final propArea = (property.specifications.carpetArea ??
            property.specifications.superBuiltUpArea ??
            property.specifications.plotArea ??
            0)
        .toDouble();
    if (q.minArea != null && propArea > 0 && propArea < q.minArea!) {
      return false;
    }
    if (q.maxArea != null && propArea > 0 && propArea > q.maxArea!) {
      return false;
    }

    // 10. Bedrooms
    final propBedrooms = property.specifications.bedrooms;
    if (q.minBedrooms != null && propBedrooms != null && propBedrooms < q.minBedrooms!) {
      return false;
    }
    if (q.maxBedrooms != null && propBedrooms != null && propBedrooms > q.maxBedrooms!) {
      return false;
    }

    // 11. Verification filter
    if (q.isVerifiedOnly == true &&
        property.verificationStatus != VerificationStatus.verified) {
      return false;
    }

    return true;
  }

  /// Evaluates new published property listings against all active saved searches
  /// and dispatches notifications to matching users (excluding the property owner).
  static Future<List<String>> evaluateNewListingMatches({
    required PropertyEntity property,
    required List<SavedSearchEntity> activeSearches,
    required NotificationRepository notificationRepository,
  }) async {
    final dispatchedNotificationIds = <String>[];

    for (final search in activeSearches) {
      if (!search.isActive) continue;
      if (search.userId.isNotEmpty && search.userId == property.ownerId) continue;

      if (matches(property, search)) {
        final notif = NotificationEntity(
          id: 'notif_match_${property.id}_${search.id}',
          recipientId: search.userId,
          type: NotificationType.newSavedSearchMatch,
          title: 'New Match: ${property.title}',
          body: 'A property matching your saved search "${search.title}" is now available in ${property.locality}.',
          propertyId: property.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final id = await notificationRepository.sendNotification(notif);
        dispatchedNotificationIds.add(id);
      }
    }

    return dispatchedNotificationIds;
  }

  /// Evaluates property price reductions against active saved searches
  /// and dispatches price drop notifications to matching users.
  static Future<List<String>> evaluatePriceDropMatches({
    required PropertyEntity property,
    required double oldPrice,
    required double newPrice,
    required List<SavedSearchEntity> activeSearches,
    required NotificationRepository notificationRepository,
  }) async {
    final dispatchedNotificationIds = <String>[];

    // Gating: Only genuine price reductions trigger alerts
    if (oldPrice <= newPrice) {
      return dispatchedNotificationIds;
    }

    final updatedProperty = property.copyWith(price: newPrice);

    for (final search in activeSearches) {
      if (!search.isActive) continue;
      if (search.userId.isNotEmpty && search.userId == property.ownerId) continue;

      if (matches(updatedProperty, search)) {
        final oldPriceStr = (oldPrice >= 100000)
            ? '₹${(oldPrice / 100000).toStringAsFixed(1)}L'
            : '₹${oldPrice.toInt()}';
        final newPriceStr = (newPrice >= 100000)
            ? '₹${(newPrice / 100000).toStringAsFixed(1)}L'
            : '₹${newPrice.toInt()}';

        final notif = NotificationEntity(
          id: 'notif_pricedrop_${property.id}_${search.id}_${newPrice.toInt()}',
          recipientId: search.userId,
          type: NotificationType.priceDropMatch,
          title: 'Price Drop Alert',
          body: 'Price for "${property.title}" dropped from $oldPriceStr to $newPriceStr in ${property.locality}.',
          propertyId: property.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final id = await notificationRepository.sendNotification(notif);
        dispatchedNotificationIds.add(id);
      }
    }

    return dispatchedNotificationIds;
  }
}
