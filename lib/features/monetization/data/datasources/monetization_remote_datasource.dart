import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/monetization_entities.dart';
import '../models/monetization_models.dart';

abstract class MonetizationRemoteDataSource {
  Future<List<SubscriptionPlanModel>> fetchSubscriptionPlans();
  Future<UserSubscriptionModel?> fetchUserSubscription(String userId);
  Future<List<AddOnPackageModel>> fetchAddOnPackages();
  Future<List<PaymentTransactionModel>> fetchUserTransactions(String userId);
  Future<UserSubscriptionModel> createSubscription({
    required String userId,
    required String planId,
  });
}

@LazySingleton(as: MonetizationRemoteDataSource)
class MonetizationRemoteDataSourceImpl extends BaseRemoteDataSource
    implements MonetizationRemoteDataSource {
  final SupabaseService _supabaseService;

  MonetizationRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<List<SubscriptionPlanModel>> fetchSubscriptionPlans() async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockPlans;
      }
      final response = await _supabaseService.from('subscription_plans').select();
      return (response as List).map((json) => SubscriptionPlanModel.fromJson(json)).toList();
    });
  }

  @override
  Future<UserSubscriptionModel?> fetchUserSubscription(String userId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return UserSubscriptionModel(
          id: 'sub_free_$userId',
          userId: userId,
          planId: 'plan_free',
          tier: SubscriptionTier.free,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        );
      }
      final response = await _supabaseService
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();
      return response != null ? UserSubscriptionModel.fromJson(response) : null;
    });
  }

  @override
  Future<List<AddOnPackageModel>> fetchAddOnPackages() async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return _mockAddOns;
      }
      final response = await _supabaseService.from('add_on_packages').select();
      return (response as List).map((json) => AddOnPackageModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<PaymentTransactionModel>> fetchUserTransactions(String userId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return const [];
      }
      final response = await _supabaseService
          .from('payments_transactions')
          .select()
          .eq('user_id', userId);
      return (response as List).map((json) => PaymentTransactionModel.fromJson(json)).toList();
    });
  }

  @override
  Future<UserSubscriptionModel> createSubscription({
    required String userId,
    required String planId,
  }) async {
    return safeQuery(() async {
      final newSub = UserSubscriptionModel(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        planId: planId,
        tier: SubscriptionTier.brokerPro,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      if (!_supabaseService.isInitialized) {
        return newSub;
      }
      final response = await _supabaseService
          .from('user_subscriptions')
          .insert(newSub.toJson())
          .select()
          .single();
      return UserSubscriptionModel.fromJson(response);
    });
  }

  static const _mockPlans = [
    SubscriptionPlanModel(
      id: 'plan_free',
      tier: SubscriptionTier.free,
      name: 'Free Plan',
      description: 'Ideal for individual buyers and single listing owners.',
      priceInr: 0,
      priceUsd: 0,
      cycle: BillingCycle.monthly,
      maxActiveListings: 1,
      featuredListingSlots: 0,
      teamSeats: 0,
      aiGenerationsPerMonth: 1,
    ),
    SubscriptionPlanModel(
      id: 'plan_seller_premium',
      tier: SubscriptionTier.premiumSeller,
      name: 'Premium Seller Plan',
      description: 'For individual sellers who want featured exposure.',
      priceInr: 999,
      priceUsd: 12,
      cycle: BillingCycle.monthly,
      maxActiveListings: 5,
      featuredListingSlots: 1,
      teamSeats: 0,
      aiGenerationsPerMonth: 5,
      hasLegalAssistance: true,
    ),
    SubscriptionPlanModel(
      id: 'plan_broker_pro',
      tier: SubscriptionTier.brokerPro,
      name: 'Broker Pro Plan',
      description: 'For real estate agents with CRM & team access.',
      priceInr: 2499,
      priceUsd: 30,
      cycle: BillingCycle.monthly,
      maxActiveListings: 25,
      featuredListingSlots: 5,
      teamSeats: 3,
      aiGenerationsPerMonth: 50,
      hasCrmAccess: true,
      hasAnalyticsAccess: true,
      hasLegalAssistance: true,
    ),
    SubscriptionPlanModel(
      id: 'plan_builder_pro',
      tier: SubscriptionTier.builderPro,
      name: 'Builder Pro Plan',
      description: 'For developers showcasing project towers & inventories.',
      priceInr: 9999,
      priceUsd: 120,
      cycle: BillingCycle.monthly,
      maxActiveListings: 100,
      featuredListingSlots: 20,
      teamSeats: 10,
      aiGenerationsPerMonth: 200,
      hasCrmAccess: true,
      hasAnalyticsAccess: true,
      hasLegalAssistance: true,
    ),
    SubscriptionPlanModel(
      id: 'plan_enterprise_builder',
      tier: SubscriptionTier.enterpriseBuilder,
      name: 'Enterprise Builder Plan',
      description: 'Unlimited capacity for multi-state real estate builders.',
      priceInr: 24999,
      priceUsd: 300,
      cycle: BillingCycle.monthly,
      maxActiveListings: 9999,
      featuredListingSlots: 50,
      teamSeats: 999,
      aiGenerationsPerMonth: 9999,
      hasCrmAccess: true,
      hasAnalyticsAccess: true,
      hasLegalAssistance: true,
    ),
  ];

  static const _mockAddOns = [
    AddOnPackageModel(
      id: 'addon_featured_7d',
      name: '7-Day Featured Listing Boost',
      description: 'Promote your property at the top of search results for 7 days.',
      priceInr: 499,
      packageType: 'featured_boost',
    ),
    AddOnPackageModel(
      id: 'addon_legal_draft',
      name: 'Legal Title & Sale Deed Assistance',
      description: 'Legal documentation support and title check by PropertyHub legal team.',
      priceInr: 2999,
      packageType: 'legal_package',
    ),
  ];
}
