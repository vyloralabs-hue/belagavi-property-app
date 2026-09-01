import 'package:equatable/equatable.dart';

/// Property Core Domain Entities for Belagavi Property System

enum PropertyCategory { residential, commercial, industrial, land, plotLand, builderProject, other }

enum PropertySubtype {
  apartment,
  villa,
  independentHouse,
  rowHouse,
  penthouse,
  plot,
  residentialPlot,
  commercialPlot,
  commercialOffice,
  commercialShop,
  commercialShowroom,
  warehouse,
  warehouseGodown,
  agriculturalLand,
  industrialLand,
  naLand,
  nonNaLand,
  builderProject,
  builderApartmentProject,
  builderGatedCommunity,
  other,
}

enum ListingPurpose { forSale, forRent, lease }

/// Extended Listing Lifecycle Statuses
enum ListingStatus {
  draft,
  submitted,
  pendingVerification, // Backward compatibility alias
  underReview,
  changesRequested,
  approved,
  published,
  active, // Backward compatibility alias
  paused,
  rejected,
  sold,
  rented,
  leased,
  disputed,
  archived,
}

enum VerificationStatus { unverified, pending, changesRequested, verified, rejected }

enum MediaType { image, video, virtualTour360, floorPlan, legalDocument }

enum MediaProcessingStatus { uploaded, processing, ready, failed }

enum PropertyDocumentType { titleDeed, encumbranceCertificate, khataCertificate, taxReceipt, approvedPlan, occupancyCertificate, other }

enum UnlockType { payPerProperty, subscriptionPass, brokerCredit, adminGrant }

enum UnlockStatus { active, expired, revoked }

enum SellerType { owner, agent, builder }

class PropertySpecificationsEntity extends Equatable {
  final double? superBuiltUpArea;
  final double? carpetArea;
  final double? plotArea;
  final String areaUnit; // 'sqft', 'acre', 'gunta'
  final int? bedrooms;
  final int? bathrooms;
  final int? balconies;
  final int? floorNumber;
  final int? totalFloors;
  final String? furnishingStatus;
  final String? facingDirection;
  final bool? isNaApproved;

  const PropertySpecificationsEntity({
    this.superBuiltUpArea,
    this.carpetArea,
    this.plotArea,
    this.areaUnit = 'sqft',
    this.bedrooms,
    this.bathrooms,
    this.balconies,
    this.floorNumber,
    this.totalFloors,
    this.furnishingStatus,
    this.facingDirection,
    this.isNaApproved,
  });

  @override
  List<Object?> get props => [
        superBuiltUpArea,
        carpetArea,
        plotArea,
        areaUnit,
        bedrooms,
        bathrooms,
        balconies,
        floorNumber,
        totalFloors,
        furnishingStatus,
        facingDirection,
        isNaApproved,
      ];
}

class PropertyMediaEntity extends Equatable {
  final String id;
  final String propertyId;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? mediumUrl;
  final String? fullUrl;
  final MediaType type;
  final bool isCover;
  final String? caption;
  final int displayOrder;
  final int? width;
  final int? height;
  final int? fileSize;
  final String? mimeType;
  final MediaProcessingStatus processingStatus;
  final DateTime? uploadedAt;

  const PropertyMediaEntity({
    required this.id,
    required this.propertyId,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.mediumUrl,
    this.fullUrl,
    required this.type,
    this.isCover = false,
    this.caption,
    this.displayOrder = 0,
    this.width,
    this.height,
    this.fileSize,
    this.mimeType,
    this.processingStatus = MediaProcessingStatus.ready,
    this.uploadedAt,
  });

  /// Client delivery helpers with fallback to base mediaUrl
  String get effectiveThumbnailUrl => thumbnailUrl ?? mediaUrl;
  String get effectiveMediumUrl => mediumUrl ?? mediaUrl;
  String get effectiveFullUrl => fullUrl ?? mediaUrl;

