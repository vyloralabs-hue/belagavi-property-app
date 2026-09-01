import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_panel_repository.dart';

sealed class PlatformConfigState extends Equatable {
  const PlatformConfigState();

  @override
  List<Object?> get props => [];
}

class PlatformConfigInitial extends PlatformConfigState {
  const PlatformConfigInitial();
}

class PlatformConfigLoading extends PlatformConfigState {
  const PlatformConfigLoading();
}

class PlatformConfigLoaded extends PlatformConfigState {
  final PlatformConfigEntity config;
  final PlatformBrandingEntity branding;

  const PlatformConfigLoaded({
    required this.config,
    required this.branding,
  });

  @override
  List<Object?> get props => [config, branding];
}

class PlatformConfigError extends PlatformConfigState {
  final String message;

  const PlatformConfigError(this.message);

  @override
  List<Object?> get props => [message];
}

final platformConfigNotifierProvider =
    NotifierProvider<PlatformConfigNotifier, PlatformConfigState>(
  PlatformConfigNotifier.new,
);

class PlatformConfigNotifier extends Notifier<PlatformConfigState> {
  late final AdminPanelRepository _repository;

  @override
  PlatformConfigState build() {
    _repository = getIt<AdminPanelRepository>();
    return const PlatformConfigInitial();
  }

  Future<void> fetchConfigurations() async {
    state = const PlatformConfigLoading();
    final configRes = await _repository.getPlatformConfig();
    final brandingRes = await _repository.getPlatformBranding();

    configRes.fold(
      (failure) => state = PlatformConfigError(failure.message),
      (config) {
        PlatformBrandingEntity branding = const PlatformBrandingEntity(
          brandName: 'PropertyHub',
          logoUrl: '',
          primaryColorHex: '#1E3A8A',
          secondaryColorHex: '#0D9488',
          supportEmail: 'support@propertyhub.com',
          supportPhone: '+918000000000',
        );
        brandingRes.fold((_) => null, (b) => branding = b);
        state = PlatformConfigLoaded(config: config, branding: branding);
      },
    );
  }

  Future<void> updateConfig(PlatformConfigEntity newConfig) async {
    final res = await _repository.updatePlatformConfig(newConfig);
    res.fold(
      (failure) => state = PlatformConfigError(failure.message),
      (_) => fetchConfigurations(),
    );
  }
}
