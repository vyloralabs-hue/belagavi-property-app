import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/errors/security_exceptions.dart';

import '../../../../core/security/user_role.dart';
import '../../data/datasources/property_remote_datasource.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/repositories/property_repository.dart';
import '../../utils/property_security_guard.dart';
import '../../utils/property_status_workflow.dart';

enum MyPropertiesStateStatus { initial, loading, loaded, error }

class MyPropertiesState extends Equatable {
  final MyPropertiesStateStatus status;
  final String activeTab; // 'All', 'Drafts', 'Submitted', 'Under Review', 'Changes Requested', 'Approved', 'Published', 'Paused', 'Rejected', 'Disputed', 'Archived'
  final List<PropertyEntity> allProperties;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool profileResolved;
  final bool remoteFetchSucceeded;
  final Set<String> remotePropertyIds;

  const MyPropertiesState({
    this.status = MyPropertiesStateStatus.initial,
    this.activeTab = 'All',
    this.allProperties = const [],
    this.errorMessage,
    this.isAuthenticated = false,
    this.profileResolved = false,
    this.remoteFetchSucceeded = false,
    this.remotePropertyIds = const {},
  });

  List<PropertyEntity> get filteredProperties {
    if (activeTab == 'All') return allProperties;
    if (activeTab == 'Drafts' || activeTab == 'DRAFT') {
      return allProperties.where((p) => p.status == ListingStatus.draft).toList();
    }
    if (activeTab == 'Submitted' || activeTab == 'SUBMITTED') {
      return allProperties.where((p) => p.status == ListingStatus.submitted || p.status == ListingStatus.pendingVerification).toList();
    }
    if (activeTab == 'Under Review' || activeTab == 'UNDER_REVIEW') {
      return allProperties.where((p) => p.status == ListingStatus.underReview).toList();
    }
    if (activeTab == 'Changes Requested' || activeTab == 'CHANGES_REQUESTED') {
      return allProperties.where((p) => p.status == ListingStatus.changesRequested).toList();
    }
    if (activeTab == 'Approved' || activeTab == 'APPROVED') {
      return allProperties.where((p) => p.status == ListingStatus.approved).toList();
    }
    if (activeTab == 'Published' || activeTab == 'PUBLISHED') {
      return allProperties
          .where((p) => p.status == ListingStatus.published || p.status == ListingStatus.active)
          .toList();
    }
    if (activeTab == 'Paused' || activeTab == 'PAUSED') {
      return allProperties.where((p) => p.status == ListingStatus.paused).toList();
    }
    if (activeTab == 'Rejected' || activeTab == 'REJECTED') {
      return allProperties.where((p) => p.status == ListingStatus.rejected).toList();
    }
    if (activeTab == 'Disputed' || activeTab == 'DISPUTED') {
      return allProperties.where((p) => p.status == ListingStatus.disputed).toList();
    }
    if (activeTab == 'Archived' || activeTab == 'ARCHIVED') {
      return allProperties.where((p) => p.status == ListingStatus.archived).toList();
    }
    return allProperties;
  }

  MyPropertiesState copyWith({
    MyPropertiesStateStatus? status,
    String? activeTab,
    List<PropertyEntity>? allProperties,
    String? errorMessage,
    bool? isAuthenticated,
    bool? profileResolved,
    bool? remoteFetchSucceeded,
    Set<String>? remotePropertyIds,
  }) {
    return MyPropertiesState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      allProperties: allProperties ?? this.allProperties,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profileResolved: profileResolved ?? this.profileResolved,
      remoteFetchSucceeded: remoteFetchSucceeded ?? this.remoteFetchSucceeded,
      remotePropertyIds: remotePropertyIds ?? this.remotePropertyIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeTab,
        allProperties,
        errorMessage,
        isAuthenticated,
        profileResolved,
        remoteFetchSucceeded,
        remotePropertyIds,
      ];
}

class MyPropertiesNotifier extends StateNotifier<MyPropertiesState> {
  final PropertyRepository _repository;

  MyPropertiesNotifier(this._repository) : super(const MyPropertiesState());

  Future<void> fetchMyProperties(String authenticatedUserId) async {
    state = state.copyWith(status: MyPropertiesStateStatus.loading);
    AppLogger.i('[MyProperties] fetchMyProperties initiating...');
    final result = await _repository.getPropertiesByOwner(ownerId: authenticatedUserId);
    final isAuth = FirebaseAuth.instance.currentUser != null;
    final profRes = PropertyRemoteDataSourceImpl.lastFetchProfileResolved;
    final remoteSucc = PropertyRemoteDataSourceImpl.lastRemoteFetchSucceeded;
    final remoteIds = PropertyRemoteDataSourceImpl.lastRemotePropertyIds;

    result.fold(
      (failure) {
        AppLogger.e('[MyProperties] fetchMyProperties failed: ${failure.message}');
        state = state.copyWith(
          status: MyPropertiesStateStatus.error,
          errorMessage: failure.message,
          isAuthenticated: isAuth,
          profileResolved: profRes,
          remoteFetchSucceeded: remoteSucc,
          remotePropertyIds: remoteIds,
        );
      },
      (list) {
        AppLogger.i('[MyProperties] SUCCESS: loaded count=${list.length}');
        state = state.copyWith(
          status: MyPropertiesStateStatus.loaded,
          allProperties: list,
          isAuthenticated: isAuth,
          profileResolved: profRes,
          remoteFetchSucceeded: remoteSucc,
          remotePropertyIds: remoteIds,
        );
      },
    );
  }



  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  Future<bool> holdProperty({
    required String authenticatedUserId,
    required String propertyId,
    UserRole? userRole,
  }) async {
    return updatePropertyStatus(
      authenticatedUserId: authenticatedUserId,
      propertyId: propertyId,
      targetStatus: ListingStatus.paused,
      userRole: userRole,
    );
  }

