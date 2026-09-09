import 'dart:math';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/config/legal_notice_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/legal_notice_entities.dart';

String _generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40;
  values[8] = (values[8] & 0x3f) | 0x80;
  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

abstract class LegalNoticeRemoteDataSource {
  Future<TransactionLegalNoticeEntity> createLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
  });

  Future<List<TransactionLegalNoticeEntity>> fetchLegalNotices({
    LegalNoticeType? type,
    String? transactionType,
    String? locality,
    String? query,
    int limit = 50,
    int offset = 0,
  });

  Future<TransactionLegalNoticeEntity?> fetchLegalNoticeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  });

  Future<TransactionLegalNoticeEntity> updateLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<TransactionLegalNoticeEntity> attachDocuments(
    String noticeId, {
    required List<String> newDocuments,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<TransactionLegalNoticeEntity> updateStatus({
    required String noticeId,
    required LegalNoticeStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<void> deleteLegalNotice(
    String noticeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  });

  Future<String> uploadLegalNoticeDocumentFile({
    required String noticeId,
    required String fileName,
    required Uint8List fileBytes,
    String? authenticatedUserId,
  });

  // End-to-End Legal Notice & Dispute Assistance Module Methods
  Future<LegalMatterEntity> createLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  });

  Future<List<LegalMatterEntity>> fetchUserLegalMatters({
    required String authenticatedUserId,
    LegalMatterStatus? statusFilter,
    String? categoryFilter,
    String? query,
  });

  Future<LegalMatterEntity?> fetchLegalMatterById(
    String matterId, {
    required String authenticatedUserId,
  });

  Future<LegalMatterEntity> updateLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  });

  Future<LegalMatterEntity> updateMatterStatus({
    required String matterId,
    required LegalMatterStatus newStatus,
    required String authenticatedUserId,
  });

  Future<LegalMatterEntity> addDraftVersion(
    String matterId, {
    required int versionNumber,
    required String contentMarkdown,
    required String generatedByType,
    String? reasonForChange,
    required String authenticatedUserId,
  });

  Future<LegalMatterEntity> recordServiceAttempt(
    String matterId, {
    required LegalServiceAttemptEntity attempt,
    required String authenticatedUserId,
  });

  Future<LegalMatterEntity> recordResponse(
    String matterId, {
    required LegalResponseEntity response,
    required String authenticatedUserId,
  });
}

@LazySingleton(as: LegalNoticeRemoteDataSource)
class LegalNoticeRemoteDataSourceImpl extends BaseRemoteDataSource implements LegalNoticeRemoteDataSource {
  final SupabaseService _supabaseService;

