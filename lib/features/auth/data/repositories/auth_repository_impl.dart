import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_profile_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<void> sendOtp(String phoneNumber) async {
    return safeCall(() => _remoteDataSource.sendOtp(phoneNumber));
  }

  @override
  FutureEither<UserProfileEntity> verifyOtp({
    required String phoneNumber,
    required String otpToken,
  }) async {
    return safeCall(
      () => _remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otpToken: otpToken,
      ),
    );
  }

  @override
  FutureEither<UserProfileEntity> signInWithGoogle() async {
    return safeCall(() => _remoteDataSource.signInWithGoogle());
  }

  @override
  FutureEither<UserProfileEntity> signInWithApple() async {
    return safeCall(() => _remoteDataSource.signInWithApple());
  }

  @override
  FutureEither<UserProfileEntity?> getCurrentProfile() async {
    return safeCall(() => _remoteDataSource.fetchCurrentProfile());
  }

  @override
  FutureEither<UserProfileEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return safeCall(() => _remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    ));
  }

  @override
  FutureEither<UserProfileEntity> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return safeCall(() => _remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    ));
  }

  @override
  FutureEither<UserProfileEntity> updateProfile(UserProfileEntity profile) async {
    return safeCall(() async {
      final model = UserProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        phoneNumber: profile.phoneNumber,
        email: profile.email,
        role: profile.role,
        avatarUrl: profile.avatarUrl,
        companyName: profile.companyName,
        reraNumber: profile.reraNumber,
        kycStatus: profile.kycStatus,
        teamId: profile.teamId,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      );
      return await _remoteDataSource.updateProfile(model);
    });
  }

  @override
  FutureEither<UserProfileEntity> setRole(UserRoleEnum role) async {
    return safeCall(() => _remoteDataSource.setRole(role));
  }

  @override
  FutureEither<KYCVerificationEntity> submitKyc({
    required String documentType,
    required String documentNumber,
    required String documentUrl,
  }) async {
    return safeCall(
      () => _remoteDataSource.submitKyc(
        documentType: documentType,
        documentNumber: documentNumber,
        documentUrl: documentUrl,
      ),
    );
  }

  @override
  FutureEither<void> sendPasswordResetEmail(String email) async {
    return safeCall(() => _remoteDataSource.sendPasswordResetEmail(email));
  }

  @override
  FutureEither<void> signOut() async {
    return safeCall(() => _remoteDataSource.signOut());
  }
}
