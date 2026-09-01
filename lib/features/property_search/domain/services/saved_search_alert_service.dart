import 'package:equatable/equatable.dart';
import '../entities/saved_search_entity.dart';
import '../entities/search_entities.dart';
import '../../../property/domain/entities/property_entities.dart';

enum AlertFrequency { instant, daily, weekly }
enum AlertChannel { inApp, push, email, sms, whatsapp }

class SavedSearchAlertPreference extends Equatable {
  final String savedSearchId;
  final String userId;
  final AlertFrequency frequency;
  final Set<AlertChannel> enabledChannels;
  final bool isMuted;

  const SavedSearchAlertPreference({
    required this.savedSearchId,
    required this.userId,
    this.frequency = AlertFrequency.instant,
    this.enabledChannels = const {AlertChannel.inApp, AlertChannel.push},
    this.isMuted = false,
  });

  @override
  List<Object?> get props => [savedSearchId, userId, frequency, enabledChannels, isMuted];
}

class SavedSearchAlertNotification extends Equatable {
  final String id;
  final String savedSearchId;
  final String userId;
  final String propertyId;
  final String propertyTitle;
  final double propertyPrice;
  final String locationSummary;
  final DateTime matchedAt;

  const SavedSearchAlertNotification({
    required this.id,
    required this.savedSearchId,
    required this.userId,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyPrice,
    required this.locationSummary,
    required this.matchedAt,
  });

  @override
  List<Object?> get props => [id, savedSearchId, userId, propertyId, matchedAt];
}

class SavedSearchAlertService {
  const SavedSearchAlertService();

  /// Deterministically checks if a newly listed or updated property matches a saved search query
  static bool doesPropertyMatchQuery(PropertyEntity property, SearchQueryEntity query) {
    // 1. Status must be published/approved
    if (property.status != ListingStatus.published &&
        property.status != ListingStatus.approved &&
        property.status != ListingStatus.active) {
      return false;
    }

    // 2. Category Check
    if (query.category != null && property.category != query.category) {
      return false;
    }

    // 3. Subtype Check
    if (query.type != null && property.type != query.type) {
      return false;
    }

    // 4. Price Bounds
    if (query.minPrice != null && property.price < query.minPrice!) {
      return false;
    }
    if (query.maxPrice != null && property.price > query.maxPrice!) {
      return false;
    }

    // 5. Bedroom Count
    if (query.minBedrooms != null) {
      final bedrooms = property.specifications.bedrooms ?? 0;
      if (bedrooms < query.minBedrooms!) return false;
    }

    // 6. Location Match (City, Locality, District, State)
    if (query.city != null && query.city!.isNotEmpty) {
      if (property.city.toLowerCase() != query.city!.toLowerCase()) {
        return false;
      }
    }
    if (query.locality != null && query.locality!.isNotEmpty) {
      if (!property.locality.toLowerCase().contains(query.locality!.toLowerCase())) {
        return false;
      }
    }
    if (query.pincode != null && query.pincode!.isNotEmpty) {
      if (property.pincode != query.pincode) {
        return false;
      }
    }

    // 7. Area Bounds
    final area = property.specifications.superBuiltUpArea ?? property.specifications.carpetArea ?? property.specifications.plotArea;
    if (query.minArea != null && area != null && area < query.minArea!) {
      return false;
    }
    if (query.maxArea != null && area != null && area > query.maxArea!) {
      return false;
    }

    // 8. Verification requirement
    if (query.isVerifiedOnly == true && property.verificationStatus != VerificationStatus.verified) {
      return false;
    }

    return true;
  }

  /// Match a property against a collection of user saved searches and generate notifications
  static List<SavedSearchAlertNotification> evaluateMatches({
    required PropertyEntity property,
    required List<SavedSearchEntity> savedSearches,
    Map<String, SavedSearchAlertPreference> preferences = const {},
  }) {
    final notifications = <SavedSearchAlertNotification>[];

    for (final search in savedSearches) {
      if (!search.isActive) continue;

      final pref = preferences[search.id];
      if (pref != null && pref.isMuted) continue;

      if (doesPropertyMatchQuery(property, search.query)) {
        notifications.add(
          SavedSearchAlertNotification(
            id: 'alert_${search.id}_${property.id}_${DateTime.now().millisecondsSinceEpoch}',
            savedSearchId: search.id,
            userId: search.userId,
            propertyId: property.id,
            propertyTitle: property.title,
            propertyPrice: property.price,
            locationSummary: '${property.locality}, ${property.city}',
            matchedAt: DateTime.now(),
          ),
        );
      }
    }

    return notifications;
  }
}
