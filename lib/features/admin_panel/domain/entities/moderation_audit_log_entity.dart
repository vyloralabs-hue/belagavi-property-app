import 'package:equatable/equatable.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

class ModerationAuditLogEntity extends Equatable {
  final String id;
  final String actorId;
  final UserRole actorRole;
  final String propertyId;
  final String action; // 'EMERGENCY_HIDE', 'PAUSE', 'REJECT', 'ARCHIVE', 'RESTORE', 'MARK_DISPUTED'
  final String reason; // 'Unauthorized Listing', 'Ownership Dispute', 'Fraud Suspicion', 'Duplicate Listing', 'Incorrect Information', 'Legal Complaint', 'Policy Violation', 'Other'
  final DateTime timestamp;
  final ListingStatus previousStatus;
  final ListingStatus newStatus;

  const ModerationAuditLogEntity({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.propertyId,
    required this.action,
    required this.reason,
    required this.timestamp,
    required this.previousStatus,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [
        id,
        actorId,
        actorRole,
        propertyId,
        action,
        reason,
        timestamp,
        previousStatus,
        newStatus,
      ];
}
