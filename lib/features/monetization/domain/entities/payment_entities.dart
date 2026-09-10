import 'package:equatable/equatable.dart';

/// Server-Authoritative Payment Order Entity
class PaymentOrderEntity extends Equatable {
  final String orderId;
  final String planCode;
  final String planName;
  final String productFamily;
  final int amountInPaise;
  final String currency;
  final String? targetId;
  final String status;
  final DateTime createdAt;

  const PaymentOrderEntity({
    required this.orderId,
    required this.planCode,
    required this.planName,
    required this.productFamily,
    required this.amountInPaise,
    this.currency = 'INR',
    this.targetId,
    this.status = 'created',
    required this.createdAt,
  });

  double get amountInRupees => amountInPaise / 100.0;
  int get integerRupees => amountInPaise ~/ 100;

  @override
  List<Object?> get props => [
        orderId,
        planCode,
        planName,
        productFamily,
        amountInPaise,
        currency,
        targetId,
        status,
        createdAt,
      ];
}

/// Verification Result Entity
class PaymentVerificationResultEntity extends Equatable {
  final bool success;
  final String status;
  final String orderId;
  final String paymentId;
  final String planCode;
  final String productFamily;
  final int? creditsGranted;
  final int? validityDays;
  final DateTime? expiresAt;

  const PaymentVerificationResultEntity({
    required this.success,
    required this.status,
    required this.orderId,
    required this.paymentId,
    required this.planCode,
    required this.productFamily,
    this.creditsGranted,
    this.validityDays,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        success,
        status,
        orderId,
        paymentId,
        planCode,
        productFamily,
        creditsGranted,
        validityDays,
        expiresAt,
      ];
}

/// User Billing Record Entity (Order + Transaction History)
class BillingRecordEntity extends Equatable {
  final String orderId;
  final String planCode;
  final String productFamily;
  final int amountInPaise;
  final String currency;
  final String status;
  final String? paymentId;
  final DateTime createdAt;

  const BillingRecordEntity({
    required this.orderId,
    required this.planCode,
    required this.productFamily,
    required this.amountInPaise,
    this.currency = 'INR',
    required this.status,
    this.paymentId,
    required this.createdAt,
  });

  double get amountInRupees => amountInPaise / 100.0;
  int get integerRupees => amountInPaise ~/ 100;

  @override
  List<Object?> get props => [
        orderId,
        planCode,
        productFamily,
        amountInPaise,
        currency,
        status,
        paymentId,
        createdAt,
      ];
}
