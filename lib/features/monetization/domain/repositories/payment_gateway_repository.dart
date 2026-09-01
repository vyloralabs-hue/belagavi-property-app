import '../../../../core/utils/typedefs.dart';
import '../entities/payment_entities.dart';

abstract class PaymentGatewayRepository {
  FutureEither<RazorpayOrderEntity> createRazorpayOrder({
    required double amount,
    required String currency,
    required String planId,
  });

  FutureEither<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  });

  FutureEither<PromoCouponEntity> validateCouponCode(String code, double orderAmount);

  FutureEither<InvoiceEntity> generateInvoice({
    required String userId,
    required String planId,
    required double subtotal,
    required double discount,
  });
}
