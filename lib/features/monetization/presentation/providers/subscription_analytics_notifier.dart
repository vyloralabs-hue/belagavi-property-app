import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class SubscriptionAnalyticsState extends Equatable {
  const SubscriptionAnalyticsState();

  @override
  List<Object?> get props => [];
}

class SubscriptionAnalyticsInitial extends SubscriptionAnalyticsState {
  const SubscriptionAnalyticsInitial();
}

class SubscriptionAnalyticsLoaded extends SubscriptionAnalyticsState {
  final double mrrInr; // Monthly Recurring Revenue
  final double arrInr; // Annual Recurring Revenue
  final int activePaidSubscribers;
  final int totalBoostPackagesSold;

  const SubscriptionAnalyticsLoaded({
    required this.mrrInr,
    required this.arrInr,
    required this.activePaidSubscribers,
    required this.totalBoostPackagesSold,
  });

  @override
  List<Object?> get props => [mrrInr, arrInr, activePaidSubscribers, totalBoostPackagesSold];
}

final subscriptionAnalyticsNotifierProvider =
    NotifierProvider<SubscriptionAnalyticsNotifier, SubscriptionAnalyticsState>(
  SubscriptionAnalyticsNotifier.new,
);

class SubscriptionAnalyticsNotifier extends Notifier<SubscriptionAnalyticsState> {
  @override
  SubscriptionAnalyticsState build() {
    return const SubscriptionAnalyticsLoaded(
      mrrInr: 450000.0,
      arrInr: 5400000.0,
      activePaidSubscribers: 320,
      totalBoostPackagesSold: 145,
    );
  }
}
