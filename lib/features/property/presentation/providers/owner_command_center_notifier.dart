import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/property/domain/entities/owner_command_center_entities.dart';

class OwnerCommandCenterState extends Equatable {
  final OwnerCommandCenterSummaryEntity summary;
  final List<OwnerPropertyPerformanceEntity> propertyPerformances;
  final List<OwnerCommandLeadEntity> leads;
  final String selectedTimeframe;
  final String? selectedPropertyId;
  final bool isLoading;
  final String? errorMessage;

  const OwnerCommandCenterState({
    this.summary = const OwnerCommandCenterSummaryEntity(),
    this.propertyPerformances = const [],
    this.leads = const [],
    this.selectedTimeframe = '7D',
    this.selectedPropertyId,
    this.isLoading = false,
    this.errorMessage,
  });

  OwnerCommandCenterState copyWith({
    OwnerCommandCenterSummaryEntity? summary,
    List<OwnerPropertyPerformanceEntity>? propertyPerformances,
    List<OwnerCommandLeadEntity>? leads,
    String? selectedTimeframe,
    String? selectedPropertyId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OwnerCommandCenterState(
      summary: summary ?? this.summary,
      propertyPerformances: propertyPerformances ?? this.propertyPerformances,
      leads: leads ?? this.leads,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      selectedPropertyId: selectedPropertyId ?? this.selectedPropertyId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        propertyPerformances,
        leads,
        selectedTimeframe,
        selectedPropertyId,
        isLoading,
        errorMessage,
      ];
}

final ownerCommandCenterNotifierProvider =
    NotifierProvider<OwnerCommandCenterNotifier, OwnerCommandCenterState>(
  OwnerCommandCenterNotifier.new,
);

class OwnerCommandCenterNotifier extends Notifier<OwnerCommandCenterState> {
  @override
  OwnerCommandCenterState build() => const OwnerCommandCenterState();

  Future<void> fetchCommandCenterData({
    required String authenticatedUserId,
    required String targetOwnerId,
    String timeframe = '7D',
    String? propertyId,
  }) async {
    // 1. Dual-Layer Owner Authorization Check
    if (authenticatedUserId != targetOwnerId) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Access Denied: You cannot access another owner\'s private Command Center.',
      );
      throw const AccessDeniedException('Access Denied: Private owner command center access unauthorized.');
    }

    state = state.copyWith(
      isLoading: true,
      selectedTimeframe: timeframe,
      selectedPropertyId: propertyId,
    );

    final now = DateTime.now();

    final mockSummary = OwnerCommandCenterSummaryEntity(
      activeListings: 3,
      hiddenListings: 1,
      onHoldListings: 0,
      totalViews: timeframe == 'today' ? 94 : 340,
      totalEnquiries: timeframe == 'today' ? 13 : 48,
      newLeadsCount: 5,
    );

    final mockPerformances = [
      OwnerPropertyPerformanceEntity(
        propertyId: 'prop_001',
        ownerId: authenticatedUserId,
        title: '3 BHK Villa in Tilakwadi',
        propertyType: 'Residential Villa',
        location: 'Tilakwadi, Belagavi',
        status: 'PUBLISHED',
        views: 184,
        enquiriesCount: 22,
        contactRequestsCount: 14,
        favoritesCount: 12,
        searchAppearances: 420,
        premiumStatus: 'FEATURED',
        publishedDate: now.subtract(const Duration(days: 15)),
        lastActivity: now.subtract(const Duration(hours: 1)),
      ),
      OwnerPropertyPerformanceEntity(
        propertyId: 'prop_002',
        ownerId: authenticatedUserId,
        title: 'Commercial Shop on College Road',
        propertyType: 'Commercial Shop',
        location: 'College Road, Belagavi',
        status: 'PAUSED', // Hidden from public
        views: 95,
        enquiriesCount: 11,
        contactRequestsCount: 6,
        favoritesCount: 5,
        searchAppearances: 180,
        premiumStatus: 'FREE',
        publishedDate: now.subtract(const Duration(days: 30)),
        lastActivity: now.subtract(const Duration(hours: 4)),
      ),
    ];

    final mockLeads = [
      OwnerCommandLeadEntity(
        id: 'cmd_lead_001',
        propertyId: 'prop_001',
        ownerId: authenticatedUserId,
        leadType: 'CALL',
        actorRole: 'BUYER',
        name: 'Ramesh Patil',
        contactMethod: 'Phone Call',
        phoneNumber: '+91 98450 12345',
        propertyTitle: '3 BHK Villa in Tilakwadi',
        location: 'Tilakwadi, Belagavi',
        status: OwnerCommandLeadStatus.newLead,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      OwnerCommandLeadEntity(
        id: 'cmd_lead_002',
        propertyId: 'prop_001',
        ownerId: authenticatedUserId,
        leadType: 'WHATSAPP',
        actorRole: 'BUYER',
        name: 'Suresh Kulkarni',
        contactMethod: 'WhatsApp',
        phoneNumber: '+91 94481 67890',
        propertyTitle: '3 BHK Villa in Tilakwadi',
        location: 'Tilakwadi, Belagavi',
        status: OwnerCommandLeadStatus.contacted,
        notes: 'Requested site visit timing.',
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
    ];

    state = state.copyWith(
      isLoading: false,
      summary: mockSummary,
      propertyPerformances: mockPerformances,
      leads: mockLeads,
    );
  }

  void updateLeadStatus({
    required String authenticatedUserId,
    required String leadId,
    required OwnerCommandLeadStatus newStatus,
  }) {
    final updatedLeads = state.leads.map((lead) {
      if (lead.id == leadId && lead.ownerId == authenticatedUserId) {
        return lead.copyWith(status: newStatus, updatedAt: DateTime.now());
      }
      return lead;
    }).toList();

    state = state.copyWith(leads: updatedLeads);
  }
}
