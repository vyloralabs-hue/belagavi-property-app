import '../../domain/entities/payment_entities.dart';

class PromoCouponModel extends PromoCouponEntity {
  const PromoCouponModel({
    required super.code,
    required super.discountType,
    required super.discountValue,
    super.minimumOrderAmount = 0.0,
    required super.expiryDate,
    super.isActive = true,
  });

  factory PromoCouponModel.fromJson(Map<String, dynamic> json) {
    return PromoCouponModel(
      code: json['code'] as String? ?? '',
      discountType: DiscountType.values.firstWhere(
        (e) => e.name == json['discount_type'],
        orElse: () => DiscountType.percentage,
      ),
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minimumOrderAmount: (json['minimum_order_amount'] as num?)?.toDouble() ?? 0.0,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'discount_type': discountType.name,
        'discount_value': discountValue,
        'minimum_order_amount': minimumOrderAmount,
        'expiry_date': expiryDate.toIso8601String(),
        'is_active': isActive,
      };
}

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.invoiceNumber,
    required super.userId,
    required super.planId,
    required super.subtotalAmount,
    required super.discountAmount,
    required super.taxAmountGst,
    required super.totalPaidAmount,
    super.currency = 'INR',
    required super.paidAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceNumber: json['invoice_number'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      subtotalAmount: (json['subtotal_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmountGst: (json['tax_amount_gst'] as num?)?.toDouble() ?? 0.0,
      totalPaidAmount: (json['total_paid_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'invoice_number': invoiceNumber,
        'user_id': userId,
        'plan_id': planId,
        'subtotal_amount': subtotalAmount,
        'discount_amount': discountAmount,
        'tax_amount_gst': taxAmountGst,
        'total_paid_amount': totalPaidAmount,
        'currency': currency,
        'paid_at': paidAt.toIso8601String(),
      };
}

class RazorpayOrderModel extends RazorpayOrderEntity {
  const RazorpayOrderModel({
    required super.orderId,
    required super.amount,
    required super.currency,
    required super.receiptId,
    required super.status,
  });

  factory RazorpayOrderModel.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderModel(
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      receiptId: json['receipt_id'] as String? ?? '',
      status: json['status'] as String? ?? 'created',
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'receipt_id': receiptId,
        'status': status,
      };
}
