import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/bootstrap/bootstrap.dart';
import 'package:belagavi_property/features/property/domain/entities/project_entity.dart';
import 'package:belagavi_property/features/property/presentation/providers/builder_project_list_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/builder_providers.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'create_project_wizard_view.dart';
import 'tower_unit_inventory_manager_view.dart';

class BuilderProjectListView extends ConsumerStatefulWidget {
  const BuilderProjectListView({super.key});

  @override
  ConsumerState<BuilderProjectListView> createState() =>
      _BuilderProjectListViewState();
}

class _BuilderProjectListViewState
    extends ConsumerState<BuilderProjectListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';
      ref
          .read(builderProjectListNotifierProvider.notifier)
          .fetchBuilderProjects(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(builderProjectListNotifierProvider);

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
        title: const Text(
          'Builder Project Control Panel',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: AppDesignSystem.primaryNavy,
              size: 28,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateProjectWizardView(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.status == BuilderProjectListStatus.loading
            ? const Center(
                child: const CircularProgressIndicator(
                  color: AppDesignSystem.primaryNavy,
                ),
              )
            : state.projects.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return _buildProjectCard(context, project);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.domain_outlined,
                size: 56,
                color: AppDesignSystem.primaryNavy,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Builder Projects Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first residential or commercial project to manage towers, floors, flat inventory, and pricing.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProjectWizardView(),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create New Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectEntity project) {
    final statusColor = switch (project.status) {
      ProjectStatus.upcoming => Colors.blue,
      ProjectStatus.underConstruction => Colors.orange,
      ProjectStatus.readyToMove => Colors.green,
      ProjectStatus.completed => Colors.teal,
    };

    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppDesignSystem.borderSubtle),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image & Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: Center(
                    child: Icon(
                      Icons.location_city_rounded,
                      size: 52,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    project.status.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      color: AppDesignSystem.textPrimary,
                      size: 20,
                    ),
                  ),
                  onSelected: (action) async {
                    if (action == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateProjectWizardView(editProject: project),
                        ),
                      );
                    } else if (action == 'inventory') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TowerUnitInventoryManagerView(
                            projectId: project.id,
                            projectName: project.projectName,
                          ),
                        ),
                      );
                    } else if (action == 'delete') {
                      await ref
                          .read(builderProjectListNotifierProvider.notifier)
                          .deleteProject(
                            authenticatedUserId: currentUserId,
                            projectId: project.id,
                          );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'inventory',
                      child: Text('Manage Towers & Inventory'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Project Details'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete Project',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.projectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${project.locality}, ${project.city}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TowerUnitInventoryManagerView(
                                    projectId: project.id,
                                    projectName: project.projectName,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.inventory_2_rounded, size: 16),
                        label: const Text(
                          'Manage Inventory',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
