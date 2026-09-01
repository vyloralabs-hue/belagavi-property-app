import '../domain/entities/search_entities.dart';

class AdvancedPropertyFilterEngine {
  AdvancedPropertyFilterEngine._();

  /// Validates search query parameters and constructs clean filter criteria.
  /// Ensures min <= max for price and area ranges, clamps pagination, and preserves all fields.
  static SearchQueryEntity sanitize(SearchQueryEntity query) {
    double? minP = query.minPrice;
    double? maxP = query.maxPrice;
    if (minP != null && maxP != null && minP > maxP) {
      final temp = minP;
      minP = maxP;
      maxP = temp;
    }

    double? minA = query.minArea;
    double? maxA = query.maxArea;
    if (minA != null && maxA != null && minA > maxA) {
      final temp = minA;
      minA = maxA;
      maxA = temp;
    }

    return SearchQueryEntity(
      rawQuery: query.rawQuery?.trim().isEmpty == true ? null : query.rawQuery?.trim(),
      country: query.country?.trim(),
      state: query.state?.trim().isEmpty == true ? null : query.state?.trim(),
      district: query.district?.trim().isEmpty == true ? null : query.district?.trim(),
      city: query.city?.trim().isEmpty == true ? null : query.city?.trim(),
      locality: query.locality?.trim().isEmpty == true ? null : query.locality?.trim(),
      area: query.area?.trim().isEmpty == true ? null : query.area?.trim(),
      pincode: query.pincode?.trim().isEmpty == true ? null : query.pincode?.trim(),
      category: query.category,
      type: query.type,
      purpose: query.purpose,
      amenities: query.amenities,
      unitStatus: query.unitStatus,
      projectId: query.projectId,
      builderId: query.builderId,
      ownerId: query.ownerId,
      minPrice: minP,
      maxPrice: maxP,
      minArea: minA,
      maxArea: maxA,
      minBedrooms: query.minBedrooms,
      maxBedrooms: query.maxBedrooms,
      facingDirection: query.facingDirection,
      isNaApproved: query.isNaApproved,
      isVerifiedOnly: query.isVerifiedOnly,
      isFeaturedOnly: query.isFeaturedOnly,
      status: query.status,
      sortBy: query.sortBy,
      limit: query.limit.clamp(1, 100),
      offset: query.offset < 0 ? 0 : query.offset,
    );
  }
}
