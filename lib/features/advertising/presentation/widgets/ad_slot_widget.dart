import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/direct_ad_entities.dart';
import '../providers/advertising_providers.dart';

class AdSlotWidget extends ConsumerStatefulWidget {
  final String placement;
  final String? locality;
  final EdgeInsetsGeometry padding;

  const AdSlotWidget({
    super.key,
    required this.placement,
    this.locality,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  ConsumerState<AdSlotWidget> createState() => _AdSlotWidgetState();
}

class _AdSlotWidgetState extends ConsumerState<AdSlotWidget> {
  bool _impressionLogged = false;

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(
      directAdsForPlacementProvider((
        placement: widget.placement,
        locality: widget.locality,
      )),
    );

    return adsAsync.when(
      data: (ads) {
        if (ads.isNotEmpty) {
          final ad = ads.first;
          if (!_impressionLogged) {
            _impressionLogged = true;
            ref.read(advertisingRepositoryProvider).recordImpression(ad.id, widget.placement);
          }
          return _buildDirectAdCard(context, ad);
        }

        // Clean empty state / zero ad gap if no active approved direct sponsored ad
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDirectAdCard(BuildContext context, DirectAdCampaignEntity ad) {
    return Padding(
      padding: widget.padding,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sponsored Label header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'SPONSORED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ad.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (ad.targetLocality != null && ad.targetLocality!.isNotEmpty)
                    Text(
                      ad.targetLocality!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
              Image.network(
                ad.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.headline,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (ad.bodyText != null && ad.bodyText!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      ad.bodyText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleAdClick(ad),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        ad.ctaText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAdClick(DirectAdCampaignEntity ad) async {
    ref.read(advertisingRepositoryProvider).recordClick(ad.id, widget.placement);

    final actionValue = ad.actionValue.trim();
    if (actionValue.isEmpty) return;

    try {
      if (ad.actionType.toUpperCase() == 'PHONE' || actionValue.startsWith('tel:')) {
        final uri = Uri.parse(actionValue.startsWith('tel:') ? actionValue : 'tel:$actionValue');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      } else {
        final urlString = actionValue.startsWith('http') ? actionValue : 'https://$actionValue';
        final uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {}
  }
}
