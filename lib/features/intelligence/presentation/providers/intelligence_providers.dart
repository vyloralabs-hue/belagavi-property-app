import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../property/domain/entities/property_entities.dart';
import '../../domain/entities/preference_entities.dart';
import '../../domain/entities/requirement_entities.dart';
import '../../domain/entities/property_watch_entities.dart';
import '../../domain/entities/entitlement_entities.dart';
import '../../domain/repositories/intelligence_repository.dart';
import '../../domain/services/property_match_evaluator.dart';
import '../../data/repositories/intelligence_repository_impl.dart';

final intelligenceRepositoryProvider = Provider<IntelligenceRepository>((ref) {
  return IntelligenceRepositoryImpl();
});

// ─── 1. Preference State & Notifier ──────────────────────────────────────────

class PreferenceState {
  final PropertyPreferenceEntity? preference;
  final bool isLoading;
  final String? error;

  const PreferenceState({
    this.preference,
    this.isLoading = false,
    this.error,
  });

  PreferenceState copyWith({
    PropertyPreferenceEntity? preference,
    bool? isLoading,
    String? error,
  }) {
    return PreferenceState(
      preference: preference ?? this.preference,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PropertyPreferenceNotifier extends StateNotifier<PreferenceState> {
  final IntelligenceRepository _repository;

  PropertyPreferenceNotifier(this._repository) : super(const PreferenceState()) {
    loadPreference();
  }

  Future<void> loadPreference() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pref = await _repository.getPreference();
      state = state.copyWith(preference: pref, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> savePreference(PropertyPreferenceEntity preference) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final saved = await _repository.savePreference(preference);
      state = state.copyWith(preference: saved, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> toggleActive(bool isActive) async {
    if (state.preference == null) return;
    final updated = state.preference!.copyWith(isActive: isActive);
    await savePreference(updated);
  }

  Future<void> resetPreference() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deletePreference();
      state = const PreferenceState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final propertyPreferenceNotifierProvider =
    StateNotifierProvider<PropertyPreferenceNotifier, PreferenceState>((ref) {
  final repo = ref.watch(intelligenceRepositoryProvider);
  return PropertyPreferenceNotifier(repo);
});

// ─── 2. Saved Requirements & Alerts Notifier ─────────────────────────────────

class SavedRequirementsState {
  final List<SavedRequirementEntity> requirements;
  final List<PropertyAlertMatchEntity> matches;
  final bool isLoading;
  final String? error;

  const SavedRequirementsState({
    this.requirements = const [],
    this.matches = const [],
    this.isLoading = false,
    this.error,
  });

  SavedRequirementsState copyWith({
    List<SavedRequirementEntity>? requirements,
    List<PropertyAlertMatchEntity>? matches,
    bool? isLoading,
    String? error,
  }) {
    return SavedRequirementsState(
      requirements: requirements ?? this.requirements,
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SavedRequirementsNotifier extends StateNotifier<SavedRequirementsState> {
  final IntelligenceRepository _repository;

  SavedRequirementsNotifier(this._repository) : super(const SavedRequirementsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reqs = await _repository.getSavedRequirements();
      final matches = await _repository.getAlertMatches();
      state = state.copyWith(requirements: reqs, matches: matches, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> saveRequirement(SavedRequirementEntity req) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.saveRequirement(req);
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      await _repository.updateRequirementActiveStatus(id, isActive);
      state = state.copyWith(
        requirements: state.requirements.map((r) {
          if (r.id == id) return r.copyWith(isActive: isActive);
          return r;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteRequirement(String id) async {
    try {
      await _repository.deleteRequirement(id);
      state = state.copyWith(
        requirements: state.requirements.where((r) => r.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markMatchViewed(String matchId) async {
    try {
      await _repository.markMatchAsViewed(matchId);
      state = state.copyWith(
        matches: state.matches.map((m) {
          if (m.id == matchId) return m.copyWith(isViewed: true);
          return m;
        }).toList(),
      );
    } catch (_) {}
  }
}

final savedRequirementsNotifierProvider =
    StateNotifierProvider<SavedRequirementsNotifier, SavedRequirementsState>((ref) {
  final repo = ref.watch(intelligenceRepositoryProvider);
  return SavedRequirementsNotifier(repo);
});

// ─── 3. Paid Property Watch & Entitlement Notifier ───────────────────────────

class PropertyWatchState {
  final List<PropertyWatchEntity> watches;
  final UserEntitlementEntity? entitlement;
  final bool isLoading;
  final String? error;

  const PropertyWatchState({
    this.watches = const [],
    this.entitlement,
    this.isLoading = false,
    this.error,
  });

  bool get isPaidEntitled => entitlement != null && entitlement!.hasAvailableQuota;

  PropertyWatchState copyWith({
    List<PropertyWatchEntity>? watches,
    UserEntitlementEntity? entitlement,
    bool? isLoading,
    String? error,
  }) {
    return PropertyWatchState(
      watches: watches ?? this.watches,
      entitlement: entitlement ?? this.entitlement,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PropertyWatchNotifier extends StateNotifier<PropertyWatchState> {
  final IntelligenceRepository _repository;

  PropertyWatchNotifier(this._repository) : super(const PropertyWatchState()) {
    loadWatchesAndEntitlement();
  }

  Future<void> loadWatchesAndEntitlement() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entitlement = await _repository.getMonitoringEntitlement();
      final watches = await _repository.getPropertyWatches();
      state = state.copyWith(
        entitlement: entitlement,
        watches: watches,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addWatch(PropertyWatchEntity watch) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final created = await _repository.addPropertyWatch(watch);
      state = state.copyWith(
        watches: [created, ...state.watches],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> deleteWatch(String watchId) async {
    try {
      await _repository.deletePropertyWatch(watchId);
      state = state.copyWith(
        watches: state.watches.where((w) => w.id != watchId).toList(),
      );
      // Refresh entitlement quota
      final ent = await _repository.getMonitoringEntitlement();
      state = state.copyWith(entitlement: ent);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final propertyWatchNotifierProvider =
    StateNotifierProvider<PropertyWatchNotifier, PropertyWatchState>((ref) {
  final repo = ref.watch(intelligenceRepositoryProvider);
  return PropertyWatchNotifier(repo);
});

// ─── 4. Personalized Feed Notifier ("Properties For You") ────────────────────

class PersonalizedFeedState {
  final List<Property> properties;
  final Map<String, MatchEvaluationResult> matchResults;
  final bool isLoading;
  final String? error;

  const PersonalizedFeedState({
    this.properties = const [],
    this.matchResults = const {},
    this.isLoading = false,
    this.error,
  });

  PersonalizedFeedState copyWith({
    List<Property>? properties,
    Map<String, MatchEvaluationResult>? matchResults,
    bool? isLoading,
    String? error,
  }) {
    return PersonalizedFeedState(
      properties: properties ?? this.properties,
      matchResults: matchResults ?? this.matchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PersonalizedFeedNotifier extends StateNotifier<PersonalizedFeedState> {
  final IntelligenceRepository _repository;

  PersonalizedFeedNotifier(this._repository) : super(const PersonalizedFeedState());

  Future<void> loadPersonalizedProperties(PropertyPreferenceEntity preference) async {
    if (!preference.isActive) {
      state = const PersonalizedFeedState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final rawProps = await _repository.getPersonalizedProperties(preference);

      final Map<String, MatchEvaluationResult> results = {};
      final List<Property> matchingProps = [];

      for (final p in rawProps) {
        final res = PropertyMatchEvaluator.evaluatePreference(
          preference: preference,
          property: p,
        );
        if (res.isMatch) {
          results[p.id] = res;
          matchingProps.add(p);
        }
      }

      // Sort by match score descending
      matchingProps.sort((a, b) {
        final scoreA = results[a.id]?.score ?? 0;
        final scoreB = results[b.id]?.score ?? 0;
        return scoreB.compareTo(scoreA);
      });

      state = state.copyWith(
        properties: matchingProps,
        matchResults: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final personalizedFeedNotifierProvider =
    StateNotifierProvider<PersonalizedFeedNotifier, PersonalizedFeedState>((ref) {
  final repo = ref.watch(intelligenceRepositoryProvider);
  return PersonalizedFeedNotifier(repo);
});
