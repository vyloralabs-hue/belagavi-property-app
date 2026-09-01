import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../error/exceptions.dart';
import '../utils/app_logger.dart';
import '../utils/local_storage.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(),
          webOptions: WebOptions(dbName: 'propertyhub_secure'),
        );

  Future<void> saveToken(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.w('SecureStorage write error ($key): $e. Attempting Web fallback.');
      if (kIsWeb) {
        try {
          await LocalStorage().put('sec_$key', value);
          return;
        } catch (_) {}
      }
      AppLogger.e('Failed to save to secure storage for key: $key', e);
      throw const SecureStorageException();
    }
  }

  Future<String?> getToken(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.w('SecureStorage read error ($key): $e. Attempting Web fallback.');
      if (kIsWeb) {
        try {
          final res = LocalStorage().get('sec_$key');
          return res as String?;
        } catch (_) {}
      }
      AppLogger.e('Failed to read from secure storage for key: $key', e);
      throw const SecureStorageException();
    }
  }

  Future<void> deleteToken(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.w('SecureStorage delete error ($key): $e. Attempting Web fallback.');
      if (kIsWeb) {
        try {
          await LocalStorage().delete('sec_$key');
          return;
        } catch (_) {}
      }
      AppLogger.e('Failed to delete from secure storage for key: $key', e);
      throw const SecureStorageException();
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      AppLogger.w('SecureStorage clearAll error: $e. Attempting Web fallback.');
      if (kIsWeb) {
        try {
          await LocalStorage().clear();
          return;
        } catch (_) {}
      }
      AppLogger.e('Failed to clear secure storage', e);
      throw const SecureStorageException();
    }
  }
}
