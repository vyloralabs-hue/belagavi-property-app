import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/direct_ad_entities.dart';

class DirectAdsRemoteDataSource {
  final SupabaseClient _client;

  DirectAdsRemoteDataSource(this._client);

  Future<List<DirectAdCampaignEntity>> getActiveDirectAds({
    required String placement,
    String? locality,
  }) async {
    try {
      final res = await _client.rpc(
        'get_active_direct_ads',
        params: {
          'p_placement': placement,
          if (locality != null && locality.isNotEmpty) 'p_locality': locality,
        },
      );

      if (res == null) return [];
      final List<dynamic> list = res is String ? jsonDecode(res) : (res as List<dynamic>);
      return list
          .map((item) => DirectAdCampaignEntity.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      AppLogger.w('[DirectAds] Failed to fetch active ads: $e');
      return [];
    }
  }

  Future<List<DirectAdCampaignEntity>> getAdminCampaigns({String? filterStatus}) async {
    try {
      final res = await _client.rpc(
        'get_admin_ad_campaigns',
        params: {
          if (filterStatus != null && filterStatus.isNotEmpty) 'p_filter_status': filterStatus,
        },
      );

      if (res == null) return [];
      final List<dynamic> list = res is String ? jsonDecode(res) : (res as List<dynamic>);
      return list
          .map((item) => DirectAdCampaignEntity.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      AppLogger.e('[DirectAds] Failed to fetch admin campaigns: $e');
      rethrow;
    }
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
  }) async {
    try {
      final res = await _client.rpc(
        'submit_direct_ad_campaign',
        params: {
          'p_business_name': businessName,
          'p_contact_person': contactPerson,
          'p_email': email,
          'p_phone': phone,
          'p_website_url': websiteUrl,
          'p_title': title,
          'p_description': description,
          'p_placement': placement,
          'p_target_locality': targetLocality,
          'p_start_date': startDate.toIso8601String(),
          'p_end_date': endDate.toIso8601String(),
          'p_headline': headline,
          'p_body_text': bodyText,
          'p_image_url': imageUrl,
          'p_cta_text': ctaText,
          'p_action_type': actionType,
          'p_action_value': actionValue,
        },
      );

      if (res is String) return jsonDecode(res) as Map<String, dynamic>;
      return Map<String, dynamic>.from(res as Map);
    } catch (e) {
      AppLogger.e('[DirectAds] Failed to submit ad campaign: $e');
      rethrow;
    }
  }

  Future<void> moderateCampaign({
    required String campaignId,
    required String action,
    String? reason,
  }) async {
    try {
      await _client.rpc(
        'admin_moderate_ad_campaign',
        params: {
          'p_campaign_id': campaignId,
          'p_action': action,
          'p_reason': reason,
        },
      );
    } catch (e) {
      AppLogger.e('[DirectAds] Moderation error: $e');
      rethrow;
    }
  }

  Future<void> recordImpression({
    required String campaignId,
    required String placement,
  }) async {
    try {
      await _client.rpc(
        'record_ad_impression',
        params: {
          'p_campaign_id': campaignId,
          'p_placement': placement,
        },
      );
    } catch (_) {}
  }

  Future<void> recordClick({
    required String campaignId,
    required String placement,
  }) async {
    try {
      await _client.rpc(
        'record_ad_click',
        params: {
          'p_campaign_id': campaignId,
          'p_placement': placement,
        },
      );
    } catch (_) {}
  }
}
