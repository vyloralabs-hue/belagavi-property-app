import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../../property/domain/entities/property_entities.dart';
import '../providers/intelligence_providers.dart';
import '../views/property_preference_modal.dart';

class HomePersonalizedFeed extends ConsumerStatefulWidget {
  const HomePersonalizedFeed({super.key});

  @override
  ConsumerState<HomePersonalizedFeed> createState() => _HomePersonalizedFeedState();
}

class _HomePersonalizedFeedState extends ConsumerState<HomePersonalizedFeed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pref = ref.read(propertyPreferenceNotifierProvider).preference;
      if (pref != null && pref.isActive) {
        ref.read(personalizedFeedNotifierProvider.notifier).loadPersonalizedProperties(pref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefState = ref.watch(propertyPreferenceNotifierProvider);
    final feedState = ref.watch(personalizedFeedNotifierProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textP = isDark ? const Color(0xFFFDFCF4) : const Color(0xFF0F172A);
    final textS = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF131922) : Colors.white;
    final borderCol = isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);

    final pref = prefState.preference;

    // 1. If user has no preference configured yet, display lightweight invitation banner
    if (pref == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF18202B), const Color(0xFF131922)]
                : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppDesignSystem.brandGold.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppDesignSystem.brandGold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Properties For You',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Set your budget & location to see curated listings matching your criteria.',
                    style: TextStyle(fontSize: 11, color: textS),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 34),
              ),
              onPressed: () => PropertyPreferenceModal.show(context),
              child: const Text('Set Up', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    // 2. If preference exists but paused
    if (!pref.isActive) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            const Icon(Icons.pause_circle_outline_rounded, size: 18, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Personalized recommendations paused',
                style: TextStyle(fontSize: 12, color: textS),
              ),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(propertyPreferenceNotifierProvider.notifier).toggleActive(true);
                ref.read(personalizedFeedNotifierProvider.notifier).loadPersonalizedProperties(pref.copyWith(isActive: true));
              },
              child: const Text('Resume', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppDesignSystem.brandGold)),
            ),
          ],
        ),
      );
    }

    // 3. If preference is active but no matching listings
    if (feedState.properties.isEmpty && !feedState.isLoading) {
      return const SizedBox.shrink(); // Don't clutter if zero matches
    }

    // 4. Render personalized properties carousel
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppDesignSystem.brandGold, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'Properties For You',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 28),
                  ),
                  onPressed: () => PropertyPreferenceModal.show(context),
                  icon: const Icon(Icons.tune_rounded, size: 14, color: AppDesignSystem.brandGold),
                  label: const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppDesignSystem.brandGold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Property Cards
          SizedBox(
            height: 250,
            child: feedState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppDesignSystem.brandGold))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: feedState.properties.length,
                    itemBuilder: (context, index) {
                      final property = feedState.properties[index];
                      final match = feedState.matchResults[property.id];
                      return _buildPropertyCard(context, property, match, cardBg, borderCol, textP, textS);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(
    BuildContext context,
    Property property,
    dynamic matchResult,
    Color cardBg,
    Color borderCol,
    Color textP,
    Color textS,
  ) {
    final score = matchResult?.score ?? 85;
    final reasons = (matchResult?.matchReasons as List<String>?) ?? [];

    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/property/${property.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: property.mediaList.isNotEmpty
                      ? Image.network(
                          property.mediaList.first.mediaUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.apartment_rounded, color: Colors.white38, size: 36),
                          ),
                        )
                      : Container(
                          height: 120,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.apartment_rounded, color: Colors.white38, size: 36),
                        ),
                ),
                // Match Score Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          '$score% MATCH',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${(property.price / 100000).toStringAsFixed(1)} Lakhs',
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          property.locality,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: textS),
                        ),
                      ),
                    ],
                  ),
                  if (reasons.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.brandGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        reasons.first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppDesignSystem.brandGold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
