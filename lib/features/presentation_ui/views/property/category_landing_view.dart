import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/utils/number_formatter.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/favorites_notifier.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/user_location_context.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/property_search_notifier.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/user_location_notifier.dart';
import 'package:belagavi_property/features/presentation_ui/views/search/widgets/universal_location_search_modal.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/property/presentation/widgets/app_property_image.dart';

/// Dedicated Category Landing Page
/// Supports Residential, Plots/Layouts, Commercial, and Raw Land with mandatory top List Property CTA
class CategoryLandingView extends ConsumerStatefulWidget {
  final String categoryKey;

  const CategoryLandingView({super.key, required this.categoryKey});

  @override
  ConsumerState<CategoryLandingView> createState() =>
      _CategoryLandingViewState();
}

class _CategoryLandingViewState extends ConsumerState<CategoryLandingView> {
  String _selectedSubFilter = 'All';
  String _selectedSort = 'newest';

  String get _selectedCity =>
      ref.read(userLocationNotifierProvider).current.shortDisplayName;

  PropertyCategory get _category {
    final key = widget.categoryKey.toLowerCase();
    if (key.contains('plot')) return PropertyCategory.plotLand;
    if (key.contains('commercial')) return PropertyCategory.commercial;
    if (key.contains('land') || key.contains('raw'))
      return PropertyCategory.land;
    return PropertyCategory.residential;
  }

  String _categoryTitle(UserLocationContext loc) {
    return loc.categoryHeading(_category);
  }

  String get _categoryDisplayName {
    switch (_category) {
      case PropertyCategory.residential:
        return 'Residential Properties';
      case PropertyCategory.plotLand:
        return 'Plots & Layouts';
      case PropertyCategory.commercial:
        return 'Commercial Properties';
      case PropertyCategory.land:
        return 'Land Listings';
      default:
        return 'Properties';
    }
  }

  String get _categorySubtitle {
    switch (_category) {
      case PropertyCategory.residential:
        return 'Verified apartments, villas, independent houses & penthouses';
      case PropertyCategory.plotLand:
        return 'BUDA approved, NA converted residential & commercial plots';
      case PropertyCategory.commercial:
        return 'Prime retail showrooms, corporate offices, shops & warehouses';
      case PropertyCategory.land:
        return 'Agricultural acreage, farmhouse plots & industrial land with clear RTC';
      default:
        return 'Explore verified property listings';
    }
  }

