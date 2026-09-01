import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/repositories/ai_engine_repository.dart';

sealed class AIIntelligenceState extends Equatable {
  const AIIntelligenceState();

  @override
  List<Object?> get props => [];
}

class AIIntelligenceInitial extends AIIntelligenceState {
  const AIIntelligenceInitial();
}

class AIIntelligenceLoading extends AIIntelligenceState {
  const AIIntelligenceLoading();
}

class AIIntelligenceLoaded extends AIIntelligenceState {
  final AIInvestmentAdviceEntity? investmentAdvice;
  final AIAreaIntelligenceEntity? areaIntelligence;
  final AIMarketIntelligenceEntity? marketIntelligence;

  const AIIntelligenceLoaded({
    this.investmentAdvice,
    this.areaIntelligence,
    this.marketIntelligence,
  });

  @override
  List<Object?> get props => [investmentAdvice, areaIntelligence, marketIntelligence];
}

class AIIntelligenceError extends AIIntelligenceState {
  final String message;

  const AIIntelligenceError(this.message);

  @override
  List<Object?> get props => [message];
}

final aiIntelligenceNotifierProvider =
    NotifierProvider<AIIntelligenceNotifier, AIIntelligenceState>(
  AIIntelligenceNotifier.new,
);

class AIIntelligenceNotifier extends Notifier<AIIntelligenceState> {
  late final AIEngineRepository _repository;

  @override
  AIIntelligenceState build() {
    _repository = getIt<AIEngineRepository>();
    return const AIIntelligenceInitial();
  }

  Future<void> fetchLocalityInsights(String locality, String city) async {
    state = const AIIntelligenceLoading();
    final adviceRes = await _repository.getInvestmentAdvice(locality);
    final areaRes = await _repository.getAreaIntelligence(locality);
    final marketRes = await _repository.getMarketIntelligence(city);

    AIInvestmentAdviceEntity? advice;
    AIAreaIntelligenceEntity? area;
    AIMarketIntelligenceEntity? market;

    adviceRes.fold((_) => null, (data) => advice = data);
    areaRes.fold((_) => null, (data) => area = data);
    marketRes.fold((_) => null, (data) => market = data);

    state = AIIntelligenceLoaded(
      investmentAdvice: advice,
      areaIntelligence: area,
      marketIntelligence: market,
    );
  }
}
