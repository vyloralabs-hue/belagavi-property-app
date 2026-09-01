import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/legal_notice_entities.dart';
import '../../domain/repositories/legal_notice_repository.dart';
import '../datasources/legal_notice_remote_datasource.dart';

@LazySingleton(as: LegalNoticeRepository)
class LegalNoticeRepositoryImpl extends BaseRepository implements LegalNoticeRepository {
  final LegalNoticeRemoteDataSource _remoteDataSource;

  LegalNoticeRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<TransactionLegalNoticeEntity> createLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.createLegalNotice(notice, authenticatedUserId: authenticatedUserId));
  }

  @override
  FutureEither<List<TransactionLegalNoticeEntity>> getLegalNotices({
    LegalNoticeType? type,
    String? transactionType,
    String? locality,
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    return safeCall(() => _remoteDataSource.fetchLegalNotices(
      type: type,
      transactionType: transactionType,
      locality: locality,
      query: query,
      limit: limit,
      offset: offset,
    ));
  }

  @override
  FutureEither<TransactionLegalNoticeEntity?> getLegalNoticeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.fetchLegalNoticeById(
      id,
      requestingUserId: requestingUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<TransactionLegalNoticeEntity> updateLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.updateLegalNotice(
      notice,
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<TransactionLegalNoticeEntity> attachDocuments(
    String noticeId, {
    required List<String> newDocuments,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.attachDocuments(
      noticeId,
      newDocuments: newDocuments,
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<TransactionLegalNoticeEntity> updateStatus({
    required String noticeId,
    required LegalNoticeStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.updateStatus(
      noticeId: noticeId,
      newStatus: newStatus,
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<void> deleteLegalNotice(
    String noticeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.deleteLegalNotice(
      noticeId,
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<LegalMatterEntity> createLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.createLegalMatter(matter, authenticatedUserId: authenticatedUserId));
  }

  @override
  FutureEither<List<LegalMatterEntity>> getUserLegalMatters({
    required String authenticatedUserId,
    LegalMatterStatus? statusFilter,
    String? categoryFilter,
    String? query,
  }) async {
    return safeCall(() => _remoteDataSource.fetchUserLegalMatters(
      authenticatedUserId: authenticatedUserId,
      statusFilter: statusFilter,
      categoryFilter: categoryFilter,
      query: query,
    ));
  }

  @override
  FutureEither<LegalMatterEntity?> getLegalMatterById(
    String matterId, {
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.fetchLegalMatterById(matterId, authenticatedUserId: authenticatedUserId));
  }

  @override
  FutureEither<LegalMatterEntity> updateLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.updateLegalMatter(matter, authenticatedUserId: authenticatedUserId));
  }

  @override
  FutureEither<LegalMatterEntity> updateMatterStatus({
    required String matterId,
    required LegalMatterStatus newStatus,
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.updateMatterStatus(
      matterId: matterId,
      newStatus: newStatus,
      authenticatedUserId: authenticatedUserId,
    ));
  }

  @override
  FutureEither<LegalMatterEntity> addDraftVersion(
    String matterId, {
    required int versionNumber,
    required String contentMarkdown,
    required String generatedByType,
    String? reasonForChange,
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.addDraftVersion(
      matterId,
      versionNumber: versionNumber,
      contentMarkdown: contentMarkdown,
      generatedByType: generatedByType,
      reasonForChange: reasonForChange,
      authenticatedUserId: authenticatedUserId,
    ));
  }

  @override
  FutureEither<LegalMatterEntity> recordServiceAttempt(
    String matterId, {
    required LegalServiceAttemptEntity attempt,
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.recordServiceAttempt(
      matterId,
      attempt: attempt,
      authenticatedUserId: authenticatedUserId,
    ));
  }

  @override
  FutureEither<LegalMatterEntity> recordResponse(
    String matterId, {
    required LegalResponseEntity response,
    required String authenticatedUserId,
  }) async {
    return safeCall(() => _remoteDataSource.recordResponse(
      matterId,
      response: response,
      authenticatedUserId: authenticatedUserId,
    ));
  }
}