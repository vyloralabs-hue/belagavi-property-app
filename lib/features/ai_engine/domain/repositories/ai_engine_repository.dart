import '../../../../core/utils/typedefs.dart';
import '../entities/ai_entities.dart';

abstract class AIEngineRepository {
  FutureEither<AIAssistantChatMessageEntity> sendMessageToAssistant(
    String userPrompt,
    List<AIAssistantChatMessageEntity> history,
  );

  FutureEither<String> transcribeVoiceSearch(List<int> audioBytes);

  FutureEither<AIInvestmentAdviceEntity> getInvestmentAdvice(String locality);

  FutureEither<AIAreaIntelligenceEntity> getAreaIntelligence(String locality);

  FutureEither<AIDocumentSummaryEntity> summarizeLegalDocument(String documentUrl);

  FutureEither<AIMarketIntelligenceEntity> getMarketIntelligence(String city);
}
