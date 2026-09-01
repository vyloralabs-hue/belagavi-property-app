import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../property/data/models/property_models.dart';
import '../../../property/domain/entities/property_entities.dart';
import '../../domain/entities/favorite_entity.dart';

abstract class FavoriteLocalDataSource {
  Future<List<FavoritePropertyEntity>> getFavorites();
  Future<bool> isFavorite(String propertyId);
  Future<void> addFavorite(PropertyEntity property);
  Future<void> removeFavorite(String propertyId);
  Future<void> clearFavorites();
}

@LazySingleton(as: FavoriteLocalDataSource)
class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  static const String _favoritesKey = 'user_local_favorites_v1';
  final LocalStorage _localStorage;

  FavoriteLocalDataSourceImpl(this._localStorage);

  @override
  Future<List<FavoritePropertyEntity>> getFavorites() async {
    try {
      final rawData = _localStorage.get(_favoritesKey);
      if (rawData == null) return [];

      final List<dynamic> jsonList = rawData is String ? jsonDecode(rawData) : rawData;
      return jsonList.map((item) {
        final map = Map<String, dynamic>.from(item);
        final propMap = Map<String, dynamic>.from(map['property']);
        return FavoritePropertyEntity(
          id: map['id'] ?? map['propertyId'],
          propertyId: map['propertyId'],
          property: PropertyModel.fromJson(propMap),
          addedAt: map['addedAt'] != null
              ? DateTime.parse(map['addedAt'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      AppLogger.w('Failed to load local favorites: $e');
      return [];
    }
  }

  @override
  Future<bool> isFavorite(String propertyId) async {
    final list = await getFavorites();
    return list.any((f) => f.propertyId == propertyId);
  }

  @override
  Future<void> addFavorite(PropertyEntity property) async {
    final list = await getFavorites();
    if (list.any((f) => f.propertyId == property.id)) return; // Prevent duplicate

    final newFavorite = FavoritePropertyEntity(
      id: 'fav_${property.id}',
      propertyId: property.id,
      property: property,
      addedAt: DateTime.now(),
    );

    final updatedList = [...list, newFavorite];
    await _saveList(updatedList);
  }

  @override
  Future<void> removeFavorite(String propertyId) async {
    final list = await getFavorites();
    final updatedList = list.where((f) => f.propertyId != propertyId).toList();
    await _saveList(updatedList);
  }

  @override
  Future<void> clearFavorites() async {
    await _localStorage.delete(_favoritesKey);
  }

  Future<void> _saveList(List<FavoritePropertyEntity> list) async {
    final jsonList = list.map((f) => f.toJson()).toList();
    await _localStorage.put(_favoritesKey, jsonEncode(jsonList));
  }
}
