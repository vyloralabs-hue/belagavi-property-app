import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

@lazySingleton
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'PropertyHub-Flutter',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.d('HTTP Request [${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d('HTTP Response [${response.statusCode}] <= ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          AppLogger.e('HTTP Error [${error.response?.statusCode}] <= ${error.requestOptions.uri}', error);
          return handler.next(error);
        },
      ),
    );
  }

  Dio get client => _dio;
}
