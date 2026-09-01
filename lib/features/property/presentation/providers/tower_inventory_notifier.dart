import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/tower_entity.dart';
import '../../domain/entities/unit_inventory_entity.dart';
import '../../domain/repositories/builder_repository.dart';

enum TowerInventoryStatus { initial, loading, loaded, saving, error }

class TowerInventoryState extends Equatable {
  final String projectId;
  final List<TowerEntity> towers;
  final List<UnitInventoryEntity> units;
  final String? selectedTowerId;
  final String selectedUnitType; // 'All', '1 BHK', '2 BHK', etc.
  final UnitAvailabilityStatus? selectedStatusFilter;
  final TowerInventoryStatus status;
  final String? errorMessage;
  final String? lastGeneratedMessage;

  const TowerInventoryState({
    this.projectId = '',
    this.towers = const [],
    this.units = const [],
    this.selectedTowerId,
    this.selectedUnitType = 'All',
    this.selectedStatusFilter,
    this.status = TowerInventoryStatus.initial,
    this.errorMessage,
    this.lastGeneratedMessage,
  });

  TowerInventoryState copyWith({
    String? projectId,
    List<TowerEntity>? towers,
    List<UnitInventoryEntity>? units,
    String? selectedTowerId,
    String? selectedUnitType,
    UnitAvailabilityStatus? selectedStatusFilter,
    TowerInventoryStatus? status,
    String? errorMessage,
    String? lastGeneratedMessage,
  }) {
    return TowerInventoryState(
      projectId: projectId ?? this.projectId,
      towers: towers ?? this.towers,
      units: units ?? this.units,
      selectedTowerId: selectedTowerId ?? this.selectedTowerId,
      selectedUnitType: selectedUnitType ?? this.selectedUnitType,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastGeneratedMessage: lastGeneratedMessage ?? this.lastGeneratedMessage,
    );
  }

