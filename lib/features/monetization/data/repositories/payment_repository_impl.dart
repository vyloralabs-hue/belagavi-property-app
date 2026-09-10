import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl({PaymentRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? PaymentRemoteDataSourceImpl();

  @override
  FutureEither<PaymentOrderEntity> createOrder({
    required String planCode,
    String? targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final order = await _remoteDataSource.createOrder(
        planCode: planCode,
        targetId: targetId,
        metadata: metadata,
      );
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<PaymentVerificationResultEntity> verifyPaymentAndGrant({
    required String orderId,
    required String paymentId,
    String? signature,
    Map<String, dynamic> rawResponse = const {},
  }) async {
    try {
      final result = await _remoteDataSource.verifyPaymentAndGrant(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        rawResponse: rawResponse,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<Map<String, dynamic>> unlockProperty(String propertyId) async {
    try {
      final res = await _remoteDataSource.unlockProperty(propertyId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<BillingRecordEntity>> getBillingHistory() async {
    try {
      final list = await _remoteDataSource.fetchBillingHistory();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> softDeleteAccount() async {
    try {
      await _remoteDataSource.softDeleteAccount();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
