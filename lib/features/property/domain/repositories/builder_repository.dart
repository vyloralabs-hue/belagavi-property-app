import '../../../../core/utils/typedefs.dart';
import '../entities/project_entity.dart';
import '../entities/tower_entity.dart';
import '../entities/unit_inventory_entity.dart';

abstract class BuilderRepository {
  FutureEither<ProjectEntity> createProject(
    ProjectEntity project, {
    required String authenticatedUserId,
  });

  FutureEither<ProjectEntity> updateProject(
    ProjectEntity project, {
    required String authenticatedUserId,
  });

  FutureEither<void> deleteProject(
    String projectId, {
    required String authenticatedUserId,
  });

  FutureEither<List<ProjectEntity>> getProjectsByBuilder(String builderId);

  FutureEither<ProjectEntity?> getProjectById(String projectId);

  FutureEither<TowerEntity> createTower(
    TowerEntity tower, {
    required String authenticatedUserId,
  });

  FutureEither<TowerEntity> updateTower(
    TowerEntity tower, {
    required String authenticatedUserId,
  });

  FutureEither<void> deleteTower(
    String towerId, {
    required String authenticatedUserId,
  });

  FutureEither<List<TowerEntity>> getTowersByProject(String projectId);

  FutureEither<UnitInventoryEntity> createUnit(
    UnitInventoryEntity unit, {
    required String authenticatedUserId,
  });

  FutureEither<List<UnitInventoryEntity>> bulkCreateUnits(
    List<UnitInventoryEntity> units, {
    required String authenticatedUserId,
  });

  FutureEither<UnitInventoryEntity> updateUnit(
    UnitInventoryEntity unit, {
    required String authenticatedUserId,
  });

  FutureEither<void> deleteUnit(
    String unitId, {
    required String authenticatedUserId,
  });

  FutureEither<List<UnitInventoryEntity>> getUnitsByProject(
    String projectId, {
    String? towerId,
    String? unitType,
    UnitAvailabilityStatus? statusFilter,
    int limit = 500,
    int offset = 0,
  });

  FutureEither<bool> checkUnitNumberExists({
    required String projectId,
    required String towerId,
    required String unitNumber,
  });
}
