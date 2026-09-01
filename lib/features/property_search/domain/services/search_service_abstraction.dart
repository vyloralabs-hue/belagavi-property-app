import '../entities/search_entities.dart';
import '../../../property/domain/entities/property_entities.dart';

/// Keyset / Cursor Pagination metadata for crore-scale search operations
class SearchCursor {
  final String? nextCursor;
  final String? prevCursor;
  final bool hasMore;
  final int totalCount;

  const SearchCursor({
    this.nextCursor,
    this.prevCursor,
    this.hasMore = false,
    this.totalCount = 0,
  });
}

/// Search Facets and aggregations for filter count badges
class SearchFacets {
  final Map<String, int> categoryCounts;
  final Map<String, int> localityCounts;
  final Map<String, int> bhkCounts;
  final Map<String, int> priceBandCounts;

  const SearchFacets({
    this.categoryCounts = const {},
    this.localityCounts = const {},
    this.bhkCounts = const {},
    this.priceBandCounts = const {},
  });
}

/// Generalized Search Result with pagination cursor, latency, and engine metadata
class MarketplaceSearchResult {
  final List<PropertyEntity> items;
  final SearchCursor cursor;
  final SearchFacets facets;
  final int executionDurationMs;
  final String searchEngineBackend; // 'postgresql_supabase', 'typesense', 'meilisearch', 'opensearch'

  const MarketplaceSearchResult({
    required this.items,
    required this.cursor,
    this.facets = const SearchFacets(),
    required this.executionDurationMs,
    required this.searchEngineBackend,
  });
}

/// Pluggable Marketplace Search Service Interface
abstract class MarketplaceSearchService {
  /// Execute a parameterized marketplace search query with cursor/offset pagination
  Future<MarketplaceSearchResult> search(SearchQueryEntity query, {String? cursor});

  /// Autocomplete suggestions for locality, builder, keyword
  Future<List<String>> autocomplete(String prefix, {String? city});

  /// Compute facet counts for active filters
  Future<SearchFacets> getFacets(SearchQueryEntity query);

  /// Engine identifier name
  String get engineName;
}
