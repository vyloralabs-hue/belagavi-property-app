import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/repositories/property_repository.dart';

enum PropertyFormStatus {
  initial,
  editing,
  saving,
  saved,
  uploading,
  validationError,
  submitting,
  submitted,
  error,
}

class PropertyFormState extends Equatable {
  final int currentStep; // 0 to 7 (8 steps)
  final PropertyFormStatus status;
  final String? errorMessage;
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final PropertyCategory category;
  final PropertySubtype type;
  final String listingType; // 'FOR_SALE', 'FOR_RENT', 'LEASE'
  final ListingStatus listingStatus;
  final double price;
  final bool isNegotiable;
  // ─── Rent / Lease specific fields ───────────────────────────────────────────
  final double securityDeposit;   // FOR_RENT & LEASE
  final double maintenanceCharge; // FOR_RENT (monthly)
  final double leaseAmount;       // LEASE total premium
  final int leaseDuration;        // LEASE duration in months
  final String availabilityDate;  // FOR_RENT & LEASE (free-text, e.g. 'Immediate', 'Oct 2026')
  // ─── Plot / Land specific fields ─────────────────────────────────────────────
  final double? plotLength;        // in feet/meters
  final double? plotWidth;         // in feet/meters
  final double? roadWidth;         // Road facing width (in feet)
  final bool isCornerPlot;
  final bool isGatedLayout;
  final bool hasBoundaryWall;
  final int numberOfRoads;         // 1, 2, 3, 4 sides
  final bool isNaConverted;        // Non-Agricultural conversion done
  final bool isLayoutApproved;     // Layout approved by authority
  // ─── Raw Land specific fields ────────────────────────────────────────────────
  final String? soilType;          // Red soil, Black cotton soil, Alluvial, Loam
  final String? waterSource;       // Borewell, Canal, River, Open Well, Rainfed
  final bool hasBorewell;
  final int? borewellCount;
  final String? electricityType;   // 3-Phase Agri Power, Single Phase, Solar
  final String? roadAccessType;    // Tar Road, Concrete, Mud Road, Approach Right
  final String? fencingType;       // Barbed Wire, Stone Compound, Bio-Fenced, Open
  final bool hasFarmHouse;
  final String? existingCropsTrees;// Sugarcane, Paddy, Mango Plantation, Teak
  final String? surveyNumber;      // Sy No. / RTC Reference
  final bool isAgricultural;
  // ─── Commercial specific fields ──────────────────────────────────────────────
  final double? entranceWidth;     // Entrance frontage width (in feet)
  final double? ceilingHeight;     // Clear ceiling height (in feet)
  final int? washrooms;            // Number of private/common washrooms
  final int? parkingSpaces;        // Dedicated parking spots
  final bool hasLift;              // Passenger / Goods lift
  final bool hasLoadingDock;       // Loading / unloading access
  final String? powerLoad;         // Power capacity (e.g. 5 KVA, 25 HP)
  final String? waterSupply;       // 24/7 Water source availability
  // ─────────────────────────────────────────────────────────────────────────────
  final PropertySpecificationsEntity specifications;
  final List<PropertyMediaEntity> mediaList;
  final List<PropertyDocumentEntity> documentList;
  final List<String> amenities;
  final String country;
  final String state;
  final String district;
  final String taluk;
  final String city;
  final String locality;
  final String address;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final Map<String, String> fieldErrors;

  const PropertyFormState({
    this.currentStep = 0,
    this.status = PropertyFormStatus.initial,
    this.errorMessage,
    this.id = '',
    this.ownerId = '',
    this.title = '',
    this.description = '',
    this.category = PropertyCategory.residential,
    this.type = PropertySubtype.apartment,
    this.listingType = 'FOR_SALE',
    this.listingStatus = ListingStatus.draft,
    this.price = 0.0,
    this.isNegotiable = true,
    this.securityDeposit = 0.0,
    this.maintenanceCharge = 0.0,
    this.leaseAmount = 0.0,
    this.leaseDuration = 11,
    this.availabilityDate = 'Immediate',
    this.plotLength,
    this.plotWidth,
    this.roadWidth,
    this.isCornerPlot = false,
    this.isGatedLayout = false,
    this.hasBoundaryWall = false,
    this.numberOfRoads = 1,
    this.isNaConverted = false,
    this.isLayoutApproved = false,
    this.soilType,
    this.waterSource,
    this.hasBorewell = false,
    this.borewellCount,
    this.electricityType,
    this.roadAccessType,
    this.fencingType,
    this.hasFarmHouse = false,
    this.existingCropsTrees,
    this.surveyNumber,
    this.isAgricultural = false,
    this.entranceWidth,
    this.ceilingHeight,
    this.washrooms,
    this.parkingSpaces,
    this.hasLift = false,
    this.hasLoadingDock = false,
    this.powerLoad,
    this.waterSupply,
    this.specifications = const PropertySpecificationsEntity(),
    this.mediaList = const [],
    this.documentList = const [],
    this.amenities = const [],
    this.country = 'India',
    this.state = '',
    this.district = '',
    this.taluk = '',
    this.city = '',
    this.locality = '',
    this.address = '',
    this.pincode = '',
    this.latitude,
    this.longitude,
    this.fieldErrors = const {},
  });

