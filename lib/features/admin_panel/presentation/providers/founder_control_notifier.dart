import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../../domain/entities/moderation_audit_log_entity.dart';
import '../../domain/repositories/founder_control_repository.dart';

enum FounderControlStatus { initial, loading, loaded, error }

class FounderControlState extends Equatable {
  final FounderControlStatus status;
  final List<PropertyEntity> properties;
  final List<PropertyEntity> disputedProperties;
  final List<ModerationAuditLogEntity> auditLogs;
  final String? errorMessage;

  const FounderControlState({
    this.status = FounderControlStatus.initial,
    this.properties = const [],
    this.disputedProperties = const [],
    this.auditLogs = const [],
    this.errorMessage,
  });

  FounderControlState copyWith({
    FounderControlStatus? status,
    List<PropertyEntity>? properties,
    List<PropertyEntity>? disputedProperties,
    List<ModerationAuditLogEntity>? auditLogs,
    String? errorMessage,
  }) {
    return FounderControlState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      disputedProperties: disputedProperties ?? this.disputedProperties,
      auditLogs: auditLogs ?? this.auditLogs,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, properties, disputedProperties, auditLogs, errorMessage];
}

class FounderControlNotifier extends StateNotifier<FounderControlState> {
  final FounderControlRepository _repository;

  FounderControlNotifier(this._repository) : super(const FounderControlState());

  Future<void> fetchAuditLogs({
    required String authenticatedUserId,
    required UserRole userRole,
    String? propertyId,
  }) async {
    state = state.copyWith(status: FounderControlStatus.loading);
    final result = await _repository.getModerationAuditLogs(
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
      propertyId: propertyId,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: FounderControlStatus.error,
        errorMessage: failure.message,
      ),
      (logs) => state = state.copyWith(
        status: FounderControlStatus.loaded,
        auditLogs: logs,
      ),
    );
  }

  Future<bool> emergencyHideProperty({
    required String authenticatedUserId,
    required UserRole userRole,
    required String propertyId,
    required String reason,
  }) async {
    final result = await _repository.emergencyHideProperty(
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
      propertyId: propertyId,
      reason: reason,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updatedProperty) {
        // Refresh audit logs
        fetchAuditLogs(authenticatedUserId: authenticatedUserId, userRole: userRole);
        return true;
      },
    );
  }

  Future<bool> moderateProperty({
    required String authenticatedUserId,
    required UserRole userRole,
    required String propertyId,
    required ListingStatus targetStatus,
    required String action,
    required String reason,
  }) async {
    final result = await _repository.moderatePropertyStatus(
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
      propertyId: propertyId,
      targetStatus: targetStatus,
      action: action,
      reason: reason,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updatedProperty) {
        fetchAuditLogs(authenticatedUserId: authenticatedUserId, userRole: userRole);
        return true;
      },
    );
  }
}
