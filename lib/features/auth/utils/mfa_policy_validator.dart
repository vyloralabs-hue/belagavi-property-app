import '../domain/entities/user_profile_entity.dart';

class MfaPolicyValidator {
  MfaPolicyValidator._();

  /// Enforces mandatory Multi-Factor Authentication for sensitive roles
  static bool requiresMfa(UserRoleEnum role) {
    return role == UserRoleEnum.admin || role == UserRoleEnum.superAdmin;
  }
}
