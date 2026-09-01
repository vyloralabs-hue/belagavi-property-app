// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../core/backend/analytics_service.dart' as _i417;
import '../core/backend/crashlytics_service.dart' as _i271;
import '../core/backend/supabase_service.dart' as _i965;
import '../core/constants/app_config.dart' as _i435;
import '../core/constants/env_config.dart' as _i183;
import '../core/network/api_client.dart' as _i510;
import '../core/network/connectivity_service.dart' as _i332;
import '../core/network/network_info.dart' as _i6;
import '../core/payments/razorpay_service.dart' as _i105;
import '../core/security/secure_storage_service.dart' as _i1016;
import '../core/telemetry/telemetry_service.dart' as _i637;
import '../core/utils/local_storage.dart' as _i471;
import '../features/admin_panel/data/datasources/admin_panel_remote_datasource.dart'
    as _i298;
import '../features/admin_panel/data/repositories/admin_panel_repository_impl.dart'
    as _i366;
import '../features/admin_panel/domain/repositories/admin_panel_repository.dart'
    as _i515;
import '../features/ai_engine/data/datasources/ai_engine_remote_datasource.dart'
    as _i455;
import '../features/ai_engine/data/repositories/ai_engine_repository_impl.dart'
    as _i191;
import '../features/ai_engine/domain/repositories/ai_engine_repository.dart'
    as _i638;
import '../features/ai_engine/utils/ai_cost_optimization_cache.dart' as _i747;
import '../features/auth/data/datasources/auth_remote_datasource.dart' as _i130;
import '../features/auth/data/datasources/team_remote_datasource.dart' as _i854;
import '../features/auth/data/repositories/auth_repository_impl.dart' as _i570;
import '../features/auth/data/repositories/team_repository_impl.dart' as _i404;
import '../features/auth/domain/repositories/auth_repository.dart' as _i869;
import '../features/auth/domain/repositories/team_repository.dart' as _i36;
import '../features/crm/data/datasources/crm_remote_datasource.dart' as _i500;
import '../features/crm/data/repositories/crm_repository_impl.dart' as _i601;
import '../features/crm/domain/repositories/crm_repository.dart' as _i784;
import '../features/feedback/data/repositories/closed_beta_feedback_repository.dart'
    as _i878;
import '../features/geography/data/datasources/geography_local_cache_datasource.dart'
    as _i525;
import '../features/geography/data/datasources/geography_remote_datasource.dart'
    as _i582;
import '../features/geography/data/repositories/geography_repository_impl.dart'
    as _i802;
import '../features/geography/domain/repositories/geography_repository.dart'
    as _i367;
import '../features/legal_dispute/data/datasources/dispute_remote_datasource.dart'
    as _i156;
import '../features/legal_dispute/data/datasources/legal_notice_remote_datasource.dart'
    as _i377;
import '../features/legal_dispute/data/repositories/dispute_repository_impl.dart'
    as _i25;
import '../features/legal_dispute/data/repositories/legal_notice_repository_impl.dart'
    as _i993;
import '../features/legal_dispute/domain/repositories/dispute_repository.dart'
    as _i83;
import '../features/legal_dispute/domain/repositories/legal_notice_repository.dart'
    as _i121;
import '../features/monetization/data/datasources/monetization_remote_datasource.dart'
    as _i238;
import '../features/monetization/data/datasources/payment_gateway_remote_datasource.dart'
    as _i558;
import '../features/monetization/data/repositories/monetization_repository_impl.dart'
    as _i669;
import '../features/monetization/data/repositories/payment_gateway_repository_impl.dart'
    as _i627;
import '../features/monetization/domain/repositories/monetization_repository.dart'
    as _i998;
import '../features/monetization/domain/repositories/payment_gateway_repository.dart'
    as _i52;
import '../features/production_engine/data/datasources/production_engine_remote_datasource.dart'
    as _i850;
import '../features/production_engine/data/repositories/production_engine_repository_impl.dart'
    as _i201;
import '../features/production_engine/domain/repositories/production_engine_repository.dart'
    as _i273;
import '../features/property/data/datasources/favorite_local_datasource.dart'
    as _i1037;
import '../features/property/data/datasources/property_remote_datasource.dart'
    as _i905;
import '../features/property/data/repositories/property_repository_impl.dart'
    as _i896;
import '../features/property/domain/repositories/property_repository.dart'
    as _i449;
import '../features/property/services/property_media_upload_service.dart'
    as _i167;
import '../features/property_search/data/datasources/property_search_remote_datasource.dart'
    as _i487;
import '../features/property_search/data/datasources/saved_search_local_datasource.dart'
    as _i951;
import '../features/property_search/data/repositories/property_search_repository_impl.dart'
    as _i654;
import '../features/property_search/domain/repositories/property_search_repository.dart'
    as _i413;
