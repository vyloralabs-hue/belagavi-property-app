import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';
import '../../../../property_search/domain/entities/india_administrative_hierarchy.dart';
import '../../../../property_search/domain/entities/user_location_context.dart';
import '../../../../property_search/domain/services/open_street_map_search_provider.dart';
import '../../../../property_search/presentation/providers/user_location_notifier.dart';
import '../../../../property_search/utils/india_location_directory.dart';

class UniversalLocationSearchModal extends ConsumerStatefulWidget {
  const UniversalLocationSearchModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const UniversalLocationSearchModal(),
    );
  }

  @override
  ConsumerState<UniversalLocationSearchModal> createState() =>
      _UniversalLocationSearchModalState();
}

class _UniversalLocationSearchModalState
    extends ConsumerState<UniversalLocationSearchModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final OpenStreetMapSearchProvider _geocoder = OpenStreetMapSearchProvider();

  Timer? _debounceTimer;
  List<LocationCandidate> _suggestions = const [];
  bool _isSearching = false;

  // Cascading hierarchy selection state
  IndiaState? _selectedState;
  IndiaDistrict? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);

    // Default tab based on current active mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentMode = ref.read(userLocationNotifierProvider).current.mode;
      switch (currentMode) {
        case DiscoveryLocationMode.nearMe:
          _tabController.index = 0;
        case DiscoveryLocationMode.chooseLocation:
          _tabController.index = 1;
        case DiscoveryLocationMode.exploreMap:
          _tabController.index = 2;
        case DiscoveryLocationMode.allIndia:
          _tabController.index = 3;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _suggestions = const [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      // 1. Directory Search
      final localResults = IndiaLocationDirectory.search(query);

      // 2. Geocoder live query for street / landmark / road
      final geocodedPlaces = await _geocoder.searchPlaces(query, limit: 5);
      final geocodedCandidates = geocodedPlaces.map((g) {
        return LocationCandidate(
          id: g.id,
          name: g.mainText,
          subtitle: g.secondaryText,
          type: LocationCandidateType.landmark,
          cityName: g.city ?? '',
          stateName: g.state ?? '',
          localityName: g.locality,
          pincode: g.pincode,
          latitude: g.latitude,
          longitude: g.longitude,
        );
      }).toList();

      if (mounted) {
        // Merge & deduplicate
        final merged = [...localResults];
        for (final g in geocodedCandidates) {
          if (!merged.any((m) => m.name.toLowerCase() == g.name.toLowerCase())) {
            merged.add(g);
          }
        }
        setState(() {
          _suggestions = merged;
          _isSearching = false;
        });
      }
    });
  }

  void _onCandidateSelected(LocationCandidate candidate) {
    ref.read(userLocationNotifierProvider.notifier).selectCandidate(candidate);
    Navigator.pop(context);
  }

  void _onCitySelected(
    String cityName, {
    String? stateName,
    String? stateCode,
  }) {
    ref
        .read(userLocationNotifierProvider.notifier)
        .selectCity(cityName, stateName: stateName, stateCode: stateCode);
    Navigator.pop(context);
  }

  void _onAllIndiaSelected() {
    ref.read(userLocationNotifierProvider.notifier).selectAllIndia();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(userLocationNotifierProvider);
    final currentLoc = locationState.current;
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: mediaQuery.viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where are you looking for property?',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select city, locality, area or enter pincode',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 12,
                      color: textS,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 4 Modes Tab Bar ───────────────────────────────────────────────
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppDesignSystem.brandGold,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: textS,
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Near Me'),
                Tab(text: 'Hierarchy'),
                Tab(text: 'Map View'),
                Tab(text: 'All India'),
              ],
              onTap: (idx) {
                if (idx == 3) {
                  _onAllIndiaSelected();
                }
              },
            ),
          ),

          // Search Input
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCol),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(color: textP, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search city, locality, landmark or pincode...',
                hintStyle: TextStyle(color: textS, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppDesignSystem.brandGold,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Results or Popular Locations
          Expanded(
            child: _searchController.text.trim().isNotEmpty
                ? _buildSearchResultsList(textP, textS, cardBg, borderCol)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Mode 1: Near Me
                      _buildNearMeTab(textP, textS, cardBg, borderCol),
                      // Mode 2: Choose Location / Hierarchy
                      _buildHierarchyTab(textP, textS, cardBg, borderCol),
                      // Mode 3: Explore Map Tab
                      _buildExploreMapTab(textP, textS, cardBg, borderCol),
                      // Mode 4: All India
                      _buildDefaultLocationBrowser(
                        currentLoc,
                        locationState.recentLocations,
                        textP,
                        textS,
                        cardBg,
                        borderCol,
                        isDark,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(
    Color textP,
    Color textS,
    Color cardBg,
    Color borderCol,
  ) {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No matching location found',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textP,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching with a city name, locality, or 6-digit Indian pincode.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textS),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) => Divider(color: borderCol, height: 1),
      itemBuilder: (context, index) {
        final candidate = _suggestions[index];
        final Color badgeColor;
        switch (candidate.type) {
          case LocationCandidateType.city:
            badgeColor = const Color(0xFF2563EB);
          case LocationCandidateType.locality:
            badgeColor = const Color(0xFF059669);
          case LocationCandidateType.pincode:
            badgeColor = const Color(0xFFD97706);
          case LocationCandidateType.landmark:
          case LocationCandidateType.area:
            badgeColor = const Color(0xFF7C3AED);
          case LocationCandidateType.state:
            badgeColor = const Color(0xFF4B5563);
          case LocationCandidateType.taluk:
            badgeColor = const Color(0xFF0D9488);
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              candidate.typeLabel,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
          title: Text(
            candidate.name,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: textP,
            ),
          ),
          subtitle: Text(
            candidate.subtitle,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 11.5,
              color: textS,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppDesignSystem.brandGold,
          ),
          onTap: () => _onCandidateSelected(candidate),
        );
      },
    );
  }

  Widget _buildDefaultLocationBrowser(
    UserLocationContext currentLoc,
    List<UserLocationContext> recents,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderCol,
    bool isDark,
  ) {
    return ListView(
      shrinkWrap: true,
      children: [
        // ─── CURRENT LOCATION CARD ─────────────────────────────────────────
        if (currentLoc.hasExplicitSelection) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppDesignSystem.brandGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppDesignSystem.brandGold.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppDesignSystem.brandGold,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Currently Selected',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.brandGold,
                        ),
                      ),
                      Text(
                        currentLoc.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: textP,
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentLoc.localityName != null)
                  TextButton(
                    onPressed: () {
                      ref
                          .read(userLocationNotifierProvider.notifier)
                          .clearLocality();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      'Clear Locality',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppDesignSystem.brandGold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ─── RECENT LOCATIONS ──────────────────────────────────────────────
        if (recents.isNotEmpty) ...[
          Text(
            'Recent Locations',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textP,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recents.map((r) {
              return ActionChip(
                backgroundColor: cardBg,
                avatar: const Icon(
                  Icons.history_rounded,
                  size: 14,
                  color: AppDesignSystem.brandGold,
                ),
                label: Text(
                  r.shortDisplayName,
                  style: TextStyle(fontSize: 12, color: textP),
                ),
                side: BorderSide(color: borderCol),
                onPressed: () {
                  ref
                      .read(userLocationNotifierProvider.notifier)
                      .selectLocation(r);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // ─── LOCALITIES FOR SELECTED CITY ──────────────────────────────────
        if (currentLoc.cityName != null &&
            currentLoc.cityName!.isNotEmpty &&
            !currentLoc.isAllIndia) ...[
          Text(
            'Localities in ${currentLoc.cityName}',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textP,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                IndiaLocationDirectory.getLocalitiesForCity(
                  currentLoc.cityName!,
                ).map((loc) {
                  final isLocSelected = currentLoc.localityName == loc;
                  return ChoiceChip(
                    avatar: Icon(
                      Icons.near_me_rounded,
                      size: 13,
                      color: isLocSelected
                          ? Colors.black
                          : AppDesignSystem.brandGold,
                    ),
                    label: Text(loc, style: const TextStyle(fontSize: 12)),
                    selected: isLocSelected,
                    selectedColor: AppDesignSystem.brandGold,
                    onSelected: (_) {
                      ref
                          .read(userLocationNotifierProvider.notifier)
                          .selectLocality(
                            loc,
                            currentLoc.cityName!,
                            stateName: currentLoc.stateName,
                            stateCode: currentLoc.stateCode,
                          );
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // ─── POPULAR CITIES IN INDIA ───────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Cities in India',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textP,
              ),
            ),
            TextButton(
              onPressed: _onAllIndiaSelected,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text(
                'View All India',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.brandGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All India option chip
            ChoiceChip(
              avatar: const Icon(
                Icons.public_rounded,
                size: 14,
                color: Colors.black,
              ),
              label: const Text('All India'),
              selected: currentLoc.isAllIndia,
              selectedColor: AppDesignSystem.brandGold,
              onSelected: (_) => _onAllIndiaSelected(),
            ),
            ...IndiaLocationDirectory.popularCities.map((city) {
              final cityName = city['name'] as String;
              final stateName = city['state'] as String;
              final stateCode = city['stateCode'] as String?;
              final isSelected =
                  currentLoc.cityName == cityName && !currentLoc.isAllIndia;

              return ChoiceChip(
                avatar: Icon(
                  Icons.location_city_rounded,
                  size: 14,
                  color: isSelected ? Colors.black : AppDesignSystem.brandGold,
                ),
                label: Text(cityName),
                selected: isSelected,
                selectedColor: AppDesignSystem.brandGold,
                onSelected: (selected) {
                  if (selected) {
                    _onCitySelected(
                      cityName,
                      stateName: stateName,
                      stateCode: stateCode,
                    );
                  }
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  // ── Mode 1: Near Me Tab ──────────────────────────────────────────────────
  Widget _buildNearMeTab(
    Color textP,
    Color textS,
    Color cardBg,
    Color borderCol,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppDesignSystem.brandGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppDesignSystem.brandGold.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.my_location_rounded, color: AppDesignSystem.brandGold, size: 36),
              const SizedBox(height: 10),
              Text(
                'Explore Properties Around You',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textP),
              ),
              const SizedBox(height: 4),
              Text(
                'Instant radial discovery within your immediate vicinity',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textS),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Select Radius',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textP),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [5.0, 10.0, 20.0, 50.0, 100.0].map((radius) {
            return ActionChip(
              backgroundColor: cardBg,
              avatar: const Icon(Icons.radar_rounded, size: 16, color: AppDesignSystem.brandGold),
              label: Text('${radius.toInt()} km Radius', style: TextStyle(fontSize: 12, color: textP)),
              side: BorderSide(color: borderCol),
              onPressed: () {
                // Default center: Belagavi / User location
                ref.read(userLocationNotifierProvider.notifier).selectNearMe(
                      latitude: 15.8497,
                      longitude: 74.4977,
                      radiusKm: radius,
                      cityName: 'Belagavi',
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Mode 2: Cascading Hierarchy Tab ──────────────────────────────────────
  Widget _buildHierarchyTab(
    Color textP,
    Color textS,
    Color cardBg,
    Color borderCol,
  ) {
    if (_selectedState == null) {
      // Step 1: Select State
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Step 1: Select State / Union Territory',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textP),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: IndiaAdministrativeHierarchy.allStatesAndUTs.length,
              separatorBuilder: (_, __) => Divider(color: borderCol, height: 1),
              itemBuilder: (context, idx) {
                final s = IndiaAdministrativeHierarchy.allStatesAndUTs[idx];
                return ListTile(
                  dense: true,
                  title: Text(s.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textP)),
                  subtitle: Text(s.isUnionTerritory ? 'Union Territory' : 'State', style: TextStyle(fontSize: 11, color: textS)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  onTap: () => setState(() => _selectedState = s),
                );
              },
            ),
          ),
        ],
      );
    }

    if (_selectedDistrict == null) {
      // Step 2: Select District
      final stateDistricts = IndiaAdministrativeHierarchy.getDistrictsForState(_selectedState!.name);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                onPressed: () => setState(() => _selectedState = null),
              ),
              Expanded(
                child: Text(
                  'Step 2: ${_selectedState!.name} Districts',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textP),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(userLocationNotifierProvider.notifier).selectState(
                        _selectedState!.name,
                        stateCode: _selectedState!.code,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Select Entire State', style: TextStyle(fontSize: 11, color: AppDesignSystem.brandGold)),
              ),
            ],
          ),
          Expanded(
            child: stateDistricts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('No listed districts for ${_selectedState!.name}. Select entire state.', style: TextStyle(color: textS)),
                    ),
                  )
                : ListView.separated(
                    itemCount: stateDistricts.length,
                    separatorBuilder: (_, __) => Divider(color: borderCol, height: 1),
                    itemBuilder: (context, idx) {
                      final d = stateDistricts[idx];
                      return ListTile(
                        dense: true,
                        title: Text(d.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textP)),
                        subtitle: Text('${d.taluks.length} Taluks • ${d.majorCities.length} Cities', style: TextStyle(fontSize: 11, color: textS)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        onTap: () => setState(() => _selectedDistrict = d),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    // Step 3: Select Taluk / City in District
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              onPressed: () => setState(() => _selectedDistrict = null),
            ),
            Expanded(
              child: Text(
                'Step 3: ${_selectedDistrict!.name} Taluks & Cities',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textP),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(userLocationNotifierProvider.notifier).selectDistrict(
                      _selectedDistrict!.name,
                      stateName: _selectedState!.name,
                      stateCode: _selectedState!.code,
                    );
                Navigator.pop(context);
              },
              child: const Text('Entire District', style: TextStyle(fontSize: 11, color: AppDesignSystem.brandGold)),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: [
              if (_selectedDistrict!.taluks.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('TALUKS / TEHSILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textS)),
                ),
                ..._selectedDistrict!.taluks.map((t) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.holiday_village_rounded, size: 18, color: AppDesignSystem.brandGold),
                      title: Text(t, style: TextStyle(fontSize: 13, color: textP)),
                      trailing: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      onTap: () {
                        ref.read(userLocationNotifierProvider.notifier).selectTaluk(
                              t,
                              districtName: _selectedDistrict!.name,
                              stateName: _selectedState!.name,
                              stateCode: _selectedState!.code,
                            );
                        Navigator.pop(context);
                      },
                    )),
              ],
              if (_selectedDistrict!.majorCities.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('CITIES / TOWNS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textS)),
                ),
                ..._selectedDistrict!.majorCities.map((c) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_city_rounded, size: 18, color: AppDesignSystem.brandGold),
                      title: Text(c, style: TextStyle(fontSize: 13, color: textP)),
                      trailing: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      onTap: () {
                        ref.read(userLocationNotifierProvider.notifier).selectCity(
                              c,
                              stateName: _selectedState!.name,
                              stateCode: _selectedState!.code,
                            );
                        Navigator.pop(context);
                      },
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Mode 3: Explore Map Tab ──────────────────────────────────────────────
  Widget _buildExploreMapTab(
    Color textP,
    Color textS,
    Color cardBg,
    Color borderCol,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            children: [
              const Icon(Icons.map_rounded, color: AppDesignSystem.brandGold, size: 36),
              const SizedBox(height: 10),
              Text(
                'Explore via Interactive Map',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textP),
              ),
              const SizedBox(height: 4),
              Text(
                'Drag canvas, zoom, adjust radius, and tap "Search This Area" anywhere in India',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: textS),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(userLocationNotifierProvider.notifier).selectMapArea(
                        centerLatitude: 15.8497,
                        centerLongitude: 74.4977,
                        radiusKm: 10.0,
                        cityName: 'Belagavi',
                      );
                  Navigator.pop(context);
                  context.go('/search');
                },
                icon: const Icon(Icons.explore_rounded, size: 16),
                label: const Text('Open Map Discovery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.brandGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

