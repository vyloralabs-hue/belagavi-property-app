import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class AnalyticsService {
  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      AppLogger.i('Analytics Event: $name | params: $parameters');
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      AppLogger.w('Analytics logEvent fallback: $e');
    }
  }

  Future<void> setCurrentScreen({required String screenName}) async {
    try {
      AppLogger.d('Analytics Screen: $screenName');
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      AppLogger.w('Analytics logScreenView fallback: $e');
    }
  }

  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      AppLogger.w('Analytics setUserId fallback: $e');
    }
  }
}
