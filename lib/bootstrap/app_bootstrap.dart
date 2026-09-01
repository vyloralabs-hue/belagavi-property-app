import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../core/constants/app_constants.dart';
import '../core/constants/env.dart';
import '../core/constants/env_config.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/local_storage.dart';
import '../firebase_options.dart';
import 'bootstrap.dart';

enum BootstrapStatus { uninitialized, initializing, success, error }

class AppBootstrap {
  AppBootstrap._();
  static final AppBootstrap instance = AppBootstrap._();

  BootstrapStatus _status = BootstrapStatus.uninitialized;
  String? _errorMessage;
  Completer<void>? _initCompleter;

  BootstrapStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> initialize(String environment) async {
    // 1. If already initialized successfully, return immediately.
    if (_status == BootstrapStatus.success) {
      return;
    }

    // 2. If initialization is currently in progress, await the active Completer.
    if (_status == BootstrapStatus.initializing && _initCompleter != null) {
      return _initCompleter!.future;
    }

    _status = BootstrapStatus.initializing;
    _errorMessage = null;
    _initCompleter = Completer<void>();

    try {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Local storage initialization with 4s timeout safety
      try {
        await LocalStorage.init().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            AppLogger.w('LocalStorage initialization timed out after 4s; continuing bootstrap.');
          },
        );
      } catch (e) {
        AppLogger.e('LocalStorage initialization error', e);
      }

      // 2. Envied environment config
      late AppEnvironment appEnv;
      String supabaseUrl = '';
      String supabaseAnonKey = '';

      try {
        if (environment == 'prod') {
          appEnv = AppEnvironment.production;
          supabaseUrl = EnvProd.supabaseUrl;
          supabaseAnonKey = EnvProd.supabaseAnonKey;
        } else if (environment == 'stg') {
          appEnv = AppEnvironment.staging;
          supabaseUrl = EnvStg.supabaseUrl;
          supabaseAnonKey = EnvStg.supabaseAnonKey;
        } else {
          appEnv = AppEnvironment.dev;
          supabaseUrl = EnvDev.supabaseUrl;
          supabaseAnonKey = EnvDev.supabaseAnonKey;
        }
      } catch (e) {
        AppLogger.w('Envied environment load warning: using fallback environment ($e)');
        appEnv = AppEnvironment.dev;
      }

      // Register EnvConfig in GetIt
      if (!getIt.isRegistered<EnvConfig>()) {
        getIt.registerSingleton<EnvConfig>(
          EnvConfig(
            environment: appEnv,
            apiBaseUrl: supabaseUrl,
            appTitle: AppConstants.projectName,
          ),
        );
      }

      // 3. Supabase Initialization with Production Configuration Guard & 5s timeout safety
      final isPlaceholderSupabase = supabaseUrl.contains('prod.supabase.co') ||
          supabaseUrl.contains('example') ||
          supabaseAnonKey.contains('prod_anon_key') ||
          supabaseAnonKey.contains('placeholder');

      if (isPlaceholderSupabase) {
        AppLogger.w(
          'Supabase Production Guard: Placeholder credentials detected ("$supabaseUrl"). '
          'Skipping live Supabase connection until valid production credentials are provided.',
        );
      } else if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        try {
          await Supabase.initialize(
            url: supabaseUrl,
            anonKey: supabaseAnonKey,
            accessToken: () async {
              try {
                return await FirebaseAuth.instance.currentUser?.getIdToken();
              } catch (_) {
                return null;
              }
            },
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              AppLogger.w('Supabase initialization timed out after 5s; continuing bootstrap.');
              return Supabase.instance;
            },
          );
          AppLogger.i('Supabase initialized successfully.');
        } catch (e) {
          AppLogger.w('Supabase initialization deferred: $e');
        }
      }

      // 4. Firebase Initialization with 5s timeout safety
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.w('Firebase initialization timed out after 5s; continuing bootstrap.');
            return Firebase.app();
          },
        );
        if (!kIsWeb) {
          FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
          PlatformDispatcher.instance.onError = (error, stack) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            return true;
          };
        }
        AppLogger.i('Firebase initialized successfully.');
      } catch (e) {
        AppLogger.w('Firebase initialization deferred: $e');
      }

      // 5. Dependency Injection setup
      try {
        await configureDependencies();
        AppLogger.i('Application dependencies configured with GetIt.');
      } catch (e) {
        AppLogger.w('GetIt dependencies configuration warning: $e');
      }

      _status = BootstrapStatus.success;
      if (!(_initCompleter?.isCompleted ?? true)) {
        _initCompleter?.complete();
      }
    } catch (e, stack) {
      AppLogger.e('Fatal error during AppBootstrap.initialize', e, stack);
      _status = BootstrapStatus.error;
      _errorMessage = e.toString();
      if (!(_initCompleter?.isCompleted ?? true)) {
        _initCompleter?.completeError(e, stack);
      }
      rethrow;
    }
  }
}
