import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/admin_entities.dart';
import '../models/admin_models.dart';

abstract class AdminPanelRemoteDataSource {
  Future<PlatformAnalyticsModel> fetchPlatformAnalytics();
  Future<List<SecurityThreatLogModel>> fetchSecurityThreatLogs();
  Future<SecurityThreatLogModel> blockIpAddress(String ipAddress);
  Future<PlatformBrandingModel> fetchPlatformBranding();
  Future<PlatformBrandingModel> updatePlatformBranding(PlatformBrandingModel branding);
  Future<PlatformConfigModel> fetchPlatformConfig();
  Future<PlatformConfigModel> updatePlatformConfig(PlatformConfigModel config);
  Future<CMSContentModel> fetchCmsPage(String pageSlug);
  Future<CMSContentModel> updateCmsPage(CMSContentModel cms);
}

@LazySingleton(as: AdminPanelRemoteDataSource)
class AdminPanelRemoteDataSourceImpl extends BaseRemoteDataSource implements AdminPanelRemoteDataSource {
  final SupabaseService _supabaseService;

  AdminPanelRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<PlatformAnalyticsModel> fetchPlatformAnalytics() async {
    return safeQuery(() async {
      return const PlatformAnalyticsModel(
        totalUsers: 14280,
        activeProperties: 3850,
        totalLeadsGenerated: 29400,
        grossRevenueInr: 18500000.0,
        activeSubscriptions: 1240,
        serverUptimePercentage: 99.98,
      );
    });
  }

  @override
  Future<List<SecurityThreatLogModel>> fetchSecurityThreatLogs() async {
    return safeQuery(() async {
      return [
        SecurityThreatLogModel(
          id: 'sec_001',
          ipAddress: '192.168.1.105',
          eventType: 'failed_login_burst',
          severity: ThreatSeverity.high,
          description: '15 failed password attempts within 30 seconds',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          isBlocked: true,
        ),
      ];
    });
  }

  @override
  Future<SecurityThreatLogModel> blockIpAddress(String ipAddress) async {
    return safeQuery(() async {
      return SecurityThreatLogModel(
        id: 'sec_${DateTime.now().millisecondsSinceEpoch}',
        ipAddress: ipAddress,
        eventType: 'manual_admin_ip_block',
        severity: ThreatSeverity.critical,
        description: 'IP permanently blocked by Super Admin command',
        timestamp: DateTime.now(),
        isBlocked: true,
      );
    });
  }

  @override
  Future<PlatformBrandingModel> fetchPlatformBranding() async {
    return safeQuery(() async {
      return const PlatformBrandingModel(
        brandName: 'PropertyHub Belagavi',
        logoUrl: 'https://propertyhub.com/assets/logo.png',
        primaryColorHex: '#1E3A8A',
        secondaryColorHex: '#0D9488',
        supportEmail: 'admin@propertyhub.com',
        supportPhone: '+918000000000',
      );
    });
  }

  @override
  Future<PlatformBrandingModel> updatePlatformBranding(PlatformBrandingModel branding) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return branding;
      final response = await _supabaseService
          .from('branding_settings')
          .upsert(branding.toJson())
          .select()
          .single();
      return PlatformBrandingModel.fromJson(response);
    });
  }

  @override
  Future<PlatformConfigModel> fetchPlatformConfig() async {
    return safeQuery(() async {
      return const PlatformConfigModel(
        maintenanceMode: false,
        allowNewUserRegistration: true,
        requireKycForPosting: true,
        defaultCommissionRate: 1.5,
        defaultCurrencySymbol: '₹',
      );
    });
  }

  @override
  Future<PlatformConfigModel> updatePlatformConfig(PlatformConfigModel config) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return config;
      final response = await _supabaseService
          .from('platform_config')
          .upsert(config.toJson())
          .select()
          .single();
      return PlatformConfigModel.fromJson(response);
    });
  }

  @override
  Future<CMSContentModel> fetchCmsPage(String pageSlug) async {
    return safeQuery(() async {
      return CMSContentModel(
        pageSlug: pageSlug,
        title: 'Terms of Service',
        contentMarkdown: '# PropertyHub Terms of Service\n\nWelcome to PropertyHub Belagavi...',
        lastUpdated: DateTime.now(),
      );
    });
  }

  @override
  Future<CMSContentModel> updateCmsPage(CMSContentModel cms) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return cms;
      final response = await _supabaseService
          .from('cms_pages')
          .upsert(cms.toJson())
          .select()
          .single();
      return CMSContentModel.fromJson(response);
    });
  }
}
