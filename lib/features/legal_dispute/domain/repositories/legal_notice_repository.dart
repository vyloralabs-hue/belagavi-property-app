import '../../../../core/security/user_role.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/legal_notice_entities.dart';

abstract class LegalNoticeRepository {
  FutureEither<TransactionLegalNoticeEntity> createLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
  });

  FutureEither<List<TransactionLegalNoticeEntity>> getLegalNotices({
    LegalNoticeType? type,
    String? transactionType,
    String? locality,
    String? query,
    int limit = 50,
    int offset = 0,
  });

  FutureEither<TransactionLegalNoticeEntity?> getLegalNoticeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  });

  FutureEither<TransactionLegalNoticeEntity> updateLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<TransactionLegalNoticeEntity> attachDocuments(
    String noticeId, {
    required List<String> newDocuments,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<TransactionLegalNoticeEntity> updateStatus({
    required String noticeId,
    required LegalNoticeStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<void> deleteLegalNotice(
    String noticeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  // End-to-End Legal Notice & Dispute Assistance Module Methods
  FutureEither<LegalMatterEntity> createLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  });

  FutureEither<List<LegalMatterEntity>> getUserLegalMatters({
    required String authenticatedUserId,
    LegalMatterStatus? statusFilter,
    String? categoryFilter,
    String? query,
  });

  FutureEither<LegalMatterEntity?> getLegalMatterById(
    String matterId, {
    required String authenticatedUserId,
  });

  FutureEither<LegalMatterEntity> updateLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  });

  FutureEither<LegalMatterEntity> updateMatterStatus({
    required String matterId,
    required LegalMatterStatus newStatus,
    required String authenticatedUserId,
  });

  FutureEither<LegalMatterEntity> addDraftVersion(
    String matterId, {
    required int versionNumber,
    required String contentMarkdown,
    required String generatedByType,
    String? reasonForChange,
    required String authenticatedUserId,
  });

  FutureEither<LegalMatterEntity> recordServiceAttempt(
    String matterId, {
    required LegalServiceAttemptEntity attempt,
    required String authenticatedUserId,
  });

  FutureEither<LegalMatterEntity> recordResponse(
    String matterId, {
    required LegalResponseEntity response,
    required String authenticatedUserId,
  });
}