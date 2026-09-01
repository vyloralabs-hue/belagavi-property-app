import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/builder_repository.dart';

enum BuilderProjectListStatus { initial, loading, loaded, error }

class BuilderProjectListState extends Equatable {
  final List<ProjectEntity> projects;
  final BuilderProjectListStatus status;
  final String? errorMessage;

  const BuilderProjectListState({
    this.projects = const [],
    this.status = BuilderProjectListStatus.initial,
    this.errorMessage,
  });

  BuilderProjectListState copyWith({
    List<ProjectEntity>? projects,
    BuilderProjectListStatus? status,
    String? errorMessage,
  }) {
    return BuilderProjectListState(
      projects: projects ?? this.projects,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [projects, status, errorMessage];
}

class BuilderProjectListNotifier extends StateNotifier<BuilderProjectListState> {
  final BuilderRepository _repository;

  BuilderProjectListNotifier(this._repository) : super(const BuilderProjectListState());

  Future<void> fetchBuilderProjects(String builderId) async {
    state = state.copyWith(status: BuilderProjectListStatus.loading);
    final result = await _repository.getProjectsByBuilder(builderId);
    result.fold(
      (failure) => state = state.copyWith(
        status: BuilderProjectListStatus.error,
        errorMessage: failure.message,
      ),
      (list) => state = state.copyWith(
        projects: list,
        status: BuilderProjectListStatus.loaded,
      ),
    );
  }

  Future<bool> deleteProject({
    required String authenticatedUserId,
    required String projectId,
  }) async {
    final result = await _repository.deleteProject(
      projectId,
      authenticatedUserId: authenticatedUserId,
    );

    return result.fold(
      (failure) => false,
      (_) {
        final updated = state.projects.where((p) => p.id != projectId).toList();
        state = state.copyWith(projects: updated);
        return true;
      },
    );
  }
}
