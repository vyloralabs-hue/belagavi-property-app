import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';
import '../../../../property/domain/entities/property_entities.dart';
import '../../../../property/presentation/providers/property_providers.dart';
import '../../../../property/presentation/widgets/app_property_image.dart';
import '../../../../auth/utils/auth_session_storage_helper.dart';

/// Featured Carousel — Master UI/UX Design Blueprint
/// Uses real Supabase published properties or graceful fallback card
class HomeFeaturedCarousel extends ConsumerStatefulWidget {
  const HomeFeaturedCarousel({super.key});

  @override
  ConsumerState<HomeFeaturedCarousel> createState() =>
      _HomeFeaturedCarouselState();
}

class _HomeFeaturedCarouselState extends ConsumerState<HomeFeaturedCarousel> {
  List<PropertyEntity> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  Future<void> _loadFeatured() async {
    try {
      final repo = ref.read(propertyRepositoryProvider);
      final result = await repo.getProperties(limit: 10);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _properties = [];
              _isLoading = false;
            });
          }
        },
        (paginated) {
          if (mounted) {
            setState(() {
              _properties = paginated;
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
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Properties',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/search'),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      color: AppDesignSystem.brandGold,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppDesignSystem.brandGold,
                ),
              ),
            )
          else if (_properties.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderCol, width: 1.2),
                  boxShadow: AppDesignSystem.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.brandGold.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppDesignSystem.brandGold.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 32,
                        color: AppDesignSystem.brandGold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No properties listed yet.',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to list your property.',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 12,
                        color: textS,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        const target = '/add-property';
                        if (!AuthSessionStorageHelper.isLoggedIn()) {
                          context.push(
                            '/auth?redirect=${Uri.encodeComponent(target)}',
                          );
                        } else {
                          context.push(target);
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Post Your Property'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 270,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  final item = _properties[index];
                  return _CarouselPropertyCard(item: item);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CarouselPropertyCard extends StatefulWidget {
  final PropertyEntity item;
  const _CarouselPropertyCard({required this.item});

  @override
  State<_CarouselPropertyCard> createState() => _CarouselPropertyCardState();
}

class _CarouselPropertyCardState extends State<_CarouselPropertyCard> {
  bool _isFavorite = false;

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)} Lakh';
    }
    return '₹${price.toStringAsFixed(0)}';
  }

  String _formatSpecs(PropertyEntity p) {
    final s = p.specifications;
    final parts = <String>[];
    if (s.bedrooms != null && s.bedrooms! > 0) parts.add('${s.bedrooms} BHK');
    if (s.carpetArea != null && s.carpetArea! > 0)
      parts.add('${s.carpetArea!.toStringAsFixed(0)} sqft');
    if (s.plotArea != null && s.plotArea! > 0)
      parts.add('${s.plotArea!.toStringAsFixed(0)} ${s.areaUnit}');
    if (p.locality.isNotEmpty) parts.add(p.locality);
    return parts.join(' • ');
  }

  String _getBadge(PropertyEntity p) {
    if (p.category == PropertyCategory.plotLand) return 'PLOT';
    if (p.category == PropertyCategory.commercial) return 'COMMERCIAL';
    if (p.category == PropertyCategory.land) return 'LAND';
    return 'RESIDENTIAL';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.item;
    final mediaList = p.mediaList;
    final coverMedia = mediaList.isNotEmpty
        ? mediaList.firstWhere((m) => m.isCover, orElse: () => mediaList.first)
        : null;

    final textP = AppDesignSystem.textP(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return GestureDetector(
      onTap: () => context.push('/property/${p.id}'),
      child: Container(
        width: 235,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1.2),
          boxShadow: AppDesignSystem.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with Gold Badge and Heart Icon
            Stack(
              children: [
                Container(
                  height: 148,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B2330),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: AppPropertyImage(
                      imageUrl: coverMedia?.mediaUrl,
                      height: 148,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.brandGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getBadge(p),
                      style: const TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Heart Bookmark Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title.isNotEmpty ? p.title : 'Property in Belagavi',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textP,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(p.price),
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatSpecs(p),
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 11,
                      color: AppDesignSystem.textS(context),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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
