import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/features/notification/presentation/providers/notification_notifier.dart';
import '../../domain/entities/review_entities.dart';
import '../../domain/repositories/review_repository.dart';
import '../../data/repositories/review_repository_impl.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final supabaseService = SupabaseService();
  final notificationRepo = ref.read(notificationRepositoryProvider);
  return ReviewRepositoryImpl(
    supabaseService: supabaseService,
    notificationRepository: notificationRepo,
  );
});

final propertyRatingSummaryProvider = FutureProvider.family<PropertyRatingSummaryEntity, String>((ref, propertyId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getPropertyRatingSummary(propertyId);
});

final sellerTrustScoreProvider = FutureProvider.family<SellerTrustScoreEntity, String>((ref, sellerId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getSellerTrustScore(sellerId);
});

final propertyReviewsProvider = FutureProvider.family<List<PropertyReviewEntity>, String>((ref, propertyId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getPropertyReviews(propertyId);
});