  PropertyMediaEntity copyWith({
    String? id,
    String? propertyId,
    String? mediaUrl,
    String? thumbnailUrl,
    String? mediumUrl,
    String? fullUrl,
    MediaType? type,
    bool? isCover,
    String? caption,
    int? displayOrder,
    int? width,
    int? height,
    int? fileSize,
    String? mimeType,
    MediaProcessingStatus? processingStatus,
    DateTime? uploadedAt,
  }) {
    return PropertyMediaEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediumUrl: mediumUrl ?? this.mediumUrl,
      fullUrl: fullUrl ?? this.fullUrl,
      type: type ?? this.type,
      isCover: isCover ?? this.isCover,
      caption: caption ?? this.caption,
      displayOrder: displayOrder ?? this.displayOrder,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      processingStatus: processingStatus ?? this.processingStatus,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        mediaUrl,
        thumbnailUrl,
        mediumUrl,
        fullUrl,
        type,
        isCover,
        caption,
        displayOrder,
        width,
        height,
        fileSize,
        mimeType,
        processingStatus,
        uploadedAt,
      ];
}

class PropertyDocumentEntity extends Equatable {
  final String id;
  final String propertyId;
  final String documentUrl;
  final PropertyDocumentType documentType;
  final String? documentName;
  final String? fileName;
  final String? uploadedBy;
  final VerificationStatus verificationStatus;
  final DateTime uploadedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyDocumentEntity({
    required this.id,
    required this.propertyId,
    required this.documentUrl,
    required this.documentType,
    this.documentName,
    this.fileName,
    this.uploadedBy,
    this.verificationStatus = VerificationStatus.pending,
    required this.uploadedAt,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, propertyId, documentUrl, documentType, documentName, fileName, uploadedBy, verificationStatus, uploadedAt, createdAt, updatedAt];
}

class PropertyUnlockEntity extends Equatable {
  final String id;
  final String userId;
  final String propertyId;
  final UnlockType unlockType;
  final double amount;
  final int creditsUsed;
  final UnlockStatus status;
  final DateTime unlockedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const PropertyUnlockEntity({
    required this.id,
    required this.userId,
    required this.propertyId,
    this.unlockType = UnlockType.payPerProperty,
    this.amount = 0.0,
    this.creditsUsed = 0,
    this.status = UnlockStatus.active,
    required this.unlockedAt,
    this.expiresAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, propertyId, unlockType, amount, creditsUsed, status, unlockedAt, expiresAt, createdAt];
}

class PropertyVerificationEntity extends Equatable {
  final String id;
  final String propertyId;
  final String verifiedBy;
  final VerificationStatus status;
  final String? verificationNotes;
  final DateTime verifiedAt;

  const PropertyVerificationEntity({
    required this.id,
    required this.propertyId,
    required this.verifiedBy,
    required this.status,
    this.verificationNotes,
    required this.verifiedAt,
  });

  @override
  List<Object?> get props => [id, propertyId, verifiedBy, status, verificationNotes, verifiedAt];
}

class AIPropertyAnalysisEntity extends Equatable {
  final double qualityScore; // 0.0 to 100.0
  final bool isDuplicate;
  final String? suggestedDescription;
  final PropertyCategory? suggestedCategory;
  final List<String> similarPropertyIds;

  const AIPropertyAnalysisEntity({
    required this.qualityScore,
    this.isDuplicate = false,
    this.suggestedDescription,
    this.suggestedCategory,
    this.similarPropertyIds = const [],
  });

