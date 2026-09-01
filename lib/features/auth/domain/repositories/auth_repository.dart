import '../../../../core/utils/typedefs.dart';
import '../entities/user_profile_entity.dart';

abstract class AuthRepository {
  FutureEither<void> sendOtp(String phoneNumber);

  FutureEither<UserProfileEntity> verifyOtp({
    required String phoneNumber,
    required String otpToken,
  });

  FutureEither<UserProfileEntity> signInWithGoogle();
  FutureEither<UserProfileEntity> signInWithApple();

  FutureEither<UserProfileEntity> signInWithEmail({
    required String email,
    required String password,
  });

  FutureEither<UserProfileEntity> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  FutureEither<UserProfileEntity?> getCurrentProfile();

  FutureEither<UserProfileEntity> updateProfile(UserProfileEntity profile);

  FutureEither<UserProfileEntity> setRole(UserRoleEnum role);

  FutureEither<KYCVerificationEntity> submitKyc({
    required String documentType,
    required String documentNumber,
    required String documentUrl,
  });

  FutureEither<void> sendPasswordResetEmail(String email);

  FutureEither<void> signOut();
}
