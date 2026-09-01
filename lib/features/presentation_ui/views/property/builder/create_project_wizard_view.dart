import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/bootstrap/bootstrap.dart';
import 'package:belagavi_property/core/routing/app_routes.dart';
import 'package:belagavi_property/features/property/domain/entities/project_entity.dart';
import 'package:belagavi_property/features/property/presentation/providers/builder_project_form_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/builder_providers.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';

class CreateProjectWizardView extends ConsumerStatefulWidget {
  final ProjectEntity? editProject;

  const CreateProjectWizardView({super.key, this.editProject});

  @override
  ConsumerState<CreateProjectWizardView> createState() =>
      _CreateProjectWizardViewState();
}

class _CreateProjectWizardViewState
    extends ConsumerState<CreateProjectWizardView> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _reraController = TextEditingController();

  final _localityController = TextEditingController();
  final _cityController = TextEditingController(text: 'Belagavi');
  final _districtController = TextEditingController(text: 'Belagavi');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _countryController = TextEditingController(text: 'India');
  final _streetController = TextEditingController();

  final _towersController = TextEditingController(text: '1');
  final _unitsController = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';
      if (widget.editProject != null) {
        ref
            .read(builderProjectFormNotifierProvider.notifier)
            .initForEditing(widget.editProject!);
        _populateFields(widget.editProject!);
      } else {
        ref
            .read(builderProjectFormNotifierProvider.notifier)
            .initForNewProject(currentUserId);
      }
    });
  }

  void _populateFields(ProjectEntity p) {
    _nameController.text = p.projectName;
    _descriptionController.text = p.description;
    _localityController.text = p.locality;
    _cityController.text = p.city;
    _districtController.text = p.district;
    _stateController.text = p.state;
    _countryController.text = p.country;
    _streetController.text = p.exactLocation;
    _reraController.text = p.reraNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _reraController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _streetController.dispose();
    _towersController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(builderProjectFormNotifierProvider);

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
        title: Text(
          widget.editProject != null
              ? 'Edit Builder Project'
              : 'Create Builder Project',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppDesignSystem.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(formState.currentStep),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(formState),
              ),
            ),
            _buildWizardNavigationButtons(formState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    final stepTitles = ['Basic Info', 'Location', 'Config', 'Towers', 'Review'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 4 ? 6.0 : 0.0),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppDesignSystem.primaryNavy
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isCurrent = index == currentStep;
              return Text(
                stepTitles[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent
                      ? AppDesignSystem.primaryNavy
                      : AppDesignSystem.textSecondary,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuilderProjectFormState state) {
    return switch (state.currentStep) {
      0 => _buildStep1BasicInfo(state),
      1 => _buildStep2Location(state),
      2 => _buildStep3Configuration(state),
      3 => _buildStep4TowersPreview(state),
      4 => _buildStep5Review(state),
      _ => _buildStep1BasicInfo(state),
    };
  }

  // ─── STEP 1: BASIC INFORMATION ─────────────────────────────────────────────

  Widget _buildStep1BasicInfo(BuilderProjectFormState state) {
    final notifier = ref.read(builderProjectFormNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1 of 5: Basic Information',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter project name, type, status, and starting price.',
          style: const TextStyle(
            fontSize: 13,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: 'Project Name *',
          hint: 'e.g. Prestige Heights Belagavi',
          controller: _nameController,
          errorText: state.fieldErrors['projectName'],
          onChanged: (val) => notifier.updateBasicDetails(projectName: val),
        ),
        const SizedBox(height: 16),

        const Text(
          'Project Type *',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProjectType.values.map((ProjectType type) {
            final label = switch (type) {
              ProjectType.apartment => 'Residential Apartment',
              ProjectType.gatedCommunity => 'Gated Community',
              ProjectType.villaProject => 'Villa Project',
              ProjectType.commercialComplex => 'Commercial Complex',
              ProjectType.mixedUse => 'Mixed Use',
            };
            return _buildChoiceChip(
              label,
              state.projectType == type,
              () => notifier.updateBasicDetails(projectType: type),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        const Text(
          'Project Status *',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProjectStatus.values.map((ProjectStatus st) {
            final label = switch (st) {
              ProjectStatus.upcoming => 'Upcoming',
              ProjectStatus.underConstruction => 'Under Construction',
              ProjectStatus.readyToMove => 'Ready to Move',
              ProjectStatus.completed => 'Completed',
            };
            return _buildChoiceChip(
              label,
              state.status == st,
              () => notifier.updateBasicDetails(status: st),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: 'Starting Price (in ₹)',
          hint: 'e.g. 4500000',
          keyboardType: TextInputType.number,
          controller: _priceController,
          onChanged: (val) => notifier.updateBasicDetails(
            startingPrice: double.tryParse(val) ?? 0.0,
          ),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: 'RERA Registration Number (Optional)',
          hint: 'e.g. PRM/KA/RERA/1259/001234',
          controller: _reraController,
          onChanged: (val) => notifier.updateBasicDetails(reraNumber: val),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: 'Project Overview / Description',
          hint:
              'Describe builder highlights, architectural layout, target occupancy, etc.',
          controller: _descriptionController,
          maxLines: 4,
          onChanged: (val) => notifier.updateBasicDetails(description: val),
        ),
      ],
    );
  }

  // ─── STEP 2: LOCATION ──────────────────────────────────────────────────────

  Widget _buildStep2Location(BuilderProjectFormState state) {
    final notifier = ref.read(builderProjectFormNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2 of 5: Project Location',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Specify public area/locality and private protected street location.',
          style: const TextStyle(
            fontSize: 13,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  const Icon(
                    Icons.public_rounded,
                    color: AppDesignSystem.primaryNavy,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  const Text(
                    'PUBLIC LOCATION (Visible to Buyers)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppDesignSystem.primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Locality / Area *',
                hint: 'e.g. Tilakwadi, Shahapur, Hindwadi, Camp',
                controller: _localityController,
                errorText: state.fieldErrors['locality'],
                onChanged: (val) => notifier.updateLocation(locality: val),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'City',
                      controller: _cityController,
                      onChanged: (val) => notifier.updateLocation(city: val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'State',
                      controller: _stateController,
                      onChanged: (val) =>
                          notifier.updateLocation(stateName: val),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shield_rounded,
                    color: Color(0xFFB45309),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'PROTECTED PRIVATE SITE LOCATION (Phase 2 Encrypted)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Exact survey numbers, door numbers, and site GPS are protected under Phase 2 security rules.',
                style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Exact Site Address (Protected)',
                hint: 'e.g. Survey #104/A, Main Road, Tilakwadi',
                controller: _streetController,
                onChanged: (val) => notifier.updateLocation(exactLocation: val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STEP 3: CONFIGURATION ─────────────────────────────────────────────────

  Widget _buildStep3Configuration(BuilderProjectFormState state) {
    final notifier = ref.read(builderProjectFormNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3 of 5: Project Configuration',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Specify initial number of towers and total planned units.',
          style: const TextStyle(
            fontSize: 13,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Total Towers / Blocks',
                controller: _towersController,
                keyboardType: TextInputType.number,
                onChanged: (val) => notifier.updateConfiguration(
                  totalTowers: int.tryParse(val) ?? 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: 'Planned Total Units',
                controller: _unitsController,
                keyboardType: TextInputType.number,
                onChanged: (val) => notifier.updateConfiguration(
                  totalUnits: int.tryParse(val) ?? 50,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Project Amenities & Facilities',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Clubhouse')),
            Chip(label: Text('Swimming Pool')),
            Chip(label: Text('24/7 Security')),
            Chip(label: Text('Power Backup')),
            Chip(label: Text('Children Play Area')),
            Chip(label: Text('Covered Parking')),
            Chip(label: Text('Gymnasium')),
            Chip(label: Text('EV Charging')),
          ],
        ),
      ],
    );
  }

  // ─── STEP 4: TOWERS SETUP PREVIEW ─────────────────────────────────────────

  Widget _buildStep4TowersPreview(BuilderProjectFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4 of 5: Towers & Inventory Setup',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Project towers and flat unit inventory can be configured immediately after saving.',
          style: const TextStyle(
            fontSize: 13,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: const Row(
            children: [
              const Icon(
                Icons.domain_rounded,
                size: 36,
                color: AppDesignSystem.primaryNavy,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tower & Inventory Manager Ready',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppDesignSystem.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    const Text(
                      'You will be able to add Tower A, Tower B, bulk generate units (e.g. A-101 to A-206), set pricing, and manage unit status.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STEP 5: REVIEW & SAVE ─────────────────────────────────────────────────

  Widget _buildStep5Review(BuilderProjectFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 5 of 5: Review & Save',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Review project details before saving to the Builder Control Panel.',
          style: const TextStyle(
            fontSize: 13,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppDesignSystem.borderSubtle),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.projectName.isNotEmpty
                    ? state.projectName
                    : 'Untitled Project',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Starting @ ₹${state.startingPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppDesignSystem.primaryNavy,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildReviewRow('Type', state.projectType.name),
              _buildReviewRow('Status', state.status.name),
              _buildReviewRow(
                'Public Location',
                '${state.locality}, ${state.city}',
              ),
              _buildReviewRow(
                'Protected Site Address',
                state.exactLocation.isNotEmpty
                    ? '${state.exactLocation} (Encrypted)'
                    : 'Not specified',
              ),
              _buildReviewRow('Towers', '${state.totalTowers} towers'),
              _buildReviewRow('Planned Units', '${state.totalUnits} units'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppDesignSystem.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? errorText,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignSystem.primaryNavy
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppDesignSystem.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildWizardNavigationButtons(BuilderProjectFormState state) {
    final notifier = ref.read(builderProjectFormNotifierProvider.notifier);
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_builder_101';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => notifier.setStep(state.currentStep - 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (state.currentStep < 4) {
                  if (notifier.validateStep(state.currentStep)) {
                    notifier.setStep(state.currentStep + 1);
                  }
                } else {
                  final success = await notifier.saveProject(currentUserId);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Builder Project created successfully!'),
                      ),
                    );
                    context.pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                state.currentStep == 4 ? 'Save Project' : 'Next Step',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
