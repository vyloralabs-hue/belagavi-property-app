import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/review/domain/entities/review_entities.dart';
import 'package:belagavi_property/features/review/presentation/providers/review_providers.dart';
import 'submit_review_modal.dart';

class PropertyReviewsWidget extends ConsumerWidget {
  final PropertyEntity property;

  const PropertyReviewsWidget({super.key, required this.property});

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(propertyRatingSummaryProvider(property.id));
    final reviewsAsync = ref.watch(propertyReviewsProvider(property.id));
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: AppDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratings & Verified Reviews',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  color: textP,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () => SubmitReviewModal.show(context, property),
                icon: const Icon(
                  Icons.rate_review_outlined,
                  color: AppDesignSystem.brandGold,
                  size: 16,
                ),
                label: const Text(
                  'Write Review',
                  style: TextStyle(
                    color: AppDesignSystem.brandGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating Summary Box
          summaryAsync.when(
            data: (summary) {
              if (summary.reviewCount == 0) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaceBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_outline_rounded, color: textS, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No verified reviews yet. Interact with the property to be the first to review.',
                          style: TextStyle(color: textS, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surfaceBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              summary.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: textP,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 26,
                            ),
                          ],
                        ),
                        Text(
                          '${summary.verifiedReviewCount} Verified ${summary.verifiedReviewCount == 1 ? "Review" : "Reviews"}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    // Rating Distribution Bar
                    Expanded(
                      child: Column(
                        children: [5, 4, 3, 2, 1].map((star) {
                          final count = summary.ratingBreakdown[star] ?? 0;
                          final pct = summary.reviewCount > 0
                              ? count / summary.reviewCount
                              : 0.0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Row(
                              children: [
                                Text(
                                  '$star★',
                                  style: TextStyle(fontSize: 10, color: textS),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: borderCol,
                                      valueColor: const AlwaysStoppedAnimation(
                                        Color(0xFFF59E0B),
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$count',
                                  style: TextStyle(fontSize: 10, color: textS),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppDesignSystem.brandGold,
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Reviews List
          reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) return const SizedBox.shrink();

              return Column(
                children: reviews
                    .map(
                      (rev) => _buildReviewCard(
                        rev,
                        context,
                        textP,
                        textS,
                        surfaceBg,
                        borderCol,
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    PropertyReviewEntity review,
    BuildContext context,
    Color textP,
    Color textS,
    Color surfaceBg,
    Color borderCol,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    review.reviewerName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textP,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (review.isVerifiedInteraction)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 11,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            review.verificationSource.displayName,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(fontSize: 10, color: textS),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 14,
                color: const Color(0xFFF59E0B),
              );
            }),
          ),
          if (review.title.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: textP,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            review.reviewText,
            style: TextStyle(color: textS, fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
}