  @override
  List<Object?> get props => [
        qualityScore,
        isDuplicate,
        suggestedDescription,
        suggestedCategory,
        similarPropertyIds,
      ];
}

class PropertyEntity extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final PropertyCategory category;
  final PropertySubtype type;
  final ListingStatus status;
  final VerificationStatus verificationStatus;
  final String? rejectionReason;
  final String? verificationNotes;
  final double price;
  final bool isNegotiable;
  final PropertySpecificationsEntity specifications;
  final List<PropertyMediaEntity> mediaList;
  final String state;
  final String district;
  final String taluk;
  final String city;
  final String locality;
  final String address;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final int viewsCount;
  final Map<String, dynamic> features;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.status = ListingStatus.draft,
    this.verificationStatus = VerificationStatus.unverified,
    this.rejectionReason,
    this.verificationNotes,
    required this.price,
    this.isNegotiable = true,
    required this.specifications,
    this.mediaList = const [],
    required this.state,
    required this.district,
    required this.taluk,
    required this.city,
    required this.locality,
    required this.address,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.viewsCount = 0,
    this.features = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  PropertyEntity copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    PropertyCategory? category,
    PropertySubtype? type,
    ListingStatus? status,
    VerificationStatus? verificationStatus,
    String? rejectionReason,
    String? verificationNotes,
    double? price,
    bool? isNegotiable,
    PropertySpecificationsEntity? specifications,
    List<PropertyMediaEntity>? mediaList,
    String? state,
    String? district,
    String? taluk,
    String? city,
    String? locality,
    String? address,
    String? pincode,
    double? latitude,
    double? longitude,
    int? viewsCount,
    Map<String, dynamic>? features,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      price: price ?? this.price,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      specifications: specifications ?? this.specifications,
      mediaList: mediaList ?? this.mediaList,
      state: state ?? this.state,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      viewsCount: viewsCount ?? this.viewsCount,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  List<PropertyMediaEntity> get media => mediaList;

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        category,
        type,
        status,
        verificationStatus,
        rejectionReason,
        verificationNotes,
        price,
        isNegotiable,
        specifications,
        mediaList,
        state,
        district,
        taluk,
        city,
        locality,
        address,
        pincode,
        latitude,
        longitude,
        viewsCount,
        features,
        createdAt,
        updatedAt,
      ];
}

extension ListingStatusX on ListingStatus {
  String get dbValue {
    return switch (this) {
      ListingStatus.draft => 'draft',
      ListingStatus.submitted ||
      ListingStatus.pendingVerification ||
      ListingStatus.underReview => 'pending_verification',
      ListingStatus.changesRequested ||
      ListingStatus.paused ||
      ListingStatus.disputed ||
      ListingStatus.archived => 'archived',
      ListingStatus.approved ||
      ListingStatus.published ||
      ListingStatus.active => 'active',
      ListingStatus.rejected => 'rejected',
      ListingStatus.sold ||
      ListingStatus.rented ||
      ListingStatus.leased => 'sold',
    };
  }


  static ListingStatus fromDb(dynamic value) {
    if (value == null) return ListingStatus.draft;
    final str = value.toString().trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    return switch (str) {
      'draft' => ListingStatus.draft,
      'submitted' => ListingStatus.submitted,
      'pending_verification' || 'pendingverification' || 'pending' => ListingStatus.pendingVerification,
      'under_review' || 'underreview' || 'review' => ListingStatus.underReview,
      'changes_requested' || 'changesrequested' => ListingStatus.changesRequested,
      'approved' => ListingStatus.approved,
      'published' || 'published_active' => ListingStatus.published,
      'active' || 'live' => ListingStatus.active,
      'paused' || 'on_hold' || 'onhold' || 'hold' => ListingStatus.paused,
      'rejected' => ListingStatus.rejected,
      'sold' => ListingStatus.sold,
      'rented' => ListingStatus.rented,
      'leased' => ListingStatus.leased,
      'disputed' => ListingStatus.disputed,
      'archived' || 'unpublish' || 'unpublished' => ListingStatus.archived,
      _ => ListingStatus.draft,
    };
  }

  bool get isPubliclyVisible =>
      this == ListingStatus.published || this == ListingStatus.active || this == ListingStatus.approved;

  String get humanLabel => switch (this) {
        ListingStatus.draft => 'Draft',
        ListingStatus.submitted => 'Submitted',
        ListingStatus.pendingVerification => 'Pending Verification',
        ListingStatus.underReview => 'Under Review',
        ListingStatus.changesRequested => 'Changes Requested',
        ListingStatus.approved => 'Approved',
        ListingStatus.published => 'Published',
        ListingStatus.active => 'Active',
        ListingStatus.paused => 'On Hold',
        ListingStatus.rejected => 'Rejected',
        ListingStatus.sold => 'Sold',
        ListingStatus.rented => 'Rented',
        ListingStatus.leased => 'Leased',
        ListingStatus.disputed => 'Disputed',
        ListingStatus.archived => 'Archived',
      };
}

extension PropertyCategoryX on PropertyCategory {
  String get dbValue => switch (this) {
        PropertyCategory.residential => 'residential',
        PropertyCategory.commercial => 'commercial',
        PropertyCategory.plotLand => 'plot_land',
        PropertyCategory.land => 'land',
        PropertyCategory.industrial => 'commercial',
        PropertyCategory.builderProject => 'builder_project',
        PropertyCategory.other => 'other',
      };

