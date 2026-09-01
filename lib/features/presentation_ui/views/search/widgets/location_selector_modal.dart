import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_design_system.dart';
import '../../../../geography/domain/entities/geography_entities.dart';
import '../../../../geography/presentation/providers/geography_notifier.dart';
import '../../../../property_search/domain/entities/search_entities.dart';
import '../../../../property_search/presentation/providers/property_search_notifier.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/localization/localization_provider.dart';
import '../../../../../core/localization/language_selector_modal.dart';

/// Cascading worldwide location selector modal.
/// Supports: Country → State → District → City → Locality → Area
/// Each level loads lazily from the database — no preloading entire world dataset.
class LocationSelectorModal extends ConsumerStatefulWidget {
  const LocationSelectorModal({super.key});

  @override
  ConsumerState<LocationSelectorModal> createState() =>
      _LocationSelectorModalState();
}

class _LocationSelectorModalState extends ConsumerState<LocationSelectorModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  CountryEntity? _selectedCountry;
  StateEntity? _selectedState;
  DistrictEntity? _selectedDistrict;
  CityEntity? _selectedCity;
  LocalityEntity? _selectedLocality;
  AreaEntity? _selectedArea;

  int _activeStep =
      0; // 0=Country, 1=State, 2=District, 3=City, 4=Locality, 5=Area

  static const _steps = [
    'Country',
    'State',
    'District',
    'City',
    'Locality',
    'Area',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _steps.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeStep = _tabController.index);
      }
    });
    // Pre-select India as default country
    _selectedCountry = const CountryEntity(
      code: 'IN',
      name: 'India',
      dialCode: '+91',
      currencyCode: 'INR',
      currencySymbol: '₹',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCountrySelected(CountryEntity country) {
    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _selectedDistrict = null;
      _selectedCity = null;
      _selectedLocality = null;
      _selectedArea = null;
      _activeStep = 1;
    });
    _tabController.animateTo(1);
  }

  void _onStateSelected(StateEntity state) {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _selectedCity = null;
      _selectedLocality = null;
      _selectedArea = null;
      _activeStep = 2;
    });
    _tabController.animateTo(2);
  }

  void _onDistrictSelected(DistrictEntity district) {
    setState(() {
      _selectedDistrict = district;
      _selectedCity = null;
      _selectedLocality = null;
      _selectedArea = null;
      _activeStep = 3;
    });
    _tabController.animateTo(3);
  }

  void _onCitySelected(CityEntity city) {
    setState(() {
      _selectedCity = city;
      _selectedLocality = null;
      _selectedArea = null;
      _activeStep = 4;
    });
    _tabController.animateTo(4);
  }

  void _onLocalitySelected(LocalityEntity locality) {
    setState(() {
      _selectedLocality = locality;
      _selectedArea = null;
      _activeStep = 5;
    });
    _tabController.animateTo(5);
  }

  void _onAreaSelected(AreaEntity area) {
    setState(() => _selectedArea = area);
  }

  void _applyLocation() {
    final currentQuery = ref
        .read(propertySearchNotifierProvider.notifier)
        .currentQuery;
    final updatedQuery = currentQuery.copyWith(
      country: _selectedCountry?.name,
      state: _selectedState?.name,
      district: _selectedDistrict?.name,
      city: _selectedCity?.name,
      locality: _selectedLocality?.name,
      area: _selectedArea?.name,
      offset: 0,
    );
    ref
        .read(propertySearchNotifierProvider.notifier)
        .executeSearch(updatedQuery);
    Navigator.pop(context);
  }

  void _resetLocation() {
    setState(() {
      _selectedCountry = const CountryEntity(
        code: 'IN',
        name: 'India',
        dialCode: '+91',
        currencyCode: 'INR',
        currencySymbol: '₹',
      );
      _selectedState = null;
      _selectedDistrict = null;
      _selectedCity = null;
      _selectedLocality = null;
      _selectedArea = null;
      _activeStep = 0;
    });
    _tabController.animateTo(0);
  }

  String get _selectionBreadcrumb {
    final parts = <String>[];
    if (_selectedCountry != null) parts.add(_selectedCountry!.name);
    if (_selectedState != null) parts.add(_selectedState!.name);
    if (_selectedDistrict != null) parts.add(_selectedDistrict!.name);
    if (_selectedCity != null) parts.add(_selectedCity!.name);
    if (_selectedLocality != null) parts.add(_selectedLocality!.name);
    if (_selectedArea != null) parts.add(_selectedArea!.name);
    return parts.join(' › ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppDesignSystem.brandGold,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.language_rounded,
                    color: AppDesignSystem.primaryNavy,
                  ),
                  tooltip: 'Change Language',
                  onPressed: () => LanguageSelectorModal.show(context),
                ),
                TextButton(
                  onPressed: _resetLocation,
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // ─── Quick Belagavi Localities ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppDesignSystem.brandGold,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'QUICK BELAGAVI LOCALITIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppDesignSystem.brandGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'Tilakwadi',
                          'Hindwadi',
                          'Shahapur',
                          'Khanapur Road',
                          'Sambra',
                          'Udyambag',
                          'Camp',
                          'Mandoli Road',
                          'Kuvempu Nagar',
                          'Angol',
                          'Vadgaon',
                          'Rani Chennamma Circle',
                        ].map((loc) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(
                                loc,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 0.8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCountry = const CountryEntity(
                                    code: 'IN',
                                    name: 'India',
                                    dialCode: '+91',
                                    currencyCode: 'INR',
                                    currencySymbol: '₹',
                                  );
                                  _selectedState = const StateEntity(
                                    id: 'state_ka',
                                    code: 'KA',
                                    name: 'Karnataka',
                                    countryCode: 'IN',
                                  );
                                  _selectedDistrict = const DistrictEntity(
                                    id: 'dist_belagavi',
                                    stateId: 'state_ka',
                                    name: 'Belagavi',
                                    stateCode: 'KA',
                                  );
                                  _selectedCity = const CityEntity(
                                    id: 'city_belagavi',
                                    talukId: 'taluk_belagavi',
                                    name: 'Belagavi',
                                  );
                                  _selectedLocality = LocalityEntity(
                                    id: 'loc_$loc',
                                    cityId: 'city_belagavi',
                                    name: loc,
                                    pincode: '590001',
                                  );
                                });
                                _applyLocation();
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Breadcrumb Trail
          if (_selectionBreadcrumb.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Text(
                _selectionBreadcrumb,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppDesignSystem.brandGold,
            labelColor: const Color(0xFF0F172A),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: _steps.map((s) => Tab(text: s)).toList(),
            onTap: (i) => setState(() => _activeStep = i),
          ),

          const Divider(height: 1),

          // Tab content — lazy loading per level
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CountryTab(
                  onSelected: _onCountrySelected,
                  selected: _selectedCountry,
                ),
                _StateTab(
                  countryCode: _selectedCountry?.code ?? 'IN',
                  onSelected: _onStateSelected,
                  selected: _selectedState,
                ),
                _DistrictTab(
                  stateId: _selectedState?.id,
                  onSelected: _onDistrictSelected,
                  selected: _selectedDistrict,
                ),
                _CityTab(
                  districtId: _selectedDistrict?.id,
                  onSelected: _onCitySelected,
                  selected: _selectedCity,
                ),
                _LocalityTab(
                  cityId: _selectedCity?.id,
                  onSelected: _onLocalitySelected,
                  selected: _selectedLocality,
                ),
                _AreaTab(
                  localityId: _selectedLocality?.id,
                  onSelected: _onAreaSelected,
                  selected: _selectedArea,
                ),
              ],
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDesignSystem.borderRadiusM,
                  ),
                ),
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text(
                  'Search in this Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: _applyLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Country Tab ──────────────────────────────────────────────────────────────
class _CountryTab extends ConsumerWidget {
  final ValueChanged<CountryEntity> onSelected;
  final CountryEntity? selected;
  const _CountryTab({required this.onSelected, this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(countriesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (countries) => _SelectionList<CountryEntity>(
        items: countries,
        labelOf: (c) => '${c.name} (${c.currencySymbol})',
        isSelected: (c) => selected?.code == c.code,
        onTap: onSelected,
      ),
    );
  }
}

// ─── State Tab ────────────────────────────────────────────────────────────────
class _StateTab extends ConsumerWidget {
  final String countryCode;
  final ValueChanged<StateEntity> onSelected;
  final StateEntity? selected;
  const _StateTab({
    required this.countryCode,
    required this.onSelected,
    this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(statesProvider(countryCode));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (states) => _SelectionList<StateEntity>(
        items: states,
        labelOf: (s) => s.isUnionTerritory ? '${s.name} (UT)' : s.name,
        isSelected: (s) => selected?.id == s.id,
        onTap: onSelected,
      ),
    );
  }
}

// ─── District Tab ─────────────────────────────────────────────────────────────
class _DistrictTab extends ConsumerWidget {
  final String? stateId;
  final ValueChanged<DistrictEntity> onSelected;
  final DistrictEntity? selected;
  const _DistrictTab({this.stateId, required this.onSelected, this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stateId == null)
      return const _PromptState(message: 'Select a State first');
    final async = ref.watch(districtsProvider(stateId!));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (districts) => _SelectionList<DistrictEntity>(
        items: districts,
        labelOf: (d) => d.name,
        isSelected: (d) => selected?.id == d.id,
        onTap: onSelected,
      ),
    );
  }
}

// ─── City Tab — loads via taluks ─────────────────────────────────────────────
class _CityTab extends ConsumerWidget {
  final String? districtId;
  final ValueChanged<CityEntity> onSelected;
  final CityEntity? selected;
  const _CityTab({this.districtId, required this.onSelected, this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (districtId == null)
      return const _PromptState(message: 'Select a District first');
    final taluks = ref.watch(taluksProvider(districtId!));
    return taluks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (talukList) {
        if (talukList.isEmpty)
          return const _EmptyState(label: 'No cities found');
        // Load cities for the first taluk — for UX simplicity, merge all taluks' cities
        final firstTaluk = talukList.first;
        final cities = ref.watch(citiesProvider(firstTaluk.id));
        return cities.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(message: e.toString()),
          data: (cityList) => _SelectionList<CityEntity>(
            items: cityList,
            labelOf: (c) => c.isTier1 ? '${c.name} ★' : c.name,
            isSelected: (c) => selected?.id == c.id,
            onTap: onSelected,
          ),
        );
      },
    );
  }
}

