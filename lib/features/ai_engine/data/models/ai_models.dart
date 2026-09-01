import '../../domain/entities/ai_entities.dart';

class AIAssistantChatMessageModel extends AIAssistantChatMessageEntity {
  const AIAssistantChatMessageModel({
    required super.id,
    required super.text,
    required super.sender,
    required super.timestamp,
    super.recommendedPropertyIds = const [],
  });

  factory AIAssistantChatMessageModel.fromJson(Map<String, dynamic> json) {
    return AIAssistantChatMessageModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sender: AISenderRole.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => AISenderRole.assistant,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      recommendedPropertyIds: (json['recommended_property_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
        'recommended_property_ids': recommendedPropertyIds,
      };
}

class AIInvestmentAdviceModel extends AIInvestmentAdviceEntity {
  const AIInvestmentAdviceModel({
    required super.locality,
    required super.projectedAppreciation5Year,
    required super.estimatedRentalYield,
    required super.riskRating,
    required super.summaryText,
    required super.growthDrivers,
  });

  factory AIInvestmentAdviceModel.fromJson(Map<String, dynamic> json) {
    return AIInvestmentAdviceModel(
      locality: json['locality'] as String? ?? '',
      projectedAppreciation5Year: (json['projected_appreciation_5yr'] as num?)?.toDouble() ?? 0.0,
      estimatedRentalYield: (json['estimated_rental_yield'] as num?)?.toDouble() ?? 0.0,
      riskRating: json['risk_rating'] as String? ?? 'Moderate',
      summaryText: json['summary_text'] as String? ?? '',
      growthDrivers:
          (json['growth_drivers'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'locality': locality,
        'projected_appreciation_5yr': projectedAppreciation5Year,
        'estimated_rental_yield': estimatedRentalYield,
        'risk_rating': riskRating,
        'summary_text': summaryText,
        'growth_drivers': growthDrivers,
      };
}

class AIAreaIntelligenceModel extends AIAreaIntelligenceEntity {
  const AIAreaIntelligenceModel({
    required super.locality,
    required super.city,
    required super.livabilityScore,
    required super.nearbyKeyInfra,
    required super.pros,
    required super.cons,
  });

  factory AIAreaIntelligenceModel.fromJson(Map<String, dynamic> json) {
    return AIAreaIntelligenceModel(
      locality: json['locality'] as String? ?? '',
      city: json['city'] as String? ?? '',
      livabilityScore: json['livability_score'] as int? ?? 80,
      nearbyKeyInfra:
          (json['nearby_key_infra'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      pros: (json['pros'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      cons: (json['cons'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'locality': locality,
        'city': city,
        'livability_score': livabilityScore,
        'nearby_key_infra': nearbyKeyInfra,
        'pros': pros,
        'cons': cons,
      };
}

class AIDocumentSummaryModel extends AIDocumentSummaryEntity {
  const AIDocumentSummaryModel({
    required super.documentTitle,
    required super.summaryText,
    required super.isTitleClear,
    required super.keyClauses,
    required super.warnings,
  });

  factory AIDocumentSummaryModel.fromJson(Map<String, dynamic> json) {
    return AIDocumentSummaryModel(
      documentTitle: json['document_title'] as String? ?? '',
      summaryText: json['summary_text'] as String? ?? '',
      isTitleClear: json['is_title_clear'] as bool? ?? true,
      keyClauses: (json['key_clauses'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      warnings: (json['warnings'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'document_title': documentTitle,
        'summary_text': summaryText,
        'is_title_clear': isTitleClear,
        'key_clauses': keyClauses,
        'warnings': warnings,
      };
}

class AIMarketIntelligenceModel extends AIMarketIntelligenceEntity {
  const AIMarketIntelligenceModel({
    required super.city,
    required super.averagePricePerSqft,
    required super.priceTrendYoY,
    required super.activeListingsCount,
    required super.marketPhase,
  });

  factory AIMarketIntelligenceModel.fromJson(Map<String, dynamic> json) {
    return AIMarketIntelligenceModel(
      city: json['city'] as String? ?? '',
      averagePricePerSqft: (json['avg_price_per_sqft'] as num?)?.toDouble() ?? 0.0,
      priceTrendYoY: (json['price_trend_yoy'] as num?)?.toDouble() ?? 0.0,
      activeListingsCount: json['active_listings_count'] as int? ?? 0,
      marketPhase: json['market_phase'] as String? ?? 'Balanced',
    );
  }

  Map<String, dynamic> toJson() => {
        'city': city,
        'avg_price_per_sqft': averagePricePerSqft,
        'price_trend_yoy': priceTrendYoY,
        'active_listings_count': activeListingsCount,
        'market_phase': marketPhase,
      };
}
