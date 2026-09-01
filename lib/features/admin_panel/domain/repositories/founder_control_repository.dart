import 'package:fpdart/fpdart.dart';
import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../entities/advertisement_entity.dart';
import '../entities/moderation_audit_log_entity.dart';

abstract class FounderControlRepository {
  Future<Either<Failure, PropertyEntity>> emergencyHideProperty({
    required String authenticatedUserId,
    required UserRole userRole,
    required String propertyId,
    required String reason,
  });

  Future<Either<Failure, PropertyEntity>> moderatePropertyStatus({
    required String authenticatedUserId,
    required UserRole userRole,
    required String propertyId,
    required ListingStatus targetStatus,
    required String action,
    required String reason,
  });

  Future<Either<Failure, List<ModerationAuditLogEntity>>> getModerationAuditLogs({
    required String authenticatedUserId,
    required UserRole userRole,
    String? propertyId,
  });

  Future<Either<Failure, AdvertisementEntity>> createAdvertisement({
    required String authenticatedUserId,
    required UserRole userRole,
    required AdvertisementEntity ad,
  });

  Future<Either<Failure, AdvertisementEntity>> updateAdvertisement({
    required String authenticatedUserId,
    required UserRole userRole,
    required AdvertisementEntity ad,
  });

  Future<Either<Failure, void>> deleteAdvertisement({
    required String authenticatedUserId,
    required UserRole userRole,
    required String adId,
  });

  Future<Either<Failure, List<AdvertisementEntity>>> getAdvertisements({
    AdPlacement? placement,
    bool activeOnly = false,
  });
}
