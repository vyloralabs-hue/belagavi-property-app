import 'package:equatable/equatable.dart';

class RecentlyViewedEntry extends Equatable {
  final String propertyId;
  final DateTime viewedAt;

  const RecentlyViewedEntry({
    required this.propertyId,
    required this.viewedAt,
  });

  @override
  List<Object?> get props => [propertyId, viewedAt];
}

class RecentlyViewedService {
  static const int maxHistoryLimit = 30;
  final List<RecentlyViewedEntry> _history = [];

  List<RecentlyViewedEntry> get history => List.unmodifiable(_history);

  /// Record a viewed property safely without duplicates, moving to most recent
  void recordView(String propertyId) {
    _history.removeWhere((e) => e.propertyId == propertyId);
    _history.insert(0, RecentlyViewedEntry(propertyId: propertyId, viewedAt: DateTime.now()));

    if (_history.length > maxHistoryLimit) {
      _history.removeRange(maxHistoryLimit, _history.length);
    }
  }

  /// Clear view history
  void clearHistory() {
    _history.clear();
  }
}
