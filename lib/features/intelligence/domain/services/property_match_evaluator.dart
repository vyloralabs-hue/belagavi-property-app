import '../../../property/domain/entities/property_entities.dart';
import '../entities/preference_entities.dart';
import '../entities/requirement_entities.dart';

class MatchEvaluationResult {
  final int score;
  final bool isMatch;
  final List<String> matchReasons;
  final String summary;

  const MatchEvaluationResult({
    required this.score,
    required this.isMatch,
    required this.matchReasons,
    required this.summary,
  });
}

class PropertyMatchEvaluator {
  PropertyMatchEvaluator._();

  /// Evaluates a Property against a SavedRequirementEntity with price tolerance
  static MatchEvaluationResult evaluateRequirement({
    required SavedRequirementEntity requirement,
    required Property property,
  }) {
    // 1. Mandatory Status Check
    if (property.status != ListingStatus.active && property.status != ListingStatus.published) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Listing is not active'],
        summary: 'Inactive listing',
      );
    }

    if (property.isPaused) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Listing is currently on hold'],
        summary: 'On hold listing',
      );
    }

    // 2. Category Check
    final propCategoryName = property.category.name.toLowerCase();
    final reqCategoryName = requirement.category.toLowerCase();
    if (propCategoryName != reqCategoryName) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Category mismatch'],
        summary: 'Different category',
      );
    }

    // 3. District Check
    if (requirement.district.trim().toLowerCase() != property.district.trim().toLowerCase()) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['District mismatch'],
        summary: 'Outside district',
      );
    }

    int score = 0;
    final List<String> reasons = [];

    // 4. Price & Tolerance Check
    final minB = requirement.minBudget;
    final maxB = requirement.maxBudget;
    final tolPercent = requirement.priceTolerancePercent;
    final tol = tolPercent / 100.0;
    final tolMin = minB * (1.0 - tol);
    final tolMax = maxB * (1.0 + tol);

    if (property.price >= minB && property.price <= maxB) {
      score += 40;
      reasons.add('Exact budget match (₹${(property.price / 100000).toStringAsFixed(1)}L)');
    } else if (property.price >= tolMin && property.price <= tolMax) {
      score += 25;
      final diffPercent = property.price < minB
          ? ((minB - property.price) / minB * 100).toStringAsFixed(0)
          : ((property.price - maxB) / maxB * 100).toStringAsFixed(0);
      reasons.add('Within ±$tolPercent% tolerance ($diffPercent% off target)');
    } else {
      // Outside allowable tolerance
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Price exceeds allowable tolerance'],
        summary: 'Price out of range',
      );
    }

    // 5. Locality Check
    if (requirement.preferredLocalities.isNotEmpty) {
      final matchesLocality = requirement.preferredLocalities.any(
        (loc) => loc.trim().toLowerCase() == property.locality.trim().toLowerCase(),
      );
      if (matchesLocality) {
        score += 30;
        reasons.add('Preferred locality: ${property.locality}');
      } else if (requirement.taluk.trim().toLowerCase() == property.taluk.trim().toLowerCase()) {
        score += 15;
        reasons.add('Same taluk: ${property.taluk}');
      }
    } else {
      score += 30;
      reasons.add('Area: ${property.locality}');
    }

    // 6. Bedrooms Check
    if (requirement.minBedrooms != null) {
      final pBeds = property.specifications.bedrooms ?? 0;
      if (pBeds >= requirement.minBedrooms! &&
          (requirement.maxBedrooms == null || pBeds <= requirement.maxBedrooms!)) {
        score += 15;
        reasons.add('$pBeds BHK match');
      }
    } else {
      score += 15;
    }

    // 7. Area Check
    if (requirement.minArea != null) {
      final pArea = property.specifications.carpetArea ??
          property.specifications.superBuiltUpArea ??
          property.specifications.plotArea ??
          0.0;
      if (pArea >= requirement.minArea! &&
          (requirement.maxArea == null || pArea <= requirement.maxArea!)) {
        score += 15;
        reasons.add('${pArea.toStringAsFixed(0)} ${property.specifications.areaUnit} area match');
      }
    } else {
      score += 15;
    }

    final finalScore = score.clamp(0, 100);
    return MatchEvaluationResult(
      score: finalScore,
      isMatch: finalScore >= 50,
      matchReasons: reasons,
      summary: '$finalScore% Match • ${reasons.take(2).join(' • ')}',
    );
  }

  /// Evaluates a Property against a user's active PropertyPreferenceEntity for Home Personalization
  static MatchEvaluationResult evaluatePreference({
    required PropertyPreferenceEntity preference,
    required Property property,
  }) {
    if (!preference.isActive) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Preference is inactive'],
        summary: 'Preference disabled',
      );
    }

    // Must be active and published
    if (property.status != ListingStatus.active && property.status != ListingStatus.published) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Listing is not active'],
        summary: 'Inactive listing',
      );
    }

    if (property.isPaused) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Listing is on hold'],
        summary: 'On hold listing',
      );
    }

    // Category
    if (preference.category.toLowerCase() != property.category.name.toLowerCase()) {
      return const MatchEvaluationResult(
        score: 0,
        isMatch: false,
        matchReasons: ['Category mismatch'],
        summary: 'Different category',
      );
    }

    int score = 30; // base category match
    final List<String> reasons = [property.category.name.toUpperCase()];

    // Budget
    if (preference.minBudget != null || preference.maxBudget != null) {
      final minB = preference.minBudget ?? 0.0;
      final maxB = preference.maxBudget ?? double.infinity;
      if (property.price >= minB && property.price <= maxB) {
        score += 35;
        reasons.add('Within your budget');
      } else if (property.price <= maxB * 1.15) {
        score += 15;
        reasons.add('Near budget');
      }
    } else {
      score += 35;
    }

    // Locality
    if (preference.preferredLocalities.isNotEmpty) {
      final matchLoc = preference.preferredLocalities.any(
        (loc) => loc.trim().toLowerCase() == property.locality.trim().toLowerCase(),
      );
      if (matchLoc) {
        score += 25;
        reasons.add('In ${property.locality}');
      } else if (preference.taluk.trim().toLowerCase() == property.taluk.trim().toLowerCase()) {
        score += 10;
        reasons.add('In ${property.taluk}');
      }
    } else {
      score += 25;
    }

    // BHK
    if (preference.minBedrooms != null) {
      final pBeds = property.specifications.bedrooms ?? 0;
      if (pBeds >= preference.minBedrooms! &&
          (preference.maxBedrooms == null || pBeds <= preference.maxBedrooms!)) {
        score += 10;
        reasons.add('$pBeds BHK');
      }
    } else {
      score += 10;
    }

    final finalScore = score.clamp(0, 100);
    return MatchEvaluationResult(
      score: finalScore,
      isMatch: finalScore >= 60,
      matchReasons: reasons,
      summary: '$finalScore% Match For You',
    );
  }
}
