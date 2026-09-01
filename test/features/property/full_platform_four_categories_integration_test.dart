import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';

class MockPropertyRepository implements PropertyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockPropertyRepository mockRepo;
  late PropertyFormNotifier notifier;

  setUp(() {
    mockRepo = MockPropertyRepository();
    notifier = PropertyFormNotifier(mockRepo);
  });

  group('Phase 5: Full 4-Category Platform Integration Tests', () {
    test('1. Housing (Residential) Complete Lifecycle & Serialization', () {
      notifier.initForNewProperty('user_housing_1');
      notifier.updatePropertyType(
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
      );
      notifier.updateBasicDetails(
        title: 'Luxury 3 BHK Penthouse Tilakwadi',
        description: 'Spacious flat with panoramic city views',
        listingType: 'FOR_SALE',
      );
      notifier.updateLocation(
        locality: 'Tilakwadi',
        city: 'Belagavi',
        stateName: 'Karnataka',
        address: '1st Cross, Tilakwadi',
        pincode: '590006',
      );
      notifier.updatePriceAndArea(
        price: 8500000.0,
        carpetArea: 1650.0,
        builtUpArea: 1950.0,
        areaUnit: 'sqft',
        isNegotiable: true,
      );
      notifier.updateSpecifications(
        const PropertySpecificationsEntity(
          bedrooms: 3,
          bathrooms: 3,
          balconies: 2,
          floorNumber: 4,
          totalFloors: 6,
          furnishingStatus: 'Semi-Furnished',
          facingDirection: 'East',
        ),
      );
      notifier.toggleAmenity('Lift / Elevator');
      notifier.toggleAmenity('Power Backup');

      // Validation check
      expect(notifier.validateStep(1), isTrue);
      expect(notifier.validateStep(2), isTrue);
      expect(notifier.validateStep(3), isTrue);

      final entity = notifier.state.toEntity('user_housing_1');
      expect(entity.category, PropertyCategory.residential);
      expect(entity.type, PropertySubtype.apartment);
      expect(entity.price, 8500000.0);
      expect(entity.specifications.bedrooms, 3);
      expect(entity.specifications.bathrooms, 3);
      expect(entity.specifications.carpetArea, 1650.0);

      // Re-init for editing & verify preservation
      notifier.initForEditing(entity);
      expect(notifier.state.title, 'Luxury 3 BHK Penthouse Tilakwadi');
      expect(notifier.state.specifications.bedrooms, 3);
      expect(notifier.state.amenities, contains('Lift / Elevator'));
    });

    test('2. Plot / Land Complete Lifecycle & Serialization', () {
      notifier.initForNewProperty('user_plot_1');
      notifier.updatePropertyType(
        category: PropertyCategory.plotLand,
        type: PropertySubtype.residentialPlot,
      );
      notifier.updateBasicDetails(
        title: 'Corner NA Approved Plot in Bhagya Nagar',
        description: 'Prime 40x60 corner plot in gated layout',
        listingType: 'FOR_SALE',
      );
      notifier.updateLocation(
        locality: 'Bhagya Nagar',
        city: 'Belagavi',
        stateName: 'Karnataka',
        address: 'Plot 42, Green Avenue',
        pincode: '590008',
      );
      notifier.updatePriceAndArea(
        price: 4500000.0,
        plotArea: 2400.0,
        areaUnit: 'sqft',
        isNegotiable: true,
      );
      notifier.updatePlotDetails(
        plotLength: 60.0,
        plotWidth: 40.0,
        roadWidth: 30.0,
        isCornerPlot: true,
        isGatedLayout: true,
        hasBoundaryWall: true,
        numberOfRoads: 2,
        isNaConverted: true,
        isLayoutApproved: true,
        facingDirection: 'North-East',
      );

      expect(notifier.validateStep(1), isTrue);
      expect(notifier.validateStep(2), isTrue);
      expect(notifier.validateStep(3), isTrue);

      final entity = notifier.state.toEntity('user_plot_1');
      expect(entity.category, PropertyCategory.plotLand);
      expect(entity.type, PropertySubtype.residentialPlot);
      expect(entity.features['plotLength'], 60.0);
      expect(entity.features['isCornerPlot'], true);
      expect(entity.features['isNaConverted'], true);

      // Re-init for editing
      notifier.initForEditing(entity);
      expect(notifier.state.plotLength, 60.0);
      expect(notifier.state.isCornerPlot, true);
      expect(notifier.state.numberOfRoads, 2);
    });

    test('3. Commercial Complete Lifecycle & Serialization', () {
      notifier.initForNewProperty('user_comm_1');
      notifier.updatePropertyType(
        category: PropertyCategory.commercial,
        type: PropertySubtype.commercialOffice,
      );
      notifier.updateBasicDetails(
        title: 'Grade-A Commercial Office Khanapur Road',
        description: 'Fully furnished corporate office with power backup',
        listingType: 'FOR_RENT',
      );
      notifier.updateLocation(
        locality: 'Khanapur Road',
        city: 'Belagavi',
        stateName: 'Karnataka',
        address: 'Trade Center, 3rd Floor',
        pincode: '590006',
      );
      notifier.updatePriceAndArea(
        price: 75000.0,
        carpetArea: 1800.0,
        builtUpArea: 2200.0,
        areaUnit: 'sqft',
      );
      notifier.updateRentLeaseDetails(
        securityDeposit: 450000.0,
        maintenanceCharge: 5000.0,
        availabilityDate: 'Immediate',
      );
      notifier.updateCommercialDetails(
        entranceWidth: 25.0,
        ceilingHeight: 12.0,
        washrooms: 2,
        parkingSpaces: 4,
        hasLift: true,
        hasLoadingDock: true,
        powerLoad: '25 KVA 3-Phase',
        waterSupply: '24/7 Municipal + Borewell',
        furnishingStatus: 'Fully Furnished',
        floorNumber: 3,
        totalFloors: 5,
      );

      expect(notifier.validateStep(1), isTrue);
      expect(notifier.validateStep(2), isTrue);
      expect(notifier.validateStep(3), isTrue);

      final entity = notifier.state.toEntity('user_comm_1');
      expect(entity.category, PropertyCategory.commercial);
      expect(entity.type, PropertySubtype.commercialOffice);
      expect(entity.features['entranceWidth'], 25.0);
      expect(entity.features['ceilingHeight'], 12.0);
      expect(entity.features['washrooms'], 2);
      expect(entity.features['parkingSpaces'], 4);
      expect(entity.features['hasLift'], true);
      expect(entity.features['powerLoad'], '25 KVA 3-Phase');

      // Re-init for editing
      notifier.initForEditing(entity);
      expect(notifier.state.entranceWidth, 25.0);
      expect(notifier.state.washrooms, 2);
      expect(notifier.state.hasLift, true);
    });

    test('4. Raw Land Complete Lifecycle & Serialization', () {
      notifier.initForNewProperty('user_raw_1');
      notifier.updatePropertyType(
        category: PropertyCategory.land,
        type: PropertySubtype.agriculturalLand,
      );
      notifier.updateBasicDetails(
        title: '5 Acre Fertile Sugarcane Farm Land Sambra',
        description: 'Red soil agricultural land with 2 borewells and river access',
        listingType: 'FOR_SALE',
      );
      notifier.updateLocation(
        locality: 'Sambra Road',
        city: 'Belagavi',
        stateName: 'Karnataka',
        address: 'Survey 142/3, Sambra',
        pincode: '591124',
      );
      notifier.updatePriceAndArea(
        price: 15000000.0,
        plotArea: 5.0,
        areaUnit: 'acre',
        isNegotiable: true,
      );
      notifier.updatePlotDetails(
        soilType: 'Red Soil',
        waterSource: 'Borewell + Canal',
        hasBorewell: true,
        borewellCount: 2,
        electricityType: '3-Phase Agri Power',
        roadAccessType: 'Tar Road Frontage',
        fencingType: 'Barbed Wire Fencing',
        hasFarmHouse: true,
        existingCropsTrees: 'Sugarcane & 50 Coconut Trees',
        surveyNumber: 'Sy No. 142/3',
        isAgricultural: true,
      );

      expect(notifier.validateStep(1), isTrue);
      expect(notifier.validateStep(2), isTrue);
      expect(notifier.validateStep(3), isTrue);

      final entity = notifier.state.toEntity('user_raw_1');
      expect(entity.category, PropertyCategory.land);
      expect(entity.type, PropertySubtype.agriculturalLand);
      expect(entity.features['soilType'], 'Red Soil');
      expect(entity.features['waterSource'], 'Borewell + Canal');
      expect(entity.features['hasBorewell'], true);
      expect(entity.features['borewellCount'], 2);
      expect(entity.features['electricityType'], '3-Phase Agri Power');
      expect(entity.features['hasFarmHouse'], true);
      expect(entity.features['surveyNumber'], 'Sy No. 142/3');

      // Re-init for editing
      notifier.initForEditing(entity);
      expect(notifier.state.soilType, 'Red Soil');
      expect(notifier.state.waterSource, 'Borewell + Canal');
      expect(notifier.state.hasBorewell, true);
      expect(notifier.state.hasFarmHouse, true);
      expect(notifier.state.surveyNumber, 'Sy No. 142/3');
    });

    test('5. Cross-Category Isolation — Validation and Field Purity', () {
      // Raw Land should not require Bedrooms/Washrooms/Elevator
      notifier.initForNewProperty('user_raw_2');
      notifier.updatePropertyType(
        category: PropertyCategory.land,
        type: PropertySubtype.agriculturalLand,
      );
      notifier.updateBasicDetails(
        title: 'Agricultural Land 2 Guntha',
        listingType: 'FOR_SALE',
      );
      notifier.updateLocation(
        locality: 'Udyambag Rural',
        city: 'Belagavi',
      );
      notifier.updatePriceAndArea(
        price: 2500000.0,
        plotArea: 2.0,
        areaUnit: 'guntha',
      );
      expect(notifier.validateStep(1), isTrue);
      expect(notifier.validateStep(2), isTrue);
      expect(notifier.validateStep(3), isTrue);

      // Plot should not require Washrooms or Bedrooms
      notifier.initForNewProperty('user_plot_2');
      notifier.updatePropertyType(
        category: PropertyCategory.plotLand,
        type: PropertySubtype.residentialPlot,
      );
      notifier.updateBasicDetails(
        title: '30x40 Site in Shahapur',
        listingType: 'FOR_SALE',
      );
      notifier.updateLocation(
        locality: 'Shahapur',
        city: 'Belagavi',
      );
      notifier.updatePriceAndArea(
        price: 3200000.0,
        plotArea: 1200.0,
        areaUnit: 'sqft',
      );
      expect(notifier.validateStep(1), isTrue);
      expect(notifier.validateStep(2), isTrue);
      expect(notifier.validateStep(3), isTrue);
    });
  });
}
