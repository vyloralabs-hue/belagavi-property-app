class CurrencyFormatter {
  /// Format canonical price according to currency code without baking symbols into database values
  static String format(double amount, {String currencyCode = 'INR'}) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        if (amount >= 10000000) {
          return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
        } else if (amount >= 100000) {
          return '₹${(amount / 100000).toStringAsFixed(1)} L';
        } else if (amount >= 1000) {
          return '₹${(amount / 1000).toStringAsFixed(0)} K';
        }
        return '₹${amount.round()}';

      case 'USD':
        return '\$${amount.toStringAsFixed(0)}';

      case 'AED':
        return 'AED ${amount.toStringAsFixed(0)}';

      default:
        return '$currencyCode ${amount.toStringAsFixed(0)}';
    }
  }
}

class AreaUnitConverter {
  /// Standardized conversions to square feet baseline
  static const Map<String, double> _toSqFtMultipliers = {
    'sqft': 1.0,
    'sqm': 10.7639,
    'sqyd': 9.0,
    'gunta': 1089.0, // Karnataka standard (1 Gunta = 1089 Sq Ft = 1/40th acre)
    'acre': 43560.0,
    'hectare': 107639.0,
  };

  /// Convert an area from one unit to another
  static double convert({
    required double area,
    required String fromUnit,
    required String toUnit,
  }) {
    final fromLower = fromUnit.toLowerCase().trim();
    final toLower = toUnit.toLowerCase().trim();

    if (fromLower == toLower) return area;

    final multiplierFrom = _toSqFtMultipliers[fromLower];
    final multiplierTo = _toSqFtMultipliers[toLower];

    if (multiplierFrom == null || multiplierTo == null) {
      return area; // Fallback unchanged if unknown unit
    }

    final inSqFt = area * multiplierFrom;
    return inSqFt / multiplierTo;
  }
}
