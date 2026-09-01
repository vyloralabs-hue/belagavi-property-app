import 'package:equatable/equatable.dart';
import '../entities/property_entities.dart';

class LocalityMarketInsight extends Equatable {
  final String locality;
  final String city;
  final int activeListingCount;
  final double medianAskingPrice;
  final double averagePricePerSqFt;
  final double minPrice;
  final double maxPrice;
  final bool hasSufficientData;

  const LocalityMarketInsight({
    required this.locality,
    required this.city,
    required this.activeListingCount,
    required this.medianAskingPrice,
    required this.averagePricePerSqFt,
    required this.minPrice,
    required this.maxPrice,
    required this.hasSufficientData,
  });

  @override
  List<Object?> get props => [locality, city, activeListingCount, medianAskingPrice, averagePricePerSqFt, hasSufficientData];
}

class PropertyPriceHistoryRecord extends Equatable {
  final String propertyId;
  final double currentPrice;
  final double previousPrice;
  final double deltaPercentage; // e.g. -5.2%
  final DateTime changedAt;

  const PropertyPriceHistoryRecord({
    required this.propertyId,
    required this.currentPrice,
    required this.previousPrice,
    required this.deltaPercentage,
    required this.changedAt,
  });

  @override
  List<Object?> get props => [propertyId, currentPrice, previousPrice, deltaPercentage, changedAt];
}

class MarketInsightsService {
  static const int minSampleSize = 3;

  /// Calculate locality market statistics from live active property listings
  static LocalityMarketInsight computeLocalityInsight({
    required String locality,
    required String city,
    required List<PropertyEntity> listings,
  }) {
    final localityListings = listings.where((p) {
      return p.locality.toLowerCase() == locality.toLowerCase() &&
          p.city.toLowerCase() == city.toLowerCase() &&
          (p.status == ListingStatus.published || p.status == ListingStatus.approved || p.status == ListingStatus.active) &&
          p.price > 0;
    }).toList();

    if (localityListings.length < minSampleSize) {
      return LocalityMarketInsight(
        locality: locality,
        city: city,
        activeListingCount: localityListings.length,
        medianAskingPrice: 0.0,
        averagePricePerSqFt: 0.0,
        minPrice: 0.0,
        maxPrice: 0.0,
        hasSufficientData: false,
      );
    }

    final prices = localityListings.map((p) => p.price).toList()..sort();
    final median = prices[prices.length ~/ 2];
    final min = prices.first;
    final max = prices.last;

    double totalRate = 0.0;
    int rateSamples = 0;
    for (final p in localityListings) {
      final area = p.specifications.superBuiltUpArea ?? p.specifications.carpetArea ?? p.specifications.plotArea;
      if (area != null && area > 0) {
        totalRate += (p.price / area);
        rateSamples++;
      }
    }

    final avgRate = rateSamples > 0 ? (totalRate / rateSamples).roundToDouble() : 0.0;

    return LocalityMarketInsight(
      locality: locality,
      city: city,
      activeListingCount: localityListings.length,
      medianAskingPrice: median,
      averagePricePerSqFt: avgRate,
      minPrice: min,
      maxPrice: max,
      hasSufficientData: true,
    );
  }

  /// Create price change record
  static PropertyPriceHistoryRecord recordPriceChange({
    required String propertyId,
    required double oldPrice,
    required double newPrice,
  }) {
    final delta = oldPrice > 0 ? ((newPrice - oldPrice) / oldPrice) * 100.0 : 0.0;
    return PropertyPriceHistoryRecord(
      propertyId: propertyId,
      currentPrice: newPrice,
      previousPrice: oldPrice,
      deltaPercentage: double.parse(delta.toStringAsFixed(1)),
      changedAt: DateTime.now(),
    );
  }
}
