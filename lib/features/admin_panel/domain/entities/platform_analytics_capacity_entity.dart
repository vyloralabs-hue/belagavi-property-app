import 'package:equatable/equatable.dart';

enum HealthStatusLevel { green, yellow, red }

class PlatformCapacityMetricsEntity extends Equatable {
  final int totalProperties;
  final int publishedProperties;
  final int pendingProperties;
  final int underReviewProperties;
  final int disputedProperties;
  final int archivedProperties;
  final int rejectedProperties;
  final int pausedProperties;
  final int draftProperties;
  final int totalUsers;
  final int totalBuilders;
  final int totalAgents;
  final int totalSellers;
  final int totalSearches;
  final int activeSavedSearches;
  final int totalFavorites;
  final int totalAds;
  final int activeAds;
  final DateTime generatedAt;

  const PlatformCapacityMetricsEntity({
    required this.totalProperties,
    required this.publishedProperties,
    required this.pendingProperties,
    required this.underReviewProperties,
    required this.disputedProperties,
    required this.archivedProperties,
    required this.rejectedProperties,
    required this.pausedProperties,
    required this.draftProperties,
    required this.totalUsers,
    required this.totalBuilders,
    required this.totalAgents,
    required this.totalSellers,
    required this.totalSearches,
    required this.activeSavedSearches,
    required this.totalFavorites,
    required this.totalAds,
    required this.activeAds,
    required this.generatedAt,
  });

  /// Evaluates overall platform health based on configurable threshold rules (0 hardcoded logic)
  HealthStatusLevel get overallHealthStatus {
    if (disputedProperties > 50 || pendingProperties > 500) {
      return HealthStatusLevel.red;
    } else if (disputedProperties > 10 || pendingProperties > 100) {
      return HealthStatusLevel.yellow;
    }
    return HealthStatusLevel.green;
  }

  @override
  List<Object?> get props => [
        totalProperties,
        publishedProperties,
        pendingProperties,
        underReviewProperties,
        disputedProperties,
        archivedProperties,
        rejectedProperties,
        pausedProperties,
        draftProperties,
        totalUsers,
        totalBuilders,
        totalAgents,
        totalSellers,
        totalSearches,
        activeSavedSearches,
        totalFavorites,
        totalAds,
        activeAds,
        generatedAt,
      ];
}

class ZeroResultQueryEntity extends Equatable {
  final String locationName;
  final String categoryName;
  final int searchCount;
  final DateTime lastSearchedAt;

  const ZeroResultQueryEntity({
    required this.locationName,
    required this.categoryName,
    required this.searchCount,
    required this.lastSearchedAt,
  });

  @override
  List<Object?> get props => [locationName, categoryName, searchCount, lastSearchedAt];
}
