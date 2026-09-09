/// Configurable Public Legal Notice Duration Configuration
/// Defaults to 10 days per CTO Master Directive.
class LegalNoticeConfig {
  LegalNoticeConfig._();

  /// Default public visibility window for property legal notices in days
  static const int defaultPublicNoticeDays = 10;

  /// Duration object for public notices
  static const Duration defaultPublicNoticeDuration = Duration(days: defaultPublicNoticeDays);

  /// Calculate the public_until timestamp given a published_at timestamp
  static DateTime calculatePublicUntil(DateTime publishedAt, [int days = defaultPublicNoticeDays]) {
    return publishedAt.add(Duration(days: days));
  }

  /// Helper to calculate remaining days until public expiry
  /// Returns 0 if expired.
  static int remainingDays(DateTime? publicUntil, [DateTime? now]) {
    if (publicUntil == null) return 0;
    final current = now ?? DateTime.now();
    final diff = publicUntil.difference(current);
    if (diff.isNegative) return 0;
    return (diff.inHours / 24).ceil();
  }

  /// Returns true if the notice public window is still active
  static bool isPubliclyActive({
    required String status,
    required DateTime? publishedAt,
    required DateTime? publicUntil,
    DateTime? now,
  }) {
    if (status != 'published') return false;
    final current = now ?? DateTime.now();
    if (publishedAt != null && publishedAt.isAfter(current)) return false;
    if (publicUntil != null && !publicUntil.isAfter(current)) return false;
    return true;
  }
}
