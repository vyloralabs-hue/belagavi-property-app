import '../entities/pricing_plan_entity.dart';

abstract class PricingRepository {
  Future<List<PricingPlanEntity>> getActivePlans();
  Future<List<PricingPlanEntity>> getPlansByProductFamily(String productFamily);
  Future<PricingPlanEntity?> getPlanById(String planId);
}
