/// Production Remote Configuration & Release Governance Flags (Phase 19)
class AppRemoteConfigService {
  AppRemoteConfigService._();
  static final AppRemoteConfigService instance = AppRemoteConfigService._();

  bool _maintenanceMode = false;
  bool _propertyPostingEnabled = true;
  bool _legalModuleEnabled = true;
  String _minSupportedAppVersion = '1.0.0';

  bool get maintenanceMode => _maintenanceMode;
  bool get propertyPostingEnabled => _propertyPostingEnabled;
  bool get legalModuleEnabled => _legalModuleEnabled;
  String get minSupportedAppVersion => _minSupportedAppVersion;

  void updateFlags({
    bool? maintenanceMode,
    bool? propertyPostingEnabled,
    bool? legalModuleEnabled,
    String? minSupportedAppVersion,
  }) {
    if (maintenanceMode != null) _maintenanceMode = maintenanceMode;
    if (propertyPostingEnabled != null) _propertyPostingEnabled = propertyPostingEnabled;
    if (legalModuleEnabled != null) _legalModuleEnabled = legalModuleEnabled;
    if (minSupportedAppVersion != null) _minSupportedAppVersion = minSupportedAppVersion;
  }

  bool isVersionSupported(String currentVersion) {
    try {
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final minParts = _minSupportedAppVersion.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final cur = i < currentParts.length ? currentParts[i] : 0;
        final min = i < minParts.length ? minParts[i] : 0;
        if (cur > min) return true;
        if (cur < min) return false;
      }
      return true;
    } catch (_) {
      return true;
    }
  }
}
