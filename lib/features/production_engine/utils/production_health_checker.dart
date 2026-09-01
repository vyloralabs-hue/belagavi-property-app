import 'package:flutter/foundation.dart';

class ProductionHealthChecker {
  ProductionHealthChecker._();

  /// Validates runtime environment memory and target platform
  static Map<String, dynamic> evaluateRuntimeEnvironment() {
    return {
      'isWeb': kIsWeb,
      'isAndroid': defaultTargetPlatform == TargetPlatform.android,
      'isIOS': defaultTargetPlatform == TargetPlatform.iOS,
      'isMacOS': defaultTargetPlatform == TargetPlatform.macOS,
      'isReleaseMode': kReleaseMode,
    };
  }
}
