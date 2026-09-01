import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/tower_entity.dart';
import '../../domain/entities/unit_inventory_entity.dart';
import '../../domain/repositories/builder_repository.dart';
import '../../utils/property_security_guard.dart';

class BuilderRepositoryImpl implements BuilderRepository {
  final Map<String, ProjectEntity> _projects = {};
  final Map<String, TowerEntity> _towers = {};
  final Map<String, UnitInventoryEntity> _units = {};

  @override
  FutureEither<ProjectEntity> createProject(
    ProjectEntity project, {
    required String authenticatedUserId,
  }) async {
    try {
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: project.builderId,
        actionName: 'create this builder project',
      );
      _projects[project.id] = project;
      return right(project);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<ProjectEntity> updateProject(
    ProjectEntity project, {
    required String authenticatedUserId,
  }) async {
    try {
      final existing = _projects[project.id];
      final builderId = existing?.builderId ?? project.builderId;
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'update this builder project',
      );
      _projects[project.id] = project;
      return right(project);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteProject(
    String projectId, {
    required String authenticatedUserId,
  }) async {
    try {
      final existing = _projects[projectId];
      if (existing == null) {
        return left(const ServerFailure('Project not found'));
      }
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: existing.builderId,
        actionName: 'delete this builder project',
      );

      _projects.remove(projectId);
      _towers.removeWhere((_, t) => t.projectId == projectId);
      _units.removeWhere((_, u) => u.projectId == projectId);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<ProjectEntity>> getProjectsByBuilder(String builderId) async {
    try {
      final list = _projects.values.where((p) => p.builderId == builderId).toList();
      return right(list);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<ProjectEntity?> getProjectById(String projectId) async {
    try {
      return right(_projects[projectId]);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<TowerEntity> createTower(
    TowerEntity tower, {
    required String authenticatedUserId,
  }) async {
    try {
      final project = _projects[tower.projectId];
      final builderId = project?.builderId ?? authenticatedUserId;
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'add a tower to this project',
      );
      _towers[tower.id] = tower;
      return right(tower);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<TowerEntity> updateTower(
    TowerEntity tower, {
    required String authenticatedUserId,
  }) async {
    try {
      final project = _projects[tower.projectId];
      final builderId = project?.builderId ?? authenticatedUserId;
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'update this tower',
      );
      _towers[tower.id] = tower;
      return right(tower);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteTower(
    String towerId, {
    required String authenticatedUserId,
  }) async {
    try {
      final existing = _towers[towerId];
      if (existing == null) {
        return left(const ServerFailure('Tower not found'));
      }
      final project = _projects[existing.projectId];
      final builderId = project?.builderId ?? authenticatedUserId;
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'delete this tower',
      );

      _towers.remove(towerId);
      _units.removeWhere((_, u) => u.towerId == towerId);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<TowerEntity>> getTowersByProject(String projectId) async {
    try {
      final list = _towers.values.where((t) => t.projectId == projectId).toList();
      return right(list);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<UnitInventoryEntity> createUnit(
    UnitInventoryEntity unit, {
    required String authenticatedUserId,
  }) async {
    try {
      final project = _projects[unit.projectId];
      final builderId = project?.builderId ?? authenticatedUserId;
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'create unit inventory',
      );

      final exists = _units.values.any((u) =>
          u.projectId == unit.projectId &&
          u.towerId == unit.towerId &&
          u.unitNumber.toLowerCase() == unit.unitNumber.toLowerCase());

      if (exists) {
        return left(ServerFailure('Duplicate unit number "${unit.unitNumber}" already exists in this tower.'));
      }

      _units[unit.id] = unit;
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<UnitInventoryEntity>> bulkCreateUnits(
    List<UnitInventoryEntity> units, {
    required String authenticatedUserId,
  }) async {
    try {
      if (units.isEmpty) return right([]);
      final projectId = units.first.projectId;
      final project = _projects[projectId];
      final builderId = project?.builderId ?? authenticatedUserId;

      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'bulk create unit inventory',
      );

      final created = <UnitInventoryEntity>[];
      for (final unit in units) {
        final exists = _units.values.any((u) =>
            u.projectId == unit.projectId &&
            u.towerId == unit.towerId &&
            u.unitNumber.toLowerCase() == unit.unitNumber.toLowerCase());
        if (!exists) {
          _units[unit.id] = unit;
          created.add(unit);
        }
      }
      return right(created);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<UnitInventoryEntity> updateUnit(
    UnitInventoryEntity unit, {
    required String authenticatedUserId,
  }) async {
    try {
      final project = _projects[unit.projectId];
      final builderId = project?.builderId ?? authenticatedUserId;
      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'update unit inventory',
      );

      _units[unit.id] = unit;
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteUnit(
    String unitId, {
    required String authenticatedUserId,
  }) async {
    try {
      final existing = _units[unitId];
      if (existing == null) {
        return left(const ServerFailure('Unit not found'));
      }
      final project = _projects[existing.projectId];
      final builderId = project?.builderId ?? authenticatedUserId;

      PropertySecurityGuard.verifyProjectOwnership(
        authenticatedUserId: authenticatedUserId,
        builderId: builderId,
        actionName: 'delete unit inventory',
      );

      _units.remove(unitId);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<UnitInventoryEntity>> getUnitsByProject(
    String projectId, {
    String? towerId,
    String? unitType,
    UnitAvailabilityStatus? statusFilter,
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      var list = _units.values.where((u) => u.projectId == projectId);
      if (towerId != null && towerId.isNotEmpty) {
        list = list.where((u) => u.towerId == towerId);
      }
      if (unitType != null && unitType.isNotEmpty && unitType != 'All') {
        list = list.where((u) => u.unitType == unitType);
      }
      if (statusFilter != null) {
        list = list.where((u) => u.availabilityStatus == statusFilter);
      }
      final result = list.skip(offset).take(limit).toList();
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<bool> checkUnitNumberExists({
    required String projectId,
    required String towerId,
    required String unitNumber,
  }) async {
    try {
      final exists = _units.values.any((u) =>
          u.projectId == projectId &&
          u.towerId == towerId &&
          u.unitNumber.toLowerCase() == unitNumber.toLowerCase());
      return right(exists);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
