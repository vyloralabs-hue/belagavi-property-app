import '../../../../core/utils/typedefs.dart';
import '../entities/payment_entities.dart';

abstract class PaymentRepository {
  /// Calls server-authoritative RPC `create_payment_order`
  FutureEither<PaymentOrderEntity> createOrder({
    required String planCode,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  });

  /// Calls server-authoritative RPC `verify_payment_and_grant`
  FutureEither<PaymentVerificationResultEntity> verifyPaymentAndGrant({
    required String orderId,
    required String paymentId,
    String? signature,
    Map<String, dynamic> rawResponse = const {},
  });

  /// Calls server-authoritative RPC `unlock_property_details`
  FutureEither<Map<String, dynamic>> unlockProperty(String propertyId);

  /// Fetches user's billing history (orders and payment transactions)
  FutureEither<List<BillingRecordEntity>> getBillingHistory();

  /// Soft deletes user account (compliance)
  FutureEither<void> softDeleteAccount();
}
