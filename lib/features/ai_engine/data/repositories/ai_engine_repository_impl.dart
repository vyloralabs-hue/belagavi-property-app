import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/repositories/ai_engine_repository.dart';
import '../datasources/ai_engine_remote_datasource.dart';
import '../../utils/ai_cost_optimization_cache.dart';

@LazySingleton(as: AIEngineRepository)
class AIEngineRepositoryImpl extends BaseRepository implements AIEngineRepository {
  final AIEngineRemoteDataSource _remoteDataSource;
  final AICostOptimizationCache _cache;

  AIEngineRepositoryImpl(this._remoteDataSource, this._cache);

  @override
  FutureEither<AIAssistantChatMessageEntity> sendMessageToAssistant(
    String userPrompt,
    List<AIAssistantChatMessageEntity> history,
  ) async {
    return safeCall(() => _remoteDataSource.generateAssistantReply(userPrompt, history));
  }

  @override
  FutureEither<String> transcribeVoiceSearch(List<int> audioBytes) async {
    return safeCall(() => _remoteDataSource.transcribeAudio(audioBytes));
  }

  @override
  FutureEither<AIInvestmentAdviceEntity> getInvestmentAdvice(String locality) async {
    return safeCall(() async {
      final cached = _cache.getAdvice(locality);
      if (cached != null) return cached;
      final res = await _remoteDataSource.fetchInvestmentAdvice(locality);
      await _cache.cacheAdvice(locality, res);
      return res;
    });
  }

  @override
  FutureEither<AIAreaIntelligenceEntity> getAreaIntelligence(String locality) async {
    return safeCall(() => _remoteDataSource.fetchAreaIntelligence(locality));
  }

  @override
  FutureEither<AIDocumentSummaryEntity> summarizeLegalDocument(String documentUrl) async {
    return safeCall(() => _remoteDataSource.fetchDocumentSummary(documentUrl));
  }

  @override
  FutureEither<AIMarketIntelligenceEntity> getMarketIntelligence(String city) async {
    return safeCall(() => _remoteDataSource.fetchMarketIntelligence(city));
  }
}
