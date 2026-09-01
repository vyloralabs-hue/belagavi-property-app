import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class MockPropertyRepositoryImpl implements PropertyRepository {
  final Map<String, PropertyEntity> storage = {};
  bool shouldFail = false;

  @override
  Future<Either<Failure, PropertyEntity>> createProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
  }) async {
    if (shouldFail) return left(const ServerFailure('Database creation error'));
    final propId = property.id.isEmpty ? 'prop_${storage.length + 1}' : property.id;
    final saved = property.copyWith(id: propId);
    storage[propId] = saved;
    return right(saved);
  }

  @override
  Future<Either<Failure, PropertyEntity>> updateProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    if (shouldFail) return left(const ServerFailure('Database update error'));
    storage[property.id] = property;
    return right(property);
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    var list = storage.values.toList();
    if (category != null) {
      list = list.where((p) => p.category == category).toList();
    }
    return right(list);
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) async => right(storage.values.where((p) => p.ownerId == ownerId).toList());

  @override
  Future<Either<Failure, List<PropertyEntity>>> getAllPropertiesForAdmin({
    required String authenticatedUserId,
    UserRole? userRole,
    int limit = 100,
    int offset = 0,
  }) async => right(storage.values.toList());

  @override
  Future<Either<Failure, PropertyEntity?>> getPropertyById(
    String id, {
    String? requestingUserId,
    List<PropertyUnlockEntity>? userUnlocks,
  }) async => right(storage[id]);

  @override
  Future<Either<Failure, PropertyEntity>> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    final existing = storage[propertyId];
    if (existing == null) return left(const ServerFailure('Not found'));
    final updated = existing.copyWith(status: newStatus);
    storage[propertyId] = updated;
    return right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteProperty(
    String id, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    storage.remove(id);
    return right(null);
  }

  @override
  Future<Either<Failure, AIPropertyAnalysisEntity>> analyzePropertyWithAI(PropertyEntity property) async {
    return right(const AIPropertyAnalysisEntity(qualityScore: 85));
  }
}

