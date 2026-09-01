import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_engine/domain/entities/ai_entities.dart';
import '../../../ai_engine/presentation/providers/ai_assistant_notifier.dart';
import '../../theme/app_design_system.dart';

class AIAssistantChatSheet extends ConsumerStatefulWidget {
  const AIAssistantChatSheet({super.key});

  @override
  ConsumerState<AIAssistantChatSheet> createState() =>
      _AIAssistantChatSheetState();
}

class _AIAssistantChatSheetState extends ConsumerState<AIAssistantChatSheet> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(aiAssistantNotifierProvider.notifier).sendUserMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppDesignSystem.primaryNavy,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.white),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PropertyHub AI Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Powered by Gemini Real Estate Intelligence',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (aiState) {
              AIAssistantInitial() => const Center(
                child: Text(
                  'Ask me anything about Belagavi properties & market trends!',
                ),
              ),
              AIAssistantLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AIAssistantError(message: final msg) => Center(
                child: Text('Error: $msg'),
              ),
              AIAssistantSuccess(chatHistory: final history) =>
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final msg = history[index];
                    final isUser = msg.sender == AISenderRole.user;
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppDesignSystem.primaryNavy
                              : AppDesignSystem.backgroundWhite,
                          borderRadius: AppDesignSystem.borderRadiusM,
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser
                                ? Colors.white
                                : AppDesignSystem.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your property question...',
                      border: const OutlineInputBorder(
                        borderRadius: AppDesignSystem.borderRadiusPill,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppDesignSystem.accentEmerald,
                  onPressed: _send,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
