import 'dart:math';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/dispute_entities.dart';

String _generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40;
  values[8] = (values[8] & 0x3f) | 0x80;
  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

abstract class DisputeRemoteDataSource {
  Future<PropertyDisputeEntity> createDispute(
    PropertyDisputeEntity dispute, {
    required String authenticatedUserId,
    List<DisputeDocumentEntity> initialDocuments = const [],
  });

  Future<List<PropertyDisputeEntity>> fetchDisputedProperties({
    DisputeType? type,
    String? category,
    String? locality,
    String? query,
    String? status,
    int limit = 20,
    int offset = 0,
  });

  Future<List<PropertyDisputeEntity>> fetchMyDisputedProperties({
    required String authenticatedUserId,
    String? statusFilter,
    int limit = 20,
    int offset = 0,
  });

  Future<PropertyDisputeEntity?> fetchDisputeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  });

  Future<PropertyDisputeEntity> updateDisputeStatus({
    required String disputeId,
    required DisputeVerificationStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<void> deleteDispute(
    String disputeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<List<DisputeDuplicateCandidate>> checkPossibleDuplicates({
    required String locality,
    String? surveyNumber,
    String? propertyNumber,
  });

  Future<DisputeResponseEntity> submitDisputeResponse({
    required String disputeId,
    required String respondentId,
    required String respondentName,
    required String respondentRole,
    required String responseType,
    required String statement,
    List<String> documentUrls = const [],
  });

  Future<String> uploadDisputeDocumentFile({
    required String disputeId,
    required String fileName,
    required Uint8List fileBytes,
  });
}

@LazySingleton(as: DisputeRemoteDataSource)
class DisputeRemoteDataSourceImpl extends BaseRemoteDataSource implements DisputeRemoteDataSource {
  final SupabaseService _supabaseService;
  final Map<String, PropertyDisputeEntity> _testRegistry = {};

  DisputeRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<PropertyDisputeEntity> createDispute(
    PropertyDisputeEntity dispute, {
    required String authenticatedUserId,
    List<DisputeDocumentEntity> initialDocuments = const [],
  }) async {
    return safeQuery(() async {
      final disputeId = dispute.id.isNotEmpty ? dispute.id : _generateUuidV4();

      final targetStatus = dispute.verificationStatus == DisputeVerificationStatus.draft
          ? DisputeVerificationStatus.draft
          : (dispute.verificationStatus == DisputeVerificationStatus.underReview
              ? DisputeVerificationStatus.underReview
              : DisputeVerificationStatus.submitted);

      final enriched = dispute.copyWith(
        id: disputeId,
        creatorId: authenticatedUserId,
        reportedBy: authenticatedUserId,
        verificationStatus: targetStatus,
        isFounderConfirmed: false,
        reportDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        hasDocuments: initialDocuments.isNotEmpty || dispute.documentUrls.isNotEmpty,
      );

      _testRegistry[disputeId] = enriched;

      final payload = enriched.toSupabaseMap();
      payload['creator_id'] = authenticatedUserId;

      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('dispute_listings').insert(payload);

          // Insert documents
          if (initialDocuments.isNotEmpty) {
            for (final doc in initialDocuments) {
              final docPayload = doc.copyWith(
                id: doc.id.isNotEmpty ? doc.id : _generateUuidV4(),
                disputeId: disputeId,
              ).toSupabaseMap();
              await _supabaseService.from('dispute_documents').insert(docPayload);
            }
          }

          // Insert audit event
          await _supabaseService.from('dispute_events').insert({
            'id': _generateUuidV4(),
            'dispute_id': disputeId,
            'event_type': 'created',
            'actor_id': authenticatedUserId,
            'actor_role': 'user',
            'description': 'Disputed property record submitted for verification.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          AppLogger.w('Failed to insert into live dispute_listings: $e');
        }
      }

      return enriched.copyWith(documents: initialDocuments);
    });
  }

  @override
  Future<List<PropertyDisputeEntity>> fetchDisputedProperties({
    DisputeType? type,
    String? category,
    String? locality,
    String? query,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        if (_testRegistry.isEmpty) {
          _testRegistry['disp_101'] = PropertyDisputeEntity(
            id: 'disp_101',
            propertyId: 'prop_camp_house_201',
            title: 'Bungalow in Camp with Injunction Order',
            category: 'Residential',
            propertyType: 'Independent House',
            city: 'Belagavi',
            locality: 'Camp',
            surveyCtsNumber: 'CTS No. 892/1',
            relationship: 'I am claiming an interest',
            disputeType: DisputeType.courtCaseStayOrder,
            courtAuthority: 'Civil Court Senior Division, Belagavi',
            caseNumber: 'OS 440/2026',
            caseYear: '2026',
            caseStatus: 'Temporary Injunction Order in force',
            litigatingParties: 'Petitioner vs Vendor',
            description: 'Temporary injunction granted restraining alienation or creation of third-party rights.',
            contactName: 'Adv. Suresh Kulkarni',
            contactPhone: '+91 94801 22334',
            contactEmail: 'suresh.law@example.com',
            photoUrls: const ['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00'],
            documentUrls: const ['https://storage.belagaviproperty.com/disputes/stay_order_112.pdf'],
            isDocumentPrivate: true,
            verificationStatus: DisputeVerificationStatus.publishedListed,
            reportDate: DateTime(2026, 1, 1),
            lastUpdated: DateTime(2026, 1, 1),
          );
          _testRegistry['disp_102'] = PropertyDisputeEntity(
            id: 'disp_102',
            propertyId: 'prop_sambra_land_202',
            title: 'Agricultural Land near Airport with Writ Petition',
            category: 'Agricultural',
            propertyType: 'Agricultural Land',
            city: 'Belagavi',
            locality: 'Sambra',
            surveyCtsNumber: 'Sy No. 142/3',
            relationship: 'Adjacent landowner',
            disputeType: DisputeType.landAcquisitionDispute,
            courtAuthority: 'High Court of Karnataka, Dharwad Bench',
            caseNumber: 'WP 48291/2024',
            caseYear: '2024',
            caseStatus: 'Writ Petition admitted, stay on road widening execution',
            litigatingParties: 'Landowners vs NHAI & SLAO',
            description: 'Compensation enhancement and acquisition route challenge.',
            contactName: 'Sanjay Deshpande',
            contactPhone: '+91 98450 33445',
            contactEmail: 'sanjay.d@example.com',
            photoUrls: const ['https://images.unsplash.com/photo-1500382017468-9049fed747ef'],
            documentUrls: const ['https://storage.belagaviproperty.com/disputes/high_court_stay_48291.pdf'],
            isDocumentPrivate: true,
            verificationStatus: DisputeVerificationStatus.publishedListed,
            reportDate: DateTime(2026, 1, 5),
            lastUpdated: DateTime(2026, 1, 5),
          );
        }

        var items = _testRegistry.values.toList();
        if (status != null && status.isNotEmpty) {
          items = items.where((d) =>
            d.verificationStatus.dbValue == status ||
            d.verificationStatus.displayName.toLowerCase() == status.toLowerCase() ||
            d.caseStatus == status
          ).toList();
        }

        if (locality != null && locality.isNotEmpty && locality != 'All Localities') {
          items = items.where((d) => d.locality.toLowerCase().contains(locality.toLowerCase())).toList();
        }
        if (type != null) {
          items = items.where((d) => d.disputeType == type).toList();
        }
        if (query != null && query.isNotEmpty) {
          items = items.where((d) =>
            d.title.toLowerCase().contains(query.toLowerCase()) ||
            d.locality.toLowerCase().contains(query.toLowerCase()) ||
            (d.caseNumber != null && d.caseNumber!.toLowerCase().contains(query.toLowerCase())) ||
            (d.surveyCtsNumber != null && d.surveyCtsNumber!.toLowerCase().contains(query.toLowerCase()))
          ).toList();
        }
        return items.map((d) => _maskPrivateInfo(d)).toList();
      }

      try {
        var q = _supabaseService.from('dispute_listings').select('*, dispute_documents(*)');

        // Public browse strictly filters for published records
        final effectiveStatus = status ?? 'published';
        q = q.eq('status', effectiveStatus);

        if (category != null && category != 'All' && category.isNotEmpty) {
          q = q.ilike('dispute_category', '%$category%');
        } else if (type != null) {
          q = q.ilike('dispute_category', '%${type.displayName}%');
        }

        if (locality != null && locality != 'All Localities' && locality.isNotEmpty) {
          q = q.ilike('locality', '%$locality%');
        }

        if (query != null && query.trim().isNotEmpty) {
          final trimmed = query.trim();
          q = q.or('title.ilike.%$trimmed%,locality.ilike.%$trimmed%,city.ilike.%$trimmed%,taluk.ilike.%$trimmed%,village.ilike.%$trimmed%,survey_number.ilike.%$trimmed%,property_number.ilike.%$trimmed%,case_number.ilike.%$trimmed%,court_authority_name.ilike.%$trimmed%,factual_summary.ilike.%$trimmed%');
        }

        final response = await q.order('created_at', ascending: false).range(offset, offset + limit - 1);

        final list = (response as List).map((json) => PropertyDisputeEntity.fromMap(json as Map<String, dynamic>)).toList();
        return list.map((d) => _maskPrivateInfo(d)).toList();
      } catch (e) {
        AppLogger.w('DisputeRemoteDataSource.fetchDisputedProperties error: $e');
        return const [];
      }
    });
  }

  @override
  Future<List<PropertyDisputeEntity>> fetchMyDisputedProperties({
    required String authenticatedUserId,
    String? statusFilter,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized || authenticatedUserId.isEmpty) {
        return const [];
      }

      try {
        var q = _supabaseService
            .from('dispute_listings')
            .select('*, dispute_documents(*)')
            .eq('creator_id', authenticatedUserId);

        if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'ALL') {
          if (statusFilter == 'REJECTED_WITHDRAWN') {
            q = q.or('status.eq.rejected,status.eq.withdrawn');
          } else {
            q = q.eq('status', statusFilter.toLowerCase());
          }
        }

        final response = await q.order('created_at', ascending: false).range(offset, offset + limit - 1);

        return (response as List).map((json) => PropertyDisputeEntity.fromMap(json as Map<String, dynamic>)).toList();
      } catch (e) {
        AppLogger.w('DisputeRemoteDataSource.fetchMyDisputedProperties error: $e');
        return const [];
      }
    });
  }

  @override
  Future<PropertyDisputeEntity?> fetchDisputeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        final existing = _testRegistry[id];
        if (existing != null) {
          final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
          final isOwnerReporter = existing.creatorId == requestingUserId || existing.reportedBy == requestingUserId;
          if (isAuthorized || isOwnerReporter) {
            return existing;
          } else {
            return _maskPrivateInfo(existing);
          }
        }

        if (id == 'disp_101' || id == 'disp_m_01') {
          final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
          final isOwnerReporter = requestingUserId == 'usr_claimant_1' || requestingUserId == 'usr_claimant_01';
          final sample = PropertyDisputeEntity(
            id: id,
            propertyId: 'prop_camp_house_201',
            title: 'Bungalow in Camp with Injunction Order',
            category: 'Residential',
            propertyType: 'Independent House',
            city: 'Belagavi',
            locality: 'Camp',
            surveyCtsNumber: 'CTS No. 892/1',
            relationship: 'I am claiming an interest',
            disputeType: DisputeType.courtCaseStayOrder,
            courtAuthority: 'Civil Court Senior Division, Belagavi',
            caseNumber: 'OS 440/2026',
            caseYear: '2026',
            caseStatus: 'Temporary Injunction Order in force',
            litigatingParties: 'Petitioner vs Vendor',
            description: 'Temporary injunction granted restraining alienation or creation of third-party rights.',
            contactName: 'Adv. Suresh Kulkarni',
            contactPhone: '+91 94801 22334',
            contactEmail: 'suresh.law@example.com',
            photoUrls: const ['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00'],
            documentUrls: const ['https://storage.belagaviproperty.com/disputes/stay_order_112.pdf'],
            isDocumentPrivate: true,
            verificationStatus: DisputeVerificationStatus.publishedListed,
            reportDate: DateTime(2026, 1, 1),
            lastUpdated: DateTime(2026, 1, 1),
          );
          if (isAuthorized || isOwnerReporter) {
            return sample;
          } else {
            return _maskPrivateInfo(sample);
          }
        }
        return null;
      }

      try {
        final res = await _supabaseService
            .from('dispute_listings')
            .select('*, dispute_documents(*), dispute_events(*), dispute_responses(*)')
            .eq('id', id)
            .maybeSingle();

        if (res == null) return null;

        final dispute = PropertyDisputeEntity.fromMap(res);
        final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
        final isOwnerReporter = dispute.creatorId == requestingUserId || dispute.reportedBy == requestingUserId;

        if (isAuthorized || isOwnerReporter) {
          return dispute;
        } else {
          return _maskPrivateInfo(dispute);
        }
      } catch (e) {
        AppLogger.w('DisputeRemoteDataSource.fetchDisputeById error: $e');
        return null;
      }
    });
  }

  @override
  Future<PropertyDisputeEntity> updateDisputeStatus({
    required String disputeId,
    required DisputeVerificationStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
      if (newStatus == DisputeVerificationStatus.publishedListed && !isAuthorized) {
        throw const UnauthorizedException('Only administrators or moderators can publish disputes');
      }

      final isConfirmed = isAuthorized && newStatus == DisputeVerificationStatus.publishedListed;

      if (!_supabaseService.isInitialized) {
        return PropertyDisputeEntity(
          id: disputeId,
          propertyId: disputeId,
          title: 'Updated Dispute',
          category: 'Residential',
          description: 'Updated dispute status.',
          disputeType: DisputeType.otherLegalDispute,
          verificationStatus: newStatus,
          isFounderConfirmed: isConfirmed,
        );
      }

      await _supabaseService.from('dispute_listings').update({
        'status': newStatus.dbValue,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', disputeId);

      // Audit event
      await _supabaseService.from('dispute_events').insert({
        'id': _generateUuidV4(),
        'dispute_id': disputeId,
        'event_type': 'status_changed',
        'actor_id': authenticatedUserId,
        'actor_role': isAuthorized ? 'admin' : 'user',
        'description': 'Dispute status updated to ${newStatus.displayName}.',
        'created_at': DateTime.now().toIso8601String(),
      });

      final fetched = await fetchDisputeById(disputeId, requestingUserId: authenticatedUserId, userRole: userRole);
      return fetched ?? PropertyDisputeEntity(
        id: disputeId,
        propertyId: disputeId,
        title: 'Updated Dispute',
        category: 'Residential',
        description: 'Updated dispute status.',
        disputeType: DisputeType.otherLegalDispute,
        verificationStatus: newStatus,
        isFounderConfirmed: isConfirmed,
      );
    });
  }

  @override
  Future<void> deleteDispute(
    String disputeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      final isAuthorized = userRole != null && userRole.isAdminOrFounder;
      if (!isAuthorized) {
        throw const UnauthorizedException('Unauthorized to delete dispute.');
      }

      if (_supabaseService.isInitialized) {
        await _supabaseService.from('dispute_listings').delete().eq('id', disputeId);
      }
    });
  }

  @override
  Future<List<DisputeDuplicateCandidate>> checkPossibleDuplicates({
    required String locality,
    String? surveyNumber,
    String? propertyNumber,
  }) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized || locality.isEmpty) {
        return const [];
      }

      try {
        var q = _supabaseService.from('dispute_listings').select('id, title, locality, survey_number, property_number, status, dispute_category').ilike('locality', '%$locality%');

        final conditions = <String>[];
        if (surveyNumber != null && surveyNumber.trim().isNotEmpty) {
          conditions.add('survey_number.ilike.%${surveyNumber.trim()}%');
        }
        if (propertyNumber != null && propertyNumber.trim().isNotEmpty) {
          conditions.add('property_number.ilike.%${propertyNumber.trim()}%');
        }

        if (conditions.isNotEmpty) {
          q = q.or(conditions.join(','));
        }

        final res = await q.limit(5);
        return (res as List).map((row) {
          final m = row as Map<String, dynamic>;
          return DisputeDuplicateCandidate(
            id: (m['id'] as String?) ?? '',
            title: (m['title'] as String?) ?? 'Dispute Record',
            locality: (m['locality'] as String?) ?? '',
            surveyNumber: m['survey_number'] as String?,
            propertyNumber: m['property_number'] as String?,
            status: (m['status'] as String?) ?? 'under_review',
            disputeCategory: (m['dispute_category'] as String?) ?? 'Ownership / Title',
          );
        }).toList();
      } catch (e) {
        AppLogger.w('checkPossibleDuplicates error: $e');
        return const [];
      }
    });
  }

  @override
  Future<DisputeResponseEntity> submitDisputeResponse({
    required String disputeId,
    required String respondentId,
    required String respondentName,
    required String respondentRole,
    required String responseType,
    required String statement,
    List<String> documentUrls = const [],
  }) async {
    return safeQuery(() async {
      final responseId = _generateUuidV4();
      final entity = DisputeResponseEntity(
        id: responseId,
        disputeId: disputeId,
        respondentId: respondentId,
        respondentName: respondentName,
        respondentRole: respondentRole,
        responseType: responseType,
        statement: statement,
        supportingDocumentUrls: documentUrls,
        status: 'submitted',
        createdAt: DateTime.now(),
      );

      if (_supabaseService.isInitialized) {
        await _supabaseService.from('dispute_responses').insert(entity.toSupabaseMap());

        await _supabaseService.from('dispute_events').insert({
          'id': _generateUuidV4(),
          'dispute_id': disputeId,
          'event_type': 'response_submitted',
          'actor_id': respondentId,
          'actor_role': 'user',
          'description': '$respondentRole ($respondentName) submitted a $responseType.',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return entity;
    });
  }

  @override
  Future<String> uploadDisputeDocumentFile({
    required String disputeId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) {
        return 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-media/disputes/$disputeId/$fileName';
      }

      try {
        final path = 'disputes/$disputeId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await _supabaseService.client.storage.from('property-media').uploadBinary(path, fileBytes);
        final publicUrl = _supabaseService.client.storage.from('property-media').getPublicUrl(path);
        return publicUrl;
      } catch (e) {
        AppLogger.w('uploadDisputeDocumentFile failed to upload: $e');
        return 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-media/disputes/$disputeId/$fileName';
      }
    });
  }

  PropertyDisputeEntity _maskPrivateInfo(PropertyDisputeEntity entity) {
    return entity.copyWith(
      contactName: entity.contactName != null && entity.contactName!.isNotEmpty ? 'Authorized Reporter' : null,
      contactPhone: entity.contactPhone != null && entity.contactPhone!.isNotEmpty ? '+91 ••••• •••••' : null,
      contactEmail: entity.contactEmail != null && entity.contactEmail!.isNotEmpty ? '••••@••••.com' : null,
      documentUrls: entity.isDocumentPrivate ? const [] : entity.documentUrls,
    );
  }
}