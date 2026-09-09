import '../../domain/entities/pricing_plan_entity.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../datasources/pricing_remote_datasource.dart';

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource _remoteDataSource;

  PricingRepositoryImpl({PricingRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PricingRemoteDataSourceImpl();

  @override
  Future<List<PricingPlanEntity>> getActivePlans() {
    return _remoteDataSource.fetchAllActivePlans();
  }

  @override
  Future<List<PricingPlanEntity>> getPlansByProductFamily(String productFamily) {
    return _remoteDataSource.fetchPlansByProductFamily(productFamily);
  }

  @override
  Future<PricingPlanEntity?> getPlanById(String planId) {
    return _remoteDataSource.fetchPlanById(planId);
  }
}
