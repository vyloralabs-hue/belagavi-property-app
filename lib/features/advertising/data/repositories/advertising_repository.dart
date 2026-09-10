import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/direct_ad_entities.dart';
import '../datasources/admob_service.dart';
import '../datasources/direct_ads_remote_datasource.dart';

class AdvertisingRepository {
  final DirectAdsRemoteDataSource _remoteDataSource;

  AdvertisingRepository([DirectAdsRemoteDataSource? remoteDataSource])
      : _remoteDataSource =
            remoteDataSource ?? DirectAdsRemoteDataSource(Supabase.instance.client);

  Future<List<DirectAdCampaignEntity>> getActiveDirectAds({
    required String placement,
    String? locality,
  }) {
    return _remoteDataSource.getActiveDirectAds(
      placement: placement,
      locality: locality,
    );
  }

  Future<List<DirectAdCampaignEntity>> getAdminCampaigns({String? filterStatus}) {
    return _remoteDataSource.getAdminCampaigns(filterStatus: filterStatus);
  }

  Future<Map<String, dynamic>> submitDirectAdCampaign({
    required String businessName,
    required String contactPerson,
    required String email,
    required String phone,
    String? websiteUrl,
    required String title,
    String? description,
    required String placement,
    String? targetLocality,
    required DateTime startDate,
    required DateTime endDate,
    required String headline,
    String? bodyText,
    String? imageUrl,
    required String ctaText,
    required String actionType,
    required String actionValue,
  }) {
    return _remoteDataSource.submitDirectAdCampaign(
      businessName: businessName,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      websiteUrl: websiteUrl,
      title: title,
      description: description,
      placement: placement,
      targetLocality: targetLocality,
      startDate: startDate,
      endDate: endDate,
      headline: headline,
      bodyText: bodyText,
      imageUrl: imageUrl,
      ctaText: ctaText,
      actionType: actionType,
      actionValue: actionValue,
    );
  }

  Future<void> moderateCampaign({
    required String campaignId,
    required String action,
    String? reason,
  }) {
    return _remoteDataSource.moderateCampaign(
      campaignId: campaignId,
      action: action,
      reason: reason,
    );
  }

  Future<void> recordImpression(String campaignId, String placement) {
    return _remoteDataSource.recordImpression(
      campaignId: campaignId,
      placement: placement,
    );
  }

  Future<void> recordClick(String campaignId, String placement) {
    return _remoteDataSource.recordClick(
      campaignId: campaignId,
      placement: placement,
    );
  }

  bool get isAdMobAvailable => AdMobService.instance.isAdMobConfigured;
}
