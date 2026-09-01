import 'dart:math';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

class SyntheticPropertyRecord {
  final PropertyEntity property;
  final String testRunId;

  const SyntheticPropertyRecord({
    required this.property,
    required this.testRunId,
  });

  Map<String, dynamic> toDatabaseRow() {
    final specs = property.specifications;
    return {
      'id': property.id,
      'owner_id': property.ownerId,
      'title': property.title,
      'description': property.description,
      'category': property.category.name,
      'type': property.type.name,
      'listing_purpose': 'forSale',
      'status': property.status.name,
      'verification_status': property.verificationStatus.name,
      'price': property.price,
      'currency': 'INR',
      'built_up_area':
          specs.superBuiltUpArea ?? specs.plotArea ?? specs.carpetArea ?? 1000,
      'area_unit': specs.areaUnit,
      'bedrooms': specs.bedrooms,
      'bathrooms': specs.bathrooms,
      'country': 'India',
      'state': property.state,
      'district': property.district,
      'taluk': property.taluk,
      'city': property.city,
      'locality': property.locality,
      'address': property.address,
      'pincode': property.pincode,
      'latitude': property.latitude,
      'longitude': property.longitude,
      'test_run_id': testRunId,
      'created_at': property.createdAt.toIso8601String(),
      'updated_at': property.updatedAt.toIso8601String(),
    };
  }
}

class StagingDataGenerator {
  static const List<String> localities = [
    'Tilakwadi',
    'Mandoli Road',
    'Camp',
    'Shahapur',
    'Udyambag',
    'Angol',
    'Vadgaon',
    'Hindwadi',
    'Bhagya Nagar',
    'Khanapur Road',
    'Club Road',
    'Rani Chennamma Nagar',
    'Kuvempu Nagar',
    'Auto Nagar',
    'Peeranwadi',
  ];

  static const List<Map<String, dynamic>> categoryConfigurations = [
    {
      'category': PropertyCategory.residential,
      'type': PropertySubtype.apartment,
      'titleTemplate': 'Luxury BHK Apartment in',
      'minPrice': 3500000.0,
      'maxPrice': 12000000.0,
      'minArea': 850.0,
      'maxArea': 2200.0,
      'isBhkRelevant': true,
    },
    {
      'category': PropertyCategory.residential,
      'type': PropertySubtype.villa,
      'titleTemplate': 'Premium Independent Villa in',
      'minPrice': 7500000.0,
      'maxPrice': 25000000.0,
      'minArea': 1800.0,
      'maxArea': 4500.0,
      'isBhkRelevant': true,
    },
    {
      'category': PropertyCategory.plotLand,
      'type': PropertySubtype.residentialPlot,
      'titleTemplate': 'Clear Title Residential Plot in',
      'minPrice': 1800000.0,
      'maxPrice': 8000000.0,
      'minArea': 1200.0,
      'maxArea': 4000.0,
      'isBhkRelevant': false,
    },
    {
      'category': PropertyCategory.commercial,
      'type': PropertySubtype.commercialShop,
      'titleTemplate': 'High Footfall Commercial Shop in',
      'minPrice': 4500000.0,
      'maxPrice': 20000000.0,
      'minArea': 300.0,
      'maxArea': 1500.0,
      'isBhkRelevant': false,
    },
  ];

  /// Generate [count] realistic synthetic property records tagged with [testRunId]
  static List<SyntheticPropertyRecord> generateBatch({
    required String testRunId,
    required int count,
    Random? randomInstance,
  }) {
    final rng =
        randomInstance ??
        Random(42); // Deterministic seed for reproducible benchmarks
    final results = <SyntheticPropertyRecord>[];

    final now = DateTime.now();

    for (int i = 1; i <= count; i++) {
      final config = categoryConfigurations[i % categoryConfigurations.length];
      final locality = localities[rng.nextInt(localities.length)];
      final category = config['category'] as PropertyCategory;
      final type = config['type'] as PropertySubtype;
      final isBhk = config['isBhkRelevant'] as bool;

      final bedrooms = isBhk ? (rng.nextInt(3) + 2) : null; // 2, 3, or 4 BHK
      final bathrooms = isBhk ? (bedrooms! - (rng.nextBool() ? 1 : 0)) : null;

      final minPrice = config['minPrice'] as double;
      final maxPrice = config['maxPrice'] as double;
      final price = (minPrice + rng.nextDouble() * (maxPrice - minPrice))
          .roundToDouble();

      final minArea = config['minArea'] as double;
      final maxArea = config['maxArea'] as double;
      final area = (minArea + rng.nextDouble() * (maxArea - minArea))
          .roundToDouble();

      final title = isBhk
          ? '$bedrooms BHK ${(config['titleTemplate'] as String).replaceAll('BHK ', '')} $locality'
          : '${config['titleTemplate']} $locality';

      final propId = 'synth_${testRunId}_${i.toString().padLeft(6, '0')}';
      final ownerId = 'synth_owner_${(i % 500) + 1}'; // 500 synthetic owners

      final property = PropertyEntity(
        id: propId,
        ownerId: ownerId,
        title: title,
        description:
            'Prime verified property located in $locality, Belagavi with high appreciation potential, wide road access, and clear legal title deeds.',
        category: category,
        type: type,
        status: ListingStatus.published,
        price: price,
        specifications: PropertySpecificationsEntity(
          superBuiltUpArea: area,
          carpetArea: area * 0.82,
          plotArea: category == PropertyCategory.plotLand ? area : null,
          areaUnit: 'sqft',
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          facingDirection: [
            'East',
            'North',
            'North-East',
            'West',
          ][rng.nextInt(4)],
        ),
        mediaList: [
          PropertyMediaEntity(
            id: 'med_${propId}_1',
            propertyId: propId,
            mediaUrl:
                'https://cdn-staging.belagaviproperty.com/properties/$propId/cover.webp',
            thumbnailUrl:
                'https://cdn-staging.belagaviproperty.com/properties/$propId/thumb_300x200.webp',
            mediumUrl:
                'https://cdn-staging.belagaviproperty.com/properties/$propId/medium_800x600.webp',
            type: MediaType.image,
            isCover: true,
          ),
        ],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: locality,
        address: '${rng.nextInt(50) + 1}th Cross, $locality',
        pincode: '590006',
        latitude: 15.8497 + (rng.nextDouble() - 0.5) * 0.08,
        longitude: 74.5089 + (rng.nextDouble() - 0.5) * 0.08,
        verificationStatus: (i % 3 == 0)
            ? VerificationStatus.verified
            : VerificationStatus.unverified,
        createdAt: now.subtract(Duration(hours: i % 720)),
        updatedAt: now.subtract(Duration(hours: i % 72)),
      );

      results.add(
        SyntheticPropertyRecord(property: property, testRunId: testRunId),
      );
    }

    return results;
  }
}
