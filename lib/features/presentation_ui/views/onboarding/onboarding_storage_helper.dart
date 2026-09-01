import '../../../../bootstrap/bootstrap.dart';
import '../../../../core/utils/local_storage.dart';

class OnboardingStorageHelper {
  OnboardingStorageHelper._();

  static const String _key = 'has_completed_onboarding';

  static bool isCompleted() {
    try {
      final storage = getIt<LocalStorage>();
      final val = storage.get(_key);
      return val == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markCompleted() async {
    try {
      final storage = getIt<LocalStorage>();
      await storage.put(_key, true);
    } catch (_) {}
  }
}
