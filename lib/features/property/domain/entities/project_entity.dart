import 'package:equatable/equatable.dart';

enum ProjectType {
  apartment,
  gatedCommunity,
  villaProject,
  commercialComplex,
  mixedUse,
}

enum ProjectStatus {
  upcoming,
  underConstruction,
  readyToMove,
  completed,
}

class ProjectEntity extends Equatable {
  final String id;
  final String builderId;
  final String projectName;
  final String description;
  final ProjectType projectType;
  final ProjectStatus status;
  final String country;
  final String state;
  final String district;
  final String city;
  final String locality;
  final String approximateLocation;
  final String exactLocation; // Protected location field
  final String? reraNumber;
  final DateTime? possessionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectEntity({
    required this.id,
    required this.builderId,
    required this.projectName,
    required this.description,
    required this.projectType,
    this.status = ProjectStatus.underConstruction,
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.locality,
    required this.approximateLocation,
    required this.exactLocation,
    this.reraNumber,
    this.possessionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        builderId,
        projectName,
        description,
        projectType,
        status,
        country,
        state,
        district,
        city,
        locality,
        approximateLocation,
        exactLocation,
        reraNumber,
        possessionDate,
        createdAt,
        updatedAt,
      ];
}
