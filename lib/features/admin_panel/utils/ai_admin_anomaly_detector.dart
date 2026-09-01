class AIAdminAnomalyDetector {
  AIAdminAnomalyDetector._();

  /// Analyzes platform metrics for unexpected anomalies (e.g. fake listing spikes or lead spam)
  static List<String> detectAnomalies({
    required int hourlyLeadsCount,
    required int newPropertiesCount,
  }) {
    final anomalies = <String>[];
    if (hourlyLeadsCount > 500) {
      anomalies.add('AI Alert: Unusually high lead creation rate ($hourlyLeadsCount leads/hr). Potential bot activity.');
    }
    if (newPropertiesCount > 200) {
      anomalies.add('AI Alert: Mass listing bulk upload detected ($newPropertiesCount properties/hr). Auto-flagged for review.');
    }
    return anomalies;
  }
}
