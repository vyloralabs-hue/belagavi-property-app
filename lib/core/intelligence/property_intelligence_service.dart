import 'package:equatable/equatable.dart';
import '../../features/property/domain/entities/property_entities.dart';
import '../../features/property_search/domain/entities/search_entities.dart';

/// Parsed search intent generated purely through deterministic rule parsing
class ParsedSearchIntent extends Equatable {
  final String rawQuery;
  final int? bedrooms;
  final double? maxPrice;
  final double? minPrice;
  final String? cityName;
  final String? localityName;
  final PropertyCategory? category;
  final PropertySubtype? type;
  final double confidenceScore;

  const ParsedSearchIntent({
    required this.rawQuery,
    this.bedrooms,
    this.maxPrice,
    this.minPrice,
    this.cityName,
    this.localityName,
    this.category,
    this.type,
    this.confidenceScore = 1.0,
  });

  SearchQueryEntity toSearchQuery() {
    return SearchQueryEntity(
      rawQuery: rawQuery,
      category: category,
      type: type,
      city: cityName,
      locality: localityName,
      maxPrice: maxPrice,
      minPrice: minPrice,
      minBedrooms: bedrooms,
    );
  }

  @override
  List<Object?> get props => [
        rawQuery,
        bedrooms,
        maxPrice,
        minPrice,
        cityName,
        localityName,
        category,
        type,
        confidenceScore,
      ];
}

/// Abstract Core Intelligence Service
/// Core marketplace uses RuleBasedIntelligenceService (zero external paid AI dependencies).
abstract class PropertyIntelligenceService {
  /// Listing completion percentage (0.0 to 100.0)
  double calculateCompletionScore(PropertyEntity property);

  /// Quality score evaluating completeness, description, photo count, location accuracy (0.0 to 100.0)
  double calculateQualityScore(PropertyEntity property);

  /// Exact/fuzzy duplicate detection
  bool detectDuplicateListing(PropertyEntity a, PropertyEntity b);

  /// Price per square unit calculation
  double calculatePricePerUnit({required double price, required double area});

  /// Deterministic natural language query parser
  ParsedSearchIntent parseNaturalLanguageQuery(String query);

  /// Deterministic relevance ranker for search results
  List<PropertyEntity> rankSearchResults(List<PropertyEntity> results, SearchQueryEntity query);

  /// Rule-based recommendation engine based on user preference, recent location, budget, favorites
  List<PropertyEntity> getRecommendations({
    required List<PropertyEntity> availableProperties,
    String? preferredCity,
    String? preferredLocality,
    double? preferredBudget,
    List<String> userFavoriteIds = const [],
    int limit = 10,
  });
}

/// Production Rule-Based Intelligence Implementation
/// 100% deterministic, offline-capable, zero external paid API calls.
class RuleBasedIntelligenceService implements PropertyIntelligenceService {
  const RuleBasedIntelligenceService();

  @override
  double calculateCompletionScore(PropertyEntity property) {
    int points = 0;
    const totalPoints = 8;

    if (property.title.trim().isNotEmpty) points++;
    if (property.description.trim().length >= 20) points++;
    if (property.city.trim().isNotEmpty) points++;
    if (property.locality.trim().isNotEmpty) points++;
    if (property.price > 0) points++;
    if (property.specifications.carpetArea != null || property.specifications.plotArea != null || property.specifications.superBuiltUpArea != null) points++;
    if (property.media.isNotEmpty) points++;
    if (property.latitude != null && property.longitude != null) points++;

    return (points / totalPoints) * 100.0;
  }

  @override
  double calculateQualityScore(PropertyEntity property) {
    double score = 40.0;

    // Photos quality
    if (property.media.length >= 5) {
      score += 25.0;
    } else if (property.media.length >= 3) {
      score += 15.0;
    } else if (property.media.isNotEmpty) {
      score += 8.0;
    }

    // Description depth
    if (property.description.trim().length >= 100) {
      score += 15.0;
    } else if (property.description.trim().length >= 40) {
      score += 8.0;
    }

    // Exact location details
    if (property.locality.isNotEmpty && property.pincode.isNotEmpty) {
      score += 10.0;
    }

    // Verified / Specifications
    if (property.specifications.furnishingStatus != null && property.specifications.furnishingStatus!.isNotEmpty) {
      score += 5.0;
    }
    if (property.specifications.facingDirection != null && property.specifications.facingDirection!.isNotEmpty) {
      score += 5.0;
    }

    return score.clamp(0.0, 100.0);
  }

