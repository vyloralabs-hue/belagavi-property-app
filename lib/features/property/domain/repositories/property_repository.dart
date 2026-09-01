import '../../../../core/security/user_role.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/property_entities.dart';

abstract class PropertyRepository {
  FutureEither<List<PropertyEntity>> getProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  });

  FutureEither<List<PropertyEntity>> getPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  });

  FutureEither<List<PropertyEntity>> getAllPropertiesForAdmin({
    required String authenticatedUserId,
    UserRole? userRole,
    int limit = 100,
    int offset = 0,
  });

  FutureEither<PropertyEntity?> getPropertyById(
    String id, {
    String? requestingUserId,
    List<PropertyUnlockEntity>? userUnlocks,
  });

  FutureEither<PropertyEntity> createProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
  });

  FutureEither<PropertyEntity> updateProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<PropertyEntity> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<void> deleteProperty(
    String id, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<AIPropertyAnalysisEntity> analyzePropertyWithAI(PropertyEntity property);
}
