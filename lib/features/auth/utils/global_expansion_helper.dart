class GlobalExpansionHelper {
  GlobalExpansionHelper._();

  /// Formats international phone numbers to standardized E.164 string format
  /// e.g. formatE164('9876543210', 'IN') -> '+919876543210'
  /// e.g. formatE164('501234567', 'AE') -> '+971501234567'
  static String formatE164(String phoneDigits, {String countryCode = 'IN'}) {
    final cleanDigits = phoneDigits.replaceAll(RegExp(r'\D'), '');
    final prefix = switch (countryCode.toUpperCase()) {
      'IN' => '+91',
      'US' => '+1',
      'AE' => '+971',
      'GB' => '+44',
      _ => '+91',
    };

    if (cleanDigits.startsWith(prefix.replaceAll('+', ''))) {
      return '+$cleanDigits';
    }
    return '$prefix$cleanDigits';
  }
}
