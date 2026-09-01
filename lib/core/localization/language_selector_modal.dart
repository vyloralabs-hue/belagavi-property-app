import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/presentation_ui/theme/app_design_system.dart';
import 'app_localizations.dart';
import 'localization_provider.dart';

class LanguageSelectorModal extends ConsumerWidget {
  const LanguageSelectorModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LanguageSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(localizationNotifierProvider);
    final localizations = ref.watch(appLocalizationsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.language_rounded,
                    color: AppDesignSystem.primaryNavy,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    localizations.translate('select_language'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...AppLanguage.values.map((lang) {
            final isSelected = currentLanguage == lang;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppDesignSystem.primaryNavy.withValues(alpha: 0.08)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppDesignSystem.primaryNavy
                      : AppDesignSystem.borderSubtle,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                title: Text(
                  lang.nativeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppDesignSystem.primaryNavy
                        : AppDesignSystem.textPrimary,
                  ),
                ),
                subtitle: Text(
                  lang.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppDesignSystem.primaryNavy,
                      )
                    : null,
                onTap: () {
                  ref
                      .read(localizationNotifierProvider.notifier)
                      .setLanguage(lang);
                  Navigator.pop(context);
                },
              ),
            );
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
