import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/production_entities.dart';
import '../../domain/repositories/production_engine_repository.dart';
import '../datasources/production_engine_remote_datasource.dart';
import '../../utils/multi_platform_manifest_validator.dart';

@LazySingleton(as: ProductionEngineRepository)
class ProductionEngineRepositoryImpl extends BaseRepository implements ProductionEngineRepository {
  final ProductionEngineRemoteDataSource _remoteDataSource;

  ProductionEngineRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<HealthStatusEntity> checkSystemHealth() async {
    return safeCall(() => _remoteDataSource.checkHealth());
  }

  @override
  FutureEither<SecurityAuditReportEntity> runSecurityAudit() async {
    return safeCall(() => _remoteDataSource.runAudit());
  }

  @override
  FutureEither<bool> validateMultiPlatformManifests() async {
    return safeCall(() async {
      return MultiPlatformManifestValidator.areAllManifestsValid();
    });
  }
}
