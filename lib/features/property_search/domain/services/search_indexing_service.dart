import 'package:equatable/equatable.dart';
import '../../../property/domain/entities/property_entities.dart';

enum SearchEngineBackendType { postgresql, typesense, meilisearch, opensearch }

/// Normalized Public Search Document (0 private/contact PII)
class SearchIndexDocument extends Equatable {
  final String propertyId;
  final String title;
  final String description;
  final String category;
  final String subtype;
  final String purpose;
  final String country;
  final String state;
  final String city;
  final String locality;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final double price;
  final String currency;
  final double? area;
  final String areaUnit;
  final int? bedrooms;
  final int? bathrooms;
  final List<String> amenities;
  final String sellerType;
  final String verificationStatus;
  final String? coverImageUrl;
  final DateTime publishedAt;

  const SearchIndexDocument({
    required this.propertyId,
    required this.title,
    required this.description,
    required this.category,
    required this.subtype,
    required this.purpose,
    required this.country,
    required this.state,
    required this.city,
    required this.locality,
    required this.pincode,
    this.latitude,
    this.longitude,
    required this.price,
    this.currency = 'INR',
    this.area,
    this.areaUnit = 'sqft',
    this.bedrooms,
    this.bathrooms,
    this.amenities = const [],
    this.sellerType = 'owner',
    required this.verificationStatus,
    this.coverImageUrl,
    required this.publishedAt,
  });

  /// Factory to extract ONLY public searchable fields from PropertyEntity
  factory SearchIndexDocument.fromProperty(PropertyEntity property) {
    final specs = property.specifications;
    final area = specs.superBuiltUpArea ?? specs.carpetArea ?? specs.plotArea;
    final coverMedia = property.mediaList.isNotEmpty
        ? property.mediaList.firstWhere(
            (m) => m.isCover,
            orElse: () => property.mediaList.first,
          )
        : null;

    return SearchIndexDocument(
      propertyId: property.id,
      title: property.title,
      description: property.description,
      category: property.category.name,
      subtype: property.type.name,
      purpose: 'forSale',
      country: 'India',
      state: property.state,
      city: property.city,
      locality: property.locality,
      pincode: property.pincode,
      latitude: property.latitude,
      longitude: property.longitude,
      price: property.price,
      currency: 'INR',
      area: area,
      areaUnit: specs.areaUnit,
      bedrooms: specs.bedrooms,
      bathrooms: specs.bathrooms,
      amenities: property.features.keys.toList(),
      sellerType: 'owner',
      verificationStatus: property.verificationStatus.name,
      coverImageUrl: coverMedia?.effectiveThumbnailUrl,
      publishedAt: property.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'property_id': propertyId,
        'title': title,
        'description': description,
        'category': category,
        'subtype': subtype,
        'purpose': purpose,
        'country': country,
        'state': state,
        'city': city,
        'locality': locality,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'price': price,
        'currency': currency,
        'area': area,
        'area_unit': areaUnit,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'amenities': amenities,
        'seller_type': sellerType,
        'verification_status': verificationStatus,
        'cover_image_url': coverImageUrl,
        'published_at': publishedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        propertyId,
        title,
        category,
        subtype,
        city,
        locality,
        price,
        bedrooms,
        publishedAt,
      ];
}

/// Abstract search indexing service with swappable engine adapter
class SearchIndexingService {
  final SearchEngineBackendType backendType;
  final Map<String, SearchIndexDocument> _inMemoryIndex = {};

  SearchIndexingService({
    this.backendType = SearchEngineBackendType.postgresql,
  });

  Map<String, SearchIndexDocument> get indexedDocuments => Map.unmodifiable(_inMemoryIndex);

  /// Index a newly published property
  Future<void> indexProperty(PropertyEntity property) async {
    // Only index published or approved properties
    if (property.status != ListingStatus.published &&
        property.status != ListingStatus.approved &&
        property.status != ListingStatus.active) {
      return;
    }

    final doc = SearchIndexDocument.fromProperty(property);
    _inMemoryIndex[property.id] = doc;
  }

  /// Update an existing property search document
  Future<void> updatePropertyIndex(PropertyEntity property) async {
    if (property.status != ListingStatus.published &&
        property.status != ListingStatus.approved &&
        property.status != ListingStatus.active) {
      await removePropertyIndex(property.id);
      return;
    }

    final doc = SearchIndexDocument.fromProperty(property);
    _inMemoryIndex[property.id] = doc;
  }

  /// Remove document from search index upon deletion or unpublishing
  Future<void> removePropertyIndex(String propertyId) async {
    _inMemoryIndex.remove(propertyId);
  }
}