  static PropertyCategory fromDb(dynamic value) {
    if (value == null) return PropertyCategory.residential;
    final str = value.toString().trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    return switch (str) {
      'residential' => PropertyCategory.residential,
      'commercial' => PropertyCategory.commercial,
      'plot_land' || 'plotland' || 'plot' || 'plots' => PropertyCategory.plotLand,
      'land' || 'raw_land' || 'rawland' || 'agricultural' => PropertyCategory.land,
      'industrial' => PropertyCategory.commercial,
      'builder_project' || 'builderproject' => PropertyCategory.builderProject,
      _ => PropertyCategory.residential,
    };
  }
}

extension PropertySubtypeX on PropertySubtype {
  String get dbValue => switch (this) {
        PropertySubtype.apartment => 'apartment',
        PropertySubtype.villa => 'villa',
        PropertySubtype.independentHouse => 'independent_house',
        PropertySubtype.rowHouse => 'row_house',
        PropertySubtype.penthouse => 'penthouse',
        PropertySubtype.commercialShop => 'commercial_shop',
        PropertySubtype.commercialOffice => 'commercial_office',
        PropertySubtype.commercialShowroom => 'commercial_showroom',
        PropertySubtype.warehouse || PropertySubtype.warehouseGodown => 'warehouse_godown',
        PropertySubtype.plot || PropertySubtype.residentialPlot => 'residential_plot',
        PropertySubtype.commercialPlot => 'commercial_plot',
        PropertySubtype.agriculturalLand => 'agricultural_land',
        PropertySubtype.naLand => 'na_land',
        PropertySubtype.builderProject ||
        PropertySubtype.builderApartmentProject => 'builder_apartment_project',
        PropertySubtype.builderGatedCommunity => 'builder_gated_community',
        _ => 'other',
      };

  static PropertySubtype fromDb(dynamic value) {
    if (value == null) return PropertySubtype.apartment;
    final str = value.toString().trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    return switch (str) {
      'apartment' => PropertySubtype.apartment,
      'villa' => PropertySubtype.villa,
      'independent_house' || 'independenthouse' => PropertySubtype.independentHouse,
      'row_house' || 'rowhouse' => PropertySubtype.rowHouse,
      'penthouse' => PropertySubtype.penthouse,
      'commercial_shop' || 'commercialshop' || 'shop' => PropertySubtype.commercialShop,
      'commercial_office' || 'commercialoffice' || 'office' => PropertySubtype.commercialOffice,
      'commercial_showroom' || 'commercialshowroom' || 'showroom' => PropertySubtype.commercialShowroom,
      'warehouse_godown' || 'warehouse' || 'godown' => PropertySubtype.warehouseGodown,
      'residential_plot' || 'residentialplot' || 'plot' => PropertySubtype.residentialPlot,
      'commercial_plot' || 'commercialplot' => PropertySubtype.commercialPlot,
      'agricultural_land' || 'agriculturalland' => PropertySubtype.agriculturalLand,
      'na_land' || 'naland' => PropertySubtype.naLand,
      'builder_apartment_project' || 'builderapartmentproject' => PropertySubtype.builderApartmentProject,
      'builder_gated_community' || 'buildergatedcommunity' => PropertySubtype.builderGatedCommunity,
      'raw_land' || 'rawland' => PropertySubtype.agriculturalLand,
      _ => PropertySubtype.apartment,
    };
  }
}

extension VerificationStatusX on VerificationStatus {
  String get dbValue => switch (this) {
        VerificationStatus.unverified => 'unverified',
        VerificationStatus.pending => 'pending',
        VerificationStatus.changesRequested => 'changes_requested',
        VerificationStatus.verified => 'verified',
        VerificationStatus.rejected => 'rejected',
      };

  static VerificationStatus fromDb(dynamic value) {
    if (value == null) return VerificationStatus.unverified;
    final str = value.toString().trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    return switch (str) {
      'unverified' => VerificationStatus.unverified,
      'pending' => VerificationStatus.pending,
      'changes_requested' || 'changesrequested' => VerificationStatus.changesRequested,
      'verified' => VerificationStatus.verified,
      'rejected' => VerificationStatus.rejected,
      _ => VerificationStatus.unverified,
    };
  }
}