import '../features/support/data/datasources/support_remote_datasource.dart'
    as _i366;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i417.AnalyticsService>(() => _i417.AnalyticsService());
    gh.lazySingleton<_i271.CrashlyticsService>(
      () => _i271.CrashlyticsService(),
    );
    gh.lazySingleton<_i965.SupabaseService>(() => _i965.SupabaseService());
    gh.lazySingleton<_i510.ApiClient>(() => _i510.ApiClient());
    gh.lazySingleton<_i105.RazorpayService>(() => _i105.RazorpayService());
    gh.lazySingleton<_i1016.SecureStorageService>(
      () => _i1016.SecureStorageService(),
    );
    gh.lazySingleton<_i471.LocalStorage>(() => _i471.LocalStorage());
    gh.lazySingleton<_i878.ClosedBetaFeedbackRepository>(
      () => _i878.ClosedBetaFeedbackRepository(),
    );
    gh.lazySingleton<_i637.TelemetryService>(
      () => _i637.TelemetryService(gh<_i417.AnalyticsService>()),
    );
    gh.lazySingleton<_i850.ProductionEngineRemoteDataSource>(
      () => _i850.ProductionEngineRemoteDataSourceImpl(
        gh<_i965.SupabaseService>(),
      ),
    );
    gh.lazySingleton<_i558.PaymentGatewayRemoteDataSource>(
      () =>
          _i558.PaymentGatewayRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i167.PropertyMediaUploadService>(
      () => _i167.PropertyMediaUploadService(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i854.TeamRemoteDataSource>(
      () => _i854.TeamRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i905.PropertyRemoteDataSource>(
      () => _i905.PropertyRemoteDataSourceImpl(
        gh<_i965.SupabaseService>(),
        gh<_i471.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i951.SavedSearchLocalDataSource>(
      () => _i951.SavedSearchLocalDataSourceImpl(gh<_i471.LocalStorage>()),
    );
    gh.lazySingleton<_i377.LegalNoticeRemoteDataSource>(
      () => _i377.LegalNoticeRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i1037.FavoriteLocalDataSource>(
      () => _i1037.FavoriteLocalDataSourceImpl(gh<_i471.LocalStorage>()),
    );
    gh.lazySingleton<_i449.PropertyRepository>(
      () => _i896.PropertyRepositoryImpl(gh<_i905.PropertyRemoteDataSource>()),
    );
    gh.lazySingleton<_i6.NetworkInfo>(() => _i6.NetworkInfoImpl());
    gh.lazySingleton<_i130.AuthRemoteDataSource>(
      () => _i130.AuthRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i487.PropertySearchRemoteDataSource>(
      () =>
          _i487.PropertySearchRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i500.CRMRemoteDataSource>(
      () => _i500.CRMRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i582.GeographyRemoteDataSource>(
      () => _i582.GeographyRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i52.PaymentGatewayRepository>(
      () => _i627.PaymentGatewayRepositoryImpl(
        gh<_i558.PaymentGatewayRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i298.AdminPanelRemoteDataSource>(
      () => _i298.AdminPanelRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i156.DisputeRemoteDataSource>(
      () => _i156.DisputeRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i332.ConnectivityService>(
      () => _i332.ConnectivityServiceImpl(),
    );
    gh.lazySingleton<_i747.AICostOptimizationCache>(
      () => _i747.AICostOptimizationCacheImpl(gh<_i471.LocalStorage>()),
    );
    gh.lazySingleton<_i525.GeographyLocalCacheDataSource>(
      () => _i525.GeographyLocalCacheDataSourceImpl(gh<_i471.LocalStorage>()),
    );
    gh.lazySingleton<_i238.MonetizationRemoteDataSource>(
      () => _i238.MonetizationRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i455.AIEngineRemoteDataSource>(
      () => _i455.AIEngineRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i367.GeographyRepository>(
      () => _i802.GeographyRepositoryImpl(
        gh<_i582.GeographyRemoteDataSource>(),
        gh<_i525.GeographyLocalCacheDataSource>(),
      ),
    );
    gh.lazySingleton<_i183.EnvConfig>(
      () => _i183.EnvConfig(
        environment: gh<_i183.AppEnvironment>(),
        apiBaseUrl: gh<String>(),
        appTitle: gh<String>(),
      ),
    );
    gh.lazySingleton<_i638.AIEngineRepository>(
      () => _i191.AIEngineRepositoryImpl(
        gh<_i455.AIEngineRemoteDataSource>(),
        gh<_i747.AICostOptimizationCache>(),
      ),
    );
    gh.lazySingleton<_i869.AuthRepository>(
      () => _i570.AuthRepositoryImpl(gh<_i130.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i515.AdminPanelRepository>(
      () => _i366.AdminPanelRepositoryImpl(
        gh<_i298.AdminPanelRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i273.ProductionEngineRepository>(
      () => _i201.ProductionEngineRepositoryImpl(
        gh<_i850.ProductionEngineRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i36.TeamRepository>(
      () => _i404.TeamRepositoryImpl(gh<_i854.TeamRemoteDataSource>()),
    );
    gh.lazySingleton<_i83.DisputeRepository>(
      () => _i25.DisputeRepositoryImpl(gh<_i156.DisputeRemoteDataSource>()),
    );
    gh.lazySingleton<_i121.LegalNoticeRepository>(
      () => _i993.LegalNoticeRepositoryImpl(
        gh<_i377.LegalNoticeRemoteDataSource>(),
      ),
    );
    gh.factory<_i366.SupportRemoteDataSource>(
      () => _i366.SupportRemoteDataSourceImpl(gh<_i965.SupabaseService>()),
    );
    gh.lazySingleton<_i413.PropertySearchRepository>(
      () => _i654.PropertySearchRepositoryImpl(
        gh<_i487.PropertySearchRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i435.AppConfig>(
      () => _i435.AppConfig(gh<_i183.EnvConfig>()),
    );
    gh.lazySingleton<_i784.CRMRepository>(
      () => _i601.CRMRepositoryImpl(gh<_i500.CRMRemoteDataSource>()),
    );
    gh.lazySingleton<_i998.MonetizationRepository>(
      () => _i669.MonetizationRepositoryImpl(
        gh<_i238.MonetizationRemoteDataSource>(),
      ),
    );
    return this;
  }
}
