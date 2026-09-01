import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/saved_search_entity.dart';
import '../../domain/entities/search_entities.dart';

abstract class SavedSearchLocalDataSource {
  Future<List<SavedSearchEntity>> getSavedSearches();
  Future<SavedSearchEntity> saveSearch(String title, SearchQueryEntity query);
  Future<SavedSearchEntity> updateSearch(String id, String title, SearchQueryEntity query);
  Future<void> deleteSearch(String id);
  Future<SavedSearchEntity?> toggleActive(String id, bool isActive);
}

@LazySingleton(as: SavedSearchLocalDataSource)
class SavedSearchLocalDataSourceImpl implements SavedSearchLocalDataSource {
  static const String _savedSearchesKey = 'user_saved_searches_v1';
  final LocalStorage _localStorage;

  SavedSearchLocalDataSourceImpl(this._localStorage);

  @override
  Future<List<SavedSearchEntity>> getSavedSearches() async {
    try {
      final rawData = _localStorage.get(_savedSearchesKey);
      if (rawData == null) return [];

      final List<dynamic> jsonList = rawData is String ? jsonDecode(rawData) : rawData;
      return jsonList
          .map((item) => SavedSearchEntity.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      AppLogger.w('Failed to load local saved searches: $e');
      return [];
    }
  }

  @override
  Future<SavedSearchEntity> saveSearch(String title, SearchQueryEntity query) async {
    final list = await getSavedSearches();
    final newId = 'saved_search_${DateTime.now().millisecondsSinceEpoch}';
    final entity = SavedSearchEntity(
      id: newId,
      title: title,
      query: query,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updatedList = [...list, entity];
    await _saveList(updatedList);
    return entity;
  }

  @override
  Future<SavedSearchEntity> updateSearch(String id, String title, SearchQueryEntity query) async {
    final list = await getSavedSearches();
    final index = list.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Saved search with id $id not found');
    }

    final updated = list[index].copyWith(title: title, query: query);
    list[index] = updated;
    await _saveList(list);
    return updated;
  }

  @override
  Future<void> deleteSearch(String id) async {
    final list = await getSavedSearches();
    final updatedList = list.where((s) => s.id != id).toList();
    await _saveList(updatedList);
  }

  @override
  Future<SavedSearchEntity?> toggleActive(String id, bool isActive) async {
    final list = await getSavedSearches();
    final index = list.indexWhere((s) => s.id == id);
    if (index == -1) return null;

    final updated = list[index].copyWith(isActive: isActive);
    list[index] = updated;
    await _saveList(list);
    return updated;
  }

  Future<void> _saveList(List<SavedSearchEntity> list) async {
    final jsonList = list.map((s) => s.toJson()).toList();
    await _localStorage.put(_savedSearchesKey, jsonEncode(jsonList));
  }
}
