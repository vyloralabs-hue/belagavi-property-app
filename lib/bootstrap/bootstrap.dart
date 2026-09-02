import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../core/utils/app_logger.dart';
import 'app_bootstrap.dart';
import 'bootstrap.config.dart';

final getIt = GetIt.instance;
bool _isDependenciesConfigured = false;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  if (_isDependenciesConfigured) {
    AppLogger.i('GetIt dependencies already configured.');
    return;
  }
  getIt.init();
  _isDependenciesConfigured = true;
}

Future<void> initializeApp(String environment) async {
  try {
    await configureDependencies();
  } catch (e) {
    AppLogger.w('Dependencies init warning: $e');
  }
  await AppBootstrap.instance.initialize(environment);
}
