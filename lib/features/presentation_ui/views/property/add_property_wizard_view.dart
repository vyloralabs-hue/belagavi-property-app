import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/bootstrap/bootstrap.dart';
import 'package:belagavi_property/core/backend/supabase_service.dart';
import 'package:belagavi_property/core/utils/app_logger.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_form_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/my_properties_notifier.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import 'package:belagavi_property/features/property/presentation/widgets/app_property_image.dart';
import 'package:belagavi_property/features/property/services/media_picker_service.dart';
import 'package:belagavi_property/features/property/services/property_media_upload_service.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property_search/domain/entities/search_entities.dart';
import 'package:belagavi_property/features/property_search/domain/entities/user_location_context.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/property_search_notifier.dart';
import 'package:belagavi_property/features/property_search/presentation/providers/user_location_notifier.dart';
import 'widgets/interactive_map_location_picker.dart';
import '../property_details/google_maps_launcher.dart';

class AddPropertyWizardView extends ConsumerStatefulWidget {
  final PropertyEntity? editProperty;
  final PropertyCategory? initialCategory;

  const AddPropertyWizardView({
    super.key,
    this.editProperty,
    this.initialCategory,
  });

  @override
  ConsumerState<AddPropertyWizardView> createState() =>
      _AddPropertyWizardViewState();
}

