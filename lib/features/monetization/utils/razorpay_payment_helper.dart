import '../domain/entities/payment_entities.dart';

class RazorpayPaymentHelper {
  RazorpayPaymentHelper._();

  /// Standardized Razorpay checkout options builder for PropertyHub payment flow
  static Map<String, dynamic> buildCheckoutOptions({
    required RazorpayOrderEntity order,
    required String userPhone,
    required String userEmail,
    required String description,
  }) {
    return {
      'key': 'rzp_test_PropertyHubKeyId',
      'amount': (order.amount * 100).toInt(), // Amount in paise
      'name': 'PropertyHub Belagavi',
      'order_id': order.orderId,
      'description': description,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
      },
      'external': {
        'wallets': ['paytm', 'gpay']
      }
    };
  }
}
