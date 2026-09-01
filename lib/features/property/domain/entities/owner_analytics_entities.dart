import 'package:equatable/equatable.dart';

enum OwnerLeadType {
  buyer,
  seller,
  generalInquiry,
  call,
  whatsApp,
  message,
  propertyView,
  contactRequest,
}

class OwnerLeadEntity extends Equatable {
  final String id;
  final String propertyId;
  final String ownerId;
  final OwnerLeadType leadType;
  final String actorRole; // 'BUYER', 'SELLER'
  final String name;
  final String contactMethod;
  final String? phoneNumber;
  final String? email;
  final String propertyTitle;
  final String location;
  final String status;
  final DateTime createdAt;

  const OwnerLeadEntity({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.leadType,
    this.actorRole = 'BUYER',
    required this.name,
    required this.contactMethod,
    this.phoneNumber,
    this.email,
    required this.propertyTitle,
    required this.location,
    this.status = 'NEW',
    required this.createdAt,
  });

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
        createdAt,
      ];
}

class OwnerDailyAnalyticsEntity extends Equatable {
  final String propertyId;
  final String ownerId;
  final DateTime date;
  final int totalViews;
  final int searchAppearances;
  final int detailOpens;
  final int contactClicks;
  final int callClicks;
  final int whatsAppClicks;
  final int messagesCount;
  final int buyerLeads;
  final int sellerLeads;
  final int favoritesCount;
  final int promotionImpressions;
  final int promotionClicks;

  const OwnerDailyAnalyticsEntity({
    required this.propertyId,
    required this.ownerId,
    required this.date,
    this.totalViews = 0,
    this.searchAppearances = 0,
    this.detailOpens = 0,
    this.contactClicks = 0,
    this.callClicks = 0,
    this.whatsAppClicks = 0,
    this.messagesCount = 0,
    this.buyerLeads = 0,
    this.sellerLeads = 0,
    this.favoritesCount = 0,
    this.promotionImpressions = 0,
    this.promotionClicks = 0,
  });

  @override
  List<Object?> get props => [
        propertyId,
        ownerId,
        date,
        totalViews,
        searchAppearances,
        detailOpens,
        contactClicks,
        callClicks,
        whatsAppClicks,
        messagesCount,
        buyerLeads,
        sellerLeads,
        favoritesCount,
        promotionImpressions,
        promotionClicks,
      ];
}
