import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_engine/domain/entities/ai_entities.dart';
import '../../../ai_engine/presentation/providers/ai_assistant_notifier.dart';
import '../../theme/app_design_system.dart';
import 'widgets/ai_listing_quality_card.dart';
import 'widgets/ai_quick_prompt_chips.dart';
import 'widgets/ai_voice_search_dialog.dart';

class AIAssistantView extends ConsumerStatefulWidget {
  const AIAssistantView({super.key});

  @override
  ConsumerState<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends ConsumerState<AIAssistantView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _send([String? customText]) {
    final text = (customText ?? _textController.text).trim();
    if (text.isNotEmpty) {
      ref.read(aiAssistantNotifierProvider.notifier).sendUserMessage(text);
      if (customText == null) _textController.clear();
    }
  }

  void _openVoiceSearch() {
    showDialog(
      context: context,
      builder: (_) =>
          AIVoiceSearchDialog(onSpeechRecognized: (text) => _send(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'AI Property Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: AppDesignSystem.accentEmerald),
            onPressed: _openVoiceSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          const AIListingQualityCard(score: 94.8, isDuplicate: false),
          AIQuickPromptChips(onPromptSelected: (prompt) => _send(prompt)),
          const SizedBox(height: 8),
          Expanded(
            child: switch (aiState) {
              AIAssistantInitial() => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Ask PropertyHub AI about Belagavi prices, 7/12 land titles, or market trends!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppDesignSystem.textSecondary),
                  ),
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
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppDesignSystem.primaryNavy
                              : Colors.white,
                          borderRadius: AppDesignSystem.borderRadiusM,
                          boxShadow: isUser ? null : AppDesignSystem.softShadow,
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
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      prefixIcon: IconButton(
                        icon: const Icon(
                          Icons.mic,
                          color: AppDesignSystem.accentEmerald,
                        ),
                        onPressed: _openVoiceSearch,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppDesignSystem.borderRadiusPill,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
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
                  onPressed: () => _send(),
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
