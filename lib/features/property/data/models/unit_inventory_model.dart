import '../../domain/entities/unit_inventory_entity.dart';

class UnitInventoryModel extends UnitInventoryEntity {
  const UnitInventoryModel({
    required super.id,
    required super.projectId,
    required super.towerId,
    required super.unitNumber,
    required super.floorNumber,
    required super.unitType,
    required super.carpetArea,
    required super.builtUpArea,
    required super.price,
    super.availabilityStatus = UnitAvailabilityStatus.available,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UnitInventoryModel.fromJson(Map<String, dynamic> json) {
    return UnitInventoryModel(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      towerId: json['tower_id'] as String? ?? '',
      unitNumber: json['unit_number'] as String? ?? '',
      floorNumber: json['floor_number'] as int? ?? 1,
      unitType: json['unit_type'] as String? ?? '2BHK',
      carpetArea: (json['carpet_area'] as num?)?.toDouble() ?? 0.0,
      builtUpArea: (json['built_up_area'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      availabilityStatus: UnitAvailabilityStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['availability_status'] as String? ?? '').toLowerCase(),
        orElse: () => UnitAvailabilityStatus.available,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'tower_id': towerId,
        'unit_number': unitNumber,
        'floor_number': floorNumber,
        'unit_type': unitType,
        'carpet_area': carpetArea,
        'built_up_area': builtUpArea,
        'price': price,
        'availability_status': availabilityStatus.name.toUpperCase(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
