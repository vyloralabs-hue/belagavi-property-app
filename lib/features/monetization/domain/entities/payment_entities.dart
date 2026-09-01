import 'package:equatable/equatable.dart';

enum DiscountType { percentage, flatAmount }

class PromoCouponEntity extends Equatable {
  final String code;
  final DiscountType discountType;
  final double discountValue; // e.g. 10.0 for 10% or 500.0 for ₹500
  final double minimumOrderAmount;
  final DateTime expiryDate;
  final bool isActive;

  const PromoCouponEntity({
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minimumOrderAmount = 0.0,
    required this.expiryDate,
    this.isActive = true,
  });

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

class InvoiceEntity extends Equatable {
  final String invoiceNumber;
  final String userId;
  final String planId;
  final double subtotalAmount;
  final double discountAmount;
  final double taxAmountGst; // 18% GST
  final double totalPaidAmount;
  final String currency; // 'INR', 'USD', 'AED'
  final DateTime paidAt;

  const InvoiceEntity({
    required this.invoiceNumber,
    required this.userId,
    required this.planId,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.taxAmountGst,
    required this.totalPaidAmount,
    this.currency = 'INR',
    required this.paidAt,
  });

  @override
  List<Object?> get props => [
        invoiceNumber,
        userId,
        planId,
        subtotalAmount,
        discountAmount,
        taxAmountGst,
        totalPaidAmount,
        currency,
        paidAt,
      ];
}

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