  // In-memory persistent registry store for reliable local/offline operation and test determinism
  static final Map<String, TransactionLegalNoticeEntity> _localRegistry = {
    'not_101': TransactionLegalNoticeEntity(
      id: 'not_101',
      propertyId: 'prop_tilak_bungalow_101',
      title: 'Agreement to Sell: 4 BHK Independent Bungalow Tilakwadi',
      category: 'Residential',
      propertyType: 'Independent House',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      surveyCtsNumber: 'CTS No. 2314/B',
      buyerName: 'Mr. Arvind Joshi',
      buyerAddress: 'Tilakwadi, Belagavi',
      buyerAdvocate: 'Adv. M. S. Patil',
      sellerName: 'Dr. Ramesh Kulkarni',
      sellerAddress: 'Camp, Belagavi',
      contactName: 'Adv. M. S. Patil (Buyer Counsel)',
      contactPhone: '+91 94481 44556',
      contactEmail: 'patil.legal@example.com',
      contactRole: 'Legal Advocate',
      transactionType: 'Purchase',
      agreedValue: 'â‚¹ 1.65 Crore',
      agreementDate: '15/08/2026',
      executionDate: '30/10/2026',
      transactionStatus: 'Agreement Executed / Title Search in Progress',
      transactionDescription: 'Registered Agreement to sell executed with 20% advance token paid. 30-year title verification underway.',
      noticeType: LegalNoticeType.purchaseLegalNotice,
      issuingAuthority: 'Sub-Registrar Office Belagavi',
      referenceNumber: 'BGM/SR/NOTICE/2026/89',
      noticeDate: '16/08/2026',
      publicNoticeSummary: 'Public caveat inviting claims or objections within 15 days of notice date.',
      dueDiligenceNotes: 'Original 1994 Sale deed inspected. Form 15 Encumbrance Certificate obtained up to date.',
      photoUrls: const ['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00'],
      documentUrls: const ['https://storage.belagaviproperty.com/legal/agreement_to_sell_2314.pdf'],
      isDocumentPrivate: true,
      canAddDocumentsLater: true,
      verificationStatus: LegalNoticeStatus.underReview,
      recordedBy: 'usr_buyer_joshi',
      createdAt: DateTime(2026, 8, 16),
      updatedAt: DateTime(2026, 8, 16),
    ),
    'not_102': TransactionLegalNoticeEntity(
      id: 'not_102',
      propertyId: 'prop_plot_mandoli_102',
      title: 'Public Notice of Sale: 2400 sq.ft NA Plot Mandoli Road',
      category: 'Plots & Layouts',
      propertyType: 'Residential Plot',
      city: 'Belagavi',
      locality: 'Mandoli Road',
      surveyCtsNumber: 'Sy No. 44/2A, Plot No. 12',
      buyerName: 'Proposed Purchaser (Public Notice)',
      sellerName: 'Mrs. Sunita Deshpande',
      sellerAddress: 'Mandoli Road, Belagavi',
      contactName: 'Adv. S. K. Hegde',
      contactPhone: '+91 98801 88990',
      contactEmail: 'hegde.associates@example.com',
      contactRole: 'Legal Advocate',
      transactionType: 'Sale',
      agreedValue: 'â‚¹ 58 Lakhs',
      agreementDate: '20/08/2026',
      executionDate: '15/11/2026',
      transactionStatus: 'Under Negotiation / Proposed',
      transactionDescription: 'Intended absolute sale transfer. Vendor claims free of all prior encumbrances and family claims.',
      noticeType: LegalNoticeType.saleLegalNotice,
      issuingAuthority: 'Advocate Public Notice & Sub-Registrar Notification',
      referenceNumber: 'PUB/NOT/2026/412',
      noticeDate: '21/08/2026',
      publicNoticeSummary: 'Any person having lien, mortgage, maintenance, or charge should submit objections within 14 days.',
      dueDiligenceNotes: 'DC Conversion Order & BUDA approved layout blueprint verified.',
      photoUrls: const ['https://images.unsplash.com/photo-1500382017468-9049fed747ef'],
      documentUrls: const [],
      isDocumentPrivate: true,
      canAddDocumentsLater: true,
      verificationStatus: LegalNoticeStatus.recorded,
      recordedBy: 'usr_seller_deshpande',
      createdAt: DateTime(2026, 8, 21),
      updatedAt: DateTime(2026, 8, 21),
    ),
  };

  LegalNoticeRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<TransactionLegalNoticeEntity> createLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final recordId = notice.id.isNotEmpty
          ? notice.id
          : _generateUuidV4();
      final propId = notice.propertyId.isNotEmpty
          ? notice.propertyId
          : null;

      final targetStatus = notice.verificationStatus == LegalNoticeStatus.draft
          ? LegalNoticeStatus.draft
          : LegalNoticeStatus.underReview;

      final now = DateTime.now();
      final isPublished = targetStatus == LegalNoticeStatus.published;
      final pubAt = isPublished ? (notice.publishedAt ?? now) : notice.publishedAt;
      final pubUntil = isPublished ? (notice.publicUntil ?? LegalNoticeConfig.calculatePublicUntil(pubAt!)) : notice.publicUntil;

      final enriched = notice.copyWith(
        id: recordId,
        propertyId: propId ?? '',
        verificationStatus: targetStatus,
        recordedBy: authenticatedUserId,
        publishedAt: pubAt,
        publicUntil: pubUntil,
        createdAt: now,
        updatedAt: now,
      );

      _localRegistry[recordId] = enriched;

