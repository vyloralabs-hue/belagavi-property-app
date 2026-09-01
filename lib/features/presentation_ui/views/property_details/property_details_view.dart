import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';
import 'package:belagavi_property/features/presentation_ui/views/gallery/property_media_gallery_view.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import 'package:belagavi_property/features/property/presentation/providers/favorites_notifier.dart';
import 'package:belagavi_property/features/property/presentation/widgets/app_property_image.dart';
import 'package:belagavi_property/features/transaction/presentation/widgets/send_enquiry_modal.dart';
import 'package:belagavi_property/features/chat/presentation/providers/chat_providers.dart';
import 'widgets/property_reviews_widget.dart';
import 'google_maps_launcher.dart';

/// Property Details View â€” Master Marketplace Production Architecture
class PropertyDetailsView extends ConsumerStatefulWidget {
  final String propertyId;
  final PropertyEntity? property;

  const PropertyDetailsView({
    super.key,
    required this.propertyId,
    this.property,
  });

  @override
  ConsumerState<PropertyDetailsView> createState() =>
      _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends ConsumerState<PropertyDetailsView> {
  PropertyEntity? _property;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _property = widget.property;
    } else {
      _fetchProperty();
    }
  }

  Future<void> _fetchProperty() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(propertyRepositoryProvider);
      final result = await repo.getPropertyById(widget.propertyId);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = failure.message;
            });
          }
        },
        (entity) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _property = entity;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _shareProperty(PropertyEntity property) {
    final price = property.price >= 10000000
        ? 'â‚¹${(property.price / 10000000).toStringAsFixed(2)} Cr'
        : property.price >= 100000
        ? 'â‚¹${(property.price / 100000).toStringAsFixed(1)} L'
        : 'â‚¹${property.price.toStringAsFixed(0)}';
    final shareText =
        '${property.title}\nPrice: $price\nLocation: ${property.locality}, ${property.city}\n\nExplore on Belagavi Property Marketplace!';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Property details copied to clipboard for sharing!'),
        backgroundColor: Color(0xFF1E293B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: surfaceBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: const Text(
            'PROPERTY DETAILS',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppDesignSystem.brandGold,
              letterSpacing: 2.0,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
        ),
      );
    }

    if (_property == null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: surfaceBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: const Text(
            'PROPERTY NOT FOUND',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppDesignSystem.brandGold,
              letterSpacing: 2.0,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppDesignSystem.brandGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.search_off_rounded,
                    size: 56,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Property Not Found',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textP,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ??
                      'This property does not exist or has been removed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: textS),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final property = _property!;
    final isSaved = ref.watch(
      favoritesNotifierProvider.select(
        (s) => s.favorites.any((f) => f.propertyId == property.id),
      ),
    );
    final mediaList = property.mediaList;
    final coverMedia =
        mediaList.where((m) => m.isCover).firstOrNull ?? mediaList.firstOrNull;
    final videoMedia = mediaList
        .where((m) => m.type == MediaType.video)
        .firstOrNull;
    final imageList = mediaList
        .where((m) => m.type == MediaType.image)
        .toList();
    final allMediaUrls = imageList.isNotEmpty
        ? imageList.map((m) => m.mediaUrl).toList()
        : (coverMedia != null && coverMedia.mediaUrl.isNotEmpty
              ? [coverMedia.mediaUrl]
              : <String>[]);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          property.city.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppDesignSystem.brandGold,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppDesignSystem.brandGold : textP,
            ),
            tooltip: isSaved ? 'Remove from Saved' : 'Save Property',
            onPressed: () {
              ref
                  .read(favoritesNotifierProvider.notifier)
                  .toggleFavorite(property);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved
                        ? 'Removed from saved properties'
                        : 'Property saved to your favorites!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: textP),
            tooltip: 'Share Property',
            onPressed: () => _shareProperty(property),
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Color(0xFFF87171)),
            tooltip: 'Report Listing / Dispute',
            onPressed: () => _showUserDisputeReportModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Hero Cover Image Banner ──────────────────────────────
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyMediaGalleryView(
                              mediaUrls: allMediaUrls,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppDesignSystem.brandGold.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AppPropertyImage(
                                imageUrl: coverMedia?.mediaUrl,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Builder(
                                builder: (_) {
                                  final rawType =
                                      (property.features['listingType'] ??
                                              property.features['purpose'])
                                          as String?;
                                  final String label;
                                  final Color badgeColor;
                                  switch (rawType) {
                                    case 'FOR_RENT':
                                      label = 'For Rent';
                                      badgeColor = const Color(0xFF1E7BB5);
                                      break;
                                    case 'LEASE':
                                      label = 'Lease';
                                      badgeColor = const Color(0xFF7B3FB5);
                                      break;
                                    default:
                                      label = 'For Sale';
                                      badgeColor = AppDesignSystem.brandGold;
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontFamily: AppDesignSystem.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.photo_library_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${allMediaUrls.length} Photos',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Gallery Thumbnail Row
                    if (imageList.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageList.length,
                          itemBuilder: (context, index) {
                            final img = imageList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PropertyMediaGalleryView(
                                          mediaUrls: allMediaUrls,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: img.isCover
                                        ? AppDesignSystem.brandGold
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AppPropertyImage(
                                    imageUrl: img.mediaUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Video Section
                    if (videoMedia != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              color: AppDesignSystem.brandGold,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Property Walkthrough Video',
                                    style: TextStyle(
                                      color: textP,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Tap to watch video tour',
                                    style: TextStyle(
                                      color: textS,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // â”€â”€ 2. Moderation / Dispute Status Banners â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (property.status == ListingStatus.disputed) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF87171)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.gavel_rounded,
                              color: Color(0xFFF87171),
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FOUNDER CONFIRMED DISPUTE',
                                    style: TextStyle(
                                      fontFamily: AppDesignSystem.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF87171),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'This listing is under active moderation review due to an ownership or details dispute.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFFECACA),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (property.features['user_dispute_reported'] ==
                        true) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF78350F).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFBBF24)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.report_problem_rounded,
                              color: Color(0xFFFBBF24),
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'USER REPORT PENDING REVIEW',
                                    style: TextStyle(
                                      fontFamily: AppDesignSystem.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFBBF24),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'A user has reported an issue with this listing. Our team is verifying details.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFFDE68A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // â”€â”€ 3. Title & Price â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Text(
                      property.title,
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final price = property.price;
                        if (price <= 0) {
                          return const Text(
                            'Price on Request',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppDesignSystem.brandGold,
                            ),
                          );
                        }
                        final priceStr = price >= 10000000
                            ? '₹${(price / 10000000).toStringAsFixed(2)} Cr'
                            : price >= 100000
                            ? '₹${(price / 100000).toStringAsFixed(1)} L'
                            : '₹${price.toStringAsFixed(0)}';
                        final listingType =
                            (property.features['listingType'] ??
                                    property.features['purpose'])
                                as String? ??
                            'FOR_SALE';
                        final listingLabel = listingType == 'FOR_RENT'
                            ? '/month'
                            : listingType == 'LEASE'
                            ? ' (Lease)'
                            : '';
                        return Text(
                          '$priceStr$listingLabel',
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppDesignSystem.brandGold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final specs = property.specifications;
                        final isLandOrPlot =
                            property.category == PropertyCategory.plotLand ||
                            property.category == PropertyCategory.land;
                        final isCommercial =
                            property.category == PropertyCategory.commercial ||
                            property.category == PropertyCategory.industrial;
                        final rawArea = isLandOrPlot
                            ? specs.plotArea
                            : (specs.carpetArea ?? specs.superBuiltUpArea);
                        final areaStr = (rawArea != null && rawArea > 0)
                            ? '${rawArea.toStringAsFixed(0)} ${specs.areaUnit.toUpperCase()}'
                            : null;

                        final String prefix;
                        if (isCommercial) {
                          final subtypeName = switch (property.type) {
                            PropertySubtype.commercialOffice =>
                              'Commercial Office',
                            PropertySubtype.commercialShop => 'Commercial Shop',
                            PropertySubtype.commercialShowroom => 'Showroom',
                            PropertySubtype.warehouse ||
                            PropertySubtype.warehouseGodown =>
                              'Warehouse / Godown',
                            PropertySubtype.commercialPlot =>
                              'Commercial Building',
                            _ => 'Commercial',
                          };
                          final floorInfo =
                              (specs.floorNumber != null &&
                                  (specs.floorNumber ?? 0) > 0)
                              ? ' • Floor ${specs.floorNumber}'
                              : '';
                          prefix = '$subtypeName$floorInfo';
                        } else if (isLandOrPlot) {
                          final landSubtypeName = switch (property.type) {
                            PropertySubtype.agriculturalLand =>
                              'Agricultural Land',
                            PropertySubtype.nonNaLand => 'Non-NA Raw Land',
                            PropertySubtype.naLand => 'NA Approved Land',
                            PropertySubtype.residentialPlot =>
                              'Residential Plot',
                            PropertySubtype.commercialPlot => 'Commercial Plot',
                            PropertySubtype.industrialLand => 'Industrial Land',
                            _ => 'Land / Plot',
                          };
                          prefix = landSubtypeName;
                        } else if (!isLandOrPlot && (specs.bedrooms ?? 0) > 0) {
                          prefix = '${specs.bedrooms} BHK';
                        } else {
                          prefix = '';
                        }

                        final locality = [
                          property.locality,
                          property.city,
                        ].where((s) => s.isNotEmpty).join(', ');
                        final parts = <String>[
                          if (prefix.isNotEmpty) prefix,
                          ?areaStr,
                          if (locality.isNotEmpty) locality,
                        ];

                        return Text(
                          parts.join('  •  '),
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            color: textS,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Divider(color: borderCol),
                    const SizedBox(height: 16),

                    // ── 4. About Property ───────────────────────────────────────
                    Text(
                      'About Property',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.description.trim().isNotEmpty
                          ? property.description
                          : 'Contact seller for complete property walkthrough and details.',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 13,
                        color: textS,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // â”€â”€ 5. Category-Specific Specifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    // Residential Specifications
                    if (property.category == PropertyCategory.residential) ...[
                      Text(
                        'Residential Specifications',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textP,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Builder(
                        builder: (context) {
                          final specs = property.specifications;
                          final f = property.features;
                          final rows = <Map<String, String>>[
                            if (specs.bedrooms != null && specs.bedrooms! > 0)
                              {
                                'label': 'Bedrooms',
                                'value': '${specs.bedrooms} BHK',
                              },
                            if (specs.bathrooms != null && specs.bathrooms! > 0)
                              {
                                'label': 'Bathrooms',
                                'value': '${specs.bathrooms}',
                              },
                            if (specs.balconies != null && specs.balconies! > 0)
                              {
                                'label': 'Balconies',
                                'value': '${specs.balconies}',
                              },
                            if (specs.carpetArea != null &&
                                specs.carpetArea! > 0)
                              {
                                'label': 'Carpet Area',
                                'value':
                                    '${specs.carpetArea!.toStringAsFixed(0)} ${specs.areaUnit}',
                              },
                            if (specs.superBuiltUpArea != null &&
                                specs.superBuiltUpArea! > 0)
                              {
                                'label': 'Super Built-up Area',
                                'value':
                                    '${specs.superBuiltUpArea!.toStringAsFixed(0)} ${specs.areaUnit}',
                              },
                            if (specs.floorNumber != null)
                              {
                                'label': 'Floor',
                                'value':
                                    '${specs.floorNumber}${specs.totalFloors != null ? ' of ${specs.totalFloors}' : ''}',
                              },
                            if (specs.facingDirection != null &&
                                specs.facingDirection!.isNotEmpty)
                              {
                                'label': 'Facing Direction',
                                'value': specs.facingDirection!,
                              },
                            if (specs.furnishingStatus != null &&
                                specs.furnishingStatus!.isNotEmpty)
                              {
                                'label': 'Furnishing Status',
                                'value': specs.furnishingStatus!,
                              },
                            if (f['parking'] != null &&
                                f['parking'].toString().isNotEmpty)
                              {
                                'label': 'Parking',
                                'value': f['parking'].toString(),
                              },
                            if (f['propertyAge'] != null &&
                                f['propertyAge'].toString().isNotEmpty)
                              {
                                'label': 'Property Age',
                                'value': f['propertyAge'].toString(),
                              },
                            if (f['possessionStatus'] != null &&
                                f['possessionStatus'].toString().isNotEmpty)
                              {
                                'label': 'Possession Status',
                                'value': f['possessionStatus'].toString(),
                              },
                          ];
                          return Column(
                            children: rows
                                .map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          r['label']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textS,
                                          ),
                                        ),
                                        Text(
                                          r['value']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textP,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Commercial Specifications
                    if (property.category == PropertyCategory.commercial ||
                        property.category == PropertyCategory.industrial) ...[
                      Text(
                        'Commercial Specifications',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textP,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Builder(
                        builder: (context) {
                          final p = property;
                          final f = p.features;
                          final specs = p.specifications;
                          final rows = <Map<String, String>>[
                            if ((specs.carpetArea ?? 0) > 0)
                              {
                                'label': 'Carpet / Usable Area',
                                'value':
                                    '${specs.carpetArea!.toStringAsFixed(0)} ${specs.areaUnit.toUpperCase()}',
                              },
                            if ((specs.superBuiltUpArea ?? 0) > 0)
                              {
                                'label': 'Super Built-up Area',
                                'value':
                                    '${specs.superBuiltUpArea!.toStringAsFixed(0)} ${specs.areaUnit.toUpperCase()}',
                              },
                            if (specs.floorNumber != null)
                              {
                                'label': 'Floor',
                                'value':
                                    '${specs.floorNumber}${specs.totalFloors != null ? ' of ${specs.totalFloors}' : ''}',
                              },
                            if (f['entranceWidth'] != null)
                              {
                                'label': 'Entrance Frontage',
                                'value':
                                    '${(f['entranceWidth'] as num).toStringAsFixed(0)} ft',
                              },
                            if (f['ceilingHeight'] != null)
                              {
                                'label': 'Ceiling Height',
                                'value':
                                    '${(f['ceilingHeight'] as num).toStringAsFixed(0)} ft',
                              },
                            if (f['washrooms'] != null ||
                                specs.bathrooms != null)
                              {
                                'label': 'Washrooms',
                                'value': '${f['washrooms'] ?? specs.bathrooms}',
                              },
                            if (f['parkingSpaces'] != null)
                              {
                                'label': 'Dedicated Parking',
                                'value':
                                    '${f['parkingSpaces']} Slot${(f['parkingSpaces'] as int) > 1 ? 's' : ''}',
                              },
                            if (f['powerLoad'] != null &&
                                (f['powerLoad'] as String).isNotEmpty)
                              {
                                'label': 'Power Load',
                                'value': f['powerLoad'] as String,
                              },
                            if (specs.furnishingStatus != null &&
                                specs.furnishingStatus!.isNotEmpty)
                              {
                                'label': 'Furnishing',
                                'value': specs.furnishingStatus!,
                              },
                            if (specs.facingDirection != null)
                              {
                                'label': 'Facing Direction',
                                'value': specs.facingDirection!,
                              },
                          ];
                          return Column(
                            children: rows
                                .map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          r['label']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textS,
                                          ),
                                        ),
                                        Text(
                                          r['value']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textP,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Commercial Feature Badges
                      Builder(
                        builder: (context) {
                          final p = property;
                          final f = p.features;
                          final badges = <String>[
                            if (f['hasLift'] == true) 'Passenger / Goods Lift',
                            if (f['hasLoadingDock'] == true)
                              'Loading & Unloading Dock',
                          ];
                          if (badges.isEmpty) return const SizedBox.shrink();
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: badges
                                .map(
                                  (b) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0284C7,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF0284C7,
                                        ).withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 12,
                                          color: Color(0xFF38BDF8),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          b,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF38BDF8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Plot / Land / Raw Land Specific Detail Panel
                    if (property.category == PropertyCategory.plotLand ||
                        property.category == PropertyCategory.land) ...[
                      Builder(
                        builder: (context) {
                          final p = property;
                          final f = p.features;
                          final specs = p.specifications;
                          final isRawLand =
                              p.type == PropertySubtype.agriculturalLand ||
                              p.type == PropertySubtype.nonNaLand ||
                              p.category == PropertyCategory.land;
                          final title = isRawLand
                              ? 'Raw Land & Farm Details'
                              : 'Plot Details';

                          final rows = <Map<String, String>>[
                            if ((specs.plotArea ?? 0) > 0)
                              {
                                'label': 'Land Area',
                                'value':
                                    '${specs.plotArea!.toStringAsFixed(0)} ${specs.areaUnit.toUpperCase()}',
                              },
                            if (f['soilType'] != null &&
                                (f['soilType'] as String).isNotEmpty)
                              {
                                'label': 'Soil Type',
                                'value': f['soilType'] as String,
                              },
                            if (f['waterSource'] != null &&
                                (f['waterSource'] as String).isNotEmpty)
                              {
                                'label': 'Water Source / Irrigation',
                                'value': f['waterSource'] as String,
                              },
                            if (f['electricityType'] != null &&
                                (f['electricityType'] as String).isNotEmpty)
                              {
                                'label': 'Electricity Connection',
                                'value': f['electricityType'] as String,
                              },
                            if (f['roadAccessType'] != null &&
                                (f['roadAccessType'] as String).isNotEmpty)
                              {
                                'label': 'Road Access',
                                'value': f['roadAccessType'] as String,
                              },
                            if (f['fencingType'] != null &&
                                (f['fencingType'] as String).isNotEmpty)
                              {
                                'label': 'Fencing / Boundary',
                                'value': f['fencingType'] as String,
                              },
                            if (f['existingCropsTrees'] != null &&
                                (f['existingCropsTrees'] as String).isNotEmpty)
                              {
                                'label': 'Crops & Trees',
                                'value': f['existingCropsTrees'] as String,
                              },
                            if (f['surveyNumber'] != null &&
                                (f['surveyNumber'] as String).isNotEmpty)
                              {
                                'label': 'Survey No. / RTC Ref',
                                'value': f['surveyNumber'] as String,
                              },
                            if (f['plotLength'] != null &&
                                f['plotWidth'] != null)
                              {
                                'label': 'Dimensions',
                                'value':
                                    '${(f['plotLength'] as num).toStringAsFixed(0)} Ã— ${(f['plotWidth'] as num).toStringAsFixed(0)} ft',
                              },
                            if (f['roadWidth'] != null)
                              {
                                'label': 'Road Width',
                                'value':
                                    '${(f['roadWidth'] as num).toStringAsFixed(0)} ft',
                              },
                            if (specs.facingDirection != null)
                              {
                                'label': 'Facing',
                                'value': specs.facingDirection!,
                              },
                            if (f['numberOfRoads'] != null)
                              {
                                'label': 'Roads Adjoining',
                                'value':
                                    '${f['numberOfRoads']} side${(f['numberOfRoads'] as int) > 1 ? 's' : ''}',
                              },
                          ];

                          final badges = <String>[
                            if (f['hasBorewell'] == true) 'Borewell Available',
                            if (f['hasFarmHouse'] == true) 'Farmhouse Built',
                            if (f['isAgricultural'] == true ||
                                p.type == PropertySubtype.agriculturalLand)
                              'Agricultural Land',
                            if (f['isCornerPlot'] == true) 'Corner Plot',
                            if (f['isGatedLayout'] == true) 'Gated Layout',
                            if (f['hasBoundaryWall'] == true)
                              'Boundary Wall / Fenced',
                            if (f['isNaConverted'] == true) 'NA Converted',
                            if (f['isLayoutApproved'] == true)
                              'Layout Approved',
                            if (specs.isNaApproved == true) 'NA Approved',
                          ];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textP,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ...rows.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        r['label']!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: textS,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          r['value']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: textP,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (badges.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: badges
                                      .map(
                                        (b) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF16A34A,
                                            ).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF16A34A,
                                              ).withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                size: 12,
                                                color: Color(0xFF16A34A),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                b,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF16A34A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // â”€â”€ 6. Amenities â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Text(
                      'Amenities & Highlights',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Builder(
                      builder: (context) {
                        final rawAmenities = property.features['amenities'];
                        final amenityList = rawAmenities is List
                            ? rawAmenities.map((e) => e.toString()).toList()
                            : <String>[];
                        final specs = property.specifications;
                        final isLandOrPlot =
                            property.category == PropertyCategory.plotLand ||
                            property.category == PropertyCategory.land;
                        final isCommercial =
                            property.category == PropertyCategory.commercial ||
                            property.category == PropertyCategory.industrial;

                        if (amenityList.isNotEmpty) {
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: amenityList
                                .map(
                                  (a) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: borderCol),
                                    ),
                                    child: Text(
                                      a,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textP,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }

                        if (isCommercial) {
                          return Row(
                            children: [
                              Expanded(
                                child: _AmenityCard(
                                  icon: Icons.local_parking_rounded,
                                  label: 'Parking',
                                  cardBg: cardBg,
                                  borderCol: borderCol,
                                  textP: textP,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _AmenityCard(
                                  icon: Icons.elevator_rounded,
                                  label: 'Lift',
                                  cardBg: cardBg,
                                  borderCol: borderCol,
                                  textP: textP,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _AmenityCard(
                                  icon: Icons.security_rounded,
                                  label: 'Security',
                                  cardBg: cardBg,
                                  borderCol: borderCol,
                                  textP: textP,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _AmenityCard(
                                  icon: Icons.bolt_rounded,
                                  label: 'Power Backup',
                                  cardBg: cardBg,
                                  borderCol: borderCol,
                                  textP: textP,
                                ),
                              ),
                            ],
                          );
                        }

                        if (!isLandOrPlot) {
                          return Row(
                            children: [
                              if ((specs.bedrooms ?? 0) > 0) ...[
                                Expanded(
                                  child: _AmenityCard(
                                    icon: Icons.king_bed_outlined,
                                    label: '${specs.bedrooms} Beds',
                                    cardBg: cardBg,
                                    borderCol: borderCol,
                                    textP: textP,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              if ((specs.bathrooms ?? 0) > 0) ...[
                                Expanded(
                                  child: _AmenityCard(
                                    icon: Icons.bathtub_outlined,
                                    label: '${specs.bathrooms} Baths',
                                    cardBg: cardBg,
                                    borderCol: borderCol,
                                    textP: textP,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: _AmenityCard(
                                  icon: Icons.countertops_outlined,
                                  label: 'Kitchen',
                                  cardBg: cardBg,
                                  borderCol: borderCol,
                                  textP: textP,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _AmenityCard(
                                  icon: Icons.directions_car_outlined,
                                  label: 'Parking',
                                  cardBg: cardBg,
                                  borderCol: borderCol,
                                  textP: textP,
                                ),
                              ),
                            ],
                          );
                        }

                        return Text(
                          'Standard amenities included.',
                          style: TextStyle(fontSize: 13, color: textS),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // â”€â”€ 7. Location & Navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                        boxShadow: AppDesignSystem.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppDesignSystem.brandGold,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Location & Accessibility',
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textP,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${property.locality.isNotEmpty ? "${property.locality}, " : ""}${property.city}, Karnataka',
                            style: TextStyle(
                              fontSize: 13,
                              color: textP,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    GoogleMapsLauncher.launchLocationPin(
                                      latitude: property.latitude ?? 15.8497,
                                      longitude: property.longitude ?? 74.4977,
                                      query:
                                          '${property.locality}, ${property.city}',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.map_rounded,
                                    size: 16,
                                    color: AppDesignSystem.brandGold,
                                  ),
                                  label: const Text(
                                    'View Pin',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppDesignSystem.brandGold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppDesignSystem.brandGold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    GoogleMapsLauncher.launchNavigation(
                                      latitude: property.latitude ?? 15.8497,
                                      longitude: property.longitude ?? 74.4977,
                                      query:
                                          '${property.locality}, ${property.city}',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.navigation_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Directions',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppDesignSystem.brandGold,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // â”€â”€ 8. Seller Information Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                        boxShadow: AppDesignSystem.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppDesignSystem.brandGold.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppDesignSystem.brandGold,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppDesignSystem.brandGold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Verified Seller',
                                      style: TextStyle(
                                        fontFamily: AppDesignSystem.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textP,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFF38BDF8),
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Belagavi Property Registered Owner / Agent',
                                  style: TextStyle(fontSize: 11, color: textS),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    PropertyReviewsWidget(property: property),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // â”€â”€ 9. Bottom Action CTAs (Enquire, Site Visit, Make Offer, Chat) â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: surfaceBg,
                border: Border(top: BorderSide(color: borderCol)),
              ),
              child: SafeArea(
                top: false,
                child: Builder(
                  builder: (ctx) {
                    final purpose =
                        (property.features['listingType'] ??
                                property.features['purpose'])
                            as String? ??
                        'FOR_SALE';
                    final isRent = purpose == 'FOR_RENT';
                    final isLease = purpose == 'LEASE';
                    final ctaLabel = isRent
                        ? "I'm Interested / Rent"
                        : (isLease
                              ? "I'm Interested / Lease"
                              : "I'm Interested / Buy");

                    final isInactive =
                        property.status == ListingStatus.sold ||
                        property.status == ListingStatus.rented ||
                        property.status == ListingStatus.leased ||
                        property.status == ListingStatus.archived ||
                        property.status == ListingStatus.paused ||
                        property.status == ListingStatus.rejected ||
                        property.status == ListingStatus.disputed;

                    if (isInactive) {
                      final statusName = switch (property.status) {
                        ListingStatus.sold => 'SOLD',
                        ListingStatus.rented => 'RENTED',
                        ListingStatus.leased => 'LEASED',
                        ListingStatus.archived => 'ARCHIVED',
                        ListingStatus.paused => 'ON HOLD',
                        ListingStatus.disputed => 'UNDER DISPUTE',
                        _ => 'INACTIVE',
                      };
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderCol),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: textS,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Listing is $statusName â€¢ Not accepting new inquiries',
                              style: TextStyle(
                                color: textS,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => SendEnquiryModal.show(
                                  context,
                                  property,
                                  initialMode: 'site_visit',
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  side: const BorderSide(
                                    color: Color(0xFF0284C7),
                                  ),
                                  foregroundColor: const Color(0xFF38BDF8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Site Visit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => SendEnquiryModal.show(
                                  context,
                                  property,
                                  initialMode: 'offer',
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  side: const BorderSide(
                                    color: Color(0xFF15803D),
                                  ),
                                  foregroundColor: const Color(0xFF4ADE80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.local_offer_outlined,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Make Offer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) {
                                    context.push('/phone-login');
                                    return;
                                  }
                                  if (user.uid == property.ownerId) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You are the owner of this property.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final conv = await ref
                                      .read(chatNotifierProvider.notifier)
                                      .startOrOpenChat(
                                        propertyId: property.id,
                                        sellerId: property.ownerId,
                                        propertyTitle: property.title,
                                        propertyLocality: property.locality,
                                        propertyPrice: property.price,
                                      );
                                  if (conv != null && context.mounted) {
                                    context.push('/chat/${conv.id}');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  side: const BorderSide(
                                    color: AppDesignSystem.brandGold,
                                  ),
                                  foregroundColor: AppDesignSystem.brandGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => SendEnquiryModal.show(
                            context,
                            property,
                            initialMode: 'enquiry',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: AppDesignSystem.brandGold,
                            foregroundColor: const Color(0xFF0A0D11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: Text(
                            ctaLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDisputeReportModal(BuildContext context) {
    final reasonController = TextEditingController();
    String selectedReason = 'Property Sold / Unavailable';
    final reasons = [
      'Property Sold / Unavailable',
      'Incorrect Pricing / Terms',
      'Misleading / Fake Photos',
      'Ownership Dispute Concern',
      'Brokerage Fee Disagreement',
      'Other Issue',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDesignSystem.surfaceBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomCtx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag_rounded, color: Color(0xFFF87171), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Report Listing / Raise Dispute',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Help Founder Moderation keep Belagavi Property safe and accurate.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                dropdownColor: AppDesignSystem.cardBg(context),
                decoration: InputDecoration(
                  labelText: 'Report Reason',
                  labelStyle: const TextStyle(color: AppDesignSystem.brandGold),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppDesignSystem.borderCol(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                ),
                items: reasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedReason = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Details / Description (Optional)',
                  labelStyle: TextStyle(color: AppDesignSystem.textS(context)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppDesignSystem.borderCol(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(bottomCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Listing report submitted ($selectedReason). Founder Moderation notified.',
                        ),
                        backgroundColor: const Color(0xFF1E293B),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF87171),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmenityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color cardBg;
  final Color borderCol;
  final Color textP;

  const _AmenityCard({
    required this.icon,
    required this.label,
    required this.cardBg,
    required this.borderCol,
    required this.textP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppDesignSystem.brandGold, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textP,
            ),
          ),
        ],
      ),
    );
  }
}
