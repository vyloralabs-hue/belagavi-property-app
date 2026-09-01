import 'package:equatable/equatable.dart';
import '../../../property/domain/entities/property_entities.dart';

class SearchQueryEntity extends Equatable {
  final String? rawQuery;
  final String? country;
  final String? state;
  final String? district;
  final String? city;
  final String? locality;
  final String? area;
  final String? pincode;
  final PropertyCategory? category;
  final PropertySubtype? type;
  final ListingPurpose? purpose;
  final List<String>? amenities;
  final String? unitStatus;
  final String? projectId;
  final String? builderId;
  final String? ownerId;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int? minBedrooms;
  final int? maxBedrooms;
  final String? facingDirection;
  final bool? isNaApproved;
  final bool? isVerifiedOnly;
  final bool? isFeaturedOnly;
  final ListingStatus? status; // Null defaults to PUBLISHED for public search
  final String sortBy; // 'created_at_desc', 'price_asc', 'price_desc', 'area_desc'
  final int limit;
  final int offset;

  const SearchQueryEntity({
    this.rawQuery,
    this.country,
    this.state,
    this.district,
    this.city,
    this.locality,
    this.area,
    this.pincode,
    this.category,
    this.type,
    this.purpose,
    this.amenities,
    this.unitStatus,
    this.projectId,
    this.builderId,
    this.ownerId,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.minBedrooms,
    this.maxBedrooms,
    this.facingDirection,
    this.isNaApproved,
    this.isVerifiedOnly,
    this.isFeaturedOnly,
    this.status,
    this.sortBy = 'created_at_desc',
    this.limit = 20,
    this.offset = 0,
  });

  SearchQueryEntity copyWith({
    String? rawQuery,
    String? country,
    String? state,
    String? district,
    String? city,
    String? locality,
    String? area,
    String? pincode,
    PropertyCategory? category,
    PropertySubtype? type,
    ListingPurpose? purpose,
    List<String>? amenities,
    String? unitStatus,
    String? projectId,
    String? builderId,
    String? ownerId,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? minBedrooms,
    int? maxBedrooms,
    String? facingDirection,
    bool? isNaApproved,
    bool? isVerifiedOnly,
    bool? isFeaturedOnly,
    ListingStatus? status,
    String? sortBy,
    int? limit,
    int? offset,
  }) {
    return SearchQueryEntity(
      rawQuery: rawQuery ?? this.rawQuery,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      area: area ?? this.area,
      pincode: pincode ?? this.pincode,
      category: category ?? this.category,
      type: type ?? this.type,
      purpose: purpose ?? this.purpose,
      amenities: amenities ?? this.amenities,
      unitStatus: unitStatus ?? this.unitStatus,
      projectId: projectId ?? this.projectId,
      builderId: builderId ?? this.builderId,
      ownerId: ownerId ?? this.ownerId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      facingDirection: facingDirection ?? this.facingDirection,
      isNaApproved: isNaApproved ?? this.isNaApproved,
      isVerifiedOnly: isVerifiedOnly ?? this.isVerifiedOnly,
      isFeaturedOnly: isFeaturedOnly ?? this.isFeaturedOnly,
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rawQuery': rawQuery,
      'country': country,
      'state': state,
      'district': district,
      'city': city,
      'locality': locality,
      'area': area,
      'pincode': pincode,
      'category': category?.name,
      'type': type?.name,
      'purpose': purpose?.name,
      'amenities': amenities,
      'unitStatus': unitStatus,
      'projectId': projectId,
      'builderId': builderId,
      'ownerId': ownerId,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minArea': minArea,
      'maxArea': maxArea,
      'minBedrooms': minBedrooms,
      'maxBedrooms': maxBedrooms,
      'facingDirection': facingDirection,
      'isNaApproved': isNaApproved,
      'isVerifiedOnly': isVerifiedOnly,
      'isFeaturedOnly': isFeaturedOnly,
      'status': status?.name,
      'sortBy': sortBy,
      'limit': limit,
      'offset': offset,
    };
  }

  factory SearchQueryEntity.fromJson(Map<String, dynamic> json) {
    return SearchQueryEntity(
      rawQuery: json['rawQuery'] as String?,
      country: json['country'] as String? ?? 'India',
      state: json['state'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String? ?? 'Belagavi',
      locality: json['locality'] as String?,
      area: json['area'] as String?,
      pincode: json['pincode'] as String?,
      category: json['category'] != null
          ? PropertyCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => PropertyCategory.residential,
            )
          : null,
      type: json['type'] != null
          ? PropertySubtype.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => PropertySubtype.apartment,
            )
          : null,
      purpose: json['purpose'] != null
          ? ListingPurpose.values.firstWhere(
              (e) => e.name == json['purpose'],
              orElse: () => ListingPurpose.forSale,
            )
          : null,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      unitStatus: json['unitStatus'] as String?,
      projectId: json['projectId'] as String?,
      builderId: json['builderId'] as String?,
      ownerId: json['ownerId'] as String?,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minArea: (json['minArea'] as num?)?.toDouble(),
      maxArea: (json['maxArea'] as num?)?.toDouble(),
      minBedrooms: (json['minBedrooms'] as num?)?.toInt(),
      maxBedrooms: (json['maxBedrooms'] as num?)?.toInt(),
      facingDirection: json['facingDirection'] as String?,
      isNaApproved: json['isNaApproved'] as bool?,
      isVerifiedOnly: json['isVerifiedOnly'] as bool?,
      isFeaturedOnly: json['isFeaturedOnly'] as bool?,
      status: json['status'] != null
          ? ListingStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => ListingStatus.published,
            )
          : null,
      sortBy: json['sortBy'] as String? ?? 'created_at_desc',
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        rawQuery,
        country,
        state,
        district,
        city,
        locality,
        area,
        pincode,
        category,
        type,
        purpose,
        amenities,
        unitStatus,
        projectId,
        builderId,
        ownerId,
        minPrice,
        maxPrice,
        minArea,
        maxArea,
        minBedrooms,
        maxBedrooms,
        facingDirection,
        isNaApproved,
        isVerifiedOnly,
        isFeaturedOnly,
        status,
        sortBy,
        limit,
        offset,
      ];
}

class AISearchIntentEntity extends Equatable {
  final String originalPrompt;
  final SearchQueryEntity extractedQuery;
  final List<String> vectorSearchTerms;
  final double confidenceScore;

  const AISearchIntentEntity({
    required this.originalPrompt,
    required this.extractedQuery,
    this.vectorSearchTerms = const [],
    this.confidenceScore = 1.0,
  });

  @override
  List<Object?> get props => [
        originalPrompt,
        extractedQuery,
        vectorSearchTerms,
        confidenceScore,
      ];
}

class SearchResultEntity extends Equatable {
  final List<PropertyEntity> properties;
  final int totalCount;
  final int limit;
  final int offset;
  final bool hasMore;
  final AISearchIntentEntity? aiIntent;

  const SearchResultEntity({
    required this.properties,
    required this.totalCount,
    this.limit = 20,
    this.offset = 0,
    this.hasMore = false,
    this.aiIntent,
  });

  @override
  List<Object?> get props => [properties, totalCount, limit, offset, hasMore, aiIntent];
}
