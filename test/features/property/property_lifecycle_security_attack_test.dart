import 'package:flutter_test/flutter_test.dart';
import 'package:belagavi_property/core/errors/security_exceptions.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/utils/property_security_guard.dart';
import 'package:belagavi_property/features/property/utils/property_status_workflow.dart';

void main() {
  PropertyEntity createTestProperty({
    required String id,
    required String ownerId,
    required String title,
    ListingStatus status = ListingStatus.published,
    double price = 5000000,
  }) {
    return PropertyEntity(
      id: id,
      ownerId: ownerId,
      title: title,
      description: 'Test Description',
      category: PropertyCategory.residential,
      type: PropertySubtype.apartment,
      status: status,
      verificationStatus: VerificationStatus.verified,
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
      latitude: 15.8497,
      longitude: 74.4977,
      viewsCount: 10,
      features: const {'purpose': 'FOR_SALE'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('PROPERTY LIFECYCLE & MODERATION SECURITY ATTACK TEST MATRIX (PHASE 24)', () {
    const customerA = 'usr_customer_A_101';
    const customerB = 'usr_customer_B_202';
    const sellerA = 'usr_seller_A_303';
    const sellerB = 'usr_seller_B_404';

    test('1. Customer changes own status to SOLD directly -> DENIED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.published,
          targetStatus: ListingStatus.sold,
          userRole: UserRole.user,
        ),
        isFalse,
      );
    });

    test('2. Customer changes own status to APPROVED directly -> DENIED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.submitted,
          targetStatus: ListingStatus.approved,
          userRole: UserRole.sellerOwner,
        ),
        isFalse,
      );
    });

    test('3. Customer changes own status to PUBLISHED bypassing moderation -> DENIED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.draft,
          targetStatus: ListingStatus.published,
          userRole: UserRole.user,
        ),
        isFalse,
      );
    });

    test('4. Customer changes owner_id on edit -> DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyUpdate(
          existingOwnerId: customerA,
          updatedOwnerId: customerB,
          currentUserId: customerA,
          userRole: UserRole.user,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('5. Customer modifies another property -> DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: customerA,
          ownerId: sellerB,
          userRole: UserRole.user,
          actionName: 'edit property',
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('6. Customer deletes another property -> DENIED', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyOwnership(
          authenticatedUserId: customerA,
          ownerId: sellerB,
          userRole: UserRole.user,
          actionName: 'delete property',
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });

    test('7. Seller accesses admin moderation -> DENIED', () {
      expect(UserRole.sellerOwner.isAdminOrFounder, isFalse);
      expect(UserRole.user.isAdminOrFounder, isFalse);
      expect(UserRole.builder.isAdminOrFounder, isFalse);
    });

    test('8. Seller approves another listing -> DENIED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.submitted,
          targetStatus: ListingStatus.approved,
          userRole: UserRole.sellerOwner,
        ),
        isFalse,
      );
    });

    test('9. Seller rejects another listing -> DENIED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.submitted,
          targetStatus: ListingStatus.rejected,
          userRole: UserRole.sellerOwner,
        ),
        isFalse,
      );
    });

    test('10. Customer accesses unpublished property of another seller -> DENIED', () {
      final draftProperty = createTestProperty(
        id: 'prop_draft_private',
        ownerId: sellerB,
        title: 'Secret Draft',
        status: ListingStatus.draft,
      );

      final canCustomerAView = PropertySecurityGuard.canViewProperty(
        status: draftProperty.status,
        ownerId: draftProperty.ownerId,
        requestingUserId: customerA,
        userRole: UserRole.user,
      );
      expect(canCustomerAView, isFalse);

      final canOwnerView = PropertySecurityGuard.canViewProperty(
        status: draftProperty.status,
        ownerId: draftProperty.ownerId,
        requestingUserId: sellerB,
        userRole: UserRole.sellerOwner,
      );
      expect(canOwnerView, isTrue);
    });

    test('11. Rejected listing is NOT publicly visible', () {
      final canPublicView = PropertySecurityGuard.canViewProperty(
        status: ListingStatus.rejected,
        ownerId: sellerA,
        requestingUserId: null,
      );
      expect(canPublicView, isFalse);
    });

    test('12. On-hold listing is NOT publicly visible to general public', () {
      final canPublicView = PropertySecurityGuard.canViewProperty(
        status: ListingStatus.paused,
        ownerId: sellerA,
        requestingUserId: null,
      );
      expect(canPublicView, isFalse);
    });

    test('13. Sold listing is NOT publicly active for new public creation', () {
      final canPublicView = PropertySecurityGuard.canViewProperty(
        status: ListingStatus.sold,
        ownerId: sellerA,
        requestingUserId: null,
      );
      expect(canPublicView, isFalse);
    });

    test('14. Admin performs legitimate moderation (approve, reject, changes requested) -> ALLOWED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.submitted,
          targetStatus: ListingStatus.approved,
          userRole: UserRole.admin,
        ),
        isTrue,
      );
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.submitted,
          targetStatus: ListingStatus.changesRequested,
          userRole: UserRole.admin,
        ),
        isTrue,
      );
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.submitted,
          targetStatus: ListingStatus.rejected,
          userRole: UserRole.admin,
        ),
        isTrue,
      );
    });

    test('15. Owner edits own permitted listing (Draft -> Submitted or Published -> Paused) -> ALLOWED', () {
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.draft,
          targetStatus: ListingStatus.submitted,
          userRole: UserRole.sellerOwner,
        ),
        isTrue,
      );
      expect(
        PropertyStatusWorkflow.canTransitionWithRole(
          currentStatus: ListingStatus.published,
          targetStatus: ListingStatus.paused,
          userRole: UserRole.sellerOwner,
        ),
        isTrue,
      );
    });

    test('16. Owner edits owner_id during update -> DENIED (Immutability Enforced)', () {
      expect(
        () => PropertySecurityGuard.verifyPropertyUpdate(
          existingOwnerId: sellerA,
          updatedOwnerId: 'forged_new_owner_id',
          currentUserId: sellerA,
          userRole: UserRole.sellerOwner,
        ),
        throwsA(isA<AccessDeniedException>()),
      );
    });
  });
}
