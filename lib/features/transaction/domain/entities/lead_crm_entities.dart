import 'package:equatable/equatable.dart';

enum LeadStage {
  newLead,
  contacted,
  qualified,
  visitScheduled,
  negotiation,
  documents,
  won,
  lost,
}

class SellerPrivateLeadNote extends Equatable {
  final String id;
  final String authorId;
  final String content;
  final DateTime createdAt;

  const SellerPrivateLeadNote({
    required this.id,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorId, content, createdAt];
}

class LeadCRMRecord extends Equatable {
  final String id;
  final String propertyId;
  final String sellerId;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final LeadStage stage;
  final List<SellerPrivateLeadNote> privateNotes;
  final DateTime? followUpScheduledAt;
  final bool isMarkedSpam;
  final bool isBuyerBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LeadCRMRecord({
    required this.id,
    required this.propertyId,
    required this.sellerId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    this.stage = LeadStage.newLead,
    this.privateNotes = const [],
    this.followUpScheduledAt,
    this.isMarkedSpam = false,
    this.isBuyerBlocked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  LeadCRMRecord copyWith({
    LeadStage? stage,
    List<SellerPrivateLeadNote>? privateNotes,
    DateTime? followUpScheduledAt,
    bool? isMarkedSpam,
    bool? isBuyerBlocked,
    DateTime? updatedAt,
  }) {
    return LeadCRMRecord(
      id: id,
      propertyId: propertyId,
      sellerId: sellerId,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      stage: stage ?? this.stage,
      privateNotes: privateNotes ?? this.privateNotes,
      followUpScheduledAt: followUpScheduledAt ?? this.followUpScheduledAt,
      isMarkedSpam: isMarkedSpam ?? this.isMarkedSpam,
      isBuyerBlocked: isBuyerBlocked ?? this.isBuyerBlocked,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        sellerId,
        buyerId,
        stage,
        privateNotes,
        followUpScheduledAt,
        isMarkedSpam,
        isBuyerBlocked,
        updatedAt,
      ];
}

class BuyerActivitySummary extends Equatable {
  final String buyerId;
  final int totalEnquiries;
  final int scheduledVisits;
  final int activeOffers;
  final int savedPropertiesCount;

  const BuyerActivitySummary({
    required this.buyerId,
    this.totalEnquiries = 0,
    this.scheduledVisits = 0,
    this.activeOffers = 0,
    this.savedPropertiesCount = 0,
  });

  @override
  List<Object?> get props => [buyerId, totalEnquiries, scheduledVisits, activeOffers, savedPropertiesCount];
}
