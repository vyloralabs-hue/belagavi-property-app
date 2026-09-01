import '../../domain/entities/admin_entities.dart';

class PlatformAnalyticsModel extends PlatformAnalyticsEntity {
  const PlatformAnalyticsModel({
    required super.totalUsers,
    required super.activeProperties,
    required super.totalLeadsGenerated,
    required super.grossRevenueInr,
    required super.activeSubscriptions,
    required super.serverUptimePercentage,
    super.pendingModeration,
    super.heldProperties,
    super.disputedProperties,
    super.resolvedDisputes,
    super.rejectedProperties,
    super.submittedToday,
  });

  factory PlatformAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return PlatformAnalyticsModel(
      totalUsers: json['total_users'] as int? ?? 0,
      activeProperties: json['active_properties'] as int? ?? 0,
      totalLeadsGenerated: json['total_leads_generated'] as int? ?? 0,
      grossRevenueInr: (json['gross_revenue_inr'] as num?)?.toDouble() ?? 0.0,
      activeSubscriptions: json['active_subscriptions'] as int? ?? 0,
      serverUptimePercentage: (json['server_uptime_percentage'] as num?)?.toDouble() ?? 99.9,
      pendingModeration: json['pending_moderation'] as int? ?? 12,
      heldProperties: json['held_properties'] as int? ?? 3,
      disputedProperties: json['disputed_properties'] as int? ?? 2,
      resolvedDisputes: json['resolved_disputes'] as int? ?? 14,
      rejectedProperties: json['rejected_properties'] as int? ?? 8,
      submittedToday: json['submitted_today'] as int? ?? 15,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_users': totalUsers,
        'active_properties': activeProperties,
        'total_leads_generated': totalLeadsGenerated,
        'gross_revenue_inr': grossRevenueInr,
        'active_subscriptions': activeSubscriptions,
        'server_uptime_percentage': serverUptimePercentage,
        'pending_moderation': pendingModeration,
        'held_properties': heldProperties,
        'disputed_properties': disputedProperties,
        'resolved_disputes': resolvedDisputes,
        'rejected_properties': rejectedProperties,
        'submitted_today': submittedToday,
      };
}

class SecurityThreatLogModel extends SecurityThreatLogEntity {
  const SecurityThreatLogModel({
    required super.id,
    required super.ipAddress,
    super.userId,
    required super.eventType,
    required super.severity,
    required super.description,
    required super.timestamp,
    super.isBlocked = false,
  });

  factory SecurityThreatLogModel.fromJson(Map<String, dynamic> json) {
    return SecurityThreatLogModel(
      id: json['id'] as String? ?? '',
      ipAddress: json['ip_address'] as String? ?? '',
      userId: json['user_id'] as String?,
      eventType: json['event_type'] as String? ?? 'suspicious_activity',
      severity: ThreatSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ThreatSeverity.medium,
      ),
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isBlocked: json['is_blocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ip_address': ipAddress,
        'user_id': userId,
        'event_type': eventType,
        'severity': severity.name,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'is_blocked': isBlocked,
      };
}

class PlatformBrandingModel extends PlatformBrandingEntity {
  const PlatformBrandingModel({
    required super.brandName,
    required super.logoUrl,
    required super.primaryColorHex,
    required super.secondaryColorHex,
    required super.supportEmail,
    required super.supportPhone,
  });

  factory PlatformBrandingModel.fromJson(Map<String, dynamic> json) {
    return PlatformBrandingModel(
      brandName: json['brand_name'] as String? ?? 'PropertyHub',
      logoUrl: json['logo_url'] as String? ?? '',
      primaryColorHex: json['primary_color_hex'] as String? ?? '#1E3A8A',
      secondaryColorHex: json['secondary_color_hex'] as String? ?? '#0D9488',
      supportEmail: json['support_email'] as String? ?? 'support@propertyhub.com',
      supportPhone: json['support_phone'] as String? ?? '+918000000000',
    );
  }

  Map<String, dynamic> toJson() => {
        'brand_name': brandName,
        'logo_url': logoUrl,
        'primary_color_hex': primaryColorHex,
        'secondary_color_hex': secondaryColorHex,
        'support_email': supportEmail,
        'support_phone': supportPhone,
      };
}

class PlatformConfigModel extends PlatformConfigEntity {
  const PlatformConfigModel({
    super.maintenanceMode = false,
    super.allowNewUserRegistration = true,
    super.requireKycForPosting = true,
    super.defaultCommissionRate = 1.5,
    super.defaultCurrencySymbol = '₹',
  });

  factory PlatformConfigModel.fromJson(Map<String, dynamic> json) {
    return PlatformConfigModel(
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      allowNewUserRegistration: json['allow_new_user_registration'] as bool? ?? true,
      requireKycForPosting: json['require_kyc_for_posting'] as bool? ?? true,
      defaultCommissionRate: (json['default_commission_rate'] as num?)?.toDouble() ?? 1.5,
      defaultCurrencySymbol: json['default_currency_symbol'] as String? ?? '₹',
    );
  }

  Map<String, dynamic> toJson() => {
        'maintenance_mode': maintenanceMode,
        'allow_new_user_registration': allowNewUserRegistration,
        'require_kyc_for_posting': requireKycForPosting,
        'default_commission_rate': defaultCommissionRate,
        'default_currency_symbol': defaultCurrencySymbol,
      };
}

class CMSContentModel extends CMSContentEntity {
  const CMSContentModel({
    required super.pageSlug,
    required super.title,
    required super.contentMarkdown,
    required super.lastUpdated,
  });

  factory CMSContentModel.fromJson(Map<String, dynamic> json) {
    return CMSContentModel(
      pageSlug: json['page_slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      contentMarkdown: json['content_markdown'] as String? ?? '',
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'page_slug': pageSlug,
        'title': title,
        'content_markdown': contentMarkdown,
        'last_updated': lastUpdated.toIso8601String(),
      };
}
