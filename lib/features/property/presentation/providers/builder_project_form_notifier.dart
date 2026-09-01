import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/builder_repository.dart';

enum BuilderProjectFormStatus { initial, editing, saving, saved, error }

class BuilderProjectFormState extends Equatable {
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
  final String exactLocation;
  final String? reraNumber;
  final DateTime? possessionDate;
  final double startingPrice;
  final int totalTowers;
  final int totalUnits;
  final int currentStep;
  final BuilderProjectFormStatus formStatus;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const BuilderProjectFormState({
    required this.id,
    required this.builderId,
    this.projectName = '',
    this.description = '',
    this.projectType = ProjectType.apartment,
    this.status = ProjectStatus.underConstruction,
    this.country = 'India',
    this.state = 'Karnataka',
    this.district = 'Belagavi',
    this.city = 'Belagavi',
    this.locality = '',
    this.approximateLocation = '',
    this.exactLocation = '',
    this.reraNumber,
    this.possessionDate,
    this.startingPrice = 0.0,
    this.totalTowers = 1,
    this.totalUnits = 0,
    this.currentStep = 0,
    this.formStatus = BuilderProjectFormStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  BuilderProjectFormState copyWith({
    String? id,
    String? builderId,
    String? projectName,
    String? description,
    ProjectType? projectType,
    ProjectStatus? status,
    String? country,
    String? state,
    String? district,
    String? city,
    String? locality,
    String? approximateLocation,
    String? exactLocation,
    String? reraNumber,
    DateTime? possessionDate,
    double? startingPrice,
    int? totalTowers,
    int? totalUnits,
    int? currentStep,
    BuilderProjectFormStatus? formStatus,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return BuilderProjectFormState(
      id: id ?? this.id,
      builderId: builderId ?? this.builderId,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      approximateLocation: approximateLocation ?? this.approximateLocation,
      exactLocation: exactLocation ?? this.exactLocation,
      reraNumber: reraNumber ?? this.reraNumber,
      possessionDate: possessionDate ?? this.possessionDate,
      startingPrice: startingPrice ?? this.startingPrice,
      totalTowers: totalTowers ?? this.totalTowers,
      totalUnits: totalUnits ?? this.totalUnits,
      currentStep: currentStep ?? this.currentStep,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  ProjectEntity toEntity(String authBuilderId) {
    return ProjectEntity(
      id: id.isEmpty ? 'proj_${DateTime.now().millisecondsSinceEpoch}' : id,
      builderId: authBuilderId,
      projectName: projectName,
      description: description,
      projectType: projectType,
      status: status,
      country: country,
      state: state,
      district: district,
      city: city,
      locality: locality,
      approximateLocation: locality.isNotEmpty ? '$locality, $city' : city,
      exactLocation: exactLocation,
      reraNumber: reraNumber,
      possessionDate: possessionDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

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
        startingPrice,
        totalTowers,
        totalUnits,
        currentStep,
        formStatus,
        errorMessage,
        fieldErrors,
      ];
}

class BuilderProjectFormNotifier extends StateNotifier<BuilderProjectFormState> {
  final BuilderRepository _repository;

  BuilderProjectFormNotifier(this._repository)
      : super(BuilderProjectFormState(
          id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
          builderId: '',
        ));

  void initForNewProject(String builderId) {
    state = BuilderProjectFormState(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      builderId: builderId,
    );
  }

  void initForEditing(ProjectEntity project) {
    state = BuilderProjectFormState(
      id: project.id,
      builderId: project.builderId,
      projectName: project.projectName,
      description: project.description,
      projectType: project.projectType,
      status: project.status,
      country: project.country,
      state: project.state,
      district: project.district,
      city: project.city,
      locality: project.locality,
      approximateLocation: project.approximateLocation,
      exactLocation: project.exactLocation,
      reraNumber: project.reraNumber,
      possessionDate: project.possessionDate,
      formStatus: BuilderProjectFormStatus.editing,
    );
  }

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  void updateBasicDetails({
    String? projectName,
    String? description,
    ProjectType? projectType,
    ProjectStatus? status,
    double? startingPrice,
    String? reraNumber,
  }) {
    state = state.copyWith(
      projectName: projectName ?? state.projectName,
      description: description ?? state.description,
      projectType: projectType ?? state.projectType,
      status: status ?? state.status,
      startingPrice: startingPrice ?? state.startingPrice,
      reraNumber: reraNumber ?? state.reraNumber,
      fieldErrors: Map.from(state.fieldErrors)..remove('projectName'),
    );
  }

  void updateLocation({
    String? country,
    String? stateName,
    String? district,
    String? city,
    String? locality,
    String? exactLocation,
  }) {
    state = state.copyWith(
      country: country ?? state.country,
      state: stateName ?? state.state,
      district: district ?? state.district,
      city: city ?? state.city,
      locality: locality ?? state.locality,
      exactLocation: exactLocation ?? state.exactLocation,
      fieldErrors: Map.from(state.fieldErrors)..remove('locality'),
    );
  }

  void updateConfiguration({
    int? totalTowers,
    int? totalUnits,
    DateTime? possessionDate,
  }) {
    state = state.copyWith(
      totalTowers: totalTowers ?? state.totalTowers,
      totalUnits: totalUnits ?? state.totalUnits,
      possessionDate: possessionDate ?? state.possessionDate,
    );
  }

  bool validateStep(int step) {
    final errors = <String, String>{};
    if (step == 0) {
      if (state.projectName.trim().isEmpty) {
        errors['projectName'] = 'Project name is required';
      }
    } else if (step == 1) {
      if (state.locality.trim().isEmpty) {
        errors['locality'] = 'Locality / Area is required';
      }
    }
    state = state.copyWith(fieldErrors: errors);
    return errors.isEmpty;
  }

  Future<bool> saveProject(String authenticatedUserId) async {
    if (!validateStep(0) || !validateStep(1)) {
      state = state.copyWith(
        formStatus: BuilderProjectFormStatus.error,
        errorMessage: 'Please fill in all required fields.',
      );
      return false;
    }

    state = state.copyWith(formStatus: BuilderProjectFormStatus.saving);

    final project = state.toEntity(authenticatedUserId);
    final result = await _repository.createProject(
      project,
      authenticatedUserId: authenticatedUserId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          formStatus: BuilderProjectFormStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (savedProject) {
        state = state.copyWith(
          id: savedProject.id,
          formStatus: BuilderProjectFormStatus.saved,
        );
        return true;
      },
    );
  }
}
