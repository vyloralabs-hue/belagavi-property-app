/// Central Server-Authoritative Listing Pricing Configuration
/// Enforces business rules:
/// - Disputed Property Listing = â‚¹500/property
/// - Purchase / Sale Deal = â‚¹500/deal
/// - Standard Marketplace Categories (Residential, Plots, Commercial, Raw Land) = Configurable standard rates
/// - Builder Projects = Configurable developer project tier
class ListingPricingConfig {
  ListingPricingConfig._();

  // Core Specialized Listing Fees
  static const int disputeListingFeeInRupees = 500;
  static const int purchaseSaleDealFeeInRupees = 500;
  static const int standardPropertyListingFeeInRupees = 0; // Free basic tier
  static const int builderProjectListingFeeInRupees = 2499;

  // Currency & Formatted Helpers
  static const String currencySymbol = 'â‚¹';

  static String get formattedDisputeListingFee => '$currencySymbol$disputeListingFeeInRupees';
  static String get formattedPurchaseSaleDealFee => '$currencySymbol$purchaseSaleDealFeeInRupees';
  static String get formattedStandardListingFee => standardPropertyListingFeeInRupees == 0 ? 'Free' : '$currencySymbol$standardPropertyListingFeeInRupees';
  static String get formattedBuilderProjectFee => '$currencySymbol$builderProjectListingFeeInRupees';

  // Dispute Property Pricing Meta
  static const Map<String, dynamic> disputePricing = {
    'feeRupees': disputeListingFeeInRupees,
    'feePaise': disputeListingFeeInRupees * 100,
    'legalDocumentStorageIncluded': true,
    'privateStorageEncrypted': true,
    'moderationReviewSlaHours': 24,
  };

  // Purchase / Sale Transaction Pricing Meta
  static const Map<String, dynamic> purchaseSalePricing = {
    'feeRupees': purchaseSaleDealFeeInRupees,
    'feePaise': purchaseSaleDealFeeInRupees * 100,
    'dueDiligenceChecklistIncluded': true,
    'saveWithoutDocsSupported': true,
    'attachDocsLaterSupported': true,
  };
}