class _AddPropertyWizardViewState extends ConsumerState<AddPropertyWizardView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final _bedroomsController = TextEditingController(text: '2');
  final _bathroomsController = TextEditingController(text: '2');
  final _balconiesController = TextEditingController(text: '1');
  final _floorNumberController = TextEditingController(text: '1');
  final _totalFloorsController = TextEditingController(text: '5');
  final _facingDirectionController = TextEditingController(text: 'East');
  final _carpetAreaController = TextEditingController(text: '1000');
  final _builtUpAreaController = TextEditingController(text: '1200');
  final _superBuiltUpAreaController = TextEditingController(text: '1400');
  final _plotAreaController = TextEditingController(text: '0');

  // Rent / Lease specific controllers
  final _securityDepositController = TextEditingController(text: '0');
  final _maintenanceChargeController = TextEditingController(text: '0');
  final _leaseAmountController = TextEditingController(text: '0');
  final _leaseDurationController = TextEditingController(text: '11');
  final _availabilityDateController = TextEditingController(text: 'Immediate');

  // Plot / Land specific controllers
  final _plotLengthController = TextEditingController(text: '');
  final _plotWidthController = TextEditingController(text: '');
  final _roadWidthController = TextEditingController(text: '');
  final _plotFacingController = TextEditingController(text: 'East');
  final _numberOfRoadsController = TextEditingController(text: '1');

  // Raw Land specific controllers
  final _soilTypeController = TextEditingController(text: 'Red Soil');
  final _waterSourceController = TextEditingController(text: 'Borewell');
  final _borewellCountController = TextEditingController(text: '1');
  final _electricityTypeController = TextEditingController(
    text: '3-Phase Agri Power',
  );
  final _roadAccessTypeController = TextEditingController(
    text: 'Tar Road Frontage',
  );
  final _fencingTypeController = TextEditingController(
    text: 'Barbed Wire Fencing',
  );
  final _existingCropsTreesController = TextEditingController(text: '');
  final _surveyNumberController = TextEditingController(text: '');

  // Commercial specific controllers
  final _entranceWidthController = TextEditingController(text: '');
  final _ceilingHeightController = TextEditingController(text: '');
  final _washroomsController = TextEditingController(text: '1');
  final _parkingSpacesController = TextEditingController(text: '1');
  final _powerLoadController = TextEditingController(text: '');
  final _waterSupplyController = TextEditingController(text: '24/7 Supply');

  final _countryController = TextEditingController(text: 'India');
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _localityController = TextEditingController();
  final _streetController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatusMessage = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentUserId =
          FirebaseAuth.instance.currentUser?.uid ??
          AuthSessionStorageHelper.getUserUid() ??
          '';
      if (widget.editProperty != null) {
        ref
            .read(propertyFormNotifierProvider.notifier)
            .initForEditing(widget.editProperty!);
        _populateFields(widget.editProperty!);
      } else {
        ref
            .read(propertyFormNotifierProvider.notifier)
            .initForNewProperty(currentUserId);
        final userLoc = ref.read(userLocationNotifierProvider).current;
        if (userLoc.hasExplicitSelection && !userLoc.isAllIndia) {
          if (userLoc.stateName != null && userLoc.stateName!.isNotEmpty) {
            _stateController.text = userLoc.stateName!;
            ref
                .read(propertyFormNotifierProvider.notifier)
                .updateLocation(stateName: userLoc.stateName!);
          }
          if (userLoc.cityName != null && userLoc.cityName!.isNotEmpty) {
            _cityController.text = userLoc.cityName!;
            ref
                .read(propertyFormNotifierProvider.notifier)
                .updateLocation(city: userLoc.cityName!);
          }
          if (userLoc.districtName != null &&
              userLoc.districtName!.isNotEmpty) {
            _districtController.text = userLoc.districtName!;
            ref
                .read(propertyFormNotifierProvider.notifier)
                .updateLocation(district: userLoc.districtName!);
          }
          if (userLoc.localityName != null &&
              userLoc.localityName!.isNotEmpty) {
            _localityController.text = userLoc.localityName!;
            ref
                .read(propertyFormNotifierProvider.notifier)
                .updateLocation(locality: userLoc.localityName!);
          }
          if (userLoc.pincode != null && userLoc.pincode!.isNotEmpty) {
            _pincodeController.text = userLoc.pincode!;
            ref
                .read(propertyFormNotifierProvider.notifier)
                .updateLocation(pincode: userLoc.pincode!);
          }
        }
        if (widget.initialCategory != null) {
          final cat = widget.initialCategory!;
          final defaultType = switch (cat) {
            PropertyCategory.residential => PropertySubtype.apartment,
            PropertyCategory.plotLand => PropertySubtype.residentialPlot,
            PropertyCategory.commercial => PropertySubtype.commercialShop,
            PropertyCategory.land => PropertySubtype.agriculturalLand,
            _ => PropertySubtype.apartment,
          };
          ref
              .read(propertyFormNotifierProvider.notifier)
              .updatePropertyType(category: cat, type: defaultType);
          ref.read(propertyFormNotifierProvider.notifier).setStep(1);
        }
      }
    });
  }

  void _populateFields(PropertyEntity p) {
    _titleController.text = p.title;
    _descriptionController.text = p.description;
    _priceController.text = p.price.toStringAsFixed(0);
    _bedroomsController.text = p.specifications.bedrooms?.toString() ?? '2';
    _bathroomsController.text = p.specifications.bathrooms?.toString() ?? '2';
    _balconiesController.text = p.specifications.balconies?.toString() ?? '1';
    _floorNumberController.text =
        p.specifications.floorNumber?.toString() ?? '1';
    _totalFloorsController.text =
        p.specifications.totalFloors?.toString() ?? '5';
    _facingDirectionController.text =
        p.specifications.facingDirection ?? 'East';
    _carpetAreaController.text = (p.specifications.carpetArea ?? 1000)
        .toStringAsFixed(0);
    _builtUpAreaController.text = (p.specifications.superBuiltUpArea ?? 1200)
        .toStringAsFixed(0);
    _superBuiltUpAreaController.text =
        (p.specifications.superBuiltUpArea ?? 1400).toStringAsFixed(0);
    _plotAreaController.text = (p.specifications.plotArea ?? 0).toStringAsFixed(
      0,
    );
    _securityDepositController.text =
        ((p.features['securityDeposit'] as num?)?.toDouble() ?? 0)
            .toStringAsFixed(0);
    _maintenanceChargeController.text =
        ((p.features['maintenanceCharge'] as num?)?.toDouble() ?? 0)
            .toStringAsFixed(0);
    _leaseAmountController.text =
        ((p.features['leaseAmount'] as num?)?.toDouble() ?? 0).toStringAsFixed(
          0,
        );
    _leaseDurationController.text = (p.features['leaseDuration'] as int? ?? 11)
        .toString();
    _availabilityDateController.text =
        p.features['availabilityDate'] as String? ?? 'Immediate';
    // Plot / Land specific field population
    _plotLengthController.text =
        (p.features['plotLength'] as num?)?.toStringAsFixed(0) ?? '';
    _plotWidthController.text =
        (p.features['plotWidth'] as num?)?.toStringAsFixed(0) ?? '';
    _roadWidthController.text =
        (p.features['roadWidth'] as num?)?.toStringAsFixed(0) ?? '';
    _plotFacingController.text = p.specifications.facingDirection ?? 'East';
    _numberOfRoadsController.text = (p.features['numberOfRoads'] as int? ?? 1)
        .toString();
    // Raw Land specific field population
    _soilTypeController.text = p.features['soilType'] as String? ?? 'Red Soil';
    _waterSourceController.text =
        p.features['waterSource'] as String? ?? 'Borewell';
    _borewellCountController.text = (p.features['borewellCount'] as int? ?? 1)
        .toString();
    _electricityTypeController.text =
        p.features['electricityType'] as String? ?? '3-Phase Agri Power';
    _roadAccessTypeController.text =
        p.features['roadAccessType'] as String? ?? 'Tar Road Frontage';
    _fencingTypeController.text =
        p.features['fencingType'] as String? ?? 'Barbed Wire Fencing';
    _existingCropsTreesController.text =
        p.features['existingCropsTrees'] as String? ?? '';
    _surveyNumberController.text = p.features['surveyNumber'] as String? ?? '';
    // Commercial specific field population
    _entranceWidthController.text =
        (p.features['entranceWidth'] as num?)?.toStringAsFixed(0) ?? '';
    _ceilingHeightController.text =
        (p.features['ceilingHeight'] as num?)?.toStringAsFixed(0) ?? '';
    _washroomsController.text =
        (p.features['washrooms'] as int? ?? p.specifications.bathrooms ?? 1)
            .toString();
    _parkingSpacesController.text = (p.features['parkingSpaces'] as int? ?? 1)
        .toString();
    _powerLoadController.text = p.features['powerLoad'] as String? ?? '';
    _waterSupplyController.text =
        p.features['waterSupply'] as String? ?? '24/7 Supply';
    _countryController.text = p.features['country'] as String? ?? 'India';
    _stateController.text = p.state;
    _districtController.text = p.district;
    _cityController.text = p.city;
    _localityController.text = p.locality;
    _streetController.text = p.address;
    _pincodeController.text = p.pincode;
    _latitudeController.text = (p.latitude ?? 15.8497).toString();
    _longitudeController.text = (p.longitude ?? 74.4977).toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _balconiesController.dispose();
    _floorNumberController.dispose();
    _totalFloorsController.dispose();
    _facingDirectionController.dispose();
    _carpetAreaController.dispose();
    _builtUpAreaController.dispose();
    _superBuiltUpAreaController.dispose();
    _plotAreaController.dispose();
    _securityDepositController.dispose();
    _maintenanceChargeController.dispose();
    _leaseAmountController.dispose();
    _leaseDurationController.dispose();
    _availabilityDateController.dispose();
    // Plot / Land specific
    _plotLengthController.dispose();
    _plotWidthController.dispose();
    _roadWidthController.dispose();
    _plotFacingController.dispose();
    _numberOfRoadsController.dispose();
    // Raw Land specific
    _soilTypeController.dispose();
    _waterSourceController.dispose();
    _borewellCountController.dispose();
    _electricityTypeController.dispose();
    _roadAccessTypeController.dispose();
    _fencingTypeController.dispose();
    _existingCropsTreesController.dispose();
    _surveyNumberController.dispose();
    // Commercial specific
    _entranceWidthController.dispose();
    _ceilingHeightController.dispose();
    _washroomsController.dispose();
    _parkingSpacesController.dispose();
    _powerLoadController.dispose();
    _waterSupplyController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<bool> _confirmExitOrSaveDraft() async {
    final formState = ref.read(propertyFormNotifierProvider);
    if (formState.status == PropertyFormStatus.editing ||
        formState.title.isNotEmpty) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppDesignSystem.surfaceBg(context),
          title: Text(
            'Save Draft before leaving?',
            style: TextStyle(color: AppDesignSystem.textP(context)),
          ),
          content: Text(
            'You have unsaved property changes. Would you like to save as draft or discard?',
            style: TextStyle(color: AppDesignSystem.textS(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
              ),
              onPressed: () async {
                final currentUserId =
                    FirebaseAuth.instance.currentUser?.uid ??
                    AuthSessionStorageHelper.getUserUid() ??
                    '';
                if (currentUserId.isNotEmpty) {
                  await ref
                      .read(propertyFormNotifierProvider.notifier)
                      .saveDraft(currentUserId);
                  ref
                      .read(myPropertiesNotifierProvider.notifier)
                      .fetchMyProperties(currentUserId);
                }
                if (mounted) Navigator.pop(context, true);
              },
              child: const Text(
                'Save Draft',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  void _handleStepBack() async {
    final formState = ref.read(propertyFormNotifierProvider);
    if (formState.currentStep > 0) {
      ref
          .read(propertyFormNotifierProvider.notifier)
          .setStep(formState.currentStep - 1);
    } else {
      final shouldExit = await _confirmExitOrSaveDraft();
      if (shouldExit && mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(propertyFormNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleStepBack();
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.scaffoldBg(context),
        appBar: AppBar(
          backgroundColor: AppDesignSystem.surfaceBg(context),
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppDesignSystem.textP(context),
            ),
            onPressed: _handleStepBack,
          ),
          title: Text(
            widget.editProperty != null ? 'Edit Property' : 'Post New Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: AppDesignSystem.textP(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _handleSaveDraft(context),
              child: const Text(
                'Save Draft',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.brandGold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildWizardProgressBar(formState.currentStep),
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
      ),
    );
  }

  Widget _buildWizardProgressBar(int currentStep) {
    final stepTitles = [
      'Category',
      'Basic Details',
      'Location',
      'Price & Area',
      'Amenities',
      'Media',
      'Preview',
      'Submit',
    ];
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Container(
      color: surfaceBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: List.generate(8, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 7 ? 4.0 : 0.0),
                  decoration: BoxDecoration(
                    color: isActive ? AppDesignSystem.brandGold : borderCol,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of 8: ${stepTitles[currentStep]}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textP,
                ),
              ),
              Text(
                'Completion: ${ref.read(propertyFormNotifierProvider.notifier).calculateCompletionScore()}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppDesignSystem.brandGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(PropertyFormState state) {
    return switch (state.currentStep) {
      0 => _buildStep1PropertyType(state),
      1 => _buildStep2BasicDetails(state),
      2 => _buildStep3Location(state),
      3 => _buildStep4PriceAndArea(state),
      4 => _buildStep5Amenities(state),
      5 => _buildStep6Media(state),
      6 => _buildStep7Preview(state),
      7 => _buildStep8Submit(state),
      _ => _buildStep1PropertyType(state),
    };
  }

  // ─── STEP 1: PROPERTY CATEGORY & TYPE ────────────────────────────────────────

  Widget _buildStep1PropertyType(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);

    final categories = [
      (
        PropertyCategory.residential,
        'Residential',
        'Apartments, Villas, Houses',
        Icons.home_work_rounded,
        PropertySubtype.apartment,
      ),
      (
        PropertyCategory.plotLand,
        'Plots & Layouts',
        'Residential & Commercial Plots',
        Icons.landscape_rounded,
        PropertySubtype.residentialPlot,
      ),
      (
        PropertyCategory.commercial,
        'Commercial',
        'Shops, Showrooms, Offices',
        Icons.business_rounded,
        PropertySubtype.commercialShop,
      ),
      (
        PropertyCategory.land,
        'Raw Land',
        'Agricultural & Farm Land',
        Icons.terrain_rounded,
        PropertySubtype.agriculturalLand,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1 of 8: Select Category & Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the primary category and subtype for your property listing in Belagavi.',
          style: TextStyle(fontSize: 13, color: textS),
        ),
        const SizedBox(height: 20),

        Text(
          'Primary Category *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textP,
          ),
        ),
        const SizedBox(height: 12),

        // 4 Large Category Cards Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: categories.map((catItem) {
            final isSelected = state.category == catItem.$1;
            return GestureDetector(
              onTap: () {
                notifier.updatePropertyType(
                  category: catItem.$1,
                  type: catItem.$5,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppDesignSystem.brandGold.withValues(
                          alpha: isDark ? 0.25 : 0.12,
                        )
                      : (isDark
                            ? const Color(0xFF1B2330)
                            : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppDesignSystem.brandGold
                        : AppDesignSystem.borderCol(context),
                    width: isSelected ? 2 : 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppDesignSystem.brandGold
                                : (isDark
                                      ? const Color(0xFF131922)
                                      : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            catItem.$4,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : AppDesignSystem.brandGold,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppDesignSystem.brandGold,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      catItem.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      catItem.$3,
                      style: TextStyle(fontSize: 10, color: textS),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),

        Text(
          'Property Sub-Type *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textP,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _getAvailableSubtypes(state.category).map((sub) {
            final label = switch (sub) {
              PropertySubtype.apartment => 'Flat / Apartment',
              PropertySubtype.villa => 'Independent Villa',
              PropertySubtype.independentHouse => 'House / Bungalow',
              PropertySubtype.rowHouse => 'Row House',
              PropertySubtype.penthouse => 'Penthouse',
              PropertySubtype.commercialShop => 'Commercial Shop',
              PropertySubtype.commercialOffice => 'Commercial Office',
              PropertySubtype.commercialShowroom => 'Showroom',
              PropertySubtype.warehouse ||
              PropertySubtype.warehouseGodown => 'Warehouse / Godown',
              PropertySubtype.residentialPlot => 'Residential Plot',
              PropertySubtype.commercialPlot => 'Commercial Plot',
              PropertySubtype.agriculturalLand => 'Agricultural Land',
              PropertySubtype.industrialLand => 'Industrial Land',
              PropertySubtype.naLand => 'NA Approved Land',
              PropertySubtype.nonNaLand => 'Non-NA Land',
              PropertySubtype.plot => 'Plot / Layout',
              PropertySubtype.builderProject ||
              PropertySubtype.builderApartmentProject => 'Builder Project',
              PropertySubtype.builderGatedCommunity => 'Gated Community',
              _ => 'Other',
            };
            return _buildChoiceChip(label, state.type == sub, () {
              notifier.updatePropertyType(category: state.category, type: sub);
            });
          }).toList(),
        ),
        const SizedBox(height: 22),

        Text(
          'Listing Purpose *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textP,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                'For Sale',
                state.listingType == 'FOR_SALE',
                () => notifier.updateBasicDetails(listingType: 'FOR_SALE'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildChoiceChip(
                'For Rent',
                state.listingType == 'FOR_RENT',
                () => notifier.updateBasicDetails(listingType: 'FOR_RENT'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildChoiceChip(
                'Lease',
                state.listingType == 'LEASE',
                () => notifier.updateBasicDetails(listingType: 'LEASE'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<PropertySubtype> _getAvailableSubtypes(PropertyCategory category) {
    return switch (category) {
      PropertyCategory.residential => [
        PropertySubtype.apartment,
        PropertySubtype.villa,
        PropertySubtype.independentHouse,
        PropertySubtype.rowHouse,
        PropertySubtype.penthouse,
      ],
      PropertyCategory.commercial => [
        PropertySubtype.commercialOffice,
        PropertySubtype.commercialShop,
        PropertySubtype.commercialShowroom,
        PropertySubtype.warehouseGodown,
      ],
      PropertyCategory.plotLand => [
        PropertySubtype.residentialPlot,
        PropertySubtype.commercialPlot,
        PropertySubtype.naLand,
        PropertySubtype.plot,
      ],
      PropertyCategory.land => [
        PropertySubtype.agriculturalLand,
        PropertySubtype.nonNaLand,
        PropertySubtype.industrialLand,
      ],
      PropertyCategory.industrial => [
        PropertySubtype.warehouseGodown,
        PropertySubtype.commercialPlot,
      ],
      PropertyCategory.builderProject => [
        PropertySubtype.builderApartmentProject,
        PropertySubtype.builderGatedCommunity,
      ],
      _ => [PropertySubtype.other],
    };
  }

  // ─── STEP 2: BASIC DETAILS ──────────────────────────────────────────────────

  Widget _buildStep2BasicDetails(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);

    final isPlot = state.category == PropertyCategory.plotLand;
    final isLand = state.category == PropertyCategory.land;
    final isCommercial =
        state.category == PropertyCategory.commercial ||
        state.category == PropertyCategory.industrial;
    final isLandOrPlot = isPlot || isLand;
    final isResidential = !isPlot && !isLand && !isCommercial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Context Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2330) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppDesignSystem.brandGold, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(
                isResidential
                    ? Icons.home_work_rounded
                    : isPlot
                    ? Icons.landscape_rounded
                    : isCommercial
                    ? Icons.business_rounded
                    : Icons.terrain_rounded,
                color: AppDesignSystem.brandGold,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY: ${state.category.name.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppDesignSystem.brandGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${state.type.name} • ${state.listingType.replaceAll('_', ' ')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textP,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => notifier.setStep(0),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 28),
                ),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.brandGold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Step 2 of 8: Basic Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isCommercial
              ? 'Specify commercial specifications, floor details, and frontage.'
              : isPlot
              ? 'Provide plot dimensions, road width, and layout details.'
              : isLand
              ? 'Provide land survey number, soil, and irrigation details.'
              : 'Provide residential bedrooms, bathrooms, and floor specifications.',
          style: TextStyle(fontSize: 13, color: textS),
        ),
        const SizedBox(height: 18),

        _buildTextField(
          label: 'Property Title *',
          hint: isCommercial
              ? 'e.g. Prime Commercial Office Space on College Road'
              : isPlot
              ? 'e.g. 40x60 North Facing BUDA Approved Plot in Tilakwadi'
              : isLand
              ? 'e.g. 5 Acre Fertile Agricultural Farm Land in Sambra'
              : 'e.g. Luxurious 3 BHK Apartment in Tilakwadi',
          controller: _titleController,
          errorText: state.fieldErrors['title'],
          onChanged: (val) => notifier.updateBasicDetails(title: val),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: 'Property Description',
          hint: isCommercial
              ? 'Describe footfall, frontage, parking access, main road connectivity, power backup, etc.'
              : isPlot
              ? 'Describe layout approvals, road connectivity, corner advantage, water line, etc.'
              : isLand
              ? 'Describe soil quality, water source, crop history, road approach, RTC status, etc.'
              : 'Describe key highlights, ventilation, nearby landmarks, security, etc.',
          controller: _descriptionController,
          maxLines: 4,
          onChanged: (val) => notifier.updateBasicDetails(description: val),
        ),
        const SizedBox(height: 16),

        // ─── RESIDENTIAL ROOM COUNTS ──────────────────────────────────────────
        if (!isLandOrPlot && !isCommercial) ...[
          _buildTextField(
            label: 'Bedrooms (BHK)',
            hint: 'e.g. 2 or 3',
            controller: _bedroomsController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final n = int.tryParse(val) ?? 2;
              notifier.updateSpecifications(
                PropertySpecificationsEntity(
                  bedrooms: n,
                  bathrooms: state.specifications.bathrooms,
                  balconies: state.specifications.balconies,
                  floorNumber: state.specifications.floorNumber,
                  totalFloors: state.specifications.totalFloors,
                  furnishingStatus: state.specifications.furnishingStatus,
                  facingDirection: state.specifications.facingDirection,
                  carpetArea: state.specifications.carpetArea,
                  superBuiltUpArea: state.specifications.superBuiltUpArea,
                  areaUnit: state.specifications.areaUnit,
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Bathrooms',
            hint: 'e.g. 2',
            controller: _bathroomsController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final n = int.tryParse(val) ?? 2;
              notifier.updateSpecifications(
                PropertySpecificationsEntity(
                  bedrooms: state.specifications.bedrooms,
                  bathrooms: n,
                  balconies: state.specifications.balconies,
                  floorNumber: state.specifications.floorNumber,
                  totalFloors: state.specifications.totalFloors,
                  furnishingStatus: state.specifications.furnishingStatus,
                  facingDirection: state.specifications.facingDirection,
                  carpetArea: state.specifications.carpetArea,
                  superBuiltUpArea: state.specifications.superBuiltUpArea,
                  areaUnit: state.specifications.areaUnit,
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Balconies',
            hint: 'e.g. 1',
            controller: _balconiesController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final n = int.tryParse(val) ?? 1;
              notifier.updateSpecifications(
                PropertySpecificationsEntity(
                  bedrooms: state.specifications.bedrooms,
                  bathrooms: state.specifications.bathrooms,
                  balconies: n,
                  floorNumber: state.specifications.floorNumber,
                  totalFloors: state.specifications.totalFloors,
                  furnishingStatus: state.specifications.furnishingStatus,
                  facingDirection: state.specifications.facingDirection,
                  carpetArea: state.specifications.carpetArea,
                  superBuiltUpArea: state.specifications.superBuiltUpArea,
                  areaUnit: state.specifications.areaUnit,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // ─── COMMERCIAL DETAILS ───────────────────────────────────────────────
        if (isCommercial) ...[
          _buildTextField(
            label: 'Washrooms',
            hint: 'e.g. 2',
            controller: _washroomsController,
            keyboardType: TextInputType.number,
            onChanged: (val) =>
                notifier.updateCommercialDetails(washrooms: int.tryParse(val)),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Dedicated Parking Spaces',
            hint: 'e.g. 3 cars',
            controller: _parkingSpacesController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateCommercialDetails(
              parkingSpaces: int.tryParse(val),
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Entrance / Frontage Width (ft)',
            hint: 'e.g. 20',
            controller: _entranceWidthController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateCommercialDetails(
              entranceWidth: double.tryParse(val),
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Ceiling Height (ft)',
            hint: 'e.g. 12',
            controller: _ceilingHeightController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateCommercialDetails(
              ceilingHeight: double.tryParse(val),
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Power Load',
            hint: 'e.g. 10 KVA / 3-Phase',
            controller: _powerLoadController,
            onChanged: (val) =>
                notifier.updateCommercialDetails(powerLoad: val),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Water Supply',
            hint: 'e.g. 24/7 Corporation Water',
            controller: _waterSupplyController,
            onChanged: (val) =>
                notifier.updateCommercialDetails(waterSupply: val),
          ),
          const SizedBox(height: 16),
          Text(
            'Commercial Features',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textP,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildToggleChip(
                'Passenger / Goods Lift',
                state.hasLift,
                () => notifier.updateCommercialDetails(hasLift: !state.hasLift),
              ),
              _buildToggleChip(
                'Loading & Unloading Dock',
                state.hasLoadingDock,
                () => notifier.updateCommercialDetails(
                  hasLoadingDock: !state.hasLoadingDock,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // ─── FLOORS (Residential & Commercial) ────────────────────────────────
        if (!isLandOrPlot) ...[
          _buildTextField(
            label: 'Floor Number',
            hint: 'e.g. 2',
            controller: _floorNumberController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final n = int.tryParse(val) ?? 1;
              notifier.updateSpecifications(
                PropertySpecificationsEntity(
                  bedrooms: state.specifications.bedrooms,
                  bathrooms: state.specifications.bathrooms,
                  balconies: state.specifications.balconies,
                  floorNumber: n,
                  totalFloors: state.specifications.totalFloors,
                  furnishingStatus: state.specifications.furnishingStatus,
                  facingDirection: state.specifications.facingDirection,
                  carpetArea: state.specifications.carpetArea,
                  superBuiltUpArea: state.specifications.superBuiltUpArea,
                  areaUnit: state.specifications.areaUnit,
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Total Floors',
            hint: 'e.g. 5',
            controller: _totalFloorsController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final n = int.tryParse(val) ?? 5;
              notifier.updateSpecifications(
                PropertySpecificationsEntity(
                  bedrooms: state.specifications.bedrooms,
                  bathrooms: state.specifications.bathrooms,
                  balconies: state.specifications.balconies,
                  floorNumber: state.specifications.floorNumber,
                  totalFloors: n,
                  furnishingStatus: state.specifications.furnishingStatus,
                  facingDirection: state.specifications.facingDirection,
                  carpetArea: state.specifications.carpetArea,
                  superBuiltUpArea: state.specifications.superBuiltUpArea,
                  areaUnit: state.specifications.areaUnit,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // ─── FACING DIRECTION ────────────────────────────────────────────────
        if (!isLandOrPlot) ...[
          const Text(
            'Facing Direction',
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
            children:
                [
                  'East',
                  'West',
                  'North',
                  'South',
                  'North-East',
                  'North-West',
                  'South-East',
                  'South-West',
                ].map((dir) {
                  final isSelected =
                      state.specifications.facingDirection == dir;
                  return _buildChoiceChip(dir, isSelected, () {
                    _facingDirectionController.text = dir;
                    notifier.updateSpecifications(
                      PropertySpecificationsEntity(
                        bedrooms: state.specifications.bedrooms,
                        bathrooms: state.specifications.bathrooms,
                        balconies: state.specifications.balconies,
                        floorNumber: state.specifications.floorNumber,
                        totalFloors: state.specifications.totalFloors,
                        furnishingStatus: state.specifications.furnishingStatus,
                        facingDirection: dir,
                        carpetArea: state.specifications.carpetArea,
                        superBuiltUpArea: state.specifications.superBuiltUpArea,
                        areaUnit: state.specifications.areaUnit,
                      ),
                    );
                  });
                }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // ─── FURNISHING STATUS ────────────────────────────────────────────────
        if (!isLandOrPlot) ...[
          const Text(
            'Furnishing Status',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                (isCommercial
                        ? [
                            'Bare Shell',
                            'Warm Shell',
                            'Semi-Furnished',
                            'Fully Furnished',
                          ]
                        : ['Unfurnished', 'Semi-Furnished', 'Fully Furnished'])
                    .map((f) {
                      final isSelected =
                          state.specifications.furnishingStatus == f;
                      return _buildChoiceChip(f, isSelected, () {
                        notifier.updateSpecifications(
                          PropertySpecificationsEntity(
                            furnishingStatus: f,
                            bedrooms: state.specifications.bedrooms,
                            bathrooms: state.specifications.bathrooms,
                            balconies: state.specifications.balconies,
                            floorNumber: state.specifications.floorNumber,
                            totalFloors: state.specifications.totalFloors,
                            facingDirection:
                                state.specifications.facingDirection,
                            carpetArea: state.specifications.carpetArea,
                            superBuiltUpArea:
                                state.specifications.superBuiltUpArea,
                            areaUnit: state.specifications.areaUnit,
                          ),
                        );
                      });
                    })
                    .toList(),
          ),
        ],
      ],
    );
  }

  // ─── STEP 3: LOCATION ──────────────────────────────────────────────────────

  Widget _buildStep3Location(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    final belagaviLocalities = [
      'Tilakwadi',
      'Hindwadi',
      'Shahapur',
      'Khanapur Road',
      'Sambra',
      'Udyambag',
      'Camp',
      'Mandoli Road',
      'Kuvempu Nagar',
      'Angol',
      'Vadgaon',
      'Rani Chennamma Circle',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3 of 8: Location Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Specify public locality and private protected site location.',
          style: TextStyle(fontSize: 13, color: textS),
        ),
        const SizedBox(height: 20),

        // Quick Belagavi Localities Selection
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.near_me_rounded,
                    size: 16,
                    color: AppDesignSystem.brandGold,
                  ),
                  SizedBox(width: 8),
                  const Text(
                    'QUICK BELAGAVI LOCALITIES',
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppDesignSystem.brandGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: belagaviLocalities.map((loc) {
                  final isSelected =
                      _localityController.text.trim().toLowerCase() ==
                      loc.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      _localityController.text = loc;
                      _cityController.text = 'Belagavi';
                      _districtController.text = 'Belagavi';
                      _stateController.text = 'Karnataka';
                      _countryController.text = 'India';
                      notifier.updateLocation(
                        city: 'Belagavi',
                        district: 'Belagavi',
                        stateName: 'Karnataka',
                        country: 'India',
                        locality: loc,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppDesignSystem.brandGold
                            : (isDark
                                  ? const Color(0xFF1B2330)
                                  : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppDesignSystem.brandGold
                              : borderCol,
                        ),
                      ),
                      child: Text(
                        loc,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected ? Colors.white : textP,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.public_rounded,
                    color: AppDesignSystem.brandGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PUBLIC LOCATION (Visible to Buyers)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textP,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Country',
                      controller: _countryController,
                      onChanged: (val) => notifier.updateLocation(country: val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'State / Province',
                      controller: _stateController,
                      onChanged: (val) =>
                          notifier.updateLocation(stateName: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'District / Region',
                      controller: _districtController,
                      onChanged: (val) =>
                          notifier.updateLocation(district: val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'City *',
                      controller: _cityController,
                      errorText: state.fieldErrors['city'],
                      onChanged: (val) => notifier.updateLocation(city: val),
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
              _buildTextField(
                label: 'Pincode',
                hint: 'e.g. 590001',
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                onChanged: (val) => notifier.updateLocation(pincode: val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Coordinates & Map Pin Section
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_pin,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Map Coordinates (Zero-Cost Deep Link)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textP,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Buyers can navigate directly to the property via Google Maps / Apple Maps at zero recurring API cost.',
                style: TextStyle(fontSize: 11.5, color: textS),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Latitude',
                      hint: 'e.g. 15.8497',
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => notifier.updateLocation(
                        latitude: double.tryParse(val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Longitude',
                      hint: 'e.g. 74.4977',
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => notifier.updateLocation(
                        longitude: double.tryParse(val),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final res = await InteractiveMapLocationPicker.show(
                      context,
                      initialLat:
                          double.tryParse(_latitudeController.text) ?? 15.8497,
                      initialLng:
                          double.tryParse(_longitudeController.text) ?? 74.4977,
                      initialCity: _cityController.text.isNotEmpty
                          ? _cityController.text
                          : 'Belagavi',
                      initialLocality: _localityController.text.isNotEmpty
                          ? _localityController.text
                          : 'Tilakwadi',
                    );
                    if (res != null) {
                      _latitudeController.text = res.latitude.toStringAsFixed(
                        4,
                      );
                      _longitudeController.text = res.longitude.toStringAsFixed(
                        4,
                      );
                      _localityController.text = res.locality;
                      _cityController.text = res.city;
                      _districtController.text = res.city;
                      _stateController.text = res.state;
                      _pincodeController.text = res.pincode;
                      _streetController.text = res.address;
                      notifier.updateLocation(
                        latitude: res.latitude,
                        longitude: res.longitude,
                        locality: res.locality,
                        city: res.city,
                        district: res.city,
                        stateName: res.state,
                        country: 'India',
                        pincode: res.pincode,
                        address: res.address,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.map_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Select Location on Map',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  final lat =
                      double.tryParse(_latitudeController.text) ?? 15.8497;
                  final lng =
                      double.tryParse(_longitudeController.text) ?? 74.4977;
                  GoogleMapsLauncher.launchLocationPin(
                    latitude: lat,
                    longitude: lng,
                    query:
                        '${_localityController.text}, ${_cityController.text}',
                  );
                },
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: AppDesignSystem.brandGold,
                ),
                label: const Text(
                  'Open in External Maps',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppDesignSystem.brandGold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E14) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(14),
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
                    'PROTECTED PRIVATE LOCATION',
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
                'Exact house number, street address, and private contact info are hidden from public view.',
                style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Street / Door / Flat Address (Protected)',
                hint: 'e.g. Door #45, 2nd Main Road',
                controller: _streetController,
                onChanged: (val) => notifier.updateLocation(address: val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STEP 4: PRICE & AREA ──────────────────────────────────────────────────

  Widget _buildStep4PriceAndArea(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final isLand =
        state.category == PropertyCategory.plotLand ||
        state.category == PropertyCategory.land;
    final isRent = state.listingType == 'FOR_RENT';
    final isLease = state.listingType == 'LEASE';
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 4 of 8: Price & Area Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isRent
              ? 'Specify monthly rent, deposit, and area measurements.'
              : isLease
              ? 'Specify lease premium, deposit, and area measurements.'
              : 'Specify sale price and area measurements.',
          style: TextStyle(fontSize: 13, color: textS),
        ),
        const SizedBox(height: 20),

        // ── Listing-type-aware pricing section ──────────────────────────────
        if (isRent) ...[
          // FOR_RENT: Monthly Rent + Security Deposit + Maintenance
          _buildTextField(
            label: 'Monthly Rent (₹) *',
            hint: 'e.g. 15000',
            controller: _priceController,
            keyboardType: TextInputType.number,
            errorText: state.fieldErrors['price'],
            onChanged: (val) =>
                notifier.updatePriceAndArea(price: double.tryParse(val) ?? 0.0),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Security Deposit (₹)',
            hint: 'e.g. 45000',
            controller: _securityDepositController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateRentLeaseDetails(
              securityDeposit: double.tryParse(val) ?? 0.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Maintenance / Month (₹)',
            hint: 'e.g. 2000',
            controller: _maintenanceChargeController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateRentLeaseDetails(
              maintenanceCharge: double.tryParse(val) ?? 0.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Availability',
            hint: 'e.g. Immediate, 15 Oct 2026',
            controller: _availabilityDateController,
            onChanged: (val) =>
                notifier.updateRentLeaseDetails(availabilityDate: val),
          ),
        ] else if (isLease) ...[
          // LEASE: Lease Amount + Duration + Deposit
          _buildTextField(
            label: 'Lease Premium / Total Amount (₹) *',
            hint: 'e.g. 500000',
            controller: _priceController,
            keyboardType: TextInputType.number,
            errorText: state.fieldErrors['price'],
            onChanged: (val) =>
                notifier.updatePriceAndArea(price: double.tryParse(val) ?? 0.0),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Lease Duration (months)',
            hint: 'e.g. 11, 36, 60',
            controller: _leaseDurationController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateRentLeaseDetails(
              leaseDuration: int.tryParse(val) ?? 11,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Security Deposit (₹)',
            hint: 'e.g. 100000',
            controller: _securityDepositController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateRentLeaseDetails(
              securityDeposit: double.tryParse(val) ?? 0.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Availability',
            hint: 'e.g. Immediate, 15 Oct 2026',
            controller: _availabilityDateController,
            onChanged: (val) =>
                notifier.updateRentLeaseDetails(availabilityDate: val),
          ),
        ] else ...[
          // FOR_SALE: Sale Price + Negotiable checkbox
          _buildTextField(
            label: 'Total Sale Price (₹) *',
            hint: 'e.g. 6500000',
            controller: _priceController,
            keyboardType: TextInputType.number,
            errorText: state.fieldErrors['price'],
            onChanged: (val) =>
                notifier.updatePriceAndArea(price: double.tryParse(val) ?? 0.0),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: state.isNegotiable,
                activeColor: AppDesignSystem.brandGold,
                onChanged: (val) =>
                    notifier.updatePriceAndArea(isNegotiable: val ?? true),
              ),
              Text(
                'Price is Negotiable',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textP,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),

        // ── Area Measurements (always shown) ───────────────────────────────
        Text(
          'Area Measurements *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textP,
          ),
        ),
        if (state.fieldErrors['area'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              state.fieldErrors['area']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 10),

        if (isLand) ...[
          _buildTextField(
            label: 'Plot / Land Area',
            hint: 'e.g. 1200 or 2.5',
            controller: _plotAreaController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updatePriceAndArea(
              plotArea: double.tryParse(val) ?? 0.0,
            ),
          ),
        ] else ...[
          _buildTextField(
            label: 'Carpet Area',
            hint: 'e.g. 1100',
            controller: _carpetAreaController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updatePriceAndArea(
              carpetArea: double.tryParse(val) ?? 0.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Built-up / Super Built-up Area',
            hint: 'e.g. 1450',
            controller: _builtUpAreaController,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updatePriceAndArea(
              builtUpArea: double.tryParse(val) ?? 0.0,
            ),
          ),
        ],
        const SizedBox(height: 16),

        Text(
          'Area Unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textP,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['sqft', 'sqm', 'acre', 'gunta', 'sqyard', 'guntha'].map((
            u,
          ) {
            final isSelected = state.specifications.areaUnit == u;
            return _buildChoiceChip(
              u.toUpperCase(),
              isSelected,
              () => notifier.updatePriceAndArea(areaUnit: u),
            );
          }).toList(),
        ),

        // ── Plot / Land Specific Details (only for Land/Plot category) ─────────
        if (isLand) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            state.type == PropertySubtype.agriculturalLand ||
                    state.type == PropertySubtype.nonNaLand ||
                    state.category == PropertyCategory.land
                ? 'Raw Land & Agricultural Details'
                : 'Plot Details',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.type == PropertySubtype.agriculturalLand ||
                    state.type == PropertySubtype.nonNaLand ||
                    state.category == PropertyCategory.land
                ? 'Soil type, water sources, irrigation, road access, and agricultural status.'
                : 'Dimensions, road access, and approvals help buyers quickly assess your plot.',
            style: const TextStyle(
              fontSize: 12,
              color: AppDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // RAW LAND SPECIFIC FIELDS
          if (state.type == PropertySubtype.agriculturalLand ||
              state.type == PropertySubtype.nonNaLand ||
              state.category == PropertyCategory.land) ...[
            // Soil Type
            const Text(
              'Soil Type',
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
              children:
                  [
                    'Red Soil',
                    'Black Cotton Soil',
                    'Alluvial Soil',
                    'Sandy Loam',
                    'Clay Loam',
                  ].map((s) {
                    final isSelected = state.soilType == s;
                    return _buildChoiceChip(s, isSelected, () {
                      _soilTypeController.text = s;
                      notifier.updatePlotDetails(soilType: s);
                    });
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Water Source & Irrigation
            const Text(
              'Water Source & Irrigation',
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
              children:
                  [
                    'Borewell',
                    'Canal Water',
                    'River Nearby',
                    'Open Well',
                    'Rainfed / Stream',
                  ].map((w) {
                    final isSelected = state.waterSource == w;
                    return _buildChoiceChip(w, isSelected, () {
                      _waterSourceController.text = w;
                      notifier.updatePlotDetails(waterSource: w);
                    });
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Electricity Connection
            const Text(
              'Electricity Connection',
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
              children:
                  [
                    '3-Phase Agri Power',
                    'Single Phase',
                    'Solar Powered',
                    'Near Transformer',
                    'None',
                  ].map((e) {
                    final isSelected = state.electricityType == e;
                    return _buildChoiceChip(e, isSelected, () {
                      _electricityTypeController.text = e;
                      notifier.updatePlotDetails(electricityType: e);
                    });
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Road Access Type
            const Text(
              'Road Access Type',
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
              children:
                  [
                    'Tar Road Frontage',
                    'Concrete Road',
                    'Mud / Katcha Road',
                    'Approach Right of Way',
                  ].map((r) {
                    final isSelected = state.roadAccessType == r;
                    return _buildChoiceChip(r, isSelected, () {
                      _roadAccessTypeController.text = r;
                      notifier.updatePlotDetails(roadAccessType: r);
                    });
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Fencing Type
            const Text(
              'Boundary & Fencing',
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
              children:
                  [
                    'Barbed Wire Fencing',
                    'Stone Compound',
                    'Bio-Fenced',
                    'Open / Unfenced',
                  ].map((f) {
                    final isSelected = state.fencingType == f;
                    return _buildChoiceChip(f, isSelected, () {
                      _fencingTypeController.text = f;
                      notifier.updatePlotDetails(fencingType: f);
                    });
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Trees, Crops & Plantations
            _buildTextField(
              label: 'Existing Crops / Trees / Plantations (Optional)',
              hint: 'e.g. Sugarcane crop, 120 Alphonso Mango Trees, Teakwood',
              controller: _existingCropsTreesController,
              onChanged: (val) =>
                  notifier.updatePlotDetails(existingCropsTrees: val),
            ),
            const SizedBox(height: 16),

            // Survey Number & Agricultural Status
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Survey No. / RTC Reference',
                    hint: 'e.g. Sy No. 154/2B',
                    controller: _surveyNumberController,
                    onChanged: (val) =>
                        notifier.updatePlotDetails(surveyNumber: val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Road Width (ft)',
                    hint: 'e.g. 20, 30',
                    controller: _roadWidthController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => notifier.updatePlotDetails(
                      roadWidth: double.tryParse(val),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Raw Land Feature Toggles
            const Text(
              'Land Infrastructure',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildToggleChip(
                  'Borewell Present',
                  state.hasBorewell,
                  () => notifier.updatePlotDetails(
                    hasBorewell: !state.hasBorewell,
                  ),
                ),
                _buildToggleChip(
                  'Farm House Present',
                  state.hasFarmHouse,
                  () => notifier.updatePlotDetails(
                    hasFarmHouse: !state.hasFarmHouse,
                  ),
                ),
                _buildToggleChip(
                  'Agricultural Land',
                  state.isAgricultural,
                  () => notifier.updatePlotDetails(
                    isAgricultural: !state.isAgricultural,
                  ),
                ),
                _buildToggleChip(
                  'NA Converted',
                  state.isNaConverted,
                  () => notifier.updatePlotDetails(
                    isNaConverted: !state.isNaConverted,
                  ),
                ),
                _buildToggleChip(
                  'Boundary Wall',
                  state.hasBoundaryWall,
                  () => notifier.updatePlotDetails(
                    hasBoundaryWall: !state.hasBoundaryWall,
                  ),
                ),
              ],
            ),
          ] else ...[
            // STANDARD PLOT FIELDS (Residential / Commercial Plot)
            // Dimensions row: Length × Width
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Plot Length (ft)',
                    hint: 'e.g. 30',
                    controller: _plotLengthController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final len = double.tryParse(val);
                      notifier.updatePlotDetails(plotLength: len);
                      final wid = double.tryParse(_plotWidthController.text);
                      if (len != null && wid != null && len > 0 && wid > 0) {
                        if (_plotAreaController.text.isEmpty ||
                            _plotAreaController.text == '0') {
                          final autoArea = len * wid;
                          _plotAreaController.text = autoArea.toStringAsFixed(
                            0,
                          );
                          notifier.updatePriceAndArea(plotArea: autoArea);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Plot Width (ft)',
                    hint: 'e.g. 40',
                    controller: _plotWidthController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final wid = double.tryParse(val);
                      notifier.updatePlotDetails(plotWidth: wid);
                      final len = double.tryParse(_plotLengthController.text);
                      if (len != null && wid != null && len > 0 && wid > 0) {
                        if (_plotAreaController.text.isEmpty ||
                            _plotAreaController.text == '0') {
                          final autoArea = len * wid;
                          _plotAreaController.text = autoArea.toStringAsFixed(
                            0,
                          );
                          notifier.updatePriceAndArea(plotArea: autoArea);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Road Width + Facing Direction
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Road Width (ft)',
                    hint: 'e.g. 20, 30, 40',
                    controller: _roadWidthController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => notifier.updatePlotDetails(
                      roadWidth: double.tryParse(val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Facing Direction',
                    hint: 'East, West, North, South',
                    controller: _plotFacingController,
                    onChanged: (val) =>
                        notifier.updatePlotDetails(facingDirection: val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Number of Roads
            const Text(
              'Roads Adjoining',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4].map((n) {
                final isSelected = state.numberOfRoads == n;
                return _buildChoiceChip(
                  '$n Side${n > 1 ? 's' : ''}',
                  isSelected,
                  () => notifier.updatePlotDetails(numberOfRoads: n),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Plot Flags
            const Text(
              'Plot Features',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildToggleChip(
                  'Corner Plot',
                  state.isCornerPlot,
                  () => notifier.updatePlotDetails(
                    isCornerPlot: !state.isCornerPlot,
                  ),
                ),
                _buildToggleChip(
                  'Gated Layout',
                  state.isGatedLayout,
                  () => notifier.updatePlotDetails(
                    isGatedLayout: !state.isGatedLayout,
                  ),
                ),
                _buildToggleChip(
                  'Boundary Wall',
                  state.hasBoundaryWall,
                  () => notifier.updatePlotDetails(
                    hasBoundaryWall: !state.hasBoundaryWall,
                  ),
                ),
                _buildToggleChip(
                  'NA Converted',
                  state.isNaConverted,
                  () => notifier.updatePlotDetails(
                    isNaConverted: !state.isNaConverted,
                  ),
                ),
                _buildToggleChip(
                  'Layout Approved',
                  state.isLayoutApproved,
                  () => notifier.updatePlotDetails(
                    isLayoutApproved: !state.isLayoutApproved,
                  ),
                ),
                _buildToggleChip(
                  'NA Approved Plot',
                  state.specifications.isNaApproved ?? false,
                  () => notifier.updatePlotDetails(
                    isNaApproved: !(state.specifications.isNaApproved ?? false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  // ─── STEP 5: AMENITIES ──────────────────────────────────────────────────────

  Widget _buildStep5Amenities(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final isCommercial =
        state.category == PropertyCategory.commercial ||
        state.category == PropertyCategory.industrial;
    final isRawLand =
        state.type == PropertySubtype.agriculturalLand ||
        state.type == PropertySubtype.nonNaLand ||
        state.category == PropertyCategory.land;
    final isLandOrPlot =
        state.category == PropertyCategory.plotLand ||
        state.category == PropertyCategory.land;

    final availableAmenities = isCommercial
        ? [
            'Dedicated Parking',
            'Visitor Parking',
            'High Speed Lift',
            'Goods / Service Lift',
            '24/7 Security & Guard',
            'CCTV Surveillance',
            '100% Power Backup',
            'Fire Safety / Sprinklers',
            '24/7 Water Supply',
            'Private Washroom',
            'Central Air Conditioning',
            'Reception / Lobby Area',
            'Loading & Unloading Dock',
            'Conference & Meeting Room',
            'Cafeteria / Pantry',
            'EV Charging Station',
          ]
        : isRawLand
        ? [
            '3-Phase Agri Power',
            'Borewell Water',
            'Canal / River Irrigation',
            'Farmhouse Structure',
            'Tractor / Vehicle Access',
            'Barbed Wire Fencing',
            'Drip Irrigation System',
            'Storage Shed / Godown',
            'Solar Water Pump',
            'Workers Quarter',
            'Natural Stream / Lake',
            'Motor Pump Room',
            'Security Cabin',
            'Tar Road Frontage',
          ]
        : isLandOrPlot
        ? [
            'Gated Layout',
            'Boundary Wall',
            '24/7 Water Connection',
            'Electricity Connection',
            'Street Lights',
            'Tar / Concrete Road',
            'Underground Drainage',
            'Park / Greenery',
            'Security Cabin',
          ]
        : [
            'Car Parking',
            'Lift / Elevator',
            '24/7 Security',
            'Power Backup',
            'Gymnasium',
            'Swimming Pool',
            'Garden / Park',
            'Clubhouse',
            'CCTV Camera',
            'Water Supply 24/7',
            'Intercom Facility',
            'EV Charging',
            'Children Play Area',
            'Rainwater Harvesting',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 5 of 8: Property Amenities',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isCommercial
              ? 'Select key commercial amenities, utilities, and infrastructure.'
              : 'Select available features and amenities for your property.',
          style: const TextStyle(
            fontSize: 13,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableAmenities.map((amenity) {
            final isSelected = state.amenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              selectedColor: AppDesignSystem.primaryNavy.withValues(
                alpha: 0.15,
              ),
              checkmarkColor: AppDesignSystem.primaryNavy,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppDesignSystem.primaryNavy
                    : AppDesignSystem.textPrimary,
              ),
              onSelected: (_) => notifier.toggleAmenity(amenity),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── STEP 6: MEDIA ──────────────────────────────────────────────────────────

  Widget _buildStep6Media(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final isDark = AppDesignSystem.isDark(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    final photoCount = state.mediaList
        .where((m) => m.type == MediaType.image)
        .length;
    final meetsDraft = photoCount >= 1;
    final meetsPublish = photoCount >= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 6 of 8: Property Photos & Media',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Upload high-resolution property photos, videos, or private legal documents.',
          style: TextStyle(fontSize: 13, color: textS),
        ),
        const SizedBox(height: 16),

        // Photo Validation Requirement Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: meetsPublish
                ? const Color(0xFFD1FAE5)
                : (meetsDraft
                      ? const Color(0xFFFEF3C7)
                      : (isDark
                            ? const Color(0xFF1E1E14)
                            : const Color(0xFFFFFBEB))),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: meetsPublish
                  ? const Color(0xFF059669)
                  : (meetsDraft
                        ? const Color(0xFFD97706)
                        : AppDesignSystem.brandGold),
            ),
          ),
          child: Row(
            children: [
              Icon(
                meetsPublish
                    ? Icons.check_circle_rounded
                    : (meetsDraft
                          ? Icons.info_rounded
                          : Icons.add_photo_alternate_rounded),
                color: meetsPublish
                    ? const Color(0xFF059669)
                    : const Color(0xFFB45309),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meetsPublish
                      ? 'Photo requirements satisfied ($photoCount photos added).'
                      : (meetsDraft
                            ? '$photoCount/3 photos added. (1 photo is sufficient for draft, 3 photos required for publishing).'
                            : 'Minimum 1 photo for draft. Minimum 3 photos required before publishing.'),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: meetsPublish
                        ? const Color(0xFF065F46)
                        : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_isUploading) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            color: AppDesignSystem.brandGold,
          ),
          const SizedBox(height: 8),
          Text(
            _uploadStatusMessage,
            style: TextStyle(fontSize: 12, color: textS),
          ),
          const SizedBox(height: 16),
        ],

        // ─── ACTION BUTTONS ROW (REAL DEVICE MEDIA PICKERS) ────────────────
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _showAddPhotosModal(state),
              icon: const Icon(
                Icons.add_photo_alternate_rounded,
                size: 18,
                color: Colors.black,
              ),
              label: const Text(
                'Add Photos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _isUploading
                  ? null
                  : () => _takePhotoWithCamera(state),
              icon: const Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: AppDesignSystem.brandGold,
              ),
              label: const Text(
                'Take Photo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.brandGold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppDesignSystem.brandGold),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _isUploading ? null : () => _showAddVideoModal(state),
              icon: const Icon(
                Icons.videocam_rounded,
                size: 18,
                color: AppDesignSystem.brandGold,
              ),
              label: const Text(
                'Add Video',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.brandGold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppDesignSystem.brandGold),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (state.mediaList.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol, width: 1.2),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppDesignSystem.brandGold,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      size: 30,
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No Photos Uploaded Yet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload clear photos of the property to attract verified buyers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: textS),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isUploading
                            ? null
                            : () => _pickPhotosFromGallery(state),
                        icon: const Icon(
                          Icons.photo_library_rounded,
                          size: 16,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.brandGold,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _isUploading
                            ? null
                            : () => _takePhotoWithCamera(state),
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: AppDesignSystem.brandGold,
                        ),
                        label: const Text(
                          'Take Photo',
                          style: TextStyle(
                            color: AppDesignSystem.brandGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppDesignSystem.brandGold,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: state.mediaList.length,
            itemBuilder: (context, index) {
              final media = state.mediaList[index];

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: _buildMediaThumbnail(media),
                    ),
                  ),
                  // Cover Badge / Set Cover Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => notifier.setPrimaryImage(media.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: media.isCover
                              ? AppDesignSystem.primaryNavy
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          media.isCover ? '★ COVER' : 'Make Cover',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Delete Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.red,
                        ),
                        onPressed: () => notifier.removeMedia(media.id),
                      ),
                    ),
                  ),
                  // Order indicator
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),

        // Private Documents Section
        const Text(
          'Private Legal Documents (Optional)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload Title Deed, Khata, or Approval PDFs. Strictly private to owner & verified buyers.',
          style: const TextStyle(
            fontSize: 12,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: _isUploading ? null : () => _uploadDocDemo(state),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('Add Legal Document (PDF)'),
        ),

        if (state.documentList.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.documentList.length,
            itemBuilder: (context, index) {
              final doc = state.documentList[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(
                  doc.documentName ?? 'Property Legal Document',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(doc.documentType.name),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  onPressed: () => notifier.removeDocument(doc.id),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMediaThumbnail(PropertyMediaEntity media) {
    final isVideo = media.type == MediaType.video;
    if (isVideo) {
      return Container(
        color: const Color(0xFF1B2330),
        child: const Center(
          child: Icon(
            Icons.videocam_rounded,
            size: 40,
            color: AppDesignSystem.brandGold,
          ),
        ),
      );
    }
    return AppPropertyImage(
      imageUrl: media.mediaUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  final _mediaPicker = MediaPickerService();

  PropertyMediaUploadService get _mediaUploadService {
    if (getIt.isRegistered<PropertyMediaUploadService>()) {
      return getIt<PropertyMediaUploadService>();
    }
    final supabase = getIt.isRegistered<SupabaseService>()
        ? getIt<SupabaseService>()
        : SupabaseService();
    return PropertyMediaUploadService(supabase);
  }

  void _showAddPhotosModal(PropertyFormState state) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Property Photos',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textP,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Listings with clear photos usually get better buyer attention.',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 12,
                color: textS,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.black87,
                ),
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w700, color: textP),
              ),
              subtitle: Text(
                'Select one or more photos from your phone',
                style: TextStyle(fontSize: 12, color: textS),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhotosFromGallery(state);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.black87,
                ),
              ),
              title: Text(
                'Take Photo with Camera',
                style: TextStyle(fontWeight: FontWeight.w700, color: textP),
              ),
              subtitle: Text(
                'Open camera to take a photo of the property',
                style: TextStyle(fontSize: 12, color: textS),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _takePhotoWithCamera(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVideoModal(PropertyFormState state) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Property Video',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textP,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Short walkthrough videos help buyers inspect property layout.',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 12,
                color: textS,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.video_library_rounded,
                  color: Colors.black87,
                ),
              ),
              title: Text(
                'Choose Video from Gallery',
                style: TextStyle(fontWeight: FontWeight.w700, color: textP),
              ),
              subtitle: Text(
                'Select an existing walkthrough video',
                style: TextStyle(fontSize: 12, color: textS),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickVideoFromGallery(state);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Colors.black87,
                ),
              ),
              title: Text(
                'Record Video with Camera',
                style: TextStyle(fontWeight: FontWeight.w700, color: textP),
              ),
              subtitle: Text(
                'Record a walkthrough video now',
                style: TextStyle(fontSize: 12, color: textS),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _recordVideoWithCamera(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhotosFromGallery(PropertyFormState state) async {
    final pickedFiles = await _mediaPicker.pickPhotosFromGallery();
    if (pickedFiles.isEmpty) return;

    for (int i = 0; i < pickedFiles.length; i++) {
      final file = pickedFiles[i];
      await _uploadSelectedFile(
        state,
        file,
        isFirst: i == 0 && state.mediaList.isEmpty,
      );
    }
  }

  Future<void> _takePhotoWithCamera(PropertyFormState state) async {
    final photo = await _mediaPicker.takePhotoWithCamera();
    if (photo == null) return;

    await _uploadSelectedFile(state, photo, isFirst: state.mediaList.isEmpty);
  }

  Future<void> _pickVideoFromGallery(PropertyFormState state) async {
    final video = await _mediaPicker.pickVideoFromGallery();
    if (video == null) return;

    await _uploadSelectedFile(state, video, isFirst: false);
  }

  Future<void> _recordVideoWithCamera(PropertyFormState state) async {
    final video = await _mediaPicker.recordVideoWithCamera();
    if (video == null) return;

    await _uploadSelectedFile(state, video, isFirst: false);
  }

  Future<void> _uploadSelectedFile(
    PropertyFormState state,
    SelectedMediaFile file, {
    bool isFirst = false,
  }) async {
    final propId = state.id.isNotEmpty
        ? state.id
        : 'prop_${DateTime.now().millisecondsSinceEpoch}';
    final tempMediaId = 'med_${DateTime.now().millisecondsSinceEpoch}';
    final localUrl = file.path.isNotEmpty
        ? file.path
        : 'file://${file.fileName}';

    // 1. Immediately show local preview
    final initialMedia = PropertyMediaEntity(
      id: tempMediaId,
      propertyId: propId,
      mediaUrl: localUrl,
      type: file.type,
      isCover: isFirst || state.mediaList.isEmpty,
      displayOrder: state.mediaList.length,
      uploadedAt: DateTime.now(),
    );
    ref.read(propertyFormNotifierProvider.notifier).addMedia(initialMedia);

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.2;
      _uploadStatusMessage = 'Uploading ${file.fileName}...';
    });

    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ??
        AuthSessionStorageHelper.getUserUid() ??
        'usr_anonymous';

    try {
      final media = await _mediaUploadService.uploadMedia(
        uploadId: 'up_${DateTime.now().millisecondsSinceEpoch}',
        authenticatedUserId: currentUserId,
        ownerId: currentUserId,
        propertyId: propId,
        fileName: file.fileName,
        fileBytes: file.bytes,
        type: file.type,
        isCover: isFirst || state.mediaList.isEmpty,
        displayOrder: state.mediaList.length,
      );

      // Replace local placeholder with remote Supabase storage public URL
      final currentList = ref.read(propertyFormNotifierProvider).mediaList;
      final List<PropertyMediaEntity> updatedList = currentList
          .map<PropertyMediaEntity>((m) {
            if (m.id == tempMediaId) {
              return m.copyWith(id: media.id, mediaUrl: media.mediaUrl);
            }
            return m;
          })
          .toList();

      ref
          .read(propertyFormNotifierProvider.notifier)
          .updateMediaList(updatedList);

      setState(() {
        _isUploading = false;
        _uploadProgress = 1.0;
        _uploadStatusMessage = 'Uploaded ${file.fileName}';
      });
    } catch (e) {
      AppLogger.w('Storage upload error (retaining local preview): $e');
      setState(() {
        _isUploading = false;
        _uploadProgress = 1.0;
        _uploadStatusMessage = 'Saved locally to draft';
      });
    }
  }

  Future<void> _uploadDocDemo(PropertyFormState state) async {
    final newDoc = PropertyDocumentEntity(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: state.id.isEmpty ? 'temp' : state.id,
      documentType: PropertyDocumentType.titleDeed,
      documentName: 'Title_Deed.pdf',
      documentUrl:
          'https://supabase.mock.storage/property-documents/title_deed.pdf',
      uploadedBy:
          FirebaseAuth.instance.currentUser?.uid ??
          AuthSessionStorageHelper.getUserUid() ??
          '',
      verificationStatus: VerificationStatus.pending,
      uploadedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(propertyFormNotifierProvider.notifier).addDocument(newDoc);
  }

  // ─── STEP 7: PREVIEW ────────────────────────────────────────────────────────

  Widget _buildStep7Preview(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    // Resolve listing purpose display
    final String purposeLabel;
    final Color purposeColor;
    switch (state.listingType) {
      case 'FOR_RENT':
        purposeLabel = 'For Rent';
        purposeColor = const Color(0xFF1E7BB5);
        break;
      case 'LEASE':
        purposeLabel = 'Lease';
        purposeColor = const Color(0xFF7B3FB5);
        break;
      default:
        purposeLabel = 'For Sale';
        purposeColor = const Color(0xFFB39037);
    }

    // Resolve price label
    final String priceLabel;
    switch (state.listingType) {
      case 'FOR_RENT':
        priceLabel = '\u20b9${state.price.toStringAsFixed(0)} / month';
        break;
      case 'LEASE':
        priceLabel = '\u20b9${state.price.toStringAsFixed(0)} (Lease)';
        break;
      default:
        priceLabel = '\u20b9${state.price.toStringAsFixed(0)}';
    }

    // Cover photo URL (first isCover, else first in list)
    final coverMedia = state.mediaList.isNotEmpty
        ? (state.mediaList.firstWhere(
            (m) => m.isCover,
            orElse: () => state.mediaList.first,
          ))
        : null;

    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 7 of 8: Listing Preview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Review how buyers will view your property listing.',
          style: TextStyle(fontSize: 13, color: textS),
        ),
        const SizedBox(height: 20),

        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
            boxShadow: AppDesignSystem.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover photo section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: coverMedia != null
                          ? _buildMediaThumbnail(coverMedia)
                          : GestureDetector(
                              onTap: () => notifier.setStep(5),
                              child: Container(
                                color: const Color(0xFFF1F5F9),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo_rounded,
                                      size: 36,
                                      color: AppDesignSystem.brandGold,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No photos added yet',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textP,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppDesignSystem.brandGold,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '+ Add Photos Now',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    // Listing purpose badge overlay
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: purposeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          purposeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (state.mediaList.isNotEmpty)
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${state.mediaList.length} photo${state.mediaList.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.title.isNotEmpty
                          ? state.title
                          : 'Untitled Property',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.locality.isNotEmpty ? state.locality : 'Locality'}, ${state.city}, ${state.state}',
                      style: TextStyle(fontSize: 12, color: textS),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      priceLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppDesignSystem.brandGold,
                      ),
                    ),
                    // Rent/lease extra info row
                    if (state.listingType == 'FOR_RENT' &&
                        state.securityDeposit > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Deposit: \u20b9${state.securityDeposit.toStringAsFixed(0)}  ·  Maintenance: \u20b9${state.maintenanceCharge.toStringAsFixed(0)}/mo',
                        style: TextStyle(fontSize: 12, color: textS),
                      ),
                      if (state.availabilityDate.isNotEmpty)
                        Text(
                          'Available: ${state.availabilityDate}',
                          style: TextStyle(fontSize: 12, color: textS),
                        ),
                    ],
                    if (state.listingType == 'LEASE' &&
                        state.securityDeposit > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Deposit: \u20b9${state.securityDeposit.toStringAsFixed(0)}  ·  Duration: ${state.leaseDuration} months',
                        style: TextStyle(fontSize: 12, color: textS),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (state.category == PropertyCategory.commercial ||
                            state.category == PropertyCategory.industrial) ...[
                          if (state.washrooms != null ||
                              state.specifications.bathrooms != null) ...[
                            const Icon(
                              Icons.wc_rounded,
                              size: 16,
                              color: AppDesignSystem.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${state.washrooms ?? state.specifications.bathrooms} Washroom${(state.washrooms ?? state.specifications.bathrooms ?? 1) > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                          if (state.parkingSpaces != null) ...[
                            const Icon(
                              Icons.local_parking_rounded,
                              size: 16,
                              color: AppDesignSystem.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${state.parkingSpaces} Parking',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ] else if (state.category ==
                                PropertyCategory.plotLand ||
                            state.category == PropertyCategory.land) ...[
                          if (state.waterSource != null &&
                              state.waterSource!.isNotEmpty) ...[
                            const Icon(
                              Icons.water_drop_outlined,
                              size: 16,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.waterSource!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                          if (state.soilType != null &&
                              state.soilType!.isNotEmpty) ...[
                            const Icon(
                              Icons.landscape_rounded,
                              size: 16,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.soilType!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ] else ...[
                          if (state.specifications.bedrooms != null) ...[
                            const Icon(
                              Icons.bed_rounded,
                              size: 16,
                              color: AppDesignSystem.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${state.specifications.bedrooms} Beds',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                          if (state.specifications.bathrooms != null) ...[
                            const Icon(
                              Icons.bathtub_outlined,
                              size: 16,
                              color: AppDesignSystem.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${state.specifications.bathrooms} Baths',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppDesignSystem.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ],
                        const Icon(
                          Icons.square_foot_rounded,
                          size: 16,
                          color: AppDesignSystem.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(state.specifications.plotArea ?? state.specifications.carpetArea ?? state.specifications.superBuiltUpArea ?? 0).toStringAsFixed(0)} ${state.specifications.areaUnit.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppDesignSystem.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.amenities.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: state.amenities
                            .take(5)
                            .map(
                              (a) => Chip(
                                label: Text(
                                  a,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        // Completeness check hint
        if (state.mediaList.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB45309),
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Add at least 1 photo before submitting for review.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── STEP 8: SUBMIT / SAVE DRAFT ────────────────────────────────────────────

  Widget _buildStep8Submit(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final completionScore = notifier.calculateCompletionScore();
    final missingFields = notifier.getMissingPublishFields();
    final hasErrors = state.fieldErrors.isNotEmpty || missingFields.isNotEmpty;
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 8 of 8: Save Draft or Submit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textP,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose whether to save as draft or submit for admin verification.',
          style: TextStyle(fontSize: 13, color: textS),
        ),
        const SizedBox(height: 20),

        // Deterministic Completion Score Card (Phase 14)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Listing Completion Score',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textP,
                    ),
                  ),
                  Text(
                    '$completionScore%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionScore / 100.0,
                  backgroundColor: borderCol,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionScore >= 80
                        ? const Color(0xFF16A34A)
                        : AppDesignSystem.brandGold,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                completionScore >= 80
                    ? 'Great! Your listing details are comprehensive and ready for submission.'
                    : 'Add more specifications, details and photos to maximize buyer inquiries.',
                style: TextStyle(fontSize: 12, color: textS),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Missing Fields Box (Phase 13)
        if (missingFields.isNotEmpty) ...[
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
                      Icons.info_outline_rounded,
                      color: Color(0xFFB45309),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Required before publishing:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...missingFields.map(
                  (field) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            field,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Note: You can still save this property as a Draft and complete it later.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Validation errors (if any runtime errors were set)
        if (hasErrors && state.fieldErrors.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.error_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Please fix the following before submitting:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...state.fieldErrors.values.map(
                  (msg) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            msg,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppDesignSystem.brandGold,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Listing Lifecycle Notice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textP,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Save Draft: Retains your listing in your My Properties workspace for future editing.\n'
                '• Submit for Review: Enters the verification workflow (DRAFT → SUBMITTED → UNDER_REVIEW → PUBLISHED).',
                style: TextStyle(fontSize: 12, color: textS, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required String label,
    String? hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? errorText,
    required ValueChanged<String> onChanged,
  }) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final inputBg = AppDesignSystem.inputBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textP,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: textP, fontSize: 14),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textS, fontSize: 13),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderCol),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderCol),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppDesignSystem.brandGold,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = AppDesignSystem.isDark(context);
    final textP = AppDesignSystem.textP(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignSystem.brandGold
              : (isDark ? const Color(0xFF1B2330) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppDesignSystem.brandGold : borderCol,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : textP,
          ),
        ),
      ),
    );
  }

  /// Toggle chip for boolean plot flags (e.g. Corner Plot, Gated Layout).
  Widget _buildToggleChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = AppDesignSystem.isDark(context);
    final textP = AppDesignSystem.textP(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF16A34A).withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF1B2330) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF16A34A),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF16A34A) : textP,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncAllControllersToState() {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final currentState = ref.read(propertyFormNotifierProvider);

    notifier.updateBasicDetails(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    notifier.updateLocation(
      country: _countryController.text.isNotEmpty
          ? _countryController.text
          : 'India',
      stateName: _stateController.text.isNotEmpty
          ? _stateController.text
          : 'Karnataka',
      district: _districtController.text.isNotEmpty
          ? _districtController.text
          : 'Belagavi',
      city: _cityController.text.isNotEmpty ? _cityController.text : 'Belagavi',
      locality: _localityController.text,
      address: _streetController.text.isNotEmpty
          ? _streetController.text
          : _localityController.text,
      pincode: _pincodeController.text.isNotEmpty
          ? _pincodeController.text
          : '590001',
    );

    final carpet = double.tryParse(_carpetAreaController.text) ?? 1000.0;
    final superBuilt =
        double.tryParse(_superBuiltUpAreaController.text) ?? 1400.0;
    final plot = double.tryParse(_plotAreaController.text) ?? 0.0;
    final priceVal =
        double.tryParse(_priceController.text) ?? currentState.price;

    notifier.updatePriceAndArea(
      price: priceVal,
      carpetArea: carpet,
      superBuiltUpArea: superBuilt,
      plotArea: plot,
    );

    notifier.updateSpecifications(
      PropertySpecificationsEntity(
        bedrooms: int.tryParse(_bedroomsController.text) ?? 2,
        bathrooms: int.tryParse(_bathroomsController.text) ?? 2,
        balconies: int.tryParse(_balconiesController.text) ?? 1,
        floorNumber: int.tryParse(_floorNumberController.text) ?? 1,
        totalFloors: int.tryParse(_totalFloorsController.text) ?? 5,
        furnishingStatus:
            currentState.specifications.furnishingStatus ?? 'Semi-Furnished',
        facingDirection: _facingDirectionController.text.isNotEmpty
            ? _facingDirectionController.text
            : 'East',
        carpetArea: carpet,
        superBuiltUpArea: superBuilt,
        plotArea: plot,
        areaUnit: currentState.specifications.areaUnit.isNotEmpty
            ? currentState.specifications.areaUnit
            : 'sqft',
      ),
    );

    notifier.updateRentLeaseDetails(
      securityDeposit: double.tryParse(_securityDepositController.text) ?? 0.0,
      maintenanceCharge:
          double.tryParse(_maintenanceChargeController.text) ?? 0.0,
      leaseAmount: double.tryParse(_leaseAmountController.text) ?? 0.0,
      leaseDuration: int.tryParse(_leaseDurationController.text) ?? 11,
      availabilityDate: _availabilityDateController.text,
    );

    notifier.updatePlotDetails(
      plotLength: double.tryParse(_plotLengthController.text),
      plotWidth: double.tryParse(_plotWidthController.text),
      roadWidth: double.tryParse(_roadWidthController.text),
      numberOfRoads: int.tryParse(_numberOfRoadsController.text) ?? 1,
      soilType: _soilTypeController.text,
      waterSource: _waterSourceController.text,
      borewellCount: int.tryParse(_borewellCountController.text) ?? 1,
      electricityType: _electricityTypeController.text,
      roadAccessType: _roadAccessTypeController.text,
      fencingType: _fencingTypeController.text,
      existingCropsTrees: _existingCropsTreesController.text,
      surveyNumber: _surveyNumberController.text,
    );

    notifier.updateCommercialDetails(
      entranceWidth: double.tryParse(_entranceWidthController.text),
      ceilingHeight: double.tryParse(_ceilingHeightController.text),
      washrooms: int.tryParse(_washroomsController.text) ?? 1,
      parkingSpaces: int.tryParse(_parkingSpacesController.text) ?? 1,
      powerLoad: _powerLoadController.text,
      waterSupply: _waterSupplyController.text,
    );
  }

  Widget _buildWizardNavigationButtons(PropertyFormState state) {
    final notifier = ref.read(propertyFormNotifierProvider.notifier);
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ??
        AuthSessionStorageHelper.getUserUid() ??
        '';
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: surfaceBg,
      child: Row(
        children: [
          if (state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _syncAllControllersToState();
                  notifier.setStep(state.currentStep - 1);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: textP,
                  side: BorderSide(color: AppDesignSystem.borderCol(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                _syncAllControllersToState();
                if (state.currentStep < 7) {
                  if (notifier.validateStep(state.currentStep)) {
                    notifier.setStep(state.currentStep + 1);
                  }
                } else {
                  if (currentUserId.isEmpty) {
                    _promptSignIn(
                      context,
                      actionMessage:
                          'Authentication is required to submit a property listing.',
                    );
                    return;
                  }
                  final success = await notifier.submitProperty(currentUserId);
                  if (success && mounted) {
                    final cat = state.category;
                    ref
                        .read(propertySearchNotifierProvider.notifier)
                        .executeSearch(
                          SearchQueryEntity(
                            country: 'India',
                            state: 'Karnataka',
                            city: 'Belagavi',
                            category: cat,
                          ),
                        );
                    ref
                        .read(myPropertiesNotifierProvider.notifier)
                        .fetchMyProperties(currentUserId);
                    _showSubmissionSuccessModal(context, state.id);
                  } else if (mounted) {
                    final formState = ref.read(propertyFormNotifierProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          formState.errorMessage ??
                              'Submission failed. Please verify required fields.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                state.currentStep == 7 ? 'Submit for Review' : 'Next Step',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmissionSuccessModal(BuildContext context, String propertyId) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: surfaceBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderCol),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Property Submitted Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: textP,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your listing is pending verification. Our team will review your property details before it appears in public marketplace searches.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 12,
                  color: textS,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    if (propertyId.isNotEmpty) {
                      context.push('/property/$propertyId');
                    } else {
                      context.go('/my-properties');
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
                  child: const Text(
                    'View Property',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    context.go('/my-properties');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textP,
                    side: BorderSide(color: borderCol),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('My Properties'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    context.go('/');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textS,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptSignIn(BuildContext context, {required String actionMessage}) {
    final catParam = switch (ref.read(propertyFormNotifierProvider).category) {
      PropertyCategory.residential => 'residential',
      PropertyCategory.plotLand => 'plotLand',
      PropertyCategory.commercial => 'commercial',
      PropertyCategory.land => 'land',
      _ => 'residential',
    };
    final target = '/add-property?category=$catParam';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131922),
        title: const Text(
          'Authentication Required',
          style: TextStyle(
            color: Color(0xFFFDFCF4),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '$actionMessage\n\nPlease log in or create an account to secure and save your property.',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.brandGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/auth?redirect=${Uri.encodeComponent(target)}');
            },
            child: const Text('Sign In / Register'),
          ),
        ],
      ),
    );
  }

  void _handleSaveDraft(BuildContext context) async {
    _syncAllControllersToState();
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ??
        AuthSessionStorageHelper.getUserUid() ??
        '';
    if (currentUserId.isEmpty) {
      _promptSignIn(
        context,
        actionMessage: 'Authentication is required to save a property draft.',
      );
      return;
    }
    final success = await ref
        .read(propertyFormNotifierProvider.notifier)
        .saveDraft(currentUserId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property draft saved successfully!')),
      );
      context.pop();
    } else if (mounted) {
      final formState = ref.read(propertyFormNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formState.errorMessage ??
                'Failed to save draft. Please check connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
