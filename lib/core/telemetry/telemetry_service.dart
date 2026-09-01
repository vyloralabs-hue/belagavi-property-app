import 'package:injectable/injectable.dart';
import '../backend/analytics_service.dart';
import '../utils/app_logger.dart';
import 'telemetry_events.dart';

@lazySingleton
class TelemetryService {
  final AnalyticsService _analyticsService;

  TelemetryService(this._analyticsService);

  /// Safe Event Logger — guarantees silent error isolation so app never crashes
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      final sanitizedParams = _sanitizeParameters(parameters);
      await _analyticsService.logEvent(name: name, parameters: sanitizedParams);
    } catch (e) {
      AppLogger.w('TelemetryService logEvent silent failure isolation: $e');
    }
  }

  /// Screen View Tracking
  Future<void> trackScreen(String screenName) async {
    try {
      await _analyticsService.setCurrentScreen(screenName: screenName);
    } catch (e) {
      AppLogger.w('TelemetryService trackScreen silent failure isolation: $e');
    }
  }

  /// Performance Latency Timer Hook
  Future<T> measureLatency<T>({
    required String metricName,
    required Future<T> Function() action,
    Map<String, Object>? extraParameters,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      final durationMs = stopwatch.elapsedMilliseconds;

      final params = <String, Object>{
        'duration_ms': durationMs,
        ...?extraParameters,
      };

      await logEvent(name: '${metricName}_latency', parameters: params);
      return result;
    } catch (e) {
      stopwatch.stop();
      await logEvent(
        name: TelemetryEvents.networkError,
        parameters: {'context': metricName, 'error': e.runtimeType.toString()},
      );
      rethrow;
    }
  }

  /// Removes sensitive keys/PII prior to dispatching events
  Map<String, Object>? _sanitizeParameters(Map<String, Object>? input) {
    if (input == null) return null;
    final sanitized = Map<String, Object>.from(input);
    final forbiddenKeys = [
      'password',
      'token',
      'secret',
      'auth_token',
      'service_role',
      'private_key',
      'credit_card',
      'cvv',
      'ssn',
      'aadhar',
    ];

    sanitized.removeWhere((key, value) {
      final lowerKey = key.toLowerCase();
      return forbiddenKeys.any((fk) => lowerKey.contains(fk));
    });

    return sanitized;
  }
}
