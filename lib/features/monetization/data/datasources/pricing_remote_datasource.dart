import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/backend/supabase_service.dart';
import '../models/pricing_plan_model.dart';

abstract class PricingRemoteDataSource {
  Future<List<PricingPlanModel>> fetchAllActivePlans();
  Future<List<PricingPlanModel>> fetchPlansByProductFamily(String productFamily);
  Future<PricingPlanModel?> fetchPlanById(String planId);
}

class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final SupabaseService _supabaseService;

  PricingRemoteDataSourceImpl({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  SupabaseClient get _client => _supabaseService.client;

  @override
  Future<List<PricingPlanModel>> fetchAllActivePlans() async {
    try {
      final response = await _client
          .from('pricing_plans')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final list = (response as List)
          .map((item) => PricingPlanModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<PricingPlanModel>> fetchPlansByProductFamily(String productFamily) async {
    try {
      final response = await _client
          .from('pricing_plans')
          .select()
          .eq('is_active', true)
          .eq('product_family', productFamily)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((item) => PricingPlanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PricingPlanModel?> fetchPlanById(String planId) async {
    try {
      final response = await _client
          .from('pricing_plans')
          .select()
          .eq('is_active', true)
          .or('id.eq.$planId,code.eq.$planId,plan_id.eq.$planId')
          .maybeSingle();

      if (response == null) return null;
      return PricingPlanModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