  @override
  bool detectDuplicateListing(PropertyEntity a, PropertyEntity b) {
    if (a.id == b.id) return true;

    // Same owner with matching core attributes
    if (a.ownerId == b.ownerId) {
      final sameLoc = a.locality.trim().toLowerCase() == b.locality.trim().toLowerCase();
      final samePrice = (a.price - b.price).abs() < 100;
      final sameBed = a.specifications.bedrooms == b.specifications.bedrooms;
      final sameCategory = a.category == b.category;

      if (sameLoc && samePrice && sameBed && sameCategory) {
        return true;
      }
    }

    // Same city, locality, exact title and identical price
    if (a.city.trim().toLowerCase() == b.city.trim().toLowerCase() &&
        a.locality.trim().toLowerCase() == b.locality.trim().toLowerCase() &&
        a.title.trim().toLowerCase() == b.title.trim().toLowerCase() &&
        (a.price - b.price).abs() < 1.0) {
      return true;
    }

    return false;
  }

  @override
  double calculatePricePerUnit({required double price, required double area}) {
    if (area <= 0 || price <= 0) return 0.0;
    return double.parse((price / area).toStringAsFixed(2));
  }

  @override
  ParsedSearchIntent parseNaturalLanguageQuery(String query) {
    final lower = query.toLowerCase();
    int? bedrooms;
    double? maxPrice;
    double? minPrice;
    String? cityName;
    String? localityName;
    PropertyCategory? category;
    PropertySubtype? type;

    // 1. BHK pattern extraction (e.g. 1 bhk, 2bhk, 3 BHK)
    final bhkMatch = RegExp(r'([1-9])\s*(?:bhk|bed|bedroom)', caseSensitive: false).firstMatch(lower);
    if (bhkMatch != null) {
      bedrooms = int.tryParse(bhkMatch.group(1)!);
    }

    // 2. Budget / Price pattern extraction
    final croreMatch = RegExp(r'(?:under|below|within|upto|less than)?\s*([0-9]+(?:\.[0-9]+)?)\s*(?:cr|crore|crores)', caseSensitive: false).firstMatch(lower);
    if (croreMatch != null) {
      final val = double.tryParse(croreMatch.group(1)!);
      if (val != null) maxPrice = val * 10000000;
    }

    final lakhMatch = RegExp(r'(?:under|below|within|upto|less than)?\s*([0-9]+(?:\.[0-9]+)?)\s*(?:lakh|lakhs|lac|lacs|l)\b', caseSensitive: false).firstMatch(lower);
    if (lakhMatch != null && maxPrice == null) {
      final val = double.tryParse(lakhMatch.group(1)!);
      if (val != null) maxPrice = val * 100000;
    }

    // 3. Category & Type extraction
    if (lower.contains('commercial') || lower.contains('office') || lower.contains('showroom') || lower.contains('shop')) {
      category = PropertyCategory.commercial;
      if (lower.contains('office')) type = PropertySubtype.commercialOffice;
      if (lower.contains('showroom')) type = PropertySubtype.commercialShowroom;
      if (lower.contains('shop')) type = PropertySubtype.commercialShop;
    } else if (lower.contains('plot') || lower.contains('layout') || lower.contains('site') || lower.contains('na plot')) {
      category = PropertyCategory.plotLand;
      type = PropertySubtype.plot;
    } else if (lower.contains('land') || lower.contains('agriculture') || lower.contains('farmland')) {
      category = PropertyCategory.land;
      type = PropertySubtype.agriculturalLand;
    } else if (lower.contains('villa') || lower.contains('house') || lower.contains('row house') || lower.contains('independent house')) {
      category = PropertyCategory.residential;
      if (lower.contains('villa')) type = PropertySubtype.villa;
      if (lower.contains('independent')) type = PropertySubtype.independentHouse;
    } else if (lower.contains('flat') || lower.contains('apartment') || lower.contains('bhk') || lower.contains('penthouse')) {
      category = PropertyCategory.residential;
      type = lower.contains('penthouse') ? PropertySubtype.penthouse : PropertySubtype.apartment;
    }

    // 4. Well-known Cities extraction
    final knownCities = {
      'bengaluru': 'Bengaluru',
      'bangalore': 'Bengaluru',
      'pune': 'Pune',
      'mumbai': 'Mumbai',
      'bombay': 'Mumbai',
      'belagavi': 'Belagavi',
      'belgaum': 'Belagavi',
      'hyderabad': 'Hyderabad',
      'delhi': 'Delhi NCR',
      'noida': 'Delhi NCR',
      'gurgaon': 'Delhi NCR',
      'chennai': 'Chennai',
      'madras': 'Chennai',
      'kolkata': 'Kolkata',
      'mysuru': 'Mysuru',
      'hubballi': 'Hubballi',
      'goa': 'Goa',
    };

    for (final entry in knownCities.entries) {
      if (lower.contains(entry.key)) {
        cityName = entry.value;
        break;
      }
    }

    // 5. Well-known Localities extraction
    final knownLocalities = {
      'whitefield': 'Whitefield',
      'koramangala': 'Koramangala',
      'indiranagar': 'Indiranagar',
      'hsr': 'HSR Layout',
      'baner': 'Baner',
      'hinjewadi': 'Hinjewadi',
      'wakad': 'Wakad',
      'kothrud': 'Kothrud',
      'andheri': 'Andheri',
      'bandra': 'Bandra',
      'tilakwadi': 'Tilakwadi',
      'shahapur': 'Shahapur',
      'hindalga': 'Hindalga',
      'hanuman nagar': 'Hanuman Nagar',
      'camp': 'Camp',
      'gachibowli': 'Gachibowli',
      'connaught place': 'Connaught Place',
    };

    for (final entry in knownLocalities.entries) {
      if (lower.contains(entry.key)) {
        localityName = entry.value;
        break;
      }
    }

    return ParsedSearchIntent(
      rawQuery: query,
      bedrooms: bedrooms,
      maxPrice: maxPrice,
      minPrice: minPrice,
      cityName: cityName,
      localityName: localityName,
      category: category,
      type: type,
      confidenceScore: 0.95,
    );
  }

