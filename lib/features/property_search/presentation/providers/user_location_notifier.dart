import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/local_storage.dart';
import '../../domain/entities/user_location_context.dart';
import '../providers/property_search_notifier.dart';
import '../../utils/india_location_directory.dart';

class UserLocationState {
  final UserLocationContext current;
  final List<UserLocationContext> recentLocations;
  final bool isLoading;

  const UserLocationState({
    this.current = UserLocationContext.unselected,
    this.recentLocations = const [],
    this.isLoading = false,
  });

  UserLocationState copyWith({
    UserLocationContext? current,
    List<UserLocationContext>? recentLocations,
    bool? isLoading,
  }) {
    return UserLocationState(
      current: current ?? this.current,
      recentLocations: recentLocations ?? this.recentLocations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserLocationNotifier extends Notifier<UserLocationState> {
  static const String _savedLocationKey = 'ph_selected_user_location';
  static const String _recentLocationsKey = 'ph_recent_user_locations';

  LocalStorage? get _storage {
    if (getIt.isRegistered<LocalStorage>()) {
      return getIt<LocalStorage>();
    }
    return null;
  }

  @override
  UserLocationState build() {
    final loadedState = _loadPersistedState();
    return loadedState;
  }

  UserLocationState _loadPersistedState() {
    try {
      final storage = _storage;
      if (storage == null) return const UserLocationState();

      final rawSelected = storage.get(_savedLocationKey);
      UserLocationContext current = UserLocationContext.unselected;

      if (rawSelected != null) {
        if (rawSelected is String && rawSelected.isNotEmpty) {
          final Map<String, dynamic> decoded = jsonDecode(rawSelected);
          current = UserLocationContext.fromJson(decoded);
        } else if (rawSelected is Map) {
          current = UserLocationContext.fromJson(Map<String, dynamic>.from(rawSelected));
        }
      }

      final rawRecents = storage.get(_recentLocationsKey);
      final recentList = <UserLocationContext>[];

      if (rawRecents != null && rawRecents is List) {
        for (final item in rawRecents) {
          try {
            if (item is String) {
              recentList.add(UserLocationContext.fromJson(jsonDecode(item)));
            } else if (item is Map) {
              recentList.add(UserLocationContext.fromJson(Map<String, dynamic>.from(item)));
            }
          } catch (_) {}
        }
      }

      return UserLocationState(
        current: current,
        recentLocations: recentList,
      );
    } catch (e) {
      AppLogger.w('Error loading persisted user location: $e');
      return const UserLocationState();
    }
  }

  Future<void> _persist(UserLocationContext context) async {
    state = state.copyWith(current: context);
    try {
      final storage = _storage;
      if (storage == null) return;

      final encoded = jsonEncode(context.toJson());
      await storage.put(_savedLocationKey, encoded);

      // Add to recents (max 5 distinct)
      if (context.hasExplicitSelection && !context.isAllIndia) {
        final updatedRecents = [
          context,
          ...state.recentLocations.where((r) => r.displayName != context.displayName),
        ].take(5).toList();

        final rawRecentsList = updatedRecents.map((r) => jsonEncode(r.toJson())).toList();
        await storage.put(_recentLocationsKey, rawRecentsList);

        state = state.copyWith(
          current: context,
          recentLocations: updatedRecents,
        );
      }
    } catch (e) {
      AppLogger.w('Error persisting user location: $e');
    }
  }

  void _syncSearch(UserLocationContext newContext) {
    try {
      final searchNotifier = ref.read(propertySearchNotifierProvider.notifier);
      final currentQuery = searchNotifier.currentQuery;

      final updatedQuery = newContext.toSearchQuery(
        category: currentQuery.category,
        type: currentQuery.type,
        purpose: currentQuery.purpose,
        sortBy: currentQuery.sortBy,
        limit: currentQuery.limit,
        offset: 0,
        rawQuery: currentQuery.rawQuery,
      );

      searchNotifier.executeSearch(updatedQuery);
    } catch (e) {
      AppLogger.w('Location sync search note: $e');
    }
  }

  Future<void> selectLocation(UserLocationContext context) async {
    await _persist(context);
    _syncSearch(context);
  }

  Future<void> selectCandidate(LocationCandidate candidate) async {
    final context = candidate.toLocationContext();
    await _persist(context);
    _syncSearch(context);
  }

  Future<void> selectCity(
    String cityName, {
    String? stateName,
    String? stateCode,
  }) async {
    // Resolve alias if applicable
    final resolvedCity = IndiaLocationDirectory.normalizeCityName(cityName);

    String? resolvedState = stateName;
    String? resolvedCode = stateCode;

    if (resolvedState == null || resolvedState.isEmpty) {
      for (final c in IndiaLocationDirectory.popularCities) {
        if (c['name'] == resolvedCity) {
          resolvedState = c['state'] as String?;
          resolvedCode = c['stateCode'] as String?;
          break;
        }
      }
    }

    // Changing city automatically clears old child locality, area, pincode
    final newContext = UserLocationContext(
      countryCode: 'IN',
      countryName: 'India',
      stateCode: resolvedCode,
      stateName: resolvedState,
      cityName: resolvedCity,
      localityName: null,
      areaName: null,
      pincode: null,
      hasExplicitSelection: true,
      isAllIndia: false,
    );

    await _persist(newContext);
    _syncSearch(newContext);
  }

  Future<void> selectLocality(
    String localityName,
    String cityName, {
    String? stateName,
    String? stateCode,
    String? pincode,
  }) async {
    final newContext = UserLocationContext(
      countryCode: 'IN',
      countryName: 'India',
      stateCode: stateCode,
      stateName: stateName,
      cityName: cityName,
      localityName: localityName,
      pincode: pincode,
      hasExplicitSelection: true,
      isAllIndia: false,
    );

    await _persist(newContext);
    _syncSearch(newContext);
  }

  Future<void> selectPincode(
    String pincode, {
    String? localityName,
    String? cityName,
    String? stateName,
    String? stateCode,
  }) async {
    final newContext = UserLocationContext(
      countryCode: 'IN',
      countryName: 'India',
      stateCode: stateCode,
      stateName: stateName,
      cityName: cityName,
      localityName: localityName,
      pincode: pincode,
      hasExplicitSelection: true,
      isAllIndia: false,
    );

    await _persist(newContext);
    _syncSearch(newContext);
  }

  Future<void> selectAllIndia() async {
    const newContext = UserLocationContext.allIndia;
    await _persist(newContext);
    _syncSearch(newContext);
  }

  Future<void> clearLocality() async {
    final newContext = state.current.copyWith(clearLocality: true);
    await _persist(newContext);
    _syncSearch(newContext);
  }

  Future<void> clearLocation() async {
    const newContext = UserLocationContext.unselected;
    await _persist(newContext);
    _syncSearch(newContext);
  }
}

final userLocationNotifierProvider =
    NotifierProvider<UserLocationNotifier, UserLocationState>(
  UserLocationNotifier.new,
);
