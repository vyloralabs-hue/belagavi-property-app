import '../../../property/data/models/property_models.dart';
import '../../domain/entities/search_entities.dart';

class SearchQueryModel extends SearchQueryEntity {
  const SearchQueryModel({
    super.rawQuery,
    super.category,
    super.type,
    super.state,
    super.district,
    super.city,
    super.locality,
    super.pincode,
    super.minPrice,
    super.maxPrice,
    super.minBedrooms,
    super.maxBedrooms,
    super.facingDirection,
    super.isNaApproved,
    super.isVerifiedOnly,
    super.isFeaturedOnly,
    super.limit = 20,
    super.offset = 0,
  });

  @override
  Map<String, dynamic> toJson() => {
    'raw_query': rawQuery,
    'category': category?.name,
    'type': type?.name,
    'state': state,
    'district': district,
    'city': city,
    'locality': locality,
    'pincode': pincode,
    'min_price': minPrice,
    'max_price': maxPrice,
    'min_bedrooms': minBedrooms,
    'max_bedrooms': maxBedrooms,
    'facing_direction': facingDirection,
    'is_na_approved': isNaApproved,
    'is_verified_only': isVerifiedOnly,
    'is_featured_only': isFeaturedOnly,
    'limit': limit,
    'offset': offset,
  };
}

class SearchResultModel extends SearchResultEntity {
  const SearchResultModel({
    required List<PropertyModel> properties,
    required super.totalCount,
    super.hasMore = false,
    super.aiIntent,
  }) : super(properties: properties);
}
