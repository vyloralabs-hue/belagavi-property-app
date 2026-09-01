import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/dispute_entities.dart';
import '../providers/dispute_providers.dart';

/// Single-Flow List Disputed Property Wizard
/// Rules:
/// - Asks: "WHAT TYPE OF PROPERTY IS INVOLVED?" first
/// - Shows dynamic property fields based on property type (House, Apartment, Land, Commercial, etc.)
/// - Factual dispute information & case/authority details
/// - Duplicate warning protection
/// - Moderation-first publication (submitted -> under_review -> published)
/// - Creator immediately sees record in My Disputed Properties
class AddDisputedPropertyView extends ConsumerStatefulWidget {
  const AddDisputedPropertyView({super.key});

  @override
  ConsumerState<AddDisputedPropertyView> createState() =>
      _AddDisputedPropertyViewState();
}

class _AddDisputedPropertyViewState
    extends ConsumerState<AddDisputedPropertyView> {
  // Step 1 Controllers (Property Identity)
  final _titleController = TextEditingController();
  final _localityController = TextEditingController(text: 'Tilakwadi');
  final _villageController = TextEditingController();
  final _talukController = TextEditingController(text: 'Belagavi');
  final _districtController = TextEditingController(text: 'Belagavi');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _surveyNumberController = TextEditingController();
  final _propertyNumberController = TextEditingController();
  final _plotFlatNumberController = TextEditingController();
  final _buildingProjectController = TextEditingController();
  final _floorController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 2 Controllers (Dispute Statement)
  final _factualSummaryController = TextEditingController();
  final _claimedNatureController = TextEditingController(
    text: 'Conflicting ownership & title dispute',
  );

  // Step 3 Controllers (Case / Authority)
  final _caseNumberController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _caseFilingDateController = TextEditingController();
  final _caseOrdersNotesController = TextEditingController();

  static const List<String> _propertyTypes = [
    'House',
    'Apartment / Flat',
    'Villa',
    'Plot',
    'Open Land',
    'Agricultural Land',
    'Commercial',
    'Shop',
    'Office',
    'Warehouse',
    'Industrial',
    'Building',
    'Other',
  ];

  static const List<String> _disputeTypes = [
    'Ownership / Title',
    'Boundary',
    'Partition / Family',
    'Inheritance / Succession',
    'Possession',
    'Sale Agreement',
    'Tenancy / Lease',
    'Mortgage / Charge',
    'Encroachment Allegation',
    'Access / Road',
    'Development / JDA',
    'Payment',
    'Court Case',
    'Revenue Record',
    'Registration / Document',
    'Other',
  ];

  static const List<String> _partyRoles = [
    'Owner / Claimant',
    'Legal Heir / Family Member',
    'Agreement Holder / Buyer',
    'Tenant / Occupant',
    'Adjacent Landowner',
    'Creditor / Mortgage Holder',
    'Other Interested Party',
  ];

  static const List<String> _stages = [
    'Reported / Notice Issued',
    'Legal Notice Served',
    'Pending in Civil Court',
    'Interim Stay / Injunction Active',
    'Pending Before Revenue Authority',
    'Under Mediation / Compromise',
    'Dispute Settled / Decree Passed',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _localityController.dispose();
    _villageController.dispose();
    _talukController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _surveyNumberController.dispose();
    _propertyNumberController.dispose();
    _plotFlatNumberController.dispose();
    _buildingProjectController.dispose();
    _floorController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _factualSummaryController.dispose();
    _claimedNatureController.dispose();
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _caseFilingDateController.dispose();
    _caseOrdersNotesController.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDesignSystem.surfaceBg(context),
        title: Text(
          'Discard dispute report?',
          style: TextStyle(color: AppDesignSystem.textP(context)),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to exit without submitting?',
          style: TextStyle(color: AppDesignSystem.textS(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Editing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  void _handleStepBack() async {
    final state = ref.read(addDisputeWizardNotifierProvider);
    if (state.currentStep > 0) {
      ref
          .read(addDisputeWizardNotifierProvider.notifier)
          .setStep(state.currentStep - 1);
    } else {
      final shouldExit = await _confirmExit();
      if (shouldExit && mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.disputedProperties);
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final doc = SelectedDisputeDocument(
          fileName: picked.name,
          documentType: 'Property Photo',
          bytes: bytes,
          localPath: picked.path,
          uploadStatus: 'SELECTED',
        );
        ref.read(addDisputeWizardNotifierProvider.notifier).addDocument(doc);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Photo selection error: $e')));
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final doc = SelectedDisputeDocument(
          fileName: picked.name,
          documentType: 'Supporting Document',
          bytes: bytes,
          localPath: picked.path,
          uploadStatus: 'SELECTED',
        );
        ref.read(addDisputeWizardNotifierProvider.notifier).addDocument(doc);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Document selection error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addDisputeWizardNotifierProvider);
    final notifier = ref.read(addDisputeWizardNotifierProvider.notifier);
    final textP = AppDesignSystem.textP(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    String currentUserId = AuthSessionStorageHelper.getUserUid() ?? '';
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) {
        currentUserId = fbUid;
      }
    } catch (_) {}

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleStepBack();
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: Text(
            'List Disputed Property',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: textP,
            ),
          ),
          backgroundColor: surfaceBg,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textP),
            onPressed: _handleStepBack,
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Step ${state.currentStep + 1} of 5',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Step Progress Bar
            LinearProgressIndicator(
              value: (state.currentStep + 1) / 5.0,
              backgroundColor: borderCol,
              color: AppDesignSystem.brandGold,
              minHeight: 3,
            ),

            if (state.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.red.shade900.withValues(alpha: 0.2),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Step Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: switch (state.currentStep) {
                  0 => _buildStep1PropertyIdentity(context, state, notifier),
                  1 => _buildStep2DisputeDetails(context, state, notifier),
                  2 => _buildStep3CaseAuthority(context, state, notifier),
                  3 => _buildStep4Documents(context, state, notifier),
                  4 => _buildStep5ReviewSubmit(context, state, notifier),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceBg,
                border: Border(top: BorderSide(color: borderCol)),
              ),
              child: Row(
                children: [
                  if (state.currentStep > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _handleStepBack,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textP,
                          side: BorderSide(color: borderCol),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (state.currentStep > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () async {
                              if (!notifier.validateStep(state.currentStep))
                                return;

                              if (state.currentStep < 4) {
                                notifier.setStep(state.currentStep + 1);
                              } else {
                                if (!state.agreedToDisclaimer) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please confirm accuracy to submit.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final created = await notifier.submitDispute(
                                  currentUserId,
                                );
                                if (created != null && mounted) {
                                  ref
                                      .read(
                                        myDisputedPropertiesNotifierProvider
                                            .notifier,
                                      )
                                      .prependDispute(created);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Disputed property submitted for platform review successfully!',
                                      ),
                                    ),
                                  );
                                  context.go(AppRoutes.myDisputedProperties);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0F172A),
                              ),
                            )
                          : Text(
                              state.currentStep == 4
                                  ? 'Submit for Review'
                                  : 'Next Step',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Property Identity (Dynamically adapted to Property Type)
  Widget _buildStep1PropertyIdentity(
    BuildContext context,
    AddDisputeWizardState state,
    AddDisputeWizardNotifier notifier,
  ) {
    final textP = AppDesignSystem.textP(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final selectedType = state.propertyType;

    final isApartment =
        selectedType.contains('Apartment') || selectedType.contains('Flat');
    final isLand =
        selectedType.contains('Land') || selectedType.contains('Plot');
    final isHouse =
        selectedType.contains('House') || selectedType.contains('Villa');
    final isCommercial =
        selectedType.contains('Commercial') ||
        selectedType.contains('Shop') ||
        selectedType.contains('Office');
    final isIndustrial =
        selectedType.contains('Warehouse') ||
        selectedType.contains('Industrial');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Property Identity',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What type of property is involved in this reported dispute?',
          style: TextStyle(fontSize: 12, color: AppDesignSystem.textS(context)),
        ),
        const SizedBox(height: 16),

        // Property Type Dropdown
        _buildLabel('Property Type *'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppDesignSystem.inputBg(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _propertyTypes.contains(state.propertyType)
                  ? state.propertyType
                  : _propertyTypes.first,
              isExpanded: true,
              style: TextStyle(
                fontSize: 13,
                color: textP,
                fontWeight: FontWeight.w600,
              ),
              items: _propertyTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) {
                if (val != null)
                  notifier.updatePropertyDetails(propertyType: val);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildLabel('Short Property Title / Identifier *'),
        _buildTextField(
          _titleController,
          isApartment
              ? 'e.g. 2 BHK Flat in Green Valley Heights'
              : (isLand
                    ? 'e.g. 5 Acre Agricultural Land in Sambra'
                    : 'e.g. Residential House in Tilakwadi'),
          onChanged: (val) => notifier.updatePropertyDetails(title: val),
        ),
        const SizedBox(height: 12),

        _buildLabel('Locality / Area *'),
        _buildTextField(
          _localityController,
          'e.g. Tilakwadi, Camp, Khanapur Road',
          onChanged: (val) {
            notifier.updatePropertyDetails(locality: val);
          },
        ),
        const SizedBox(height: 12),

        // Dynamic fields based on property type
        if (isApartment) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Flat / Unit Number'),
                    _buildTextField(
                      _plotFlatNumberController,
                      'e.g. Flat 302',
                      onChanged: (val) {
                        notifier.updatePropertyDetails(plotFlatShopNumber: val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Floor'),
                    _buildTextField(_floorController, 'e.g. 3rd Floor'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel('Building / Project Name'),
          _buildTextField(
            _buildingProjectController,
            'e.g. Royal Palms Apartment',
            onChanged: (val) {
              notifier.updatePropertyDetails(projectBuildingName: val);
            },
          ),
        ] else if (isLand) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Survey / CTS Number *'),
                    _buildTextField(
                      _surveyNumberController,
                      'e.g. Sy No. 142/3',
                      onChanged: (val) {
                        notifier.updatePropertyDetails(surveyNumber: val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Plot / Hissa Number'),
                    _buildTextField(
                      _plotFlatNumberController,
                      'e.g. Plot 12 / Hissa 2',
                      onChanged: (val) {
                        notifier.updatePropertyDetails(plotFlatShopNumber: val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel('Village / Taluk'),
          _buildTextField(
            _villageController,
            'e.g. Sambra Village, Belagavi Taluk',
            onChanged: (val) {
              notifier.updatePropertyDetails(village: val);
            },
          ),
        ] else if (isHouse) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('House / Property No.'),
                    _buildTextField(
                      _propertyNumberController,
                      'e.g. House No. 89/A',
                      onChanged: (val) {
                        notifier.updatePropertyDetails(propertyNumber: val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Survey / CTS No.'),
                    _buildTextField(
                      _surveyNumberController,
                      'e.g. CTS 4412',
                      onChanged: (val) {
                        notifier.updatePropertyDetails(surveyNumber: val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else if (isCommercial || isIndustrial) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Shop / Office / Unit No.'),
                    _buildTextField(
                      _plotFlatNumberController,
                      'e.g. Shop 14 / Unit 201',
                      onChanged: (val) {
                        notifier.updatePropertyDetails(plotFlatShopNumber: val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Building / Mall / Estate'),
                    _buildTextField(
                      _buildingProjectController,
                      'e.g. City Center Mall',
                      onChanged: (val) {
                        notifier.updatePropertyDetails(
                          projectBuildingName: val,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          _buildLabel('Survey / Property Number'),
          _buildTextField(
            _surveyNumberController,
            'e.g. Sy No. 101 or Property 44',
            onChanged: (val) {
              notifier.updatePropertyDetails(surveyNumber: val);
            },
          ),
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Area'),
                  _buildTextField(
                    _areaController,
                    'e.g. 2400',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      notifier.updatePropertyDetails(
                        propertyArea: double.tryParse(val),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Area Unit'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.inputBg(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderCol),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.areaUnit,
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 13,
                          color: textP,
                          fontWeight: FontWeight.w600,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'sqft', child: Text('sqft')),
                          DropdownMenuItem(
                            value: 'Acres',
                            child: Text('Acres'),
                          ),
                          DropdownMenuItem(
                            value: 'Guntas',
                            child: Text('Guntas'),
                          ),
                          DropdownMenuItem(
                            value: 'sq.yards',
                            child: Text('sq.yards'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null)
                            notifier.updatePropertyDetails(areaUnit: val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 2: Dispute Details
  Widget _buildStep2DisputeDetails(
    BuildContext context,
    AddDisputeWizardState state,
    AddDisputeWizardNotifier notifier,
  ) {
    final textP = AppDesignSystem.textP(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Reported Dispute Details',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What is the nature of the reported dispute? State neutral factual details.',
          style: TextStyle(fontSize: 12, color: AppDesignSystem.textS(context)),
        ),
        const SizedBox(height: 16),

        _buildLabel('Dispute Type *'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppDesignSystem.inputBg(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _disputeTypes.contains(state.disputeCategory)
                  ? state.disputeCategory
                  : _disputeTypes.first,
              isExpanded: true,
              style: TextStyle(
                fontSize: 13,
                color: textP,
                fontWeight: FontWeight.w600,
              ),
              items: _disputeTypes
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null)
                  notifier.updateDisputeDetails(disputeCategory: val);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildLabel('Factual Summary *'),
        _buildTextField(
          _factualSummaryController,
          'State factual timeline, nature of claim, and dispute context without defamatory accusations...',
          maxLines: 4,
          onChanged: (val) =>
              notifier.updateDisputeDetails(factualSummary: val),
        ),
        const SizedBox(height: 12),

        _buildLabel('Your Relationship / Role in this Property'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppDesignSystem.inputBg(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _partyRoles.contains(state.claimingPartyRole)
                  ? state.claimingPartyRole
                  : _partyRoles.first,
              isExpanded: true,
              style: TextStyle(
                fontSize: 13,
                color: textP,
                fontWeight: FontWeight.w600,
              ),
              items: _partyRoles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) {
                if (val != null)
                  notifier.updateDisputeDetails(claimingPartyRole: val);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildLabel('Current Reported Stage'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppDesignSystem.inputBg(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _stages.contains(state.currentStage)
                  ? state.currentStage
                  : _stages.first,
              isExpanded: true,
              style: TextStyle(
                fontSize: 13,
                color: textP,
                fontWeight: FontWeight.w600,
              ),
              items: _stages
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null)
                  notifier.updateDisputeDetails(currentStage: val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // STEP 3: Case / Authority Information
  Widget _buildStep3CaseAuthority(
    BuildContext context,
    AddDisputeWizardState state,
    AddDisputeWizardNotifier notifier,
  ) {
    final textP = AppDesignSystem.textP(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3: Legal / Case Information',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide court, authority, or case reference numbers if available.',
          style: TextStyle(fontSize: 12, color: AppDesignSystem.textS(context)),
        ),
        const SizedBox(height: 16),

        _buildLabel('Court / Authority Name (Optional)'),
        _buildTextField(
          _courtNameController,
          'e.g. Civil Court Senior Division, Belagavi / Tahsildar Office',
          onChanged: (val) {
            notifier.updateCaseDetails(courtAuthorityName: val);
          },
        ),
        const SizedBox(height: 12),

        _buildLabel('Case / Reference / Injunction Number (Optional)'),
        _buildTextField(
          _caseNumberController,
          'e.g. OS 440/2026 / Caveat 112/2026',
          onChanged: (val) {
            notifier.updateCaseDetails(caseNumber: val);
          },
        ),
        const SizedBox(height: 12),

        _buildLabel('Filing Year / Date (Optional)'),
        _buildTextField(
          _caseFilingDateController,
          'e.g. 2026',
          onChanged: (val) {
            notifier.updateCaseDetails(caseFilingDate: val);
          },
        ),
        const SizedBox(height: 12),

        _buildLabel('Active Orders / Interim Relief Notes (Optional)'),
        _buildTextField(
          _caseOrdersNotesController,
          'e.g. Temporary injunction in force restraining third-party creation...',
          maxLines: 3,
          onChanged: (val) => notifier.updateCaseDetails(caseOrdersNotes: val),
        ),
      ],
    );
  }

  // STEP 4: Images & Documents
  Widget _buildStep4Documents(
    BuildContext context,
    AddDisputeWizardState state,
    AddDisputeWizardNotifier notifier,
  ) {
    final textP = AppDesignSystem.textP(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 4: Photos & Supporting Documents',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Attach real property photos and verifiable legal/revenue notices.',
          style: TextStyle(fontSize: 12, color: AppDesignSystem.textS(context)),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                label: const Text('Add Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppDesignSystem.brandGold),
                  foregroundColor: AppDesignSystem.brandGold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.note_add_outlined, size: 16),
                label: const Text('Add Document'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: borderCol),
                  foregroundColor: textP,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (state.documents.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppDesignSystem.inputBg(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol),
            ),
            child: Center(
              child: Text(
                'No photos or documents selected yet.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textS(context),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.documents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = state.documents[index];
              return ListTile(
                tileColor: AppDesignSystem.inputBg(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Icon(
                  doc.documentType == 'Property Photo'
                      ? Icons.image_outlined
                      : Icons.description_outlined,
                  color: AppDesignSystem.brandGold,
                ),
                title: Text(
                  doc.fileName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textP,
                  ),
                ),
                subtitle: Text(
                  doc.documentType,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textS(context),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  onPressed: () => notifier.removeDocument(index),
                ),
              );
            },
          ),
      ],
    );
  }

  // STEP 5: Review & Submit (With Duplicate Check & Declaration)
  Widget _buildStep5ReviewSubmit(
    BuildContext context,
    AddDisputeWizardState state,
    AddDisputeWizardNotifier notifier,
  ) {
    final textP = AppDesignSystem.textP(context);
    final cardBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 5: Review & Confirm Submission',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify your report details before submitting for platform review.',
          style: TextStyle(fontSize: 12, color: AppDesignSystem.textS(context)),
        ),
        const SizedBox(height: 16),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Property Type', state.propertyType),
              _buildReviewRow(
                'Title / Identifier',
                state.title.isNotEmpty ? state.title : 'Disputed Asset',
              ),
              _buildReviewRow('Locality', state.locality),
              if (state.surveyNumber.isNotEmpty)
                _buildReviewRow('Survey / CTS No.', state.surveyNumber),
              if (state.propertyNumber.isNotEmpty)
                _buildReviewRow('Property No.', state.propertyNumber),
              _buildReviewRow('Dispute Type', state.disputeCategory),
              _buildReviewRow('Current Stage', state.currentStage),
              if (state.caseNumber.isNotEmpty)
                _buildReviewRow('Case Number', state.caseNumber),
              if (state.courtAuthorityName.isNotEmpty)
                _buildReviewRow('Court / Authority', state.courtAuthorityName),
              _buildReviewRow(
                'Documents Attached',
                '${state.documents.length} item(s)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Confirmation Checkbox
        CheckboxListTile(
          value: state.agreedToDisclaimer,
          activeColor: AppDesignSystem.brandGold,
          checkColor: const Color(0xFF0F172A),
          contentPadding: EdgeInsets.zero,
          title: Text(
            'I confirm that the information I am submitting is accurate to the best of my knowledge.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textP,
            ),
          ),
          subtitle: Text(
            'This record will be submitted to moderators and will only appear publicly once published.',
            style: TextStyle(
              fontSize: 11,
              color: AppDesignSystem.textS(context),
            ),
          ),
          onChanged: (val) => notifier.setAgreedToDisclaimer(val ?? false),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppDesignSystem.textP(context),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: 13, color: AppDesignSystem.textP(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12,
          color: AppDesignSystem.textS(context),
        ),
        filled: true,
        fillColor: AppDesignSystem.inputBg(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppDesignSystem.borderCol(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppDesignSystem.borderCol(context)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppDesignSystem.brandGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: AppDesignSystem.textS(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textP(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
