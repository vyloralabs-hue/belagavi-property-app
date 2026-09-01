import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_gateway_repository.dart';
import '../datasources/payment_gateway_remote_datasource.dart';
import '../../utils/coupon_validator.dart';

@LazySingleton(as: PaymentGatewayRepository)
class PaymentGatewayRepositoryImpl extends BaseRepository implements PaymentGatewayRepository {
  final PaymentGatewayRemoteDataSource _remoteDataSource;

  PaymentGatewayRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<RazorpayOrderEntity> createRazorpayOrder({
    required double amount,
    required String currency,
    required String planId,
  }) async {
    return safeCall(
      () => _remoteDataSource.createRazorpayOrder(
        amount: amount,
        currency: currency,
        planId: planId,
      ),
    );
  }

  @override
  FutureEither<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    return safeCall(
      () => _remoteDataSource.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      ),
    );
  }

  @override
  FutureEither<PromoCouponEntity> validateCouponCode(String code, double orderAmount) async {
    return safeCall(() async {
      final coupon = await _remoteDataSource.fetchCoupon(code);
      if (!CouponValidator.isValid(coupon, orderAmount)) {
        throw Exception('Coupon condition not met or expired');
      }
      return coupon;
    });
  }

  @override
  FutureEither<InvoiceEntity> generateInvoice({
    required String userId,
    required String planId,
    required double subtotal,
    required double discount,
  }) async {
    return safeCall(
      () => _remoteDataSource.generateInvoice(
        userId: userId,
        planId: planId,
        subtotal: subtotal,
        discount: discount,
      ),
    );
  }
}
