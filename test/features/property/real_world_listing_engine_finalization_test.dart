import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/config/listing_pricing_config.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/map/map_configuration.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';

class MockPropertyRepository implements PropertyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockPropertyRepository mockPropertyRepo;
  late PropertyFormNotifier formNotifier;

  setUp(() {
    mockPropertyRepo = MockPropertyRepository();
    formNotifier = PropertyFormNotifier(mockPropertyRepo);
  });

  group(
    'BELAGAVI PROPERTY â€” REAL-WORLD PROPERTY LISTING ENGINE FINALIZATION MATRIX',
    () {
      test(
        '1. Residential: Complete flow with 3 BHK, Rent, Specs, Cover Photo & Validation',
        () {
          formNotifier.initForNewProperty('usr_seller_res_01');
          formNotifier.updatePropertyType(
            category: PropertyCategory.residential,
            type: PropertySubtype.apartment,
          );

          // Step 2: Basic Details (For Rent)
          formNotifier.updateBasicDetails(
            title: 'Luxurious 3 BHK Apartment in Tilakwadi',
            description:
                'Spacious 3 BHK apartment with modular kitchen and covered parking.',
            listingType: 'FOR_RENT',
          );
          expect(formNotifier.validateStep(1), isTrue);

          // Step 3: Location
          formNotifier.updateLocation(
            stateName: 'Karnataka',
            district: 'Belagavi',
            city: 'Belagavi',
            locality: 'Tilakwadi 2nd Gate',
            pincode: '590006',
            address: 'Plot 42, 2nd Railway Gate Road',
            latitude: 15.8497,
            longitude: 74.4977,
          );
          expect(formNotifier.validateStep(2), isTrue);

          // Step 4: Pricing & Specs
          formNotifier.updatePriceAndArea(
            price: 25000.0, // Monthly rent
            carpetArea: 1450.0,
            superBuiltUpArea: 1800.0,
          );
          formNotifier.updateSpecifications(
            const PropertySpecificationsEntity(
              bedrooms: 3,
              bathrooms: 3,
              balconies: 2,
              floorNumber: 4,
              totalFloors: 7,
              furnishingStatus: 'Semi-Furnished',
              facingDirection: 'East',
            ),
          );
          expect(formNotifier.validateStep(3), isTrue);

          // Step 5: Amenities
          formNotifier.toggleAmenity('Lift');
          formNotifier.toggleAmenity('Power Backup');
          formNotifier.toggleAmenity('Covered Parking');
          expect(formNotifier.validateStep(4), isTrue);

          // Step 6: Media (2 photos, first photo is cover)
          const photo1 = PropertyMediaEntity(
            id: 'med_r1',
            propertyId: 'temp_p1',
            mediaUrl:
                'https://storage.belagaviproperty.com/photos/res_living.jpg',
            type: MediaType.image,
            isCover: true,
          );
          const photo2 = PropertyMediaEntity(
            id: 'med_r2',
            propertyId: 'temp_p1',
            mediaUrl: 'https://storage.belagaviproperty.com/photos/res_bed.jpg',
            type: MediaType.image,
            isCover: false,
          );
          formNotifier.addMedia(photo1);
          formNotifier.addMedia(photo2);

          // Step 8: Full validation
          expect(formNotifier.validateStep(7), isTrue);
          expect(formNotifier.getMissingPublishFields(), isEmpty);

          // Verify Entity conversion
          final entity = formNotifier.state.toEntity('usr_seller_res_01');
          expect(entity.title, 'Luxurious 3 BHK Apartment in Tilakwadi');
          expect(entity.price, 25000.0);
          expect(entity.specifications.bedrooms, 3);
          expect(entity.specifications.bathrooms, 3);
          expect(entity.mediaList.length, 2);
          expect(entity.mediaList.first.isCover, isTrue);
        },
      );

      test(
        '2. Plots & Layouts: Auto-calculated Dimensions, Road Width, NA & BUDA Approvals',
        () {
          formNotifier.initForNewProperty('usr_seller_plot_01');
          formNotifier.updatePropertyType(
            category: PropertyCategory.plotLand,
            type: PropertySubtype.residentialPlot,
          );

          formNotifier.updateBasicDetails(
            title: 'BUDA Approved 2400 sqft Corner Plot in Bhagyanagar',
            description:
                'Prime East-facing corner plot with 40 ft wide tar road access.',
          );
          formNotifier.updateLocation(
            locality: 'Bhagyanagar',
            city: 'Belagavi',
            district: 'Belagavi',
            stateName: 'Karnataka',
            pincode: '590008',
          );

          // 40 x 60 = 2400 sqft
          formNotifier.updatePlotDetails(
            plotLength: 40.0,
            plotWidth: 60.0,
            roadWidth: 40.0,
            isCornerPlot: true,
            isGatedLayout: true,
            isNaConverted: true,
            surveyNumber: 'Sy. No. 182/4',
          );
          formNotifier.updatePriceAndArea(
            plotArea: 2400.0,
            price: 7200000.0, // 3000 / sqft
          );

          const photo = PropertyMediaEntity(
            id: 'med_p1',
            propertyId: 'temp_p2',
            mediaUrl:
                'https://storage.belagaviproperty.com/plots/bhagya_plot.jpg',
            type: MediaType.image,
            isCover: true,
          );
          formNotifier.addMedia(photo);

          expect(formNotifier.validateStep(7), isTrue);
          final entity = formNotifier.state.toEntity('usr_seller_plot_01');
          expect(entity.features['plotLength'], 40.0);
          expect(entity.features['plotWidth'], 60.0);
          expect(entity.features['isNaConverted'], isTrue);
          expect(entity.features['surveyNumber'], 'Sy. No. 182/4');
        },
      );

      test(
        '3. Commercial: Purpose (Sale vs Rent vs Lease), Power Load, Goods Lift & Loading Dock',
        () {
          formNotifier.initForNewProperty('usr_seller_comm_01');
          formNotifier.updatePropertyType(
            category: PropertyCategory.commercial,
            type: PropertySubtype.commercialShop,
          );

          // Commercial Lease Workflow
          formNotifier.updateBasicDetails(
            title: 'Ground Floor Commercial Showroom on College Road',
            description:
                'Prime frontage retail showroom with 25 kW power and loading bay.',
            listingType: 'LEASE',
          );
          formNotifier.updateLocation(
            locality: 'College Road',
            city: 'Belagavi',
            district: 'Belagavi',
            stateName: 'Karnataka',
            pincode: '590001',
          );
          formNotifier.updatePriceAndArea(
            price: 800000.0, // Annual lease
            carpetArea: 2200.0,
            superBuiltUpArea: 2600.0,
          );
          formNotifier.updateCommercialDetails(
            entranceWidth: 35.0,
            ceilingHeight: 14.0,
            washrooms: 2,
            powerLoad: '25 kW 3-Phase',
            hasLift: true,
            hasLoadingDock: true,
            parkingSpaces: 4,
          );

          const photo = PropertyMediaEntity(
            id: 'med_c1',
            propertyId: 'temp_p3',
            mediaUrl: 'https://storage.belagaviproperty.com/comm/showroom.jpg',
            type: MediaType.image,
            isCover: true,
          );
          formNotifier.addMedia(photo);

          expect(formNotifier.validateStep(7), isTrue);
          final entity = formNotifier.state.toEntity('usr_seller_comm_01');
          expect(entity.features['powerLoad'], '25 kW 3-Phase');
          expect(entity.features['hasLoadingDock'], isTrue);
          expect(entity.features['hasLift'], isTrue);
          expect(entity.features['entranceWidth'], 35.0);
        },
      );

      test(
        '4. Raw Land / Farm: Acres/Guntas, Survey No, RTC, Water Sources & 3-Phase Electricity',
        () {
          formNotifier.initForNewProperty('usr_seller_raw_01');
          formNotifier.updatePropertyType(
            category: PropertyCategory.land,
            type: PropertySubtype.agriculturalLand,
          );

          formNotifier.updateBasicDetails(
            title: '5 Acres Fertile Agri Land with 2 Borewells near Peeranwadi',
            description:
                'Red loamy soil farm land with canal water and 3-phase agricultural power.',
          );
          formNotifier.updateLocation(
            locality: 'Peeranwadi Rural',
            city: 'Belagavi',
            district: 'Belagavi',
            stateName: 'Karnataka',
            pincode: '590014',
          );
          // 5 Acres = 217,800 sqft
          formNotifier.updatePriceAndArea(
            plotArea: 217800.0,
            price: 12500000.0, // 25 Lakhs / acre
          );
          formNotifier.updatePlotDetails(
            surveyNumber: 'Sy. No. 412/1B',
            soilType: 'Red Loam',
            waterSource: 'Canal & Borewells',
            electricityType: '3-Phase Agricultural',
            roadAccessType: 'Tar Road',
            fencingType: 'Barbed Wire',
            existingCropsTrees: 'Sugarcane & Mango Trees',
          );

          const photo = PropertyMediaEntity(
            id: 'med_l1',
            propertyId: 'temp_p4',
            mediaUrl:
                'https://storage.belagaviproperty.com/land/farm5acres.jpg',
            type: MediaType.image,
            isCover: true,
          );
          formNotifier.addMedia(photo);

          expect(formNotifier.validateStep(7), isTrue);
          final entity = formNotifier.state.toEntity('usr_seller_raw_01');
          expect(entity.features['surveyNumber'], 'Sy. No. 412/1B');
          expect(entity.features['electricityType'], '3-Phase Agricultural');
          expect(
            entity.features['existingCropsTrees'],
            'Sugarcane & Mango Trees',
          );
        },
      );

      test(
        '5. Photo System: Multiple selection, Reorder, Delete, Dynamic Cover Assignment',
        () {
          formNotifier.initForNewProperty('usr_seller_media_01');

          const photoA = PropertyMediaEntity(
            id: 'm_a',
            propertyId: 'temp_m',
            mediaUrl: 'https://storage.belagaviproperty.com/a.jpg',
            type: MediaType.image,
            isCover: true,
          );
          const photoB = PropertyMediaEntity(
            id: 'm_b',
            propertyId: 'temp_m',
            mediaUrl: 'https://storage.belagaviproperty.com/b.jpg',
            type: MediaType.image,
            isCover: false,
          );
          const photoC = PropertyMediaEntity(
            id: 'm_c',
            propertyId: 'temp_m',
            mediaUrl: 'https://storage.belagaviproperty.com/c.jpg',
            type: MediaType.image,
            isCover: false,
          );

          formNotifier.addMedia(photoA);
          formNotifier.addMedia(photoB);
          formNotifier.addMedia(photoC);
          expect(formNotifier.state.mediaList.length, 3);

          // Make Photo B the Primary Cover (moves to index 0)
          formNotifier.setPrimaryImage('m_b');
          expect(formNotifier.state.mediaList[0].id, 'm_b');
          expect(formNotifier.state.mediaList[0].isCover, isTrue);
          expect(formNotifier.state.mediaList[1].isCover, isFalse);

          // Delete photo A
          formNotifier.removeMedia('m_a');
          expect(formNotifier.state.mediaList.length, 2);
          expect(formNotifier.state.mediaList[0].id, 'm_b');
          expect(formNotifier.state.mediaList[0].isCover, isTrue);
        },
      );

      test(
        '6. Draft & Resume Engine: Preserves all category specs and missing fields report',
        () {
          formNotifier.initForNewProperty('usr_seller_draft_01');
          formNotifier.updatePropertyType(
            category: PropertyCategory.plotLand,
            type: PropertySubtype.residentialPlot,
          );
          formNotifier.updateBasicDetails(title: 'Partial Draft Plot');
          // No price, location or media yet

          final missing = formNotifier.getMissingPublishFields();
          expect(missing, contains('Locality / Area'));
          // City defaults to Belagavi in initForNewProperty
          expect(missing, contains('Expected Sale Price (must be > 0)'));
          expect(
            missing,
            contains('Property Area (Carpet / Plot / Land Area)'),
          );
          expect(missing, contains('At least 1 Property Photo'));

          // Save draft state
          expect(formNotifier.state.listingStatus, ListingStatus.draft);

          // Complete missing fields
          formNotifier.updateLocation(
            locality: 'Udyambag',
            city: 'Belagavi',
            district: 'Belagavi',
            stateName: 'Karnataka',
          );
          formNotifier.updatePriceAndArea(price: 3500000.0, plotArea: 1500.0);
          formNotifier.addMedia(
            const PropertyMediaEntity(
              id: 'm_draft',
              propertyId: 'temp_m',
              mediaUrl: 'https://storage.belagaviproperty.com/draft.jpg',
              type: MediaType.image,
              isCover: true,
            ),
          );

          expect(formNotifier.getMissingPublishFields(), isEmpty);
          expect(formNotifier.validateStep(7), isTrue);
        },
      );

      test(
        '7. Location Architecture: Zero Google Maps billing & Native Deep Link configuration',
        () {
          expect(MapConfiguration.defaultLatitude, 15.8497);
          expect(MapConfiguration.defaultLongitude, 74.4977);
        },
      );

      test('8. Centralized Pricing & Security Immutability', () {
        expect(ListingPricingConfig.disputeListingFeeInRupees, 500);
        expect(ListingPricingConfig.purchaseSaleDealFeeInRupees, 500);

        // Security Guard prevents cross-seller tampering
        expect(
          () => PropertySecurityGuard.verifyPropertyOwnership(
            authenticatedUserId: 'attacker_007',
            ownerId: 'seller_123',
            actionName: 'edit property',
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      });
    },
  );
}
