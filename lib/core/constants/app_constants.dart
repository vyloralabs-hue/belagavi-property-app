class AppConstants {
  AppConstants._();

  static const String projectName = 'Belagavi Property';
  static const String platformBrand = 'Belagavi Property';
  static const String appVersion = '1.0.0+1';

  // Network & Timeouts
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;

  // Cache & Storage Keys
  static const String themeModeKey = 'propertyhub_theme_mode';
  static const String authTokenKey = 'propertyhub_auth_token';
  static const String userPrefsBoxName = 'propertyhub_user_prefs';

  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
}
