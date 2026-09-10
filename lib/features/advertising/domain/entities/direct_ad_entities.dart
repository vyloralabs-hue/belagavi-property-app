import 'package:equatable/equatable.dart';

enum DirectAdPlacement {
  homeNativeSponsored('HOME_NATIVE_SPONSORED'),
  searchNativeSponsored('SEARCH_NATIVE_SPONSORED'),
  localityBanner('LOCALITY_BANNER'),
  categoryBanner('CATEGORY_BANNER'),
  featuredBusiness('FEATURED_BUSINESS');

  final String value;
  const DirectAdPlacement(this.value);

  static DirectAdPlacement fromString(String val) {
    return DirectAdPlacement.values.firstWhere(
      (e) => e.value == val,
      orElse: () => DirectAdPlacement.homeNativeSponsored,
    );
  }
}

enum DirectAdStatus {
  draft('DRAFT'),
  submitted('SUBMITTED'),
  approved('APPROVED'),
  scheduled('SCHEDULED'),
  active('ACTIVE'),
  paused('PAUSED'),
  expired('EXPIRED'),
  rejected('REJECTED'),
  archived('ARCHIVED');

  final String value;
  const DirectAdStatus(this.value);

  static DirectAdStatus fromString(String val) {
    return DirectAdStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DirectAdStatus.submitted,
    );
  }
}

class DirectAdCampaignEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String placement;
  final String targetCity;
  final String? targetLocality;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String businessName;
  final String? contactPhone;
  final String? contactPerson;
  final String? email;
  final String? websiteUrl;
  final String? rejectionReason;
  final DateTime? createdAt;
  // Creative details
  final String headline;
  final String? bodyText;
  final String? imageUrl;
  final String ctaText;
  final String actionType;
  final String actionValue;
  // Analytics
  final int impressions;
  final int clicks;
  final double ctr;

  const DirectAdCampaignEntity({
    required this.id,
    required this.title,
    this.description,
    required this.placement,
    this.targetCity = 'Belagavi',
    this.targetLocality,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.businessName,
    this.contactPhone,
    this.contactPerson,
    this.email,
    this.websiteUrl,
    this.rejectionReason,
    this.createdAt,
    required this.headline,
    this.bodyText,
    this.imageUrl,
    this.ctaText = 'Learn More',
    this.actionType = 'URL',
    required this.actionValue,
    this.impressions = 0,
    this.clicks = 0,
    this.ctr = 0.0,
  });

  bool get isActive {
    final now = DateTime.now();
    return status.toUpperCase() == 'ACTIVE' &&
        startDate.isBefore(now) &&
        endDate.isAfter(now);
  }

  factory DirectAdCampaignEntity.fromJson(Map<String, dynamic> json) {
    return DirectAdCampaignEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      placement: json['placement'] as String? ?? 'HOME_NATIVE_SPONSORED',
      targetCity: json['target_city'] as String? ?? 'Belagavi',
      targetLocality: json['target_locality'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String) ?? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      status: json['status'] as String? ?? 'SUBMITTED',
      businessName: json['business_name'] as String? ?? 'Local Sponsor',
      contactPhone: json['contact_phone'] as String? ?? json['phone'] as String?,
      contactPerson: json['contact_person'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['website_url'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      headline: json['headline'] as String? ?? json['title'] as String? ?? 'Sponsored',
      bodyText: json['body_text'] as String? ?? json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      ctaText: json['cta_text'] as String? ?? 'Contact Us',
      actionType: json['action_type'] as String? ?? 'URL',
      actionValue: json['action_value'] as String? ?? '',
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      ctr: (json['ctr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        placement,
        targetLocality,
        startDate,
        endDate,
        status,
        businessName,
        headline,
        actionValue,
      ];
}
