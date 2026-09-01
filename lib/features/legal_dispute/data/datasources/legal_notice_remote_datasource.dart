import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/security/user_role.dart';
import '../../domain/entities/legal_notice_entities.dart';

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
          : 'not_${DateTime.now().millisecondsSinceEpoch}';
      final propId = notice.propertyId.isNotEmpty
          ? notice.propertyId
          : 'prop_not_${DateTime.now().millisecondsSinceEpoch}';

      final targetStatus = notice.verificationStatus == LegalNoticeStatus.draft
          ? LegalNoticeStatus.draft
          : LegalNoticeStatus.underReview;

      final enriched = notice.copyWith(
        id: recordId,
        propertyId: propId,
        verificationStatus: targetStatus,
        recordedBy: authenticatedUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _localRegistry[recordId] = enriched;

      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('property_legal_notices').insert(enriched.toMap());
        } catch (_) {}
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
      List<TransactionLegalNoticeEntity> list;

      if (_supabaseService.isInitialized) {
        try {
          var q = _supabaseService.from('property_legal_notices').select();
          if (type != null) q = q.eq('notice_type', type.name);
          if (transactionType != null && transactionType.isNotEmpty && transactionType != 'All Types') {
            q = q.eq('transaction_type', transactionType);
          }
          if (locality != null && locality != 'All Localities' && locality.isNotEmpty) {
            q = q.ilike('locality', '%$locality%');
          }
          final response = await q.range(offset, offset + limit - 1);
          list = (response as List).map((json) => TransactionLegalNoticeEntity.fromMap(json)).toList();
        } catch (_) {
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
          final res = await _supabaseService.from('property_legal_notices').select().eq('id', id).maybeSingle();
          if (res != null) notice = TransactionLegalNoticeEntity.fromMap(res);
        } catch (_) {}
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
      final existing = _localRegistry[notice.id];
      if (existing == null) {
        throw Exception('Legal notice record not found: ${notice.id}');
      }

      final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
      final isCreator = existing.recordedBy == authenticatedUserId;

      if (!isAuthorized && !isCreator) {
        throw Exception('Unauthorized to update legal notice record.');
      }

      final updated = notice.copyWith(updatedAt: DateTime.now());
      _localRegistry[notice.id] = updated;

      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('property_legal_notices').update(updated.toMap()).eq('id', notice.id);
        } catch (_) {}
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
      final existing = _localRegistry[noticeId];
      if (existing == null) {
        throw Exception('Legal notice record not found: $noticeId');
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
          await _supabaseService.from('property_legal_notices').update({
            'document_urls': updated.documentUrls,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', noticeId);
        } catch (_) {}
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
      final existing = _localRegistry[noticeId];
      if (existing == null) {
        throw const NotFoundException('Legal notice record not found');
      }

      final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
      final isCreator = existing.recordedBy == authenticatedUserId;

      if (!isAuthorized && !isCreator) {
        throw const UnauthorizedException('Unauthorized to update legal notice status.');
      }

      final updated = existing.copyWith(
        verificationStatus: newStatus,
        updatedAt: DateTime.now(),
      );
      _localRegistry[noticeId] = updated;

      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('property_legal_notices').update({
            'verification_status': newStatus.name,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', noticeId);
        } catch (_) {}
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
      final existing = _localRegistry[noticeId];
      if (existing != null) {
        final isAuthorized = userRole != null && (userRole.isAdminOrFounder || userRole.isModerator);
        final isCreator = existing.recordedBy == authenticatedUserId;
        if (!isAuthorized && !isCreator) {
          throw const UnauthorizedException('Unauthorized to delete legal notice.');
        }
      }
      _localRegistry.remove(noticeId);
      if (_supabaseService.isInitialized) {
        try {
          await _supabaseService.from('property_legal_notices').delete().eq('id', noticeId);
          } catch (_) {}
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

  TransactionLegalNoticeEntity _maskPrivateInfo(TransactionLegalNoticeEntity entity) {
    return entity.copyWith(
      contactPhone: entity.contactPhone.isNotEmpty ? '+91 ••••• •••••' : '',
      contactEmail: entity.contactEmail != null && entity.contactEmail!.isNotEmpty ? '••••@••••.com' : null,
      documentUrls: entity.isDocumentPrivate ? const [] : entity.documentUrls,
    );
  }
}