  PropertyFormState copyWith({
    int? currentStep,
    PropertyFormStatus? status,
    String? errorMessage,
    String? id,
    String? ownerId,
    String? title,
    String? description,
    PropertyCategory? category,
    PropertySubtype? type,
    String? listingType,
    ListingStatus? listingStatus,
    double? price,
    bool? isNegotiable,
    double? securityDeposit,
    double? maintenanceCharge,
    double? leaseAmount,
    int? leaseDuration,
    String? availabilityDate,
    double? plotLength,
    double? plotWidth,
    double? roadWidth,
    bool? isCornerPlot,
    bool? isGatedLayout,
    bool? hasBoundaryWall,
    int? numberOfRoads,
    bool? isNaConverted,
    bool? isLayoutApproved,
    String? soilType,
    String? waterSource,
    bool? hasBorewell,
    int? borewellCount,
    String? electricityType,
    String? roadAccessType,
    String? fencingType,
    bool? hasFarmHouse,
    String? existingCropsTrees,
    String? surveyNumber,
    bool? isAgricultural,
    double? entranceWidth,
    double? ceilingHeight,
    int? washrooms,
    int? parkingSpaces,
    bool? hasLift,
    bool? hasLoadingDock,
    String? powerLoad,
    String? waterSupply,
    PropertySpecificationsEntity? specifications,
    List<PropertyMediaEntity>? mediaList,
    List<PropertyDocumentEntity>? documentList,
    List<String>? amenities,
    String? country,
    String? state,
    String? district,
    String? taluk,
    String? city,
    String? locality,
    String? address,
    String? pincode,
    double? latitude,
    double? longitude,
    Map<String, String>? fieldErrors,
  }) {
    return PropertyFormState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage,
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      listingType: listingType ?? this.listingType,
      listingStatus: listingStatus ?? this.listingStatus,
      price: price ?? this.price,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      maintenanceCharge: maintenanceCharge ?? this.maintenanceCharge,
      leaseAmount: leaseAmount ?? this.leaseAmount,
      leaseDuration: leaseDuration ?? this.leaseDuration,
      availabilityDate: availabilityDate ?? this.availabilityDate,
      plotLength: plotLength ?? this.plotLength,
      plotWidth: plotWidth ?? this.plotWidth,
      roadWidth: roadWidth ?? this.roadWidth,
      isCornerPlot: isCornerPlot ?? this.isCornerPlot,
      isGatedLayout: isGatedLayout ?? this.isGatedLayout,
      hasBoundaryWall: hasBoundaryWall ?? this.hasBoundaryWall,
      numberOfRoads: numberOfRoads ?? this.numberOfRoads,
      isNaConverted: isNaConverted ?? this.isNaConverted,
      isLayoutApproved: isLayoutApproved ?? this.isLayoutApproved,
      soilType: soilType ?? this.soilType,
      waterSource: waterSource ?? this.waterSource,
      hasBorewell: hasBorewell ?? this.hasBorewell,
      borewellCount: borewellCount ?? this.borewellCount,
      electricityType: electricityType ?? this.electricityType,
      roadAccessType: roadAccessType ?? this.roadAccessType,
      fencingType: fencingType ?? this.fencingType,
      hasFarmHouse: hasFarmHouse ?? this.hasFarmHouse,
      existingCropsTrees: existingCropsTrees ?? this.existingCropsTrees,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      isAgricultural: isAgricultural ?? this.isAgricultural,
      entranceWidth: entranceWidth ?? this.entranceWidth,
      ceilingHeight: ceilingHeight ?? this.ceilingHeight,
      washrooms: washrooms ?? this.washrooms,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      hasLift: hasLift ?? this.hasLift,
      hasLoadingDock: hasLoadingDock ?? this.hasLoadingDock,
      powerLoad: powerLoad ?? this.powerLoad,
      waterSupply: waterSupply ?? this.waterSupply,
      specifications: specifications ?? this.specifications,
      mediaList: mediaList ?? this.mediaList,
      documentList: documentList ?? this.documentList,
      amenities: amenities ?? this.amenities,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  PropertyEntity toEntity(String ownerId) {
    final effectiveId = id.isEmpty ? 'prop_${DateTime.now().millisecondsSinceEpoch}' : id;
    return PropertyEntity(
      id: effectiveId,
      ownerId: ownerId,
      title: title,
      description: description,
      category: category,
      type: type,
      status: listingStatus,
      verificationStatus: VerificationStatus.pending,
      price: price,
      isNegotiable: isNegotiable,
      specifications: specifications,
      mediaList: mediaList,
      state: state,
      district: district,
      taluk: taluk,
      city: city,
      locality: locality,
      address: address,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
      features: {
        // Both keys kept for forward/backward compatibility:
        // detail view reads 'listingType', legacy data may use 'purpose'
        'listingType': listingType,
        'purpose': listingType,
        'country': country,
        'amenities': amenities,
        // Rent / Lease specific fields stored in JSONB features map
        if (listingType == 'FOR_RENT' || listingType == 'LEASE') ...{
          'securityDeposit': securityDeposit,
          'availabilityDate': availabilityDate,
        },
        if (listingType == 'FOR_RENT') ...{
          'maintenanceCharge': maintenanceCharge,
        },
        if (listingType == 'LEASE') ...{
          'leaseAmount': leaseAmount,
          'leaseDuration': leaseDuration,
        },
        // Plot / Land / Raw Land specific fields — stored for plot/land categories
        if (category == PropertyCategory.plotLand || category == PropertyCategory.land) ...{
          if (plotLength != null) 'plotLength': plotLength,
          if (plotWidth != null) 'plotWidth': plotWidth,
          if (roadWidth != null) 'roadWidth': roadWidth,
          'isCornerPlot': isCornerPlot,
          'isGatedLayout': isGatedLayout,
          'hasBoundaryWall': hasBoundaryWall,
          'numberOfRoads': numberOfRoads,
          'isNaConverted': isNaConverted,
          'isLayoutApproved': isLayoutApproved,
          if (soilType != null && soilType!.isNotEmpty) 'soilType': soilType,
          if (waterSource != null && waterSource!.isNotEmpty) 'waterSource': waterSource,
          'hasBorewell': hasBorewell,
          if (borewellCount != null) 'borewellCount': borewellCount,
          if (electricityType != null && electricityType!.isNotEmpty) 'electricityType': electricityType,
          if (roadAccessType != null && roadAccessType!.isNotEmpty) 'roadAccessType': roadAccessType,
          if (fencingType != null && fencingType!.isNotEmpty) 'fencingType': fencingType,
          'hasFarmHouse': hasFarmHouse,
          if (existingCropsTrees != null && existingCropsTrees!.isNotEmpty) 'existingCropsTrees': existingCropsTrees,
          if (surveyNumber != null && surveyNumber!.isNotEmpty) 'surveyNumber': surveyNumber,
          'isAgricultural': isAgricultural,
        },
        // Commercial specific fields — stored for commercial/industrial categories
        if (category == PropertyCategory.commercial || category == PropertyCategory.industrial) ...{
          if (entranceWidth != null) 'entranceWidth': entranceWidth,
          if (ceilingHeight != null) 'ceilingHeight': ceilingHeight,
          if (washrooms != null) 'washrooms': washrooms,
          if (parkingSpaces != null) 'parkingSpaces': parkingSpaces,
          'hasLift': hasLift,
          'hasLoadingDock': hasLoadingDock,
          if (powerLoad != null && powerLoad!.isNotEmpty) 'powerLoad': powerLoad,
          if (waterSupply != null && waterSupply!.isNotEmpty) 'waterSupply': waterSupply,
        },
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        status,
        errorMessage,
        id,
        ownerId,
        title,
        description,
        category,
        type,
        listingType,
        listingStatus,
        price,
        isNegotiable,
        securityDeposit,
        maintenanceCharge,
        leaseAmount,
        leaseDuration,
        availabilityDate,
        plotLength,
        plotWidth,
        roadWidth,
        isCornerPlot,
        isGatedLayout,
        hasBoundaryWall,
        numberOfRoads,
        isNaConverted,
        isLayoutApproved,
        soilType,
        waterSource,
        hasBorewell,
        borewellCount,
        electricityType,
        roadAccessType,
        fencingType,
        hasFarmHouse,
        existingCropsTrees,
        surveyNumber,
        isAgricultural,
        entranceWidth,
        ceilingHeight,
        washrooms,
        parkingSpaces,
        hasLift,
        hasLoadingDock,
        powerLoad,
        waterSupply,
        specifications,
        mediaList,
        documentList,
        amenities,
        country,
        state,
        district,
        taluk,
        city,
        locality,
        address,
        pincode,
        latitude,
        longitude,
        fieldErrors,
      ];
}

class PropertyFormNotifier extends StateNotifier<PropertyFormState> {
  final PropertyRepository _repository;

  PropertyFormNotifier(this._repository) : super(const PropertyFormState());

  void initForNewProperty(String ownerId) {
    state = PropertyFormState(ownerId: ownerId);
  }

  void initForEditing(PropertyEntity property) {
    final rawAmenities = property.features['amenities'];
    List<String> amenitiesList = [];
    if (rawAmenities is List) {
      amenitiesList = rawAmenities.map((e) => e.toString()).toList();
    }

    // Resolve listingType from either key for backward compatibility
    final resolvedListingType =
        (property.features['listingType'] ?? property.features['purpose']) as String? ?? 'FOR_SALE';

    state = PropertyFormState(
      id: property.id,
      ownerId: property.ownerId,
      title: property.title,
      description: property.description,
      category: property.category,
      type: property.type,
      listingType: resolvedListingType,
      listingStatus: property.status,
      price: property.price,
      isNegotiable: property.isNegotiable,
      securityDeposit: (property.features['securityDeposit'] as num?)?.toDouble() ?? 0.0,
      maintenanceCharge: (property.features['maintenanceCharge'] as num?)?.toDouble() ?? 0.0,
      leaseAmount: (property.features['leaseAmount'] as num?)?.toDouble() ?? 0.0,
      leaseDuration: (property.features['leaseDuration'] as int?) ?? 11,
      availabilityDate: property.features['availabilityDate'] as String? ?? 'Immediate',
      // Plot / Land specific — restored from features JSONB
      plotLength: (property.features['plotLength'] as num?)?.toDouble(),
      plotWidth: (property.features['plotWidth'] as num?)?.toDouble(),
      roadWidth: (property.features['roadWidth'] as num?)?.toDouble(),
      isCornerPlot: property.features['isCornerPlot'] as bool? ?? false,
      isGatedLayout: property.features['isGatedLayout'] as bool? ?? false,
      hasBoundaryWall: property.features['hasBoundaryWall'] as bool? ?? false,
      numberOfRoads: (property.features['numberOfRoads'] as int?) ?? 1,
      isNaConverted: property.features['isNaConverted'] as bool? ?? false,
      isLayoutApproved: property.features['isLayoutApproved'] as bool? ?? false,
      soilType: property.features['soilType'] as String?,
      waterSource: property.features['waterSource'] as String?,
      hasBorewell: property.features['hasBorewell'] as bool? ?? false,
      borewellCount: property.features['borewellCount'] as int?,
      electricityType: property.features['electricityType'] as String?,
      roadAccessType: property.features['roadAccessType'] as String?,
      fencingType: property.features['fencingType'] as String?,
      hasFarmHouse: property.features['hasFarmHouse'] as bool? ?? false,
      existingCropsTrees: property.features['existingCropsTrees'] as String?,
      surveyNumber: property.features['surveyNumber'] as String?,
      isAgricultural: property.features['isAgricultural'] as bool? ?? (property.type == PropertySubtype.agriculturalLand),
      // Commercial specific — restored from features JSONB
      entranceWidth: (property.features['entranceWidth'] as num?)?.toDouble(),
      ceilingHeight: (property.features['ceilingHeight'] as num?)?.toDouble(),
      washrooms: property.features['washrooms'] as int? ?? property.specifications.bathrooms,
      parkingSpaces: property.features['parkingSpaces'] as int?,
      hasLift: property.features['hasLift'] as bool? ?? false,
      hasLoadingDock: property.features['hasLoadingDock'] as bool? ?? false,
      powerLoad: property.features['powerLoad'] as String?,
      waterSupply: property.features['waterSupply'] as String?,
      specifications: property.specifications,
      mediaList: property.mediaList,
      amenities: amenitiesList,
      country: property.features['country'] as String? ?? 'India',
      state: property.state,
      district: property.district,
      taluk: property.taluk,
      city: property.city,
      locality: property.locality,
      address: property.address,
      pincode: property.pincode,
      latitude: property.latitude,
      longitude: property.longitude,
      status: PropertyFormStatus.editing,
    );
  }

  void setStep(int step) {
    if (step >= 0 && step <= 7) {
      state = state.copyWith(currentStep: step);
    }
  }

  void updatePropertyType({
    required PropertyCategory category,
    required PropertySubtype type,
    String? listingType,
  }) {
    state = state.copyWith(
      category: category,
      type: type,
      listingType: listingType ?? state.listingType,
      status: PropertyFormStatus.editing,
    );
  }

  void updateBasicDetails({
    String? title,
    String? description,
    PropertyCategory? category,
    PropertySubtype? type,
    String? listingType,
    double? price,
    bool? isNegotiable,
  }) {
    state = state.copyWith(
      title: title ?? state.title,
      description: description ?? state.description,
      category: category ?? state.category,
      type: type ?? state.type,
      listingType: listingType ?? state.listingType,
      price: price ?? state.price,
      isNegotiable: isNegotiable ?? state.isNegotiable,
      status: PropertyFormStatus.editing,
    );
  }

  void updateSpecifications(PropertySpecificationsEntity specs) {
    final merged = PropertySpecificationsEntity(
      superBuiltUpArea: specs.superBuiltUpArea ?? state.specifications.superBuiltUpArea,
      carpetArea: specs.carpetArea ?? state.specifications.carpetArea,
      plotArea: specs.plotArea ?? state.specifications.plotArea,
      areaUnit: specs.areaUnit.isNotEmpty ? specs.areaUnit : state.specifications.areaUnit,
      bedrooms: specs.bedrooms ?? state.specifications.bedrooms,
      bathrooms: specs.bathrooms ?? state.specifications.bathrooms,
      balconies: specs.balconies ?? state.specifications.balconies,
      floorNumber: specs.floorNumber ?? state.specifications.floorNumber,
      totalFloors: specs.totalFloors ?? state.specifications.totalFloors,
      furnishingStatus: specs.furnishingStatus ?? state.specifications.furnishingStatus,
      facingDirection: specs.facingDirection ?? state.specifications.facingDirection,
      isNaApproved: specs.isNaApproved ?? state.specifications.isNaApproved,
    );
    state = state.copyWith(specifications: merged, status: PropertyFormStatus.editing);
  }

  void updateLocation({
    String? country,
    String? stateName,
    String? district,
    String? taluk,
    String? city,
    String? locality,
    String? address,
    String? pincode,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      country: country ?? state.country,
      state: stateName ?? state.state,
      district: district ?? state.district,
      taluk: taluk ?? state.taluk,
      city: city ?? state.city,
      locality: locality ?? state.locality,
      address: address ?? state.address,
      pincode: pincode ?? state.pincode,
      latitude: latitude ?? state.latitude,
      longitude: longitude ?? state.longitude,
      status: PropertyFormStatus.editing,
    );
  }

  void updatePriceAndArea({
    double? price,
    bool? isNegotiable,
    double? carpetArea,
    double? builtUpArea,
    double? superBuiltUpArea,
    double? plotArea,
    String? areaUnit,
  }) {
    final updatedSpecs = PropertySpecificationsEntity(
      carpetArea: carpetArea ?? state.specifications.carpetArea,
      // builtUpArea maps to superBuiltUpArea (the model's built-up proxy field)
      superBuiltUpArea: builtUpArea ?? superBuiltUpArea ?? state.specifications.superBuiltUpArea,
      plotArea: plotArea ?? state.specifications.plotArea,
      areaUnit: areaUnit ?? state.specifications.areaUnit,
      bedrooms: state.specifications.bedrooms,
      bathrooms: state.specifications.bathrooms,
      balconies: state.specifications.balconies,
      floorNumber: state.specifications.floorNumber,
      totalFloors: state.specifications.totalFloors,
      furnishingStatus: state.specifications.furnishingStatus,
      facingDirection: state.specifications.facingDirection,
      isNaApproved: state.specifications.isNaApproved,
    );

    state = state.copyWith(
      price: price ?? state.price,
      isNegotiable: isNegotiable ?? state.isNegotiable,
      specifications: updatedSpecs,
      status: PropertyFormStatus.editing,
    );
  }

  /// Update rent/lease specific pricing fields only.
  void updateRentLeaseDetails({
    double? securityDeposit,
    double? maintenanceCharge,
    double? leaseAmount,
    int? leaseDuration,
    String? availabilityDate,
  }) {
    state = state.copyWith(
      securityDeposit: securityDeposit ?? state.securityDeposit,
      maintenanceCharge: maintenanceCharge ?? state.maintenanceCharge,
      leaseAmount: leaseAmount ?? state.leaseAmount,
      leaseDuration: leaseDuration ?? state.leaseDuration,
      availabilityDate: availabilityDate ?? state.availabilityDate,
      status: PropertyFormStatus.editing,
    );
  }

  /// Update plot / land / raw land specific details.
  void updatePlotDetails({
    double? plotLength,
    double? plotWidth,
    double? roadWidth,
    bool? isCornerPlot,
    bool? isGatedLayout,
    bool? hasBoundaryWall,
    int? numberOfRoads,
    bool? isNaConverted,
    bool? isLayoutApproved,
    bool? isNaApproved,        // updates specifications.isNaApproved
    String? facingDirection,   // updates specifications.facingDirection
    String? soilType,
    String? waterSource,
    bool? hasBorewell,
    int? borewellCount,
    String? electricityType,
    String? roadAccessType,
    String? fencingType,
    bool? hasFarmHouse,
    String? existingCropsTrees,
    String? surveyNumber,
    bool? isAgricultural,
  }) {
    // Update specifications if plot-facing fields changed
    final updatedSpecs = (isNaApproved != null || facingDirection != null)
        ? PropertySpecificationsEntity(
            superBuiltUpArea: state.specifications.superBuiltUpArea,
            carpetArea: state.specifications.carpetArea,
            plotArea: state.specifications.plotArea,
            areaUnit: state.specifications.areaUnit,
            bedrooms: state.specifications.bedrooms,
            bathrooms: state.specifications.bathrooms,
            balconies: state.specifications.balconies,
            floorNumber: state.specifications.floorNumber,
            totalFloors: state.specifications.totalFloors,
            furnishingStatus: state.specifications.furnishingStatus,
            facingDirection: facingDirection ?? state.specifications.facingDirection,
            isNaApproved: isNaApproved ?? state.specifications.isNaApproved,
          )
        : null;

    state = state.copyWith(
      plotLength: plotLength ?? state.plotLength,
      plotWidth: plotWidth ?? state.plotWidth,
      roadWidth: roadWidth ?? state.roadWidth,
      isCornerPlot: isCornerPlot ?? state.isCornerPlot,
      isGatedLayout: isGatedLayout ?? state.isGatedLayout,
      hasBoundaryWall: hasBoundaryWall ?? state.hasBoundaryWall,
      numberOfRoads: numberOfRoads ?? state.numberOfRoads,
      isNaConverted: isNaConverted ?? state.isNaConverted,
      isLayoutApproved: isLayoutApproved ?? state.isLayoutApproved,
      soilType: soilType ?? state.soilType,
      waterSource: waterSource ?? state.waterSource,
      hasBorewell: hasBorewell ?? state.hasBorewell,
      borewellCount: borewellCount ?? state.borewellCount,
      electricityType: electricityType ?? state.electricityType,
      roadAccessType: roadAccessType ?? state.roadAccessType,
      fencingType: fencingType ?? state.fencingType,
      hasFarmHouse: hasFarmHouse ?? state.hasFarmHouse,
      existingCropsTrees: existingCropsTrees ?? state.existingCropsTrees,
      surveyNumber: surveyNumber ?? state.surveyNumber,
      isAgricultural: isAgricultural ?? state.isAgricultural,
      specifications: updatedSpecs ?? state.specifications,
      status: PropertyFormStatus.editing,
    );
  }

  /// Update commercial / industrial specific details.
  void updateCommercialDetails({
    double? entranceWidth,
    double? ceilingHeight,
    int? washrooms,
    int? parkingSpaces,
    bool? hasLift,
    bool? hasLoadingDock,
    String? powerLoad,
    String? waterSupply,
    String? furnishingStatus,
    String? facingDirection,
    int? floorNumber,
    int? totalFloors,
  }) {
    final updatedSpecs = (furnishingStatus != null ||
            facingDirection != null ||
            floorNumber != null ||
            totalFloors != null ||
            washrooms != null)
        ? PropertySpecificationsEntity(
            superBuiltUpArea: state.specifications.superBuiltUpArea,
            carpetArea: state.specifications.carpetArea,
            plotArea: state.specifications.plotArea,
            areaUnit: state.specifications.areaUnit,
            bedrooms: state.specifications.bedrooms,
            bathrooms: washrooms ?? state.specifications.bathrooms,
            balconies: state.specifications.balconies,
            floorNumber: floorNumber ?? state.specifications.floorNumber,
            totalFloors: totalFloors ?? state.specifications.totalFloors,
            furnishingStatus: furnishingStatus ?? state.specifications.furnishingStatus,
            facingDirection: facingDirection ?? state.specifications.facingDirection,
            isNaApproved: state.specifications.isNaApproved,
          )
        : null;

    state = state.copyWith(
      entranceWidth: entranceWidth ?? state.entranceWidth,
      ceilingHeight: ceilingHeight ?? state.ceilingHeight,
      washrooms: washrooms ?? state.washrooms,
      parkingSpaces: parkingSpaces ?? state.parkingSpaces,
      hasLift: hasLift ?? state.hasLift,
      hasLoadingDock: hasLoadingDock ?? state.hasLoadingDock,
      powerLoad: powerLoad ?? state.powerLoad,
      waterSupply: waterSupply ?? state.waterSupply,
      specifications: updatedSpecs ?? state.specifications,
      status: PropertyFormStatus.editing,
    );
  }

  void toggleAmenity(String amenity) {
    final list = List<String>.from(state.amenities);
    if (list.contains(amenity)) {
      list.remove(amenity);
    } else {
      list.add(amenity);
    }
    state = state.copyWith(amenities: list, status: PropertyFormStatus.editing);
  }

  void addMedia(PropertyMediaEntity media) {
    final isFirst = state.mediaList.isEmpty;
    final mediaToAdd = PropertyMediaEntity(
      id: media.id,
      propertyId: media.propertyId,
      mediaUrl: media.mediaUrl,
      type: media.type,
      displayOrder: state.mediaList.length,
      isCover: isFirst || media.isCover,
      caption: media.caption,
      uploadedAt: media.uploadedAt,
    );
    final updated = List<PropertyMediaEntity>.from(state.mediaList)..add(mediaToAdd);
    state = state.copyWith(mediaList: updated, status: PropertyFormStatus.editing);
  }

  void updateMediaList(List<PropertyMediaEntity> mediaList) {
    state = state.copyWith(mediaList: mediaList, status: PropertyFormStatus.editing);
  }

  void removeMedia(String mediaId) {
    final filtered = state.mediaList.where((m) => m.id != mediaId).toList();
    if (filtered.isEmpty) {
      state = state.copyWith(mediaList: const [], status: PropertyFormStatus.editing);
      return;
    }

    final hadCover = state.mediaList.any((m) => m.id == mediaId && m.isCover);
    final updated = filtered.asMap().entries.map((entry) {
      final index = entry.key;
      final m = entry.value;
      final shouldBeCover = hadCover ? index == 0 : m.isCover;
      return PropertyMediaEntity(
        id: m.id,
        propertyId: m.propertyId,
        mediaUrl: m.mediaUrl,
        type: m.type,
        displayOrder: index,
        isCover: shouldBeCover,
        caption: m.caption,
        uploadedAt: m.uploadedAt,
      );
    }).toList();

    state = state.copyWith(mediaList: updated, status: PropertyFormStatus.editing);
  }

  void setPrimaryImage(String mediaId) {
    final updated = state.mediaList.map<PropertyMediaEntity>((m) {
      final isNewCover = m.id == mediaId;
      return PropertyMediaEntity(
        id: m.id,
        propertyId: m.propertyId,
        mediaUrl: m.mediaUrl,
        type: m.type,
        displayOrder: isNewCover ? 0 : m.displayOrder + 1,
        isCover: isNewCover,
        caption: m.caption,
        uploadedAt: m.uploadedAt,
      );
    }).toList();
    
    // Sort so cover is first in array
    updated.sort((a, b) => a.isCover ? -1 : (b.isCover ? 1 : a.displayOrder.compareTo(b.displayOrder)));
    
    final reordered = updated.asMap().entries.map((e) {
      final m = e.value;
      return PropertyMediaEntity(
        id: m.id,
        propertyId: m.propertyId,
        mediaUrl: m.mediaUrl,
        type: m.type,
        displayOrder: e.key,
        isCover: m.isCover,
        caption: m.caption,
        uploadedAt: m.uploadedAt,
      );
    }).toList();

    state = state.copyWith(mediaList: reordered, status: PropertyFormStatus.editing);
  }

  void reorderMedia(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.mediaList.length) return;
    if (newIndex < 0 || newIndex > state.mediaList.length) return;
    
    var targetIndex = newIndex;
    if (oldIndex < targetIndex) targetIndex -= 1;

    final list = List<PropertyMediaEntity>.from(state.mediaList);
    final item = list.removeAt(oldIndex);
    list.insert(targetIndex, item);

    final reordered = list.asMap().entries.map((e) {
      final m = e.value;
      return PropertyMediaEntity(
        id: m.id,
        propertyId: m.propertyId,
        mediaUrl: m.mediaUrl,
        type: m.type,
        displayOrder: e.key,
        isCover: m.isCover,
        caption: m.caption,
        uploadedAt: m.uploadedAt,
      );
    }).toList();

    state = state.copyWith(mediaList: reordered, status: PropertyFormStatus.editing);
  }

  void replaceMedia(String oldMediaId, PropertyMediaEntity newMedia) {
    final updated = state.mediaList.map((m) {
      if (m.id == oldMediaId) {
        return PropertyMediaEntity(
          id: newMedia.id,
          propertyId: newMedia.propertyId,
          mediaUrl: newMedia.mediaUrl,
          type: newMedia.type,
          displayOrder: m.displayOrder,
          isCover: m.isCover,
          caption: newMedia.caption ?? m.caption,
          uploadedAt: newMedia.uploadedAt,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(mediaList: updated, status: PropertyFormStatus.editing);
  }

  void addDocument(PropertyDocumentEntity doc) {
    final updated = List<PropertyDocumentEntity>.from(state.documentList)..add(doc);
    state = state.copyWith(documentList: updated, status: PropertyFormStatus.editing);
  }

  void removeDocument(String docId) {
    final updated = state.documentList.where((d) => d.id != docId).toList();
    state = state.copyWith(documentList: updated, status: PropertyFormStatus.editing);
  }


  bool validateStep(int step) {
    final errors = <String, String>{};

    switch (step) {
      case 0: // Step 1: Property Type
        // Category & Type already defaulted — no validation needed
        break;

      case 1: // Step 2: Basic Details
        if (state.title.trim().isEmpty) {
          errors['title'] = 'Property title is required';
        }
        break;

      case 2: // Step 3: Location
        if (state.locality.trim().isEmpty) {
          errors['locality'] = 'Locality / Area is required';
        }
        if (state.city.trim().isEmpty) {
          errors['city'] = 'City is required';
        }
        break;

      case 3: // Step 4: Price & Area (listing-type-aware)
        if (state.listingType == 'FOR_RENT') {
          // For rent: price field holds Monthly Rent
          if (state.price <= 0) {
            errors['price'] = 'Please enter a valid monthly rent greater than 0';
          }
        } else if (state.listingType == 'LEASE') {
          // For lease: price field holds Lease Amount
          if (state.price <= 0) {
            errors['price'] = 'Please enter a valid lease amount greater than 0';
          }
        } else {
          // FOR_SALE
          if (state.price <= 0) {
            errors['price'] = 'Please enter a valid sale price greater than 0';
          }
        }
        final totalArea = (state.specifications.carpetArea ?? 0) +
            (state.specifications.superBuiltUpArea ?? 0) +
            (state.specifications.plotArea ?? 0);
        if (totalArea <= 0) {
          errors['area'] = 'Please enter a valid area greater than 0';
        }
        break;

      case 4: // Step 5: Amenities
        // Optional selection
        break;

      case 5: // Step 6: Media
        // Media optional for draft, required for submission
        break;

      case 6: // Step 7: Preview
        break;

      case 7: // Step 8: Submit / Review (full validation gate)
        if (state.title.trim().isEmpty) errors['title'] = 'Property title is required';
        if (state.locality.trim().isEmpty) errors['locality'] = 'Locality is required';
        // Price validation depends on listing type
        if (state.listingType == 'FOR_RENT') {
          if (state.price <= 0) errors['price'] = 'Monthly rent is required';
        } else {
          if (state.price <= 0) errors['price'] = 'Sale / lease price is required';
        }
        if (state.mediaList.isEmpty) {
          errors['media'] = 'Add at least one property photo to continue.';
        }
        break;
    }

    state = state.copyWith(
      fieldErrors: errors,
      status: errors.isNotEmpty ? PropertyFormStatus.validationError : state.status,
    );
    return errors.isEmpty;
  }

  Future<bool> saveDraft(String authenticatedUserId) async {
    state = state.copyWith(status: PropertyFormStatus.saving, listingStatus: ListingStatus.draft);
    final entity = state.toEntity(authenticatedUserId);

    final result = state.id.isEmpty
        ? await _repository.createProperty(entity, authenticatedUserId: authenticatedUserId)
        : await _repository.updateProperty(entity, authenticatedUserId: authenticatedUserId);

    return result.fold(
      (failure) {
        state = state.copyWith(status: PropertyFormStatus.error, errorMessage: failure.message);
        return false;
      },
      (savedEntity) {
        state = state.copyWith(
          id: savedEntity.id,
          status: PropertyFormStatus.saved,
          listingStatus: ListingStatus.draft,
        );
        return true;
      },
    );
  }

  Future<bool> submitProperty(String authenticatedUserId) async {
    if (!validateStep(7)) return false;

    state = state.copyWith(
      status: PropertyFormStatus.submitting,
      listingStatus: ListingStatus.submitted,
    );

    final entity = state.toEntity(authenticatedUserId);
    final result = state.id.isEmpty
        ? await _repository.createProperty(entity, authenticatedUserId: authenticatedUserId)
        : await _repository.updateProperty(entity, authenticatedUserId: authenticatedUserId);

    return result.fold(
      (failure) {
        state = state.copyWith(status: PropertyFormStatus.error, errorMessage: failure.message);
        return false;
      },
      (submittedEntity) {
        state = state.copyWith(
          id: submittedEntity.id,
          status: PropertyFormStatus.submitted,
          listingStatus: ListingStatus.submitted,
        );
        return true;
      },
    );
  }

  /// Deterministic Listing Completion Score (Phase 14)
  int calculateCompletionScore() {
    int score = 0;

    // 1. Basic details (20%)
    if (state.title.trim().isNotEmpty) score += 12;
    if (state.description.trim().isNotEmpty) score += 8;

    // 2. Location (20%)
    if (state.city.trim().isNotEmpty) score += 6;
    if (state.locality.trim().isNotEmpty) score += 8;
    if (state.pincode.trim().isNotEmpty) score += 6;

    // 3. Category-Specific Details (20%)
    final totalArea = (state.specifications.carpetArea ?? 0) +
        (state.specifications.superBuiltUpArea ?? 0) +
        (state.specifications.plotArea ?? 0);
    if (totalArea > 0) score += 10;
    if (state.category == PropertyCategory.residential) {
      if ((state.specifications.bedrooms ?? 0) > 0) score += 5;
      if ((state.specifications.bathrooms ?? 0) > 0) score += 5;
    } else if (state.category == PropertyCategory.land) {
      if (state.surveyNumber != null && state.surveyNumber!.trim().isNotEmpty) score += 10;
    } else if (state.category == PropertyCategory.plotLand) {
      if (state.plotLength != null && state.plotWidth != null) score += 10;
    } else if (state.category == PropertyCategory.commercial) {
      if (state.washrooms != null || state.powerLoad != null) score += 10;
    }

    // 4. Price & Financials (15%)
    if (state.price > 0) score += 15;

    // 5. Features & Amenities (10%)
    if (state.amenities.isNotEmpty) {
      score += 10;
    } else if (state.hasLift || state.hasBorewell || state.isGatedLayout) {
      score += 10;
    }

    // 6. Photos & Media (15%)
    if (state.mediaList.isNotEmpty) {
      score += 10;
      if (state.mediaList.length >= 3) score += 5;
    }

    return score.clamp(0, 100);
  }

  /// Returns exact list of missing required fields for publishing (Phase 13)
  List<String> getMissingPublishFields() {
    final missing = <String>[];
    if (state.title.trim().isEmpty) missing.add('Property Title');
    if (state.locality.trim().isEmpty) missing.add('Locality / Area');
    if (state.city.trim().isEmpty) missing.add('City');
    if (state.price <= 0) {
      if (state.listingType == 'FOR_RENT') {
        missing.add('Monthly Rent (must be > 0)');
      } else if (state.listingType == 'LEASE') {
        missing.add('Lease Amount (must be > 0)');
      } else {
        missing.add('Expected Sale Price (must be > 0)');
      }
    }
    final totalArea = (state.specifications.carpetArea ?? 0) +
        (state.specifications.superBuiltUpArea ?? 0) +
        (state.specifications.plotArea ?? 0);
    if (totalArea <= 0) missing.add('Property Area (Carpet / Plot / Land Area)');

    if (state.category == PropertyCategory.residential) {
      if ((state.specifications.bedrooms ?? 0) <= 0) missing.add('Bedrooms / BHK');
    } else if (state.category == PropertyCategory.land) {
      if (state.surveyNumber == null || state.surveyNumber!.trim().isEmpty) {
        missing.add('Survey Number / RTC Reference');
      }
    }

    if (state.mediaList.isEmpty) missing.add('At least 1 Property Photo');

    return missing;
  }
}
