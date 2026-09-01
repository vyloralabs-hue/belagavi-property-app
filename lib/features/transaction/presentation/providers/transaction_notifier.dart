import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/notification/domain/entities/notification_entity.dart';
import 'package:belagavi_property/features/notification/presentation/providers/notification_notifier.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../data/repositories/transaction_repository_impl.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

class TransactionState {
  final List<PropertyEnquiryEntity> buyerEnquiries;
  final List<PropertyEnquiryEntity> sellerEnquiries;
  final PropertyEnquiryEntity? selectedEnquiry;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const TransactionState({
    this.buyerEnquiries = const [],
    this.sellerEnquiries = const [],
    this.selectedEnquiry,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  TransactionState copyWith({
    List<PropertyEnquiryEntity>? buyerEnquiries,
    List<PropertyEnquiryEntity>? sellerEnquiries,
    PropertyEnquiryEntity? selectedEnquiry,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return TransactionState(
      buyerEnquiries: buyerEnquiries ?? this.buyerEnquiries,
      sellerEnquiries: sellerEnquiries ?? this.sellerEnquiries,
      selectedEnquiry: selectedEnquiry ?? this.selectedEnquiry,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final transactionNotifierProvider =
    NotifierProvider<TransactionNotifier, TransactionState>(TransactionNotifier.new);

class TransactionNotifier extends Notifier<TransactionState> {
  late final TransactionRepository _repo;

  @override
  TransactionState build() {
    _repo = ref.watch(transactionRepositoryProvider);
    Future.microtask(() => loadEnquiries());
    return const TransactionState();
  }

  String get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ??
      AuthSessionStorageHelper.getUserUid() ??
      'usr_authenticated';

  Future<void> loadEnquiries({String? buyerId, String? sellerId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final effectiveBuyerId = buyerId ?? _currentUserId;
      final effectiveSellerId = sellerId ?? _currentUserId;
      final buyerList = await _repo.getBuyerEnquiries(effectiveBuyerId);
      final sellerList = await _repo.getSellerEnquiries(effectiveSellerId);
      state = state.copyWith(
        buyerEnquiries: buyerList,
        sellerEnquiries: sellerList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> hasActiveInquiry({required String propertyId, String? buyerId}) async {
    final effectiveBuyerId = buyerId ?? _currentUserId;
    return await _repo.hasActiveInquiry(propertyId: propertyId, buyerId: effectiveBuyerId);
  }

  Future<String> sendEnquiry(PropertyEnquiryEntity enquiry) async {
    state = state.copyWith(isLoading: true);
    try {
      final id = await _repo.submitEnquiry(enquiry);
      await loadEnquiries(buyerId: enquiry.buyerId, sellerId: enquiry.sellerId);

      // Automated Notification Creation for Property Owner
      final isSiteVisit = enquiry.siteVisitStatus == SiteVisitStatus.requested;
      final notification = NotificationEntity(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        recipientId: enquiry.sellerId,
        type: isSiteVisit ? NotificationType.newSiteVisitRequest : NotificationType.newPropertyInquiry,
        title: isSiteVisit ? 'New Site Visit Request' : 'New Property Inquiry',
        body: isSiteVisit
            ? '${enquiry.buyerName} requested an on-site visit for "${enquiry.propertyTitle}".'
            : '${enquiry.buyerName} expressed interest in your property "${enquiry.propertyTitle}".',
        propertyId: enquiry.propertyId,
        inquiryId: enquiry.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(notificationNotifierProvider.notifier).dispatchNotification(notification);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Enquiry sent successfully to property owner!',
      );
      return id;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> selectEnquiry(String id) async {
    final enquiry = await _repo.getEnquiryById(id);
    state = state.copyWith(selectedEnquiry: enquiry);
  }

  Future<void> updateStatus(String enquiryId, TransactionStatus newStatus) async {
    await _repo.updateEnquiryStatus(enquiryId, newStatus);
    await loadEnquiries();
    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }

  Future<void> requestSiteVisit({
    required String enquiryId,
    required String preferredDate,
    required String preferredTime,
    String? message,
  }) async {
    await _repo.requestSiteVisit(
      enquiryId: enquiryId,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      message: message,
    );
    await loadEnquiries();
    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }

  Future<void> respondToSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
  }) async {
    await _repo.respondToSiteVisit(
      enquiryId: enquiryId,
      status: status,
      scheduledDateTime: scheduledDateTime,
      notes: notes,
    );
    await loadEnquiries();
    final enquiry = await _repo.getEnquiryById(enquiryId);
    if (enquiry != null) {
      // Dispatch notification to buyer
      final isConfirmed = status == SiteVisitStatus.confirmed || status == SiteVisitStatus.scheduled;
      final isCancelled = status == SiteVisitStatus.cancelled;
      final notification = NotificationEntity(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        recipientId: enquiry.buyerId,
        type: isConfirmed
            ? NotificationType.siteVisitConfirmed
            : (isCancelled ? NotificationType.siteVisitRejected : NotificationType.siteVisitRescheduled),
        title: isConfirmed
            ? 'Site Visit Confirmed'
            : (isCancelled ? 'Site Visit Update' : 'Site Visit Rescheduled'),
        body: isConfirmed
            ? 'Your site visit for "${enquiry.propertyTitle}" has been confirmed by the owner.'
            : 'Your site visit request for "${enquiry.propertyTitle}" status: ${status.name}.',
        propertyId: enquiry.propertyId,
        inquiryId: enquiry.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(notificationNotifierProvider.notifier).dispatchNotification(notification);
    }

    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }

  Future<void> submitOfferEvent({
    required String enquiryId,
    required String userId,
    required String userName,
    required bool isBuyer,
    required double offerAmount,
    double? monthlyRent,
    double? depositAmount,
    int? leaseDurationMonths,
    double? maintenanceCharges,
    String? terms,
  }) async {
    final event = NegotiationOfferEvent(
      id: 'off_event_${DateTime.now().millisecondsSinceEpoch}',
      enquiryId: enquiryId,
      submittedByUserId: userId,
      submittedByName: userName,
      isBuyerOffer: isBuyer,
      offerAmount: offerAmount,
      monthlyRent: monthlyRent,
      depositAmount: depositAmount,
      leaseDurationMonths: leaseDurationMonths,
      maintenanceCharges: maintenanceCharges,
      termsAndConditions: terms,
      status: isBuyer ? OfferLifecycleStatus.submitted : OfferLifecycleStatus.countered,
      createdAt: DateTime.now(),
    );

    await _repo.submitOfferEvent(event);
    await loadEnquiries();
    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }

  Future<void> updateOfferStatus({
    required String enquiryId,
    required OfferLifecycleStatus status,
    String? notes,
  }) async {
    await _repo.updateOfferStatus(
      enquiryId: enquiryId,
      status: status,
      notes: notes,
    );
    await loadEnquiries();
    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }

  Future<void> updateDocVerification({
    required String enquiryId,
    required DocVerificationStatus status,
    String? notes,
  }) async {
    await _repo.updateDocVerification(
      enquiryId: enquiryId,
      status: status,
      notes: notes,
    );
    await loadEnquiries();
    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }

  Future<void> updateSiteVisit({
    required String enquiryId,
    required SiteVisitStatus status,
    DateTime? scheduledDateTime,
    String? notes,
  }) async {
    await _repo.updateSiteVisit(
      enquiryId: enquiryId,
      status: status,
      scheduledDateTime: scheduledDateTime,
      notes: notes,
    );
    await loadEnquiries();
    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }

  Future<void> submitOffer({
    required String enquiryId,
    double? buyerOffer,
    double? sellerCounterOffer,
    double? agreedAmount,
  }) async {
    await _repo.submitNegotiationOffer(
      enquiryId: enquiryId,
      buyerOffer: buyerOffer,
      sellerCounterOffer: sellerCounterOffer,
      agreedAmount: agreedAmount,
    );
    await loadEnquiries();
    if (state.selectedEnquiry?.id == enquiryId) {
      await selectEnquiry(enquiryId);
    }
  }
}
