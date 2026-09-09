import 'package:equatable/equatable.dart';

/// Server-Authoritative Pricing Plan Entity for Belagavi Property.
/// Governs all 7 product families with integer paise precision.
class PricingPlanEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String productFamily;
  final int priceMinorUnits; // In integer paise (e.g., ₹149 = 14900)
  final String currency;
  final int validityDays;
  final int creditCount;
  final bool isActive;
  final int sortOrder;
  final Map<String, dynamic> metadata;

  const PricingPlanEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.productFamily,
    required this.priceMinorUnits,
    this.currency = 'INR',
    required this.validityDays,
    this.creditCount = 1,
    this.isActive = true,
    this.sortOrder = 0,
    this.metadata = const {},
  });

  /// Price in full Rupee units (e.g. 149.0 for 14900 paise).
  double get priceInRupees => priceMinorUnits / 100.0;

  /// Integer Rupee amount (e.g. 149 for 14900 paise).
  int get amountInRupees => priceMinorUnits ~/ 100;

  /// Formatted rupee string e.g. "₹149" or "₹1,499".
  String get formattedPrice {
    final rupees = amountInRupees;
    if (rupees >= 1000) {
      final s = rupees.toString();
      // Indian numbering formatting
      if (s.length == 4) {
        return '₹${s.substring(0, 1)},${s.substring(1)}';
      } else if (s.length == 5) {
        return '₹${s.substring(0, 2)},${s.substring(2)}';
      }
    }
    return '₹$rupees';
  }

  /// Human-readable duration string e.g. "30 Days", "1 Year".
  String get durationLabel {
    if (validityDays == 365) return '1 Year';
    if (validityDays == 90) return '90 Days';
    if (validityDays == 30) return '30 Days';
    if (validityDays == 10) return '10 Days';
    return '$validityDays Days';
  }

  // Product Family Classification
  bool get isResidentialListing => productFamily == 'residential_listing';
  bool get isCommercialListing => productFamily == 'commercial_listing';
  bool get isLegalNoticePublication => productFamily == 'legal_notice_publication';
  bool get isDisputePublication => productFamily == 'dispute_publication';
  bool get isPropertyWatch => productFamily == 'property_watch';
  bool get isSurveyMonitoring => productFamily == 'survey_monitoring';
  bool get isBuyerUnlock => productFamily == 'buyer_unlock';

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        productFamily,
        priceMinorUnits,
        currency,
        validityDays,
        creditCount,
        isActive,
        sortOrder,
        metadata,
      ];
}
