import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/local_storage.dart';
import '../../data/datasources/saved_search_local_datasource.dart';
import '../../domain/entities/saved_search_entity.dart';
import '../../domain/entities/search_entities.dart';

class SavedSearchState {
  final List<SavedSearchEntity> savedSearches;
  final bool isLoading;
  final String? errorMessage;

  const SavedSearchState({
    this.savedSearches = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SavedSearchState copyWith({
    List<SavedSearchEntity>? savedSearches,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SavedSearchState(
      savedSearches: savedSearches ?? this.savedSearches,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final savedSearchNotifierProvider =
    NotifierProvider<SavedSearchNotifier, SavedSearchState>(
  SavedSearchNotifier.new,
);

class SavedSearchNotifier extends Notifier<SavedSearchState> {
  late final SavedSearchLocalDataSource _dataSource;

  @override
  SavedSearchState build() {
    _dataSource = SavedSearchLocalDataSourceImpl(LocalStorage());
    _loadSavedSearchesSilently();
    return const SavedSearchState(isLoading: true);
  }

  Future<void> _loadSavedSearchesSilently() async {
    try {
      final list = await _dataSource.getSavedSearches();
      state = state.copyWith(savedSearches: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load saved searches');
    }
  }

  Future<void> loadSavedSearches() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _dataSource.getSavedSearches();
      state = state.copyWith(savedSearches: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load saved searches');
    }
  }

  Future<SavedSearchEntity?> saveCurrentQuery(String title, SearchQueryEntity query) async {
    try {
      final item = await _dataSource.saveSearch(title, query);
      await loadSavedSearches();
      return item;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save search');
      return null;
    }
  }

  Future<void> updateSavedSearch(String id, String title, SearchQueryEntity query) async {
    try {
      await _dataSource.updateSearch(id, title, query);
      await loadSavedSearches();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update saved search');
    }
  }

  Future<void> deleteSavedSearch(String id) async {
    try {
      await _dataSource.deleteSearch(id);
      await loadSavedSearches();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete saved search');
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      await _dataSource.toggleActive(id, isActive);
      await loadSavedSearches();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update saved search status');
    }
  }
}
