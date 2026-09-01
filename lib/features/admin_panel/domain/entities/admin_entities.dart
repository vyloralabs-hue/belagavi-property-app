import 'package:equatable/equatable.dart';

enum ThreatSeverity { low, medium, high, critical }

class PlatformAnalyticsEntity extends Equatable {
  final int totalUsers;
  final int activeProperties;
  final int totalLeadsGenerated;
  final double grossRevenueInr;
  final int activeSubscriptions;
  final double serverUptimePercentage;
  final int pendingModeration;
  final int heldProperties;
  final int disputedProperties;
  final int resolvedDisputes;
  final int rejectedProperties;
  final int submittedToday;

  const PlatformAnalyticsEntity({
    required this.totalUsers,
    required this.activeProperties,
    required this.totalLeadsGenerated,
    required this.grossRevenueInr,
    required this.activeSubscriptions,
    required this.serverUptimePercentage,
    this.pendingModeration = 12,
    this.heldProperties = 3,
    this.disputedProperties = 2,
    this.resolvedDisputes = 14,
    this.rejectedProperties = 8,
    this.submittedToday = 15,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        activeProperties,
        totalLeadsGenerated,
        grossRevenueInr,
        activeSubscriptions,
        serverUptimePercentage,
        pendingModeration,
        heldProperties,
        disputedProperties,
        resolvedDisputes,
        rejectedProperties,
        submittedToday,
      ];
}

class SecurityThreatLogEntity extends Equatable {
  final String id;
  final String ipAddress;
  final String? userId;
  final String eventType; // 'failed_login_burst', 'ddos_pattern', 'unauthorized_admin_access'
  final ThreatSeverity severity;
  final String description;
  final DateTime timestamp;
  final bool isBlocked;

  const SecurityThreatLogEntity({
    required this.id,
    required this.ipAddress,
    this.userId,
    required this.eventType,
    required this.severity,
    required this.description,
    required this.timestamp,
    this.isBlocked = false,
  });

  @override
  List<Object?> get props => [
        id,
        ipAddress,
        userId,
        eventType,
        severity,
        description,
        timestamp,
        isBlocked,
      ];
}

class PlatformBrandingEntity extends Equatable {
  final String brandName;
  final String logoUrl;
  final String primaryColorHex;
  final String secondaryColorHex;
  final String supportEmail;
  final String supportPhone;

  const PlatformBrandingEntity({
    required this.brandName,
    required this.logoUrl,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.supportEmail,
    required this.supportPhone,
  });

  @override
  List<Object?> get props => [
        brandName,
        logoUrl,
        primaryColorHex,
        secondaryColorHex,
        supportEmail,
        supportPhone,
      ];
}

class PlatformConfigEntity extends Equatable {
  final bool maintenanceMode;
  final bool allowNewUserRegistration;
  final bool requireKycForPosting;
  final double defaultCommissionRate;
  final String defaultCurrencySymbol;

  const PlatformConfigEntity({
    this.maintenanceMode = false,
    this.allowNewUserRegistration = true,
    this.requireKycForPosting = true,
    this.defaultCommissionRate = 1.5,
    this.defaultCurrencySymbol = '₹',
  });

  @override
  List<Object?> get props => [
        maintenanceMode,
        allowNewUserRegistration,
        requireKycForPosting,
        defaultCommissionRate,
        defaultCurrencySymbol,
      ];
}

class CMSContentEntity extends Equatable {
  final String pageSlug; // 'terms-of-service', 'privacy-policy', 'about-us'
  final String title;
  final String contentMarkdown;
  final DateTime lastUpdated;

  const CMSContentEntity({
    required this.pageSlug,
    required this.title,
    required this.contentMarkdown,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [pageSlug, title, contentMarkdown, lastUpdated];
}