  List<UnitInventoryEntity> get filteredUnits {
    return units.where((u) {
      if (selectedTowerId != null && selectedTowerId!.isNotEmpty && u.towerId != selectedTowerId) {
        return false;
      }
      if (selectedUnitType != 'All' && u.unitType != selectedUnitType) {
        return false;
      }
      if (selectedStatusFilter != null && u.availabilityStatus != selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  int get countAvailable => units.where((u) => u.availabilityStatus == UnitAvailabilityStatus.available).length;
  int get countReserved => units.where((u) => u.availabilityStatus == UnitAvailabilityStatus.reserved).length;
  int get countSold => units.where((u) => u.availabilityStatus == UnitAvailabilityStatus.sold).length;
  int get countBlocked => units.where((u) => u.availabilityStatus == UnitAvailabilityStatus.blocked).length;

  @override
  List<Object?> get props => [
        projectId,
        towers,
        units,
        selectedTowerId,
        selectedUnitType,
        selectedStatusFilter,
        status,
        errorMessage,
        lastGeneratedMessage,
      ];
}

class TowerInventoryNotifier extends StateNotifier<TowerInventoryState> {
  final BuilderRepository _repository;

  TowerInventoryNotifier(this._repository) : super(const TowerInventoryState());

  Future<void> loadProjectData(String projectId) async {
    state = state.copyWith(projectId: projectId, status: TowerInventoryStatus.loading);

    final towersResult = await _repository.getTowersByProject(projectId);
    final unitsResult = await _repository.getUnitsByProject(projectId);

    towersResult.fold(
      (failure) => state = state.copyWith(status: TowerInventoryStatus.error, errorMessage: failure.message),
      (towers) {
        unitsResult.fold(
          (failure) => state = state.copyWith(status: TowerInventoryStatus.error, errorMessage: failure.message),
          (units) {
            state = state.copyWith(
              projectId: projectId,
              towers: towers,
              units: units,
              status: TowerInventoryStatus.loaded,
            );
          },
        );
      },
    );
  }

  void filterByTower(String? towerId) {
    state = state.copyWith(selectedTowerId: towerId);
  }

  void filterByUnitType(String unitType) {
    state = state.copyWith(selectedUnitType: unitType);
  }

  void filterByStatus(UnitAvailabilityStatus? statusFilter) {
    state = state.copyWith(selectedStatusFilter: statusFilter);
  }

  Future<bool> addTower({
    required String authenticatedUserId,
    required String towerName,
    required int totalFloors,
  }) async {
    final newTower = TowerEntity(
      id: 'twr_${DateTime.now().millisecondsSinceEpoch}',
      projectId: state.projectId,
      towerName: towerName,
      totalFloors: totalFloors,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.createTower(newTower, authenticatedUserId: authenticatedUserId);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (savedTower) {
        final updatedTowers = List<TowerEntity>.from(state.towers)..add(savedTower);
        state = state.copyWith(towers: updatedTowers);
        return true;
      },
    );
  }

  Future<bool> addSingleUnit({
    required String authenticatedUserId,
    required String towerId,
    required String unitNumber,
    required int floorNumber,
    required String unitType,
    required double carpetArea,
    required double builtUpArea,
    required double price,
  }) async {
    final newUnit = UnitInventoryEntity(
      id: 'unit_${DateTime.now().millisecondsSinceEpoch}',
      projectId: state.projectId,
      towerId: towerId,
      unitNumber: unitNumber,
      floorNumber: floorNumber,
      unitType: unitType,
      carpetArea: carpetArea,
      builtUpArea: builtUpArea,
      price: price,
      availabilityStatus: UnitAvailabilityStatus.available,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.createUnit(newUnit, authenticatedUserId: authenticatedUserId);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (savedUnit) {
        final updatedUnits = List<UnitInventoryEntity>.from(state.units)..add(savedUnit);
        state = state.copyWith(units: updatedUnits, errorMessage: null);
        return true;
      },
    );
  }

  /// Bulk inventory generation with duplicate unit protection.
  Future<bool> bulkGenerateUnits({
    required String authenticatedUserId,
    required String towerId,
    required String towerPrefix,
    required int startFloor,
    required int endFloor,
    required int unitsPerFloor,
    required String unitType,
    required double carpetArea,
    required double builtUpArea,
    required double price,
  }) async {
    state = state.copyWith(status: TowerInventoryStatus.saving);

    final toCreate = <UnitInventoryEntity>[];
    int skippedDuplicates = 0;

    for (int fl = startFloor; fl <= endFloor; fl++) {
      for (int u = 1; u <= unitsPerFloor; u++) {
        final unitNoStr = '${towerPrefix.toUpperCase()}-${fl * 100 + u}';
        final exists = state.units.any((unit) =>
            unit.projectId == state.projectId &&
            unit.towerId == towerId &&
            unit.unitNumber.toLowerCase() == unitNoStr.toLowerCase());

        if (exists) {
          skippedDuplicates++;
          continue;
        }

        toCreate.add(UnitInventoryEntity(
          id: 'unit_${fl}_${u}_${DateTime.now().microsecondsSinceEpoch}',
          projectId: state.projectId,
          towerId: towerId,
          unitNumber: unitNoStr,
          floorNumber: fl,
          unitType: unitType,
          carpetArea: carpetArea,
          builtUpArea: builtUpArea,
          price: price,
          availabilityStatus: UnitAvailabilityStatus.available,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }

    if (toCreate.isEmpty) {
      state = state.copyWith(
        status: TowerInventoryStatus.loaded,
        lastGeneratedMessage: 'No new units created. All generated unit numbers already exist.',
      );
      return true;
    }

    final result = await _repository.bulkCreateUnits(toCreate, authenticatedUserId: authenticatedUserId);
    return result.fold(
      (failure) {
        state = state.copyWith(status: TowerInventoryStatus.error, errorMessage: failure.message);
        return false;
      },
      (createdList) {
        final updatedUnits = List<UnitInventoryEntity>.from(state.units)..addAll(createdList);
        final msg = 'Successfully created ${createdList.length} units.${skippedDuplicates > 0 ? ' Skipped $skippedDuplicates existing duplicates.' : ''}';
        state = state.copyWith(
          units: updatedUnits,
          status: TowerInventoryStatus.loaded,
          lastGeneratedMessage: msg,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> updateUnitStatus({
    required String authenticatedUserId,
    required String unitId,
    required UnitAvailabilityStatus targetStatus,
  }) async {
    final existingIndex = state.units.indexWhere((u) => u.id == unitId);
    if (existingIndex == -1) return false;

    final existing = state.units[existingIndex];
    final updated = UnitInventoryEntity(
      id: existing.id,
      projectId: existing.projectId,
      towerId: existing.towerId,
      unitNumber: existing.unitNumber,
      floorNumber: existing.floorNumber,
      unitType: existing.unitType,
      carpetArea: existing.carpetArea,
      builtUpArea: existing.builtUpArea,
      price: existing.price,
      availabilityStatus: targetStatus,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateUnit(updated, authenticatedUserId: authenticatedUserId);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (saved) {
        final updatedList = List<UnitInventoryEntity>.from(state.units);
        updatedList[existingIndex] = saved;
        state = state.copyWith(units: updatedList);
        return true;
      },
    );
  }

  Future<bool> updateUnitPrice({
    required String authenticatedUserId,
    required String unitId,
    required double newPrice,
  }) async {
    final existingIndex = state.units.indexWhere((u) => u.id == unitId);
    if (existingIndex == -1) return false;

    final existing = state.units[existingIndex];
    final updated = UnitInventoryEntity(
      id: existing.id,
      projectId: existing.projectId,
      towerId: existing.towerId,
      unitNumber: existing.unitNumber,
      floorNumber: existing.floorNumber,
      unitType: existing.unitType,
      carpetArea: existing.carpetArea,
      builtUpArea: existing.builtUpArea,
      price: newPrice,
      availabilityStatus: existing.availabilityStatus,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateUnit(updated, authenticatedUserId: authenticatedUserId);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (saved) {
        final updatedList = List<UnitInventoryEntity>.from(state.units);
        updatedList[existingIndex] = saved;
        state = state.copyWith(units: updatedList);
        return true;
      },
    );
  }
}
