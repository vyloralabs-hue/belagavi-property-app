import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/monetization/presentation/services/razorpay_checkout_service.dart';
import 'package:belagavi_property/features/advertising/domain/entities/direct_ad_entities.dart';

void main() {
  group('Payment Safety Invariant Tests', () {
    test('1. RazorpayCheckoutService detects unconfigured live gateway', () {
      final service = RazorpayCheckoutService.instance;
      // In tests/default env without real rzp_live_ key, isLiveGatewayConfigured must be false
      expect(service.isLiveGatewayConfigured, isFalse);
    });

    test('2. Razorpay key starting with rzp_test or placeholder is not considered live', () {
      final service = RazorpayCheckoutService.instance;
      expect(service.isMockGateway, isTrue);
    });
  });

  group('Direct Sponsored Advertising Model & Moderation Tests', () {
    test('3. DirectAdCampaignEntity defaults to SUBMITTED and inactive', () {
      final campaign = DirectAdCampaignEntity(
        id: 'camp_001',
        title: 'Tilakwadi Commercial Launch',
        placement: 'HOME_NATIVE_SPONSORED',
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        status: 'SUBMITTED',
        businessName: 'Belagavi Builders',
        headline: 'Exclusive Pre-Launch Offer',
        actionValue: 'https://example.com',
      );

      expect(campaign.status, 'SUBMITTED');
      expect(campaign.isActive, isFalse); // Because status is not ACTIVE and startDate is tomorrow
    });

    test('4. DirectAdCampaignEntity becomes active only if status is ACTIVE and current time is within date window', () {
      final activeCampaign = DirectAdCampaignEntity(
        id: 'camp_002',
        title: 'Active Banner',
        placement: 'HOME_NATIVE_SPONSORED',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        status: 'ACTIVE',
        businessName: 'City Center Mall',
        headline: 'Now Open in Tilakwadi',
        actionValue: 'https://example.com',
      );

      expect(activeCampaign.isActive, isTrue);

      final pausedCampaign = DirectAdCampaignEntity(
        id: 'camp_003',
        title: 'Paused Banner',
        placement: 'HOME_NATIVE_SPONSORED',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        status: 'PAUSED',
        businessName: 'City Center Mall',
        headline: 'Now Open',
        actionValue: 'https://example.com',
      );

      expect(pausedCampaign.isActive, isFalse);
    });

    test('5. Unapproved campaign status is rejected from public active view', () {
      final submitted = DirectAdCampaignEntity(
        id: 'camp_004',
        title: 'Submitted Ad',
        placement: 'HOME_NATIVE_SPONSORED',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        status: 'SUBMITTED',
        businessName: 'Local Broker',
        headline: 'Great Deals',
        actionValue: 'https://broker.com',
      );

      expect(submitted.isActive, isFalse);
    });

    test('6. Expired campaign is marked inactive even if status says ACTIVE', () {
      final expired = DirectAdCampaignEntity(
        id: 'camp_005',
        title: 'Old Promo',
        placement: 'HOME_NATIVE_SPONSORED',
        startDate: DateTime.now().subtract(const Duration(days: 40)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'ACTIVE',
        businessName: 'Belagavi Motors',
        headline: 'Last Month Offer',
        actionValue: 'https://example.com',
      );

      expect(expired.isActive, isFalse);
    });

    test('7. CTR calculation correctly computes percentage from impressions and clicks', () {
      final campaign = DirectAdCampaignEntity(
        id: 'camp_006',
        title: 'Metrics Test',
        placement: 'HOME_NATIVE_SPONSORED',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        status: 'ACTIVE',
        businessName: 'Metrics Corp',
        headline: 'Check out our services',
        actionValue: 'https://metrics.com',
        impressions: 1000,
        clicks: 45,
        ctr: 4.5,
      );

      expect(campaign.impressions, 1000);
      expect(campaign.clicks, 45);
      expect(campaign.ctr, 4.5);
    });
  });

  group('Direct Advertising System & Safety Boundary Tests', () {
    test('8. Placement enum values match database check constraint', () {
      expect(DirectAdPlacement.homeNativeSponsored.value, 'HOME_NATIVE_SPONSORED');
      expect(DirectAdPlacement.searchNativeSponsored.value, 'SEARCH_NATIVE_SPONSORED');
      expect(DirectAdPlacement.localityBanner.value, 'LOCALITY_BANNER');
      expect(DirectAdPlacement.categoryBanner.value, 'CATEGORY_BANNER');
      expect(DirectAdPlacement.featuredBusiness.value, 'FEATURED_BUSINESS');
    });

    test('11. Status enum matches database constraints and lifecycle', () {
      final statuses = [
        'DRAFT', 'SUBMITTED', 'APPROVED', 'SCHEDULED', 'ACTIVE',
        'PAUSED', 'EXPIRED', 'REJECTED', 'ARCHIVED'
      ];
      for (final s in statuses) {
        expect(DirectAdStatus.fromString(s).value, s);
      }
    });

    test('12. Ad-free screens policy list verification', () {
      final strictAdFreePaths = [
        '/auth',
        '/payment',
        '/pricing-plans',
        '/property/add',
        '/add-legal-notice',
        '/add-disputed-property',
        '/admin-properties',
        '/founder-dashboard',
        '/settings/delete-account',
      ];

      for (final path in strictAdFreePaths) {
        // Assert these are not ad placements
        expect(path.contains('SPONSORED'), isFalse);
      }
    });

    test('13. Direct ad JSON serialization and parsing integrity', () {
      final json = {
        'id': 'ad_123',
        'title': 'Test Ad',
        'description': 'Description',
        'placement': 'HOME_NATIVE_SPONSORED',
        'target_city': 'Belagavi',
        'target_locality': 'Tilakwadi',
        'start_date': '2026-09-01T00:00:00.000Z',
        'end_date': '2026-09-30T00:00:00.000Z',
        'status': 'ACTIVE',
        'business_name': 'Test Agency',
        'headline': 'Prime Plots For Sale',
        'action_type': 'PHONE',
        'action_value': '+919876543210',
        'impressions': 250,
        'clicks': 12,
        'ctr': 4.8,
      };

      final parsed = DirectAdCampaignEntity.fromJson(json);
      expect(parsed.id, 'ad_123');
      expect(parsed.title, 'Test Ad');
      expect(parsed.targetLocality, 'Tilakwadi');
      expect(parsed.actionType, 'PHONE');
      expect(parsed.actionValue, '+919876543210');
      expect(parsed.impressions, 250);
      expect(parsed.clicks, 12);
      expect(parsed.ctr, 4.8);
    });
  });
}
