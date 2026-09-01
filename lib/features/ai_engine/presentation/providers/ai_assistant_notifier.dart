import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/repositories/ai_engine_repository.dart';

sealed class AIAssistantState extends Equatable {
  const AIAssistantState();

  @override
  List<Object?> get props => [];
}

class AIAssistantInitial extends AIAssistantState {
  const AIAssistantInitial();
}

class AIAssistantLoading extends AIAssistantState {
  const AIAssistantLoading();
}

class AIAssistantSuccess extends AIAssistantState {
  final List<AIAssistantChatMessageEntity> chatHistory;

  const AIAssistantSuccess(this.chatHistory);

  @override
  List<Object?> get props => [chatHistory];
}

class AIAssistantError extends AIAssistantState {
  final String message;

  const AIAssistantError(this.message);

  @override
  List<Object?> get props => [message];
}

final aiAssistantNotifierProvider =
    NotifierProvider<AIAssistantNotifier, AIAssistantState>(
      AIAssistantNotifier.new,
    );

class AIAssistantNotifier extends Notifier<AIAssistantState> {
  AIEngineRepository get _repository => getIt<AIEngineRepository>();
  final List<AIAssistantChatMessageEntity> _messages = [];

  @override
  AIAssistantState build() {
    return const AIAssistantInitial();
  }

  Future<void> sendUserMessage(String prompt) async {
    final userMsg = AIAssistantChatMessageEntity(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      text: prompt,
      sender: AISenderRole.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    state = AIAssistantSuccess(List.unmodifiable(_messages));

    final result = await _repository.sendMessageToAssistant(prompt, _messages);
    result.fold((failure) => state = AIAssistantError(failure.message), (
      reply,
    ) {
      _messages.add(reply);
      state = AIAssistantSuccess(List.unmodifiable(_messages));
    });
  }
}
