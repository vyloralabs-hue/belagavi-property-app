import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_gateway_repository.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutOrderReady extends CheckoutState {
  final RazorpayOrderEntity order;
  final PromoCouponEntity? appliedCoupon;
  final double subtotal;
  final double discount;
  final double finalAmount;

  const CheckoutOrderReady({
    required this.order,
    this.appliedCoupon,
    required this.subtotal,
    required this.discount,
    required this.finalAmount,
  });

  @override
  List<Object?> get props => [order, appliedCoupon, subtotal, discount, finalAmount];
}

class CheckoutSuccess extends CheckoutState {
  final InvoiceEntity invoice;

  const CheckoutSuccess(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

final checkoutNotifierProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);

class CheckoutNotifier extends Notifier<CheckoutState> {
  late final PaymentGatewayRepository _repository;

  @override
  CheckoutState build() {
    _repository = getIt<PaymentGatewayRepository>();
    return const CheckoutInitial();
  }

  Future<void> initiateCheckout({
    required double amount,
    required String currency,
    required String planId,
  }) async {
    state = const CheckoutLoading();
    final result = await _repository.createRazorpayOrder(
      amount: amount,
      currency: currency,
      planId: planId,
    );

    result.fold(
      (failure) => state = CheckoutError(failure.message),
      (order) => state = CheckoutOrderReady(
        order: order,
        subtotal: amount,
        discount: 0.0,
        finalAmount: amount,
      ),
    );
  }

  Future<void> applyCoupon(String code, double currentSubtotal) async {
    final result = await _repository.validateCouponCode(code, currentSubtotal);
    result.fold(
      (failure) => state = CheckoutError(failure.message),
      (coupon) {
        if (state is CheckoutOrderReady) {
          final current = state as CheckoutOrderReady;
          double discount = 0.0;
          if (coupon.discountType == DiscountType.percentage) {
            discount = (currentSubtotal * coupon.discountValue) / 100.0;
          } else {
            discount = coupon.discountValue;
          }
          final finalAmt = (currentSubtotal - discount).clamp(0.0, double.infinity);

          state = CheckoutOrderReady(
            order: current.order,
            appliedCoupon: coupon,
            subtotal: currentSubtotal,
            discount: discount,
            finalAmount: finalAmt,
          );
        }
      },
    );
  }
}
