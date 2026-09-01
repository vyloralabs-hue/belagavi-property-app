import 'package:equatable/equatable.dart';

enum UnitAvailabilityStatus {
  available,
  reserved,
  sold,
  blocked,
}

class UnitInventoryEntity extends Equatable {
  final String id;
  final String projectId;
  final String towerId;
  final String unitNumber;
  final int floorNumber;
  final String unitType;
  final double carpetArea;
  final double builtUpArea;
  final double price;
  final UnitAvailabilityStatus availabilityStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitInventoryEntity({
    required this.id,
    required this.projectId,
    required this.towerId,
    required this.unitNumber,
    required this.floorNumber,
    required this.unitType,
    required this.carpetArea,
    required this.builtUpArea,
    required this.price,
    this.availabilityStatus = UnitAvailabilityStatus.available,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        towerId,
        unitNumber,
        floorNumber,
        unitType,
        carpetArea,
        builtUpArea,
        price,
        availabilityStatus,
        createdAt,
        updatedAt,
      ];
}
