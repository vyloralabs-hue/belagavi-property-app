import 'package:equatable/equatable.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

class BusinessCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final List<BusinessSubcategoryEntity> subcategories;

  const BusinessCategoryEntity({
    required this.id,
    required this.name,
    required this.iconName,
    this.subcategories = const [],
  });

  @override
  List<Object?> get props => [id, name, iconName, subcategories];
}

class BusinessSubcategoryEntity extends Equatable {
  final String id;
  final String categoryId;
  final String name;

  const BusinessSubcategoryEntity({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  @override
  List<Object?> get props => [id, categoryId, name];
}

class BusinessEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String categoryId;
  final String subcategoryId;
  final String countryCode;
  final String stateId;
  final String districtId;
  final String cityId;
  final String localityId;
  final String? areaId;
  final String address;
  final String phone;
  final String? whatsapp;
  final String description;
  final String openingHours;
  final List<String> photos;
  final List<String> productsServices;
  final ListingStatus status;
  final bool isVerified;
  final DateTime createdAt;

  const BusinessEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.categoryId,
    required this.subcategoryId,
    this.countryCode = 'IN',
    required this.stateId,
    required this.districtId,
    required this.cityId,
    required this.localityId,
    this.areaId,
    required this.address,
    required this.phone,
    this.whatsapp,
    required this.description,
    required this.openingHours,
    this.photos = const [],
    this.productsServices = const [],
    this.status = ListingStatus.submitted,
    this.isVerified = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        categoryId,
        subcategoryId,
        countryCode,
        stateId,
        districtId,
        cityId,
        localityId,
        areaId,
        address,
        phone,
        whatsapp,
        description,
        openingHours,
        photos,
        productsServices,
        status,
        isVerified,
        createdAt,
      ];
}
