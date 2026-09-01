import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/config/country_config.dart';
import 'package:belagavi_property/core/config/feature_flags.dart';
import 'package:belagavi_property/features/property/domain/entities/favorite_collection_entity.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/entities/shared_shortlist_entity.dart';
import 'package:belagavi_property/features/property/domain/services/market_insights_service.dart';
import 'package:belagavi_property/features/property/domain/services/moderation_report_service.dart';
import 'package:belagavi_property/features/property/domain/services/property_checklist_service.dart';
import 'package:belagavi_property/features/property/domain/services/property_comparison_service.dart';
import 'package:belagavi_property/features/property/domain/services/recently_viewed_service.dart';
import 'package:belagavi_property/features/property/domain/services/similar_properties_engine.dart';
import 'package:belagavi_property/features/property_search/utils/natural_language_search_parser.dart';
import 'package:belagavi_property/features/transaction/domain/entities/lead_crm_entities.dart';
import 'package:belagavi_property/features/transaction/domain/services/lead_crm_service.dart';
import 'package:belagavi_property/features/transaction/domain/services/site_visit_offer_service.dart';

void main() {
  group('MAXIMUM PRACTICAL IMPLEMENTATION TEST MATRIX', () {
    // ── 1. PROPERTY COMPARISON ─────────────────────────────────────────────
    test('1. PropertyComparisonService compares properties and highlights differences', () {
      final propA = PropertyEntity(
        id: 'pA',
        ownerId: 'o1',
        title: '2 BHK Apartment',
        description: 'Desc A',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        price: 5000000,
        specifications: const PropertySpecificationsEntity(bedrooms: 2, superBuiltUpArea: 1000),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Addr A',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final propB = PropertyEntity(
        id: 'pB',
        ownerId: 'o2',
        title: '3 BHK Villa',
        description: 'Desc B',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        price: 8500000,
        specifications: const PropertySpecificationsEntity(bedrooms: 3, superBuiltUpArea: 2000),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Mandoli Road',
        address: 'Addr B',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final matrix = PropertyComparisonService.compare([propA, propB]);
      expect(matrix.properties.length, 2);
      expect(matrix.rows.any((r) => r.label == 'Price' && r.isHighlightDifference), isTrue);
      expect(matrix.rows.any((r) => r.label == 'Bedrooms (BHK)'), isTrue);
    });

    // ── 2. FAVORITES COLLECTIONS ───────────────────────────────────────────
    test('2. FavoriteCollectionEntity manages custom user shortlist folders', () {
      final collection = FavoriteCollectionEntity(
        id: 'col_1',
        userId: 'usr_buyer_1',
        collectionName: 'For Family',
        propertyIds: const ['p1', 'p2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = collection.copyWith(propertyIds: ['p1', 'p2', 'p3']);
      expect(updated.propertyIds.length, 3);
      expect(updated.collectionName, 'For Family');
    });

    // ── 3. RECENTLY VIEWED ─────────────────────────────────────────────────
    test('3. RecentlyViewedService maintains bounded FIFO history without duplicates', () {
      final service = RecentlyViewedService();

      service.recordView('p1');
      service.recordView('p2');
      service.recordView('p3');
      service.recordView('p1'); // View p1 again -> should move to top

      expect(service.history.length, 3);
      expect(service.history.first.propertyId, 'p1');

      service.clearHistory();
      expect(service.history.isEmpty, isTrue);
    });

    // ── 4. SELLER LEAD CRM ─────────────────────────────────────────────────
    test('4. LeadCRMService manages stage transitions, private notes, and blocking', () {
      final initialLead = LeadCRMRecord(
        id: 'lead_1',
        propertyId: 'p1',
        sellerId: 's1',
        buyerId: 'b1',
        buyerName: 'John Doe',
        buyerPhone: '+919876543210',
        stage: LeadStage.newLead,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Transition stage
      final contacted = LeadCRMService.updateStage(initialLead, LeadStage.contacted);
      expect(contacted.stage, LeadStage.contacted);

      // Add private note
      final withNote = LeadCRMService.addPrivateNote(
        lead: contacted,
        authorId: 's1',
        content: 'Buyer requested price discount on cash payment.',
      );
      expect(withNote.privateNotes.length, 1);
      expect(withNote.privateNotes.first.content, contains('discount'));

      // Block abusive lead
      final blocked = LeadCRMService.blockBuyer(withNote);
      expect(blocked.isBuyerBlocked, isTrue);
      expect(blocked.stage, LeadStage.lost);
    });

    // ── 5. SITE VISIT CALENDAR ─────────────────────────────────────────────
    test('5. SiteVisitOfferService manages site visit workflow', () {
      final visit = SiteVisitScheduleRecord(
        id: 'visit_1',
        propertyId: 'p1',
        buyerId: 'b1',
        sellerId: 's1',
        proposedDateTime: DateTime.now().add(const Duration(days: 2)),
        status: SiteVisitStatus.requested,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final accepted = SiteVisitOfferService.acceptVisit(visit);
      expect(accepted.status, SiteVisitStatus.accepted);

      final rescheduled = SiteVisitOfferService.rescheduleVisit(
        accepted,
        DateTime.now().add(const Duration(days: 3)),
        note: 'Available only in the afternoon',
      );
      expect(rescheduled.status, SiteVisitStatus.rescheduled);
      expect(rescheduled.sellerNote, contains('afternoon'));
    });

    // ── 6. OFFER NEGOTIATION CENTER ────────────────────────────────────────
    test('6. SiteVisitOfferService tracks offer negotiations and includes legal disclaimer', () {
      final initialOffer = MarketplaceOfferRecord(
        id: 'off_1',
        propertyId: 'p1',
        buyerId: 'b1',
        sellerId: 's1',
        currentOfferAmount: 6500000,
        status: MarketplaceOfferStatus.submitted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(MarketplaceOfferRecord.legalDisclaimer, contains('not a legal contract'));

      // Seller counters
      final countered = SiteVisitOfferService.counterOffer(
        offer: initialOffer,
        counterAmount: 6800000,
        note: 'Final best price with covered car parking included.',
      );
      expect(countered.status, MarketplaceOfferStatus.countered);
      expect(countered.currentOfferAmount, 6800000);
      expect(countered.history.length, 1);

      // Buyer accepts
      final accepted = SiteVisitOfferService.acceptOffer(countered);
      expect(accepted.status, MarketplaceOfferStatus.accepted);
    });

    // ── 7. SIMILAR PROPERTIES RECOMMENDATION ────────────────────────────────
    test('7. SimilarPropertiesEngine returns grounded similar properties excluding self', () {
      final target = PropertyEntity(
        id: 'target_prop',
        ownerId: 'o1',
        title: '3 BHK Villa in Tilakwadi',
        description: 'Prime villa',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.published,
        price: 8000000,
        specifications: const PropertySpecificationsEntity(bedrooms: 3),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: '1st Cross',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final candidateSimilar = PropertyEntity(
        id: 'cand_1',
        ownerId: 'o2',
        title: '3 BHK Villa in Tilakwadi 2nd Cross',
        description: 'Another villa',
        category: PropertyCategory.residential,
        type: PropertySubtype.villa,
        status: ListingStatus.published,
        price: 8200000,
        specifications: const PropertySpecificationsEntity(bedrooms: 3),
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: '2nd Cross',
        pincode: '590006',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final candidateCommercial = PropertyEntity(
        id: 'cand_comm',
        ownerId: 'o3',
        title: 'Commercial Shop in Camp',
        description: 'Shop',
        category: PropertyCategory.commercial,
        type: PropertySubtype.commercialShop,
        status: ListingStatus.published,
        price: 5000000,
        specifications: const PropertySpecificationsEntity(),
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

      final similar = SimilarPropertiesEngine.findSimilar(
        target: target,
        candidatePool: [target, candidateSimilar, candidateCommercial],
      );

      expect(similar.length, 1);
      expect(similar.first.id, 'cand_1');
    });

    // ── 8. LOCAL MARKET INSIGHTS ───────────────────────────────────────────
    test('8. MarketInsightsService computes locality median and price change history', () {
      final listings = [
        PropertyEntity(
          id: 'p1',
          ownerId: 'o1',
          title: 'Apt 1',
          description: 'd',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 4000000,
          specifications: const PropertySpecificationsEntity(superBuiltUpArea: 1000),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'a',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        PropertyEntity(
          id: 'p2',
          ownerId: 'o2',
          title: 'Apt 2',
          description: 'd',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 5000000,
          specifications: const PropertySpecificationsEntity(superBuiltUpArea: 1000),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'a',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        PropertyEntity(
          id: 'p3',
          ownerId: 'o3',
          title: 'Apt 3',
          description: 'd',
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
          status: ListingStatus.published,
          price: 6000000,
          specifications: const PropertySpecificationsEntity(superBuiltUpArea: 1000),
          state: 'Karnataka',
          district: 'Belagavi',
          taluk: 'Belagavi',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          address: 'a',
          pincode: '590006',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final insight = MarketInsightsService.computeLocalityInsight(
        locality: 'Tilakwadi',
        city: 'Belagavi',
        listings: listings,
      );

      expect(insight.hasSufficientData, isTrue);
      expect(insight.medianAskingPrice, 5000000.0);
      expect(insight.averagePricePerSqFt, 5000.0);

      final priceChange = MarketInsightsService.recordPriceChange(
        propertyId: 'p1',
        oldPrice: 4500000,
        newPrice: 4000000,
      );
      expect(priceChange.deltaPercentage, closeTo(-11.1, 0.1));
    });

    // ── 9. PROPERTY CHECKLISTS ─────────────────────────────────────────────
    test('9. PropertyChecklistService returns category-specific verification checklists', () {
      final resTemplate = PropertyChecklistService.getTemplateForCategory(PropertyCategory.residential);
      expect(resTemplate.items.any((i) => i.title.contains('Encumbrance Certificate')), isTrue);

      final plotTemplate = PropertyChecklistService.getTemplateForCategory(PropertyCategory.plotLand);
      expect(plotTemplate.items.any((i) => i.title.contains('Non-Agricultural (NA) Order')), isTrue);
    });

    // ── 10. SHARED FAMILY SHORTLISTS ───────────────────────────────────────
    test('10. SharedShortlistEntity supports collaborative family member comments', () {
      final shortlist = SharedShortlistEntity(
        id: 'short_1',
        title: 'Our Family House Hunt',
        creatorUserId: 'u_dad',
        members: [
          ShortlistMember(userId: 'u_dad', displayName: 'Dad', role: SharedShortlistRole.admin, joinedAt: DateTime.now()),
          ShortlistMember(userId: 'u_mom', displayName: 'Mom', role: SharedShortlistRole.contributor, joinedAt: DateTime.now()),
        ],
        propertyIds: const ['p1', 'p2'],
        comments: [
          ShortlistComment(
            id: 'c1',
            propertyId: 'p1',
            authorUserId: 'u_mom',
            authorName: 'Mom',
            commentText: 'Kitchen is very spacious and near school.',
            createdAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(shortlist.members.length, 2);
      expect(shortlist.comments.first.commentText, contains('spacious'));
    });

    // ── 11. LISTING MODERATION REPORTS & USER BLOCKING ─────────────────────
    test('11. ModerationReportService submits reports and handles user blocklists', () {
      final service = ModerationReportService();

      final report = service.submitReport(
        propertyId: 'prop_spam',
        reporterUserId: 'usr_clean',
        reason: ListingReportReason.fraudulentPrice,
        description: 'Advance fee demanded before visit.',
      );

      expect(report.status, ReportStatus.pending);
      expect(service.pendingReports.length, 1);

      // Block user
      service.blockUser(currentUserId: 'usr_clean', targetUserId: 'usr_spammer');
      expect(service.isBlocked(currentUserId: 'usr_clean', targetUserId: 'usr_spammer'), isTrue);
      expect(service.isBlocked(currentUserId: 'usr_clean', targetUserId: 'usr_other'), isFalse);
    });

    // ── 12. FEATURE FLAGS ──────────────────────────────────────────────────
    test('12. FeatureFlags allows modular rollout controls', () {
      const flags = FeatureFlags.defaults;
      expect(flags.isVideoUploadEnabled, isTrue);
      expect(flags.isBulkImportEnabled, isTrue);
      expect(flags.isBuilderProjectsEnabled, isTrue);
      expect(flags.isBiometricUnlockEnabled, isTrue);
    });

    // ── 13. GLOBAL CURRENCY & AREA CONVERTER ───────────────────────────────
    test('13. CurrencyFormatter and AreaUnitConverter handle canonical global formatting', () {
      expect(CurrencyFormatter.format(7500000, currencyCode: 'INR'), '₹75.0 L');
      expect(CurrencyFormatter.format(15000000, currencyCode: 'INR'), '₹1.50 Cr');
      expect(CurrencyFormatter.format(500000, currencyCode: 'USD'), '\$500000');
      expect(CurrencyFormatter.format(2000000, currencyCode: 'AED'), 'AED 2000000');

      // 1 Gunta = 1089 Sq Ft
      final guntaToSqFt = AreaUnitConverter.convert(area: 2.0, fromUnit: 'gunta', toUnit: 'sqft');
      expect(guntaToSqFt, 2178.0);
    });

    // ── 14. NATURAL LANGUAGE SEARCH PARSER ─────────────────────────────────
    test('14. NaturalLanguageSearchParser extracts structured query from Hindi/English hybrid input', () {
      const input = 'Belagavi me 70 lakh ke andar 3BHK east facing chahiye';
      final query = NaturalLanguageSearchParser.parseQuery(input);

      expect(query.city, 'Belagavi');
      expect(query.maxPrice, 7000000.0);
      expect(query.minBedrooms, 3);
      expect(query.facingDirection, 'East');
    });
  });
}
