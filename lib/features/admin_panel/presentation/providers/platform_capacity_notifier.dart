import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/admin_panel/domain/entities/platform_analytics_capacity_entity.dart';

class PlatformCapacityState extends Equatable {
  final PlatformCapacityMetricsEntity? metrics;
  final List<ZeroResultQueryEntity> zeroResultDemands;
  final bool isLoading;
  final String? errorMessage;

  const PlatformCapacityState({
    this.metrics,
    this.zeroResultDemands = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PlatformCapacityState copyWith({
    PlatformCapacityMetricsEntity? metrics,
    List<ZeroResultQueryEntity>? zeroResultDemands,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlatformCapacityState(
      metrics: metrics ?? this.metrics,
      zeroResultDemands: zeroResultDemands ?? this.zeroResultDemands,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [metrics, zeroResultDemands, isLoading, errorMessage];
}

final platformCapacityNotifierProvider =
    NotifierProvider<PlatformCapacityNotifier, PlatformCapacityState>(
  PlatformCapacityNotifier.new,
);

class PlatformCapacityNotifier extends Notifier<PlatformCapacityState> {
  @override
  PlatformCapacityState build() {
    return const PlatformCapacityState(isLoading: false);
  }

  Future<void> fetchMetrics({
    required String authenticatedUserId,
    required UserRole userRole,
    String timeRange = '30d',
  }) async {
    // Only Founder and Admin can access platform capacity metrics
    if (userRole != UserRole.founder && userRole != UserRole.admin) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unauthorized: Founder access required for capacity analytics.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final now = DateTime.now();

      // Deterministic aggregate metrics representation
      final mockMetrics = PlatformCapacityMetricsEntity(
        totalProperties: 4850,
        publishedProperties: 4120,
        pendingProperties: 310,
        underReviewProperties: 140,
        disputedProperties: 8,
        archivedProperties: 110,
        rejectedProperties: 62,
        pausedProperties: 45,
        draftProperties: 55,
        totalUsers: 12400,
        totalBuilders: 85,
        totalAgents: 340,
        totalSellers: 1800,
        totalSearches: 94500,
        activeSavedSearches: 3200,
        totalFavorites: 18400,
        totalAds: 48,
        activeAds: 22,
        generatedAt: now,
      );

      final zeroResults = [
        ZeroResultQueryEntity(
          locationName: 'Gokak',
          categoryName: 'COMMERCIAL',
          searchCount: 142,
          lastSearchedAt: now,
        ),
        ZeroResultQueryEntity(
          locationName: 'Chikodi',
          categoryName: 'RESIDENTIAL',
          searchCount: 98,
          lastSearchedAt: now,
        ),
        ZeroResultQueryEntity(
          locationName: 'Nipani',
          categoryName: 'PLOTLAND',
          searchCount: 76,
          lastSearchedAt: now,
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        metrics: mockMetrics,
        zeroResultDemands: zeroResults,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch capacity metrics',
      );
    }
  }
}
