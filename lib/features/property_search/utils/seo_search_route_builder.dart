import '../domain/entities/search_entities.dart';

class SeoSearchRouteBuilder {
  SeoSearchRouteBuilder._();

  /// Constructs canonical SEO search URLs for search engine indexing
  /// e.g. /search/karnataka/belagavi/tilakwadi/3-bhk-apartments-for-sale
  static String buildCanonicalUrl(SearchQueryEntity query) {
    final state = (query.state ?? 'all-states').toLowerCase().replaceAll(' ', '-');
    final city = (query.city ?? 'all-cities').toLowerCase().replaceAll(' ', '-');
    final locality = query.locality?.toLowerCase().replaceAll(' ', '-');
    final category = (query.category?.name ?? 'properties').replaceAll('_', '-');

    if (locality != null && locality.isNotEmpty) {
      return '/search/$state/$city/$locality/$category-for-sale';
    }
    return '/search/$state/$city/$category-for-sale';
  }
}
