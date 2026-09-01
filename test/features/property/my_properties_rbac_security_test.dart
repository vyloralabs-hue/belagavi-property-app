import 'package:belagavi_property/core/error/failures.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/domain/repositories/property_repository.dart';
import 'package:belagavi_property/features/property/presentation/providers/my_properties_notifier.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:belagavi_property/features/transaction/domain/entities/transaction_entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class MockRbacPropertyRepository implements PropertyRepository {
  final Map<String, PropertyEntity> _db = {};

  @override
  Future<Either<Failure, PropertyEntity>> createProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
  }) async {
    if (authenticatedUserId.isEmpty || authenticatedUserId != property.ownerId) {
      return left(const ServerFailure('Access Denied: Owner ID mismatch.'));
    }
    _db[property.id] = property;
    return right(property);
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getPropertiesByOwner({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) async {
    final list = _db.values.where((p) => p.ownerId == ownerId).toList();
    return right(list);
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getAllPropertiesForAdmin({
    required String authenticatedUserId,
    UserRole? userRole,
    int limit = 100,
    int offset = 0,
  }) async {
    if (userRole == null || !userRole.isAdminOrFounder) {
      return left(const ServerFailure('Access Denied: Admin authorization required.'));
    }
    return right(_db.values.toList());
  }

  @override
  Future<Either<Failure, PropertyEntity>> updateProperty(
    PropertyEntity property, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    final existing = _db[property.id];
    if (existing == null) {
      return left(const ServerFailure('Property not found.'));
    }
    final isAllowed = (userRole != null && userRole.isAdminOrFounder) ||
        (existing.ownerId == authenticatedUserId);
    if (!isAllowed) {
      return left(const ServerFailure('Access Denied: You cannot modify another user\'s property.'));
    }
    // Strict business rule: owner_id remains immutable on edit
    final preserved = property.copyWith(ownerId: existing.ownerId);
    _db[property.id] = preserved;
    return right(preserved);
  }

  @override
  Future<Either<Failure, PropertyEntity>> updatePropertyStatus({
    required String propertyId,
    required ListingStatus newStatus,
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    final existing = _db[propertyId];
    if (existing == null) {
      return left(const ServerFailure('Property not found.'));
    }
    final isAllowed = (userRole != null && userRole.isAdminOrFounder) ||
        (existing.ownerId == authenticatedUserId);
    if (!isAllowed) {
      return left(const ServerFailure('Access Denied: You cannot change status of another user\'s property.'));
    }
    final updated = PropertyEntity(
      id: existing.id,
      ownerId: existing.ownerId,
      title: existing.title,
      description: existing.description,
      category: existing.category,
      type: existing.type,
      status: newStatus,
      verificationStatus: existing.verificationStatus,
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
      viewsCount: existing.viewsCount,
      features: existing.features,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _db[propertyId] = updated;
    return right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteProperty(
    String id, {
    required String authenticatedUserId,
    UserRole? userRole,
  }) async {
    final existing = _db[id];
    if (existing == null) {
      return left(const ServerFailure('Property not found.'));
    }
    final isAllowed = (userRole != null && userRole.isAdminOrFounder) ||
        (existing.ownerId == authenticatedUserId);
    if (!isAllowed) {
      return left(const ServerFailure('Access Denied: You cannot delete another user\'s property.'));
    }
    _db.remove(id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getProperties({
    PropertyCategory? category,
    PropertySubtype? type,
    String? city,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    return right(_db.values.where((p) => p.status == ListingStatus.published || p.status == ListingStatus.active).toList());
  }

  @override
  Future<Either<Failure, PropertyEntity?>> getPropertyById(
    String id, {
    String? requestingUserId,
    List<PropertyUnlockEntity>? userUnlocks,
  }) async {
    return right(_db[id]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockRbacPropertyRepository propertyRepository;
  late MyPropertiesNotifier myPropertiesNotifier;
  late TransactionRepositoryImpl transactionRepository;

  setUp(() {
    propertyRepository = MockRbacPropertyRepository();
    myPropertiesNotifier = MyPropertiesNotifier(propertyRepository);
    transactionRepository = TransactionRepositoryImpl();
  });

  PropertyEntity createSampleProperty({
    required String id,
    required String ownerId,
    required String title,
    double price = 7500000,
    ListingStatus status = ListingStatus.published,
  }) {
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: 'Luxury residential property in Belagavi',
      category: PropertyCategory.residential,
      type: PropertySubtype.apartment,
      status: status,
      verificationStatus: VerificationStatus.verified,
      price: price,
      isNegotiable: false,
      specifications: const PropertySpecificationsEntity(carpetArea: 1450),
      mediaList: const [],
      state: 'Karnataka',
      district: 'Belagavi',
      taluk: 'Belagavi',
      city: 'Belagavi',
      locality: 'Tilakwadi',
      address: 'Congress Road, Tilakwadi',
      pincode: '590006',
      latitude: 15.8497,
      longitude: 74.4977,
      viewsCount: 120,
      features: const {'lift': true, 'security': true, 'purpose': 'FOR_SALE'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('MASTER VERIFICATION: 10-Point Security, RBAC & Inquiries Test Matrix', () {
    const sellerAId = 'usr_seller_A_101';
    const sellerBId = 'usr_seller_B_202';
    const adminId = 'usr_admin_global_777';

    // ── TEST 1: Seller A creates Property A -> VIEW, EDIT, HOLD, RESUME, DELETE ──
    test('TEST 1: Seller A creates Property A and has full VIEW, EDIT, HOLD, RESUME, DELETE permissions', () async {
      final propA = createSampleProperty(id: 'prop_A_001', ownerId: sellerAId, title: '2BHK Tilakwadi Flat');
      final createRes = await propertyRepository.createProperty(propA, authenticatedUserId: sellerAId);
      expect(createRes.isRight(), isTrue);

      // VIEW: Appears in My Properties
      await myPropertiesNotifier.fetchMyProperties(sellerAId);
      expect(myPropertiesNotifier.state.allProperties.length, 1);
      expect(myPropertiesNotifier.state.allProperties.first.id, 'prop_A_001');

      // EDIT: Seller A updates title and price
      final updatedPropA = propA.copyWith(title: '2BHK Tilakwadi Flat (Renovated)', price: 7800000);
      final editRes = await propertyRepository.updateProperty(updatedPropA, authenticatedUserId: sellerAId);
      expect(editRes.isRight(), isTrue);
      expect(editRes.getOrElse((_) => throw Exception()).title, '2BHK Tilakwadi Flat (Renovated)');

      // HOLD: Placed on Hold / Paused
      final holdRes = await myPropertiesNotifier.holdProperty(authenticatedUserId: sellerAId, propertyId: 'prop_A_001');
      expect(holdRes, isTrue);
      expect(myPropertiesNotifier.state.allProperties.first.status, ListingStatus.paused);

      // RESUME: Resumed to Published
      final resumeRes = await myPropertiesNotifier.resumeProperty(authenticatedUserId: sellerAId, propertyId: 'prop_A_001');
      expect(resumeRes, isTrue);
      expect(myPropertiesNotifier.state.allProperties.first.status, ListingStatus.published);

      // DELETE: Seller A deletes own property
      final deleteRes = await myPropertiesNotifier.deleteProperty(authenticatedUserId: sellerAId, propertyId: 'prop_A_001');
      expect(deleteRes, isTrue);
      expect(myPropertiesNotifier.state.allProperties.isEmpty, isTrue);
    });

    // ── TEST 2: Seller A attempts to edit Property B owned by Seller B -> DENIED ──
    test('TEST 2: Seller A attempting to edit Property B owned by Seller B is DENIED', () async {
      final propB = createSampleProperty(id: 'prop_B_002', ownerId: sellerBId, title: 'Seller B Villa');
      await propertyRepository.createProperty(propB, authenticatedUserId: sellerBId);

      // Repository layer rejects cross-user edit
      final editAttempt = await propertyRepository.updateProperty(
        propB.copyWith(title: 'Hacked Title'),
        authenticatedUserId: sellerAId,
      );
      expect(editAttempt.isLeft(), isTrue);

      // Security guard rejects
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: sellerAId,
          ownerId: sellerBId,
          userRole: UserRole.sellerOwner,
          actionName: 'edit this property',
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    // ── TEST 3: Seller A attempts to change Property B owner_id -> DENIED ──
    test('TEST 3: Seller A attempting to hijack Property B owner_id is DENIED', () async {
      final propB = createSampleProperty(id: 'prop_B_002', ownerId: sellerBId, title: 'Seller B Villa');
      await propertyRepository.createProperty(propB, authenticatedUserId: sellerBId);

      final hijackAttempt = await propertyRepository.updateProperty(
        propB.copyWith(ownerId: sellerAId),
        authenticatedUserId: sellerAId,
      );
      expect(hijackAttempt.isLeft(), isTrue);
    });

    // ── TEST 4: Seller A edits Property A -> owner_id remains unchanged ──
    test('TEST 4: Seller A edits Property A -> owner_id remains strictly unchanged', () async {
      final propA = createSampleProperty(id: 'prop_A_001', ownerId: sellerAId, title: 'Original Flat');
      await propertyRepository.createProperty(propA, authenticatedUserId: sellerAId);

      // Even if client passes malicious owner_id, repository preserves original owner_id
      final editRes = await propertyRepository.updateProperty(
        propA.copyWith(title: 'Updated Flat', ownerId: 'usr_malicious_attacker'),
        authenticatedUserId: sellerAId,
      );
      expect(editRes.isRight(), isTrue);
      expect(editRes.getOrElse((_) => throw Exception()).ownerId, sellerAId);
    });

    // ── TEST 5: Admin/Founder edits Property A owned by Seller A -> ALLOWED ──
    test('TEST 5: Admin/Founder edits Property A owned by Seller A is ALLOWED', () async {
      final propA = createSampleProperty(id: 'prop_A_001', ownerId: sellerAId, title: 'Seller A Flat');
      await propertyRepository.createProperty(propA, authenticatedUserId: sellerAId);

      final adminEditRes = await propertyRepository.updateProperty(
        propA.copyWith(title: 'Admin Verified Flat'),
        authenticatedUserId: adminId,
        userRole: UserRole.admin,
      );
      expect(adminEditRes.isRight(), isTrue);
      expect(adminEditRes.getOrElse((_) => throw Exception()).title, 'Admin Verified Flat');
    });

    // ── TEST 6: Admin/Founder edits Property B owned by Seller B -> ALLOWED ──
    test('TEST 6: Admin/Founder edits Property B owned by Seller B is ALLOWED', () async {
      final propB = createSampleProperty(id: 'prop_B_002', ownerId: sellerBId, title: 'Seller B Villa');
      await propertyRepository.createProperty(propB, authenticatedUserId: sellerBId);

      final founderEditRes = await propertyRepository.updateProperty(
        propB.copyWith(title: 'Founder Verified Villa'),
        authenticatedUserId: adminId,
        userRole: UserRole.founder,
      );
      expect(founderEditRes.isRight(), isTrue);
      expect(founderEditRes.getOrElse((_) => throw Exception()).title, 'Founder Verified Villa');
    });

    // ── TEST 7: Customer creates inquiry -> Connected to correct authenticated user ──
    test('TEST 7: Customer creates inquiry and connects to correct authenticated user ID', () async {
      const buyerId = 'usr_buyer_real_333';
      final enquiry = PropertyEnquiryEntity(
        id: 'enq_real_001',
        propertyId: 'prop_A_001',
        propertyTitle: '2BHK Tilakwadi Flat',
        propertyCategory: 'residential',
        propertyLocation: 'Tilakwadi, Belagavi',
        buyerId: buyerId,
        buyerName: 'Sneha Joshi',
        buyerPhone: '+91 98450 99887',
        buyerEmail: 'sneha.joshi@example.com',
        sellerId: sellerAId,
        interestType: TransactionInterestType.buy,
        initialMessage: 'I am interested in this flat.',
        preferredContactMethod: 'Phone Call',
        financingStatus: 'Self-Funded',
        listedPrice: 7500000,
        status: TransactionStatus.newEnquiry,
        siteVisitStatus: SiteVisitStatus.none,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await transactionRepository.submitEnquiry(enquiry);
      final buyerEnquiries = await transactionRepository.getBuyerEnquiries(buyerId);
      expect(buyerEnquiries.length, 1);
      expect(buyerEnquiries.first.id, 'enq_real_001');
      expect(buyerEnquiries.first.buyerId, buyerId);
    });

    // ── TEST 8: Customer creates Site Visit request -> Property owner receives request ──
    test('TEST 8: Customer creates Site Visit request and property owner receives it', () async {
      const buyerId = 'usr_buyer_real_333';
      final visitEnquiry = PropertyEnquiryEntity(
        id: 'enq_visit_002',
        propertyId: 'prop_A_001',
        propertyTitle: '2BHK Tilakwadi Flat',
        propertyCategory: 'residential',
        propertyLocation: 'Tilakwadi, Belagavi',
        buyerId: buyerId,
        buyerName: 'Sneha Joshi',
        buyerPhone: '+91 98450 99887',
        sellerId: sellerAId,
        interestType: TransactionInterestType.buy,
        initialMessage: 'Requesting physical site inspection.',
        preferredVisitDate: '2026-08-25',
        preferredVisitTime: 'Morning (10 AM - 1 PM)',
        listedPrice: 7500000,
        status: TransactionStatus.siteVisit,
        siteVisitStatus: SiteVisitStatus.requested,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await transactionRepository.submitEnquiry(visitEnquiry);
      final sellerLeads = await transactionRepository.getSellerEnquiries(sellerAId);
      expect(sellerLeads.any((e) => e.id == 'enq_visit_002'), isTrue);
      final targetLead = sellerLeads.firstWhere((e) => e.id == 'enq_visit_002');
      expect(targetLead.siteVisitStatus, SiteVisitStatus.requested);
      expect(targetLead.preferredVisitDate, '2026-08-25');
    });

    // ── TEST 9: Seller A cannot access inquiries for Seller B's properties ──
    test('TEST 9: Seller A cannot access inquiries for Seller B\'s properties', () async {
      final enqForB = PropertyEnquiryEntity(
        id: 'enq_B_003',
        propertyId: 'prop_B_002',
        propertyTitle: 'Seller B Villa',
        propertyCategory: 'residential',
        propertyLocation: 'Belagavi',
        buyerId: 'usr_buyer_real_333',
        buyerName: 'Buyer X',
        buyerPhone: '+91 98450 00000',
        sellerId: sellerBId,
        interestType: TransactionInterestType.buy,
        initialMessage: 'Enquiry for Seller B villa.',
        listedPrice: 8500000,
        status: TransactionStatus.newEnquiry,
        siteVisitStatus: SiteVisitStatus.none,
        docVerificationStatus: DocVerificationStatus.notStarted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await transactionRepository.submitEnquiry(enqForB);

      // Seller A inquiries must NOT contain Seller B lead
      final sellerALeads = await transactionRepository.getSellerEnquiries(sellerAId);
      expect(sellerALeads.any((e) => e.id == 'enq_B_003'), isFalse);

      // Seller B inquiries MUST contain Seller B lead
      final sellerBLeads = await transactionRepository.getSellerEnquiries(sellerBId);
      expect(sellerBLeads.any((e) => e.id == 'enq_B_003'), isTrue);
    });

    // ── TEST 10: Admin/Founder can manage all property inquiries ──
    test('TEST 10: Admin/Founder can manage all property inquiries globally', () async {
      // Admin updates site visit status on any lead
      await transactionRepository.updateSiteVisit(
        enquiryId: 'enq_101',
        status: SiteVisitStatus.completed,
        notes: 'Founder verified on-site inspection.',
      );

      final updated = await transactionRepository.getEnquiryById('enq_101');
      expect(updated?.siteVisitStatus, SiteVisitStatus.completed);
      expect(updated?.siteVisitNotes, 'Founder verified on-site inspection.');
    });
  });
}
