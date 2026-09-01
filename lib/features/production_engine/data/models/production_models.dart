import '../../domain/entities/production_entities.dart';

class HealthStatusModel extends HealthStatusEntity {
  const HealthStatusModel({
    required super.status,
    required super.apiLatencyMs,
    required super.isDatabaseConnected,
    required super.isAuthInitialized,
    required super.isLocalStorageReady,
    required super.checkedAt,
  });

  factory HealthStatusModel.fromJson(Map<String, dynamic> json) {
    return HealthStatusModel(
      status: SystemHealthStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SystemHealthStatus.healthy,
      ),
      apiLatencyMs: json['api_latency_ms'] as int? ?? 25,
      isDatabaseConnected: json['is_database_connected'] as bool? ?? true,
      isAuthInitialized: json['is_auth_initialized'] as bool? ?? true,
      isLocalStorageReady: json['is_local_storage_ready'] as bool? ?? true,
      checkedAt: json['checked_at'] != null
          ? DateTime.parse(json['checked_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'api_latency_ms': apiLatencyMs,
        'is_database_connected': isDatabaseConnected,
        'is_auth_initialized': isAuthInitialized,
        'is_local_storage_ready': isLocalStorageReady,
        'checked_at': checkedAt.toIso8601String(),
      };
}

class SecurityAuditReportModel extends SecurityAuditReportEntity {
  const SecurityAuditReportModel({
    required super.isRlsPolicyEnabled,
    required super.isMfaEnforced,
    required super.isIpThreatFilterActive,
    required super.totalSecurityViolationsLogged,
    required super.complianceGrade,
  });

  factory SecurityAuditReportModel.fromJson(Map<String, dynamic> json) {
    return SecurityAuditReportModel(
      isRlsPolicyEnabled: json['is_rls_policy_enabled'] as bool? ?? true,
      isMfaEnforced: json['is_mfa_enforced'] as bool? ?? true,
      isIpThreatFilterActive: json['is_ip_threat_filter_active'] as bool? ?? true,
      totalSecurityViolationsLogged: json['total_security_violations_logged'] as int? ?? 0,
      complianceGrade: json['compliance_grade'] as String? ?? 'A+',
    );
  }

  Map<String, dynamic> toJson() => {
        'is_rls_policy_enabled': isRlsPolicyEnabled,
        'is_mfa_enforced': isMfaEnforced,
        'is_ip_threat_filter_active': isIpThreatFilterActive,
        'total_security_violations_logged': totalSecurityViolationsLogged,
        'compliance_grade': complianceGrade,
      };
}
