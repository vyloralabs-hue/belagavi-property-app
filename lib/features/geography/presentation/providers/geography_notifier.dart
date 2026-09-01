import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/geography_entities.dart';
import '../../domain/repositories/geography_repository.dart';

// ─── Countries Provider ───────────────────────────────────────────────────────
/// Provides all supported countries. Small dataset — safe to cache indefinitely.
final countriesProvider = FutureProvider<List<CountryEntity>>((ref) async {
  final repo = getIt<GeographyRepository>();
  final result = await repo.getCountries();
  return result.fold((failure) => throw Exception(failure.message), (data) => data);
});

// ─── States Provider ──────────────────────────────────────────────────────────
/// Provides states/provinces for a given country code.
/// Keyed by countryCode so different countries have independent cache.
final statesProvider = FutureProvider.family<List<StateEntity>, String>((ref, countryCode) async {
  final repo = getIt<GeographyRepository>();
  final result = await repo.getStates(countryCode: countryCode);
  return result.fold((failure) => throw Exception(failure.message), (data) => data);
});

// ─── Districts Provider ───────────────────────────────────────────────────────
/// Provides districts/counties for a given state ID.
final districtsProvider = FutureProvider.family<List<DistrictEntity>, String>((ref, stateId) async {
  final repo = getIt<GeographyRepository>();
  final result = await repo.getDistricts(stateId);
  return result.fold((failure) => throw Exception(failure.message), (data) => data);
});

// ─── Taluks Provider ──────────────────────────────────────────────────────────
/// Provides taluks/sub-districts for a given district ID.
final taluksProvider = FutureProvider.family<List<TalukEntity>, String>((ref, districtId) async {
  final repo = getIt<GeographyRepository>();
  final result = await repo.getTaluks(districtId);
  return result.fold((failure) => throw Exception(failure.message), (data) => data);
});

// ─── Cities Provider ──────────────────────────────────────────────────────────
/// Provides cities for a given taluk ID.
final citiesProvider = FutureProvider.family<List<CityEntity>, String>((ref, talukId) async {
  final repo = getIt<GeographyRepository>();
  final result = await repo.getCities(talukId);
  return result.fold((failure) => throw Exception(failure.message), (data) => data);
});

// ─── Localities Provider ──────────────────────────────────────────────────────
/// Provides localities/neighborhoods for a given city ID.
final localitiesProvider = FutureProvider.family<List<LocalityEntity>, String>((ref, cityId) async {
  final repo = getIt<GeographyRepository>();
  final result = await repo.getLocalities(cityId);
  return result.fold((failure) => throw Exception(failure.message), (data) => data);
});

// ─── Areas Provider ───────────────────────────────────────────────────────────
/// Provides micro-areas for a given locality ID (6th level).
final areasProvider = FutureProvider.family<List<AreaEntity>, String>((ref, localityId) async {
  final repo = getIt<GeographyRepository>();
  final result = await repo.getAreas(localityId);
  return result.fold((failure) => throw Exception(failure.message), (data) => data);
});

// ─── Locality Search Provider ─────────────────────────────────────────────────
/// Provides locality search results for a query string (bounded, indexed).
final localitySearchProvider = FutureProvider.family<List<LocalityEntity>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  final repo = getIt<GeographyRepository>();
  final result = await repo.searchLocalities(query);
  return result.fold((failure) => [], (data) => data);
});

// ─── Location Notifier ────────────────────────────────────────────────────────
/// Manages cascading location selection state with automatic child invalidation.
/// Selecting a parent level clears all child levels automatically.
class LocationSelectionNotifier extends Notifier<LocationSelection> {
  @override
  LocationSelection build() => const LocationSelection();

  void selectCountry(CountryEntity country) {
    // Clear everything below country when country changes
    state = LocationSelection(country: country);
  }

  void selectState(StateEntity stateEntity) {
    // Clear everything below state when state changes
    state = LocationSelection(
      country: state.country,
      state: stateEntity,
    );
  }

  void selectDistrict(DistrictEntity district) {
    state = LocationSelection(
      country: state.country,
      state: state.state,
      district: district,
    );
  }

  void selectCity(CityEntity city) {
    state = LocationSelection(
      country: state.country,
      state: state.state,
      district: state.district,
      city: city,
    );
  }

  void selectLocality(LocalityEntity locality) {
    state = LocationSelection(
      country: state.country,
      state: state.state,
      district: state.district,
      city: state.city,
      locality: locality,
    );
  }

  void selectArea(AreaEntity area) {
    state = state.withArea(area);
  }

  void reset() {
    state = const LocationSelection();
  }

  void resetToCountry() {
    state = LocationSelection(country: state.country);
  }

  void resetToState() {
    state = LocationSelection(country: state.country, state: state.state);
  }

  void resetToDistrict() {
    state = LocationSelection(country: state.country, state: state.state, district: state.district);
  }
}

final locationSelectionNotifierProvider =
    NotifierProvider<LocationSelectionNotifier, LocationSelection>(LocationSelectionNotifier.new);
