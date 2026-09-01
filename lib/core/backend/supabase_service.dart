import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../utils/app_logger.dart';

@lazySingleton
class SupabaseService {
  SupabaseClient get client => Supabase.instance.client;

  bool get isInitialized {
    try {
      final c = client;
      if (c.auth.currentSession == null && c.rest.headers.isEmpty) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  SupabaseQueryBuilder from(String table) => client.from(table);

  StorageFileApi storage(String bucketId) => client.storage.from(bucketId);

  void logStatus() {
    AppLogger.i('SupabaseService status: initialized=$isInitialized, auth=$isAuthenticated');
  }
}
