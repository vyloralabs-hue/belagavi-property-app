import '../domain/entities/user_profile_entity.dart';

class RolePermissionValidator {
  RolePermissionValidator._();

  /// Validates capability grants across 12 permission domains for all 8 user roles
  static bool hasPermission({
    required UserRoleEnum role,
    required String capability,
  }) {
    return switch (capability) {
      'view_active_properties' => true, // All roles can view active listings
      'post_listing' => role != UserRoleEnum.buyer &&
          role != UserRoleEnum.brokerTeamMember &&
          role != UserRoleEnum.builderTeamMember,
      'manage_builder_projects' => role == UserRoleEnum.builder ||
          role == UserRoleEnum.builderTeamMember ||
          role == UserRoleEnum.admin ||
          role == UserRoleEnum.superAdmin,
      'access_crm' => role == UserRoleEnum.broker ||
          role == UserRoleEnum.builder ||
          role == UserRoleEnum.brokerTeamMember ||
          role == UserRoleEnum.builderTeamMember ||
          role == UserRoleEnum.admin ||
          role == UserRoleEnum.superAdmin,
      'create_team' => role == UserRoleEnum.broker ||
          role == UserRoleEnum.builder ||
          role == UserRoleEnum.superAdmin,
      'assign_team_permissions' => role == UserRoleEnum.broker ||
          role == UserRoleEnum.builder ||
          role == UserRoleEnum.superAdmin,
      'use_ai_search' => true,
      'ai_lead_scoring' => role == UserRoleEnum.broker ||
          role == UserRoleEnum.builder ||
          role == UserRoleEnum.brokerTeamMember ||
          role == UserRoleEnum.builderTeamMember ||
          role == UserRoleEnum.admin ||
          role == UserRoleEnum.superAdmin,
      'verify_properties' => role == UserRoleEnum.admin || role == UserRoleEnum.superAdmin,
      'manage_users' => role == UserRoleEnum.superAdmin || role == UserRoleEnum.admin,
      'view_security_logs' => role == UserRoleEnum.superAdmin,
      _ => false,
    };
  }
}
