import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/repositories/property_repository.dart';
import '../../utils/owner_identity_bridge.dart';

enum VaultStateStatus { initial, loading, loaded, error }

class VaultState extends Equatable {
  final VaultStateStatus status;
  final String activeTab; // 'Active', 'Expired', 'Drafts', 'Sold', 'Legal Notices', 'Disputes'
  final List<PropertyEntity> allProperties;
  final List<Map<String, dynamic>> legalNotices;
  final List<Map<String, dynamic>> disputes;
  final String? errorMessage;

  const VaultState({
    this.status = VaultStateStatus.initial,
    this.activeTab = 'Active',
    this.allProperties = const [],
    this.legalNotices = const [],
    this.disputes = const [],
    this.errorMessage,
  });

  List<PropertyEntity> get activeProperties => allProperties
      .where((p) => p.status.isPubliclyVisible && !p.isPaused && !p.isListingExpired)
      .toList();

  List<PropertyEntity> get expiredProperties =>
      allProperties.where((p) => p.isListingExpired).toList();

  List<PropertyEntity> get draftProperties =>
      allProperties.where((p) => p.status == ListingStatus.draft).toList();

  List<PropertyEntity> get soldProperties =>
      allProperties.where((p) => p.status == ListingStatus.sold).toList();

  int get activeCount => activeProperties.length;
  int get expiredCount => expiredProperties.length;
  int get draftCount => draftProperties.length;
  int get soldCount => soldProperties.length;
  int get legalNoticeCount => legalNotices.length;
  int get disputeCount => disputes.length;

  VaultState copyWith({
    VaultStateStatus? status,
    String? activeTab,
    List<PropertyEntity>? allProperties,
    List<Map<String, dynamic>>? legalNotices,
    List<Map<String, dynamic>>? disputes,
    String? errorMessage,
  }) {
    return VaultState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      allProperties: allProperties ?? this.allProperties,
      legalNotices: legalNotices ?? this.legalNotices,
      disputes: disputes ?? this.disputes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeTab,
        allProperties,
        legalNotices,
        disputes,
        errorMessage,
      ];
}

class VaultNotifier extends StateNotifier<VaultState> {
  final PropertyRepository _propertyRepository;
  final SupabaseService _supabaseService;

  VaultNotifier(this._propertyRepository, {SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService(),
        super(const VaultState());

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  Future<void> loadVault(String authenticatedUserId) async {
    state = state.copyWith(status: VaultStateStatus.loading, errorMessage: null);

    try {
      // 1. Fetch all owner properties via repository
      final propResult = await _propertyRepository.getPropertiesByOwner(ownerId: authenticatedUserId);
      final properties = propResult.fold(
        (f) => <PropertyEntity>[],
        (list) => list,
      );

      // 2. Fetch owner's legal notices & disputes via Supabase if initialized
      List<Map<String, dynamic>> notices = [];
      List<Map<String, dynamic>> disputes = [];

      if (_supabaseService.isInitialized) {
        final profileId = await OwnerIdentityBridge.resolveProfileId(
          authenticatedUserId,
          supabaseService: _supabaseService,
        );

        // Fetch legal notices
        try {
          final query = _supabaseService.from('legal_notices').select();
          final noticeRes = await query.or(
            'publisher_id.eq.$authenticatedUserId${profileId != null ? ',publisher_id.eq.$profileId' : ''}',
          );
          notices = List<Map<String, dynamic>>.from(noticeRes as List);
        } catch (_) {}

        // Fetch disputes
        try {
          final query = _supabaseService.from('dispute_listings').select();
          final disputeRes = await query.or(
            'creator_id.eq.$authenticatedUserId${profileId != null ? ',creator_id.eq.$profileId' : ''}',
          );
          disputes = List<Map<String, dynamic>>.from(disputeRes as List);
        } catch (_) {}
      }

      state = state.copyWith(
        status: VaultStateStatus.loaded,
        allProperties: properties,
        legalNotices: notices,
        disputes: disputes,
      );
    } catch (e) {
      state = state.copyWith(
        status: VaultStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
