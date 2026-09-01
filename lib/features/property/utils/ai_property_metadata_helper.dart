import '../domain/entities/property_entities.dart';

class AIPropertyMetadataHelper {
  AIPropertyMetadataHelper._();

  /// Constructs structured parameters for LLM prompt completions
  static Map<String, String> buildPromptVariables(PropertyEntity property) {
    return {
      'title': property.title,
      'category': property.category.name,
      'type': property.type.name,
      'locality': property.locality,
      'city': property.city,
      'price': property.price.toStringAsFixed(0),
      'bedrooms': property.specifications.bedrooms?.toString() ?? 'N/A',
      'area': '${property.specifications.superBuiltUpArea ?? property.specifications.plotArea ?? 'N/A'} ${property.specifications.areaUnit}',
    };
  }
}
