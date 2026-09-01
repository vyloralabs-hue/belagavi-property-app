import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_panel_repository.dart';

sealed class AdminAnalyticsState extends Equatable {
  const AdminAnalyticsState();

  @override
  List<Object?> get props => [];
}

class AdminAnalyticsInitial extends AdminAnalyticsState {
  const AdminAnalyticsInitial();
}

class AdminAnalyticsLoading extends AdminAnalyticsState {
  const AdminAnalyticsLoading();
}

class AdminAnalyticsLoaded extends AdminAnalyticsState {
  final PlatformAnalyticsEntity analytics;
  final List<SecurityThreatLogEntity> threatLogs;

  const AdminAnalyticsLoaded({
    required this.analytics,
    required this.threatLogs,
  });

  @override
  List<Object?> get props => [analytics, threatLogs];
}

class AdminAnalyticsError extends AdminAnalyticsState {
  final String message;

  const AdminAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

final adminAnalyticsNotifierProvider =
    NotifierProvider<AdminAnalyticsNotifier, AdminAnalyticsState>(
  AdminAnalyticsNotifier.new,
);

class AdminAnalyticsNotifier extends Notifier<AdminAnalyticsState> {
  late final AdminPanelRepository _repository;

  @override
  AdminAnalyticsState build() {
    _repository = getIt<AdminPanelRepository>();
    return const AdminAnalyticsInitial();
  }

  Future<void> fetchDashboardMetrics() async {
    state = const AdminAnalyticsLoading();
    final analyticsRes = await _repository.getPlatformAnalytics();
    final logsRes = await _repository.getSecurityThreatLogs();

    analyticsRes.fold(
      (failure) => state = AdminAnalyticsError(failure.message),
      (analytics) {
        List<SecurityThreatLogEntity> logs = const [];
        logsRes.fold((_) => null, (l) => logs = l);
        state = AdminAnalyticsLoaded(analytics: analytics, threatLogs: logs);
      },
    );
  }

  Future<void> blockIp(String ip) async {
    final res = await _repository.blockIpAddress(ip);
    res.fold(
      (failure) => state = AdminAnalyticsError(failure.message),
      (_) => fetchDashboardMetrics(),
    );
  }
}
