import '../../domain/entities/payment_entities.dart';

class PaymentOrderModel extends PaymentOrderEntity {
  const PaymentOrderModel({
    required super.orderId,
    required super.planCode,
    required super.planName,
    required super.productFamily,
    required super.amountInPaise,
    super.currency = 'INR',
    super.targetId,
    super.status = 'created',
    required super.createdAt,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      orderId: (json['order_id'] ?? json['id']) as String,
      planCode: json['plan_code'] as String,
      planName: (json['plan_name'] as String?) ?? json['plan_code'] as String,
      productFamily: json['product_family'] as String,
      amountInPaise: (json['amount_in_paise'] as num).toInt(),
      currency: (json['currency'] as String?) ?? 'INR',
      targetId: json['target_id'] as String?,
      status: (json['status'] as String?) ?? 'created',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PaymentVerificationResultModel extends PaymentVerificationResultEntity {
  const PaymentVerificationResultModel({
    required super.success,
    required super.status,
    required super.orderId,
    required super.paymentId,
    required super.planCode,
    required super.productFamily,
    super.creditsGranted,
    super.validityDays,
    super.expiresAt,
  });

  factory PaymentVerificationResultModel.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResultModel(
      success: (json['success'] as bool?) ?? true,
      status: (json['status'] as String?) ?? 'paid_and_granted',
      orderId: json['order_id'] as String,
      paymentId: (json['payment_id'] as String?) ?? '',
      planCode: (json['plan_code'] as String?) ?? '',
      productFamily: (json['product_family'] as String?) ?? '',
      creditsGranted: (json['credits_granted'] as num?)?.toInt(),
      validityDays: (json['validity_days'] as num?)?.toInt(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }
}

class BillingRecordModel extends BillingRecordEntity {
  const BillingRecordModel({
    required super.orderId,
    required super.planCode,
    required super.productFamily,
    required super.amountInPaise,
    super.currency = 'INR',
    required super.status,
    super.paymentId,
    required super.createdAt,
  });

  factory BillingRecordModel.fromJson(Map<String, dynamic> json) {
    String? payId;
    if (json['payment_transactions'] != null &&
        (json['payment_transactions'] as List).isNotEmpty) {
      final tx = (json['payment_transactions'] as List).first as Map;
      payId = tx['payment_id']?.toString();
    }

    return BillingRecordModel(
      orderId: (json['order_id'] ?? json['id']) as String,
      planCode: json['plan_code'] as String,
      productFamily: json['product_family'] as String,
      amountInPaise: (json['amount_in_paise'] as num).toInt(),
      currency: (json['currency'] as String?) ?? 'INR',
      status: (json['status'] as String?) ?? 'created',
      paymentId: payId,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
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
      orderId: json['orderId'] as String? ?? json['id'] as String? ?? '',
      amount: ((json['amount'] as num?)?.toDouble() ?? 0.0),
      currency: json['currency'] as String? ?? 'INR',
      receiptId: json['receiptId'] as String? ?? json['receipt'] as String? ?? '',
      status: json['status'] as String? ?? 'created',
    );
  }
}

class InvoiceModel extends InvoiceEntity {
  InvoiceModel({
    String? invoiceId,
    String? invoiceNumber,
    required super.userId,
    required super.planId,
    double? subtotal,
    double? subtotalAmount,
    double? discount,
    double? discountAmount,
    double? total,
    double? totalPaidAmount,
    super.taxAmountGst,
    super.currency,
    super.pdfUrl,
    DateTime? createdAt,
    DateTime? paidAt,
  }) : super(
          invoiceId: invoiceId ?? invoiceNumber ?? '',
          subtotal: subtotal ?? subtotalAmount ?? 0.0,
          discount: discount ?? discountAmount ?? 0.0,
          total: total ?? totalPaidAmount ?? 0.0,
          createdAt: createdAt ?? paidAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        );

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceId: json['invoiceId'] as String? ??
          json['invoice_number'] as String? ??
          json['id'] as String? ??
          '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      planId: json['planId'] as String? ?? json['plan_id'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ??
          (json['subtotal_amount'] as num?)?.toDouble() ??
          0.0,
      discount: (json['discount'] as num?)?.toDouble() ??
          (json['discount_amount'] as num?)?.toDouble() ??
          0.0,
      total: (json['total'] as num?)?.toDouble() ??
          (json['total_paid_amount'] as num?)?.toDouble() ??
          0.0,
      taxAmountGst: (json['tax_amount_gst'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? 'INR',
      pdfUrl: json['pdfUrl'] as String? ?? json['pdf_url'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': invoiceId,
        'invoice_number': invoiceNumber,
        'user_id': userId,
        'plan_id': planId,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'tax_amount_gst': taxAmountGst,
        'currency': currency,
        'pdf_url': pdfUrl,
        'created_at': createdAt.toIso8601String(),
      };
}

class PromoCouponModel extends PromoCouponEntity {
  const PromoCouponModel({
    required super.code,
    super.discountType = DiscountType.flat,
    super.discountValue = 0.0,
    super.minimumOrderAmount = 0.0,
    required super.expiryDate,
    super.isActive = true,
  });

  factory PromoCouponModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['discountType'] as String? ?? 'flat';
    return PromoCouponModel(
      code: json['code'] as String? ?? '',
      discountType: typeStr == 'percentage' ? DiscountType.percentage : DiscountType.flat,
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble() ?? 0.0,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

