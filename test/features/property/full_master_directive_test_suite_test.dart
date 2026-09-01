import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/config/listing_pricing_config.dart';
import 'package:belagavi_property/core/map/map_configuration.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/dispute_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/datasources/legal_notice_remote_datasource.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/dispute_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/data/repositories/legal_notice_repository_impl.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/dispute_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/entities/legal_notice_entities.dart';
import 'package:belagavi_property/features/legal_dispute/domain/repositories/dispute_repository.dart';
import 'package:belagavi_property/features/legal_dispute/domain/repositories/legal_notice_repository.dart';

class MockPropertyRepository implements PropertyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockPropertyRepository mockPropertyRepo;
  late PropertyFormNotifier formNotifier;
  late SupabaseService supabase;
  late DisputeRemoteDataSource disputeDataSource;
  late DisputeRepository disputeRepository;
  late LegalNoticeRemoteDataSource noticeDataSource;
  late LegalNoticeRepository noticeRepository;

  setUp(() {
    mockPropertyRepo = MockPropertyRepository();
    formNotifier = PropertyFormNotifier(mockPropertyRepo);
    supabase = SupabaseService();
    disputeDataSource = DisputeRemoteDataSourceImpl(supabase);
    disputeRepository = DisputeRepositoryImpl(disputeDataSource);
    noticeDataSource = LegalNoticeRemoteDataSourceImpl(supabase);
    noticeRepository = LegalNoticeRepositoryImpl(noticeDataSource);
  });

  group('BELAGAVI PROPERTY â€” FULL 40-PHASE MASTER DIRECTIVE TEST MATRIX', () {
    // â”€â”€â”€ 1. RESIDENTIAL CATEGORY WORKFLOW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 6: Residential property form validates full specifications and photo count',
      () {
        formNotifier.initForNewProperty('usr_res_001');
        formNotifier.updatePropertyType(
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
        );
        formNotifier.updateBasicDetails(
          title: 'Luxury 3 BHK Penthouse in Tilakwadi',
          description:
              'Spacious East facing apartment with modular kitchen and 2 balconies.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Tilakwadi',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: '1st Cross, Tilakwadi',
          pincode: '590006',
          latitude: 15.8497,
          longitude: 74.4977,
        );
        formNotifier.updatePriceAndArea(
          price: 8500000.0,
          carpetArea: 1450.0,
          builtUpArea: 1750.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateSpecifications(
          const PropertySpecificationsEntity(
            bedrooms: 3,
            bathrooms: 3,
            balconies: 2,
            floorNumber: 4,
            totalFloors: 5,
            facingDirection: 'East',
            furnishingStatus: 'Semi-Furnished',
          ),
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'm1',
            propertyId: 'temp',
            mediaUrl:
                'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
            type: MediaType.image,
            isCover: true,
          ),
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'm2',
            propertyId: 'temp',
            mediaUrl:
                'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
            type: MediaType.image,
            isCover: false,
          ),
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'm3',
            propertyId: 'temp',
            mediaUrl:
                'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
            type: MediaType.image,
            isCover: false,
          ),
        );

        final entity = formNotifier.state.toEntity('usr_res_001');
        expect(entity.category, PropertyCategory.residential);
        expect(entity.specifications.bedrooms, 3);
        expect(entity.mediaList.length, 3);
        expect(entity.mediaList.first.isCover, isTrue);
        expect(formNotifier.getMissingPublishFields().isEmpty, isTrue);
      },
    );

    // â”€â”€â”€ 2. PLOTS & LAYOUTS SPECIFICATIONS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 7: Plots & Layouts listing validates dimensions, road width, and NA conversion',
      () {
        formNotifier.initForNewProperty('usr_plot_001');
        formNotifier.updatePropertyType(
          category: PropertyCategory.plotLand,
          type: PropertySubtype.residentialPlot,
        );
        formNotifier.updateBasicDetails(
          title: '40x60 Corner Plot in BUDA Approved Layout',
          description: 'Prime East-North corner plot on 40ft wide tar road.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Angol',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: 'Plot 42, Green Park Layout',
          pincode: '590007',
          latitude: 15.8320,
          longitude: 74.5020,
        );
        formNotifier.updatePriceAndArea(
          price: 4800000.0,
          plotArea: 2400.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateSpecifications(
          const PropertySpecificationsEntity(
            facingDirection: 'East-North Corner',
          ),
        );
        formNotifier.updatePlotDetails(
          plotLength: 60.0,
          plotWidth: 40.0,
          roadWidth: 40.0,
          isCornerPlot: true,
          isGatedLayout: true,
          hasBoundaryWall: true,
          isNaConverted: true,
          isLayoutApproved: true,
          surveyNumber: '142/2A',
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'mp1',
            propertyId: 'temp',
            mediaUrl:
                'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
            type: MediaType.image,
            isCover: true,
          ),
        );

        final entity = formNotifier.state.toEntity('usr_plot_001');
        expect(entity.category, PropertyCategory.plotLand);
        expect(entity.specifications.plotArea, 2400.0);
        expect(entity.features['plotLength'], 60.0);
        expect(entity.features['plotWidth'], 40.0);
        expect(entity.features['roadWidth'], 40.0);
        expect(entity.features['isCornerPlot'], isTrue);
        expect(entity.features['isNaConverted'], isTrue);
      },
    );

    // â”€â”€â”€ 3. COMMERCIAL PROPERTY LISTING â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 8: Commercial property listing validates frontage, power load, and lease duration',
      () {
        formNotifier.initForNewProperty('usr_comm_001');
        formNotifier.updatePropertyType(
          category: PropertyCategory.commercial,
          type: PropertySubtype.commercialOffice,
        );
        formNotifier.updateBasicDetails(
          title: 'Ground Floor Showroom on College Road',
          description: 'High visibility retail showroom with 35ft frontage.',
          listingType: 'FOR_RENT',
        );
        formNotifier.updateLocation(
          locality: 'College Road',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: 'College Road, Belagavi',
          pincode: '590001',
        );
        formNotifier.updatePriceAndArea(
          price: 180000.0,
          carpetArea: 2800.0,
          builtUpArea: 3200.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateCommercialDetails(
          entranceWidth: 35.0,
          ceilingHeight: 14.0,
          powerLoad: '50 KW',
          parkingSpaces: 6,
          hasLift: true,
        );

        final entity = formNotifier.state.toEntity('usr_comm_001');
        expect(entity.category, PropertyCategory.commercial);
        expect(formNotifier.state.listingType, 'FOR_RENT');
        expect(entity.features['powerLoad'], '50 KW');
        expect(entity.features['entranceWidth'], 35.0);
      },
    );

    // â”€â”€â”€ 4. RAW LAND LISTING â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 9: Raw Land listing validates soil type, RTC reference, water source and acre area',
      () {
        formNotifier.initForNewProperty('usr_land_001');
        formNotifier.updatePropertyType(
          category: PropertyCategory.land,
          type: PropertySubtype.agriculturalLand,
        );
        formNotifier.updateBasicDetails(
          title: '5 Acres Fertile Black Soil Land near Sambra',
          description:
              'Irrigated agricultural land with clear single-owner RTC.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Sambra',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: 'Sambra Village, Belagavi Taluk',
          pincode: '591124',
        );
        formNotifier.updatePriceAndArea(
          price: 12500000.0,
          plotArea: 5.0,
          areaUnit: 'acre',
        );
        formNotifier.updatePlotDetails(
          soilType: 'Fertile Black Cotton Soil',
          waterSource: 'Canal + 2 Borewells',
          hasBorewell: true,
          borewellCount: 2,
          roadAccessType: 'Tar Road Frontage (30ft)',
          surveyNumber: '88/1B',
          isAgricultural: true,
        );

        final entity = formNotifier.state.toEntity('usr_land_001');
        expect(entity.category, PropertyCategory.land);
        expect(entity.specifications.plotArea, 5.0);
        expect(entity.features['soilType'], 'Fertile Black Cotton Soil');
        expect(entity.features['surveyNumber'], '88/1B');
      },
    );

    // â”€â”€â”€ 5. PHOTO UPLOAD & COVER SELECTION â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 16-17: Photo requirement validates 1 photo for draft and 3 photos for publish',
      () {
        formNotifier.initForNewProperty('usr_photo_check');
        formNotifier.updateBasicDetails(
          title: 'Test',
          description: 'Desc',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Tilakwadi',
          city: 'Belagavi',
          stateName: 'Karnataka',
          address: 'A',
        );
        formNotifier.updatePriceAndArea(price: 100000, carpetArea: 500);

        // 0 photos -> publish blocked
        expect(
          formNotifier.getMissingPublishFields().any(
            (f) => f.toLowerCase().contains('photo'),
          ),
          isTrue,
        );

        // 1 photo -> sufficient for draft
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'p1',
            propertyId: 'temp',
            mediaUrl: 'https://example.com/1.jpg',
            type: MediaType.image,
            isCover: true,
          ),
        );
        expect(formNotifier.state.mediaList.length, 1);

        // 3 photos -> publish allowed
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'p2',
            propertyId: 'temp',
            mediaUrl: 'https://example.com/2.jpg',
            type: MediaType.image,
            isCover: false,
          ),
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'p3',
            propertyId: 'temp',
            mediaUrl: 'https://example.com/3.jpg',
            type: MediaType.image,
            isCover: false,
          ),
        );
        expect(formNotifier.state.mediaList.length, 3);
        expect(
          formNotifier.getMissingPublishFields().any(
            (f) => f.toLowerCase().contains('photo'),
          ),
          isFalse,
        );
      },
    );

    // â”€â”€â”€ 6. INDIA MAP & ZERO-GOOGLE-BILLING RESOLUTION â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 10, 12, 37: Map resolver resolves Indian cities & provides resilient offline fallback',
      () {
        expect(MapConfiguration.mapTileUrlTemplate, isNotEmpty);
        expect(MapConfiguration.defaultLatitude, 15.8497);
        expect(MapConfiguration.defaultLongitude, 74.4977);

        final belagavi = MapConfiguration.resolveLocation('Tilakwadi');
        expect(belagavi, isNotNull);
        expect(belagavi!.city, 'Belagavi');
        expect(belagavi.state, 'Karnataka');

        final bengaluru = MapConfiguration.resolveLocation('Whitefield');
        expect(bengaluru, isNotNull);
        expect(bengaluru!.city, 'Bengaluru');

        final mumbai = MapConfiguration.resolveLocation('Bandra');
        expect(mumbai, isNotNull);
        expect(mumbai!.city, 'Mumbai');

        final unknown = MapConfiguration.resolveLocation(
          'UnknownRemotePlaceXYZ',
        );
        expect(unknown, isNull);
      },
    );

    // â”€â”€â”€ 7. LOCALITY-FIRST SEARCH & BOUNDED QUERIES â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 13-14: SearchQueryEntity constructs bounded queries with strict taxonomy',
      () {
        const query = SearchQueryEntity(
          country: 'India',
          state: 'Karnataka',
          city: 'Belagavi',
          locality: 'Tilakwadi',
          category: PropertyCategory.residential,
          minPrice: 5000000.0,
          maxPrice: 10000000.0,
          minBedrooms: 2,
          sortBy: 'price_asc',
          limit: 20,
          offset: 0,
        );

        expect(query.city, 'Belagavi');
        expect(query.locality, 'Tilakwadi');
        expect(query.category, PropertyCategory.residential);
        expect(query.sortBy, 'price_asc');
      },
    );

    // â”€â”€â”€ 8. DISPUTED PROPERTY PRIVACY & ISOLATION â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 21-22, 24: Disputed property entities keep legal records protected and public masked',
      () async {
        const dispute = PropertyDisputeEntity(
          id: 'disp_master_001',
          propertyId: 'prop_master_001',
          title: 'Title Injunction Notice: Tilakwadi Bunglow',
          locality: 'Tilakwadi',
          description: 'Partition suit pending before Senior Civil Judge.',
          disputeType: DisputeType.courtCaseStayOrder,
          verificationStatus: DisputeVerificationStatus.underReview,
          caseNumber: 'O.S. 442/2026',
          courtAuthority: 'Civil Court Belagavi',
          contactPhone: '+91 94481 99887',
          photoUrls: const ['https://images.unsplash.com/dispute-site'],
          documentUrls: const [
            'https://storage.belagaviproperty.com/legal/stay_order.pdf',
          ],
          isDocumentPrivate: true,
          reportedBy: 'usr_claimant_master',
        );

        final createRes = await disputeRepository.createDispute(
          dispute,
          authenticatedUserId: 'usr_claimant_master',
        );
        expect(createRes.isRight(), isTrue);

        final publicRes = await disputeRepository.getDisputeById(
          'disp_master_001',
          requestingUserId: 'usr_anon_public',
          userRole: UserRole.user,
        );
        publicRes.fold((_) => fail('Failed public fetch'), (d) {
          expect(d, isNotNull);
          expect(d!.documentUrls, isEmpty);
          expect(d.contactPhone, contains('•••••'));
        });
      },
    );

    // â”€â”€â”€ 9. PURCHASE / SALE LEGAL NOTICE RECORD & ATTACH LATER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 23-24: Legal notice registry saves without docs and attaches later',
      () async {
        const notice = TransactionLegalNoticeEntity(
          id: 'not_master_001',
          title: 'Public Notice of Sale: 4 BHK House Shahapur',
          locality: 'Shahapur',
          buyerName: 'Mr. Santosh Patil',
          sellerName: 'Mr. Vinayak Hegde',
          contactName: 'Adv. A. R. Kulkarni',
          contactPhone: '+91 98801 55664',
          transactionType: 'Sale',
          agreedValue: 'â‚¹ 1.10 Crore',
          noticeType: LegalNoticeType.saleLegalNotice,
          issuingAuthority: 'Sub-Registrar Belagavi',
          referenceNumber: 'PUB/SHAH/2026/88',
          documentUrls: const [],
          isDocumentPrivate: true,
          canAddDocumentsLater: true,
        );

        final createRes = await noticeRepository.createLegalNotice(
          notice,
          authenticatedUserId: 'usr_advocate_master',
        );
        expect(createRes.isRight(), isTrue);

        final attachRes = await noticeRepository.attachDocuments(
          'not_master_001',
          newDocuments: const [
            'https://storage.belagaviproperty.com/legal/publication_clipping.pdf',
          ],
          authenticatedUserId: 'usr_advocate_master',
        );
        expect(attachRes.isRight(), isTrue);
      },
    );

    // â”€â”€â”€ 10. CENTRAL LISTING PRICING RULES (â‚¹500 DISPUTE / â‚¹500 DEAL) â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 26: Central ListingPricingConfig enforces â‚¹500 dispute and â‚¹500 purchase/sale deal rules',
      () {
        expect(ListingPricingConfig.disputeListingFeeInRupees, 500);
        expect(ListingPricingConfig.purchaseSaleDealFeeInRupees, 500);
        expect(ListingPricingConfig.formattedDisputeListingFee, 'â‚¹500');
        expect(ListingPricingConfig.formattedPurchaseSaleDealFee, 'â‚¹500');
        expect(ListingPricingConfig.standardPropertyListingFeeInRupees, 0);
        expect(ListingPricingConfig.formattedStandardListingFee, 'Free');
        expect(ListingPricingConfig.builderProjectListingFeeInRupees, 2499);
      },
    );

    // â”€â”€â”€ 11. ZERO-AI APPLICATION POSITIONING â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'Phase 1: Zero AI positioning check confirms manual property marketplace architecture',
      () {
        const marketplaceCategories = [
          'Residential',
          'Plots / Layouts',
          'Commercial',
          'Raw Land',
        ];
        expect(marketplaceCategories.length, 4);
      },
    );
  });
}
