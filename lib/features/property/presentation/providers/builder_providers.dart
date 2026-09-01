import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../data/repositories/builder_repository_impl.dart';
import '../../domain/repositories/builder_repository.dart';
import 'builder_project_form_notifier.dart';
import 'builder_project_list_notifier.dart';
import 'tower_inventory_notifier.dart';

final builderRepositoryProvider = Provider<BuilderRepository>((ref) {
  if (getIt.isRegistered<BuilderRepository>()) {
    return getIt<BuilderRepository>();
  }
  return BuilderRepositoryImpl();
});

final builderProjectFormNotifierProvider =
    StateNotifierProvider<BuilderProjectFormNotifier, BuilderProjectFormState>((ref) {
  final repo = ref.watch(builderRepositoryProvider);
  return BuilderProjectFormNotifier(repo);
});

final builderProjectListNotifierProvider =
    StateNotifierProvider<BuilderProjectListNotifier, BuilderProjectListState>((ref) {
  final repo = ref.watch(builderRepositoryProvider);
  return BuilderProjectListNotifier(repo);
});

final towerInventoryNotifierProvider =
    StateNotifierProvider<TowerInventoryNotifier, TowerInventoryState>((ref) {
  final repo = ref.watch(builderRepositoryProvider);
  return TowerInventoryNotifier(repo);
});
