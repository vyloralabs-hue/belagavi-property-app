import 'package:injectable/injectable.dart';
import 'env_config.dart';

@lazySingleton
class AppConfig {
  final EnvConfig envConfig;

  AppConfig(this.envConfig);

  String get appTitle => envConfig.appTitle;
  AppEnvironment get environment => envConfig.environment;
  String get environmentName => envConfig.environmentName;

  bool get isDev => envConfig.isDev;
  bool get isStaging => envConfig.isStaging;
  bool get isProduction => envConfig.isProduction;

  // Feature Flags Architecture
  bool get enableAnalytics => !isDev;
  bool get enableCrashlytics => !isDev;
  bool get enableRealtimeNotifications => true;
  bool get enableAIServices => true;
}
