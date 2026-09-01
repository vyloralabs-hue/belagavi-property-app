import 'package:fpdart/fpdart.dart';
import 'package:belagavi_property/core/error/failures.dart';
import '../entities/central_monetization_entities.dart';

abstract class PaymentOrderService {
  Future<Either<Failure, String>> createServerOrder({
    required String userId,
    required String planId,
    required ProductType productType,
    required String referenceEntityId,
  });
}

abstract class PaymentVerificationService {
  Future<Either<Failure, EntitlementEntity>> verifyPaymentAndGrantEntitlement({
    required String orderId,
    required String paymentId,
    required String signature,
  });
}

abstract class PaymentWebhookService {
  Future<Either<Failure, bool>> processWebhookEvent({
    required String eventId,
    required String eventType,
    required Map<String, dynamic> payload,
  });
}

abstract class PaymentRefundService {
  Future<Either<Failure, RefundEntity>> requestRefund({
    required String paymentId,
    required int amountInPaise,
    required String reason,
  });
}

abstract class PaymentInvoiceService {
  Future<Either<Failure, String>> generateInvoiceNumber({
    required String orderId,
    required String userId,
  });
}

abstract class PaymentGateway
    implements
        PaymentOrderService,
        PaymentVerificationService,
        PaymentWebhookService,
        PaymentRefundService,
        PaymentInvoiceService {
  String get providerName; // e.g. 'razorpay', 'stripe'
}

class PaymentGatewayFactory {
  static PaymentGateway getGateway(String providerName, PaymentGateway defaultGateway) {
    if (providerName == 'razorpay') {
      return defaultGateway;
    }
    return defaultGateway;
  }
}
