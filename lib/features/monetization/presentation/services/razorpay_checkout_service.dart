import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/constants/env.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/payment_entities.dart';

typedef PaymentSuccessCallback = void Function(PaymentSuccessResponse response);
typedef PaymentFailureCallback = void Function(PaymentFailureResponse response);
typedef ExternalWalletCallback = void Function(ExternalWalletResponse response);

class RazorpayCheckoutService {
  RazorpayCheckoutService._();
  static final RazorpayCheckoutService instance = RazorpayCheckoutService._();

  Razorpay? _razorpay;
  PaymentSuccessCallback? _onSuccess;
  PaymentFailureCallback? _onFailure;
  ExternalWalletCallback? _onExternalWallet;

  bool get isMockGateway {
    final key = activeRazorpayKey;
    return key.isEmpty ||
        key == 'rzp_live_prod' ||
        key.contains('placeholder') ||
        key.contains('dummy');
  }

  String get activeRazorpayKey {
    try {
      // In prod release, EnvProd is the source
      final key = EnvProd.razorpayKey;
      return key.trim();
    } catch (_) {
      return '';
    }
  }

  void initialize({
    required PaymentSuccessCallback onSuccess,
    required PaymentFailureCallback onFailure,
    ExternalWalletCallback? onExternalWallet,
  }) {
    dispose();
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onExternalWallet = onExternalWallet;

    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    AppLogger.i('[Razorpay] Payment Success: ${response.paymentId}');
    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.w('[Razorpay] Payment Error: code=${response.code}, message=${response.message}');
    _onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.i('[Razorpay] External Wallet: ${response.walletName}');
    _onExternalWallet?.call(response);
  }

  void openCheckout({
    required PaymentOrderEntity order,
    required String userEmail,
    required String userPhone,
  }) {
    if (isMockGateway) {
      AppLogger.w('[Razorpay] Live key is pending (mock gateway mode)');
    }

    final options = {
      'key': isMockGateway ? 'rzp_test_mock_gateway' : activeRazorpayKey,
      'amount': order.amountInPaise,
      'name': 'Belagavi Property',
      'description': order.planName,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
      },
      'notes': {
        'order_id': order.orderId,
        'plan_code': order.planCode,
        'product_family': order.productFamily,
        if (order.targetId != null) 'target_id': order.targetId!,
      },
      'theme': {
        'color': '#F59E0B',
      },
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      AppLogger.e('[Razorpay] Open checkout exception: $e');
      _onFailure?.call(PaymentFailureResponse(
        Razorpay.PAYMENT_CANCELLED,
        'Unable to launch payment gateway: $e',
        {},
      ));
    }
  }

  void dispose() {
    try {
      _razorpay?.clear();
      _razorpay = null;
    } catch (_) {}
  }
}
