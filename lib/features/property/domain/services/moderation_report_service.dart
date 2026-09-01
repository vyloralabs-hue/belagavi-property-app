import 'package:equatable/equatable.dart';

enum ListingReportReason {
  duplicateListing,
  wrongLocation,
  fraudulentPrice,
  alreadySold,
  inappropriateContent,
  misleadingDetails,
  other,
}

enum ReportStatus { pending, reviewed, actionTaken, dismissed }

class ListingModerationReport extends Equatable {
  final String id;
  final String propertyId;
  final String reporterUserId;
  final ListingReportReason reason;
  final String description;
  final ReportStatus status;
  final DateTime reportedAt;

  const ListingModerationReport({
    required this.id,
    required this.propertyId,
    required this.reporterUserId,
    required this.reason,
    required this.description,
    this.status = ReportStatus.pending,
    required this.reportedAt,
  });

  @override
  List<Object?> get props => [id, propertyId, reporterUserId, reason, status, reportedAt];
}

class ModerationReportService {
  final List<ListingModerationReport> _reports = [];
  final Map<String, Set<String>> _userBlocklists = {}; // userId -> Set of blockedUserIds

  List<ListingModerationReport> get pendingReports =>
      _reports.where((r) => r.status == ReportStatus.pending).toList();

  /// Submit a listing report with rate limit guard
  ListingModerationReport submitReport({
    required String propertyId,
    required String reporterUserId,
    required ListingReportReason reason,
    required String description,
  }) {
    // Check if user already reported this property in pending state
    final existing = _reports.any(
      (r) => r.propertyId == propertyId && r.reporterUserId == reporterUserId && r.status == ReportStatus.pending,
    );
    if (existing) {
      throw StateError('You have already submitted a pending report for this listing.');
    }

    final report = ListingModerationReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      reporterUserId: reporterUserId,
      reason: reason,
      description: description.trim(),
      reportedAt: DateTime.now(),
    );

    _reports.add(report);
    return report;
  }

  /// Block an abusive user from contacting or sending enquiries
  void blockUser({required String currentUserId, required String targetUserId}) {
    _userBlocklists.putIfAbsent(currentUserId, () => {}).add(targetUserId);
  }

  /// Check if an interaction is blocked
  bool isBlocked({required String currentUserId, required String targetUserId}) {
    return _userBlocklists[currentUserId]?.contains(targetUserId) ?? false;
  }
}
