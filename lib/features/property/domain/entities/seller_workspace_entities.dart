import 'package:equatable/equatable.dart';

enum ProfessionalSellerTier {
  individualOwner,
  independentBroker,
  brokerAgency,
  builderDeveloper,
}

class BrokerAgencyProfile extends Equatable {
  final String id;
  final String agencyName;
  final String? reraRegistrationNumber;
  final String primaryContactPhone;
  final String primaryContactEmail;
  final List<String> operatingCities;
  final List<String> primaryLocalities;
  final int totalTeamMembers;
  final bool isKycVerified;
  final DateTime createdAt;

  const BrokerAgencyProfile({
    required this.id,
    required this.agencyName,
    this.reraRegistrationNumber,
    required this.primaryContactPhone,
    required this.primaryContactEmail,
    this.operatingCities = const [],
    this.primaryLocalities = const [],
    this.totalTeamMembers = 1,
    this.isKycVerified = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        agencyName,
        reraRegistrationNumber,
        primaryContactPhone,
        primaryContactEmail,
        operatingCities,
        totalTeamMembers,
        isKycVerified,
      ];
}

class SellerWorkspaceSummary extends Equatable {
  final String sellerId;
  final ProfessionalSellerTier tier;
  final int totalListings;
  final int publishedListings;
  final int underReviewListings;
  final int pausedListings;
  final int closedListings;
  final int totalInboundLeads;
  final int pendingSiteVisits;
  final int activeOffers;
  final double overallQualityScore; // 0.0 to 100.0
  final double averageConversionRate;

  const SellerWorkspaceSummary({
    required this.sellerId,
    required this.tier,
    this.totalListings = 0,
    this.publishedListings = 0,
    this.underReviewListings = 0,
    this.pausedListings = 0,
    this.closedListings = 0,
    this.totalInboundLeads = 0,
    this.pendingSiteVisits = 0,
    this.activeOffers = 0,
    this.overallQualityScore = 0.0,
    this.averageConversionRate = 0.0,
  });

  @override
  List<Object?> get props => [
        sellerId,
        tier,
        totalListings,
        publishedListings,
        underReviewListings,
        pausedListings,
        closedListings,
        totalInboundLeads,
        pendingSiteVisits,
        activeOffers,
        overallQualityScore,
        averageConversionRate,
      ];
}