void main() {
  group('PHASE 1 â€” NORMAL PROPERTY LISTING WORKFLOW TESTS', () {
    late MockPropertyRepositoryImpl repo;
    late PropertyFormNotifier notifier;
    const testUserId = 'usr_seller_belagavi_001';

    setUp(() {
      repo = MockPropertyRepositoryImpl();
      notifier = PropertyFormNotifier(repo);
    });

    test('1. Residential Property Listing: Complete flow with 3 BHK, details, location, cover photo and submission', () async {
      notifier.initForNewProperty(testUserId);

      // Step 1: Category & Subtype
      notifier.updatePropertyType(
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        listingType: 'FOR_SALE',
      );
      expect(notifier.state.category, PropertyCategory.residential);

      // Step 2: Details
      notifier.updateBasicDetails(
        title: '3 BHK Ultra Luxury Apartment in Tilakwadi',
        description: 'Prime location near railway gate, marble flooring, 2 covered car parks.',
      );

      // Step 3: Location
      notifier.updateLocation(
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: '4th Cross, Tilakwadi',
        pincode: '590006',
        latitude: 15.8398,
        longitude: 74.5089,
      );

      // Step 4: Specs & Pricing
      notifier.updatePriceAndArea(
        price: 6500000,
        carpetArea: 1350,
        superBuiltUpArea: 1600,
      );
      notifier.updateSpecifications(const PropertySpecificationsEntity(
        bedrooms: 3,
        bathrooms: 3,
        balconies: 2,
        floorNumber: 3,
        totalFloors: 5,
        furnishingStatus: 'Semi-Furnished',
        facingDirection: 'East',
        carpetArea: 1350,
        superBuiltUpArea: 1600,
      ));

      // Step 5: Photos & Cover Photo
      notifier.addMedia(const PropertyMediaEntity(
        id: 'med_res_cover',
        propertyId: 'temp',
        mediaUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        type: MediaType.image,
        isCover: true,
      ));

      // Submit
      final success = await notifier.submitProperty(testUserId);
      expect(success, isTrue);

      // Verification in Category Feed
      final catQuery = await repo.getProperties(category: PropertyCategory.residential);
      expect(catQuery.isRight(), isTrue);
      final properties = catQuery.getOrElse((_) => []);
      expect(properties.length, 1);
      expect(properties.first.title, contains('Tilakwadi'));
      expect(properties.first.category, PropertyCategory.residential);
      expect(properties.first.mediaList.first.isCover, isTrue);
    });

    test('2. Plots & Layouts Listing: Complete flow with 30x40 dimension, road width, NA converted & cover photo', () async {
      notifier.initForNewProperty(testUserId);

      notifier.updatePropertyType(
        category: PropertyCategory.plotLand,
        type: PropertySubtype.residentialPlot,
        listingType: 'FOR_SALE',
      );

      notifier.updateBasicDetails(
        title: 'Clear Title 30x40 NA Plot in Angol',
        description: 'BUDA approved layout plot with 30ft wide tar road and drainage connection.',
      );

      notifier.updateLocation(
        city: 'Belagavi',
        locality: 'Angol',
        address: 'Shanti Nagar, Angol',
        pincode: '590006',
      );

      notifier.updatePriceAndArea(
        price: 3200000,
        plotArea: 1200,
      );

      notifier.updatePlotDetails(
        plotLength: 40,
        plotWidth: 30,
        roadWidth: 30,
        isCornerPlot: false,
        isGatedLayout: true,
        hasBoundaryWall: true,
        isNaConverted: true,
        isLayoutApproved: true,
        facingDirection: 'North',
      );

      notifier.addMedia(const PropertyMediaEntity(
        id: 'med_plot_cover',
        propertyId: 'temp',
        mediaUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
        type: MediaType.image,
        isCover: true,
      ));

      final success = await notifier.submitProperty(testUserId);
      expect(success, isTrue);

      final catQuery = await repo.getProperties(category: PropertyCategory.plotLand);
      final plots = catQuery.getOrElse((_) => []);
      expect(plots.length, 1);
      expect(plots.first.features['plotLength'], 40);
      expect(plots.first.features['plotWidth'], 30);
      expect(plots.first.features['roadWidth'], 30);
      expect(plots.first.features['isNaConverted'], isTrue);
    });

    test('3. Commercial Property Listing: Complete flow with Shop subtype, ceiling height, power load & cover photo', () async {
      notifier.initForNewProperty(testUserId);

      notifier.updatePropertyType(
        category: PropertyCategory.commercial,
        type: PropertySubtype.commercialShop,
        listingType: 'FOR_SALE',
      );

      notifier.updateBasicDetails(
        title: 'Prime Commercial Shop on College Road',
        description: 'Ground floor road-facing retail showroom space with heavy footfall.',
      );

      notifier.updateLocation(
        city: 'Belagavi',
        locality: 'College Road',
        address: 'Near Lingaraj College',
        pincode: '590001',
      );

      notifier.updatePriceAndArea(
        price: 7500000,
        carpetArea: 650,
      );

      notifier.updateCommercialDetails(
        ceilingHeight: 14,
        entranceWidth: 20,
        powerLoad: '15 KVA 3-Phase',
        waterSupply: '24/7 Corporation Supply',
        washrooms: 1,
        parkingSpaces: 2,
        hasLift: true,
      );

      notifier.addMedia(const PropertyMediaEntity(
        id: 'med_comm_cover',
        propertyId: 'temp',
        mediaUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
        type: MediaType.image,
        isCover: true,
      ));

      final success = await notifier.submitProperty(testUserId);
      expect(success, isTrue);

      final catQuery = await repo.getProperties(category: PropertyCategory.commercial);
      final comms = catQuery.getOrElse((_) => []);
      expect(comms.length, 1);
      expect(comms.first.features['ceilingHeight'], 14);
      expect(comms.first.features['powerLoad'], '15 KVA 3-Phase');
      expect(comms.first.category, PropertyCategory.commercial);
    });

    test('4. Raw Land Listing: Complete flow with 5 Acres, soil type, borewell, agri power & survey number', () async {
      notifier.initForNewProperty(testUserId);

      notifier.updatePropertyType(
        category: PropertyCategory.land,
        type: PropertySubtype.agriculturalLand,
        listingType: 'FOR_SALE',
      );

      notifier.updateBasicDetails(
        title: '5 Acres Fertile Agricultural Land with Borewell in Sambra',
        description: 'Rich red soil farm with 2 running borewells, electricity and road touch frontage.',
      );

      notifier.updateLocation(
        city: 'Belagavi',
        locality: 'Sambra',
        address: 'Near Sambra Airport Road',
        pincode: '591124',
      );

      notifier.updatePriceAndArea(
        price: 15000000,
        plotArea: 217800, // 5 Acres
      );

      notifier.updatePlotDetails(
        soilType: 'Red Soil',
        waterSource: 'Borewell & Canal',
        hasBorewell: true,
        borewellCount: 2,
        electricityType: '3-Phase Agri Power',
        roadAccessType: 'Tar Road Frontage',
        fencingType: 'Barbed Wire Fencing',
        hasFarmHouse: true,
        existingCropsTrees: 'Sugarcane & Mango',
        surveyNumber: 'Sy No. 182/4A',
        isAgricultural: true,
      );

      notifier.addMedia(const PropertyMediaEntity(
        id: 'med_land_cover',
        propertyId: 'temp',
        mediaUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854',
        type: MediaType.image,
        isCover: true,
      ));

      final success = await notifier.submitProperty(testUserId);
      expect(success, isTrue);

      final catQuery = await repo.getProperties(category: PropertyCategory.land);
      final lands = catQuery.getOrElse((_) => []);
      expect(lands.length, 1);
      expect(lands.first.features['soilType'], 'Red Soil');
      expect(lands.first.features['hasBorewell'], isTrue);
      expect(lands.first.features['surveyNumber'], 'Sy No. 182/4A');
    });

    test('5. Photo Gate: Submitting without at least one cover photo is strictly blocked', () async {
      notifier.initForNewProperty(testUserId);
      notifier.updateBasicDetails(title: 'Apartment without photo');
      notifier.updateLocation(locality: 'Shahapur', city: 'Belagavi');
      notifier.updatePriceAndArea(price: 4000000, carpetArea: 1000);

      // Do NOT add media
      expect(notifier.state.mediaList.isEmpty, isTrue);

      final success = await notifier.submitProperty(testUserId);
      expect(success, isFalse);
      expect(notifier.state.fieldErrors['media'], 'Add at least one property photo to continue.');
    });

    test('6. Completion Score Meter: Deterministic score reaches 100% when all aspects are filled', () {
      notifier.initForNewProperty(testUserId);

      // Basic: 20%
      notifier.updateBasicDetails(title: 'Villa in Mandoli', description: 'Gated community villa with garden');
      // Location: 20%
      notifier.updateLocation(locality: 'Mandoli Road', city: 'Belagavi', pincode: '590006');
      // Specs: 20%
      notifier.updatePriceAndArea(price: 8500000, carpetArea: 2200);
      notifier.updateSpecifications(const PropertySpecificationsEntity(
        bedrooms: 4,
        bathrooms: 4,
        carpetArea: 2200,
      ));
      // Pricing: 15% (price > 0 already done)
      // Amenities: 10%
      notifier.toggleAmenity('Car Parking');
      notifier.toggleAmenity('24/7 Security');
      // Media: 15% (3 photos)
      notifier.addMedia(const PropertyMediaEntity(
        id: 'med_villa_1',
        propertyId: 'temp',
        mediaUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        type: MediaType.image,
        isCover: true,
      ));
      notifier.addMedia(const PropertyMediaEntity(
        id: 'med_villa_2',
        propertyId: 'temp',
        mediaUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
        type: MediaType.image,
        isCover: false,
      ));
      notifier.addMedia(const PropertyMediaEntity(
        id: 'med_villa_3',
        propertyId: 'temp',
        mediaUrl: 'https://images.unsplash.com/photo-1613977257363-707ba9348227',
        type: MediaType.image,
        isCover: false,
      ));

      final score = notifier.calculateCompletionScore();
      expect(score, 100);
      expect(notifier.getMissingPublishFields(), isEmpty);
    });
  });
}