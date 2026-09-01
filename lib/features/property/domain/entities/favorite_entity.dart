import 'package:equatable/equatable.dart';
import 'property_entities.dart';

class FavoritePropertyEntity extends Equatable {
  final String id;
  final String propertyId;
  final PropertyEntity property;
  final DateTime addedAt;

  const FavoritePropertyEntity({
    required this.id,
    required this.propertyId,
    required this.property,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'property': {
        'id': property.id,
        'ownerId': property.ownerId,
        'title': property.title,
        'description': property.description,
        'category': property.category.name,
        'type': property.type.name,
        'status': property.status.name,
        'price': property.price,
        'state': property.state,
        'district': property.district,
        'city': property.city,
        'locality': property.locality,
        'address': property.address,
        'pincode': property.pincode,
        'createdAt': property.createdAt.toIso8601String(),
        'updatedAt': property.updatedAt.toIso8601String(),
      },
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, propertyId, property, addedAt];
}
