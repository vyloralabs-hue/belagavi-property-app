import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import 'app_localizations.dart';

class LocalizationNotifier extends Notifier<AppLanguage> {
  static const String _prefKey = 'app_language_code';

  @override
  AppLanguage build() {
    try {
      if (Hive.isBoxOpen(AppConstants.userPrefsBoxName)) {
        final box = Hive.box(AppConstants.userPrefsBoxName);
        final savedCode = box.get(_prefKey) as String?;
        if (savedCode != null && savedCode.isNotEmpty) {
          return AppLanguage.fromCode(savedCode);
        }
      }
    } catch (_) {}

    // First launch fallback: Check system device locale
    try {
      final deviceLocale = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      if (deviceLocale == 'hi') return AppLanguage.hindi;
      if (deviceLocale == 'mr') return AppLanguage.marathi;
      if (deviceLocale == 'kn') return AppLanguage.kannada;
      if (deviceLocale == 'en') return AppLanguage.english;
    } catch (_) {}

    return AppLanguage.english;
  }

  void setLanguage(AppLanguage newLanguage) {
    if (state != newLanguage) {
      state = newLanguage;
      _persist(newLanguage.code);
    }
  }

  void setLanguageByCode(String code) {
    setLanguage(AppLanguage.fromCode(code));
  }

  void _persist(String code) {
    try {
      if (Hive.isBoxOpen(AppConstants.userPrefsBoxName)) {
        Hive.box(AppConstants.userPrefsBoxName).put(_prefKey, code);
      }
    } catch (_) {}
  }
}

final localizationNotifierProvider = NotifierProvider<LocalizationNotifier, AppLanguage>(LocalizationNotifier.new);

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final language = ref.watch(localizationNotifierProvider);
  return AppLocalizations(language);
});
