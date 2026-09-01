import 'package:injectable/injectable.dart';
import '../../../../core/utils/local_storage.dart';
import '../data/models/ai_models.dart';
import '../domain/entities/ai_entities.dart';

abstract class AICostOptimizationCache {
  Future<void> cacheAdvice(String locality, AIInvestmentAdviceEntity advice);
  AIInvestmentAdviceEntity? getAdvice(String locality);
}

@LazySingleton(as: AICostOptimizationCache)
class AICostOptimizationCacheImpl implements AICostOptimizationCache {
  final LocalStorage _localStorage;

  AICostOptimizationCacheImpl(this._localStorage);

  @override
  Future<void> cacheAdvice(String locality, AIInvestmentAdviceEntity advice) async {
    final key = 'ai_advice_${locality.toLowerCase()}';
    final model = AIInvestmentAdviceModel(
      locality: advice.locality,
      projectedAppreciation5Year: advice.projectedAppreciation5Year,
      estimatedRentalYield: advice.estimatedRentalYield,
      riskRating: advice.riskRating,
      summaryText: advice.summaryText,
      growthDrivers: advice.growthDrivers,
    );
    await _localStorage.put(key, model.toJson());
  }

  @override
  AIInvestmentAdviceEntity? getAdvice(String locality) {
    final key = 'ai_advice_${locality.toLowerCase()}';
    final raw = _localStorage.get(key);
    if (raw is Map) {
      return AIInvestmentAdviceModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}
