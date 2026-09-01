import '../../../../core/utils/typedefs.dart';
import '../entities/monetization_entities.dart';

abstract class MonetizationRepository {
  FutureEither<List<SubscriptionPlanEntity>> getSubscriptionPlans();

  FutureEither<UserSubscriptionEntity?> getUserSubscription(String userId);

  FutureEither<List<AddOnPackageEntity>> getAddOnPackages();

  FutureEither<List<PaymentTransactionEntity>> getUserTransactions(String userId);

  FutureEither<UserSubscriptionEntity> subscribeToPlan({
    required String userId,
    required String planId,
  });
}
