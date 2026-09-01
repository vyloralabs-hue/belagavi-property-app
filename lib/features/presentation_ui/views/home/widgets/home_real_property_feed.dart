import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/routing/app_routes.dart';
import '../../../theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import 'package:belagavi_property/features/property/presentation/providers/favorites_notifier.dart';
import 'package:belagavi_property/features/property/presentation/widgets/app_property_image.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';

/// Real Property Feed — Production Dual-Theme Architecture
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// Renders strictly real live listings or premium empty state (Zero fake listings)
class HomeRealPropertyFeed extends ConsumerStatefulWidget {
  const HomeRealPropertyFeed({super.key});

  @override
  ConsumerState<HomeRealPropertyFeed> createState() => _HomeRealPropertyFeedState();
}

class _HomeRealPropertyFeedState extends ConsumerState<HomeRealPropertyFeed> {
  List<PropertyEntity> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiveProperties();
  }

  Future<void> _loadLiveProperties() async {
    try {
      final repo = ref.read(propertyRepositoryProvider);
      final result = await repo.getProperties(limit: 10);
      result.fold(
        (_) {
          if (mounted) {
            setState(() {
              _properties = [];
              _isLoading = false;
            });
          }
        },
        (paginated) {
          if (mounted) {
            // Filter strictly for active / published listings for public marketplace
            final activeOnly = paginated.where((p) =>
              p.status == ListingStatus.active ||
              p.status == ListingStatus.published ||
              p.status == ListingStatus.approved
            ).toList();

            setState(() {
              _properties = activeOnly;
              _isLoading = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _properties = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);
    final cardBg = isDark ? const Color(0xFF131B2A) : Colors.white;
    final borderCol = AppDesignSystem.borderCol(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Listings',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textP,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/search'),
                  child: const Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppDesignSystem.brandGold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppDesignSystem.brandGold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Loading State, Empty State, or Live Horizontal Carousel
          if (_isLoading)
            const SizedBox(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
              ),
            )
          else if (_properties.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol, width: 1.1),
                  boxShadow: isDark ? null : AppDesignSystem.softShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A2436)
                            : const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppDesignSystem.brandGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 30,
                        color: AppDesignSystem.brandGold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No properties available yet.',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to list your property.',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 11.5,
                        color: textS,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (!AuthSessionStorageHelper.isLoggedIn()) {
                          context.push('/auth?redirect=${Uri.encodeComponent(AppRoutes.addProperty)}');
                        } else {
                          context.push(AppRoutes.addProperty);
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text(
                        'Post Your Property',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 275,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _properties.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _properties[index];
                  return _RealPropertyCard(property: item);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RealPropertyCard extends ConsumerWidget {
  final PropertyEntity property;

  const _RealPropertyCard({required this.property});

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '₹ ${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹ ${(price / 100000).toStringAsFixed(1)} L';
    }
    return '₹ ${price.toStringAsFixed(0)}';
  }

  String _getAreaLabel(PropertyEntity p) {
    final s = p.specifications;
    if (s.carpetArea != null && s.carpetArea! > 0) {
      return '${s.carpetArea!.toStringAsFixed(0)} sq.ft';
    }
    if (s.superBuiltUpArea != null && s.superBuiltUpArea! > 0) {
      return '${s.superBuiltUpArea!.toStringAsFixed(0)} sq.ft';
    }
    if (s.plotArea != null && s.plotArea! > 0) {
      return '${s.plotArea!.toStringAsFixed(0)} ${s.areaUnit}';
    }
    return '';
  }

  String _getCategoryTag(PropertyEntity p) {
    return switch (p.category) {
      PropertyCategory.residential => 'Residential',
      PropertyCategory.plotLand => 'Residential Plot',
      PropertyCategory.commercial => 'Commercial',
      PropertyCategory.land => 'Agricultural',
      _ => 'Property',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppDesignSystem.isDark(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = isDark ? const Color(0xFF131B2A) : Colors.white;
    final borderCol = AppDesignSystem.borderCol(context);

    final coverMedia = property.mediaList.where((m) => m.isCover).firstOrNull ??
        property.mediaList.firstOrNull;

    final isFav = ref.watch(favoritesNotifierProvider.select((s) => s.favorites.any((f) => f.propertyId == property.id)));
    final areaLabel = _getAreaLabel(property);

    return GestureDetector(
      onTap: () => context.push('/property/${property.id}'),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1.1),
          boxShadow: isDark ? null : AppDesignSystem.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Badge and Favorite Toggle
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: AppPropertyImage(
                    imageUrl: coverMedia?.mediaUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Top Badge (Category / Status)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A059),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCategoryTag(property),
                      style: const TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),

                // Favorite Heart Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favoritesNotifierProvider.notifier).toggleFavorite(property);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: isFav ? const Color(0xFFEF4444) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Information details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textP,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: textS,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${property.locality.isNotEmpty ? property.locality : property.city}, ${property.city}',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 10.5,
                            color: textS,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price & Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(property.price),
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: textP,
                        ),
                      ),
                      if (areaLabel.isNotEmpty)
                        Text(
                          areaLabel,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 10.5,
                            color: textS,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Bottom Attribute Chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          property.type.name,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: textS,
                          ),
                        ),
                      ),
                      if (property.features['isReraApproved'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RERA',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
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
}