// ─── Locality Tab ─────────────────────────────────────────────────────────────
class _LocalityTab extends ConsumerWidget {
  final String? cityId;
  final ValueChanged<LocalityEntity> onSelected;
  final LocalityEntity? selected;
  const _LocalityTab({this.cityId, required this.onSelected, this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cityId == null)
      return const _PromptState(message: 'Select a City first');
    final async = ref.watch(localitiesProvider(cityId!));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (localities) => _SelectionList<LocalityEntity>(
        items: localities,
        labelOf: (l) => '${l.name} — ${l.pincode}',
        isSelected: (l) => selected?.id == l.id,
        onTap: onSelected,
      ),
    );
  }
}

// ─── Area Tab (6th level — optional) ─────────────────────────────────────────
class _AreaTab extends ConsumerWidget {
  final String? localityId;
  final ValueChanged<AreaEntity> onSelected;
  final AreaEntity? selected;
  const _AreaTab({this.localityId, required this.onSelected, this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (localityId == null)
      return const _PromptState(message: 'Select a Locality first');
    final async = ref.watch(areasProvider(localityId!));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
      data: (areas) {
        if (areas.isEmpty) {
          return const _EmptyState(
            label: 'No specific areas — entire locality will be searched',
          );
        }
        return _SelectionList<AreaEntity>(
          items: areas,
          labelOf: (a) => a.name,
          isSelected: (a) => selected?.id == a.id,
          onTap: onSelected,
        );
      },
    );
  }
}

// ─── Shared List Widget ───────────────────────────────────────────────────────
class _SelectionList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) labelOf;
  final bool Function(T) isSelected;
  final void Function(T) onTap;

  const _SelectionList({
    required this.items,
    required this.labelOf,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState(label: 'No options available');
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final selected = isSelected(item);
        return ListTile(
          leading: Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? AppDesignSystem.primaryNavy : Colors.grey,
            size: 20,
          ),
          title: Text(
            labelOf(item),
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? AppDesignSystem.primaryNavy
                  : AppDesignSystem.textPrimary,
            ),
          ),
          trailing: selected
              ? const Icon(
                  Icons.check,
                  color: AppDesignSystem.primaryNavy,
                  size: 18,
                )
              : null,
          onTap: () => onTap(item),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

class _PromptState extends StatelessWidget {
  final String message;
  const _PromptState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_upward,
            size: 48,
            color: AppDesignSystem.brandGold,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppDesignSystem.primaryNavy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: $message', style: const TextStyle(color: Colors.red)),
    );
  }
}
