import 'package:equatable/equatable.dart';

enum SystemHealthStatus { healthy, degraded, critical }

class HealthStatusEntity extends Equatable {
  final SystemHealthStatus status;
  final int apiLatencyMs;
  final bool isDatabaseConnected;
  final bool isAuthInitialized;
  final bool isLocalStorageReady;
  final DateTime checkedAt;

  const HealthStatusEntity({
    required this.status,
    required this.apiLatencyMs,
    required this.isDatabaseConnected,
    required this.isAuthInitialized,
    required this.isLocalStorageReady,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [
        status,
        apiLatencyMs,
        isDatabaseConnected,
        isAuthInitialized,
        isLocalStorageReady,
        checkedAt,
      ];
}

class SecurityAuditReportEntity extends Equatable {
  final bool isRlsPolicyEnabled;
  final bool isMfaEnforced;
  final bool isIpThreatFilterActive;
  final int totalSecurityViolationsLogged;
  final String complianceGrade; // 'A+', 'A', 'B'

  const SecurityAuditReportEntity({
    required this.isRlsPolicyEnabled,
    required this.isMfaEnforced,
    required this.isIpThreatFilterActive,
    required this.totalSecurityViolationsLogged,
    required this.complianceGrade,
  });

  @override
  List<Object?> get props => [
        isRlsPolicyEnabled,
        isMfaEnforced,
        isIpThreatFilterActive,
        totalSecurityViolationsLogged,
        complianceGrade,
      ];
}
