import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/monetization_entities.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../datasources/monetization_remote_datasource.dart';

@LazySingleton(as: MonetizationRepository)
class MonetizationRepositoryImpl extends BaseRepository implements MonetizationRepository {
  final MonetizationRemoteDataSource _remoteDataSource;

  MonetizationRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<SubscriptionPlanEntity>> getSubscriptionPlans() async {
    return safeCall(() => _remoteDataSource.fetchSubscriptionPlans());
  }

  @override
  FutureEither<UserSubscriptionEntity?> getUserSubscription(String userId) async {
    return safeCall(() => _remoteDataSource.fetchUserSubscription(userId));
  }

  @override
  FutureEither<List<AddOnPackageEntity>> getAddOnPackages() async {
    return safeCall(() => _remoteDataSource.fetchAddOnPackages());
  }

  @override
  FutureEither<List<PaymentTransactionEntity>> getUserTransactions(String userId) async {
    return safeCall(() => _remoteDataSource.fetchUserTransactions(userId));
  }

  @override
  FutureEither<UserSubscriptionEntity> subscribeToPlan({
    required String userId,
    required String planId,
  }) async {
    return safeCall(
      () => _remoteDataSource.createSubscription(
        userId: userId,
        planId: planId,
      ),
    );
  }
}
