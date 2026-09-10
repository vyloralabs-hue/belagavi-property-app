import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../data/repositories/payment_repository_impl.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl();
});

/// Fetches current user's billing and transaction history
final billingHistoryProvider = FutureProvider<List<BillingRecordEntity>>((ref) async {
  final repo = ref.watch(paymentRepositoryProvider);
  final result = await repo.getBillingHistory();
  return result.fold(
    (failure) => <BillingRecordEntity>[],
    (list) => list,
  );
});

/// Payment Order Creation Notifier
enum PaymentProcessStatus { initial, creatingOrder, readyForCheckout, verifying, success, error }

class PaymentProcessState {
  final PaymentProcessStatus status;
  final PaymentOrderEntity? order;
  final PaymentVerificationResultEntity? verificationResult;
  final String? errorMessage;

  const PaymentProcessState({
    this.status = PaymentProcessStatus.initial,
    this.order,
    this.verificationResult,
    this.errorMessage,
  });

  PaymentProcessState copyWith({
    PaymentProcessStatus? status,
    PaymentOrderEntity? order,
    PaymentVerificationResultEntity? verificationResult,
    String? errorMessage,
  }) {
    return PaymentProcessState(
      status: status ?? this.status,
      order: order ?? this.order,
      verificationResult: verificationResult ?? this.verificationResult,
      errorMessage: errorMessage,
    );
  }
}

class PaymentProcessNotifier extends StateNotifier<PaymentProcessState> {
  final PaymentRepository _repository;

  PaymentProcessNotifier(this._repository) : super(const PaymentProcessState());

  Future<PaymentOrderEntity?> createOrder({
    required String planCode,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    state = state.copyWith(status: PaymentProcessStatus.creatingOrder, errorMessage: null);

    final res = await _repository.createOrder(
      planCode: planCode,
      targetId: targetId,
      metadata: metadata,
    );

    return res.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentProcessStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (order) {
        state = state.copyWith(
          status: PaymentProcessStatus.readyForCheckout,
          order: order,
        );
        return order;
      },
    );
  }

  Future<PaymentVerificationResultEntity?> completePayment({
    required String orderId,
    required String paymentId,
    String? signature,
    Map<String, dynamic> rawResponse = const {},
  }) async {
    state = state.copyWith(status: PaymentProcessStatus.verifying, errorMessage: null);

    final res = await _repository.verifyPaymentAndGrant(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
      rawResponse: rawResponse,
    );

    return res.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentProcessStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (result) {
        state = state.copyWith(
          status: PaymentProcessStatus.success,
          verificationResult: result,
        );
        return result;
      },
    );
  }

  void reset() {
    state = const PaymentProcessState();
  }
}

final paymentProcessNotifierProvider =
    StateNotifierProvider<PaymentProcessNotifier, PaymentProcessState>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentProcessNotifier(repo);
});
