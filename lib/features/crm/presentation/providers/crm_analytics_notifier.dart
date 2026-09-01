import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/crm_entities.dart';
import '../../domain/repositories/crm_repository.dart';

sealed class CRMAnalyticsState extends Equatable {
  const CRMAnalyticsState();

  @override
  List<Object?> get props => [];
}

class CRMAnalyticsInitial extends CRMAnalyticsState {
  const CRMAnalyticsInitial();
}

class CRMAnalyticsLoading extends CRMAnalyticsState {
  const CRMAnalyticsLoading();
}

class CRMAnalyticsLoaded extends CRMAnalyticsState {
  final PerformanceAnalyticsEntity analytics;
  final BuilderProjectSalesEntity? projectSales;

  const CRMAnalyticsLoaded({
    required this.analytics,
    this.projectSales,
  });

  @override
  List<Object?> get props => [analytics, projectSales];
}

class CRMAnalyticsError extends CRMAnalyticsState {
  final String message;

  const CRMAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

final crmAnalyticsNotifierProvider =
    NotifierProvider<CRMAnalyticsNotifier, CRMAnalyticsState>(
  CRMAnalyticsNotifier.new,
);

class CRMAnalyticsNotifier extends Notifier<CRMAnalyticsState> {
  late final CRMRepository _repository;

  @override
  CRMAnalyticsState build() {
    _repository = getIt<CRMRepository>();
    return const CRMAnalyticsInitial();
  }

  Future<void> fetchAnalytics(String userId, [String? projectId]) async {
    state = const CRMAnalyticsLoading();
    final analyticsRes = await _repository.getPerformanceAnalytics(userId);

    analyticsRes.fold(
      (failure) => state = CRMAnalyticsError(failure.message),
      (analytics) async {
        BuilderProjectSalesEntity? sales;
        if (projectId != null) {
          final salesRes = await _repository.getProjectSalesMetrics(projectId);
          salesRes.fold((_) => null, (s) => sales = s);
        }
        state = CRMAnalyticsLoaded(analytics: analytics, projectSales: sales);
      },
    );
  }
}
