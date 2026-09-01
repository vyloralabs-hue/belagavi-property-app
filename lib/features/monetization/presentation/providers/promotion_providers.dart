import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/features/notification/presentation/providers/notification_notifier.dart';
import '../../domain/entities/promotion_entities.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../../data/repositories/promotion_repository_impl.dart';
import '../../domain/repositories/payment_gateway_repository.dart';
import '../../data/repositories/payment_gateway_repository_impl.dart';
import '../../data/datasources/payment_gateway_remote_datasource.dart';

final paymentGatewayRepositoryProvider = Provider<PaymentGatewayRepository>((ref) {
  final supabaseService = SupabaseService();
  final remoteDataSource = PaymentGatewayRemoteDataSourceImpl(supabaseService);
  return PaymentGatewayRepositoryImpl(remoteDataSource);
});

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  final supabaseService = SupabaseService();
  final notificationRepo = ref.read(notificationRepositoryProvider);
  return PromotionRepositoryImpl(
    supabaseService: supabaseService,
    notificationRepository: notificationRepo,
  );
});

final propertyPromotionsProvider = FutureProvider.family<List<PropertyPromotionEntity>, String>((ref, propertyId) async {
  final repo = ref.watch(promotionRepositoryProvider);
  return repo.getPromotionsForProperty(propertyId);
});

final ownerPromotionsProvider = FutureProvider.family<List<PropertyPromotionEntity>, String>((ref, ownerId) async {
  final repo = ref.watch(promotionRepositoryProvider);
  return repo.getPromotionsForOwner(ownerId);
});

final activePromotionsProvider = FutureProvider<List<PropertyPromotionEntity>>((ref) async {
  final repo = ref.watch(promotionRepositoryProvider);
  return repo.getActivePromotions();
});
