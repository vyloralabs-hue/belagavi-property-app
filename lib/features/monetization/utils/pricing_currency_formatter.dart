class PricingCurrencyFormatter {
  PricingCurrencyFormatter._();

  /// Formats currency based on target country ISO code
  /// e.g. formatPrice(999, 'INR') -> '₹999'
  /// e.g. formatPrice(12, 'USD') -> '$12'
  /// e.g. formatPrice(45, 'AED') -> '45 AED'
  static String formatPrice(double price, {String currencyCode = 'INR'}) {
    if (price == 0) return 'Free';

    final cleanPrice = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    return switch (currencyCode.toUpperCase()) {
      'INR' => '₹$cleanPrice',
      'USD' => '\$$cleanPrice',
      'AED' => '$cleanPrice AED',
      'EUR' => '€$cleanPrice',
      _ => '$currencyCode $cleanPrice',
    };
  }
}
