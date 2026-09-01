import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import '../../data/repositories/founder_control_repository_impl.dart';
import '../../domain/repositories/founder_control_repository.dart';
import 'founder_control_notifier.dart';
import 'local_ads_notifier.dart';
export 'founder_control_notifier.dart';
export 'local_ads_notifier.dart';

final founderControlRepositoryProvider = Provider<FounderControlRepository>((ref) {
  final propertyRepo = ref.watch(propertyRepositoryProvider);
  return FounderControlRepositoryImpl(propertyRepo);
});

final founderControlNotifierProvider =
    StateNotifierProvider<FounderControlNotifier, FounderControlState>((ref) {
  final repository = ref.watch(founderControlRepositoryProvider);
  return FounderControlNotifier(repository);
});

final localAdsNotifierProvider =
    StateNotifierProvider<LocalAdsNotifier, LocalAdsState>((ref) {
  final repository = ref.watch(founderControlRepositoryProvider);
  return LocalAdsNotifier(repository);
});
