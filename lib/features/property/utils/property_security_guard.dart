import '../../../core/errors/security_exceptions.dart';
import '../../../core/security/user_role.dart';
import '../domain/entities/property_entities.dart';
import 'owner_identity_bridge.dart';
import 'property_status_workflow.dart';

class PropertySecurityGuard {
  PropertySecurityGuard._();

  /// Verifies that the authenticated user owns the target property or possesses Admin/Founder role.
  /// Uses OwnerIdentityBridge to safely resolve Firebase UID vs Profile UUID without raw text inequality failures.
  static void verifyPropertyOwnership({
    required String? authenticatedUserId,
    required String ownerId,
    UserRole? userRole,
    String actionName = 'modify this property',
  }) {
    if (authenticatedUserId == null || authenticatedUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required. Please sign in.');
    }
    // Admin / Founder Global Management Authority
    if (userRole != null && userRole.isAdminOrFounder) {
      return;
    }

    final isMatch = OwnerIdentityBridge.isOwnerSync(
      callerId: authenticatedUserId,
      propertyOwnerId: ownerId,
    );

    if (!isMatch) {
      throw AccessDeniedException(
        'Access Denied: You do not have permission to $actionName.',
      );
    }
  }

  /// Async version that resolves via Supabase profiles if not yet cached in memory
  static Future<void> verifyPropertyOwnershipAsync({
    required String? authenticatedUserId,
    required String ownerId,
    UserRole? userRole,
    String actionName = 'modify this property',
  }) async {
    if (authenticatedUserId == null || authenticatedUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required. Please sign in.');
    }
    if (userRole != null && userRole.isAdminOrFounder) {
      return;
    }

    final isMatch = await OwnerIdentityBridge.isOwner(
      callerId: authenticatedUserId,
      propertyOwnerId: ownerId,
    );

    if (!isMatch) {
      throw AccessDeniedException(
        'Access Denied: You do not have permission to $actionName.',
      );
    }
  }

  /// Verifies that the authenticated user owns the target builder project.
  static void verifyProjectOwnership({
    required String? authenticatedUserId,
    required String builderId,
    String actionName = 'modify this builder project',
  }) {
    if (authenticatedUserId == null || authenticatedUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required. Please sign in.');
    }
    if (authenticatedUserId != builderId) {
      throw AccessDeniedException(
        'Access Denied: You do not have permission to $actionName.',
      );
    }
  }

  /// Verifies broker authorization for co-listings or managed properties.
  static void verifyBrokerOwnership({
    required String? authenticatedUserId,
    required String brokerOrOwnerId,
    String actionName = 'access or manage this broker listing',
  }) {
    if (authenticatedUserId == null || authenticatedUserId.trim().isEmpty) {
      throw const AccessDeniedException('Authentication required. Please sign in.');
    }
    if (authenticatedUserId != brokerOrOwnerId) {
      throw AccessDeniedException(
        'Access Denied: You do not have permission to $actionName.',
      );
    }
  }

  /// Verifies that property update operations respect owner_id immutability and valid workflow status transitions.
  static void verifyPropertyUpdate({
    required String existingOwnerId,
    required String updatedOwnerId,
    required String? currentUserId,
    UserRole? userRole,
    ListingStatus? currentStatus,
    ListingStatus? targetStatus,
  }) {
    // 1. Owner ID Immutability
    if (existingOwnerId != updatedOwnerId) {
      throw const AccessDeniedException('Access Denied: Property owner_id cannot be changed.');
    }

    // 2. Ownership verification
    verifyPropertyOwnership(
      authenticatedUserId: currentUserId,
      ownerId: existingOwnerId,
      userRole: userRole,
      actionName: 'update this property',
    );

    // 3. Workflow State Transition & Admin Lock Enforcement
    if (currentStatus != null && targetStatus != null && currentStatus != targetStatus) {
      final role = userRole ?? UserRole.user;
      if (!PropertyStatusWorkflow.canTransitionWithRole(
        currentStatus: currentStatus,
        targetStatus: targetStatus,
        userRole: role,
      )) {
        throw AccessDeniedException(
          'Access Denied: Invalid lifecycle status transition from ${currentStatus.name} to ${targetStatus.name} for role ${role.name}.',
        );
      }
    }
  }

  /// Async version of verifyPropertyUpdate ensuring full DB identity resolution
  static Future<void> verifyPropertyUpdateAsync({
    required String existingOwnerId,
    required String updatedOwnerId,
    required String? currentUserId,
    UserRole? userRole,
    ListingStatus? currentStatus,
    ListingStatus? targetStatus,
  }) async {
    // 1. Owner ID Immutability
    if (existingOwnerId != updatedOwnerId) {
      throw const AccessDeniedException('Access Denied: Property owner_id cannot be changed.');
    }

    // 2. Async Ownership verification
    await verifyPropertyOwnershipAsync(
      authenticatedUserId: currentUserId,
      ownerId: existingOwnerId,
      userRole: userRole,
      actionName: 'update this property',
    );

    // 3. Workflow State Transition & Admin Lock Enforcement
    if (currentStatus != null && targetStatus != null && currentStatus != targetStatus) {
      final role = userRole ?? UserRole.user;
      if (!PropertyStatusWorkflow.canTransitionWithRole(
        currentStatus: currentStatus,
        targetStatus: targetStatus,
        userRole: role,
      )) {
        throw AccessDeniedException(
          'Access Denied: Invalid lifecycle status transition from ${currentStatus.name} to ${targetStatus.name} for role ${role.name}.',
        );
      }
    }
  }

  /// Verifies whether a non-public property listing can be viewed by the requester.
  static bool canViewProperty({
    required ListingStatus status,
    required String ownerId,
    String? requestingUserId,
    UserRole? userRole,
  }) {
    final isPublic = status == ListingStatus.published ||
        status == ListingStatus.active ||
        status == ListingStatus.approved;

    if (isPublic) return true;

    // Admin / Founder access
    if (userRole != null && userRole.isAdminOrFounder) return true;

    // Owner access (safe against Firebase UID vs Profile UUID)
    if (requestingUserId != null &&
        OwnerIdentityBridge.isOwnerSync(
          callerId: requestingUserId,
          propertyOwnerId: ownerId,
        )) {
      return true;
    }

    return false;
  }

  /// Async version of canViewProperty that checks database if not cached
  static Future<bool> canViewPropertyAsync({
    required ListingStatus status,
    required String ownerId,
    String? requestingUserId,
    UserRole? userRole,
  }) async {
    final isPublic = status == ListingStatus.published ||
        status == ListingStatus.active ||
        status == ListingStatus.approved;

    if (isPublic) return true;

    if (userRole != null && userRole.isAdminOrFounder) return true;

    if (requestingUserId != null) {
      final isOwner = await OwnerIdentityBridge.isOwner(
        callerId: requestingUserId,
        propertyOwnerId: ownerId,
      );
      if (isOwner) return true;
    }

    return false;
  }
}
