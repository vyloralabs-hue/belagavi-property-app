import 'package:equatable/equatable.dart';

class LatencyPercentiles extends Equatable {
  final double p50;
  final double p95;
  final double p99;
  final int sampleCount;

  const LatencyPercentiles({
    required this.p50,
    required this.p95,
    required this.p99,
    required this.sampleCount,
  });

  @override
  List<Object?> get props => [p50, p95, p99, sampleCount];
}

class MarketplaceSLOStatus extends Equatable {
  final bool isSearchSloMet; // p95 < 500ms
  final bool isDetailSloMet; // p95 < 400ms
  final bool isWriteSloMet; // p95 < 1000ms
  final double errorRatePercentage;
  final bool isOverallHealthy;

  const MarketplaceSLOStatus({
    required this.isSearchSloMet,
    required this.isDetailSloMet,
    required this.isWriteSloMet,
    required this.errorRatePercentage,
    required this.isOverallHealthy,
  });

  @override
  List<Object?> get props => [
    isSearchSloMet,
    isDetailSloMet,
    isWriteSloMet,
    errorRatePercentage,
    isOverallHealthy,
  ];
}

/// Centralized Observability & SLO Monitor for crore-scale operations
class MarketplaceObservabilityService {
  final Map<String, List<int>> _latencySamples = {};
  int _totalRequests = 0;
  int _totalErrors = 0;

  void recordLatency(String operationName, int durationMs) {
    _totalRequests++;
    _latencySamples.putIfAbsent(operationName, () => []).add(durationMs);

    // Keep sliding window of latest 1000 samples to prevent memory leak
    if (_latencySamples[operationName]!.length > 1000) {
      _latencySamples[operationName]!.removeAt(0);
    }
  }

  void recordError(String operationName) {
    _totalRequests++;
    _totalErrors++;
  }

  LatencyPercentiles calculatePercentiles(String operationName) {
    final samples = _latencySamples[operationName];
    if (samples == null || samples.isEmpty) {
      return const LatencyPercentiles(p50: 0, p95: 0, p99: 0, sampleCount: 0);
    }

    final sorted = List<int>.from(samples)..sort();
    final count = sorted.length;

    final p50 = sorted[(count * 0.50).floor().clamp(0, count - 1)].toDouble();
    final p95 = sorted[(count * 0.95).floor().clamp(0, count - 1)].toDouble();
    final p99 = sorted[(count * 0.99).floor().clamp(0, count - 1)].toDouble();

    return LatencyPercentiles(p50: p50, p95: p95, p99: p99, sampleCount: count);
  }

  MarketplaceSLOStatus evaluateSloStatus() {
    final searchPercentiles = calculatePercentiles('search');
    final detailPercentiles = calculatePercentiles('property_detail');
    final writePercentiles = calculatePercentiles('property_write');

    final searchMet =
        searchPercentiles.sampleCount == 0 || searchPercentiles.p95 <= 500.0;
    final detailMet =
        detailPercentiles.sampleCount == 0 || detailPercentiles.p95 <= 400.0;
    final writeMet =
        writePercentiles.sampleCount == 0 || writePercentiles.p95 <= 1000.0;

    final errorRate = _totalRequests > 0
        ? (_totalErrors / _totalRequests) * 100.0
        : 0.0;
    final isHealthy = searchMet && detailMet && writeMet && errorRate < 1.0;

    return MarketplaceSLOStatus(
      isSearchSloMet: searchMet,
      isDetailSloMet: detailMet,
      isWriteSloMet: writeMet,
      errorRatePercentage: double.parse(errorRate.toStringAsFixed(2)),
      isOverallHealthy: isHealthy,
    );
  }
}
