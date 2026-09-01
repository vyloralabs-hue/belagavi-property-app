/// Global Brand & Localization Configuration
/// Provides scalable configuration for brand identity, location hierarchy,
/// languages, and currency across Pan-India and global expansions.
class AppBrandConfig {
  AppBrandConfig._();

  static const String brandName = 'Belgaum Property';
  static const String brandLegalName = 'Belgaum Property LLP';
  static const String brandTagline = 'Premium. Trusted. Yours.';
  static const String defaultCity = 'Belagavi';
  static const String defaultCurrency = '₹';

  static const List<String> availableLocations = [
    'Belagavi',
    'Hubballi-Dharwad',
    'Bengaluru',
    'Pune',
    'Goa',
    'Pan India',
  ];

  static const List<Map<String, String>> availableLanguages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'KN', 'name': 'ಕನ್ನಡ'},
    {'code': 'MR', 'name': 'मराठी'},
    {'code': 'HI', 'name': 'हिन्दी'},
  ];
}
