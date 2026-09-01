import '../data/models/property_models.dart';
import '../domain/entities/property_entities.dart';

class LocationPrivacyHelper {
  LocationPrivacyHelper._();

  /// Returns a fuzzy coordinate for public map markers (approximate locality center).
  static double? sanitizeCoordinate(double? coordinate) {
    if (coordinate == null) return null;
    return (coordinate * 100).roundToDouble() / 100;
  }

  /// Sanitizes a property for public / non-unlocked viewing.
  static PropertyEntity toPublicPropertyEntity(PropertyEntity property) {
    final sanitizedFeatures = Map<String, dynamic>.from(property.features)
      ..remove('ownerPhone')
      ..remove('ownerEmail')
      ..remove('ownerWhatsApp')
      ..remove('exactAddress')
      ..remove('privateDocuments');

    return PropertyEntity(
      id: property.id,
      ownerId: property.ownerId,
      title: property.title,
      description: property.description,
      category: property.category,
      type: property.type,
      status: property.status,
      verificationStatus: property.verificationStatus,
      price: property.price,
      isNegotiable: property.isNegotiable,
      specifications: property.specifications,
      mediaList: property.mediaList,
      state: property.state,
      district: property.district,
      taluk: property.taluk,
      city: property.city,
      locality: property.locality,
      address: '', // Protected: hidden for public
      pincode: '', // Protected: hidden for public
      latitude: sanitizeCoordinate(property.latitude), // Approximate locality marker
      longitude: sanitizeCoordinate(property.longitude), // Approximate locality marker
      viewsCount: property.viewsCount,
      features: sanitizedFeatures,
      createdAt: property.createdAt,
      updatedAt: property.updatedAt,
    );
  }

  /// Sanitizes a PropertyModel for public / non-unlocked viewing.
  static PropertyModel toPublicPropertyModel(PropertyModel property) {
    final sanitizedFeatures = Map<String, dynamic>.from(property.features)
      ..remove('ownerPhone')
      ..remove('ownerEmail')
      ..remove('ownerWhatsApp')
      ..remove('exactAddress')
      ..remove('privateDocuments');

    return PropertyModel(
      id: property.id,
      ownerId: property.ownerId,
      title: property.title,
      description: property.description,
      category: property.category,
      type: property.type,
      status: property.status,
      verificationStatus: property.verificationStatus,
      price: property.price,
      isNegotiable: property.isNegotiable,
      specifications: property.specifications,
      mediaList: property.mediaList,
      state: property.state,
      district: property.district,
      taluk: property.taluk,
      city: property.city,
      locality: property.locality,
      address: '',
      pincode: '',
      latitude: sanitizeCoordinate(property.latitude),
      longitude: sanitizeCoordinate(property.longitude),
      viewsCount: property.viewsCount,
      features: sanitizedFeatures,
      createdAt: property.createdAt,
      updatedAt: property.updatedAt,
    );
  }
}
