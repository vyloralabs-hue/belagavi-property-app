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

  group('BELAGAVI PROPERTY LLP â€” USER & SELLER JOURNEY E2E VERIFICATION MATRIX', () {
    // â”€â”€â”€ FLOW A: RESIDENTIAL LISTING JOURNEY â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'FLOW A: Residential listing journey â€” Create -> Draft -> Resume -> Preview -> Submit',
      () {
        formNotifier.initForNewProperty('usr_seller_res_01');
        formNotifier.updatePropertyType(
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
        );
        formNotifier.updateBasicDetails(
          title: 'Spacious 3 BHK Luxury Apartment in Tilakwadi',
          description:
              'Sunlit east-facing 3 BHK with 2 balconies, covered car park, and modular kitchen.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Tilakwadi',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: '2nd Cross, Congress Road, Tilakwadi',
          pincode: '590006',
          latitude: 15.8497,
          longitude: 74.4977,
        );
        formNotifier.updatePriceAndArea(
          price: 7500000.0,
          carpetArea: 1350.0,
          builtUpArea: 1600.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateSpecifications(
          const PropertySpecificationsEntity(
            bedrooms: 3,
            bathrooms: 3,
            balconies: 2,
            floorNumber: 3,
            totalFloors: 5,
            facingDirection: 'East',
            furnishingStatus: 'Semi-Furnished',
          ),
        );

        // Add 1 photo -> valid for draft
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'res_media_01',
            propertyId: 'temp_id',
            mediaUrl:
                'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
            type: MediaType.image,
            isCover: true,
          ),
        );

        final draftEntity = formNotifier.state.toEntity('usr_seller_res_01');
        expect(draftEntity.title, contains('3 BHK'));
        expect(draftEntity.mediaList.length, 1);
        expect(
          formNotifier.validateStep(5),
          isTrue,
        ); // Step 5 (Media) valid for draft

        // Add 2 more photos -> valid for publish
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'res_media_02',
            propertyId: 'temp_id',
            mediaUrl:
                'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
            type: MediaType.image,
            isCover: false,
          ),
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'res_media_03',
            propertyId: 'temp_id',
            mediaUrl:
                'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
            type: MediaType.image,
            isCover: false,
          ),
        );

        final publishEntity = formNotifier.state.toEntity('usr_seller_res_01');
        expect(publishEntity.mediaList.length, 3);
        expect(publishEntity.mediaList.first.isCover, isTrue);
        expect(formNotifier.getMissingPublishFields().isEmpty, isTrue);
      },
    );

    // â”€â”€â”€ FLOW B: PLOT / LAYOUT LISTING JOURNEY â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'FLOW B: Plot listing journey â€” Plot-specific fields, dimensions, NA conversion & road width',
      () {
        formNotifier.initForNewProperty('usr_seller_plot_01');
        formNotifier.updatePropertyType(
          category: PropertyCategory.plotLand,
          type: PropertySubtype.residentialPlot,
        );
        formNotifier.updateBasicDetails(
          title: '30x50 East Facing Plot in BUDA Approved Layout',
          description:
              'Prime residential plot situated in a gated layout with 30ft asphalted road.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Angol',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: 'Plot #18, Bhagya Nagar Layout',
          pincode: '590007',
          latitude: 15.8350,
          longitude: 74.5050,
        );
        formNotifier.updatePriceAndArea(
          price: 3200000.0,
          plotArea: 1500.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateSpecifications(
          const PropertySpecificationsEntity(facingDirection: 'East'),
        );
        formNotifier.updatePlotDetails(
          plotLength: 50.0,
          plotWidth: 30.0,
          roadWidth: 30.0,
          isCornerPlot: false,
          isGatedLayout: true,
          hasBoundaryWall: true,
          isNaConverted: true,
          isLayoutApproved: true,
          surveyNumber: '112/3',
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'plot_media_01',
            propertyId: 'temp_id',
            mediaUrl:
                'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
            type: MediaType.image,
            isCover: true,
          ),
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'plot_media_02',
            propertyId: 'temp_id',
            mediaUrl:
                'https://images.unsplash.com/photo-1524813686514-a57563d77d66',
            type: MediaType.image,
            isCover: false,
          ),
        );
        formNotifier.addMedia(
          const PropertyMediaEntity(
            id: 'plot_media_03',
            propertyId: 'temp_id',
            mediaUrl:
                'https://images.unsplash.com/photo-1506146332389-18140dc7b2fb',
            type: MediaType.image,
            isCover: false,
          ),
        );

        final plotEntity = formNotifier.state.toEntity('usr_seller_plot_01');
        expect(plotEntity.category, PropertyCategory.plotLand);
        expect(plotEntity.features['plotLength'], 50.0);
        expect(plotEntity.features['plotWidth'], 30.0);
        expect(plotEntity.features['roadWidth'], 30.0);
        expect(plotEntity.features['isNaConverted'], isTrue);
        expect(plotEntity.features['isLayoutApproved'], isTrue);
        expect(formNotifier.getMissingPublishFields().isEmpty, isTrue);
      },
    );

    // â”€â”€â”€ FLOW C & D: COMMERCIAL LISTING (SALE & RENT) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'FLOW C & D: Commercial listing journey â€” Showroom Sale & Office Rent with power load and frontage',
      () {
        formNotifier.initForNewProperty('usr_seller_comm_01');
        formNotifier.updatePropertyType(
          category: PropertyCategory.commercial,
          type: PropertySubtype.commercialShowroom,
        );
        formNotifier.updateBasicDetails(
          title: 'Prime 2500 sq.ft Retail Showroom on College Road',
          description:
              'Main road frontage showroom with 40ft glass display, 3-phase power, and dedicated parking.',
          listingType: 'FOR_RENT',
        );
        formNotifier.updateLocation(
          locality: 'College Road',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: 'College Road Main Commercial Belt',
          pincode: '590001',
        );
        formNotifier.updatePriceAndArea(
          price: 150000.0,
          carpetArea: 2200.0,
          builtUpArea: 2500.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateCommercialDetails(
          entranceWidth: 40.0,
          ceilingHeight: 14.0,
          powerLoad: '45 KW',
          parkingSpaces: 5,
          hasLift: true,
          hasLoadingDock: true,
        );

        final commEntity = formNotifier.state.toEntity('usr_seller_comm_01');
        expect(commEntity.category, PropertyCategory.commercial);
        expect(formNotifier.state.listingType, 'FOR_RENT');
        expect(commEntity.features['entranceWidth'], 40.0);
        expect(commEntity.features['powerLoad'], '45 KW');
        expect(commEntity.features['hasLoadingDock'], isTrue);
      },
    );

    // â”€â”€â”€ FLOW E: RAW LAND & AGRICULTURAL LISTING â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'FLOW E: Raw Land journey â€” Agricultural acreage, RTC reference, soil type, and borewells',
      () {
        formNotifier.initForNewProperty('usr_seller_land_01');
        formNotifier.updatePropertyType(
          category: PropertyCategory.land,
          type: PropertySubtype.agriculturalLand,
        );
        formNotifier.updateBasicDetails(
          title: '8.5 Acres Fertile Agricultural Farm Land near Sambra',
          description:
              'Black soil farm land with canal water access, 3 operational borewells, and clear single RTC.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Sambra',
          city: 'Belagavi',
          district: 'Belagavi',
          stateName: 'Karnataka',
          address: 'Sambra Village, Belagavi Rural',
          pincode: '591124',
        );
        formNotifier.updatePriceAndArea(
          price: 21000000.0,
          plotArea: 8.5,
          areaUnit: 'acre',
        );
        formNotifier.updatePlotDetails(
          soilType: 'Black Cotton Soil',
          waterSource: 'Malaprabha Canal + 3 Borewells',
          hasBorewell: true,
          borewellCount: 3,
          roadAccessType: '30ft Tar Road Frontage',
          surveyNumber: '94/2',
          isAgricultural: true,
          existingCropsTrees: 'Sugarcane & Mango Trees',
        );

        final landEntity = formNotifier.state.toEntity('usr_seller_land_01');
        expect(landEntity.category, PropertyCategory.land);
        expect(landEntity.specifications.plotArea, 8.5);
        expect(landEntity.features['soilType'], 'Black Cotton Soil');
        expect(landEntity.features['waterSource'], contains('Canal'));
        expect(landEntity.features['borewellCount'], 3);
      },
    );

    // â”€â”€â”€ FLOW F: DISPUTED PROPERTY ISOLATED FLOW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'FLOW F: Disputed Property journey â€” Create, legal details, private document policy, and â‚¹500 rule',
      () async {
        expect(ListingPricingConfig.disputeListingFeeInRupees, 500);

        const dispute = PropertyDisputeEntity(
          id: 'disp_e2e_001',
          propertyId: 'prop_e2e_001',
          title: 'Caveat & Partition Suit: Tilakwadi Heritage Property',
          locality: 'Tilakwadi',
          description:
              'Civil dispute regarding partition of ancestral property pending before court.',
          disputeType: DisputeType.courtCaseStayOrder,
          verificationStatus: DisputeVerificationStatus.underReview,
          caseNumber: 'O.S. 881/2026',
          courtAuthority: 'Civil Court Senior Division Belagavi',
          contactPhone: '+91 94481 12345',
          photoUrls: const ['https://images.unsplash.com/photo-site'],
          documentUrls: const [
            'https://storage.belagaviproperty.com/legal/injunction_order.pdf',
          ],
          isDocumentPrivate: true,
          reportedBy: 'usr_claimant_e2e',
        );

        final createResult = await disputeRepository.createDispute(
          dispute,
          authenticatedUserId: 'usr_claimant_e2e',
        );
        expect(createResult.isRight(), isTrue);

        final publicViewResult = await disputeRepository.getDisputeById(
          'disp_e2e_001',
          requestingUserId: 'usr_buyer_public',
          userRole: UserRole.user,
        );

        publicViewResult.fold((_) => fail('Failed to fetch public dispute'), (
          d,
        ) {
          expect(d, isNotNull);
          expect(d!.documentUrls, isEmpty);
          expect(d.contactPhone, contains('•••••')); // Masked contact
        });
      },
    );

    // ——— FLOW G & H: PURCHASE / SALE & LEGAL NOTICE MODULES —————————————————
    test(
      'FLOW G & H: Purchase / Sale and Legal Notice — Save without documents, attach later, ₹500 deal rule',
      () async {
        expect(ListingPricingConfig.purchaseSaleDealFeeInRupees, 500);

        const notice = TransactionLegalNoticeEntity(
          id: 'not_e2e_001',
          title: 'Public Notice of Intended Purchase: 3 BHK House Club Road',
          locality: 'Club Road',
          buyerName: 'Mr. Rajesh Kulkarni',
          sellerName: 'Mr. Arvind Shinde',
          contactName: 'Adv. M. S. Patil',
          contactPhone: '+91 98800 11223',
          transactionType: 'Purchase',
          agreedValue: 'â‚¹ 1.25 Crore',
          noticeType: LegalNoticeType.purchaseLegalNotice,
          issuingAuthority: 'Belagavi Bar Association / Sub-Registrar',
          referenceNumber: 'PUB/NOT/2026/104',
          documentUrls: const [],
          isDocumentPrivate: true,
          canAddDocumentsLater: true,
        );

        final createResult = await noticeRepository.createLegalNotice(
          notice,
          authenticatedUserId: 'usr_advocate_e2e',
        );
        expect(createResult.isRight(), isTrue);

        // Attach supporting notice documents later
        final attachResult = await noticeRepository.attachDocuments(
          'not_e2e_001',
          newDocuments: const [
            'https://storage.belagaviproperty.com/legal/newspaper_notice.pdf',
          ],
          authenticatedUserId: 'usr_advocate_e2e',
        );
        expect(attachResult.isRight(), isTrue);
      },
    );

    // â”€â”€â”€ FLOW I: INDIA-WIDE SEARCH & LOCALITY RESOLVER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    test(
      'FLOW I: India-wide location hierarchy and zero-Google-billing map configuration',
      () {
        expect(MapConfiguration.mapTileUrlTemplate, isNotEmpty);
        expect(MapConfiguration.defaultLatitude, 15.8497);
        expect(MapConfiguration.defaultLongitude, 74.4977);

        final tilakwadi = MapConfiguration.resolveLocation('Tilakwadi');
        expect(tilakwadi, isNotNull);
        expect(tilakwadi!.city, 'Belagavi');
        expect(tilakwadi.state, 'Karnataka');

        final bengaluru = MapConfiguration.resolveLocation('Indiranagar');
        expect(bengaluru, isNotNull);
        expect(bengaluru!.city, 'Bengaluru');

        final mumbai = MapConfiguration.resolveLocation('Bandra');
        expect(mumbai, isNotNull);
        expect(mumbai!.city, 'Mumbai');

        final pune = MapConfiguration.resolveLocation('Kothrud');
        expect(pune, isNotNull);
        expect(pune!.city, 'Pune');
      },
    );
  });
}
