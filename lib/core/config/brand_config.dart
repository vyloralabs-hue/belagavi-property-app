enum AppBrand { propertyHub, propertyHubIndia, indiaPropertyHub }

class BrandConfig {
  static AppBrand _currentBrand = AppBrand.propertyHub;

  static AppBrand get currentBrand => _currentBrand;

  static void setBrand(AppBrand brand) {
    _currentBrand = brand;
  }

  static String get brandName {
    switch (_currentBrand) {
      case AppBrand.propertyHub:
        return 'Property Hub';
      case AppBrand.propertyHubIndia:
        return 'Property Hub India';
      case AppBrand.indiaPropertyHub:
        return 'India Property Hub';
    }
  }

  static String get legalEntityName {
    return 'BELAGAVI PROPERTY LLP';
  }
}
