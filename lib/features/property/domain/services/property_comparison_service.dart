import 'package:equatable/equatable.dart';
import '../entities/property_entities.dart';

class PropertyComparisonRow extends Equatable {
  final String label;
  final String categoryKey;
  final List<String> valuesPerProperty;
  final bool isHighlightDifference;

  const PropertyComparisonRow({
    required this.label,
    required this.categoryKey,
    required this.valuesPerProperty,
    this.isHighlightDifference = false,
  });

  @override
  List<Object?> get props => [label, categoryKey, valuesPerProperty, isHighlightDifference];
}

class PropertyComparisonMatrix extends Equatable {
  final List<PropertyEntity> properties;
  final List<PropertyComparisonRow> rows;

  const PropertyComparisonMatrix({
    required this.properties,
    required this.rows,
  });

  @override
  List<Object?> get props => [properties, rows];
}

class PropertyComparisonService {
  static const int minProperties = 2;
  static const int maxProperties = 4;

  /// Compare 2 to 4 properties side-by-side with category-aware row filtering
  static PropertyComparisonMatrix compare(List<PropertyEntity> properties) {
    if (properties.length < minProperties || properties.length > maxProperties) {
      throw ArgumentError('Comparison requires between $minProperties and $maxProperties properties.');
    }

    final rows = <PropertyComparisonRow>[];

    // 1. Price & Value
    _addRow(rows, 'Price', properties.map((p) => '₹${(p.price / 100000).toStringAsFixed(1)} L').toList());

    _addRow(rows, 'Price / Sq Ft', properties.map((p) {
      final area = p.specifications.superBuiltUpArea ?? p.specifications.carpetArea ?? p.specifications.plotArea ?? 0;
      if (area > 0) {
        return '₹${(p.price / area).round()} / sqft';
      }
      return 'N/A';
    }).toList());

    _addRow(rows, 'Category', properties.map((p) => p.category.name.toUpperCase()).toList());
    _addRow(rows, 'Subtype', properties.map((p) => p.type.name).toList());
    _addRow(rows, 'Locality', properties.map((p) => '${p.locality}, ${p.city}').toList());

    // Category-aware rows (only show BHK/Bathrooms if at least one residential property exists)
    final hasResidential = properties.any((p) => p.category == PropertyCategory.residential);
    if (hasResidential) {
      _addRow(rows, 'Bedrooms (BHK)', properties.map((p) => p.specifications.bedrooms?.toString() ?? '—').toList());
      _addRow(rows, 'Bathrooms', properties.map((p) => p.specifications.bathrooms?.toString() ?? '—').toList());
      _addRow(rows, 'Furnishing', properties.map((p) => p.specifications.furnishingStatus ?? 'Unspecified').toList());
    }

    // Physical Dimensions
    _addRow(rows, 'Built-up / Plot Area', properties.map((p) {
      final area = p.specifications.superBuiltUpArea ?? p.specifications.carpetArea ?? p.specifications.plotArea;
      return area != null ? '$area ${p.specifications.areaUnit}' : 'Unspecified';
    }).toList());

    _addRow(rows, 'Facing Direction', properties.map((p) => p.specifications.facingDirection ?? 'Unspecified').toList());
    _addRow(rows, 'Verification Status', properties.map((p) => p.verificationStatus == VerificationStatus.verified ? 'Verified' : 'Unverified').toList());
    _addRow(rows, 'Negotiable', properties.map((p) => p.isNegotiable ? 'Yes' : 'Fixed Price').toList());

    return PropertyComparisonMatrix(
      properties: properties,
      rows: rows,
    );
  }

  static void _addRow(List<PropertyComparisonRow> rows, String label, List<String> values) {
    final isDiff = values.toSet().length > 1;
    rows.add(PropertyComparisonRow(
      label: label,
      categoryKey: label.toLowerCase().replaceAll(' ', '_'),
      valuesPerProperty: values,
      isHighlightDifference: isDiff,
    ));
  }
}
