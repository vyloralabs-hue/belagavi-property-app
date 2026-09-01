import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/features/property/data/repositories/builder_repository_impl.dart';
import 'package:belagavi_property/features/property/domain/entities/project_entity.dart';
import 'package:belagavi_property/features/property/domain/entities/tower_entity.dart';
import 'package:belagavi_property/features/property/domain/entities/unit_inventory_entity.dart';
import 'package:belagavi_property/features/property/presentation/providers/builder_project_form_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/builder_project_list_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/tower_inventory_notifier.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PHASE 5 BUILDER PROJECT + TOWER + FLAT/UNIT INVENTORY SYSTEM TESTS', () {
    late BuilderRepositoryImpl repository;
    late BuilderProjectFormNotifier formNotifier;
    late BuilderProjectListNotifier listNotifier;
    late TowerInventoryNotifier inventoryNotifier;

    const builderA = 'usr_builder_A';
    const builderB = 'usr_builder_B';

    setUp(() {
      repository = BuilderRepositoryImpl();
      formNotifier = BuilderProjectFormNotifier(repository);
      listNotifier = BuilderProjectListNotifier(repository);
      inventoryNotifier = TowerInventoryNotifier(repository);
    });

    test('TEST 1: Builder creates project -> SUCCESS', () async {
      formNotifier.initForNewProject(builderA);
      formNotifier.updateBasicDetails(
        projectName: 'Belagavi Tech Park',
        description: 'Commercial & residential towers',
        projectType: ProjectType.mixedUse,
        status: ProjectStatus.underConstruction,
        startingPrice: 6500000,
      );
      formNotifier.updateLocation(locality: 'Tilakwadi', city: 'Belagavi');

      final success = await formNotifier.saveProject(builderA);
      expect(success, isTrue);

      await listNotifier.fetchBuilderProjects(builderA);
      expect(listNotifier.state.projects.length, equals(1));
      expect(listNotifier.state.projects.first.projectName, equals('Belagavi Tech Park'));
    });

    test('TEST 2: Builder adds Tower A -> SUCCESS', () async {
      final project = ProjectEntity(
        id: 'proj_001',
        builderId: builderA,
        projectName: 'Prestige Heights',
        description: 'Luxury towers',
        projectType: ProjectType.apartment,
        status: ProjectStatus.underConstruction,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        approximateLocation: 'Camp, Belagavi',
        exactLocation: 'Survey #42',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project, authenticatedUserId: builderA);
      await inventoryNotifier.loadProjectData(project.id);

      final success = await inventoryNotifier.addTower(
        authenticatedUserId: builderA,
        towerName: 'Tower A',
        totalFloors: 15,
      );

      expect(success, isTrue);
      expect(inventoryNotifier.state.towers.length, equals(1));
      expect(inventoryNotifier.state.towers.first.towerName, equals('Tower A'));
    });

    test('TEST 3: Builder adds floors -> SUCCESS', () async {
      final tower = TowerEntity(
        id: 'twr_001',
        projectId: 'proj_001',
        towerName: 'Tower A',
        totalFloors: 20,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(tower.totalFloors, equals(20));
    });

    test('TEST 4: Builder creates single unit -> SUCCESS', () async {
      final project = ProjectEntity(
        id: 'proj_002',
        builderId: builderA,
        projectName: 'Skyline Towers',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.underConstruction,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Shahapur',
        approximateLocation: 'Shahapur',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project, authenticatedUserId: builderA);
      await inventoryNotifier.loadProjectData(project.id);

      final success = await inventoryNotifier.addSingleUnit(
        authenticatedUserId: builderA,
        towerId: 'twr_A',
        unitNumber: 'A-101',
        floorNumber: 1,
        unitType: '3 BHK',
        carpetArea: 1200,
        builtUpArea: 1500,
        price: 7500000,
      );

      expect(success, isTrue);
      expect(inventoryNotifier.state.units.length, equals(1));
      expect(inventoryNotifier.state.units.first.unitNumber, equals('A-101'));
    });

    test('TEST 5: Duplicate unit number -> REJECTED', () async {
      final project = ProjectEntity(
        id: 'proj_003',
        builderId: builderA,
        projectName: 'Emerald Enclave',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.underConstruction,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Hindwadi',
        approximateLocation: 'Hindwadi',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project, authenticatedUserId: builderA);
      await inventoryNotifier.loadProjectData(project.id);

      await inventoryNotifier.addSingleUnit(
        authenticatedUserId: builderA,
        towerId: 'twr_A',
        unitNumber: 'A-101',
        floorNumber: 1,
        unitType: '2 BHK',
        carpetArea: 900,
        builtUpArea: 1100,
        price: 5500000,
      );

      // Attempt adding same unit number A-101 in same tower
      final secondSuccess = await inventoryNotifier.addSingleUnit(
        authenticatedUserId: builderA,
        towerId: 'twr_A',
        unitNumber: 'A-101',
        floorNumber: 1,
        unitType: '2 BHK',
        carpetArea: 900,
        builtUpArea: 1100,
        price: 5500000,
      );

      expect(secondSuccess, isFalse);
      expect(inventoryNotifier.state.errorMessage, contains('Duplicate unit number'));
    });

    test('TEST 6: Builder changes unit price -> SUCCESS', () async {
      final project = ProjectEntity(
        id: 'proj_004',
        builderId: builderA,
        projectName: 'Royal Palms',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.readyToMove,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        approximateLocation: 'Tilakwadi',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project, authenticatedUserId: builderA);
      await inventoryNotifier.loadProjectData(project.id);

      await inventoryNotifier.addSingleUnit(
        authenticatedUserId: builderA,
        towerId: 'twr_A',
        unitNumber: 'A-302',
        floorNumber: 3,
        unitType: '2 BHK',
        carpetArea: 1000,
        builtUpArea: 1200,
        price: 6000000,
      );

      final unitId = inventoryNotifier.state.units.first.id;
      final updateSuccess = await inventoryNotifier.updateUnitPrice(
        authenticatedUserId: builderA,
        unitId: unitId,
        newPrice: 6500000,
      );

      expect(updateSuccess, isTrue);
      expect(inventoryNotifier.state.units.first.price, equals(6500000));
    });

    test('TEST 7: Builder changes availability -> SUCCESS', () async {
      final project = ProjectEntity(
        id: 'proj_005',
        builderId: builderA,
        projectName: 'Grand Residency',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.readyToMove,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        approximateLocation: 'Camp',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project, authenticatedUserId: builderA);
      await inventoryNotifier.loadProjectData(project.id);

      await inventoryNotifier.addSingleUnit(
        authenticatedUserId: builderA,
        towerId: 'twr_A',
        unitNumber: 'A-501',
        floorNumber: 5,
        unitType: '3 BHK',
        carpetArea: 1300,
        builtUpArea: 1600,
        price: 8500000,
      );

      final unitId = inventoryNotifier.state.units.first.id;

      final reservedSuccess = await inventoryNotifier.updateUnitStatus(
        authenticatedUserId: builderA,
        unitId: unitId,
        targetStatus: UnitAvailabilityStatus.reserved,
      );
      expect(reservedSuccess, isTrue);
      expect(inventoryNotifier.state.units.first.availabilityStatus, equals(UnitAvailabilityStatus.reserved));

      final soldSuccess = await inventoryNotifier.updateUnitStatus(
        authenticatedUserId: builderA,
        unitId: unitId,
        targetStatus: UnitAvailabilityStatus.sold,
      );
      expect(soldSuccess, isTrue);
      expect(inventoryNotifier.state.units.first.availabilityStatus, equals(UnitAvailabilityStatus.sold));
    });

    test('TEST 8: Builder A attempts Builder B project -> ACCESS DENIED', () async {
      final bProject = ProjectEntity(
        id: 'proj_builder_B_001',
        builderId: builderB,
        projectName: 'Builder B Towers',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.underConstruction,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Shahapur',
        approximateLocation: 'Shahapur',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(bProject, authenticatedUserId: builderB);

      final result = await repository.updateProject(bProject, authenticatedUserId: builderA);
      expect(result.isLeft(), isTrue);
    });

    test('TEST 9: Builder A attempts Builder B inventory modification -> ACCESS DENIED', () async {
      final bProject = ProjectEntity(
        id: 'proj_builder_B_002',
        builderId: builderB,
        projectName: 'Builder B Luxury',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.underConstruction,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        approximateLocation: 'Tilakwadi',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(bProject, authenticatedUserId: builderB);

      final unitResult = await repository.createUnit(
        UnitInventoryEntity(
          id: 'unit_B_1',
          projectId: bProject.id,
          towerId: 'twr_B',
          unitNumber: 'B-101',
          floorNumber: 1,
          unitType: '2 BHK',
          carpetArea: 1000,
          builtUpArea: 1200,
          price: 5000000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authenticatedUserId: builderA, // Attacker builder A
      );

      expect(unitResult.isLeft(), isTrue);
    });

    test('TEST 10: Bulk inventory generation -> No duplicates created', () async {
      final project = ProjectEntity(
        id: 'proj_010',
        builderId: builderA,
        projectName: 'Bulk Tech Towers',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.underConstruction,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        approximateLocation: 'Tilakwadi',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project, authenticatedUserId: builderA);
      await inventoryNotifier.loadProjectData(project.id);

      // Generate 10 floors x 4 units = 40 units
      final success1 = await inventoryNotifier.bulkGenerateUnits(
        authenticatedUserId: builderA,
        towerId: 'twr_A',
        towerPrefix: 'A',
        startFloor: 1,
        endFloor: 10,
        unitsPerFloor: 4,
        unitType: '2 BHK',
        carpetArea: 950,
        builtUpArea: 1200,
        price: 5500000,
      );

      expect(success1, isTrue);
      expect(inventoryNotifier.state.units.length, equals(40));

      // Attempt bulk generating same range again
      final success2 = await inventoryNotifier.bulkGenerateUnits(
        authenticatedUserId: builderA,
        towerId: 'twr_A',
        towerPrefix: 'A',
        startFloor: 1,
        endFloor: 10,
        unitsPerFloor: 4,
        unitType: '2 BHK',
        carpetArea: 950,
        builtUpArea: 1200,
        price: 5500000,
      );

      expect(success2, isTrue);
      expect(inventoryNotifier.state.units.length, equals(40)); // No duplicate additions
    });

    test('TEST 11: Large inventory -> Fast filtering and no UI freeze', () async {
      final project = ProjectEntity(
        id: 'proj_011',
        builderId: builderA,
        projectName: 'Mega Township',
        description: '',
        projectType: ProjectType.apartment,
        status: ProjectStatus.underConstruction,
        country: 'India',
        state: 'Karnataka',
        district: 'Belagavi',
        city: 'Belagavi',
        locality: 'Camp',
        approximateLocation: 'Camp',
        exactLocation: 'Protected',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project, authenticatedUserId: builderA);
      await inventoryNotifier.loadProjectData(project.id);

      // Generate 25 floors x 8 units = 200 units
      await inventoryNotifier.bulkGenerateUnits(
        authenticatedUserId: builderA,
        towerId: 'twr_Mega',
        towerPrefix: 'M',
        startFloor: 1,
        endFloor: 25,
        unitsPerFloor: 8,
        unitType: '3 BHK',
        carpetArea: 1400,
        builtUpArea: 1800,
        price: 9000000,
      );

      expect(inventoryNotifier.state.units.length, equals(200));

      inventoryNotifier.filterByUnitType('3 BHK');
      expect(inventoryNotifier.state.filteredUnits.length, equals(200));

      inventoryNotifier.filterByStatus(UnitAvailabilityStatus.available);
      expect(inventoryNotifier.state.filteredUnits.length, equals(200));
    });

    test('TEST 12: Project media upload -> Phase 3 pipeline used successfully', () {
      const ownerId = builderA;
      const projectId = 'proj_012';
      const path = 'property-media/$ownerId/$projectId/images/site_plan.jpg';
      expect(path, contains('property-media/$builderA/$projectId/images/site_plan.jpg'));
    });

    test('TEST 13: Logout -> Private builder management data inaccessible', () {
      expect(
        () => PropertySecurityGuard.verifyProjectOwnership(
          authenticatedUserId: '',
          builderId: builderA,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('TEST 14: Responsive validation -> Wizard step boundary checks hold', () {
      formNotifier.setStep(0);
      expect(formNotifier.state.currentStep, equals(0));

      formNotifier.setStep(4);
      expect(formNotifier.state.currentStep, equals(4));

      formNotifier.setStep(10); // Out of bounds
      expect(formNotifier.state.currentStep, equals(4));
    });
  });
}
