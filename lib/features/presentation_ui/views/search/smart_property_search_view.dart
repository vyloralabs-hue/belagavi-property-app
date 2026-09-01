import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/user_location_context.dart';
import '../../../property_search/presentation/providers/property_search_notifier.dart';
import '../../../property_search/presentation/providers/user_location_notifier.dart';
import '../../../property/presentation/providers/favorites_notifier.dart';
import '../../theme/app_design_system.dart';
import 'widgets/property_filter_modal.dart';
import 'widgets/location_selector_modal.dart';
import 'widgets/universal_location_search_modal.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';

class SmartPropertySearchView extends ConsumerStatefulWidget {
  final String? initialCategory;
  const SmartPropertySearchView({super.key, this.initialCategory});

  @override
  ConsumerState<SmartPropertySearchView> createState() =>
      _SmartPropertySearchViewState();
}

class _SmartPropertySearchViewState
    extends ConsumerState<SmartPropertySearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  PropertyCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(propertySearchNotifierProvider.notifier);
      final userLocation = ref.read(userLocationNotifierProvider).current;
      final cat = widget.initialCategory;
      if (cat != null && cat.isNotEmpty) {
        _selectedCategory = _parseCategoryString(cat);
        notifier.executeSearch(
          userLocation.toSearchQuery(category: _selectedCategory),
        );
      } else if (ref.read(propertySearchNotifierProvider)
          is PropertySearchInitial) {
        notifier.executeSearch(userLocation.toSearchQuery());
      }
    });
  }

  PropertyCategory? _parseCategoryString(String cat) {
    if (cat == 'residential') return PropertyCategory.residential;
    if (cat == 'plotLand' || cat == 'plot' || cat == 'plots')
      return PropertyCategory.plotLand;
    if (cat == 'commercial') return PropertyCategory.commercial;
    if (cat == 'land' || cat == 'raw_land' || cat == 'rawLand')
      return PropertyCategory.land;
    return PropertyCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == cat.toLowerCase(),
      orElse: () => PropertyCategory.residential,
    );
  }

  @override
  void didUpdateWidget(covariant SmartPropertySearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory &&
        widget.initialCategory != null) {
      final newCat = _parseCategoryString(widget.initialCategory!);
      setState(() => _selectedCategory = newCat);
      final currentQ = ref
          .read(propertySearchNotifierProvider.notifier)
          .currentQuery;
      ref
          .read(propertySearchNotifierProvider.notifier)
          .executeSearch(currentQ.copyWith(category: newCat, offset: 0));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(propertySearchNotifierProvider.notifier).fetchNextPage();
    }
  }

  void _onCategorySelected(PropertyCategory? cat) {
    setState(() => _selectedCategory = cat);
    final currentQ = ref
        .read(propertySearchNotifierProvider.notifier)
        .currentQuery;
    ref
        .read(propertySearchNotifierProvider.notifier)
        .executeSearch(currentQ.copyWith(category: cat, offset: 0));
  }

  void _executeSearch() {
    final queryText = _searchController.text.trim();
    final currentQ = ref
        .read(propertySearchNotifierProvider.notifier)
        .currentQuery;
    ref
        .read(propertySearchNotifierProvider.notifier)
        .executeSearch(currentQ.copyWith(rawQuery: queryText, offset: 0));
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PropertyFilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(propertySearchNotifierProvider);
    ref.watch(favoritesNotifierProvider);

    final isDark = AppDesignSystem.isDark(context);
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          _getCategoryPageTitle(_selectedCategory),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: textP,
          ),
        ),
        backgroundColor: surfaceBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline_rounded, color: textP),
            tooltip: 'My Saved Searches',
            onPressed: () => context.go('/saved-searches'),
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: textP),
            tooltip: 'Filter Properties',
            onPressed: _openFilterModal,
          ),
          ElevatedButton.icon(
            onPressed: () {
              final catParam = _selectedCategory?.name ?? 'residential';
              final target = '/add-property?category=$catParam';
              if (!AuthSessionStorageHelper.isLoggedIn()) {
                context.push('/auth?redirect=${Uri.encodeComponent(target)}');
              } else {
                context.push(target);
              }
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Property'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.brandGold,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ─── Search Input Bar ──────────────────────────────────────────────
          Container(
            color: surfaceBg,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textP, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search city, locality, landmark...',
                      hintStyle: TextStyle(color: textS, fontSize: 13),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppDesignSystem.brandGold,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1B2330)
                          : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderCol),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderCol),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppDesignSystem.brandGold,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _executeSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.brandGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onPressed: _executeSearch,
                ),
              ],
            ),
          ),

          // ─── Category Selection Chips Bar ───────────────────────────────────
          Container(
            color: surfaceBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryFilterChip(
                    'All',
                    null,
                    _selectedCategory == null,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryFilterChip(
                    'Residential',
                    PropertyCategory.residential,
                    _selectedCategory == PropertyCategory.residential,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryFilterChip(
                    'Plots',
                    PropertyCategory.plotLand,
                    _selectedCategory == PropertyCategory.plotLand,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryFilterChip(
                    'Commercial',
                    PropertyCategory.commercial,
                    _selectedCategory == PropertyCategory.commercial,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryFilterChip(
                    'Raw Land',
                    PropertyCategory.land,
                    _selectedCategory == PropertyCategory.land,
                  ),
                ],
              ),
            ),
          ),

          // ─── Dynamic Location Breadcrumb ───────────────────────────────────
          Builder(
            builder: (ctx) {
              final currentQ = ref
                  .watch(propertySearchNotifierProvider.notifier)
                  .currentQuery;
              final parts = <String>[];
              if (currentQ.city != null && currentQ.city!.isNotEmpty)
                parts.add(currentQ.city!);
              if (currentQ.locality != null && currentQ.locality!.isNotEmpty)
                parts.add(currentQ.locality!);
              if (currentQ.district != null &&
                  currentQ.district!.isNotEmpty &&
                  parts.isEmpty)
                parts.add(currentQ.district!);
              final userLoc = ref.watch(userLocationNotifierProvider).current;
              final breadcrumb = parts.isNotEmpty
                  ? parts.join(' › ')
                  : (userLoc.hasExplicitSelection
                        ? userLoc.displayName
                        : 'Select Location / All India');
              return GestureDetector(
                onTap: () => UniversalLocationSearchModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  color: isDark
                      ? const Color(0xFF1B2330)
                      : const Color(0xFFF1F5F9),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppDesignSystem.brandGold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          breadcrumb,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textP,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.edit_location_alt_outlined,
                        size: 16,
                        color: textS,
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(propertySearchNotifierProvider.notifier)
                              .resetFilters();
                          _searchController.clear();
                          setState(() => _selectedCategory = null);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 28),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppDesignSystem.brandGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ─── Dynamic Results Section ───────────────────────────────────────
          Expanded(
            child: switch (searchState) {
              PropertySearchInitial() ||
              PropertySearchLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppDesignSystem.brandGold,
                ),
              ),
              PropertySearchError(message: final _) => _buildErrorState(
                context,
              ),
              PropertySearchSuccess(
                result: final searchRes,
                isLoadingMore: final loadingMore,
              ) =>
                searchRes.properties.isEmpty
                    ? _buildEmptyCategoryState(context)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Count Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                            child: Text(
                              NumberFormatter.formatPageRange(
                                searchRes.offset,
                                searchRes.properties.length,
                                searchRes.totalCount,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textS,
                              ),
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              color: AppDesignSystem.brandGold,
                              backgroundColor: surfaceBg,
                              onRefresh: () async {
                                final currentQ = ref
                                    .read(
                                      propertySearchNotifierProvider.notifier,
                                    )
                                    .currentQuery;
                                await ref
                                    .read(
                                      propertySearchNotifierProvider.notifier,
                                    )
                                    .executeSearch(
                                      currentQ.copyWith(offset: 0),
                                    );
                              },
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount:
                                    searchRes.properties.length +
                                    (loadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == searchRes.properties.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppDesignSystem.brandGold,
                                        ),
                                      ),
                                    );
                                  }
                                  final item = searchRes.properties[index];
                                  return _buildPropertyCard(context, item);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChip(
    String label,
    PropertyCategory? cat,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _onCategorySelected(cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignSystem.brandGold
              : (AppDesignSystem.isDark(context)
                    ? const Color(0xFF1B2330)
                    : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppDesignSystem.brandGold
                : AppDesignSystem.borderCol(context),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppDesignSystem.textP(context),
          ),
        ),
      ),
    );
  }

  String _getCategoryPageTitle(PropertyCategory? cat) {
    return switch (cat) {
      PropertyCategory.residential => 'Residential Listings',
      PropertyCategory.plotLand => 'Plot & Layout Listings',
      PropertyCategory.commercial => 'Commercial Listings',
      PropertyCategory.land => 'Raw Land & Agri Listings',
      _ => 'Property Discovery & Listings',
    };
  }

  // ─── CATEGORY-SPECIFIC PROPERTY CARD ────────────────────────────────────────
  Widget _buildPropertyCard(BuildContext context, PropertyEntity item) {
    final coverUrl = item.mediaList.isNotEmpty
        ? item.mediaList.first.mediaUrl
        : null;
    final isFav = ref
        .watch(favoritesNotifierProvider.notifier)
        .isFavorite(item.id);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    final rawListingType =
        (item.features['listingType'] ?? item.features['purpose']) as String?;
    final priceFormatted = item.price >= 10000000
        ? '₹${(item.price / 10000000).toStringAsFixed(2)} Cr'
        : item.price >= 100000
        ? '₹${(item.price / 100000).toStringAsFixed(2)} L'
        : '₹${item.price.toStringAsFixed(0)}';
    final priceSuffix = rawListingType == 'FOR_RENT'
        ? '/month'
        : rawListingType == 'LEASE'
        ? ' (Lease)'
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusM,
        side: BorderSide(color: borderCol),
      ),
      elevation: 0.5,
      child: InkWell(
        onTap: () => context.push('/property/${item.id}'),
        borderRadius: AppDesignSystem.borderRadiusM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Header
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: Colors.grey.shade200,
                    image: coverUrl != null
                        ? DecorationImage(
                            image: NetworkImage(coverUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: coverUrl == null
                      ? Center(
                          child: Icon(
                            _getCategoryIcon(item.category),
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        )
                      : null,
                ),
                // Category Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppDesignSystem.brandGold,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _getCategoryDisplayName(item.category, item.type),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD9C394),
                      ),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : Colors.white,
                        size: 20,
                      ),
                      onPressed: () => ref
                          .read(favoritesNotifierProvider.notifier)
                          .toggleFavorite(item),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),

            // Property Details Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textP,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$priceFormatted$priceSuffix',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppDesignSystem.brandGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location Row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${item.locality.isNotEmpty ? "${item.locality}, " : ""}${item.city}',
                          style: TextStyle(fontSize: 12, color: textS),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category-Specific Highlight Spec Strip + View Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildCategorySpecificSpecStrip(item, context),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/property/${item.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.brandGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpecificSpecStrip(PropertyEntity item, context) {
    final chips = <Widget>[];

    if (item.category == PropertyCategory.residential) {
      if (item.specifications.bedrooms != null) {
        chips.add(
          _buildSpecTag(
            '${item.specifications.bedrooms} BHK',
            Icons.bed_outlined,
            context,
          ),
        );
      }
      if (item.specifications.carpetArea != null &&
          item.specifications.carpetArea! > 0) {
        chips.add(
          _buildSpecTag(
            '${item.specifications.carpetArea!.toStringAsFixed(0)} sqft',
            Icons.square_foot_rounded,
            context,
          ),
        );
      }
      if (item.specifications.furnishingStatus != null) {
        chips.add(
          _buildSpecTag(
            item.specifications.furnishingStatus!,
            Icons.chair_outlined,
            context,
          ),
        );
      }
    } else if (item.category == PropertyCategory.plotLand) {
      if (item.specifications.plotArea != null &&
          item.specifications.plotArea! > 0) {
        chips.add(
          _buildSpecTag(
            '${item.specifications.plotArea!.toStringAsFixed(0)} ${item.specifications.areaUnit}',
            Icons.landscape_outlined,
            context,
          ),
        );
      }
      final plotLen = item.features['plotLength'];
      final plotWid = item.features['plotWidth'];
      if (plotLen != null && plotWid != null) {
        chips.add(
          _buildSpecTag(
            '${plotLen}x$plotWid',
            Icons.straighten_rounded,
            context,
          ),
        );
      }
      final roadWid = item.features['roadWidth'];
      if (roadWid != null) {
        chips.add(
          _buildSpecTag('${roadWid}ft Road', Icons.alt_route_rounded, context),
        );
      }
    } else if (item.category == PropertyCategory.commercial) {
      final subName = item.type.name.replaceAll('commercial', '').toUpperCase();
      chips.add(_buildSpecTag(subName, Icons.storefront_outlined, context));
      if (item.specifications.carpetArea != null &&
          item.specifications.carpetArea! > 0) {
        chips.add(
          _buildSpecTag(
            '${item.specifications.carpetArea!.toStringAsFixed(0)} sqft',
            Icons.square_foot_rounded,
            context,
          ),
        );
      }
      final power = item.features['powerLoad'];
      if (power != null && power.toString().isNotEmpty) {
        chips.add(_buildSpecTag('$power', Icons.bolt_outlined, context));
      }
    } else if (item.category == PropertyCategory.land) {
      if (item.specifications.plotArea != null &&
          item.specifications.plotArea! > 0) {
        chips.add(
          _buildSpecTag(
            '${(item.specifications.plotArea! / 43560).toStringAsFixed(1)} Acres',
            Icons.agriculture_rounded,
            context,
          ),
        );
      }
      final soil = item.features['soilType'];
      if (soil != null && soil.toString().isNotEmpty) {
        chips.add(_buildSpecTag('$soil', Icons.grass_rounded, context));
      }
      final water = item.features['waterSource'];
      if (water != null && water.toString().isNotEmpty) {
        chips.add(_buildSpecTag('$water', Icons.water_drop_outlined, context));
      }
    }

    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }

  Widget _buildSpecTag(String text, IconData icon, BuildContext context) {
    final isDark = AppDesignSystem.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2330) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppDesignSystem.brandGold),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppDesignSystem.textP(context),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(PropertyCategory category) {
    return switch (category) {
      PropertyCategory.residential => Icons.home_rounded,
      PropertyCategory.plotLand => Icons.landscape_rounded,
      PropertyCategory.commercial => Icons.storefront_rounded,
      PropertyCategory.land => Icons.park_rounded,
      _ => Icons.apartment_rounded,
    };
  }

  String _getCategoryDisplayName(
    PropertyCategory category,
    PropertySubtype type,
  ) {
    return switch (category) {
      PropertyCategory.residential => 'RESIDENTIAL',
      PropertyCategory.plotLand => 'PLOT / LAYOUT',
      PropertyCategory.commercial => 'COMMERCIAL',
      PropertyCategory.land => 'RAW LAND',
      _ => 'PROPERTY',
    };
  }

  Widget _buildEmptyCategoryState(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return RefreshIndicator(
      color: AppDesignSystem.brandGold,
      onRefresh: () async {
        final currentQ = ref
            .read(propertySearchNotifierProvider.notifier)
            .currentQuery;
        await ref
            .read(propertySearchNotifierProvider.notifier)
            .executeSearch(currentQ.copyWith(offset: 0));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppDesignSystem.brandGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppDesignSystem.brandGold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No properties available in this category yet.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textP,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your location scope, expanding filters, or list the first property in this category!',
              style: TextStyle(fontSize: 13, color: textS, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 4 Actionable CTAs
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const LocationSelectorModal(),
                  ),
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                  label: const Text('Change Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textP,
                    side: BorderSide(color: AppDesignSystem.borderCol(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _openFilterModal,
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Adjust Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textP,
                    side: BorderSide(color: AppDesignSystem.borderCol(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _onCategorySelected(null);
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.grid_view_rounded, size: 16),
                  label: const Text('View All Properties'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final catParam = _selectedCategory?.name ?? 'residential';
                    final target = '/add-property?category=$catParam';
                    if (!AuthSessionStorageHelper.isLoggedIn()) {
                      context.push(
                        '/auth?redirect=${Uri.encodeComponent(target)}',
                      );
                    } else {
                      context.push(target);
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: const Text('List Your Property'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  // ─── ERROR STATE ────────────────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: AppDesignSystem.brandGold,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load online listings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textP(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check network connectivity or retry with cached filters.',
              style: TextStyle(
                fontSize: 13,
                color: AppDesignSystem.textS(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(propertySearchNotifierProvider.notifier)
                  .executeSearch(
                    ref
                        .read(propertySearchNotifierProvider.notifier)
                        .currentQuery,
                  ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
