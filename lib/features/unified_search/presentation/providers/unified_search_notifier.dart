import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/local_shops/domain/entities/business_entities.dart';
import 'package:belagavi_property/features/local_shops/utils/business_location_resolver.dart';
import 'package:belagavi_property/features/unified_search/domain/entities/unified_search_entity.dart';

class UnifiedSearchState extends Equatable {
  final String query;
  final UnifiedSearchMode mode;
  final List<UnifiedSearchResultEntity> results;
  final List<String> suggestions;
  final ResolvedBusinessLocation activeLocation;
  final bool isLoading;
  final String? errorMessage;

  const UnifiedSearchState({
    this.query = '',
    this.mode = UnifiedSearchMode.all,
    this.results = const [],
    this.suggestions = const [],
    this.activeLocation = const ResolvedBusinessLocation(
      stateId: 'st_karnataka',
      districtId: 'dst_belagavi',
      cityId: 'ct_belagavi',
      localityId: 'loc_tilakwadi',
      displayLabel: 'Tilakwadi, Belagavi, Karnataka',
    ),
    this.isLoading = false,
    this.errorMessage,
  });

  UnifiedSearchState copyWith({
    String? query,
    UnifiedSearchMode? mode,
    List<UnifiedSearchResultEntity>? results,
    List<String>? suggestions,
    ResolvedBusinessLocation? activeLocation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UnifiedSearchState(
      query: query ?? this.query,
      mode: mode ?? this.mode,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      activeLocation: activeLocation ?? this.activeLocation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        query,
        mode,
        results,
        suggestions,
        activeLocation,
        isLoading,
        errorMessage,
      ];
}

final unifiedSearchNotifierProvider =
    NotifierProvider<UnifiedSearchNotifier, UnifiedSearchState>(
  UnifiedSearchNotifier.new,
);

class UnifiedSearchNotifier extends Notifier<UnifiedSearchState> {
  @override
  UnifiedSearchState build() {
    return const UnifiedSearchState();
  }

  void updateQuery(String newQuery) {
    state = state.copyWith(query: newQuery);
    _performDeterministicSearch();
  }

  void setMode(UnifiedSearchMode mode) {
    state = state.copyWith(mode: mode);
    _performDeterministicSearch();
  }

  void updateActiveLocation(String locationInput) {
    final resolved = BusinessLocationResolver.resolve(locationInput);
    state = state.copyWith(activeLocation: resolved);
    _performDeterministicSearch();
  }

  void _performDeterministicSearch() {
    final q = state.query.trim().toLowerCase();
    final now = DateTime.now();

    if (q.isEmpty) {
      state = state.copyWith(results: const [], suggestions: const []);
      return;
    }

    state = state.copyWith(isLoading: true);

    final allResults = <UnifiedSearchResultEntity>[];
    final suggestionsList = <String>[];

    // 1. Direct Location Resolution Suggestion
    if (q.contains('bel') || q.contains('tilak') || q.contains('pune') || q.contains('delhi')) {
      final loc = BusinessLocationResolver.resolve(q);
      allResults.add(UnifiedSearchResultEntity.fromLocation(loc));
      suggestionsList.add('📍 ${loc.displayLabel}');
    }

    // 2. Property Result Simulation
    if (state.mode == UnifiedSearchMode.all || state.mode == UnifiedSearchMode.properties) {
      final sampleProp = PropertyEntity(
        id: 'prop_u1',
        ownerId: 'usr_owner_01',
        title: '3 BHK Villa in Tilakwadi',
        description: 'Luxury 3 BHK independent villa',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.published,
        price: 8500000,
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'First Cross, Tilakwadi',
        pincode: '590006',
        specifications: const PropertySpecificationsEntity(bedrooms: 3, bathrooms: 3),
        createdAt: now,
        updatedAt: now,
      );

      if ('villa in tilakwadi'.contains(q) || 'belagavi'.contains(q) || q.isEmpty) {
        allResults.add(UnifiedSearchResultEntity.fromProperty(sampleProp));
        suggestionsList.add('🏠 Properties in ${sampleProp.locality}');
      }
    }

    // 3. Local Business / Shop Result Simulation
    if (state.mode == UnifiedSearchMode.all || state.mode == UnifiedSearchMode.shops) {
      final sampleShop = BusinessEntity(
        id: 'biz_u1',
        ownerId: 'usr_owner_biz',
        name: 'Belgaum Pipe & Fitting Traders',
        categoryId: 'cat_pipes',
        subcategoryId: 'sub_pvc',
        stateId: 'st_karnataka',
        districtId: 'dst_belagavi',
        cityId: 'ct_belagavi',
        localityId: 'loc_tilakwadi',
        address: '124 Khanapur Road, Tilakwadi',
        phone: '+91 98450 12345',
        description: 'Wholesale PVC & CPVC plumbing pipes',
        openingHours: '09:00 AM - 08:30 PM',
        status: ListingStatus.published,
        isVerified: true,
        createdAt: now,
      );

      if ('pipe'.contains(q) || 'tilakwadi'.contains(q) || 'belgaum'.contains(q)) {
        allResults.add(UnifiedSearchResultEntity.fromBusiness(sampleShop));
        suggestionsList.add('🏪 Pipe Shops in Tilakwadi');
      }
    }

    state = state.copyWith(
      isLoading: false,
      results: allResults,
      suggestions: suggestionsList,
    );
  }
}
