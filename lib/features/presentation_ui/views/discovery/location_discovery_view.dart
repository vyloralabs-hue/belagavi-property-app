import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_design_system.dart';
import '../../../property_search/domain/entities/search_entities.dart';
import '../../../property_search/presentation/providers/property_search_notifier.dart';
import '../../../property/domain/entities/property_entities.dart';
import '../../../property/presentation/providers/favorites_notifier.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/localization/language_selector_modal.dart';
import '../search/widgets/location_selector_modal.dart';

/// Dynamic location discovery page.
/// Accepts a location name via the route parameter and shows all matching properties.
/// No hardcoded page per city — fully database-driven.
/// e.g. /discover/Belagavi, /discover/Mumbai, /discover/Koramangala
class LocationDiscoveryView extends ConsumerStatefulWidget {
  final String locationName;

  const LocationDiscoveryView({super.key, required this.locationName});

  @override
  ConsumerState<LocationDiscoveryView> createState() =>
      _LocationDiscoveryViewState();
}

class _LocationDiscoveryViewState extends ConsumerState<LocationDiscoveryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSearch();
    });
  }

  void _triggerSearch() {
    // Smart search: try city first, then locality, then raw text
    final location = widget.locationName.trim();
    ref
        .read(propertySearchNotifierProvider.notifier)
        .executeSearch(
          SearchQueryEntity(
            city: location,
            country: 'India',
            offset: 0,
            limit: 20,
          ),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(propertySearchNotifierProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(propertySearchNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.locationName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'Property Discovery',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppDesignSystem.primaryNavy,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language_rounded,
              color: AppDesignSystem.primaryNavy,
            ),
            tooltip: 'Change Language',
            onPressed: () => LanguageSelectorModal.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppDesignSystem.primaryNavy),
            tooltip: 'Change Location',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const LocationSelectorModal(),
            ),
          ),
        ],
      ),
      body: switch (searchState) {
        PropertySearchInitial() || PropertySearchLoading() => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading properties...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        PropertySearchError(message: final msg) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 56,
                  color: Color(0xFFB39037),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Properties are temporarily unavailable',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.primaryNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your internet connection or try again shortly.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _triggerSearch,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryNavy,
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
        ),
        PropertySearchSuccess(
          result: final result,
          isLoadingMore: final loadingMore,
        ) =>
          Column(
            children: [
              // Dynamic Count Header
              _DiscoveryHeader(
                locationName: widget.locationName,
                totalCount: result.totalCount,
                offset: result.offset,
                pageCount: result.properties.length,
              ),

              // Property List
              Expanded(
                child: result.properties.isEmpty
                    ? _EmptyDiscoveryState(locationName: widget.locationName)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            result.properties.length + (loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == result.properties.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return _DiscoveryPropertyCard(
                            property: result.properties[index],
                          );
                        },
                      ),
              ),
            ],
          ),
      },
    );
  }
}

// ─── Discovery Header ─────────────────────────────────────────────────────────
class _DiscoveryHeader extends StatelessWidget {
  final String locationName;
  final int totalCount;
  final int offset;
  final int pageCount;

  const _DiscoveryHeader({
    required this.locationName,
    required this.totalCount,
    required this.offset,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppDesignSystem.primaryNavy.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(
            color: AppDesignSystem.primaryNavy.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NumberFormatter.formatPropertyCount(
              totalCount,
              location: locationName,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          if (totalCount > 0)
            Text(
              NumberFormatter.formatPageRange(offset, pageCount, totalCount),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

// ─── Property Card for Discovery ─────────────────────────────────────────────
class _DiscoveryPropertyCard extends ConsumerWidget {
  final property;
  const _DiscoveryPropertyCard({required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl = property.mediaList.isNotEmpty
        ? property.mediaList.first.mediaUrl
        : null;
    final isFav = ref
        .watch(favoritesNotifierProvider.notifier)
        .isFavorite(property.id);
    final bedrooms = property.specifications.bedrooms;
    final area =
        property.specifications.carpetArea ??
        property.specifications.superBuiltUpArea ??
        property.specifications.plotArea;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: coverUrl != null
                ? Image.network(
                    coverUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _PlaceholderImage(),
                  )
                : _PlaceholderImage(),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Favorite
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.redAccent : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () => ref
                          .read(favoritesNotifierProvider.notifier)
                          .toggleFavorite(property),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppDesignSystem.brandGold,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.locality}, ${property.city}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Price + Specs Row
                Row(
                  children: [
                    Text(
                      NumberFormatter.formatPrice(property.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppDesignSystem.primaryNavy,
                      ),
                    ),
                    const Spacer(),
                    if (bedrooms != null)
                      _SpecChip(label: NumberFormatter.formatBhk(bedrooms)),
                    if (area != null)
                      _SpecChip(
                        label: NumberFormatter.formatArea(
                          area,
                          property.specifications.areaUnit,
                        ),
                      ),
                    // Verification badge
                    if (property.verificationStatus ==
                        VerificationStatus.verified)
                      const _SpecChip(label: '✓ Verified', isVerified: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  final bool isVerified;
  const _SpecChip({required this.label, this.isVerified = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isVerified
            ? AppDesignSystem.accentEmerald.withValues(alpha: 0.1)
            : AppDesignSystem.primaryNavy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isVerified
              ? AppDesignSystem.accentEmerald
              : AppDesignSystem.primaryNavy,
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.apartment, size: 48, color: Colors.grey),
    );
  }
}

class _EmptyDiscoveryState extends StatelessWidget {
  final String locationName;
  const _EmptyDiscoveryState({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No properties found in $locationName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to list a property here, or try a nearby location.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
