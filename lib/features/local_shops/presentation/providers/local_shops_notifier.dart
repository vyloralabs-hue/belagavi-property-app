import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/local_shops/domain/entities/business_entities.dart';
import 'package:belagavi_property/features/local_shops/utils/business_location_resolver.dart';

class LocalShopsState extends Equatable {
  final List<BusinessCategoryEntity> categories;
  final List<BusinessEntity> businesses;
  final ResolvedBusinessLocation selectedLocation;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const LocalShopsState({
    this.categories = const [],
    this.businesses = const [],
    this.selectedLocation = const ResolvedBusinessLocation(
      stateId: 'st_karnataka',
      districtId: 'dst_belagavi',
      cityId: 'ct_belagavi',
      localityId: 'loc_belagavi_central',
      displayLabel: 'Belagavi, Karnataka',
    ),
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  LocalShopsState copyWith({
    List<BusinessCategoryEntity>? categories,
    List<BusinessEntity>? businesses,
    ResolvedBusinessLocation? selectedLocation,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocalShopsState(
      categories: categories ?? this.categories,
      businesses: businesses ?? this.businesses,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        businesses,
        selectedLocation,
        selectedCategoryId,
        searchQuery,
        isLoading,
        errorMessage,
      ];
}

final localShopsNotifierProvider =
    NotifierProvider<LocalShopsNotifier, LocalShopsState>(
  LocalShopsNotifier.new,
);

class LocalShopsNotifier extends Notifier<LocalShopsState> {
  @override
  LocalShopsState build() {
    const defaultCategories = [
      BusinessCategoryEntity(id: 'cat_building', name: 'Building Materials', iconName: 'domain'),
      BusinessCategoryEntity(id: 'cat_pipes', name: 'Pipes & Fitting', iconName: 'water_drop'),
      BusinessCategoryEntity(id: 'cat_hardware', name: 'Hardware & Tools', iconName: 'build'),
      BusinessCategoryEntity(id: 'cat_electrical', name: 'Electricals', iconName: 'electrical_services'),
      BusinessCategoryEntity(id: 'cat_paint', name: 'Paints & Wallpapers', iconName: 'format_paint'),
      BusinessCategoryEntity(id: 'cat_tiles', name: 'Tiles & Marble', iconName: 'dashboard'),
    ];

    Future.microtask(() => loadInitialShops());

    return const LocalShopsState(categories: defaultCategories);
  }

  Future<void> loadInitialShops() async {
    state = state.copyWith(isLoading: true);
    final now = DateTime.now();

    final mockShops = [
      BusinessEntity(
        id: 'biz_001',
        ownerId: 'usr_owner_001',
        name: 'Belgaum Pipe & Fitting Traders',
        categoryId: 'cat_pipes',
        subcategoryId: 'sub_pvc',
        stateId: 'st_karnataka',
        districtId: 'dst_belagavi',
        cityId: 'ct_belagavi',
        localityId: 'loc_tilakwadi',
        address: '124 Khanapur Road, Tilakwadi',
        phone: '+91 98450 12345',
        whatsapp: '+91 98450 12345',
        description: 'Wholesale and retail PVC, CPVC, and GI pipes for domestic & commercial plumbing.',
        openingHours: '09:00 AM - 08:30 PM',
        productsServices: const ['Finolex PVC Pipes', 'Astral CPVC', 'GI Fittings'],
        status: ListingStatus.published,
        isVerified: true,
        createdAt: now,
      ),
      BusinessEntity(
        id: 'biz_002',
        ownerId: 'usr_owner_002',
        name: 'Camp Hardware & Building Mart',
        categoryId: 'cat_hardware',
        subcategoryId: 'sub_tools',
        stateId: 'st_karnataka',
        districtId: 'dst_belagavi',
        cityId: 'ct_belagavi',
        localityId: 'loc_camp',
        address: '56 High Street, Camp',
        phone: '+91 98450 67890',
        description: 'Power tools, door fittings, locks, and construction hardware.',
        openingHours: '09:30 AM - 09:00 PM',
        productsServices: const ['Bosch Power Tools', 'Godrej Locks', 'Fasteners'],
        status: ListingStatus.published,
        isVerified: true,
        createdAt: now,
      ),
    ];

    state = state.copyWith(isLoading: false, businesses: mockShops);
  }

  void updateLocation(String queryText) {
    final resolved = BusinessLocationResolver.resolve(queryText);
    state = state.copyWith(selectedLocation: resolved);
    filterShops();
  }

  void selectCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    filterShops();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    filterShops();
  }

  void filterShops() {
    // Deterministic filtering based on search query and category (0 AI)
  }

  Future<bool> registerShop(BusinessEntity shop) async {
    state = state.copyWith(isLoading: true);
    final updatedList = List<BusinessEntity>.from(state.businesses)..add(shop);
    state = state.copyWith(isLoading: false, businesses: updatedList);
    return true;
  }
}