  @override
  List<PropertyEntity> rankSearchResults(List<PropertyEntity> results, SearchQueryEntity query) {
    if (results.isEmpty) return results;

    final scored = results.map((prop) {
      double score = 0.0;

      // 1. Exact Locality match (+50)
      if (query.locality != null && query.locality!.isNotEmpty) {
        if (prop.locality.toLowerCase() == query.locality!.toLowerCase()) {
          score += 50.0;
        } else if (prop.locality.toLowerCase().contains(query.locality!.toLowerCase())) {
          score += 25.0;
        }
      }

      // 2. Exact City match (+30)
      if (query.city != null && query.city!.isNotEmpty) {
        if (prop.city.toLowerCase() == query.city!.toLowerCase()) {
          score += 30.0;
        }
      }

      // 3. Media rich (+20)
      if (prop.media.isNotEmpty) {
        score += (prop.media.length.clamp(1, 5) * 4.0);
      }

      // 4. Recency bonus (within 30 days +10)
      final ageDays = DateTime.now().difference(prop.createdAt).inDays;
      if (ageDays <= 30) {
        score += (30 - ageDays) * 0.33;
      }

      return MapEntry(prop, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  @override
  List<PropertyEntity> getRecommendations({
    required List<PropertyEntity> availableProperties,
    String? preferredCity,
    String? preferredLocality,
    double? preferredBudget,
    List<String> userFavoriteIds = const [],
    int limit = 10,
  }) {
    if (availableProperties.isEmpty) return const [];

    final scored = availableProperties.map((prop) {
      double score = 0.0;

      // Bonus if matches user's preferred city
      if (preferredCity != null && prop.city.toLowerCase() == preferredCity.toLowerCase()) {
        score += 40.0;
      }

      // Bonus if matches preferred locality
      if (preferredLocality != null && prop.locality.toLowerCase() == preferredLocality.toLowerCase()) {
        score += 30.0;
      }

      // Bonus if within ±25% of budget
      if (preferredBudget != null && preferredBudget > 0) {
        final diff = (prop.price - preferredBudget).abs();
        final ratio = diff / preferredBudget;
        if (ratio <= 0.25) {
          score += (1.0 - ratio) * 20.0;
        }
      }

      // High media count bonus
      if (prop.media.length >= 3) {
        score += 10.0;
      }

      return MapEntry(prop, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }
}

/// Placeholder for optional future On-Device model (e.g. TensorFlow Lite / ONNX)
/// Kept lazy, feature-flagged, and disabled by default with zero network dependency.
class OnDeviceModelService implements PropertyIntelligenceService {
  final bool isModelLoaded;
  const OnDeviceModelService({this.isModelLoaded = false});

  @override
  double calculateCompletionScore(PropertyEntity property) =>
      const RuleBasedIntelligenceService().calculateCompletionScore(property);

  @override
  double calculateQualityScore(PropertyEntity property) =>
      const RuleBasedIntelligenceService().calculateQualityScore(property);

  @override
  bool detectDuplicateListing(PropertyEntity a, PropertyEntity b) =>
      const RuleBasedIntelligenceService().detectDuplicateListing(a, b);

  @override
  double calculatePricePerUnit({required double price, required double area}) =>
      const RuleBasedIntelligenceService().calculatePricePerUnit(price: price, area: area);

  @override
  ParsedSearchIntent parseNaturalLanguageQuery(String query) =>
      const RuleBasedIntelligenceService().parseNaturalLanguageQuery(query);

  @override
  List<PropertyEntity> rankSearchResults(List<PropertyEntity> results, SearchQueryEntity query) =>
      const RuleBasedIntelligenceService().rankSearchResults(results, query);

  @override
  List<PropertyEntity> getRecommendations({
    required List<PropertyEntity> availableProperties,
    String? preferredCity,
    String? preferredLocality,
    double? preferredBudget,
    List<String> userFavoriteIds = const [],
    int limit = 10,
  }) =>
      const RuleBasedIntelligenceService().getRecommendations(
        availableProperties: availableProperties,
        preferredCity: preferredCity,
        preferredLocality: preferredLocality,
        preferredBudget: preferredBudget,
        userFavoriteIds: userFavoriteIds,
        limit: limit,
      );
}

/// Placeholder for optional future Self-Hosted model (e.g. self-hosted LLM on private server)
/// Kept feature-flagged and disabled by default with zero external paid AI coupling.
class SelfHostedModelService implements PropertyIntelligenceService {
  final String? serverEndpoint;
  final bool isAvailable;

  const SelfHostedModelService({this.serverEndpoint, this.isAvailable = false});

  @override
  double calculateCompletionScore(PropertyEntity property) =>
      const RuleBasedIntelligenceService().calculateCompletionScore(property);

  @override
  double calculateQualityScore(PropertyEntity property) =>
      const RuleBasedIntelligenceService().calculateQualityScore(property);

  @override
  bool detectDuplicateListing(PropertyEntity a, PropertyEntity b) =>
      const RuleBasedIntelligenceService().detectDuplicateListing(a, b);

  @override
  double calculatePricePerUnit({required double price, required double area}) =>
      const RuleBasedIntelligenceService().calculatePricePerUnit(price: price, area: area);

  @override
  ParsedSearchIntent parseNaturalLanguageQuery(String query) =>
      const RuleBasedIntelligenceService().parseNaturalLanguageQuery(query);

  @override
  List<PropertyEntity> rankSearchResults(List<PropertyEntity> results, SearchQueryEntity query) =>
      const RuleBasedIntelligenceService().rankSearchResults(results, query);

  @override
  List<PropertyEntity> getRecommendations({
    required List<PropertyEntity> availableProperties,
    String? preferredCity,
    String? preferredLocality,
    double? preferredBudget,
    List<String> userFavoriteIds = const [],
    int limit = 10,
  }) =>
      const RuleBasedIntelligenceService().getRecommendations(
        availableProperties: availableProperties,
        preferredCity: preferredCity,
        preferredLocality: preferredLocality,
        preferredBudget: preferredBudget,
        userFavoriteIds: userFavoriteIds,
        limit: limit,
      );
}
