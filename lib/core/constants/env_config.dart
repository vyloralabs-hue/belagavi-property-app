import 'package:injectable/injectable.dart';

enum AppEnvironment { dev, staging, production }

@lazySingleton
class EnvConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String appTitle;

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.appTitle,
  });

  bool get isDev => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProduction => environment == AppEnvironment.production;

  String get environmentName => switch (environment) {
        AppEnvironment.dev => 'Development',
        AppEnvironment.staging => 'Staging',
        AppEnvironment.production => 'Production',
      };
}
