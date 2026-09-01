import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/telemetry/marketplace_observability_service.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/entities/seller_workspace_entities.dart';
import 'package:belagavi_property/features/property/domain/services/listing_quality_engine.dart';
import 'package:belagavi_property/features/property/domain/services/duplicate_fraud_detection_engine.dart';
import 'package:belagavi_property/features/property/domain/services/property_analytics_service.dart';
import 'package:belagavi_property/features/property_search/domain/entities/saved_search_entity.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/services/search_service_abstraction.dart';
import 'package:belagavi_property/features/property_search/domain/services/saved_search_alert_service.dart';

void main() {
  group('CRORE-SCALE MARKETPLACE ARCHITECTURE TEST MATRIX', () {
    // ── 1. LISTING QUALITY ENGINE ──────────────────────────────────────────
    test(
      '1. ListingQualityEngine computes deterministic score and qualitative rating',
      () {
        final highQualityProperty = PropertyEntity(
          id: 'prop_high_1',
          ownerId: 'usr_owner_1',
          title: 'Luxurious 3 BHK Modern Villa with Garden',
          description:
              'Exquisite 3 BHK independent villa located in prime Tilakwadi with modular kitchen, private lawn, covered parking, and 24/7 security.',
          category: PropertyCategory.residential,
          type: PropertySubtype.villa,
          price: 9500000,
          specifications: const PropertySpecificationsEntity(
            superBuiltUpArea: 2400,
            carpetArea: 2000,
            bedrooms: 3,
            bathrooms: 3,
            facingDirection: 'East',
            furnishingStatus: 'Semi-Furnished',
          ),
          mediaList: [
            const PropertyMediaEntity(
              id: 'm1',
              propertyId: 'prop_high_1',
              mediaUrl: 'https://cdn.example.com/1.jpg',
              type: MediaType.image,
            ),
            const PropertyMediaEntity(
              id: 'm2',
              propertyId: 'prop_high_1',
              mediaUrl: 'https://cdn.example.com/2.jpg',
              type: MediaType.image,
            ),
            const PropertyMediaEntity(
              id: 'm3',
              propertyId: 'prop_high_1',
              mediaUrl: 'https://cdn.example.com/3.jpg',
              type: MediaType.image,
            ),
            const PropertyMediaEntity(
              id: 'm4',
              propertyId: 'prop_high_1',
              mediaUrl: 'https://cdn.example.com/4.jpg',
              type: MediaType.image,
            ),
            const PropertyMediaEntity(
              id: 'm5',
              propertyId: 'prop_high_1',
              mediaUrl: 'https://cdn.example.com/5.jpg',
              type: MediaType.image,
            ),
          ],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: '12th Cross, Congress Road',
          pincode: '590006',
          latitude: 15.8497,
          longitude: 74.5089,
          verificationStatus: VerificationStatus.verified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final quality = ListingQualityEngine.evaluate(highQualityProperty);

        expect(quality.score, greaterThanOrEqualTo(85));
        expect(quality.rating, 'Excellent');
        expect(quality.breakdown['content'], 20);
        expect(quality.breakdown['media'], 25);
        expect(quality.breakdown['location'], 20);
        expect(quality.breakdown['specifications'], 20);
        expect(quality.breakdown['trust'], 15);
        expect(quality.suggestions.isEmpty, isTrue);
      },
    );

    test(
      '2. ListingQualityEngine generates actionable guidance for incomplete listing',
      () {
        final sparseProperty = PropertyEntity(
          id: 'prop_sparse_1',
          ownerId: 'usr_owner_2',
          title: 'Flat sale',
          description: 'Call me for details',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          price: 4500000,
          specifications: const PropertySpecificationsEntity(),
          mediaList: const [],
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Camp',
          address: 'Camp Road',
          pincode: '590001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final quality = ListingQualityEngine.evaluate(sparseProperty);

        expect(quality.score, lessThan(50));
        expect(quality.rating, 'Poor');
        expect(quality.suggestions.isNotEmpty, isTrue);
        expect(
          quality.suggestions.any((s) => s.contains('description')),
          isTrue,
        );
        expect(quality.suggestions.any((s) => s.contains('photos')), isTrue);
        expect(
          quality.suggestions.any((s) => s.contains('dimensions')),
          isTrue,
        );
      },
    );

    // ── 2. SEARCH SERVICE ABSTRACTION ──────────────────────────────────────
    test(
      '3. SearchCursor and SearchFacets encapsulate scale pagination metadata',
      () {
        const cursor = SearchCursor(
          nextCursor: 'cursor_eyJpZCI6MTAwfQ==',
          prevCursor: null,
          hasMore: true,
          totalCount: 4850,
        );

        const facets = SearchFacets(
          categoryCounts: {
            'residential': 3200,
            'plotLand': 1100,
            'commercial': 550,
          },
          localityCounts: {'Tilakwadi': 1200, 'Mandoli Road': 850},
          bhkCounts: {'2': 1800, '3': 1400},
        );

        const searchResult = MarketplaceSearchResult(
          items: [],
          cursor: cursor,
          facets: facets,
          executionDurationMs: 42,
          searchEngineBackend: 'postgresql_supabase',
        );

        expect(searchResult.cursor.hasMore, isTrue);
        expect(searchResult.cursor.totalCount, 4850);
        expect(searchResult.facets.categoryCounts['residential'], 3200);
        expect(searchResult.executionDurationMs, 42);
        expect(searchResult.searchEngineBackend, 'postgresql_supabase');
      },
    );

    // ── 3. DUPLICATE & FRAUD DETECTION ENGINE ──────────────────────────────
    test(
      '4. DuplicateFraudDetectionEngine detects duplicate property cross-owner fingerprint collision',
      () {
        final original = PropertyEntity(
          id: 'prop_orig',
          ownerId: 'usr_legit_owner',
          title: 'Original 2 BHK in Shahapur',
          description: 'Spacious 2 BHK apartment',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          price: 5000000,
          specifications: const PropertySpecificationsEntity(
            carpetArea: 1000,
            bedrooms: 2,
          ),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Shahapur',
          address: 'Bank Colony',
          pincode: '590003',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final copycat = PropertyEntity(
          id: 'prop_copycat',
          ownerId: 'usr_fraudster_99',
          title: 'Bargain 2 BHK in Shahapur',
          description: 'Urgent distress sale',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          price: 5000000,
          specifications: const PropertySpecificationsEntity(
            carpetArea: 1000,
            bedrooms: 2,
          ),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Shahapur',
          address: 'Bank Colony',
          pincode: '590003',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final report = DuplicateFraudDetectionEngine.evaluate(
          property: copycat,
          existingListings: [original],
          localityMedianPrice: 5200000,
        );

        expect(
          report.signals.any(
            (s) => s.ruleCode == 'DUPLICATE_CROSS_OWNER_FINGERPRINT',
          ),
          isTrue,
        );
        expect(report.riskScore, greaterThanOrEqualTo(50));
        expect(report.requiresManualModeration, isTrue);
      },
    );

    test(
      '5. DuplicateFraudDetectionEngine flags extreme price anomalies and rapid posting bursts',
      () {
        final suspicious = PropertyEntity(
          id: 'prop_sus',
          ownerId: 'usr_bot_1',
          title: 'Fake Plot Listing',
          description: 'Deposit needed immediately',
          category: PropertyCategory.plotLand,
          type: PropertySubtype.plot,
          price: 100000, // 1 Lakh (locality median is 50 Lakhs)
          specifications: const PropertySpecificationsEntity(plotArea: 2400),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Congress Road',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final report = DuplicateFraudDetectionEngine.evaluate(
          property: suspicious,
          localityMedianPrice: 5000000,
          sellerPostsInLastHour: 15,
        );

        expect(
          report.signals.any(
            (s) => s.ruleCode == 'HIGH_FREQUENCY_POSTING_BURST',
          ),
          isTrue,
        );
        expect(
          report.signals.any(
            (s) => s.ruleCode == 'EXTREME_UNDERPRICING_ANOMALY',
          ),
          isTrue,
        );
        expect(report.level, FraudRiskLevel.critical);
        expect(report.requiresManualModeration, isTrue);
      },
    );

    // ── 4. LISTING ANALYTICS FOUNDATION ────────────────────────────────────
    test(
      '6. PropertyAnalyticsService buffers events and calculates funnel aggregations',
      () async {
        final service = PropertyAnalyticsService(bufferCapacity: 10);

        final now = DateTime.now();
        final sampleEvents = [
          PropertyAnalyticsEvent(
            id: 'e1',
            propertyId: 'p1',
            sessionId: 's1',
            eventType: PropertyAnalyticsEventType.view,
            timestamp: now,
          ),
          PropertyAnalyticsEvent(
            id: 'e2',
            propertyId: 'p1',
            sessionId: 's2',
            eventType: PropertyAnalyticsEventType.view,
            timestamp: now,
          ),
          PropertyAnalyticsEvent(
            id: 'e3',
            propertyId: 'p1',
            sessionId: 's1',
            eventType: PropertyAnalyticsEventType.favoriteAdd,
            timestamp: now,
          ),
          PropertyAnalyticsEvent(
            id: 'e4',
            propertyId: 'p1',
            sessionId: 's2',
            eventType: PropertyAnalyticsEventType.enquirySubmit,
            timestamp: now,
          ),
          PropertyAnalyticsEvent(
            id: 'e5',
            propertyId: 'p1',
            sessionId: 's2',
            eventType: PropertyAnalyticsEventType.siteVisitRequest,
            timestamp: now,
          ),
        ];

        for (final event in sampleEvents) {
          await service.trackEvent(event);
        }

        final allEvents = service.bufferedEvents;
        expect(allEvents.length, 5);

        final summary = PropertyAnalyticsService.aggregate('p1', allEvents);
        expect(summary.totalViews, 2);
        expect(summary.uniqueVisitors, 2);
        expect(summary.totalFavorites, 1);
        expect(summary.totalEnquiries, 1);
        expect(summary.siteVisitRequests, 1);
        expect(summary.conversionRate, 50.0); // 1 enquiry / 2 views = 50%
      },
    );

    // ── 5. SAVED SEARCHES & ALERTS ─────────────────────────────────────────
    test(
      '7. SavedSearchAlertService matches new properties against saved search filters',
      () {
        final matchingProperty = PropertyEntity(
          id: 'prop_match_1',
          ownerId: 'usr_owner_1',
          title: '3 BHK in Tilakwadi',
          description: 'Prime location villa',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          price: 6800000,
          status: ListingStatus.published,
          specifications: const PropertySpecificationsEntity(bedrooms: 3),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'Tilakwadi Main',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedSearch = SavedSearchEntity(
          id: 'search_1',
          userId: 'usr_buyer_1',
          title: '3BHK under 70L in Tilakwadi',
          query: const SearchQueryEntity(
            city: 'Belagavi',
            locality: 'Tilakwadi',
            category: PropertyCategory.residential,
            minBedrooms: 3,
            maxPrice: 7000000,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final matches = SavedSearchAlertService.evaluateMatches(
          property: matchingProperty,
          savedSearches: [savedSearch],
        );

        expect(matches.length, 1);
        expect(matches.first.savedSearchId, 'search_1');
        expect(matches.first.userId, 'usr_buyer_1');
        expect(matches.first.propertyPrice, 6800000);
      },
    );

    test(
      '8. SavedSearchAlertService ignores muted searches and non-matching criteria',
      () {
        final nonMatchingProperty = PropertyEntity(
          id: 'prop_nomatch_1',
          ownerId: 'usr_owner_1',
          title: 'Commercial Shop in Camp',
          description: 'Great for retail',
          category: PropertyCategory.commercial,
          type: PropertySubtype.commercialShop,
          price: 9000000,
          status: ListingStatus.published,
          specifications: const PropertySpecificationsEntity(),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Camp',
          address: 'Camp Bazar',
          pincode: '590001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedSearch = SavedSearchEntity(
          id: 'search_res',
          userId: 'usr_buyer_1',
          title: 'Residential in Tilakwadi',
          query: const SearchQueryEntity(
            city: 'Belagavi',
            locality: 'Tilakwadi',
            category: PropertyCategory.residential,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final matches = SavedSearchAlertService.evaluateMatches(
          property: nonMatchingProperty,
          savedSearches: [savedSearch],
        );

        expect(matches.isEmpty, isTrue);
      },
    );

    // ── 6. SELLER WORKSPACE ENTITIES ───────────────────────────────────────
    test(
      '9. SellerWorkspaceSummary handles enterprise broker inventory aggregation',
      () {
        const workspace = SellerWorkspaceSummary(
          sellerId: 'broker_agency_77',
          tier: ProfessionalSellerTier.brokerAgency,
          totalListings: 1250,
          publishedListings: 1100,
          underReviewListings: 50,
          pausedListings: 80,
          closedListings: 20,
          totalInboundLeads: 4320,
          pendingSiteVisits: 145,
          activeOffers: 28,
          overallQualityScore: 88.5,
          averageConversionRate: 4.8,
        );

        expect(workspace.totalListings, 1250);
        expect(workspace.publishedListings, 1100);
        expect(workspace.tier, ProfessionalSellerTier.brokerAgency);
        expect(workspace.totalInboundLeads, 4320);
      },
    );

    // ── 7. MARKETPLACE OBSERVABILITY & SLO MONITOR ─────────────────────────
    test(
      '10. MarketplaceObservabilityService calculates percentiles and validates SLO compliance',
      () {
        final obs = MarketplaceObservabilityService();

        // Simulate 100 search latency samples (all fast, p95 ~ 180ms)
        for (int i = 1; i <= 100; i++) {
          obs.recordLatency('search', (i * 2)); // 2ms to 200ms
          obs.recordLatency(
            'property_detail',
            (i * 1.5).toInt(),
          ); // 1ms to 150ms
          obs.recordLatency('property_write', (i * 4)); // 4ms to 400ms
        }

        final searchPercentiles = obs.calculatePercentiles('search');
        expect(searchPercentiles.p50, closeTo(100.0, 5.0));
        expect(searchPercentiles.p95, closeTo(190.0, 5.0));
        expect(searchPercentiles.p99, closeTo(198.0, 5.0));

        final slo = obs.evaluateSloStatus();
        expect(slo.isSearchSloMet, isTrue);
        expect(slo.isDetailSloMet, isTrue);
        expect(slo.isWriteSloMet, isTrue);
        expect(slo.isOverallHealthy, isTrue);
        expect(slo.errorRatePercentage, 0.0);
      },
    );
  });
}
