import '../../domain/entities/tower_entity.dart';

class TowerModel extends TowerEntity {
  const TowerModel({
    required super.id,
    required super.projectId,
    required super.towerName,
    required super.totalFloors,
    super.status = TowerStatus.underConstruction,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TowerModel.fromJson(Map<String, dynamic> json) {
    return TowerModel(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      towerName: json['tower_name'] as String? ?? '',
      totalFloors: json['total_floors'] as int? ?? 1,
      status: TowerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TowerStatus.underConstruction,
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
        'tower_name': towerName,
        'total_floors': totalFloors,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
