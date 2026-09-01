/// Number formatting utilities for Belagavi Property platform
/// All formatting is local — zero API calls, zero AI, zero cost.
class NumberFormatter {
  NumberFormatter._();

  /// Format a raw count into a comma-separated string
  /// e.g. 4850 → "4,850"
  static String formatCount(int count) {
    if (count == 0) return '0';
    final str = count.abs().toString();
    final buffer = StringBuffer();
    final mod = str.length % 3;

    // Handle Indian numbering system for larger numbers (lakhs, crores)
    // Falls back to international for simplicity — can be extended
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  /// Format property count with optional location label
  /// e.g. formatPropertyCount(4850) → "4,850 properties found"
  /// e.g. formatPropertyCount(128, location: 'Belagavi') → "128 properties in Belagavi"
  /// e.g. formatPropertyCount(0) → "No properties found"
  static String formatPropertyCount(int count, {String? location}) {
    if (count == 0) return 'No properties found';
    final formatted = formatCount(count);
    final suffix = count == 1 ? 'property' : 'properties';
    if (location != null && location.isNotEmpty) {
      return '$formatted $suffix in $location';
    }
    return '$formatted $suffix found';
  }

  /// Format a pagination range label
  /// e.g. formatPageRange(0, 20, 4850) → "Showing 1–20 of 4,850 properties"
  /// e.g. formatPageRange(20, 20, 4850) → "Showing 21–40 of 4,850 properties"
  static String formatPageRange(int offset, int pageCount, int totalCount) {
    if (totalCount == 0) return 'No properties found';
    final start = offset + 1;
    final end = (offset + pageCount).clamp(1, totalCount);
    final totalFormatted = formatCount(totalCount);
    final suffix = totalCount == 1 ? 'property' : 'properties';
    return 'Showing $start–$end of $totalFormatted $suffix';
  }

  /// Format price in Indian numbering (Lakhs/Crores)
  /// e.g. 7500000 → "₹75 Lakhs"
  /// e.g. 25000000 → "₹2.5 Cr"
  static String formatPrice(double price, {String currencySymbol = '₹'}) {
    if (price >= 10000000) {
      final crores = price / 10000000;
      return '$currencySymbol${crores.toStringAsFixed(crores == crores.truncateToDouble() ? 0 : 1)} Cr';
    } else if (price >= 100000) {
      final lakhs = price / 100000;
      return '$currencySymbol${lakhs.toStringAsFixed(lakhs == lakhs.truncateToDouble() ? 0 : 1)} L';
    } else if (price >= 1000) {
      final k = price / 1000;
      return '$currencySymbol${k.toStringAsFixed(k == k.truncateToDouble() ? 0 : 1)}K';
    }
    return '$currencySymbol${price.toStringAsFixed(0)}';
  }

  /// Format area with unit
  /// e.g. formatArea(1650, 'sqft') → "1,650 sqft"
  static String formatArea(double area, String unit) {
    return '${formatCount(area.toInt())} $unit';
  }

  /// Format bedroom count
  /// e.g. formatBhk(3) → "3 BHK"
  static String formatBhk(int? bedrooms) {
    if (bedrooms == null) return '';
    return '$bedrooms BHK';
  }
}
