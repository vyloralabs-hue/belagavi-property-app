class SeoSlugGenerator {
  SeoSlugGenerator._();

  /// Converts geography components into clean, canonical SEO URL paths
  /// e.g. generatePath('Karnataka', 'Belagavi', 'Tilakwadi') -> '/karnataka/belagavi/tilakwadi'
  static String generatePath(String state, String district, [String? locality]) {
    final stateSlug = _slugify(state);
    final districtSlug = _slugify(district);
    if (locality != null && locality.isNotEmpty) {
      final localitySlug = _slugify(locality);
      return '/$stateSlug/$districtSlug/$localitySlug';
    }
    return '/$stateSlug/$districtSlug';
  }

  static String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}
