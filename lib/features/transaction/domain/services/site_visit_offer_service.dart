import 'package:equatable/equatable.dart';

enum SiteVisitStatus {
  requested,
  accepted,
  rescheduled,
  rejected,
  completed,
  canceled,
}

enum MarketplaceOfferStatus {
  submitted,
  revised,
  countered,
  accepted,
  rejected,
  withdrawn,
}

class SiteVisitScheduleRecord extends Equatable {
  final String id;
  final String propertyId;
  final String buyerId;
  final String sellerId;
  final DateTime proposedDateTime;
  final SiteVisitStatus status;
  final String? sellerNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SiteVisitScheduleRecord({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    required this.sellerId,
    required this.proposedDateTime,
    this.status = SiteVisitStatus.requested,
    this.sellerNote,
    required this.createdAt,
    required this.updatedAt,
  });

  SiteVisitScheduleRecord copyWith({
    DateTime? proposedDateTime,
    SiteVisitStatus? status,
    String? sellerNote,
    DateTime? updatedAt,
  }) {
    return SiteVisitScheduleRecord(
      id: id,
      propertyId: propertyId,
      buyerId: buyerId,
      sellerId: sellerId,
      proposedDateTime: proposedDateTime ?? this.proposedDateTime,
      status: status ?? this.status,
      sellerNote: sellerNote ?? this.sellerNote,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, propertyId, buyerId, sellerId, proposedDateTime, status, updatedAt];
}

class OfferHistoryEntry extends Equatable {
  final double amount;
  final String proposedBy; // 'buyer' or 'seller'
  final DateTime timestamp;
  final String? note;

  const OfferHistoryEntry({
    required this.amount,
    required this.proposedBy,
    required this.timestamp,
    this.note,
  });

  @override
  List<Object?> get props => [amount, proposedBy, timestamp, note];
}

class MarketplaceOfferRecord extends Equatable {
  static const String legalDisclaimer = 'Platform negotiation record, not a legal contract.';

  final String id;
  final String propertyId;
  final String buyerId;
  final String sellerId;
  final double currentOfferAmount;
  final String currency;
  final MarketplaceOfferStatus status;
  final List<OfferHistoryEntry> history;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketplaceOfferRecord({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    required this.sellerId,
    required this.currentOfferAmount,
    this.currency = 'INR',
    this.status = MarketplaceOfferStatus.submitted,
    this.history = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  MarketplaceOfferRecord copyWith({
    double? currentOfferAmount,
    MarketplaceOfferStatus? status,
    List<OfferHistoryEntry>? history,
    DateTime? updatedAt,
  }) {
    return MarketplaceOfferRecord(
      id: id,
      propertyId: propertyId,
      buyerId: buyerId,
      sellerId: sellerId,
      currentOfferAmount: currentOfferAmount ?? this.currentOfferAmount,
      currency: currency,
      status: status ?? this.status,
      history: history ?? this.history,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, propertyId, buyerId, sellerId, currentOfferAmount, status, history, updatedAt];
}

class SiteVisitOfferService {
  // ── Site Visit Actions ───────────────────────────────────────────────────
  static SiteVisitScheduleRecord acceptVisit(SiteVisitScheduleRecord visit) {
    return visit.copyWith(status: SiteVisitStatus.accepted, updatedAt: DateTime.now());
  }

  static SiteVisitScheduleRecord rescheduleVisit(SiteVisitScheduleRecord visit, DateTime newDate, {String? note}) {
    return visit.copyWith(
      proposedDateTime: newDate,
      status: SiteVisitStatus.rescheduled,
      sellerNote: note,
      updatedAt: DateTime.now(),
    );
  }

  static SiteVisitScheduleRecord rejectVisit(SiteVisitScheduleRecord visit, {String? reason}) {
    return visit.copyWith(
      status: SiteVisitStatus.rejected,
      sellerNote: reason,
      updatedAt: DateTime.now(),
    );
  }

  static SiteVisitScheduleRecord completeVisit(SiteVisitScheduleRecord visit) {
    return visit.copyWith(status: SiteVisitStatus.completed, updatedAt: DateTime.now());
  }

  // ── Offer Actions ────────────────────────────────────────────────────────
  static MarketplaceOfferRecord counterOffer({
    required MarketplaceOfferRecord offer,
    required double counterAmount,
    String? note,
  }) {
    final newEntry = OfferHistoryEntry(
      amount: counterAmount,
      proposedBy: 'seller',
      timestamp: DateTime.now(),
      note: note,
    );

    final updatedHistory = List<OfferHistoryEntry>.from(offer.history)..add(newEntry);

    return offer.copyWith(
      currentOfferAmount: counterAmount,
      status: MarketplaceOfferStatus.countered,
      history: updatedHistory,
      updatedAt: DateTime.now(),
    );
  }

  static MarketplaceOfferRecord reviseOffer({
    required MarketplaceOfferRecord offer,
    required double revisedAmount,
    String? note,
  }) {
    final newEntry = OfferHistoryEntry(
      amount: revisedAmount,
      proposedBy: 'buyer',
      timestamp: DateTime.now(),
      note: note,
    );

    final updatedHistory = List<OfferHistoryEntry>.from(offer.history)..add(newEntry);

    return offer.copyWith(
      currentOfferAmount: revisedAmount,
      status: MarketplaceOfferStatus.revised,
      history: updatedHistory,
      updatedAt: DateTime.now(),
    );
  }

  static MarketplaceOfferRecord acceptOffer(MarketplaceOfferRecord offer) {
    return offer.copyWith(status: MarketplaceOfferStatus.accepted, updatedAt: DateTime.now());
  }

  static MarketplaceOfferRecord rejectOffer(MarketplaceOfferRecord offer) {
    return offer.copyWith(status: MarketplaceOfferStatus.rejected, updatedAt: DateTime.now());
  }

  static MarketplaceOfferRecord withdrawOffer(MarketplaceOfferRecord offer) {
    return offer.copyWith(status: MarketplaceOfferStatus.withdrawn, updatedAt: DateTime.now());
  }
}
