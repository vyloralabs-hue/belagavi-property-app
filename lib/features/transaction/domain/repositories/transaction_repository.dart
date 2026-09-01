import '../entities/transaction_entities.dart';

abstract class TransactionRepository {
  Future<String> submitEnquiry(PropertyEnquiryEntity enquiry);
  Future<List<PropertyEnquiryEntity>> getBuyerEnquiries(String buyerId);
  Future<List<PropertyEnquiryEntity>> getSellerEnquiries(String sellerId);
  Future<PropertyEnquiryEntity?> getEnquiryById(String enquiryId);
  Future<void> updateEnquiryStatus(String enquiryId, TransactionStatus status);
  Future<void> requestSiteVisit({
    required String enquiryId,
    required String preferredDate,
    required String preferredTime,
    String? message,
  });
  Future<void> respondToSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
    String? respondingUserId,
  });
  Future<void> submitOfferEvent(NegotiationOfferEvent offerEvent);
  Future<void> updateOfferStatus({
    required String enquiryId,
    required OfferLifecycleStatus status,
    String? notes,
  });
  Future<void> updateDocVerification({
    required String enquiryId,
    required DocVerificationStatus status,
    String? notes,
  });

  // Compatibility aliases
  Future<void> updateSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
  });
  Future<void> submitNegotiationOffer({
    required String enquiryId,
    double? buyerOffer,
    double? sellerCounterOffer,
    double? agreedAmount,
  });
  // Duplicate detection & admin queries
  Future<bool> hasActiveInquiry({required String propertyId, required String buyerId});
  Future<List<PropertyEnquiryEntity>> getAllEnquiries();
}
