import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../error/exceptions.dart';
import '../utils/app_logger.dart';

abstract class BaseRemoteDataSource {
  const BaseRemoteDataSource();

  /// Wraps Supabase Postgrest & Storage calls, converting exceptions to [AppException]
  Future<T> safeQuery<T>(Future<T> Function() query) async {
    try {
      return await query();
    } on PostgrestException catch (e, stackTrace) {
      AppLogger.e('Postgrest error [${e.code}]: ${e.message}', e, stackTrace);
      if (e.code == '401' || e.code == 'PGRST301') {
        throw UnauthorizedException(e.message);
      } else if (e.code == '404' || e.code == 'PGRST116') {
        throw NotFoundException(e.message);
      }
      throw ServerException(e.message);
    } on StorageException catch (e, stackTrace) {
      AppLogger.e('Supabase Storage error: ${e.message}', e, stackTrace);
      throw const ServerException(
        'Unable to process storage request. Please try again.',
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected remote data source exception: $e', e, stackTrace);
      final str = e.toString();
      if (str.contains('SocketException') ||
          str.contains('Failed host lookup') ||
          str.contains('ClientException') ||
          str.contains('HandshakeException') ||
          str.contains('TimeoutException')) {
        throw const NetworkException(
          'Unable to connect right now. Check your internet connection and try again.',
        );
      }
      throw const ServerException(
        'Unable to load data right now. Please try again shortly.',
      );
    }
  }
}
