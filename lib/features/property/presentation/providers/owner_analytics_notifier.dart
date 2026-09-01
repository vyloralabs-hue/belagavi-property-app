import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/property/domain/entities/owner_analytics_entities.dart';

class OwnerAnalyticsState extends Equatable {
  final String selectedTimeframe;
  final String? selectedPropertyId;
  final OwnerDailyAnalyticsEntity? analytics;
  final List<OwnerLeadEntity> leads;
  final bool isLoading;
  final String? errorMessage;

  const OwnerAnalyticsState({
    this.selectedTimeframe = '7D',
    this.selectedPropertyId,
    this.analytics,
    this.leads = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OwnerAnalyticsState copyWith({
    String? selectedTimeframe,
    String? selectedPropertyId,
    OwnerDailyAnalyticsEntity? analytics,
    List<OwnerLeadEntity>? leads,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OwnerAnalyticsState(
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      selectedPropertyId: selectedPropertyId ?? this.selectedPropertyId,
      analytics: analytics ?? this.analytics,
      leads: leads ?? this.leads,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedTimeframe,
        selectedPropertyId,
        analytics,
        leads,
        isLoading,
        errorMessage,
      ];
}

final ownerAnalyticsNotifierProvider =
    NotifierProvider<OwnerAnalyticsNotifier, OwnerAnalyticsState>(
  OwnerAnalyticsNotifier.new,
);

class OwnerAnalyticsNotifier extends Notifier<OwnerAnalyticsState> {
  @override
  OwnerAnalyticsState build() => const OwnerAnalyticsState();

  Future<void> fetchOwnerDashboardData({
    required String authenticatedUserId,
    required String targetOwnerId,
    String? propertyId,
    String timeframe = '7D',
  }) async {
    // 1. Strict Owner Authorization Check: Owner A can ONLY query Owner A's data
    if (authenticatedUserId != targetOwnerId) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Access Denied: You cannot view another owner\'s private analytics.',
      );
      throw const AccessDeniedException('Access Denied: Private owner analytics access unauthorized.');
    }

    state = state.copyWith(
      isLoading: true,
      selectedTimeframe: timeframe,
      selectedPropertyId: propertyId,
    );

    final now = DateTime.now();

    // Mock deterministic analytics & lead data isolated for target owner
    final mockAnalytics = OwnerDailyAnalyticsEntity(
      propertyId: propertyId ?? 'all_properties',
      ownerId: authenticatedUserId,
      date: now,
      totalViews: timeframe == 'today' ? 94 : 284,
      searchAppearances: timeframe == 'today' ? 186 : 640,
      detailOpens: timeframe == 'today' ? 94 : 284,
      contactClicks: timeframe == 'today' ? 13 : 42,
      callClicks: timeframe == 'today' ? 8 : 26,
      whatsAppClicks: timeframe == 'today' ? 5 : 16,
      messagesCount: 4,
      buyerLeads: timeframe == 'today' ? 27 : 89,
      sellerLeads: timeframe == 'today' ? 4 : 12,
      favoritesCount: 18,
      promotionImpressions: 420,
      promotionClicks: 65,
    );

    final mockLeads = [
      OwnerLeadEntity(
        id: 'lead_001',
        propertyId: 'prop_001',
        ownerId: authenticatedUserId,
        leadType: OwnerLeadType.call,
        actorRole: 'BUYER',
        name: 'Ramesh Patil',
        contactMethod: 'Phone Call',
        phoneNumber: '+91 98450 12345',
        propertyTitle: '3 BHK Villa in Tilakwadi',
        location: 'Tilakwadi, Belagavi',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      OwnerLeadEntity(
        id: 'lead_002',
        propertyId: 'prop_001',
        ownerId: authenticatedUserId,
        leadType: OwnerLeadType.whatsApp,
        actorRole: 'BUYER',
        name: 'Suresh Kulkarni',
        contactMethod: 'WhatsApp',
        phoneNumber: '+91 94481 67890',
        propertyTitle: '3 BHK Villa in Tilakwadi',
        location: 'Tilakwadi, Belagavi',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      OwnerLeadEntity(
        id: 'lead_003',
        propertyId: 'prop_002',
        ownerId: authenticatedUserId,
        leadType: OwnerLeadType.contactRequest,
        actorRole: 'SELLER',
        name: 'Anand Deshpande',
        contactMethod: 'Inquiry Form',
        phoneNumber: '+91 98800 54321',
        email: 'anand.deshpande@email.com',
        propertyTitle: 'Commercial Shop on College Road',
        location: 'College Road, Belagavi',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    state = state.copyWith(
      isLoading: false,
      analytics: mockAnalytics,
      leads: mockLeads,
    );
  }
}
