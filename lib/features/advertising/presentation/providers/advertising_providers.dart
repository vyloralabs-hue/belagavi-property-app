import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/direct_ad_entities.dart';
import '../../data/repositories/advertising_repository.dart';

final advertisingRepositoryProvider = Provider<AdvertisingRepository>((ref) {
  return AdvertisingRepository();
});

// Family provider to fetch active direct ads for any placement & locality
final directAdsForPlacementProvider = FutureProvider.family<List<DirectAdCampaignEntity>, ({String placement, String? locality})>(
  (ref, arg) async {
    final repo = ref.watch(advertisingRepositoryProvider);
    return repo.getActiveDirectAds(
      placement: arg.placement,
      locality: arg.locality,
    );
  },
);

// State model for admin ad campaigns
class AdminAdsState {
  final bool isLoading;
  final String? errorMessage;
  final List<DirectAdCampaignEntity> campaigns;
  final String? activeFilter;

  const AdminAdsState({
    this.isLoading = false,
    this.errorMessage,
    this.campaigns = const [],
    this.activeFilter,
  });

  AdminAdsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DirectAdCampaignEntity>? campaigns,
    String? activeFilter,
  }) {
    return AdminAdsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      campaigns: campaigns ?? this.campaigns,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class AdminAdsNotifier extends StateNotifier<AdminAdsState> {
  final AdvertisingRepository _repo;

  AdminAdsNotifier(this._repo) : super(const AdminAdsState());

  Future<void> fetchCampaigns({String? filterStatus}) async {
    state = state.copyWith(isLoading: true, activeFilter: filterStatus, errorMessage: null);
    try {
      final list = await _repo.getAdminCampaigns(filterStatus: filterStatus);
      state = state.copyWith(isLoading: false, campaigns: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> moderateCampaign({
    required String campaignId,
    required String action,
    String? reason,
  }) async {
    try {
      await _repo.moderateCampaign(
        campaignId: campaignId,
        action: action,
        reason: reason,
      );
      await fetchCampaigns(filterStatus: state.activeFilter);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final adminAdsNotifierProvider = StateNotifierProvider<AdminAdsNotifier, AdminAdsState>((ref) {
  final repo = ref.watch(advertisingRepositoryProvider);
  return AdminAdsNotifier(repo);
});
