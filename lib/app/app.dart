import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/localization_provider.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/presentation_ui/theme/app_theme_manager.dart';

class BelagaviApp extends ConsumerWidget {
  const BelagaviApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeManagerProvider);
    final currentLanguage = ref.watch(localizationNotifierProvider);

    return MaterialApp.router(
      title: AppConstants.projectName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: Locale(currentLanguage.code),
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
        Locale('kn'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
