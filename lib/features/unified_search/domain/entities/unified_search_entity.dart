import 'package:equatable/equatable.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/local_shops/domain/entities/business_entities.dart';
import 'package:belagavi_property/features/local_shops/utils/business_location_resolver.dart';

enum UnifiedSearchResultType { property, business, location, category }

enum UnifiedSearchMode { all, properties, shops, locations }

class UnifiedSearchResultEntity extends Equatable {
  final String id;
  final UnifiedSearchResultType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String locationLabel;
  final String categoryName;
  final double relevanceScore;
  final PropertyEntity? propertyEntity;
  final BusinessEntity? businessEntity;
  final ResolvedBusinessLocation? resolvedLocation;

  const UnifiedSearchResultEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.locationLabel,
    required this.categoryName,
    this.relevanceScore = 1.0,
    this.propertyEntity,
    this.businessEntity,
    this.resolvedLocation,
  });

  factory UnifiedSearchResultEntity.fromProperty(PropertyEntity property) {
    return UnifiedSearchResultEntity(
      id: property.id,
      type: UnifiedSearchResultType.property,
      title: property.title,
      subtitle: '${property.locality}, ${property.city} • ₹${property.price}',
      imageUrl: property.mediaList.isNotEmpty ? property.mediaList.first.mediaUrl : null,
      locationLabel: '${property.locality}, ${property.city}',
      categoryName: property.category.name.toUpperCase(),
      propertyEntity: property,
    );
  }

  factory UnifiedSearchResultEntity.fromBusiness(BusinessEntity business) {
    return UnifiedSearchResultEntity(
      id: business.id,
      type: UnifiedSearchResultType.business,
      title: business.name,
      subtitle: '${business.address} • ${business.openingHours}',
      imageUrl: business.photos.isNotEmpty ? business.photos.first : null,
      locationLabel: business.address,
      categoryName: business.categoryId,
      businessEntity: business,
    );
  }

  factory UnifiedSearchResultEntity.fromLocation(ResolvedBusinessLocation loc) {
    return UnifiedSearchResultEntity(
      id: 'loc_${loc.cityId}_${loc.localityId}',
      type: UnifiedSearchResultType.location,
      title: loc.displayLabel,
      subtitle: 'Location in India Geography Hierarchy',
      locationLabel: loc.displayLabel,
      categoryName: 'LOCATION',
      resolvedLocation: loc,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        subtitle,
        imageUrl,
        locationLabel,
        categoryName,
        relevanceScore,
        propertyEntity,
        businessEntity,
        resolvedLocation,
      ];
}
