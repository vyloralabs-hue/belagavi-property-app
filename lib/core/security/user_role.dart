import '../errors/security_exceptions.dart';

enum UserRole {
  founder,
  admin,
  moderator,
  builder,
  landDeveloper,
  sellerOwner,
  agent,
  user,
  guest;

  bool get isFounder => this == UserRole.founder;
  bool get isAdminOrFounder => this == UserRole.founder || this == UserRole.admin;
  bool get isModerator => this == UserRole.founder || this == UserRole.admin || this == UserRole.moderator;
  bool get isBuilder => this == UserRole.builder;
  bool get isLandDeveloper => this == UserRole.landDeveloper;
  bool get isDeveloper => this == UserRole.builder || this == UserRole.landDeveloper;
  bool get isOwner => this == UserRole.sellerOwner || this == UserRole.builder || this == UserRole.landDeveloper;
}

extension UserRoleExtension on UserRole {
  static UserRole fromString(String? val) {
    if (val == null) return UserRole.user;
    final clean = val.trim().toLowerCase();
    return switch (clean) {
      'founder' => UserRole.founder,
      'admin' => UserRole.admin,
      'moderator' => UserRole.moderator,
      'builder' => UserRole.builder,
      'landdeveloper' || 'land_developer' || 'land developer' => UserRole.landDeveloper,
      'sellerowner' || 'seller_owner' || 'seller' || 'owner' || 'property owner' => UserRole.sellerOwner,
      'agent' => UserRole.agent,
      'guest' => UserRole.guest,
      _ => UserRole.user,
    };
  }
}

class PlatformAuthorizationGuard {
  PlatformAuthorizationGuard._();

  /// Verifies that the user possesses Founder authority
  static void verifyFounderAuthority({
    required String? authenticatedUserId,
    required UserRole userRole,
    String actionName = 'perform founder operation',
  }) {
    if (authenticatedUserId == null || authenticatedUserId.isEmpty) {
      throw AccessDeniedException('Unauthenticated: Access denied for $actionName.');
    }

    if (!userRole.isFounder) {
      throw AccessDeniedException(
        'Access Denied: Only platform Founder accounts can $actionName. Current role: ${userRole.name}.',
      );
    }
  }

  /// Verifies administrative or moderation capabilities
  static void verifyModerationPermission({
    required String? authenticatedUserId,
    required UserRole userRole,
    String actionName = 'perform platform moderation',
  }) {
    if (authenticatedUserId == null || authenticatedUserId.isEmpty) {
      throw AccessDeniedException('Unauthenticated: Access denied for $actionName.');
    }

    if (!userRole.isModerator) {
      throw AccessDeniedException(
        'Access Denied: Requires Founder, Admin, or Moderator authorization to $actionName.',
      );
    }
  }

  /// Verifies advertisement management permissions
  static void verifyAdManagementPermission({
    required String? authenticatedUserId,
    required UserRole userRole,
    String actionName = 'manage platform advertisements',
  }) {
    if (authenticatedUserId == null || authenticatedUserId.isEmpty) {
      throw AccessDeniedException('Unauthenticated: Access denied for $actionName.');
    }

    if (!userRole.isAdminOrFounder) {
      throw AccessDeniedException(
        'Access Denied: Requires Founder or Admin authorization to $actionName.',
      );
    }
  }
}
