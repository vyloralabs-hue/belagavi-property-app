import '../../../../core/utils/typedefs.dart';
import '../entities/production_entities.dart';

abstract class ProductionEngineRepository {
  FutureEither<HealthStatusEntity> checkSystemHealth();

  FutureEither<SecurityAuditReportEntity> runSecurityAudit();

  FutureEither<bool> validateMultiPlatformManifests();
}
