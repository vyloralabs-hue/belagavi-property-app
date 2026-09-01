import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/local_storage.dart';
import '../../data/datasources/favorite_local_datasource.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/entities/property_entities.dart';

class FavoritesState {
  final List<FavoritePropertyEntity> favorites;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    List<FavoritePropertyEntity>? favorites,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final favoritesNotifierProvider =
    NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<FavoritesState> {
  late final FavoriteLocalDataSource _dataSource;

  @override
  FavoritesState build() {
    _dataSource = FavoriteLocalDataSourceImpl(LocalStorage());
    _loadFavoritesSilently();
    return const FavoritesState(isLoading: true);
  }

  Future<void> _loadFavoritesSilently() async {
    try {
      final list = await _dataSource.getFavorites();
      state = state.copyWith(favorites: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load favorites');
    }
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _dataSource.getFavorites();
      state = state.copyWith(favorites: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load favorites');
    }
  }

  bool isFavorite(String propertyId) {
    return state.favorites.any((f) => f.propertyId == propertyId);
  }

  Future<void> toggleFavorite(PropertyEntity property) async {
    final exists = isFavorite(property.id);
    if (exists) {
      await _dataSource.removeFavorite(property.id);
    } else {
      await _dataSource.addFavorite(property);
    }
    await loadFavorites();
  }

  Future<void> removeFavorite(String propertyId) async {
    await _dataSource.removeFavorite(propertyId);
    await loadFavorites();
  }

  Future<void> clearAll() async {
    await _dataSource.clearFavorites();
    state = state.copyWith(favorites: []);
  }
}
