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

enum DiscountType { percentage, flat }

class RazorpayOrderEntity extends Equatable {
  final String orderId;
  final double amount;
  final String currency;
  final String receiptId;
  final String status;

  const RazorpayOrderEntity({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.receiptId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, amount, currency, receiptId, status];
}

class InvoiceEntity extends Equatable {
  final String invoiceId;
  final String userId;
  final String planId;
  final double subtotal;
  final double discount;
  final double total;
  final double taxAmountGst;
  final String currency;
  final String pdfUrl;
  final DateTime createdAt;

  const InvoiceEntity({
    required this.invoiceId,
    required this.userId,
    required this.planId,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.taxAmountGst = 0.0,
    this.currency = 'INR',
    this.pdfUrl = '',
    required this.createdAt,
  });

  String get invoiceNumber => invoiceId;
  double get subtotalAmount => subtotal;
  double get discountAmount => discount;
  double get totalPaidAmount => total;
  DateTime get paidAt => createdAt;

  @override
  List<Object?> get props => [
        invoiceId,
        userId,
        planId,
        subtotal,
        discount,
        total,
        taxAmountGst,
        currency,
        pdfUrl,
        createdAt,
      ];
}

class PromoCouponEntity extends Equatable {
  final String code;
  final DiscountType discountType;
  final double discountValue;
  final double minimumOrderAmount;
  final DateTime expiryDate;
  final bool isActive;

  const PromoCouponEntity({
    required this.code,
    this.discountType = DiscountType.flat,
    this.discountValue = 0.0,
    this.minimumOrderAmount = 0.0,
    required this.expiryDate,
    this.isActive = true,
  });

  double get discountPercent => discountType == DiscountType.percentage ? discountValue : 0.0;

  @override
  List<Object?> get props => [
        code,
        discountType,
        discountValue,
        minimumOrderAmount,
        expiryDate,
        isActive,
      ];
}


