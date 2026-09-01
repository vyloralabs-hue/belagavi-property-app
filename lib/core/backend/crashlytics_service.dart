import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class CrashlyticsService {
  FirebaseCrashlytics? get _crashlytics => kIsWeb ? null : FirebaseCrashlytics.instance;

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    try {
      AppLogger.e('Crashlytics error recorded: $exception', exception, stack);
      if (!kIsWeb && _crashlytics != null) {
        await _crashlytics!.recordError(
          exception,
          stack,
          reason: reason,
          fatal: fatal,
        );
      }
    } catch (e) {
      AppLogger.w('Crashlytics record error fallback: $e');
    }
  }

  Future<void> setUserIdentifier(String identifier) async {
    try {
      if (!kIsWeb && _crashlytics != null) {
        await _crashlytics!.setUserIdentifier(identifier);
      }
    } catch (e) {
      AppLogger.w('Crashlytics setUserIdentifier fallback: $e');
    }
  }

  Future<void> log(String message) async {
    try {
      AppLogger.d('Crashlytics log: $message');
      if (!kIsWeb && _crashlytics != null) {
        await _crashlytics!.log(message);
      }
    } catch (e) {
      AppLogger.w('Crashlytics log fallback: $e');
    }
  }
}
