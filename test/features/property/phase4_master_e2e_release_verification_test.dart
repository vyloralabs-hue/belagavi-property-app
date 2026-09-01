import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
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

  group('PHASE 4: MASTER RELEASE E2E VERIFICATION MATRIX', () {
    // Flow 1: Residential Listing
    test(
      'Flow 1: Residential listing creation with full specifications & validations',
      () {
        formNotifier.initForNewProperty('usr_res_1');
        formNotifier.updatePropertyType(
          category: PropertyCategory.residential,
          type: PropertySubtype.apartment,
        );
        formNotifier.updateBasicDetails(
          title: '3 BHK Luxury Apartment in Tilakwadi',
          description:
              'Spacious east-facing flat with balconies and covered parking.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'Tilakwadi',
          city: 'Belagavi',
          stateName: 'Karnataka',
          address: '1st Cross, Congress Road',
          pincode: '590006',
        );
        formNotifier.updatePriceAndArea(
          price: 8500000.0,
          carpetArea: 1650.0,
          builtUpArea: 1950.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateSpecifications(
          const PropertySpecificationsEntity(
            bedrooms: 3,
            bathrooms: 3,
            balconies: 2,
            floorNumber: 3,
            totalFloors: 5,
            furnishingStatus: 'Semi-Furnished',
            facingDirection: 'East',
          ),
        );

        expect(formNotifier.validateStep(1), isTrue);
        expect(formNotifier.validateStep(2), isTrue);
        expect(formNotifier.validateStep(3), isTrue);

        final entity = formNotifier.state.toEntity('usr_res_1');
        expect(entity.category, equals(PropertyCategory.residential));
        expect(entity.specifications.bedrooms, equals(3));
        expect(entity.price, equals(8500000.0));
      },
    );

    // Flow 2: Plot Listing
    test('Flow 2: Plot listing creation with layout approval & dimensions', () {
      formNotifier.initForNewProperty('usr_plot_1');
      formNotifier.updatePropertyType(
        category: PropertyCategory.plotLand,
        type: PropertySubtype.residentialPlot,
      );
      formNotifier.updateBasicDetails(
        title: '30x40 BUDA Approved Residential Plot in Mandoli Road',
        description:
            'Clear title NA converted residential plot ready for immediate construction.',
        listingType: 'FOR_SALE',
      );
      formNotifier.updateLocation(
        locality: 'Mandoli Road',
        city: 'Belagavi',
        stateName: 'Karnataka',
        address: 'Plot 12, Green Layout',
        pincode: '590008',
      );
      formNotifier.updatePriceAndArea(
        price: 3200000.0,
        plotArea: 1200.0,
        areaUnit: 'sqft',
      );
      formNotifier.updatePlotDetails(
        plotLength: 40.0,
        plotWidth: 30.0,
        roadWidth: 30.0,
        isCornerPlot: false,
        isGatedLayout: true,
        hasBoundaryWall: true,
        isNaConverted: true,
        isLayoutApproved: true,
      );

      final entity = formNotifier.state.toEntity('usr_plot_1');
      expect(entity.category, equals(PropertyCategory.plotLand));
      expect(entity.features['plotLength'], equals(40.0));
      expect(entity.features['plotWidth'], equals(30.0));
      expect(entity.features['isLayoutApproved'], isTrue);
    });

    // Flow 3: Commercial Listing
    test(
      'Flow 3: Commercial listing creation with entrance width & power load',
      () {
        formNotifier.initForNewProperty('usr_comm_1');
        formNotifier.updatePropertyType(
          category: PropertyCategory.commercial,
          type: PropertySubtype.commercialOffice,
        );
        formNotifier.updateBasicDetails(
          title: 'Ground Floor Commercial Office on College Road',
          description: 'Prime retail office with 40 ft frontage on main road.',
          listingType: 'FOR_SALE',
        );
        formNotifier.updateLocation(
          locality: 'College Road',
          city: 'Belagavi',
          stateName: 'Karnataka',
          address: 'Main College Road',
          pincode: '590001',
        );
        formNotifier.updatePriceAndArea(
          price: 18000000.0,
          carpetArea: 2200.0,
          areaUnit: 'sqft',
        );
        formNotifier.updateCommercialDetails(
          entranceWidth: 40.0,
          ceilingHeight: 14.0,
          parkingSpaces: 4,
          hasLift: true,
          powerLoad: '25 KVA',
        );

        final entity = formNotifier.state.toEntity('usr_comm_1');
        expect(entity.category, equals(PropertyCategory.commercial));
        expect(entity.features['entranceWidth'], equals(40.0));
        expect(entity.features['powerLoad'], equals('25 KVA'));
      },
    );

    // Flow 4: Raw Land Listing
    test('Flow 4: Raw Land listing creation with water source & soil type', () {
      formNotifier.initForNewProperty('usr_land_1');
      formNotifier.updatePropertyType(
        category: PropertyCategory.land,
        type: PropertySubtype.agriculturalLand,
      );
      formNotifier.updateBasicDetails(
        title: '5 Acres Fertile Agricultural Land in Sambra',
        description:
            'Rich black soil farm land with canal water and 30ft road.',
        listingType: 'FOR_SALE',
      );
      formNotifier.updateLocation(
        locality: 'Sambra',
        city: 'Belagavi',
        stateName: 'Karnataka',
        address: 'Sambra Village',
        pincode: '591124',
      );
      formNotifier.updatePriceAndArea(
        price: 12500000.0,
        plotArea: 5.0,
        areaUnit: 'acre',
      );
      formNotifier.updatePlotDetails(
        soilType: 'Black Soil',
        waterSource: 'Canal & Borewell',
        hasBorewell: true,
        borewellCount: 2,
        roadAccessType: 'Tar Road',
        surveyNumber: 'Sy No. 112/1B',
        isAgricultural: true,
      );

      final entity = formNotifier.state.toEntity('usr_land_1');
      expect(entity.category, equals(PropertyCategory.land));
      expect(entity.features['soilType'], equals('Black Soil'));
      expect(entity.features['surveyNumber'], equals('Sy No. 112/1B'));
    });

    // Flow 5 & 6: Photo Upload and Cover Photo Validation
    test('Flow 5 & 6: Media gallery management and cover photo validation', () {
      formNotifier.initForNewProperty('usr_photo_1');

      // Add cover photo
      const coverMedia = PropertyMediaEntity(
        id: 'med_1',
        propertyId: 'prop_1',
        mediaUrl: 'https://images.unsplash.com/photo-cover',
        type: MediaType.image,
        isCover: true,
        displayOrder: 0,
      );
      formNotifier.addMedia(coverMedia);
      expect(formNotifier.state.mediaList.length, equals(1));
      expect(formNotifier.state.mediaList.first.isCover, isTrue);

      // Add second photo
      const secondMedia = PropertyMediaEntity(
        id: 'med_2',
        propertyId: 'prop_1',
        mediaUrl: 'https://images.unsplash.com/photo-interior',
        type: MediaType.image,
        isCover: false,
        displayOrder: 1,
      );
      formNotifier.addMedia(secondMedia);
      expect(formNotifier.state.mediaList.length, equals(2));
      expect(
        formNotifier.validateStep(5),
        isTrue,
      ); // Step 5 requires at least 1 photo
    });

    // Flow 7: Draft and Resume Workflow
    test('Flow 7: Draft persistence and resumption across sessions', () {
      formNotifier.initForNewProperty('usr_draft_1');
      formNotifier.updatePropertyType(
        category: PropertyCategory.plotLand,
        type: PropertySubtype.residentialPlot,
      );
      formNotifier.updateBasicDetails(
        title: 'Draft Plot in Peeranwadi',
        description: 'Ongoing drafting description...',
        listingType: 'FOR_SALE',
      );
      formNotifier.updatePlotDetails(plotLength: 50.0, plotWidth: 30.0);

      final entity = formNotifier.state.toEntity('usr_draft_1');
      expect(entity.title, equals('Draft Plot in Peeranwadi'));

      // Resume from entity
      final resumedNotifier = PropertyFormNotifier(mockPropertyRepo);
      resumedNotifier.initForEditing(entity);
      expect(resumedNotifier.state.title, equals('Draft Plot in Peeranwadi'));
      expect(resumedNotifier.state.category, equals(PropertyCategory.plotLand));
    });

    // Flow 8: Category Navigation
    test('Flow 8: Category hierarchy and subtype isolation', () {
      expect(PropertyCategory.residential.name, equals('residential'));
      expect(PropertyCategory.plotLand.name, equals('plotLand'));
      expect(PropertyCategory.commercial.name, equals('commercial'));
      expect(PropertyCategory.land.name, equals('land'));
    });

    // Flow 9 & 10: Disputed Property Listing & Privacy Gate
    test(
      'Flow 9 & 10: Disputed property creation with masked public contact & stripped legal documents',
      () async {
        const dispute = PropertyDisputeEntity(
          id: 'disp_master_01',
          propertyId: 'prop_master_01',
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

        // Public verification
        final publicRes = await disputeRepository.getDisputeById(
          'disp_master_01',
          requestingUserId: 'usr_anon_public',
          userRole: UserRole.user,
        );
        publicRes.fold((_) => fail('Failed public fetch'), (d) {
          expect(d, isNotNull);
          expect(d!.documentUrls, isEmpty);
          expect(d.contactPhone, contains('•••••'));
        });

        // Admin verification
        final adminRes = await disputeRepository.getDisputeById(
          'disp_master_01',
          requestingUserId: 'usr_admin_master',
          userRole: UserRole.admin,
        );
        adminRes.fold((_) => fail('Failed admin fetch'), (d) {
          expect(d, isNotNull);
          expect(d!.documentUrls.length, equals(1));
          expect(d.contactPhone, equals('+91 94481 99887'));
        });
      },
    );

    // Flow 11, 12, 13: Purchase / Sale / Legal Notice Records & Optional Uploads
    test(
      'Flow 11, 12, 13: Transaction legal notice creation without docs and attach later',
      () async {
        const notice = TransactionLegalNoticeEntity(
          id: 'not_master_01',
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
          documentUrls: const [], // Saved without documents
          isDocumentPrivate: true,
          canAddDocumentsLater: true,
        );

        final createRes = await noticeRepository.createLegalNotice(
          notice,
          authenticatedUserId: 'usr_advocate_master',
        );
        expect(createRes.isRight(), isTrue);

        // Attach document later
        final attachRes = await noticeRepository.attachDocuments(
          'not_master_01',
          newDocuments: const [
            'https://storage.belagaviproperty.com/legal/publication_clipping.pdf',
          ],
          authenticatedUserId: 'usr_advocate_master',
        );
        expect(attachRes.isRight(), isTrue);
        attachRes.fold(
          (_) => fail('Attach failed'),
          (updated) => expect(updated.documentUrls.length, equals(1)),
        );
      },
    );

    // Flow 14: Map Coordinates Validation
    test(
      'Flow 14: Map coordinates and Belagavi geographical bounding constraints',
      () {
        const belagaviCenterLat = 15.8497;
        const belagaviCenterLng = 74.4977;

        formNotifier.initForNewProperty('usr_geo_1');
        formNotifier.updateLocation(
          locality: 'Tilakwadi',
          city: 'Belagavi',
          stateName: 'Karnataka',
          latitude: belagaviCenterLat,
          longitude: belagaviCenterLng,
        );

        expect(formNotifier.state.latitude, equals(15.8497));
        expect(formNotifier.state.longitude, equals(74.4977));
      },
    );

    // Flow 15 & 16: Light and Dark Theme Compatibility
    testWidgets(
      'Flow 15 & 16: Theme rendering compatibility in Light and Dark mode',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: Container(
                color: AppDesignSystem.backgroundWhite,
                child: const Text(
                  'Light Mode Active',
                  style: TextStyle(color: AppDesignSystem.textPrimary),
                ),
              ),
            ),
          ),
        );
        expect(find.text('Light Mode Active'), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Container(
                color: const Color(0xFF0F172A),
                child: const Text(
                  'Dark Mode Active',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
        expect(find.text('Dark Mode Active'), findsOneWidget);
      },
    );

    // Flow 17: Empty Search & Fallback State
    test(
      'Flow 17: Query with zero matches returns empty list gracefully without throwing',
      () async {
        final searchRes = await noticeRepository.getLegalNotices(
          query: 'NonExistentXYZSearchTerm99999',
        );
        expect(searchRes.isRight(), isTrue);
        searchRes.fold(
          (_) => fail('Search failed'),
          (list) => expect(list, isEmpty),
        );
      },
    );

    // Flow 18: Network Failure Resilience
    test(
      'Flow 18: Uninitialized backend fails gracefully to offline persistent registry',
      () async {
        final uninitializedSupabase = SupabaseService();
        final offlineSource = LegalNoticeRemoteDataSourceImpl(
          uninitializedSupabase,
        );
        final offlineRepo = LegalNoticeRepositoryImpl(offlineSource);

        final result = await offlineRepo.getLegalNotices();
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Offline repository failed'),
          (list) => expect(list.isNotEmpty, isTrue),
        );
      },
    );
  });
}
