import 'package:equatable/equatable.dart';

enum AISenderRole { user, assistant, system }

class AIAssistantChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final AISenderRole sender;
  final DateTime timestamp;
  final List<String> recommendedPropertyIds;

  const AIAssistantChatMessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.recommendedPropertyIds = const [],
  });

  @override
  List<Object?> get props => [id, text, sender, timestamp, recommendedPropertyIds];
}

class AIInvestmentAdviceEntity extends Equatable {
  final String locality;
  final double projectedAppreciation5Year; // e.g. 12.5%
  final double estimatedRentalYield; // e.g. 4.2%
  final String riskRating; // 'Low', 'Moderate', 'High'
  final String summaryText;
  final List<String> growthDrivers;

  const AIInvestmentAdviceEntity({
    required this.locality,
    required this.projectedAppreciation5Year,
    required this.estimatedRentalYield,
    required this.riskRating,
    required this.summaryText,
    required this.growthDrivers,
  });

  @override
  List<Object?> get props => [
        locality,
        projectedAppreciation5Year,
        estimatedRentalYield,
        riskRating,
        summaryText,
        growthDrivers,
      ];
}

class AIAreaIntelligenceEntity extends Equatable {
  final String locality;
  final String city;
  final int livabilityScore; // 0 to 100
  final List<String> nearbyKeyInfra;
  final List<String> pros;
  final List<String> cons;

  const AIAreaIntelligenceEntity({
    required this.locality,
    required this.city,
    required this.livabilityScore,
    required this.nearbyKeyInfra,
    required this.pros,
    required this.cons,
  });

  @override
  List<Object?> get props => [locality, city, livabilityScore, nearbyKeyInfra, pros, cons];
}

class AIDocumentSummaryEntity extends Equatable {
  final String documentTitle;
  final String summaryText;
  final bool isTitleClear;
  final List<String> keyClauses;
  final List<String> warnings;

  const AIDocumentSummaryEntity({
    required this.documentTitle,
    required this.summaryText,
    required this.isTitleClear,
    required this.keyClauses,
    required this.warnings,
  });

  @override
  List<Object?> get props => [documentTitle, summaryText, isTitleClear, keyClauses, warnings];
}

class AIMarketIntelligenceEntity extends Equatable {
  final String city;
  final double averagePricePerSqft;
  final double priceTrendYoY; // e.g. +8.4%
  final int activeListingsCount;
  final String marketPhase; // 'Buyer Market', 'Seller Market', 'Balanced'

  const AIMarketIntelligenceEntity({
    required this.city,
    required this.averagePricePerSqft,
    required this.priceTrendYoY,
    required this.activeListingsCount,
    required this.marketPhase,
  });

  @override
  List<Object?> get props => [
        city,
        averagePricePerSqft,
        priceTrendYoY,
        activeListingsCount,
        marketPhase,
      ];
}
