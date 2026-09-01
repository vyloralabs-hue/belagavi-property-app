import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../data/datasources/property_search_remote_datasource.dart';
import '../../data/repositories/property_search_repository_impl.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/property_search_repository.dart';

sealed class PropertySearchState extends Equatable {
  const PropertySearchState();

  @override
  List<Object?> get props => [];
}

class PropertySearchInitial extends PropertySearchState {
  const PropertySearchInitial();
}

class PropertySearchLoading extends PropertySearchState {
  const PropertySearchLoading();
}

class PropertySearchSuccess extends PropertySearchState {
  final SearchResultEntity result;
  final SearchQueryEntity currentQuery;
  final bool isLoadingMore;

  const PropertySearchSuccess(
    this.result, {
    this.currentQuery = const SearchQueryEntity(),
    this.isLoadingMore = false,
  });

  PropertySearchSuccess copyWith({
    SearchResultEntity? result,
    SearchQueryEntity? currentQuery,
    bool? isLoadingMore,
  }) {
    return PropertySearchSuccess(
      result ?? this.result,
      currentQuery: currentQuery ?? this.currentQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [result, currentQuery, isLoadingMore];
}

class PropertySearchError extends PropertySearchState {
  final String message;
  final SearchQueryEntity? lastQuery;

  const PropertySearchError(this.message, {this.lastQuery});

  @override
  List<Object?> get props => [message, lastQuery];
}

final propertySearchNotifierProvider =
    NotifierProvider<PropertySearchNotifier, PropertySearchState>(
  PropertySearchNotifier.new,
);

class PropertySearchNotifier extends Notifier<PropertySearchState> {
  PropertySearchRepository get _repository {
    if (getIt.isRegistered<PropertySearchRepository>()) {
      return getIt<PropertySearchRepository>();
    }
    final supabase = getIt.isRegistered<SupabaseService>() ? getIt<SupabaseService>() : SupabaseService();
    return PropertySearchRepositoryImpl(PropertySearchRemoteDataSourceImpl(supabase));
  }
  SearchQueryEntity _currentQuery = const SearchQueryEntity();

  SearchQueryEntity get currentQuery => _currentQuery;

  @override
  PropertySearchState build() {
    return const PropertySearchInitial();
  }

  Future<void> executeSearch(SearchQueryEntity query) async {
    _currentQuery = query;
    state = const PropertySearchLoading();
    final result = await _repository.searchProperties(query);
    result.fold(
      (failure) => state = PropertySearchError(failure.message, lastQuery: query),
      (data) => state = PropertySearchSuccess(data, currentQuery: query),
    );
  }

  Future<void> fetchNextPage() async {
    final currentState = state;
    if (currentState is! PropertySearchSuccess) return;
    if (!currentState.result.hasMore || currentState.isLoadingMore) return;

    state = currentState.copyWith(isLoadingMore: true);
    final nextPageQuery = _currentQuery.copyWith(
      offset: currentState.result.offset + currentState.result.limit,
    );

    final result = await _repository.searchProperties(nextPageQuery);
    result.fold(
      (failure) => state = currentState.copyWith(isLoadingMore: false),
      (newData) {
        final combinedProperties = [...currentState.result.properties, ...newData.properties];
        final updatedResult = SearchResultEntity(
          properties: combinedProperties,
          totalCount: newData.totalCount,
          limit: newData.limit,
          offset: nextPageQuery.offset,
          hasMore: newData.hasMore,
          aiIntent: currentState.result.aiIntent,
        );
        _currentQuery = nextPageQuery;
        state = PropertySearchSuccess(
          updatedResult,
          currentQuery: nextPageQuery,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<void> executeAISearch(String prompt) async {
    state = const PropertySearchLoading();
    final result = await _repository.searchWithAI(prompt);
    result.fold(
      (failure) => state = PropertySearchError(failure.message),
      (data) {
        _currentQuery = data.aiIntent?.extractedQuery ?? const SearchQueryEntity();
        state = PropertySearchSuccess(data, currentQuery: _currentQuery);
      },
    );
  }

  void resetFilters() {
    _currentQuery = const SearchQueryEntity();
    executeSearch(_currentQuery);
  }
}
