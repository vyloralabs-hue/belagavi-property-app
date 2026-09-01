import 'package:fpdart/fpdart.dart';
import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/utils/property_status_workflow.dart';
import '../../domain/entities/advertisement_entity.dart';
import '../../domain/entities/moderation_audit_log_entity.dart';
import '../../domain/repositories/founder_control_repository.dart';

class FounderControlRepositoryImpl implements FounderControlRepository {
  final PropertyRepository _propertyRepository;
  final List<ModerationAuditLogEntity> _auditLogs = [];
  final List<AdvertisementEntity> _advertisements = [];

  FounderControlRepositoryImpl(this._propertyRepository);

  @override
  Future<Either<Failure, PropertyEntity>> emergencyHideProperty({
    required String authenticatedUserId,
    required UserRole userRole,
    required String propertyId,
    required String reason,
  }) async {
    return moderatePropertyStatus(
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
      propertyId: propertyId,
      targetStatus: ListingStatus.disputed,
      action: 'EMERGENCY_HIDE',
      reason: reason,
    );
  }

  @override
  Future<Either<Failure, PropertyEntity>> moderatePropertyStatus({
    required String authenticatedUserId,
    required UserRole userRole,
    required String propertyId,
    required ListingStatus targetStatus,
    required String action,
    required String reason,
  }) async {
    try {
      // Authorization Check
      PlatformAuthorizationGuard.verifyModerationPermission(
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
        actionName: 'moderate property $propertyId',
      );

      final propsResult = await _propertyRepository.getProperties(limit: 500);
      return propsResult.fold(
        (failure) => left(failure),
        (properties) async {
          final existing = properties.firstWhere(
            (p) => p.id == propertyId,
            orElse: () => throw Exception('Property not found.'),
          );

          final prevStatus = existing.status;

          // Status Transition Validation
          if (!PropertyStatusWorkflow.canTransition(
            currentStatus: prevStatus,
            targetStatus: targetStatus,
          )) {
            return left(ServerFailure(
                'Invalid status transition from ${prevStatus.name} to ${targetStatus.name}.'));
          }

          final updated = PropertyEntity(
            id: existing.id,
            ownerId: existing.ownerId,
            title: existing.title,
            description: existing.description,
            category: existing.category,
            type: existing.type,
            status: targetStatus,
            verificationStatus: existing.verificationStatus,
            price: existing.price,
            isNegotiable: existing.isNegotiable,
            specifications: existing.specifications,
            mediaList: existing.mediaList,
            state: existing.state,
            district: existing.district,
            taluk: existing.taluk,
            city: existing.city,
            locality: existing.locality,
            address: existing.address,
            pincode: existing.pincode,
            latitude: existing.latitude,
            longitude: existing.longitude,
            viewsCount: existing.viewsCount,
            features: existing.features,
            createdAt: existing.createdAt,
            updatedAt: DateTime.now(),
          );

          final updateResult = await _propertyRepository.updateProperty(
            updated,
            authenticatedUserId: existing.ownerId, // Preserve owner ID
          );

          return updateResult.fold(
            (failure) => left(failure),
            (saved) {
              // Record Moderation Audit Entry
              final auditLog = ModerationAuditLogEntity(
                id: 'log_${DateTime.now().millisecondsSinceEpoch}',
                actorId: authenticatedUserId,
                actorRole: userRole,
                propertyId: propertyId,
                action: action,
                reason: reason,
                timestamp: DateTime.now(),
                previousStatus: prevStatus,
                newStatus: targetStatus,
              );
              _auditLogs.add(auditLog);

              return right(saved);
            },
          );
        },
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ModerationAuditLogEntity>>> getModerationAuditLogs({
    required String authenticatedUserId,
    required UserRole userRole,
    String? propertyId,
  }) async {
    try {
      PlatformAuthorizationGuard.verifyModerationPermission(
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
        actionName: 'view moderation audit logs',
      );

      final filtered = propertyId != null
          ? _auditLogs.where((l) => l.propertyId == propertyId).toList()
          : List<ModerationAuditLogEntity>.from(_auditLogs);

      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return right(filtered);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdvertisementEntity>> createAdvertisement({
    required String authenticatedUserId,
    required UserRole userRole,
    required AdvertisementEntity ad,
  }) async {
    try {
      PlatformAuthorizationGuard.verifyAdManagementPermission(
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
        actionName: 'create advertisement',
      );

      final newAd = ad.copyWith(
        id: ad.id.isEmpty ? 'ad_${DateTime.now().millisecondsSinceEpoch}' : ad.id,
        createdBy: authenticatedUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _advertisements.add(newAd);
      return right(newAd);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdvertisementEntity>> updateAdvertisement({
    required String authenticatedUserId,
    required UserRole userRole,
    required AdvertisementEntity ad,
  }) async {
    try {
      PlatformAuthorizationGuard.verifyAdManagementPermission(
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
        actionName: 'update advertisement',
      );

      final index = _advertisements.indexWhere((a) => a.id == ad.id);
      if (index == -1) {
        return left(const ServerFailure('Advertisement not found.'));
      }

      final updatedAd = ad.copyWith(updatedAt: DateTime.now());
      _advertisements[index] = updatedAd;
      return right(updatedAd);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdvertisement({
    required String authenticatedUserId,
    required UserRole userRole,
    required String adId,
  }) async {
    try {
      PlatformAuthorizationGuard.verifyAdManagementPermission(
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
        actionName: 'delete advertisement',
      );

      _advertisements.removeWhere((a) => a.id == adId);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdvertisementEntity>>> getAdvertisements({
    AdPlacement? placement,
    bool activeOnly = false,
  }) async {
    try {
      final now = DateTime.now();
      var list = List<AdvertisementEntity>.from(_advertisements);

      if (placement != null) {
        list = list.where((a) => a.placement == placement).toList();
      }

      if (activeOnly) {
        list = list.where((a) => a.isActiveNow(now)).toList();
      }

      // Priority ordering: lower priority number = higher urgency (Priority 1 > 2 > 3)
      list.sort((a, b) => a.priority.compareTo(b.priority));
      return right(list);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
