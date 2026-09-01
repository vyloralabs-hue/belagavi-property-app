import 'dart:typed_data';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/dispute_entities.dart';

abstract class DisputeRepository {
  FutureEither<PropertyDisputeEntity> createDispute(
    PropertyDisputeEntity dispute, {
    required String authenticatedUserId,
    List<DisputeDocumentEntity> initialDocuments = const [],
  });

  FutureEither<List<PropertyDisputeEntity>> getDisputedProperties({
    DisputeType? type,
    String? category,
    String? locality,
    String? query,
    String? status,
    int limit = 20,
    int offset = 0,
  });

  FutureEither<List<PropertyDisputeEntity>> getMyDisputedProperties({
    required String authenticatedUserId,
    String? statusFilter,
    int limit = 20,
    int offset = 0,
  });

  FutureEither<PropertyDisputeEntity?> getDisputeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  });

  FutureEither<PropertyDisputeEntity> updateDisputeStatus({
    required String disputeId,
    required DisputeVerificationStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<void> deleteDispute(
    String disputeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  FutureEither<List<DisputeDuplicateCandidate>> checkPossibleDuplicates({
    required String locality,
    String? surveyNumber,
    String? propertyNumber,
  });

  FutureEither<DisputeResponseEntity> submitDisputeResponse({
    required String disputeId,
    required String respondentId,
    required String respondentName,
    required String respondentRole,
    required String responseType,
    required String statement,
    List<String> documentUrls = const [],
  });

  FutureEither<String> uploadDisputeDocumentFile({
    required String disputeId,
    required String fileName,
    required Uint8List fileBytes,
  });
}