  Future<bool> resumeProperty({
    required String authenticatedUserId,
    required String propertyId,
    UserRole? userRole,
  }) async {
    return updatePropertyStatus(
      authenticatedUserId: authenticatedUserId,
      propertyId: propertyId,
      targetStatus: ListingStatus.published,
      userRole: userRole,
    );
  }

  Future<bool> deleteProperty({
    required String authenticatedUserId,
    required String propertyId,
    UserRole? userRole,
  }) async {
    try {
      final existing = state.allProperties.firstWhere(
        (p) => p.id == propertyId,
        orElse: () => throw const AccessDeniedException('Property not found.'),
      );

      PropertySecurityGuard.verifyPropertyOwnership(
        authenticatedUserId: authenticatedUserId,
        ownerId: existing.ownerId,
        userRole: userRole,
        actionName: 'delete this property',
      );

      final result = await _repository.deleteProperty(
        propertyId,
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
      );

      return await result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
          return false;
        },
        (_) async {
          await fetchMyProperties(authenticatedUserId);
          return true;
        },
      );
    } catch (e) {
      if (e is AccessDeniedException) rethrow;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateListingStatus({
    required String authenticatedUserId,
    required String propertyId,
    required ListingStatus targetStatus,
    UserRole? userRole,
  }) async {
    return updatePropertyStatus(
      authenticatedUserId: authenticatedUserId,
      propertyId: propertyId,
      targetStatus: targetStatus,
      userRole: userRole,
    );
  }

  Future<bool> updatePropertyStatus({
    required String authenticatedUserId,
    required String propertyId,
    required ListingStatus targetStatus,
    UserRole? userRole,
  }) async {
    try {
      final existing = state.allProperties.firstWhere(
        (p) => p.id == propertyId,
        orElse: () => throw Exception('Property not found.'),
      );

      // Ownership Security Check
      PropertySecurityGuard.verifyPropertyOwnership(
        authenticatedUserId: authenticatedUserId,
        ownerId: existing.ownerId,
        userRole: userRole,
      );

      // State machine validation
      if (userRole == null || !userRole.isAdminOrFounder) {
        if (!PropertyStatusWorkflow.canTransition(
          currentStatus: existing.status,
          targetStatus: targetStatus,
        )) {
          state = state.copyWith(
            errorMessage: 'Invalid status transition from ${existing.status.name} to ${targetStatus.name}.',
          );
          return false;
        }
      }

      final result = await _repository.updatePropertyStatus(
        propertyId: propertyId,
        newStatus: targetStatus,
        authenticatedUserId: authenticatedUserId,
        userRole: userRole,
      );

      return await result.fold(
        (failure) async {
          state = state.copyWith(errorMessage: failure.message);
          return false;
        },
        (saved) async {
          await fetchMyProperties(authenticatedUserId);
          return true;
        },
      );
    } catch (e) {
      if (e is AccessDeniedException) rethrow;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteDraft({
    required String authenticatedUserId,
    required String propertyId,
    UserRole? userRole,
  }) async {
    return deleteProperty(
      authenticatedUserId: authenticatedUserId,
      propertyId: propertyId,
      userRole: userRole,
    );
  }

  Future<bool> duplicateProperty({
    required String authenticatedUserId,
    required String propertyId,
  }) async {
    try {
      final existing = state.allProperties.firstWhere(
        (p) => p.id == propertyId,
        orElse: () => throw Exception('Property not found.'),
      );

      PropertySecurityGuard.verifyPropertyOwnership(
        authenticatedUserId: authenticatedUserId,
        ownerId: existing.ownerId,
      );

      final duplicated = PropertyEntity(
        id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
        ownerId: authenticatedUserId,
        title: '${existing.title} (Copy)',
        description: existing.description,
        category: existing.category,
        type: existing.type,
        status: ListingStatus.draft,
        verificationStatus: VerificationStatus.unverified,
        price: existing.price,
        isNegotiable: existing.isNegotiable,
        specifications: existing.specifications,
        mediaList: existing.mediaList,
        state: existing.state,
        district: existing.district,
        taluk: existing.taluk,
        city: existing.city,
        locality: existing.locality,
        address: existing.address,
        pincode: existing.pincode,
        latitude: existing.latitude,
        longitude: existing.longitude,
        viewsCount: 0,
        features: Map<String, dynamic>.from(existing.features),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _repository.createProperty(duplicated, authenticatedUserId: authenticatedUserId);
      return await result.fold(
        (failure) async {
          state = state.copyWith(errorMessage: failure.message);
          return false;
        },
        (saved) async {
          await fetchMyProperties(authenticatedUserId);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> archiveProperty({
    required String authenticatedUserId,
    required String propertyId,
  }) async {
    return updatePropertyStatus(
      authenticatedUserId: authenticatedUserId,
      propertyId: propertyId,
      targetStatus: ListingStatus.archived,
    );
  }
}

