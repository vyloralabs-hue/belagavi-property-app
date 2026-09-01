import '../entities/property_entities.dart';

class SimilarPropertiesEngine {
  /// Deterministically finds up to [limit] similar properties grounded in actual database results
  static List<PropertyEntity> findSimilar({
    required PropertyEntity target,
    required List<PropertyEntity> candidatePool,
    int limit = 5,
  }) {
    final filtered = candidatePool.where((candidate) {
      // 1. Exclude target property itself
      if (candidate.id == target.id) return false;

      // 2. Must be published / active
      if (candidate.status != ListingStatus.published &&
          candidate.status != ListingStatus.approved &&
          candidate.status != ListingStatus.active) {
        return false;
      }

      // 3. Category match is mandatory
      if (candidate.category != target.category) return false;

      return true;
    }).toList();

    // Score candidates based on similarity dimensions
    final scored = filtered.map((candidate) {
      double score = 0.0;

      // Location match (+40 pts for same locality, +20 pts for same city)
      if (candidate.locality.toLowerCase() == target.locality.toLowerCase()) {
        score += 40.0;
      } else if (candidate.city.toLowerCase() == target.city.toLowerCase()) {
        score += 20.0;
      }

      // Price Proximity (max +30 pts if within +/- 25%)
      if (target.price > 0 && candidate.price > 0) {
        final ratio = (candidate.price - target.price).abs() / target.price;
        if (ratio <= 0.10) {
          score += 30.0;
        } else if (ratio <= 0.25) {
          score += 20.0;
        } else if (ratio <= 0.50) {
          score += 10.0;
        }
      }

      // BHK match (+20 pts)
      if (target.specifications.bedrooms != null && candidate.specifications.bedrooms != null) {
        if (target.specifications.bedrooms == candidate.specifications.bedrooms) {
          score += 20.0;
        }
      }

      // Subtype match (+10 pts)
      if (candidate.type == target.type) {
        score += 10.0;
      }

      return MapEntry(candidate, score);
    }).toList();

    // Sort by similarity score descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.take(limit).map((e) => e.key).toList();
  }
}
