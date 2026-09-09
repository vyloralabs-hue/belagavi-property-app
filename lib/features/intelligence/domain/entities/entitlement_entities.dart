import 'package:equatable/equatable.dart';

class UserEntitlementEntity extends Equatable {
  final String id;
  final String userId;
  final String entitlementKey; // 'property_watch', 'survey_monitoring', 'create_listing', etc.
  final int totalQuota;
  final int usedQuota;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntitlementEntity({
    required this.id,
    required this.userId,
    required this.entitlementKey,
    required this.totalQuota,
    required this.usedQuota,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get remainingQuota => (totalQuota - usedQuota).clamp(0, totalQuota);

  bool get hasAvailableQuota => !isExpired && remainingQuota > 0;

  @override
  List<Object?> get props => [
        id,
        userId,
        entitlementKey,
        totalQuota,
        usedQuota,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}
