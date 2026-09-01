import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_design_system.dart';
import '../../../../property_search/domain/entities/user_location_context.dart';
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
    extends ConsumerState<UniversalLocationSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  List<LocationCandidate> _suggestions = const [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      final results = IndiaLocationDirectory.search(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
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
                : _buildDefaultLocationBrowser(
                    currentLoc,
                    locationState.recentLocations,
                    textP,
                    textS,
                    cardBg,
                    borderCol,
                    isDark,
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
      separatorBuilder: (_, _) => Divider(color: borderCol, height: 1),
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
}
