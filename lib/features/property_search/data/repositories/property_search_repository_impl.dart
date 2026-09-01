import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/property_search_repository.dart';
import '../datasources/property_search_remote_datasource.dart';
import '../../utils/ai_search_query_parser.dart';

@LazySingleton(as: PropertySearchRepository)
class PropertySearchRepositoryImpl extends BaseRepository implements PropertySearchRepository {
  final PropertySearchRemoteDataSource _remoteDataSource;

  PropertySearchRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<SearchResultEntity> searchProperties(SearchQueryEntity query) async {
    return safeCall(() => _remoteDataSource.executeSearch(query));
  }

  @override
  FutureEither<SearchResultEntity> searchWithAI(String naturalLanguagePrompt) async {
    return safeCall(() async {
      final aiIntent = AISearchQueryParser.parsePrompt(naturalLanguagePrompt);
      final rawResult = await _remoteDataSource.executeSearch(aiIntent.extractedQuery);

      return SearchResultEntity(
        properties: rawResult.properties,
        totalCount: rawResult.totalCount,
        hasMore: rawResult.hasMore,
        aiIntent: aiIntent,
      );
    });
  }

  @override
  FutureEither<List<String>> getSearchSuggestions(String query) async {
    return safeCall(() => _remoteDataSource.fetchSuggestions(query));
  }
}
