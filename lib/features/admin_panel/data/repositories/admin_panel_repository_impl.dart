import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_panel_repository.dart';
import '../datasources/admin_panel_remote_datasource.dart';
import '../models/admin_models.dart';

@LazySingleton(as: AdminPanelRepository)
class AdminPanelRepositoryImpl extends BaseRepository implements AdminPanelRepository {
  final AdminPanelRemoteDataSource _remoteDataSource;

  AdminPanelRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<PlatformAnalyticsEntity> getPlatformAnalytics() async {
    return safeCall(() => _remoteDataSource.fetchPlatformAnalytics());
  }

  @override
  FutureEither<List<SecurityThreatLogEntity>> getSecurityThreatLogs() async {
    return safeCall(() => _remoteDataSource.fetchSecurityThreatLogs());
  }

  @override
  FutureEither<SecurityThreatLogEntity> blockIpAddress(String ipAddress) async {
    return safeCall(() => _remoteDataSource.blockIpAddress(ipAddress));
  }

  @override
  FutureEither<PlatformBrandingEntity> getPlatformBranding() async {
    return safeCall(() => _remoteDataSource.fetchPlatformBranding());
  }

  @override
  FutureEither<PlatformBrandingEntity> updatePlatformBranding(PlatformBrandingEntity branding) async {
    return safeCall(() async {
      final model = PlatformBrandingModel(
        brandName: branding.brandName,
        logoUrl: branding.logoUrl,
        primaryColorHex: branding.primaryColorHex,
        secondaryColorHex: branding.secondaryColorHex,
        supportEmail: branding.supportEmail,
        supportPhone: branding.supportPhone,
      );
      return await _remoteDataSource.updatePlatformBranding(model);
    });
  }

  @override
  FutureEither<PlatformConfigEntity> getPlatformConfig() async {
    return safeCall(() => _remoteDataSource.fetchPlatformConfig());
  }

  @override
  FutureEither<PlatformConfigEntity> updatePlatformConfig(PlatformConfigEntity config) async {
    return safeCall(() async {
      final model = PlatformConfigModel(
        maintenanceMode: config.maintenanceMode,
        allowNewUserRegistration: config.allowNewUserRegistration,
        requireKycForPosting: config.requireKycForPosting,
        defaultCommissionRate: config.defaultCommissionRate,
        defaultCurrencySymbol: config.defaultCurrencySymbol,
      );
      return await _remoteDataSource.updatePlatformConfig(model);
    });
  }

  @override
  FutureEither<CMSContentEntity> getCmsPage(String pageSlug) async {
    return safeCall(() => _remoteDataSource.fetchCmsPage(pageSlug));
  }

  @override
  FutureEither<CMSContentEntity> updateCmsPage(CMSContentEntity cms) async {
    return safeCall(() async {
      final model = CMSContentModel(
        pageSlug: cms.pageSlug,
        title: cms.title,
        contentMarkdown: cms.contentMarkdown,
        lastUpdated: cms.lastUpdated,
      );
      return await _remoteDataSource.updateCmsPage(model);
    });
  }
}
