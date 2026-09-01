import 'package:belagavi_property/core/config/property_monetization_config.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

class PropertyPriorityRanker {
  static double calculatePriorityScore({
    required PropertyEntity property,
    PropertyPromotionTier promotionTier = PropertyPromotionTier.free,
    String? searchLocality,
    String? searchCity,
  }) {
    // 1. Safety & Moderation Override Rule:
    // If property status is NOT published/approved/active, public priority score is -1
    final isPubliclyAllowed = property.status == ListingStatus.published ||
        property.status == ListingStatus.approved ||
        property.status == ListingStatus.active;

    if (!isPubliclyAllowed) {
      return -1.0;
    }

    double score = 100.0; // baseSearchScore

    // 2. Geographic Relevance Score
    if (searchLocality != null &&
        searchLocality.isNotEmpty &&
        property.locality.toLowerCase().contains(searchLocality.toLowerCase())) {
      score += 25.0;
    } else if (searchCity != null &&
        searchCity.isNotEmpty &&
        property.city.toLowerCase() == searchCity.toLowerCase()) {
      score += 15.0;
    }

    // 3. Verification Score
    if (property.verificationStatus == VerificationStatus.verified) {
      score += 15.0;
    }

    // 4. Listing Quality Score (based on media items & specs)
    if (property.mediaList.isNotEmpty) {
      score += (property.mediaList.length * 2.0).clamp(0.0, 10.0);
    }

    // 5. Freshness Score (recency in days)
    final ageInDays = DateTime.now().difference(property.createdAt).inDays;
    final freshnessScore = (10.0 - ageInDays).clamp(0.0, 10.0);
    score += freshnessScore;

    // 6. Premium Priority Score (from central config)
    final plan = PropertyMonetizationConfig.getPlan(promotionTier);
    score += plan.priorityBoostScore;

    return score;
  }

  static List<PropertyEntity> rankProperties({
    required List<PropertyEntity> properties,
    Map<String, PropertyPromotionTier>? propertyPromotions,
    String? searchLocality,
    String? searchCity,
  }) {
    final scoredList = properties.map((prop) {
      final tier = propertyPromotions?[prop.id] ?? PropertyPromotionTier.free;
      final score = calculatePriorityScore(
        property: prop,
        promotionTier: tier,
        searchLocality: searchLocality,
        searchCity: searchCity,
      );
      return MapEntry(prop, score);
    }).toList();

    // Filter out non-public properties (score < 0)
    final publicOnly = scoredList.where((entry) => entry.value >= 0).toList();

    // Sort deterministically by calculated priority score descending
    publicOnly.sort((a, b) => b.value.compareTo(a.value));

    return publicOnly.map((e) => e.key).toList();
  }
}
