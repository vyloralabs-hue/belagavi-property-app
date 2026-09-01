import 'package:equatable/equatable.dart';

enum OwnerCommandLeadStatus {
  newLead,
  contacted,
  followUp,
  interested,
  closed,
  notInterested,
}

class OwnerCommandLeadEntity extends Equatable {
  final String id;
  final String propertyId;
  final String ownerId;
  final String leadType; // 'BUYER', 'SELLER', 'CALL', 'WHATSAPP', 'INQUIRY'
  final String actorRole; // 'BUYER', 'SELLER'
  final String name;
  final String contactMethod;
  final String? phoneNumber;
  final String? email;
  final String propertyTitle;
  final String location;
  final OwnerCommandLeadStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OwnerCommandLeadEntity({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.leadType,
    required this.actorRole,
    required this.name,
    required this.contactMethod,
    this.phoneNumber,
    this.email,
    required this.propertyTitle,
    required this.location,
    this.status = OwnerCommandLeadStatus.newLead,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  OwnerCommandLeadEntity copyWith({
    OwnerCommandLeadStatus? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return OwnerCommandLeadEntity(
      id: id,
      propertyId: propertyId,
      ownerId: ownerId,
      leadType: leadType,
      actorRole: actorRole,
      name: name,
      contactMethod: contactMethod,
      phoneNumber: phoneNumber,
      email: email,
      propertyTitle: propertyTitle,
      location: location,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        ownerId,
        leadType,
        actorRole,
        name,
        contactMethod,
        phoneNumber,
        email,
        propertyTitle,
        location,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}

class OwnerPropertyPerformanceEntity extends Equatable {
  final String propertyId;
  final String ownerId;
  final String title;
  final String propertyType;
  final String location;
  final String status;
  final int views;
  final int enquiriesCount;
  final int contactRequestsCount;
  final int favoritesCount;
  final int searchAppearances;
  final String premiumStatus; // 'FREE', 'FEATURED', 'PRIORITY', 'PREMIUM'
  final DateTime publishedDate;
  final DateTime lastActivity;

  const OwnerPropertyPerformanceEntity({
    required this.propertyId,
    required this.ownerId,
    required this.title,
    required this.propertyType,
    required this.location,
    required this.status,
    this.views = 0,
    this.enquiriesCount = 0,
    this.contactRequestsCount = 0,
    this.favoritesCount = 0,
    this.searchAppearances = 0,
    this.premiumStatus = 'FREE',
    required this.publishedDate,
    required this.lastActivity,
  });

  @override
  List<Object?> get props => [
        propertyId,
        ownerId,
        title,
        propertyType,
        location,
        status,
        views,
        enquiriesCount,
        contactRequestsCount,
        favoritesCount,
        searchAppearances,
        premiumStatus,
        publishedDate,
        lastActivity,
      ];
}

class OwnerCommandCenterSummaryEntity extends Equatable {
  final int activeListings;
  final int hiddenListings;
  final int onHoldListings;
  final int totalViews;
  final int totalEnquiries;
  final int newLeadsCount;

  const OwnerCommandCenterSummaryEntity({
    this.activeListings = 0,
    this.hiddenListings = 0,
    this.onHoldListings = 0,
    this.totalViews = 0,
    this.totalEnquiries = 0,
    this.newLeadsCount = 0,
  });

  @override
  List<Object?> get props => [
        activeListings,
        hiddenListings,
        onHoldListings,
        totalViews,
        totalEnquiries,
        newLeadsCount,
      ];
}
