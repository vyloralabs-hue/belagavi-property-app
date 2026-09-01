class FeatureFlags {
  final bool isVideoUploadEnabled;
  final bool isBulkImportEnabled;
  final bool isBuilderProjectsEnabled;
  final bool isDisputeRegistryEnabled;
  final bool isLegalNoticeHubEnabled;
  final bool isAiSearchEnabled;
  final bool isSharedShortlistEnabled;
  final bool isBiometricUnlockEnabled;

  const FeatureFlags({
    this.isVideoUploadEnabled = true,
    this.isBulkImportEnabled = true,
    this.isBuilderProjectsEnabled = true,
    this.isDisputeRegistryEnabled = true,
    this.isLegalNoticeHubEnabled = true,
    this.isAiSearchEnabled = true,
    this.isSharedShortlistEnabled = true,
    this.isBiometricUnlockEnabled = true,
  });

  /// Production default flags
  static const FeatureFlags defaults = FeatureFlags();
}
