import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/app_logger.dart';

class AdMobService {
  AdMobService._();
  static final AdMobService instance = AdMobService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Official Google sample test AdMob banner ID
  static const String testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // In production release builds, if no real commercial AdMob unit ID is provided, fail closed/open safely
  String get bannerAdUnitId {
    if (kDebugMode) {
      return testBannerUnitId;
    }
    // Safe production fallback: if no production AdMob ID configured, return empty
    return '';
  }

  bool get isAdMobConfigured {
    if (kDebugMode) return true;
    final id = bannerAdUnitId;
    return id.isNotEmpty && id.startsWith('ca-app-pub-');
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      AppLogger.i('[AdMob] MobileAds initialized successfully.');
    } catch (e) {
      AppLogger.w('[AdMob] Initialization deferred: ');
    }
  }
}
