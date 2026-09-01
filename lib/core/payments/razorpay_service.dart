import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RazorpayService {
  late Razorpay _razorpay;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle success
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle error
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  void openCheckout(Map<String, dynamic> options) {
    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
