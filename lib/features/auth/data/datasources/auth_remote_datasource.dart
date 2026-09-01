import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/utils/app_logger.dart';

import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../models/user_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<UserProfileModel> verifyOtp({
    required String phoneNumber,
    required String otpToken,
  });
  Future<UserProfileModel> signInWithGoogle();
  Future<UserProfileModel> signInWithApple();
  Future<UserProfileModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserProfileModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });
  Future<UserProfileModel?> fetchCurrentProfile();
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<UserProfileModel> setRole(UserRoleEnum role);
  Future<void> sendPasswordResetEmail(String email);
  Future<KYCVerificationModel> submitKyc({
    required String documentType,
    required String documentNumber,
    required String documentUrl,
  });
  Future<void> signOut();
}


@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl extends BaseRemoteDataSource implements AuthRemoteDataSource {
  final SupabaseService _supabaseService;

  static final GoogleSignIn _sharedGoogleSignIn = GoogleSignIn(
    serverClientId: '1031008602596-ha9oarf6dnorgne365kqgadm5fgfv8b4.apps.googleusercontent.com',
  );
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => _sharedGoogleSignIn;

  String? _verificationId;

  AuthRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<void> sendOtp(String phoneNumber) async {
    return safeQuery(() async {
      // Clean digits & normalize to E.164
      final trimmed = phoneNumber.trim();
      final digits = trimmed.replaceAll(RegExp(r'\D'), '');
      String formattedPhone;
      if (digits.length == 10) {
        formattedPhone = '+91$digits';
      } else if (trimmed.startsWith('+')) {
        formattedPhone = '+$digits';
      } else if (digits.length == 12 && digits.startsWith('91')) {
        formattedPhone = '+$digits';
      } else {
        formattedPhone = trimmed.startsWith('+') ? trimmed : '+91$trimmed';
      }

      final maskedPhone = formattedPhone.length > 4
          ? '${formattedPhone.substring(0, 3)} ******${formattedPhone.substring(formattedPhone.length - 4)}'
          : '******';

      AppLogger.i('====================================================');
      AppLogger.i('[Auth] PHONE OTP STAGE 1: Dispatching SMS OTP to $maskedPhone');

      final completer = Completer<void>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          AppLogger.i('[Auth] PHONE OTP STAGE 2A: Instant Auto-Verification completed');
          try {
            await _firebaseAuth.signInWithCredential(credential);
          } catch (e) {
            AppLogger.w('[Auth] Auto sign-in warning: $e');
          }
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.e('[Auth] PHONE OTP STAGE 2B FAILED: ${e.code} - ${e.message}');
          String userFriendlyMsg;
          switch (e.code) {
            case 'invalid-phone-number':
              userFriendlyMsg = 'Invalid phone number. Please enter a valid 10-digit mobile number.';
              break;
            case 'too-many-requests':
              userFriendlyMsg = 'Too many requests. Please wait a few moments and try again.';
              break;
            case 'quota-exceeded':
              userFriendlyMsg = 'SMS quota reached. Please check Firebase SMS region policy/plan.';
              break;
            case 'app-not-authorized':
              userFriendlyMsg = 'App verification pending. Ensure SHA-1/SHA-256 are added to Firebase Console.';
              break;
            case 'captcha-check-failed':
              userFriendlyMsg = 'Verification check failed. Please try again.';
              break;
            default:
              userFriendlyMsg = e.message ?? 'Phone verification failed (${e.code})';
          }
          if (!completer.isCompleted) completer.completeError(Exception(userFriendlyMsg));
        },
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.i('[Auth] PHONE OTP STAGE 2C: SMS sent successfully. Verification ID registered.');
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.i('[Auth] PHONE OTP STAGE 2D: Auto-retrieval timeout. Verification ID stored.');
          _verificationId = verificationId;
        },
      );

      return completer.future;
    });
  }

  @override
  Future<UserProfileModel> verifyOtp({
    required String phoneNumber,
    required String otpToken,
  }) async {
    return safeQuery(() async {
      final verificationId = _verificationId;
      if (verificationId == null) {
        throw Exception('Verification ID expired. Please request OTP again.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      return UserProfileModel(
        id: user?.uid ?? 'usr_phone_${DateTime.now().millisecondsSinceEpoch}',
        fullName: user?.displayName ?? 'Belagavi Resident',
        phoneNumber: phoneNumber,
        email: user?.email,
        role: UserRoleEnum.buyer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Future<UserProfileModel> signInWithGoogle() async {
    AppLogger.i('====================================================');
    AppLogger.i('[Auth] STAGE A: Google account chooser started');

    GoogleSignInAccount? googleUser;
    try {
      // Clear previous cached session to avoid stale account state on retry
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      googleUser = await _googleSignIn.signIn();
    } catch (e, stackTrace) {
      AppLogger.e('[Auth] STAGE A/B FAILED: GoogleSignIn.signIn() error: $e', e, stackTrace);
      throw Exception('Google Sign-In failed: $e');
    }

    if (googleUser == null) {
      AppLogger.i('[Auth] STAGE B: Google Sign-In cancelled by user.');
      throw Exception('Google Sign-In cancelled by user');
    }

    AppLogger.i('[Auth] STAGE B: Google account selected: ${googleUser.email}');

    User? firebaseUser;
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final hasIdToken = googleAuth.idToken != null && googleAuth.idToken!.isNotEmpty;
      final hasAccessToken = googleAuth.accessToken != null && googleAuth.accessToken!.isNotEmpty;
      AppLogger.i('[Auth] STAGE C: Google auth tokens retrieved. hasIdToken: $hasIdToken, hasAccessToken: $hasAccessToken');

      if (hasIdToken || hasAccessToken) {
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        firebaseUser = userCredential.user;
        AppLogger.i('[Auth] STAGE D: Firebase signInWithCredential succeeded');
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.e('[Auth] STAGE D FAILED: Firebase credential exchange error: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Firebase Google authentication failed: ${e.code}');
    } catch (e) {
      AppLogger.w('[Auth] STAGE D Warning: $e');
    }

    if (firebaseUser == null) {
      AppLogger.e('[Auth] STAGE E FAILED: Google credential exchange failed — no Firebase user obtained.');
      throw Exception('Google Sign-In failed to authenticate with Firebase. Please try again.');
    }

    AppLogger.i('[Auth] STAGE E: Firebase currentUser available. UID: ${firebaseUser.uid}');
    AppLogger.i('[Auth] STAGE F: Initializing canonical user profile from authenticated session');
    AppLogger.i('====================================================');

    final String uid = firebaseUser.uid;
    final String name = firebaseUser.displayName ?? googleUser.displayName ?? 'Belagavi Property Owner';
    final String email = firebaseUser.email ?? googleUser.email;
    final String? photo = firebaseUser.photoURL ?? googleUser.photoUrl;
    final bool isOwner = email.toLowerCase().trim() == 'belagaviproperty@gmail.com';

    return UserProfileModel(
      id: uid,
      fullName: name,
      email: email,
      phoneNumber: firebaseUser.phoneNumber ?? '',
      avatarUrl: photo,
      role: isOwner ? UserRoleEnum.superAdmin : UserRoleEnum.buyer,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfileModel> signInWithApple() async {
    return safeQuery(() async {
      AppLogger.i('[Auth] Initiating Apple Sign-In with Firebase OAuthProvider...');
      final appleProvider = OAuthProvider('apple.com');
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      UserCredential userCredential;
      try {
        userCredential = await _firebaseAuth.signInWithProvider(appleProvider);
      } on FirebaseAuthException catch (e) {
        AppLogger.e('[Auth] Apple Sign-In FirebaseAuthException: ${e.code} - ${e.message}');
        if (e.code == 'canceled' || e.code == 'popup_closed_by_user') {
          throw Exception('Apple sign in cancelled by user');
        }
        throw Exception(e.message ?? 'Apple sign in failed. Please check Apple provider configuration.');
      } catch (e) {
        AppLogger.e('[Auth] Apple Sign-In error: $e');
        throw Exception('Apple sign in error: $e');
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Apple Sign-In failed to authenticate with Firebase.');
      }

      AppLogger.i('====================================================');
      AppLogger.i('🍎 CTO APPLE AUTHENTICATION VERIFICATION LOGS');
      AppLogger.i('Apple Firebase UID: ${firebaseUser.uid}');
      AppLogger.i('Apple Display Name: ${firebaseUser.displayName}');
      AppLogger.i('Apple Email / Private Relay: ${firebaseUser.email}');
      AppLogger.i('====================================================');

      return UserProfileModel(
        id: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? 'Apple User',
        email: firebaseUser.email,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        avatarUrl: firebaseUser.photoURL,
        role: UserRoleEnum.buyer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Future<UserProfileModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return safeQuery(() async {
      AppLogger.i('[Auth] Email/Password sign-in for: $email');
      try {
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = userCredential.user!;
        AppLogger.i('[Auth] Email sign-in success. UID: ${user.uid}');
        return UserProfileModel(
          id: user.uid,
          fullName: user.displayName ?? email.split('@').first,
          email: user.email,
          phoneNumber: user.phoneNumber ?? '',
          avatarUrl: user.photoURL,
          role: UserRoleEnum.buyer,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } on FirebaseAuthException catch (e) {
        AppLogger.e('[Auth] Email sign-in failed: ${e.code}');
        switch (e.code) {
          case 'user-not-found':
            throw Exception('No account found for this email. Please sign up first.');
          case 'wrong-password':
          case 'invalid-credential':
            throw Exception('Incorrect email or password. Please try again.');
          case 'user-disabled':
            throw Exception('This account has been disabled. Contact support.');
          case 'too-many-requests':
            throw Exception('Too many attempts. Please try again later.');
          case 'invalid-email':
            throw Exception('Please enter a valid email address.');
          default:
            throw Exception(e.message ?? 'Sign-in failed. Please try again.');
        }
      }
    });
  }

  @override
  Future<UserProfileModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return safeQuery(() async {
      AppLogger.i('[Auth] Email/Password sign-up for: $email');
      try {
        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = userCredential.user!;
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
        AppLogger.i('[Auth] Email sign-up success. UID: ${user.uid}');
        return UserProfileModel(
          id: user.uid,
          fullName: displayName ?? email.split('@').first,
          email: user.email,
          phoneNumber: '',
          avatarUrl: null,
          role: UserRoleEnum.buyer,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } on FirebaseAuthException catch (e) {
        AppLogger.e('[Auth] Email sign-up failed: ${e.code}');
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('An account already exists for this email. Please sign in.');
          case 'weak-password':
            throw Exception('Password must be at least 6 characters.');
          case 'invalid-email':
            throw Exception('Please enter a valid email address.');
          case 'operation-not-allowed':
            throw Exception('Email/Password sign-up is not enabled. Contact support.');
          default:
            throw Exception(e.message ?? 'Sign-up failed. Please try again.');
        }
      }
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return safeQuery(() async {
      AppLogger.i('[Auth] Sending password reset email to: $email');
      try {
        await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
        AppLogger.i('[Auth] Password reset email sent successfully.');
      } on FirebaseAuthException catch (e) {
        AppLogger.e('[Auth] Password reset failed: ${e.code}');
        switch (e.code) {
          case 'invalid-email':
            throw Exception('Please enter a valid email address.');
          case 'user-not-found':
            // Do NOT reveal user existence. Return success silently.
            AppLogger.w('[Auth] Password reset: user not found, returning silent success.');
            return;
          default:
            throw Exception(e.message ?? 'Failed to send reset email. Please try again.');
        }
      }
    });
  }

  @override
  Future<UserProfileModel?> fetchCurrentProfile() async {
    return safeQuery(() async {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        if (!_supabaseService.isInitialized) {
          return UserProfileModel(
            id: fbUser.uid,
            firebaseUid: fbUser.uid,
            fullName: fbUser.displayName ?? 'Belagavi Property User',
            email: fbUser.email,
            phoneNumber: fbUser.phoneNumber ?? '+91 9113219906',
            avatarUrl: fbUser.photoURL,
            role: UserRoleEnum.buyer,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }

        // Query profiles by firebase_uid
        final response = await _supabaseService
            .from('profiles')
            .select()
            .eq('firebase_uid', fbUser.uid)
            .maybeSingle();

        if (response != null) {
          return UserProfileModel.fromJson(response);
        }

        // Insert initial profile if not yet created in Supabase profiles table
        final newProfileMap = {
          'firebase_uid': fbUser.uid,
          'full_name': fbUser.displayName ?? 'Belagavi Property User',
          'phone_number': fbUser.phoneNumber ?? '+919113219906',
          if (fbUser.email != null) 'email': fbUser.email,
          'role': 'buyer',
        };

        final inserted = await _supabaseService
            .from('profiles')
            .insert(newProfileMap)
            .select()
            .single();

        return UserProfileModel.fromJson(inserted);
      }

      return null;
    });
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return profile;
      final payload = profile.toJson();
      final query = profile.id.isNotEmpty
          ? _supabaseService.from('profiles').update(payload).eq('id', profile.id)
          : _supabaseService.from('profiles').update(payload).eq('firebase_uid', profile.firebaseUid ?? '');
      final response = await query.select().single();
      return UserProfileModel.fromJson(response);
    });
  }

  @override
  Future<UserProfileModel> setRole(UserRoleEnum role) async {
    return safeQuery(() async {
      final current = await fetchCurrentProfile();
      if (current == null) {
        return UserProfileModel(
          id: 'usr_mock',
          fullName: 'PropertyHub User',
          phoneNumber: '+919876543210',
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      final updated = UserProfileModel(
        id: current.id,
        fullName: current.fullName,
        phoneNumber: current.phoneNumber,
        email: current.email,
        role: role,
        avatarUrl: current.avatarUrl,
        companyName: current.companyName,
        reraNumber: current.reraNumber,
        kycStatus: current.kycStatus,
        teamId: current.teamId,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );
      return await updateProfile(updated);
    });
  }

  @override
  Future<KYCVerificationModel> submitKyc({
    required String documentType,
    required String documentNumber,
    required String documentUrl,
  }) async {
    return safeQuery(() async {
      final kyc = KYCVerificationModel(
        id: 'kyc_${DateTime.now().millisecondsSinceEpoch}',
        userId: _firebaseAuth.currentUser?.uid ?? _supabaseService.currentUser?.id ?? 'usr_mock',
        status: KYCStatus.pendingKyc,
        documentType: documentType,
        documentNumber: documentNumber,
        documentUrl: documentUrl,
      );

      if (!_supabaseService.isInitialized) return kyc;

      final response =
          await _supabaseService.from('kyc_verifications').insert(kyc.toJson()).select().single();
      return KYCVerificationModel.fromJson(response);
    });
  }

  @override
  Future<void> signOut() async {
    return safeQuery(() async {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      if (_supabaseService.isInitialized) {
        await _supabaseService.client.auth.signOut();
      }
    });
  }
}
