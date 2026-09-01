import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.builderId,
    required super.projectName,
    required super.description,
    required super.projectType,
    super.status = ProjectStatus.underConstruction,
    required super.country,
    required super.state,
    required super.district,
    required super.city,
    required super.locality,
    required super.approximateLocation,
    required super.exactLocation,
    super.reraNumber,
    super.possessionDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      builderId: json['builder_id'] as String? ?? '',
      projectName: json['project_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      projectType: ProjectType.values.firstWhere(
        (e) => e.name == json['project_type'],
        orElse: () => ProjectType.apartment,
      ),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.underConstruction,
      ),
      country: json['country'] as String? ?? 'India',
      state: json['state'] as String? ?? 'Karnataka',
      district: json['district'] as String? ?? 'Belagavi',
      city: json['city'] as String? ?? 'Belagavi',
      locality: json['locality'] as String? ?? '',
      approximateLocation: json['approximate_location'] as String? ?? '',
      exactLocation: json['exact_location'] as String? ?? '',
      reraNumber: json['rera_number'] as String?,
      possessionDate: json['possession_date'] != null
          ? DateTime.parse(json['possession_date'] as String)
          : null,
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
        'builder_id': builderId,
        'project_name': projectName,
        'description': description,
        'project_type': projectType.name,
        'status': status.name,
        'country': country,
        'state': state,
        'district': district,
        'city': city,
        'locality': locality,
        'approximate_location': approximateLocation,
        'exact_location': exactLocation,
        'rera_number': reraNumber,
        'possession_date': possessionDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
