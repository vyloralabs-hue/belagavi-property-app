import '../../property/domain/entities/property_entities.dart';
import '../domain/entities/search_entities.dart';

class AISearchQueryParser {
  AISearchQueryParser._();

  /// Parses natural language search prompts into structured SearchQueryEntity parameters
  /// e.g. "3 BHK apartment under 80 Lakhs in Tilakwadi Belagavi"
  static AISearchIntentEntity parsePrompt(String prompt) {
    final lower = prompt.toLowerCase();
    int? minBhk;
    double? maxPrice;
    String? locality;
    PropertyCategory category = PropertyCategory.residential;
    PropertySubtype type = PropertySubtype.apartment;

    // BHK Extraction
    if (lower.contains('1 bhk') || lower.contains('1bhk')) minBhk = 1;
    if (lower.contains('2 bhk') || lower.contains('2bhk')) minBhk = 2;
    if (lower.contains('3 bhk') || lower.contains('3bhk')) minBhk = 3;
    if (lower.contains('4 bhk') || lower.contains('4bhk')) minBhk = 4;

    // Category / Type Extraction
    if (lower.contains('commercial') || lower.contains('showroom') || lower.contains('office')) {
      category = PropertyCategory.commercial;
      type = PropertySubtype.commercialShowroom;
    } else if (lower.contains('plot') || lower.contains('land') || lower.contains('na plot')) {
      category = PropertyCategory.plotLand;
      type = PropertySubtype.naLand;
    }

    // Locality Extraction
    if (lower.contains('tilakwadi')) locality = 'Tilakwadi';
    if (lower.contains('shahapur')) locality = 'Shahapur';
    if (lower.contains('hindalga')) locality = 'Hindalga';
    if (lower.contains('college road')) locality = 'College Road';

    // Price Extraction
    if (lower.contains('80 lakh') || lower.contains('80l')) maxPrice = 8000000;
    if (lower.contains('50 lakh') || lower.contains('50l')) maxPrice = 5000000;
    if (lower.contains('1 crore') || lower.contains('1cr')) maxPrice = 10000000;

    final extractedQuery = SearchQueryEntity(
      rawQuery: prompt,
      category: category,
      type: type,
      city: 'Belagavi',
      locality: locality,
      maxPrice: maxPrice,
      minBedrooms: minBhk,
    );

    return AISearchIntentEntity(
      originalPrompt: prompt,
      extractedQuery: extractedQuery,
      vectorSearchTerms: [category.name, type.name, locality ?? 'Belagavi'],
      confidenceScore: 0.92,
    );
  }
}
