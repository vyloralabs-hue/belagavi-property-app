import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/dispute_entities.dart';
import '../../domain/repositories/dispute_repository.dart';
import '../datasources/dispute_remote_datasource.dart';

@LazySingleton(as: DisputeRepository)
class DisputeRepositoryImpl extends BaseRepository implements DisputeRepository {
  final DisputeRemoteDataSource _remoteDataSource;

  DisputeRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<PropertyDisputeEntity> createDispute(
    PropertyDisputeEntity dispute, {
    required String authenticatedUserId,
    List<DisputeDocumentEntity> initialDocuments = const [],
  }) async {
    return safeCall(() => _remoteDataSource.createDispute(
      dispute,
      authenticatedUserId: authenticatedUserId,
      initialDocuments: initialDocuments,
    ));
  }

  @override
  FutureEither<List<PropertyDisputeEntity>> getDisputedProperties({
    DisputeType? type,
    String? category,
    String? locality,
    String? query,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() => _remoteDataSource.fetchDisputedProperties(
      type: type,
      category: category,
      locality: locality,
      query: query,
      status: status,
      limit: limit,
      offset: offset,
    ));
  }

  @override
  FutureEither<List<PropertyDisputeEntity>> getMyDisputedProperties({
    required String authenticatedUserId,
    String? statusFilter,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() => _remoteDataSource.fetchMyDisputedProperties(
      authenticatedUserId: authenticatedUserId,
      statusFilter: statusFilter,
      limit: limit,
      offset: offset,
    ));
  }

  @override
  FutureEither<PropertyDisputeEntity?> getDisputeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.fetchDisputeById(
      id,
      requestingUserId: requestingUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<PropertyDisputeEntity> updateDisputeStatus({
    required String disputeId,
    required DisputeVerificationStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.updateDisputeStatus(
      disputeId: disputeId,
      newStatus: newStatus,
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<void> deleteDispute(
    String disputeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeCall(() => _remoteDataSource.deleteDispute(
      disputeId,
      authenticatedUserId: authenticatedUserId,
      userRole: userRole,
    ));
  }

  @override
  FutureEither<List<DisputeDuplicateCandidate>> checkPossibleDuplicates({
    required String locality,
    String? surveyNumber,
    String? propertyNumber,
  }) async {
    return safeCall(() => _remoteDataSource.checkPossibleDuplicates(
      locality: locality,
      surveyNumber: surveyNumber,
      propertyNumber: propertyNumber,
    ));
  }

  @override
  FutureEither<DisputeResponseEntity> submitDisputeResponse({
    required String disputeId,
    required String respondentId,
    required String respondentName,
    required String respondentRole,
    required String responseType,
    required String statement,
    List<String> documentUrls = const [],
  }) async {
    return safeCall(() => _remoteDataSource.submitDisputeResponse(
      disputeId: disputeId,
      respondentId: respondentId,
      respondentName: respondentName,
      respondentRole: respondentRole,
      responseType: responseType,
      statement: statement,
      documentUrls: documentUrls,
    ));
  }

  @override
  FutureEither<String> uploadDisputeDocumentFile({
    required String disputeId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    return safeCall(() => _remoteDataSource.uploadDisputeDocumentFile(
      disputeId: disputeId,
      fileName: fileName,
      fileBytes: fileBytes,
    ));
  }
}