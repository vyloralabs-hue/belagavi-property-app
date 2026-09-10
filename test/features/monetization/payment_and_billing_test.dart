import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/monetization/domain/entities/payment_entities.dart';

void main() {
  group('Payment & Entitlement Domain Unit Tests', () {
    test('PaymentOrderEntity correctly converts integer paise to rupees', () {
      final order = PaymentOrderEntity(
        orderId: 'order_bp_test123',
        planCode: 'COMMERCIAL_30D',
        planName: 'Commercial Listing - 30 Days',
        productFamily: 'commercial_listing',
        amountInPaise: 69900,
        currency: 'INR',
        targetId: 'prop-uuid-456',
        status: 'created',
        createdAt: DateTime.now(),
      );

      expect(order.amountInRupees, 699.0);
      expect(order.integerRupees, 699);
      expect(order.productFamily, 'commercial_listing');
    });

    test('BillingRecordEntity correctly formats integer paise', () {
      final record = BillingRecordEntity(
        orderId: 'order_bp_rec789',
        planCode: 'PROPERTY_UNLOCK_SINGLE',
        productFamily: 'buyer_unlock',
        amountInPaise: 9900,
        currency: 'INR',
        status: 'paid',
        paymentId: 'pay_rzp_mock123',
        createdAt: DateTime(2026, 9, 10),
      );

      expect(record.amountInRupees, 99.0);
      expect(record.integerRupees, 99);
      expect(record.status, 'paid');
      expect(record.paymentId, 'pay_rzp_mock123');
    });

    test('PaymentVerificationResultEntity handles idempotent and active grants', () {
      final grant = PaymentVerificationResultEntity(
        success: true,
        status: 'paid_and_granted',
        orderId: 'order_bp_grant123',
        paymentId: 'pay_rzp_test_sig',
        planCode: 'PROPERTY_WATCH_30D',
        productFamily: 'property_watch',
        creditsGranted: 1,
        validityDays: 30,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      expect(grant.success, isTrue);
      expect(grant.creditsGranted, 1);
      expect(grant.validityDays, 30);
      expect(grant.productFamily, 'property_watch');
    });
  });
}
