import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/app.dart';
import 'bootstrap/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    await initializeApp('prod');
  } catch (e, stack) {
    debugPrint('Initialization error in main_prod: $e\n$stack');
  }

  runApp(
    const ProviderScope(
      child: BelagaviApp(),
    ),
  );
}
