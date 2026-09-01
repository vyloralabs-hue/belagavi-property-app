import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/app.dart';
import 'bootstrap/app_bootstrap.dart';
import 'bootstrap/bootstrap.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    await configureDependencies();
  } catch (e) {
    AppLogger.w('Dependencies init warning: $e');
  }

  // Initiate background initialization immediately
  const env = appFlavor ?? 'prod';
  AppBootstrap.instance.initialize(env);

  runApp(const ProviderScope(child: BelagaviApp()));
}
