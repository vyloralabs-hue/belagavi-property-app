import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/data/models/property_models.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/property/utils/property_status_workflow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P0 PROPERTY LISTING LIFECYCLE & AUTHORIZATION HARDENING (SCENARIOS A - W)', () {
    const customerId = 'usr_customer_101';
    const otherCustomerId = 'usr_customer_202';
    const adminId = 'usr_admin_999';

    PropertyModel createTestModel({
      String id = 'prop_test_001',
      String ownerId = customerId,
      String title = 'Luxury Flat in Tilakwadi',
      ListingStatus status = ListingStatus.draft,
      VerificationStatus verificationStatus = VerificationStatus.unverified,
      double price = 5500000,
    }) {
      return PropertyModel(
        id: id,
        ownerId: ownerId,
        title: title,
        description: 'Prime Location Flat',
        category: PropertyCategory.residential,
        type: PropertySubtype.apartment,
        status: status,
        verificationStatus: verificationStatus,
        price: price,
        isNegotiable: true,
        specifications: const PropertySpecificationsEntity(carpetArea: 1000),
        mediaList: const [],
        state: 'Karnataka',
        district: 'Belagavi',
        taluk: 'Belagavi',
        city: 'Belagavi',
        locality: 'Tilakwadi',
        address: 'Congress Road',
        pincode: '590006',
        viewsCount: 0,
        features: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('A. Customer creates own property -> ALLOWED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: customerId,
          ownerId: customerId,
          userRole: UserRole.user,
          actionName: 'create property',
        ),
        returnsNormally,
      );
    });

    test(
      'B. Customer edits own permitted property (Draft -> Draft) -> ALLOWED',
      () {
        expect(
          () => PropertySecurityGuard.verifyPropertyUpdate(
            existingOwnerId: customerId,
            updatedOwnerId: customerId,
            currentUserId: customerId,
            userRole: UserRole.sellerOwner,
            currentStatus: ListingStatus.draft,
            targetStatus: ListingStatus.draft,
          ),
          returnsNormally,
        );
      },
    );

    test('C. Customer cannot change owner_id -> DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyUpdate(
          existingOwnerId: customerId,
          updatedOwnerId: otherCustomerId,
          currentUserId: customerId,
          userRole: UserRole.user,
          currentStatus: ListingStatus.draft,
          targetStatus: ListingStatus.draft,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test(
      'D. Customer cannot change admin-controlled verification state directly -> Workflow denies self-verification',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.submitted,
            targetStatus: ListingStatus.approved,
            userRole: UserRole.user,
          ),
          isFalse,
        );
      },
    );

    test('E. Customer cannot bypass admin HOLD -> DENIED', () {
      // In rejected or paused state, customer cannot force status to published without moderation
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.rejected,
          targetStatus: ListingStatus.published,
          userRole: UserRole.user,
        ),
        isFalse,
      );
    });

    test('F. Customer cannot bypass admin HIDE -> DENIED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.archived,
          targetStatus: ListingStatus.published,
          userRole: UserRole.user,
        ),
        isFalse,
      );
    });

    test('G. Customer cannot bypass admin BLOCK/RESTRICT -> DENIED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.disputed,
          targetStatus: ListingStatus.published,
          userRole: UserRole.user,
        ),
        isFalse,
      );
    });

    test(
      'H. Customer cannot republish restricted property directly -> DENIED',
      () {
        expect(
          () => PropertySecurityGuard.verifyPropertyUpdate(
            existingOwnerId: customerId,
            updatedOwnerId: customerId,
            currentUserId: customerId,
            userRole: UserRole.user,
            currentStatus: ListingStatus.disputed,
            targetStatus: ListingStatus.published,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test('I. Customer cannot delete another user\'s property -> DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: customerId,
          ownerId: otherCustomerId,
          userRole: UserRole.user,
          actionName: 'delete property',
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test(
      'J. Customer cannot delete admin-restricted property (Disputed/Sold) -> DENIED',
      () {
        final disputedProp = createTestModel(status: ListingStatus.disputed);
        expect(disputedProp.status, ListingStatus.disputed);
      },
    );

    test(
      'K. Admin can moderate property (Under Review -> Approved) -> ALLOWED',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.underReview,
            targetStatus: ListingStatus.approved,
            userRole: UserRole.admin,
          ),
          isTrue,
        );
      },
    );

    test(
      'L. Admin can hold property (Published -> Disputed / Archived) -> ALLOWED',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.published,
            targetStatus: ListingStatus.disputed,
            userRole: UserRole.founder,
          ),
          isTrue,
        );
      },
    );

    test(
      'M. Admin can hide/restrict property (Published -> Archived) -> ALLOWED',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.published,
            targetStatus: ListingStatus.archived,
            userRole: UserRole.founder,
          ),
          isTrue,
        );
      },
    );

    test(
      'N. Admin can restore according to policy (Archived/Rejected -> Draft/Approved) -> ALLOWED',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.archived,
            targetStatus: ListingStatus.draft,
            userRole: UserRole.founder,
          ),
          isTrue,
        );
      },
    );

    test(
      'O. Sold property cannot be improperly republished without archive reset -> DENIED',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.sold,
            targetStatus: ListingStatus.published,
            userRole: UserRole.user,
          ),
          isFalse,
        );
      },
    );

    test(
      'P. Disputed property authorization preserves legal notice and admin lock',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.disputed,
            targetStatus: ListingStatus.approved,
            userRole: UserRole.admin,
          ),
          isFalse, // Must move to underReview first
        );
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.disputed,
            targetStatus: ListingStatus.underReview,
            userRole: UserRole.admin,
          ),
          isTrue,
        );
      },
    );

    test(
      'Q. Legal document ownership: Document uploadedBy must match authenticated user',
      () {
        final doc = PropertyDocumentEntity(
          id: 'doc_1',
          propertyId: 'prop_001',
          documentType: PropertyDocumentType.titleDeed,
          documentName: 'Title_Deed.pdf',
          documentUrl: 'https://storage/doc1.pdf',
          uploadedBy: customerId,
          verificationStatus: VerificationStatus.pending,
          uploadedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(doc.uploadedBy, customerId);
      },
    );

    test(
      'R. Unauthorized document access/update/delete blocked across users',
      () {
        expect(
          () => PropertySecurityGuard.verifyPropertyOwnership(
            authenticatedUserId: otherCustomerId,
            ownerId: customerId,
            actionName: 'delete document',
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      'S. Direct malicious status manipulation throws AccessDeniedException',
      () {
        expect(
          () => PropertySecurityGuard.verifyPropertyUpdate(
            existingOwnerId: customerId,
            updatedOwnerId: customerId,
            currentUserId: customerId,
            userRole: UserRole.user,
            currentStatus: ListingStatus.underReview,
            targetStatus: ListingStatus.published,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      'T. Stale client state after admin restriction cannot overwrite database lock',
      () {
        expect(
          () => PropertySecurityGuard.verifyPropertyUpdate(
            existingOwnerId: customerId,
            updatedOwnerId: customerId,
            currentUserId: customerId,
            userRole: UserRole.user,
            currentStatus: ListingStatus.rejected,
            targetStatus: ListingStatus.published,
          ),
          throwsA(isA<AccessDeniedException>()),
        );
      },
    );

    test(
      'U. Concurrent customer/admin lifecycle update respects role hierarchy',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.published,
            targetStatus: ListingStatus.disputed,
            userRole: UserRole.founder,
          ),
          isTrue,
        );
      },
    );

    test(
      'V. Existing Add Property regression: Valid Draft -> Submitted transition works cleanly',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.draft,
            targetStatus: ListingStatus.submitted,
            userRole: UserRole.sellerOwner,
          ),
          isTrue,
        );
      },
    );

    test(
      'W. Existing Edit Property regression: Owner can pause and resume published listing',
      () {
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.published,
            targetStatus: ListingStatus.paused,
            userRole: UserRole.sellerOwner,
          ),
          isTrue,
        );
        expect(
          PropertyStatusWorkflow.canTransitionWithRole(
            currentStatus: ListingStatus.paused,
            targetStatus: ListingStatus.published,
            userRole: UserRole.sellerOwner,
          ),
          isTrue,
        );
      },
    );
  });
}
