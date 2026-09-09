import '../../domain/entities/property_entities.dart';

class PropertySpecificationsModel extends PropertySpecificationsEntity {
  const PropertySpecificationsModel({
    super.superBuiltUpArea,
    super.carpetArea,
    super.plotArea,
    super.areaUnit = 'sqft',
    super.bedrooms,
    super.bathrooms,
    super.balconies,
    super.floorNumber,
    super.totalFloors,
    super.furnishingStatus,
    super.facingDirection,
    super.isNaApproved,
  });

  factory PropertySpecificationsModel.fromJson(Map<String, dynamic> json) {
    return PropertySpecificationsModel(
      superBuiltUpArea: (json['super_built_up_area'] as num?)?.toDouble(),
      carpetArea: (json['carpet_area'] as num?)?.toDouble(),
      plotArea: (json['plot_area'] as num?)?.toDouble(),
      areaUnit: json['area_unit'] as String? ?? 'sqft',
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      balconies: json['balconies'] as int?,
      floorNumber: json['floor_number'] as int?,
      totalFloors: json['total_floors'] as int?,
      furnishingStatus: json['furnishing_status'] as String?,
      facingDirection: json['facing_direction'] as String?,
      isNaApproved: json['is_na_approved'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'super_built_up_area': superBuiltUpArea,
        'carpet_area': carpetArea,
        'plot_area': plotArea,
        'area_unit': areaUnit,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'balconies': balconies,
        'floor_number': floorNumber,
        'total_floors': totalFloors,
        'furnishing_status': furnishingStatus,
        'facing_direction': facingDirection,
        'is_na_approved': isNaApproved,
      };
}

class PropertyMediaModel extends PropertyMediaEntity {
  const PropertyMediaModel({
    required super.id,
    required super.propertyId,
    required super.mediaUrl,
    super.thumbnailUrl,
    super.mediumUrl,
    super.fullUrl,
    super.type = MediaType.image,
    super.displayOrder = 0,
    super.isCover = false,
    super.caption,
    super.width,
    super.height,
    super.fileSize,
    super.mimeType,
    super.processingStatus = MediaProcessingStatus.ready,
    super.uploadedAt,
  });

  factory PropertyMediaModel.fromJson(Map<String, dynamic> json) {
    return PropertyMediaModel(
      id: json['id'] as String? ?? '',
      propertyId: json['property_id'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediumUrl: json['medium_url'] as String?,
      fullUrl: json['full_url'] as String?,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.image,
      ),
      displayOrder: json['display_order'] as int? ?? 0,
      isCover: json['is_cover'] as bool? ?? false,
      caption: json['caption'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      fileSize: json['file_size'] as int?,
      mimeType: json['mime_type'] as String?,
      processingStatus: MediaProcessingStatus.values.firstWhere(
        (e) => e.name == json['processing_status'],
        orElse: () => MediaProcessingStatus.ready,
      ),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : (json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'media_url': mediaUrl,
        'thumbnail_url': thumbnailUrl,
        'medium_url': mediumUrl,
        'full_url': fullUrl,
        'type': type.name,
        'display_order': displayOrder,
        'is_cover': isCover,
        'caption': caption,
        'width': width,
        'height': height,
        'file_size': fileSize,
        'mime_type': mimeType,
        'processing_status': processingStatus.name,
        'uploaded_at': (uploadedAt ?? DateTime.now()).toIso8601String(),
      };
}

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.category,
    required super.type,
    super.status = ListingStatus.draft,
    super.verificationStatus = VerificationStatus.unverified,
    super.rejectionReason,
    super.verificationNotes,
    required super.price,
    super.isNegotiable = true,
    required super.specifications,
    super.mediaList = const [],
    required super.state,
    required super.district,
    required super.taluk,
    required super.city,
    required super.locality,
    required super.address,
    required super.pincode,
    super.latitude,
    super.longitude,
    super.viewsCount = 0,
    super.features = const {},
    super.isPaused = false,
    super.isFeatured = false,
    super.listingAccessType = 'free_residential',
    super.listingAccessStartedAt,
    super.freeListingExpiresAt,
    super.listingExpiresAt,
    super.activePlanId,
    super.isGrandfathered = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: PropertyCategoryX.fromDb(json['category']),
      type: PropertySubtypeX.fromDb(json['type']),
      status: ListingStatusX.fromDb(json['status']),
      verificationStatus: VerificationStatusX.fromDb(json['verification_status']),
      rejectionReason: json['rejection_reason'] as String?,
      verificationNotes: json['verification_notes'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isNegotiable: json['is_negotiable'] as bool? ?? true,
      specifications: PropertySpecificationsModel.fromJson(json),
      mediaList: (json['property_media'] as List<dynamic>?)
              ?.map((m) => PropertyMediaModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
      state: json['state'] as String? ?? 'Karnataka',
      district: json['district'] as String? ?? 'Belagavi',
      taluk: json['taluk'] as String? ?? 'Belagavi',
      city: json['city'] as String? ?? 'Belagavi',
      locality: json['locality'] as String? ?? '',
      address: json['address'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      viewsCount: json['views_count'] as int? ?? 0,
      features: json['features'] as Map<String, dynamic>? ?? const {},
      isPaused: json['is_paused'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      listingAccessType: json['listing_access_type'] as String? ?? 'free_residential',
      listingAccessStartedAt: json['listing_access_started_at'] != null
          ? DateTime.tryParse(json['listing_access_started_at'] as String)
          : null,
      freeListingExpiresAt: json['free_listing_expires_at'] != null
          ? DateTime.tryParse(json['free_listing_expires_at'] as String)
          : null,
      listingExpiresAt: json['listing_expires_at'] != null
          ? DateTime.tryParse(json['listing_expires_at'] as String)
          : null,
      activePlanId: json['active_plan_id'] as String?,
      isGrandfathered: json['is_grandfathered'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toDatabaseJson() => {
        'id': id,
        'owner_id': ownerId,
        'title': title,
        'description': description,
        // Use dbValue so Supabase receives the correct snake_case PostgreSQL enum value
        'category': category.dbValue,
        'type': type.dbValue,
        'status': status.dbValue,
        'verification_status': verificationStatus.dbValue,
        'price': price,
        'is_negotiable': isNegotiable,
        'super_built_up_area': specifications.superBuiltUpArea,
        'carpet_area': specifications.carpetArea,
        'plot_area': specifications.plotArea,
        'area_unit': specifications.areaUnit.isNotEmpty ? specifications.areaUnit : 'sqft',
        'bedrooms': specifications.bedrooms,
        'bathrooms': specifications.bathrooms,
        'balconies': specifications.balconies,
        'floor_number': specifications.floorNumber,
        'total_floors': specifications.totalFloors,
        'furnishing_status': specifications.furnishingStatus,
        'state': state.isNotEmpty ? state : 'Karnataka',
        'district': district.isNotEmpty ? district : 'Belagavi',
        'taluk': taluk.isNotEmpty ? taluk : 'Belagavi',
        'city': city.isNotEmpty ? city : 'Belagavi',
        'locality': locality,
        'address': address.isNotEmpty ? address : (locality.isNotEmpty ? locality : 'Belagavi'),
        'pincode': pincode.isNotEmpty ? pincode : '590001',
        'latitude': latitude,
        'longitude': longitude,
        'views_count': viewsCount,
        'features': features,
        'is_paused': isPaused,
        'is_featured': isFeatured,
        'listing_access_type': listingAccessType,
        if (listingAccessStartedAt != null)
          'listing_access_started_at': listingAccessStartedAt!.toIso8601String(),
        if (freeListingExpiresAt != null)
          'free_listing_expires_at': freeListingExpiresAt!.toIso8601String(),
        if (listingExpiresAt != null)
          'listing_expires_at': listingExpiresAt!.toIso8601String(),
        if (activePlanId != null)
          'active_plan_id': activePlanId,
        'is_grandfathered': isGrandfathered,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() {
    final map = toDatabaseJson();
    if (mediaList.isNotEmpty) {
      map['property_media'] = mediaList
          .map((m) => m is PropertyMediaModel
              ? m.toJson()
              : PropertyMediaModel(
                  id: m.id,
                  propertyId: m.propertyId,
                  mediaUrl: m.mediaUrl,
                  thumbnailUrl: m.thumbnailUrl,
                  mediumUrl: m.mediumUrl,
                  fullUrl: m.fullUrl,
                  type: m.type,
                  displayOrder: m.displayOrder,
                  isCover: m.isCover,
                  caption: m.caption,
                  width: m.width,
                  height: m.height,
                  fileSize: m.fileSize,
                  mimeType: m.mimeType,
                  processingStatus: m.processingStatus,
                  uploadedAt: m.uploadedAt,
                ).toJson())
          .toList();
    }
    return map;
  }


  @override
  PropertyModel copyWith({
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
    bool? isPaused,
    bool? isFeatured,
    String? listingAccessType,
    DateTime? listingAccessStartedAt,
    DateTime? freeListingExpiresAt,
    DateTime? listingExpiresAt,
    String? activePlanId,
    bool? isGrandfathered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
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
      isPaused: isPaused ?? this.isPaused,
      isFeatured: isFeatured ?? this.isFeatured,
      listingAccessType: listingAccessType ?? this.listingAccessType,
      listingAccessStartedAt: listingAccessStartedAt ?? this.listingAccessStartedAt,
      freeListingExpiresAt: freeListingExpiresAt ?? this.freeListingExpiresAt,
      listingExpiresAt: listingExpiresAt ?? this.listingExpiresAt,
      activePlanId: activePlanId ?? this.activePlanId,
      isGrandfathered: isGrandfathered ?? this.isGrandfathered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

