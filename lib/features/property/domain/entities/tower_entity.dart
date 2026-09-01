import 'package:equatable/equatable.dart';

enum TowerStatus {
  planned,
  underConstruction,
  completed,
}

class TowerEntity extends Equatable {
  final String id;
  final String projectId;
  final String towerName;
  final int totalFloors;
  final TowerStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TowerEntity({
    required this.id,
    required this.projectId,
    required this.towerName,
    required this.totalFloors,
    this.status = TowerStatus.underConstruction,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        towerName,
        totalFloors,
        status,
        createdAt,
        updatedAt,
      ];
}