  List<String> get _subFilters {
    switch (_category) {
      case PropertyCategory.residential:
        return const [
          'All',
          'For Sale',
          'For Rent',
          'Apartment',
          'Villa',
          'Independent House',
          '2 BHK',
          '3+ BHK',
        ];
      case PropertyCategory.plotLand:
        return const [
          'All',
          'Residential Plot',
          'Commercial Plot',
          'BUDA Approved',
          'NA Converted',
          'Gated Layout',
          'Corner Plot',
        ];
      case PropertyCategory.commercial:
        return const [
          'All',
          'Showroom',
          'Office',
          'Shop',
          'Warehouse',
          'For Sale',
          'For Lease',
        ];
      case PropertyCategory.land:
        return const [
          'All',
          'Agricultural',
          'Farmhouse Land',
          'Industrial Land',
          'Canal Water',
          'Black Soil',
          '5+ Acres',
        ];
      default:
        return const ['All', 'For Sale', 'For Rent'];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties();
    });
  }

  void _loadProperties() {
    final locationContext = ref.read(userLocationNotifierProvider).current;
    final query = locationContext.toSearchQuery(
      category: _category,
      sortBy: _selectedSort,
    );
    ref.read(propertySearchNotifierProvider.notifier).executeSearch(query);
  }

  void _openListPropertyWizard() {
    final catParam = switch (_category) {
      PropertyCategory.residential => 'residential',
      PropertyCategory.plotLand => 'plotLand',
      PropertyCategory.commercial => 'commercial',
      PropertyCategory.land => 'land',
      _ => 'residential',
    };
    final target = '/add-property?category=$catParam';
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
    if (!isLoggedIn) {
      context.push('/auth?redirect=${Uri.encodeComponent(target)}');
      return;
    }
    context.push(target);
  }

  void _showChangeLocationSheet(BuildContext context) {
    UniversalLocationSearchModal.show(context);
  }

  String get _categoryListCtaText {
    switch (_category) {
      case PropertyCategory.residential:
        return '+ List Residential Property';
      case PropertyCategory.plotLand:
        return '+ List Plot / Layout';
      case PropertyCategory.commercial:
        return '+ List Commercial Property';
      case PropertyCategory.land:
        return '+ List Land';
      default:
        return '+ List Your Property';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    final locationState = ref.watch(userLocationNotifierProvider);
    final searchState = ref.watch(propertySearchNotifierProvider);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          _categoryTitle(locationState.current),
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textP,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppDesignSystem.brandGold,
            ),
            onPressed: () =>
                context.push('/search?category=${widget.categoryKey}'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderCol, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // ─── TOP MANDATORY BANNER WITH "LIST YOUR PROPERTY" CTA ───────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceBg,
              border: Border(bottom: BorderSide(color: borderCol, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Mandatory prominent full-width List Property CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openListPropertyWizard,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                    label: Text(
                      _categoryListCtaText,
                      style: const TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.brandGold,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Compact Location & Sort discovery controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: () => _showChangeLocationSheet(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF131922)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppDesignSystem.brandGold,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  locationState.current.shortDisplayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppDesignSystem.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textP,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort Dropdown
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF131922)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderCol),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isDense: true,
                            isExpanded: true,
                            value: _selectedSort,
                            icon: const Icon(
                              Icons.sort_rounded,
                              size: 16,
                              color: AppDesignSystem.brandGold,
                            ),
                            dropdownColor: surfaceBg,
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: textP,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'newest',
                                child: Text('Newest'),
                              ),
                              DropdownMenuItem(
                                value: 'price_asc',
                                child: Text('Price: Low'),
                              ),
                              DropdownMenuItem(
                                value: 'price_desc',
                                child: Text('Price: High'),
                              ),
                              DropdownMenuItem(
                                value: 'area_asc',
                                child: Text('Area: Low'),
                              ),
                              DropdownMenuItem(
                                value: 'area_desc',
                                child: Text('Area: High'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSort = val);
                                _loadProperties();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 3. Sub-Filters Horizontal Scroll
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _subFilters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final filter = _subFilters[idx];
                      final isSelected = _selectedSubFilter == filter;
                      return ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? Colors.black : textP,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedSubFilter = filter);
                          }
                        },
                        selectedColor: AppDesignSystem.brandGold,
                        backgroundColor: isDark
                            ? const Color(0xFF131922)
                            : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppDesignSystem.brandGold
                                : borderCol,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── PROPERTY FEED ────────────────────────────────────────────────
          Expanded(
            child: switch (searchState) {
              PropertySearchLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppDesignSystem.brandGold,
                ),
              ),
              PropertySearchError(:final message) => _buildErrorState(
                context,
                message,
              ),
              PropertySearchSuccess(:final result) => _buildPropertiesList(
                context,
                result.properties,
              ),
              _ => const Center(
                child: CircularProgressIndicator(
                  color: AppDesignSystem.brandGold,
                ),
              ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    // Sanitize message: never show raw internal exception strings
    String cleanMessage =
        'Unable to connect right now. Check your internet connection and try again.';
    if (message.isNotEmpty &&
        !message.contains('SocketException') &&
        !message.contains('Failed host lookup') &&
        !message.contains('ClientException') &&
        !message.contains('http') &&
        !message.contains('supabase')) {
      cleanMessage = message;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Listings',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textP,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cleanMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 13,
                color: textS,
              ),
            ),
            const SizedBox(height: 24),
            // Growth tool CTA inside error state
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Text(
                    'Have a property to list in $_selectedCity?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openListPropertyWizard,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                      label: Text(
                        _categoryListCtaText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadProperties,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesList(
    BuildContext context,
    List<PropertyEntity> properties,
  ) {
    final filtered = properties.where((p) {
      if (_selectedSubFilter == 'All') return true;
      final sf = _selectedSubFilter.toLowerCase();
      final lt = (p.features['listingType'] ?? 'FOR_SALE')
          .toString()
          .toUpperCase();
      if (sf == 'for sale') return lt == 'FOR_SALE';
      if (sf == 'for rent' || sf == 'for lease') return lt != 'FOR_SALE';
      if (sf == 'apartment') return p.type == PropertySubtype.apartment;
      if (sf == 'villa') return p.type == PropertySubtype.villa;
      if (sf == 'independent house')
        return p.type == PropertySubtype.independentHouse;
      if (sf == '2 bhk') return p.specifications.bedrooms == 2;
      if (sf == '3+ bhk') return (p.specifications.bedrooms ?? 0) >= 3;
      if (sf == 'residential plot')
        return p.type == PropertySubtype.residentialPlot;
      if (sf == 'commercial plot')
        return p.type == PropertySubtype.commercialPlot;
      if (sf == 'buda approved' || sf == 'na converted') {
        return p.specifications.isNaApproved == true ||
            p.features['isNaConverted'] == true;
      }
      if (sf == 'gated layout') return p.features['isGatedLayout'] == true;
      if (sf == 'corner plot') return p.features['isCornerPlot'] == true;
      if (sf == 'agricultural')
        return p.type == PropertySubtype.agriculturalLand;
      return true;
    }).toList();

    // Client-side sorting application
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'price_asc':
          return a.price.compareTo(b.price);
        case 'price_desc':
          return b.price.compareTo(a.price);
        case 'area_asc':
          final areaA =
              a.specifications.carpetArea ?? a.specifications.plotArea ?? 0;
          final areaB =
              b.specifications.carpetArea ?? b.specifications.plotArea ?? 0;
          return areaA.compareTo(areaB);
        case 'area_desc':
          final areaA =
              a.specifications.carpetArea ?? a.specifications.plotArea ?? 0;
          final areaB =
              b.specifications.carpetArea ?? b.specifications.plotArea ?? 0;
          return areaB.compareTo(areaA);
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    if (filtered.isEmpty) {
      final loc = ref.watch(userLocationNotifierProvider).current;
      return _buildEmptyState(context, loc);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final prop = filtered[index];
        return _buildCategoryPropertyCard(context, prop);
      },
    );
  }

  // ─── ACTIONABLE CALM EMPTY STATE (ZERO RESULTS != ERROR) ─────────────────
  Widget _buildEmptyState(BuildContext context, UserLocationContext loc) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    final locName = loc.hasExplicitSelection
        ? (loc.isAllIndia ? 'in India' : 'in ${loc.shortDisplayName}')
        : '';

    final emptyTitle = switch (_category) {
      PropertyCategory.residential =>
        locName.isNotEmpty
            ? 'No Residential Properties Yet $locName'
            : 'No Residential Properties Yet',
      PropertyCategory.plotLand =>
        locName.isNotEmpty
            ? 'No Plots & Layouts Yet $locName'
            : 'No Plots & Layouts Yet',
      PropertyCategory.commercial =>
        locName.isNotEmpty
            ? 'No Commercial Properties Yet $locName'
            : 'No Commercial Properties Yet',
      PropertyCategory.land =>
        locName.isNotEmpty
            ? 'No Land Listings Yet $locName'
            : 'No Land Listings Yet',
      _ =>
        locName.isNotEmpty ? 'No Properties Yet $locName' : 'No Properties Yet',
    };

    final categoryName = switch (_category) {
      PropertyCategory.residential => 'residential',
      PropertyCategory.plotLand => 'plot and layout',
      PropertyCategory.commercial => 'commercial',
      PropertyCategory.land => 'land',
      _ => 'property',
    };

    final locSubtitle = loc.hasExplicitSelection
        ? (loc.isAllIndia ? 'in India' : 'in ${loc.shortDisplayName}')
        : 'in this location';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(color: AppDesignSystem.brandGold, width: 2),
              ),
              child: const Icon(
                Icons.holiday_village_rounded,
                size: 36,
                color: AppDesignSystem.brandGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textP,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'There are no $categoryName listings available $locSubtitle right now.\nHave a property here?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 13,
                color: textS,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openListPropertyWizard,
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.black,
                  size: 18,
                ),
                label: Text(
                  _categoryListCtaText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.brandGold,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showChangeLocationSheet(context),
                  icon: const Icon(Icons.location_on_rounded, size: 14),
                  label: const Text('Change Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppDesignSystem.brandGold,
                    side: const BorderSide(color: AppDesignSystem.brandGold),
                  ),
                ),
                if (_selectedSubFilter != 'All')
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _selectedSubFilter = 'All'),
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 14),
                    label: const Text('Clear Filter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textP,
                      side: BorderSide(
                        color: AppDesignSystem.borderCol(context),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── CATEGORY SPECIFIC PROPERTY CARD ──────────────────────────────────────
  Widget _buildCategoryPropertyCard(BuildContext context, PropertyEntity prop) {
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final isSaved = ref.watch(
      favoritesNotifierProvider.select(
        (s) => s.favorites.any((f) => f.propertyId == prop.id),
      ),
    );

    final coverPhoto = prop.mediaList.isNotEmpty
        ? prop.mediaList
              .firstWhere((m) => m.isCover, orElse: () => prop.mediaList.first)
              .mediaUrl
        : '';

    final listingTypeStr = (prop.features['listingType'] ?? 'FOR_SALE')
        .toString()
        .replaceAll('_', ' ');

    return GestureDetector(
      onTap: () => context.push('/property/${prop.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1.2),
          boxShadow: AppDesignSystem.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppPropertyImage(
                    imageUrl: coverPhoto,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      listingTypeStr,
                      style: const TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(favoritesNotifierProvider.notifier)
                        .toggleFavorite(prop),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isSaved
                            ? AppDesignSystem.brandGold
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormatter.formatPrice(prop.price),
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppDesignSystem.brandGold,
                        ),
                      ),
                      if (prop.verificationStatus ==
                          VerificationStatus.verified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: Color(0xFF059669),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prop.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: textS),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${prop.locality}, ${prop.city}',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 12,
                            color: textS,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: borderCol, height: 1),
                  const SizedBox(height: 10),

                  // Category-Specific Specs Row
                  _buildCategorySpecificSpecs(prop, textS),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpecificSpecs(PropertyEntity prop, Color textS) {
    switch (prop.category) {
      case PropertyCategory.residential:
        return Row(
          children: [
            if (prop.specifications.bedrooms != null)
              _specItem(
                Icons.bed_rounded,
                '${prop.specifications.bedrooms} BHK',
                textS,
              ),
            if (prop.specifications.bathrooms != null)
              _specItem(
                Icons.bathtub_outlined,
                '${prop.specifications.bathrooms} Bath',
                textS,
              ),
            if (prop.specifications.carpetArea != null)
              _specItem(
                Icons.square_foot_rounded,
                '${prop.specifications.carpetArea!.toInt()} sqft',
                textS,
              ),
          ],
        );
      case PropertyCategory.plotLand:
        return Row(
          children: [
            if (prop.specifications.plotArea != null)
              _specItem(
                Icons.aspect_ratio_rounded,
                '${prop.specifications.plotArea!.toInt()} sqft',
                textS,
              ),
            if (prop.features['isNaConverted'] == true)
              _specItem(
                Icons.check_circle_outline_rounded,
                'NA Converted',
                textS,
              ),
            if (prop.features['isGatedLayout'] == true)
              _specItem(Icons.security_rounded, 'Gated Layout', textS),
          ],
        );
      case PropertyCategory.commercial:
        return Row(
          children: [
            if (prop.specifications.carpetArea != null)
              _specItem(
                Icons.store_rounded,
                '${prop.specifications.carpetArea!.toInt()} sqft',
                textS,
              ),
            if (prop.features['powerLoad'] != null)
              _specItem(
                Icons.bolt_rounded,
                '${prop.features['powerLoad']}',
                textS,
              ),
            if (prop.features['hasLift'] == true)
              _specItem(Icons.elevator_rounded, 'Lift Access', textS),
          ],
        );
      case PropertyCategory.land:
        return Row(
          children: [
            if (prop.specifications.plotArea != null)
              _specItem(
                Icons.landscape_rounded,
                '${prop.specifications.plotArea} ${prop.specifications.areaUnit}',
                textS,
              ),
            if (prop.features['soilType'] != null)
              _specItem(
                Icons.eco_rounded,
                '${prop.features['soilType']}',
                textS,
              ),
            if (prop.features['hasBorewell'] == true)
              _specItem(Icons.water_drop_rounded, 'Borewell', textS),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _specItem(IconData icon, String label, Color textS) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppDesignSystem.brandGold),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 11,
              color: textS,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderMedia(BuildContext context) {
    final isDark = AppDesignSystem.isDark(context);
    final icon = switch (_category) {
      PropertyCategory.residential => Icons.home_rounded,
      PropertyCategory.plotLand => Icons.landscape_rounded,
      PropertyCategory.commercial => Icons.business_rounded,
      PropertyCategory.land => Icons.agriculture_rounded,
      _ => Icons.holiday_village_rounded,
    };

    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppDesignSystem.brandGold.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 4),
            Text(
              'No Photo Added',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 10,
                color: AppDesignSystem.textS(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
