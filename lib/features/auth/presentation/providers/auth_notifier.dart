import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../utils/auth_session_storage_helper.dart';
import 'auth_state.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository? _repositoryInstance;

  AuthRepository get _repository {
    if (_repositoryInstance != null) {
      return _repositoryInstance!;
    }
    if (getIt.isRegistered<AuthRepository>()) {
      _repositoryInstance = getIt<AuthRepository>();
      return _repositoryInstance!;
    }
    final supabase = getIt.isRegistered<SupabaseService>()
        ? getIt<SupabaseService>()
        : SupabaseService();
    _repositoryInstance = AuthRepositoryImpl(AuthRemoteDataSourceImpl(supabase));
    return _repositoryInstance!;
  }

  @override
  AuthState build() {

    // ── Preserve Authenticated state across navigation / rebuilds ──
    try {
      if (Firebase.apps.isNotEmpty) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null) {
          final email = fbUser.email ?? AuthSessionStorageHelper.getUserEmail();
          final bool isOwner = email?.toLowerCase().trim() == 'belagaviproperty@gmail.com';
          final profile = UserProfileEntity(
            id: fbUser.uid,
            fullName: fbUser.displayName ?? AuthSessionStorageHelper.getUserName() ?? (isOwner ? 'Belagavi Property Owner' : 'Authenticated User'),
            phoneNumber: fbUser.phoneNumber ?? AuthSessionStorageHelper.getMobileNumber() ?? '',
            email: email,
            avatarUrl: fbUser.photoURL ?? AuthSessionStorageHelper.getUserPhoto(),
            role: isOwner ? UserRoleEnum.superAdmin : UserRoleEnum.buyer,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          return Authenticated(profile);
        }
      }
    } catch (_) {}

    final storedEmail = AuthSessionStorageHelper.getUserEmail();
    if (AuthSessionStorageHelper.isLoggedIn() && storedEmail != null && storedEmail.isNotEmpty) {
      final bool isOwner = storedEmail.toLowerCase().trim() == 'belagaviproperty@gmail.com';
      final profile = UserProfileEntity(
        id: AuthSessionStorageHelper.getUserUid() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: AuthSessionStorageHelper.getUserName() ?? (isOwner ? 'Belagavi Property Owner' : 'Authenticated User'),
        phoneNumber: AuthSessionStorageHelper.getMobileNumber() ?? '',
        email: storedEmail,
        avatarUrl: AuthSessionStorageHelper.getUserPhoto(),
        role: isOwner ? UserRoleEnum.superAdmin : UserRoleEnum.buyer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return Authenticated(profile);
    }

    return const AuthInitial();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    final isLoggedIn = AuthSessionStorageHelper.isLoggedIn();
    if (!isLoggedIn) {
      state = const Unauthenticated();
      return;
    }

    final result = await _repository.getCurrentProfile();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (profile) {
        if (profile != null) {
          state = Authenticated(profile);
        } else {
          state = const Unauthenticated();
        }
      },
    );
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = const AuthLoading();
    final result = await _repository.sendOtp(phoneNumber);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const Unauthenticated(),
    );
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpToken,
  }) async {
    state = const AuthLoading();
    final result = await _repository.verifyOtp(
      phoneNumber: phoneNumber,
      otpToken: otpToken,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (profile) async {
        await AuthSessionStorageHelper.saveLoginSession(mobileNumber: phoneNumber);
        state = Authenticated(profile);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    final result = await _repository.signInWithGoogle();
    result.fold(
      (failure) {
        if (failure.message.toLowerCase().contains('cancelled') ||
            failure.message.toLowerCase().contains('canceled')) {
          state = const Unauthenticated();
        } else {
          state = AuthError(failure.message);
        }
      },
      (profile) async {
        await AuthSessionStorageHelper.saveLoginSession(
          mobileNumber: profile.phoneNumber.isNotEmpty ? profile.phoneNumber : '',
          userName: profile.fullName,
          userEmail: profile.email,
          userPhoto: profile.avatarUrl,
          uid: profile.id,
          providerId: 'google.com',
        );
        state = Authenticated(profile);
      },
    );
  }

  Future<void> signInWithApple() async {
    state = const AuthLoading();
    final result = await _repository.signInWithApple();
    result.fold(
      (failure) {
        if (failure.message.toLowerCase().contains('cancelled') ||
            failure.message.toLowerCase().contains('canceled')) {
          state = const Unauthenticated();
        } else {
          state = AuthError(failure.message);
        }
      },
      (profile) async {
        await AuthSessionStorageHelper.saveLoginSession(
          mobileNumber: profile.phoneNumber.isNotEmpty ? profile.phoneNumber : '',
          userName: profile.fullName,
          userEmail: profile.email,
          userPhoto: profile.avatarUrl,
          uid: profile.id,
          providerId: 'apple.com',
        );
        state = Authenticated(profile);
      },
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await _repository.signInWithEmail(email: email, password: password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (profile) async {
        await AuthSessionStorageHelper.saveLoginSession(
          mobileNumber: '',
          userName: profile.fullName,
          userEmail: profile.email,
          uid: profile.id,
          providerId: 'password',
        );
        state = Authenticated(profile);
      },
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AuthLoading();
    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (profile) async {
        await AuthSessionStorageHelper.saveLoginSession(
          mobileNumber: '',
          userName: profile.fullName,
          userEmail: profile.email,
          uid: profile.id,
          providerId: 'password',
        );
        state = Authenticated(profile);
      },
    );
  }

  Future<void> switchRole(UserRoleEnum role) async {
    final currentState = state;
    if (currentState is Authenticated) {
      final result = await _repository.setRole(role);
      result.fold(
        (failure) => state = AuthError(failure.message),
        (updatedProfile) async {
          await AuthSessionStorageHelper.setUserRole(role.name);
          state = Authenticated(updatedProfile);
        },
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AuthLoading();
    final result = await _repository.sendPasswordResetEmail(email);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthPasswordResetSent(),
    );
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    await _repository.signOut();
    await AuthSessionStorageHelper.logout();
    state = const Unauthenticated();
  }
}
