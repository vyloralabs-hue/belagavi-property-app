import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/repositories/property_repository.dart';
import 'my_properties_notifier.dart';
import 'property_form_notifier.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return getIt<PropertyRepository>();
});

final propertyFormNotifierProvider =
    StateNotifierProvider<PropertyFormNotifier, PropertyFormState>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  return PropertyFormNotifier(repo);
});

final myPropertiesNotifierProvider =
    StateNotifierProvider<MyPropertiesNotifier, MyPropertiesState>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  return MyPropertiesNotifier(repo);
});

final propertiesListProvider = myPropertiesNotifierProvider;
