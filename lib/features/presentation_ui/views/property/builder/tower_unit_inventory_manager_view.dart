import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/bootstrap/bootstrap.dart';
import 'package:belagavi_property/features/property/domain/entities/tower_entity.dart';
import 'package:belagavi_property/features/property/domain/entities/unit_inventory_entity.dart';
import 'package:belagavi_property/features/property/presentation/providers/builder_providers.dart';
import 'package:belagavi_property/features/property/presentation/providers/tower_inventory_notifier.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

class TowerUnitInventoryManagerView extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const TowerUnitInventoryManagerView({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<TowerUnitInventoryManagerView> createState() =>
      _TowerUnitInventoryManagerViewState();
}

class _TowerUnitInventoryManagerViewState
    extends ConsumerState<TowerUnitInventoryManagerView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(towerInventoryNotifierProvider.notifier)
          .loadProjectData(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(towerInventoryNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tower & Unit Inventory',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            Text(
              widget.projectName,
              style: const TextStyle(
                fontSize: 12,
                color: AppDesignSystem.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_business_rounded,
              color: AppDesignSystem.primaryNavy,
              size: 24,
            ),
            tooltip: 'Add Tower',
            onPressed: () => _showAddTowerDialog(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.playlist_add_rounded,
              color: AppDesignSystem.primaryNavy,
              size: 26,
            ),
            tooltip: 'Bulk Unit Generator',
            onPressed: () => _showBulkGenerateDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildInventorySummaryCards(state),
            _buildFilterHeader(state),
            const Divider(height: 1),
            Expanded(
              child: state.status == TowerInventoryStatus.loading
                  ? const Center(
                      child: const CircularProgressIndicator(
                        color: AppDesignSystem.primaryNavy,
                      ),
                    )
                  : state.filteredUnits.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredUnits.length,
                      itemBuilder: (context, index) {
                        final unit = state.filteredUnits[index];
                        return _buildUnitCard(context, unit);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSingleUnitDialog(context),
        backgroundColor: AppDesignSystem.primaryNavy,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Unit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ─── SUMMARY CARDS ─────────────────────────────────────────────────────────

  Widget _buildInventorySummaryCards(TowerInventoryState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildSummaryChip('Total', '${state.units.length}', Colors.blue),
          const SizedBox(width: 8),
          _buildSummaryChip(
            'Available',
            '${state.countAvailable}',
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildSummaryChip(
            'Reserved',
            '${state.countReserved}',
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildSummaryChip('Sold', '${state.countSold}', Colors.purple),
          const SizedBox(width: 8),
          _buildSummaryChip('Blocked', '${state.countBlocked}', Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FILTER HEADER ──────────────────────────────────────────────────────────

  Widget _buildFilterHeader(TowerInventoryState state) {
    final notifier = ref.read(towerInventoryNotifierProvider.notifier);
    final unitTypes = [
      'All',
      '1 BHK',
      '2 BHK',
      '3 BHK',
      '4 BHK',
      'Penthouse',
      'Office',
      'Commercial',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          // Tower Selector
          Row(
            children: [
              const Text(
                'Tower:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTowerChip(
                        'All Towers',
                        state.selectedTowerId == null,
                        () => notifier.filterByTower(null),
                      ),
                      ...state.towers.map(
                        (t) => _buildTowerChip(
                          t.towerName,
                          state.selectedTowerId == t.id,
                          () => notifier.filterByTower(t.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Unit Type Selector
          Row(
            children: [
              const Text(
                'Type:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: unitTypes
                        .map(
                          (ut) => _buildTowerChip(
                            ut,
                            state.selectedUnitType == ut,
                            () => notifier.filterByUnitType(ut),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTowerChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignSystem.primaryNavy
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppDesignSystem.textPrimary,
          ),
        ),
      ),
    );
  }

  // ─── UNIT CARD ─────────────────────────────────────────────────────────────

  Widget _buildUnitCard(BuildContext context, UnitInventoryEntity unit) {
    final statusColor = switch (unit.availabilityStatus) {
      UnitAvailabilityStatus.available => Colors.green,
      UnitAvailabilityStatus.reserved => Colors.orange,
      UnitAvailabilityStatus.sold => Colors.purple,
      UnitAvailabilityStatus.blocked => Colors.red,
    };

    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';
    final notifier = ref.read(towerInventoryNotifierProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppDesignSystem.borderSubtle),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  unit.unitNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
                Text(
                  'Fl. ${unit.floorNumber}',
                  style: TextStyle(fontSize: 10, color: statusColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${unit.unitType} • ${unit.carpetArea.toStringAsFixed(0)} Sq.Ft',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${unit.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppDesignSystem.textPrimary,
            ),
            onSelected: (action) async {
              if (action == 'available') {
                await notifier.updateUnitStatus(
                  authenticatedUserId: currentUserId,
                  unitId: unit.id,
                  targetStatus: UnitAvailabilityStatus.available,
                );
              } else if (action == 'reserved') {
                await notifier.updateUnitStatus(
                  authenticatedUserId: currentUserId,
                  unitId: unit.id,
                  targetStatus: UnitAvailabilityStatus.reserved,
                );
              } else if (action == 'sold') {
                await notifier.updateUnitStatus(
                  authenticatedUserId: currentUserId,
                  unitId: unit.id,
                  targetStatus: UnitAvailabilityStatus.sold,
                );
              } else if (action == 'blocked') {
                await notifier.updateUnitStatus(
                  authenticatedUserId: currentUserId,
                  unitId: unit.id,
                  targetStatus: UnitAvailabilityStatus.blocked,
                );
              } else if (action == 'price') {
                _showEditPriceDialog(context, unit);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'available',
                child: Text('Mark Available (Green)'),
              ),
              PopupMenuItem(
                value: 'reserved',
                child: Text('Mark Reserved (Orange)'),
              ),
              PopupMenuItem(value: 'sold', child: Text('Mark Sold (Purple)')),
              PopupMenuItem(
                value: 'blocked',
                child: Text('Mark Blocked (Red)'),
              ),
              PopupMenuItem(value: 'price', child: Text('Update Price')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.domain_disabled_rounded,
            size: 56,
            color: AppDesignSystem.textSecondary,
          ),
          SizedBox(height: 14),
          const Text(
            'No Units Found',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          const Text(
            'Tap "+" below to add a unit, or use the top right icon to bulk generate inventory.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── DIALOGS ───────────────────────────────────────────────────────────────

  void _showAddTowerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final floorsCtrl = TextEditingController(text: '10');
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tower / Block'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tower Name (e.g. Tower A)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: floorsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Floors'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await ref
                    .read(towerInventoryNotifierProvider.notifier)
                    .addTower(
                      authenticatedUserId: currentUserId,
                      towerName: nameCtrl.text,
                      totalFloors: int.tryParse(floorsCtrl.text) ?? 10,
                    );
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add Tower'),
          ),
        ],
      ),
    );
  }

  void _showAddSingleUnitDialog(BuildContext context) {
    final state = ref.read(towerInventoryNotifierProvider);
    if (state.towers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one Tower first!')),
      );
      return;
    }

    final unitNoCtrl = TextEditingController();
    final floorCtrl = TextEditingController(text: '1');
    final areaCtrl = TextEditingController(text: '1200');
    final priceCtrl = TextEditingController(text: '4500000');
    String selectedTowerId = state.towers.first.id;
    String selectedUnitType = '2 BHK';
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Unit Inventory'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedTowerId,
                  decoration: const InputDecoration(labelText: 'Tower'),
                  items: state.towers
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.towerName),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedTowerId = val!),
                ),
                TextField(
                  controller: unitNoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Unit Number (e.g. A-101)',
                  ),
                ),
                TextField(
                  controller: floorCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Floor Number'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedUnitType,
                  decoration: const InputDecoration(labelText: 'Unit Type'),
                  items:
                      [
                            '1 BHK',
                            '2 BHK',
                            '3 BHK',
                            '4 BHK',
                            'Penthouse',
                            'Office',
                            'Commercial',
                          ]
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedUnitType = val!),
                ),
                TextField(
                  controller: areaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Built-up Area (Sq.Ft)',
                  ),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Price (₹)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(towerInventoryNotifierProvider.notifier)
                    .addSingleUnit(
                      authenticatedUserId: currentUserId,
                      towerId: selectedTowerId,
                      unitNumber: unitNoCtrl.text,
                      floorNumber: int.tryParse(floorCtrl.text) ?? 1,
                      unitType: selectedUnitType,
                      carpetArea:
                          (double.tryParse(areaCtrl.text) ?? 1200) * 0.8,
                      builtUpArea: double.tryParse(areaCtrl.text) ?? 1200,
                      price: double.tryParse(priceCtrl.text) ?? 4500000,
                    );
                if (success && mounted) Navigator.pop(context);
              },
              child: const Text('Save Unit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkGenerateDialog(BuildContext context) {
    final state = ref.read(towerInventoryNotifierProvider);
    if (state.towers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one Tower first!')),
      );
      return;
    }

    final prefixCtrl = TextEditingController(text: 'A');
    final startFloorCtrl = TextEditingController(text: '1');
    final endFloorCtrl = TextEditingController(text: '10');
    final unitsPerFloorCtrl = TextEditingController(text: '4');
    final priceCtrl = TextEditingController(text: '4500000');
    final areaCtrl = TextEditingController(text: '1200');
    String selectedTowerId = state.towers.first.id;
    String selectedUnitType = '2 BHK';
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Bulk Inventory Generator'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedTowerId,
                  decoration: const InputDecoration(labelText: 'Select Tower'),
                  items: state.towers
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.towerName),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedTowerId = val!),
                ),
                TextField(
                  controller: prefixCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tower Prefix (e.g. A)',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startFloorCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Start Floor',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endFloorCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'End Floor',
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: unitsPerFloorCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Units per Floor',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedUnitType,
                  decoration: const InputDecoration(labelText: 'Unit Type'),
                  items:
                      [
                            '1 BHK',
                            '2 BHK',
                            '3 BHK',
                            '4 BHK',
                            'Penthouse',
                            'Office',
                            'Commercial',
                          ]
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedUnitType = val!),
                ),
                TextField(
                  controller: areaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Built-up Area (Sq.Ft)',
                  ),
                ),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price per Unit (₹)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(towerInventoryNotifierProvider.notifier)
                    .bulkGenerateUnits(
                      authenticatedUserId: currentUserId,
                      towerId: selectedTowerId,
                      towerPrefix: prefixCtrl.text,
                      startFloor: int.tryParse(startFloorCtrl.text) ?? 1,
                      endFloor: int.tryParse(endFloorCtrl.text) ?? 10,
                      unitsPerFloor: int.tryParse(unitsPerFloorCtrl.text) ?? 4,
                      unitType: selectedUnitType,
                      carpetArea:
                          (double.tryParse(areaCtrl.text) ?? 1200) * 0.8,
                      builtUpArea: double.tryParse(areaCtrl.text) ?? 1200,
                      price: double.tryParse(priceCtrl.text) ?? 4500000,
                    );
                if (success && mounted) {
                  final msg =
                      ref
                          .read(towerInventoryNotifierProvider)
                          .lastGeneratedMessage ??
                      'Bulk units generated!';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                  Navigator.pop(context);
                }
              },
              child: const Text('Generate Inventory'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, UnitInventoryEntity unit) {
    final priceCtrl = TextEditingController(
      text: unit.price.toStringAsFixed(0),
    );
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Price for ${unit.unitNumber}'),
        content: TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Price (₹)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newP = double.tryParse(priceCtrl.text) ?? unit.price;
              await ref
                  .read(towerInventoryNotifierProvider.notifier)
                  .updateUnitPrice(
                    authenticatedUserId: currentUserId,
                    unitId: unit.id,
                    newPrice: newP,
                  );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
