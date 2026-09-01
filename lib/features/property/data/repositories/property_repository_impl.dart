import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_remote_datasource.dart';
import '../models/property_models.dart';

@LazySingleton(as: PropertyRepository)
class PropertyRepositoryImpl extends BaseRepository implements PropertyRepository {
  final PropertyRemoteDataSource _remoteDataSource;

  PropertyRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<PropertyEntity>> getProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(
      () => _remoteDataSource.fetchProperties(
        category: category,
        type: type,
        city: city,
        locality: locality,
        minPrice: minPrice,
        maxPrice: maxPrice,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  FutureEither<List<PropertyEntity>> getPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) async {
    return safeCall(
      () => _remoteDataSource.fetchPropertiesByOwner(
        ownerId: ownerId,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  FutureEither<List<PropertyEntity>> getAllPropertiesForAdmin({
    required String authenticatedUserId,
    UserRole? userRole,
    int limit = 100,
    int offset = 0,
  }) async {
    return safeCall(
      () => _remoteDataSource.fetchAllPropertiesForAdmin(
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  FutureEither<PropertyEntity?> getPropertyById(
    String id, {
    String? requestingUserId,
    List<PropertyUnlockEntity>? userUnlocks,
  }) async {
    return safeCall(
      () => _remoteDataSource.fetchPropertyById(
        id,
        requestingUserId: requestingUserId,
        userUnlocks: userUnlocks,
      ),
    );
  }

  @override
  FutureEither<PropertyEntity> createProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
  }) async {
    return safeCall(() async {
      final model = PropertyModel(
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
        address: property.address,
        pincode: property.pincode,
        latitude: property.latitude,
        longitude: property.longitude,
        viewsCount: property.viewsCount,
        features: property.features,
        createdAt: property.createdAt,
        updatedAt: property.updatedAt,
      );
      return await _remoteDataSource.createProperty(
        model,
        authenticatedUserId: authenticatedUserId,
      );
    });
  }

  @override
  FutureEither<PropertyEntity> updateProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() async {
      final model = PropertyModel(
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
        address: property.address,
        pincode: property.pincode,
        latitude: property.latitude,
        longitude: property.longitude,
        viewsCount: property.viewsCount,
        features: property.features,
        createdAt: property.createdAt,
        updatedAt: property.updatedAt,
      );
      return await _remoteDataSource.updateProperty(
        model,
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
      );
    });
  }

  @override
  FutureEither<PropertyEntity> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(
      () => _remoteDataSource.updatePropertyStatus(
        propertyId: propertyId,
        newStatus: newStatus,
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
      ),
    );
  }

  @override
  FutureEither<void> deleteProperty(
    String id, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(
      () => _remoteDataSource.deleteProperty(
        id,
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
      ),
    );
  }

  @override
  FutureEither<AIPropertyAnalysisEntity> analyzePropertyWithAI(PropertyEntity property) async {
    return safeCall(() async {
      double score = 75.0;
      if (property.mediaList.isNotEmpty) score += 15.0;
      if (property.description.length > 100) score += 10.0;

      return AIPropertyAnalysisEntity(
        qualityScore: score.clamp(0.0, 100.0),
        isDuplicate: false,
        suggestedDescription:
            'AI Enhanced: Beautiful ${property.type.name} located in prime ${property.locality}, ${property.city}. Offered at ₹${property.price}.',
        suggestedCategory: property.category,
        similarPropertyIds: const [],
      );
    });
  }
}