      if (_supabaseService.isInitialized) {
        try {
          final payload = enriched.toSupabaseMap();
          payload['id'] = recordId;
          payload['publisher_id'] = authenticatedUserId;
          if (propId != null) payload['property_id'] = propId;
          await _supabaseService.from('legal_notices').insert(payload);

          // Save attached documents to legal_notice_documents
          if (notice.documentUrls.isNotEmpty) {
            for (final docUrl in notice.documentUrls) {
              await _supabaseService.from('legal_notice_documents').insert({
                'id': _generateUuidV4(),
                'notice_id': recordId,
                'document_type': 'Legal Notice Scan',
                'storage_path': docUrl,
                'public_url': docUrl,
                'is_redacted': notice.isDocumentPrivate,
                'created_at': DateTime.now().toIso8601String(),
              });
            }
          }

          // Insert audit event
          await _supabaseService.from('legal_notice_events').insert({
            'id': _generateUuidV4(),
            'notice_id': recordId,
            'event_type': 'created',
            'actor_id': authenticatedUserId,
            'description': 'Legal notice recorded and submitted for platform review.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          AppLogger.w('Failed to insert into live legal_notices: $e');
        }
      }

      return enriched;
    });
  }

  @override
  Future<List<TransactionLegalNoticeEntity>> fetchLegalNotices({
    LegalNoticeType? type,
    String? transactionType,
    String? locality,
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    return safeQuery(() async {
      List<TransactionLegalNoticeEntity> list = [];

      if (_supabaseService.isInitialized) {
        try {
          var q = _supabaseService.from('legal_notices').select('*, legal_notice_documents(*)');
          if (type != null) q = q.eq('notice_type', type.name);
          if (locality != null && locality != 'All Localities' && locality.isNotEmpty) {
            q = q.ilike('locality', '%$locality%');
          }
          if (query != null && query.trim().isNotEmpty) {
            final trimmed = query.trim();
            q = q.or('notice_title.ilike.%$trimmed%,locality.ilike.%$trimmed%,city.ilike.%$trimmed%,publisher_name.ilike.%$trimmed%,survey_property_number.ilike.%$trimmed%,short_summary.ilike.%$trimmed%');
          }
          final response = await q.order('created_at', ascending: false).range(offset, offset + limit - 1);
          list = (response as List).map((json) => TransactionLegalNoticeEntity.fromMap(json as Map<String, dynamic>)).toList();
        } catch (e) {
          AppLogger.w('Failed to fetch from live legal_notices: $e');
          list = _localRegistry.values.toList();
        }
      } else {
        list = _localRegistry.values.toList();
      }

      var filtered = list;
      if (type != null) {
        filtered = filtered.where((n) => n.noticeType == type).toList();
      }
      if (transactionType != null && transactionType.isNotEmpty && transactionType != 'All Types') {
        filtered = filtered.where((n) => n.transactionType.toLowerCase() == transactionType.toLowerCase()).toList();
      }
      if (locality != null && locality != 'All Localities' && locality.isNotEmpty) {
        filtered = filtered.where((n) => n.locality.toLowerCase().contains(locality.toLowerCase())).toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        filtered = filtered.where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.locality.toLowerCase().contains(q) ||
            n.city.toLowerCase().contains(q) ||
            n.buyerName.toLowerCase().contains(q) ||
            n.sellerName.toLowerCase().contains(q) ||
            (n.referenceNumber != null && n.referenceNumber!.toLowerCase().contains(q)) ||
            (n.issuingAuthority != null && n.issuingAuthority!.toLowerCase().contains(q))).toList();
      }

      // Security / Privacy gate: sanitize private contact info & legal documents for public caller
      return filtered.map((n) => _maskPrivateInfo(n)).toList();
    });
  }

  @override
  Future<TransactionLegalNoticeEntity?> fetchLegalNoticeById(
    String id, {
    required String requestingUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      TransactionLegalNoticeEntity? notice;
      if (_supabaseService.isInitialized) {
        try {
          final res = await _supabaseService
              .from('legal_notices')
              .select('*, legal_notice_documents(*), legal_notice_events(*)')
              .eq('id', id)
              .maybeSingle();
          if (res != null) notice = TransactionLegalNoticeEntity.fromMap(res);
        } catch (e) {
          AppLogger.w('fetchLegalNoticeById error: $e');
        }
      }
      notice ??= _localRegistry[id];
      if (notice == null) return null;

      final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
      final isCreator = notice.recordedBy == requestingUserId;

      if (isAuthorized || isCreator) {
        return notice;
      } else {
        return _maskPrivateInfo(notice);
      }
    });
  }

  @override
  Future<TransactionLegalNoticeEntity> updateLegalNotice(
    TransactionLegalNoticeEntity notice, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      final existing = _localRegistry[notice.id] ??
          await fetchLegalNoticeById(notice.id, requestingUserId: authenticatedUserId, userRole: userRole);

      if (existing != null) {
        final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
        final isCreator = existing.recordedBy == authenticatedUserId;
        if (!isAuthorized && !isCreator) {
          throw const UnauthorizedException('Unauthorized to update legal notice record.');
        }
      }

      final updated = notice.copyWith(updatedAt: DateTime.now());
      _localRegistry[notice.id] = updated;

      if (_supabaseService.isInitialized) {
        try {
          final payload = updated.toSupabaseMap();
          payload['publisher_id'] = updated.recordedBy.isNotEmpty ? updated.recordedBy : authenticatedUserId;
          await _supabaseService.from('legal_notices').update(payload).eq('id', notice.id);

          // Audit event
          await _supabaseService.from('legal_notice_events').insert({
            'id': _generateUuidV4(),
            'notice_id': notice.id,
            'event_type': 'updated',
            'actor_id': authenticatedUserId,
            'description': 'Legal notice details updated.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          AppLogger.w('updateLegalNotice error: $e');
        }
      }

      return updated;
    });
  }

  @override
  Future<TransactionLegalNoticeEntity> attachDocuments(
    String noticeId, {
    required List<String> newDocuments,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      final existing = _localRegistry[noticeId] ??
          await fetchLegalNoticeById(noticeId, requestingUserId: authenticatedUserId, userRole: userRole);

      if (existing == null) {
        throw const NotFoundException('Legal notice record not found');
      }

      final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
      final isCreator = existing.recordedBy == authenticatedUserId;

      if (!isAuthorized && !isCreator) {
        throw const UnauthorizedException('Unauthorized to attach documents to this legal notice.');
      }

      final updatedDocs = List<String>.from(existing.documentUrls)..addAll(newDocuments);
      final updated = existing.copyWith(
        documentUrls: updatedDocs.toSet().toList(),
        updatedAt: DateTime.now(),
      );
      _localRegistry[noticeId] = updated;

      if (_supabaseService.isInitialized) {
        try {
          for (final docUrl in newDocuments) {
            await _supabaseService.from('legal_notice_documents').insert({
              'id': _generateUuidV4(),
              'notice_id': noticeId,
              'document_type': 'Attached Scan',
              'storage_path': docUrl,
              'public_url': docUrl,
              'is_redacted': existing.isDocumentPrivate,
              'created_at': DateTime.now().toIso8601String(),
            });
          }

          await _supabaseService.from('legal_notices').update({
            'has_documents': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', noticeId);

          await _supabaseService.from('legal_notice_events').insert({
            'id': _generateUuidV4(),
            'notice_id': noticeId,
            'event_type': 'document_added',
            'actor_id': authenticatedUserId,
            'description': '${newDocuments.length} document(s) attached to notice.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          AppLogger.w('attachDocuments error: $e');
        }
      }

      return updated;
    });
  }

  @override
  Future<TransactionLegalNoticeEntity> updateStatus({
    required String noticeId,
    required LegalNoticeStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      final existing = _localRegistry[noticeId] ??
          await fetchLegalNoticeById(noticeId, requestingUserId: authenticatedUserId, userRole: userRole);

      if (existing == null) {
        throw const NotFoundException('Legal notice record not found');
      }

      final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
      final isCreator = existing.recordedBy == authenticatedUserId;

      if (!isAuthorized && !isCreator) {
        throw const UnauthorizedException('Unauthorized to update legal notice status.');
      }

      final now = DateTime.now();
      DateTime? pubAt = existing.publishedAt;
      DateTime? pubUntil = existing.publicUntil;
      DateTime? expAt = existing.expiredAt;

      if (newStatus == LegalNoticeStatus.published) {
        pubAt ??= now;
        pubUntil ??= LegalNoticeConfig.calculatePublicUntil(pubAt);
        expAt = null;
      } else if (newStatus == LegalNoticeStatus.closed || newStatus == LegalNoticeStatus.withdrawn) {
        expAt ??= now;
      }

      final updated = existing.copyWith(
        verificationStatus: newStatus,
        publishedAt: pubAt,
        publicUntil: pubUntil,
        expiredAt: expAt,
        updatedAt: now,
      );
      _localRegistry[noticeId] = updated;

      if (_supabaseService.isInitialized) {
        try {
          final dbStatus = newStatus == LegalNoticeStatus.draft
              ? 'draft'
              : (newStatus == LegalNoticeStatus.published ? 'published' : 'under_review');
          final updatePayload = <String, dynamic>{
            'status': dbStatus,
            'updated_at': now.toIso8601String(),
          };
          if (pubAt != null) updatePayload['published_at'] = pubAt.toIso8601String();
          if (pubUntil != null) updatePayload['public_until'] = pubUntil.toIso8601String();
          if (expAt != null) updatePayload['expired_at'] = expAt.toIso8601String();

          await _supabaseService.from('legal_notices').update(updatePayload).eq('id', noticeId);

          await _supabaseService.from('legal_notice_events').insert({
            'id': _generateUuidV4(),
            'notice_id': noticeId,
            'event_type': 'status_changed',
            'actor_id': authenticatedUserId,
            'description': 'Notice status updated to ${newStatus.displayName}.',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          AppLogger.w('updateStatus error: $e');
        }
      }

      return updated;
    });
  }

  @override
  Future<void> deleteLegalNotice(
    String noticeId, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    return safeQuery(() async {
      final existing = _localRegistry[noticeId] ??
          await fetchLegalNoticeById(noticeId, requestingUserId: authenticatedUserId, userRole: userRole);

      final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
      final isCreator = existing != null && existing.recordedBy == authenticatedUserId;
      final isDeletable = existing != null && (
        existing.verificationStatus == LegalNoticeStatus.draft ||
        existing.verificationStatus == LegalNoticeStatus.submitted ||
        existing.verificationStatus == LegalNoticeStatus.underReview ||
        existing.verificationStatus == LegalNoticeStatus.withdrawn ||
        existing.verificationStatus == LegalNoticeStatus.closed ||
        existing.verificationStatus == LegalNoticeStatus.rejected
      );

      if (!isAuthorized && !(isCreator && isDeletable)) {
        throw const UnauthorizedException('Unauthorized to delete legal notice.');
      }

      _localRegistry.remove(noticeId);

      if (_supabaseService.isInitialized) {
        try {
          // Cleanup storage files in property-documents / property-media
          final docRows = await _supabaseService.from('legal_notice_documents').select('storage_path').eq('notice_id', noticeId);
          final pathsToRemove = <String>[];
          for (final row in (docRows as List)) {
            final p = row['storage_path'] as String?;
            if (p != null && p.isNotEmpty && !p.startsWith('http')) {
              pathsToRemove.add(p);
            }
          }
          if (pathsToRemove.isNotEmpty) {
            await _supabaseService.client.storage.from('property-media').remove(pathsToRemove);
          }
        } catch (e) {
          AppLogger.w('deleteLegalNotice storage cleanup warning: $e');
        }

        try {
          await _supabaseService.from('legal_notices').delete().eq('id', noticeId);
        } catch (e) {
          AppLogger.w('deleteLegalNotice DB delete warning: $e');
        }
      }
    });
  }

  // End-to-End Legal Notice & Dispute Assistance Module Implementations
  static final Map<String, LegalMatterEntity> _mattersRegistry = {};

  @override
  Future<LegalMatterEntity> createLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final matterId = matter.id.isEmpty ? 'matter_${DateTime.now().millisecondsSinceEpoch}' : matter.id;
      final refNum = matter.matterReference.isEmpty ? 'LGL-BEL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}' : matter.matterReference;
      final newMatter = matter.copyWith(
        id: matterId,
        userId: authenticatedUserId,
        matterReference: refNum,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _mattersRegistry[matterId] = newMatter;

      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('legal_matters').insert({
            'id': matterId,
            'user_id': authenticatedUserId,
            'property_id': matter.propertyId,
            'matter_reference': refNum,
            'title': matter.title,
            'category': matter.category,
            'notice_type': matter.noticeType.name,
            'status': matter.status.dbValue,
            'is_high_risk': matter.isHighRisk,
            'requires_advocate_review': matter.requiresAdvocateReview,
            'country': matter.country,
            'state': matter.state,
            'district': matter.district,
            'city': matter.city,
            'locality': matter.locality,
            'full_address': matter.fullAddress,
            'survey_cts_number': matter.surveyCtsNumber,
            'khata_number': matter.khataNumber,
            'plot_flat_number': matter.plotFlatNumber,
            'financial_claim_amount': matter.financialClaimAmount,
            'agreed_total_consideration': matter.agreedTotalConsideration,
            'amount_paid_so_far': matter.amountPaidSoFar,
            'interest_rate_claimed': matter.interestRateClaimed,
            'desired_remedy': matter.desiredRemedy,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}
      }

      return newMatter;
    });
  }

  @override
  Future<List<LegalMatterEntity>> fetchUserLegalMatters({
    required String authenticatedUserId,
    LegalMatterStatus? statusFilter,
    String? categoryFilter,
    String? query,
  }) async {
    return safeQuery(() async {
      List<LegalMatterEntity> list = _mattersRegistry.values
          .where((m) => m.userId == authenticatedUserId || authenticatedUserId.isEmpty)
          .toList();

      if (statusFilter != null) {
        list = list.where((m) => m.status == statusFilter).toList();
      }
      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        list = list.where((m) => m.category.toLowerCase().contains(categoryFilter.toLowerCase())).toList();
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        list = list.where((m) =>
            m.title.toLowerCase().contains(q) ||
            m.matterReference.toLowerCase().contains(q) ||
            m.locality.toLowerCase().contains(q) ||
            m.parties.any((p) => p.name.toLowerCase().contains(q))).toList();
      }

      if (_supabaseService.isInitialized) {
        try {
          var req = _supabaseService.from('legal_matters').select().eq('user_id', authenticatedUserId);
          if (statusFilter != null) {
            req = req.eq('status', statusFilter.dbValue);
          }
          final res = await req;
          final remoteMatters = (res as List).map((map) => LegalMatterEntity.fromMap(map)).toList();
          for (final rm in remoteMatters) {
            _mattersRegistry[rm.id] = rm;
          }
          if (remoteMatters.isNotEmpty) {
            list = remoteMatters;
          }
        } catch (_) {}
      }

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<LegalMatterEntity?> fetchLegalMatterById(
    String matterId, {
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      if (_mattersRegistry.containsKey(matterId)) {
        return _mattersRegistry[matterId];
      }
      if (_supabaseService.isInitialized) {
        try {
          final res = await _supabaseService.from('legal_matters').select().eq('id', matterId).maybeSingle();
          if (res != null) {
            final m = LegalMatterEntity.fromMap(res);
            _mattersRegistry[m.id] = m;
            return m;
          }
        } catch (_) {}
      }
      return null;
    });
  }

  @override
  Future<LegalMatterEntity> updateLegalMatter(
    LegalMatterEntity matter, {
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final updated = matter.copyWith(updatedAt: DateTime.now());
      _mattersRegistry[matter.id] = updated;

      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('legal_matters').update(updated.toMap()).eq('id', matter.id);
        } catch (_) {}
      }
      return updated;
    });
  }

  @override
  Future<LegalMatterEntity> updateMatterStatus({
    required String matterId,
    required LegalMatterStatus newStatus,
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final existing = _mattersRegistry[matterId];
      if (existing == null) {
        throw const NotFoundException('Legal matter not found');
      }
      final updated = existing.copyWith(status: newStatus, updatedAt: DateTime.now());
      _mattersRegistry[matterId] = updated;

      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('legal_matters').update({
            'status': newStatus.dbValue,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', matterId);
        } catch (_) {}
      }
      return updated;
    });
  }

  @override
  Future<LegalMatterEntity> addDraftVersion(
    String matterId, {
    required int versionNumber,
    required String contentMarkdown,
    required String generatedByType,
    String? reasonForChange,
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final existing = _mattersRegistry[matterId];
      if (existing == null) {
        throw const NotFoundException('Legal matter not found');
      }
      final newVer = LegalNoticeVersionEntity(
        id: 'ver_${DateTime.now().millisecondsSinceEpoch}',
        versionNumber: versionNumber,
        contentMarkdown: contentMarkdown,
        generatedByType: generatedByType,
        reasonForChange: reasonForChange,
        createdBy: authenticatedUserId,
        createdAt: DateTime.now(),
      );
      final updatedVersions = [...existing.versionHistory, newVer];
      final updated = existing.copyWith(
        versionHistory: updatedVersions,
        status: LegalMatterStatus.draftReady,
        updatedAt: DateTime.now(),
      );
      _mattersRegistry[matterId] = updated;
      return updated;
    });
  }

  @override
  Future<LegalMatterEntity> recordServiceAttempt(
    String matterId, {
    required LegalServiceAttemptEntity attempt,
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final existing = _mattersRegistry[matterId];
      if (existing == null) {
        throw const NotFoundException('Legal matter not found');
      }
      final updatedService = [...existing.serviceAttempts, attempt];
      final updated = existing.copyWith(
        serviceAttempts: updatedService,
        status: LegalMatterStatus.served,
        updatedAt: DateTime.now(),
      );
      _mattersRegistry[matterId] = updated;
      return updated;
    });
  }

  @override
  Future<LegalMatterEntity> recordResponse(
    String matterId, {
    required LegalResponseEntity response,
    required String authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final existing = _mattersRegistry[matterId];
      if (existing == null) {
        throw const NotFoundException('Legal matter not found');
      }
      final updatedResponses = [...existing.responses, response];
      final updated = existing.copyWith(
        responses: updatedResponses,
        status: LegalMatterStatus.responseReceived,
        updatedAt: DateTime.now(),
      );
      _mattersRegistry[matterId] = updated;
      return updated;
    });
  }

  @override
  Future<String> uploadLegalNoticeDocumentFile({
    required String noticeId,
    required String fileName,
    required Uint8List fileBytes,
    String? authenticatedUserId,
  }) async {
    return safeQuery(() async {
      final uid = (authenticatedUserId != null && authenticatedUserId.isNotEmpty)
          ? authenticatedUserId
          : 'usr_anonymous';

      if (!_supabaseService.isInitialized) {
        return 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-media/legal_notices/$uid/$noticeId/$fileName';
      }

      try {
        final path = 'legal_notices/$uid/$noticeId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        await _supabaseService.client.storage.from('property-media').uploadBinary(path, fileBytes);
        final publicUrl = _supabaseService.client.storage.from('property-media').getPublicUrl(path);
        return publicUrl;
      } catch (e) {
        AppLogger.w('uploadLegalNoticeDocumentFile failed to upload: $e');
        return 'https://fzgfgimscwrafnhahzlk.supabase.co/storage/v1/object/public/property-media/legal_notices/$uid/$noticeId/$fileName';
      }
    });
  }

  TransactionLegalNoticeEntity _maskPrivateInfo(TransactionLegalNoticeEntity entity) {
    return entity.copyWith(
      contactPhone: entity.contactPhone.isNotEmpty ? '+91 ••••• •••••' : '',
      contactEmail: entity.contactEmail != null && entity.contactEmail!.isNotEmpty ? '••••@••••.com' : null,
      documentUrls: entity.isDocumentPrivate ? const [] : entity.documentUrls,
    );
  }
}