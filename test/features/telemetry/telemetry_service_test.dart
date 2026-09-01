import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/analytics_service.dart';
import 'package:belagavi_property/core/telemetry/telemetry_events.dart';
import 'package:belagavi_property/core/telemetry/telemetry_service.dart';

class FakeAnalyticsService implements AnalyticsService {
  final List<Map<String, dynamic>> loggedEvents = [];
  final List<String> loggedScreens = [];
  String? currentUserId;
  bool shouldThrow = false;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (shouldThrow) {
      throw Exception('Analytics Connection Error');
    }
    loggedEvents.add({
      'name': name,
      'parameters': parameters,
    });
  }

  @override
  Future<void> setCurrentScreen({required String screenName}) async {
    if (shouldThrow) {
      throw Exception('Analytics Screen View Error');
    }
    loggedScreens.add(screenName);
  }

  @override
  Future<void> setUserId(String? userId) async {
    currentUserId = userId;
  }
}

void main() {
  late FakeAnalyticsService fakeAnalyticsService;
  late TelemetryService telemetryService;

  setUp(() {
    fakeAnalyticsService = FakeAnalyticsService();
    telemetryService = TelemetryService(fakeAnalyticsService);
  });

  group('TelemetryService Tests', () {
    test('logEvent sanitizes forbidden keys before sending', () async {
      final dirtyParams = <String, Object>{
        'property_id': 'prop_123',
        'password': 'secret_password_123',
        'auth_token': 'bearer_xyz',
        'category': 'residential',
      };

      await telemetryService.logEvent(
        name: TelemetryEvents.propertyOpened,
        parameters: dirtyParams,
      );

      expect(fakeAnalyticsService.loggedEvents.length, equals(1));
      final capturedParams = fakeAnalyticsService.loggedEvents.first['parameters'] as Map<String, Object>?;

      expect(capturedParams, isNotNull);
      expect(capturedParams!['property_id'], equals('prop_123'));
      expect(capturedParams['category'], equals('residential'));
      expect(capturedParams.containsKey('password'), isFalse);
      expect(capturedParams.containsKey('auth_token'), isFalse);
    });

    test('measureLatency logs metric duration cleanly', () async {
      final result = await telemetryService.measureLatency<String>(
        metricName: 'property_search',
        action: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'search_results';
        },
      );

      expect(result, equals('search_results'));

      expect(fakeAnalyticsService.loggedEvents.length, equals(1));
      final capturedName = fakeAnalyticsService.loggedEvents.first['name'];
      final capturedParams = fakeAnalyticsService.loggedEvents.first['parameters'] as Map<String, Object>?;

      expect(capturedName, equals('property_search_latency'));
      expect(capturedParams, isNotNull);
      expect(capturedParams!.containsKey('duration_ms'), isTrue);
    });

    test('telemetry silent failure isolation prevents application crashes', () async {
      fakeAnalyticsService.shouldThrow = true;

      expect(
        () async => await telemetryService.logEvent(
          name: TelemetryEvents.appOpen,
        ),
        returnsNormally,
      );
    });
  });
}
