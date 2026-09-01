import '../domain/entities/search_entities.dart';

class NaturalLanguageSearchParser {
  /// Parse natural language property search query into structured search filters
  static SearchQueryEntity parseQuery(String rawInput) {
    final text = rawInput.trim();
    if (text.isEmpty) return const SearchQueryEntity();

    final lower = text.toLowerCase();

    // 1. Detect City / Locality
    String? city;
    String? locality;
    if (lower.contains('belagavi') || lower.contains('belgaum')) {
      city = 'Belagavi';
    }

    final knownLocalities = ['tilakwadi', 'mandoli road', 'camp', 'shahapur', 'udyambag', 'angol', 'vadgaon', 'hindwadi'];
    for (final loc in knownLocalities) {
      if (lower.contains(loc)) {
        locality = loc[0].toUpperCase() + loc.substring(1);
        break;
      }
    }

    // 2. Detect BHK
    int? bedrooms;
    final bhkMatch = RegExp(r'(\d+)\s*bhk').firstMatch(lower);
    if (bhkMatch != null) {
      bedrooms = int.tryParse(bhkMatch.group(1) ?? '');
    }

    // 3. Detect Budget (e.g. 70 lakh, 70L, 1.5 cr)
    double? maxPrice;
    final crMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:cr|crore)').firstMatch(lower);
    final lakhMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:lakh|lakhs|l|lac)').firstMatch(lower);

    if (crMatch != null) {
      final crVal = double.tryParse(crMatch.group(1) ?? '');
      if (crVal != null) maxPrice = crVal * 10000000;
    } else if (lakhMatch != null) {
      final lakhVal = double.tryParse(lakhMatch.group(1) ?? '');
      if (lakhVal != null) maxPrice = lakhVal * 100000;
    }

    // 4. Detect Facing Direction
    String? facing;
    if (lower.contains('east facing') || lower.contains('east')) {
      facing = 'East';
    } else if (lower.contains('north facing') || lower.contains('north')) {
      facing = 'North';
    } else if (lower.contains('west facing') || lower.contains('west')) {
      facing = 'West';
    } else if (lower.contains('south facing') || lower.contains('south')) {
      facing = 'South';
    }

    return SearchQueryEntity(
      rawQuery: text,
      city: city,
      locality: locality,
      minBedrooms: bedrooms,
      maxBedrooms: bedrooms,
      maxPrice: maxPrice,
      facingDirection: facing,
    );
  }
}
