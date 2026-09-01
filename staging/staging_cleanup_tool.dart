class StagingCleanupResult {
  final bool isSuccessful;
  final String testRunId;
  final int deletedListingsCount;
  final String message;

  const StagingCleanupResult({
    required this.isSuccessful,
    required this.testRunId,
    required this.deletedListingsCount,
    required this.message,
  });
}

class StagingCleanupTool {
  /// Safety check: strictly rejects production URLs
  static bool isTargetSafeStagingEnvironment(String databaseUrl, {bool isStagingFlag = false}) {
    final lower = databaseUrl.toLowerCase();
    if (lower.contains('prod') || lower.contains('production') || lower.contains('live')) {
      return false;
    }
    return isStagingFlag || lower.contains('staging') || lower.contains('localhost') || lower.contains('127.0.0.1');
  }

  /// Construct the SQL deletion query scoped strictly to [testRunId]
  static String buildSafeCleanupQuery({
    required String testRunId,
    required String targetDatabaseUrl,
    bool isStagingFlag = false,
  }) {
    if (!isTargetSafeStagingEnvironment(targetDatabaseUrl, isStagingFlag: isStagingFlag)) {
      throw SecurityException('ABORTED: Attempted to run synthetic data cleanup on a non-staging target: $targetDatabaseUrl');
    }

    if (testRunId.trim().isEmpty) {
      throw ArgumentError('testRunId must not be empty. Full table drops are strictly forbidden.');
    }

    // Scoped deletion cascade
    return '''
-- Safe Scoped Synthetic Cleanup for Test Run: $testRunId
DELETE FROM property_media WHERE property_id IN (SELECT id FROM properties WHERE test_run_id = '$testRunId');
DELETE FROM property_inquiries WHERE property_id IN (SELECT id FROM properties WHERE test_run_id = '$testRunId');
DELETE FROM properties WHERE test_run_id = '$testRunId';
''';
  }
}

class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
