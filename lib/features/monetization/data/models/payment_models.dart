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
