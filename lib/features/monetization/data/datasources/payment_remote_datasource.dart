import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/payment_models.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentOrderModel> createOrder({
    required String planCode,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  });

  Future<PaymentVerificationResultModel> verifyPaymentAndGrant({
    required String orderId,
    required String paymentId,
    String? signature,
    Map<String, dynamic> rawResponse = const {},
  });

  Future<Map<String, dynamic>> unlockProperty(String propertyId);

  Future<List<BillingRecordModel>> fetchBillingHistory();

  Future<void> softDeleteAccount();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseService _supabaseService;

  PaymentRemoteDataSourceImpl({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  SupabaseClient get _client => _supabaseService.client;

  @override
  Future<PaymentOrderModel> createOrder({
    required String planCode,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final res = await _client.rpc('create_payment_order', params: {
        'p_plan_code': planCode,
        'p_target_id': targetId,
        'p_metadata': metadata,
      });

      if (res == null) {
        throw const ServerException('Server returned empty order response.');
      }

      final data = Map<String, dynamic>.from(res as Map);
      return PaymentOrderModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentVerificationResultModel> verifyPaymentAndGrant({
    required String orderId,
    required String paymentId,
    String? signature,
    Map<String, dynamic> rawResponse = const {},
  }) async {
    try {
      final res = await _client.rpc('verify_payment_and_grant', params: {
        'p_order_id': orderId,
        'p_payment_id': paymentId,
        'p_signature': signature,
        'p_raw_response': rawResponse,
      });

      if (res == null) {
        throw const ServerException('Empty response during payment verification.');
      }

      final data = Map<String, dynamic>.from(res as Map);
      return PaymentVerificationResultModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> unlockProperty(String propertyId) async {
    try {
      final res = await _client.rpc('unlock_property_details', params: {
        'p_property_id': propertyId,
      });

      if (res == null) {
        throw const ServerException('Failed to unlock property.');
      }

      return Map<String, dynamic>.from(res as Map);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BillingRecordModel>> fetchBillingHistory() async {
    try {
      final res = await _client
          .from('payment_orders')
          .select('*, payment_transactions(*)')
          .order('created_at', ascending: false);

      final list = (res as List).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        return BillingRecordModel.fromJson(map);
      }).toList();

      return list;
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> softDeleteAccount() async {
    try {
      await _client.rpc('soft_delete_user_account');
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
