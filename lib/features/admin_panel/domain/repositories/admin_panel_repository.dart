import '../../../../core/utils/typedefs.dart';
import '../entities/admin_entities.dart';

abstract class AdminPanelRepository {
  FutureEither<PlatformAnalyticsEntity> getPlatformAnalytics();

  FutureEither<List<SecurityThreatLogEntity>> getSecurityThreatLogs();

  FutureEither<SecurityThreatLogEntity> blockIpAddress(String ipAddress);

  FutureEither<PlatformBrandingEntity> getPlatformBranding();

  FutureEither<PlatformBrandingEntity> updatePlatformBranding(PlatformBrandingEntity branding);

  FutureEither<PlatformConfigEntity> getPlatformConfig();

  FutureEither<PlatformConfigEntity> updatePlatformConfig(PlatformConfigEntity config);

  FutureEither<CMSContentEntity> getCmsPage(String pageSlug);

  FutureEither<CMSContentEntity> updateCmsPage(CMSContentEntity cms);
}
