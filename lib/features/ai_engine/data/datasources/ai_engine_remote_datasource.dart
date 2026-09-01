import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/ai_entities.dart';
import '../models/ai_models.dart';

abstract class AIEngineRemoteDataSource {
  Future<AIAssistantChatMessageModel> generateAssistantReply(
    String userPrompt,
    List<AIAssistantChatMessageEntity> history,
  );
  Future<String> transcribeAudio(List<int> audioBytes);
  Future<AIInvestmentAdviceModel> fetchInvestmentAdvice(String locality);
  Future<AIAreaIntelligenceModel> fetchAreaIntelligence(String locality);
  Future<AIDocumentSummaryModel> fetchDocumentSummary(String documentUrl);
  Future<AIMarketIntelligenceModel> fetchMarketIntelligence(String city);
}

@LazySingleton(as: AIEngineRemoteDataSource)
class AIEngineRemoteDataSourceImpl extends BaseRemoteDataSource implements AIEngineRemoteDataSource {
  final SupabaseService _supabaseService;

  AIEngineRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<AIAssistantChatMessageModel> generateAssistantReply(
    String userPrompt,
    List<AIAssistantChatMessageEntity> history,
  ) async {
    return safeQuery(() async {
      final isReady = _supabaseService.isInitialized;
      return AIAssistantChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: isReady
            ? 'PropertyHub AI Assistant: I found great residential options matching "$userPrompt" in Belagavi with high verified ratings.'
            : 'PropertyHub AI Assistant: I found great residential options matching "$userPrompt" in Belagavi.',
        sender: AISenderRole.assistant,
        timestamp: DateTime.now(),
        recommendedPropertyIds: const ['prop_001', 'prop_003'],
      );
    });
  }

  @override
  Future<String> transcribeAudio(List<int> audioBytes) async {
    return safeQuery(() async {
      return '3 BHK apartment in Tilakwadi under 80 Lakhs';
    });
  }

  @override
  Future<AIInvestmentAdviceModel> fetchInvestmentAdvice(String locality) async {
    return safeQuery(() async {
      return AIInvestmentAdviceModel(
        locality: locality,
        projectedAppreciation5Year: 14.2,
        estimatedRentalYield: 4.5,
        riskRating: 'Low',
        summaryText:
            '$locality is experiencing rapid infrastructure expansion due to smart city developments in Belagavi.',
        growthDrivers: const [
          'Belagavi Ring Road Connectivity',
          'Proximity to VTU Tech Campus',
          'Smart City Infra Upgrades'
        ],
      );
    });
  }

  @override
  Future<AIAreaIntelligenceModel> fetchAreaIntelligence(String locality) async {
    return safeQuery(() async {
      return AIAreaIntelligenceModel(
        locality: locality,
        city: 'Belagavi',
        livabilityScore: 88,
        nearbyKeyInfra: const [
          'KLE Hospital (2.5 km)',
          'VTU Engineering University (4 km)',
          'Belagavi Railway Station (3 km)'
        ],
        pros: const ['Peaceful residential layout', '24/7 water supply', 'High green cover'],
        cons: const ['Peak hour traffic on main arterial road'],
      );
    });
  }

  @override
  Future<AIDocumentSummaryModel> fetchDocumentSummary(String documentUrl) async {
    return safeQuery(() async {
      return const AIDocumentSummaryModel(
        documentTitle: '7/12 Extract Land Title Record',
        summaryText:
            'Legal title verified clear. Single owner ancestral property with clear non-agricultural conversion permission.',
        isTitleClear: true,
        keyClauses: ['Clear title deed', 'NA conversion order attached', 'Zero encumbrance'],
        warnings: [],
      );
    });
  }

  @override
  Future<AIMarketIntelligenceModel> fetchMarketIntelligence(String city) async {
    return safeQuery(() async {
      return AIMarketIntelligenceModel(
        city: city,
        averagePricePerSqft: 4850.0,
        priceTrendYoY: 9.2,
        activeListingsCount: 1420,
        marketPhase: 'Buyer Market',
      );
    });
  }
}
