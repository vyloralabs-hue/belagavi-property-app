import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pricing_plan_entity.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../../data/repositories/pricing_repository_impl.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  return PricingRepositoryImpl();
});

final activePricingPlansProvider = FutureProvider<List<PricingPlanEntity>>((ref) async {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.getActivePlans();
});

final plansByFamilyProvider = FutureProvider.family<List<PricingPlanEntity>, String>((ref, family) async {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.getPlansByProductFamily(family);
});
