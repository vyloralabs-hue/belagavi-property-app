import '../../../../core/utils/typedefs.dart';
import '../entities/search_entities.dart';

abstract class PropertySearchRepository {
  FutureEither<SearchResultEntity> searchProperties(SearchQueryEntity query);

  FutureEither<SearchResultEntity> searchWithAI(String naturalLanguagePrompt);

  FutureEither<List<String>> getSearchSuggestions(String query);
}
