import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../entities/property_entities.dart';

enum FraudRiskLevel { low, medium, high, critical }

class FraudRiskSignal {
  final String ruleCode;
  final String description;
  final int severityPoints;

  const FraudRiskSignal({
    required this.ruleCode,
    required this.description,
    required this.severityPoints,
  });
}

class FraudRiskReport {
  final String propertyId;
  final int riskScore; // 0 to 100
  final FraudRiskLevel level;
  final List<FraudRiskSignal> signals;
  final String propertyFingerprint;
  final bool requiresManualModeration;

  const FraudRiskReport({
    required this.propertyId,
    required this.riskScore,
    required this.level,
    required this.signals,
    required this.propertyFingerprint,
    required this.requiresManualModeration,
  });
}

class DuplicateFraudDetectionEngine {
  const DuplicateFraudDetectionEngine();

  /// Generate a deterministic SHA-256 fingerprint for a property listing based on physical attributes
  static String generatePropertyFingerprint(PropertyEntity property) {
    final normalizedLocality = property.locality.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final normalizedCity = property.city.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final normalizedCategory = property.category.name.toLowerCase();
    final normalizedSubtype = property.type.name.toLowerCase();
    final area = property.specifications.superBuiltUpArea ?? property.specifications.carpetArea ?? property.specifications.plotArea ?? 0.0;
    final bedrooms = property.specifications.bedrooms ?? 0;

    final rawPayload = '$normalizedCity|$normalizedLocality|$normalizedCategory|$normalizedSubtype|$area|$bedrooms';
    final bytes = utf8.encode(rawPayload);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Analyze property against known market baseline and conflicting listings
  static FraudRiskReport evaluate({
    required PropertyEntity property,
    List<PropertyEntity> existingListings = const [],
    double? localityMedianPrice,
    int sellerPostsInLastHour = 0,
  }) {
    final signals = <FraudRiskSignal>[];
    int score = 0;
    final fingerprint = generatePropertyFingerprint(property);

    // 1. Check for Duplicate Fingerprint with different owner
    final matchingFingerprints = existingListings.where(
      (other) => other.id != property.id && generatePropertyFingerprint(other) == fingerprint,
    ).toList();

    if (matchingFingerprints.isNotEmpty) {
      final conflictingOwners = matchingFingerprints.where((other) => other.ownerId != property.ownerId).toList();
      if (conflictingOwners.isNotEmpty) {
        signals.add(const FraudRiskSignal(
          ruleCode: 'DUPLICATE_CROSS_OWNER_FINGERPRINT',
          description: 'Identical physical property fingerprint exists under a different seller ID.',
          severityPoints: 50,
        ));
        score += 50;
      } else {
        signals.add(const FraudRiskSignal(
          ruleCode: 'DUPLICATE_SAME_OWNER_REPOST',
          description: 'Seller has posted an identical duplicate listing instead of updating the existing record.',
          severityPoints: 20,
        ));
        score += 20;
      }
    }

    // 2. High-Frequency Posting Burst
    if (sellerPostsInLastHour > 10) {
      signals.add(FraudRiskSignal(
        ruleCode: 'HIGH_FREQUENCY_POSTING_BURST',
        description: 'Seller has created $sellerPostsInLastHour listings within the last hour (potential bot spam).',
        severityPoints: 35,
      ));
      score += 35;
    } else if (sellerPostsInLastHour > 5) {
      signals.add(FraudRiskSignal(
        ruleCode: 'SUSPICIOUS_POSTING_VELOCITY',
        description: 'Rapid listing creation detected ($sellerPostsInLastHour in last hour).',
        severityPoints: 15,
      ));
      score += 15;
    }

    // 3. Price Anomaly against Locality Median
    if (localityMedianPrice != null && localityMedianPrice > 0 && property.price > 0) {
      final ratio = property.price / localityMedianPrice;
      if (ratio < 0.20) {
        signals.add(FraudRiskSignal(
          ruleCode: 'EXTREME_UNDERPRICING_ANOMALY',
          description: 'Asking price is ${((1 - ratio) * 100).toInt()}% below locality median (possible advance-fee bait).',
          severityPoints: 40,
        ));
        score += 40;
      } else if (ratio > 5.0) {
        signals.add(FraudRiskSignal(
          ruleCode: 'EXTREME_OVERPRICING_ANOMALY',
          description: 'Asking price is ${ratio.toStringAsFixed(1)}x above locality median.',
          severityPoints: 15,
        ));
        score += 15;
      }
    }

    // 4. Missing Essential Specifications
    if (property.price <= 0) {
      signals.add(const FraudRiskSignal(
        ruleCode: 'INVALID_ZERO_PRICE',
        description: 'Property posted with zero or negative price.',
        severityPoints: 25,
      ));
      score += 25;
    }

    final finalScore = score.clamp(0, 100);
    final FraudRiskLevel level;
    if (finalScore >= 70) {
      level = FraudRiskLevel.critical;
    } else if (finalScore >= 45) {
      level = FraudRiskLevel.high;
    } else if (finalScore >= 20) {
      level = FraudRiskLevel.medium;
    } else {
      level = FraudRiskLevel.low;
    }

    return FraudRiskReport(
      propertyId: property.id,
      riskScore: finalScore,
      level: level,
      signals: signals,
      propertyFingerprint: fingerprint,
      requiresManualModeration: finalScore >= 45,
    );
  }
}
