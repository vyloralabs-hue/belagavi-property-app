import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

class AIQuickPromptChips extends StatelessWidget {
  final Function(String prompt) onPromptSelected;

  const AIQuickPromptChips({super.key, required this.onPromptSelected});

  static const List<Map<String, String>> _prompts = [
    {'label': '7/12 Title Check', 'prompt': 'What is the 7/12 land title status for NA plots in Tilakwadi?'},
    {'label': 'Market Yields', 'prompt': 'Calculate average rental yield for 3BHK flats in Camp, Belagavi.'},
    {'label': 'Generate Description', 'prompt': 'Generate a compelling listing description for a 2BHK flat.'},
    {'label': 'Score Listing Quality', 'prompt': 'Analyze property listing quality score and check duplicates.'},
    {'label': 'Builder Insights', 'prompt': 'Provide reputation score and delivery track record for Belagavi builders.'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _prompts.length,
        itemBuilder: (context, index) {
          final item = _prompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: Colors.white,
              elevation: 1,
              side: const BorderSide(color: AppDesignSystem.borderSubtle),
              avatar: const Icon(Icons.auto_awesome, size: 14, color: AppDesignSystem.accentEmerald),
              label: Text(item['label']!),
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppDesignSystem.textPrimary),
              onPressed: () => onPromptSelected(item['prompt']!),
            ),
          );
        },
      ),
    );
  }
}
