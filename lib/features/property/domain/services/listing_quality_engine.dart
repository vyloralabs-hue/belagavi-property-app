import '../entities/property_entities.dart';

/// Centralized deterministic engine to compute listing quality score (0-100)
/// and generate actionable improvement suggestions for property sellers.
class ListingQualityScore {
  final int score; // 0 to 100
  final String rating; // 'Poor', 'Fair', 'Good', 'Excellent'
  final List<String> suggestions;
  final Map<String, int> breakdown;

  const ListingQualityScore({
    required this.score,
    required this.rating,
    required this.suggestions,
    required this.breakdown,
  });
}

class ListingQualityEngine {
  const ListingQualityEngine();

  /// Calculate listing quality score deterministically without AI hallucination
  static ListingQualityScore evaluate(PropertyEntity property) {
    int score = 0;
    final breakdown = <String, int>{};
    final suggestions = <String>[];

    // 1. Title & Description Clarity (max 20 pts)
    int contentPts = 0;
    if (property.title.trim().length >= 10) contentPts += 8;
    if (property.description.trim().length >= 50) {
      contentPts += 12;
    } else if (property.description.trim().length >= 20) {
      contentPts += 6;
      suggestions.add('Write a more detailed description (at least 50 characters).');
    } else {
      suggestions.add('Add a comprehensive property description to attract serious buyers.');
    }
    breakdown['content'] = contentPts;
    score += contentPts;

    // 2. High-Quality Media (max 25 pts)
    int mediaPts = 0;
    final mediaCount = property.mediaList.length;
    if (mediaCount >= 5) {
      mediaPts = 25;
    } else if (mediaCount >= 3) {
      mediaPts = 18;
      suggestions.add('Add ${5 - mediaCount} more photos (including kitchen & bathroom) for maximum visibility.');
    } else if (mediaCount >= 1) {
      mediaPts = 10;
      suggestions.add('Upload at least 4 more high-resolution photos of different rooms.');
    } else {
      suggestions.add('Upload at least 3 photos. Listings with photos receive 5x more enquiries.');
    }
    breakdown['media'] = mediaPts;
    score += mediaPts;

    // 3. Location Precision (max 20 pts)
    int locPts = 0;
    if (property.city.trim().isNotEmpty) locPts += 5;
    if (property.locality.trim().isNotEmpty) locPts += 7;
    if (property.pincode.trim().isNotEmpty && property.pincode.trim().length >= 6) locPts += 4;
    if (property.latitude != null && property.longitude != null) {
      locPts += 4;
    } else {
      suggestions.add('Pin exact GPS location on the map for verified neighborhood accuracy.');
    }
    breakdown['location'] = locPts;
    score += locPts;

    // 4. Physical & Technical Specifications (max 20 pts)
    int specPts = 0;
    final specs = property.specifications;
    if ((specs.superBuiltUpArea != null && specs.superBuiltUpArea! > 0) ||
        (specs.carpetArea != null && specs.carpetArea! > 0) ||
        (specs.plotArea != null && specs.plotArea! > 0)) {
      specPts += 8;
    } else {
      suggestions.add('Specify built-up, carpet, or plot area dimensions.');
    }

    if (specs.bedrooms != null && specs.bedrooms! > 0) specPts += 4;
    if (specs.bathrooms != null && specs.bathrooms! > 0) specPts += 3;
    if (specs.facingDirection != null && specs.facingDirection!.isNotEmpty) {
      specPts += 3;
    } else {
      suggestions.add('Specify facing direction (e.g. East, North) to help Vastu-conscious buyers.');
    }
    if (specs.furnishingStatus != null && specs.furnishingStatus!.isNotEmpty) specPts += 2;
    breakdown['specifications'] = specPts;
    score += specPts;

    // 5. Pricing & Verification Readiness (max 15 pts)
    int trustPts = 0;
    if (property.price > 0) trustPts += 8;
    if (property.verificationStatus == VerificationStatus.verified) {
      trustPts += 7;
    } else if (property.verificationStatus == VerificationStatus.pending) {
      trustPts += 3;
    } else {
      suggestions.add('Submit property documents for platform verification to earn the Verified badge.');
    }
    breakdown['trust'] = trustPts;
    score += trustPts;

    // Determine qualitative rating
    final String rating;
    if (score >= 85) {
      rating = 'Excellent';
    } else if (score >= 70) {
      rating = 'Good';
    } else if (score >= 50) {
      rating = 'Fair';
    } else {
      rating = 'Poor';
    }

    return ListingQualityScore(
      score: score.clamp(0, 100),
      rating: rating,
      suggestions: suggestions,
      breakdown: breakdown,
    );
  }
}
