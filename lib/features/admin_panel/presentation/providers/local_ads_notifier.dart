import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import '../../domain/entities/advertisement_entity.dart';
import '../../domain/repositories/founder_control_repository.dart';

enum LocalAdsStatus { initial, loading, loaded, error }

class LocalAdsState extends Equatable {
  final LocalAdsStatus status;
  final List<AdvertisementEntity> advertisements;
  final String? errorMessage;

  const LocalAdsState({
    this.status = LocalAdsStatus.initial,
    this.advertisements = const [],
    this.errorMessage,
  });

  LocalAdsState copyWith({
    LocalAdsStatus? status,
    List<AdvertisementEntity>? advertisements,
    String? errorMessage,
  }) {
    return LocalAdsState(
      status: status ?? this.status,
      advertisements: advertisements ?? this.advertisements,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, advertisements, errorMessage];
}

class LocalAdsNotifier extends StateNotifier<LocalAdsState> {
  final FounderControlRepository _repository;

  LocalAdsNotifier(this._repository) : super(const LocalAdsState());

  Future<void> fetchAdvertisements({AdPlacement? placement, bool activeOnly = false}) async {
    state = state.copyWith(status: LocalAdsStatus.loading);
    final result = await _repository.getAdvertisements(placement: placement, activeOnly: activeOnly);

    result.fold(
      (failure) => state = state.copyWith(
        status: LocalAdsStatus.error,
        errorMessage: failure.message,
      ),
      (list) => state = state.copyWith(
        status: LocalAdsStatus.loaded,
        advertisements: list,
      ),
    );
  }

  Future<bool> createAd({
    required String authenticatedUserId,
    required UserRole userRole,
    required AdvertisementEntity ad,
  }) async {
    final result = await _repository.createAdvertisement(
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
      ad: ad,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (created) {
        fetchAdvertisements();
        return true;
      },
    );
  }

  Future<bool> updateAd({
    required String authenticatedUserId,
    required UserRole userRole,
    required AdvertisementEntity ad,
  }) async {
    final result = await _repository.updateAdvertisement(
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
      ad: ad,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updated) {
        fetchAdvertisements();
        return true;
      },
    );
  }

  Future<bool> toggleAdStatus({
    required String authenticatedUserId,
    required UserRole userRole,
    required String adId,
    required AdStatus targetStatus,
  }) async {
    final existing = state.advertisements.firstWhere(
      (a) => a.id == adId,
      orElse: () => throw Exception('Ad not found.'),
    );

    final updated = existing.copyWith(status: targetStatus);
    return updateAd(authenticatedUserId: authenticatedUserId, userRole: userRole, ad: updated);
  }

  Future<bool> deleteAd({
    required String authenticatedUserId,
    required UserRole userRole,
    required String adId,
  }) async {
    final result = await _repository.deleteAdvertisement(
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
      adId: adId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        fetchAdvertisements();
        return true;
      },
    );
  }
}
