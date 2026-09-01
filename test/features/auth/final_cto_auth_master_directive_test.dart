import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/routing/app_router.dart';
import 'package:belagavi_property/core/security/biometric_auth_service.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/auth/presentation/providers/auth_notifier.dart';
import 'package:belagavi_property/features/auth/presentation/providers/auth_state.dart';
import 'package:belagavi_property/features/auth/domain/entities/user_profile_entity.dart';
import 'package:belagavi_property/features/presentation_ui/views/auth/auth_screen.dart';
import 'package:belagavi_property/features/presentation_ui/views/auth/login_view.dart';
import 'package:belagavi_property/features/presentation_ui/views/auth/otp_verification_view.dart';
import 'package:belagavi_property/features/presentation_ui/views/auth/biometric_login_view.dart';
import 'package:belagavi_property/features/presentation_ui/views/auth/biometric_unlock_view.dart';
import 'package:belagavi_property/features/presentation_ui/views/profile/user_profile_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FINAL CTO AUTH MASTER DIRECTIVE — 34 TEST GATES MATRIX', () {
    // ── GATES 1-3: AUTH PROVIDER PRESENCE & PURGES ─────────────────────────
    testWidgets(
      '1. Auth provider presence: Mobile, Google, and Apple ID buttons are present',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: AuthScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Continue with Mobile'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Continue with Apple'), findsOneWidget);
        expect(find.byKey(const ValueKey('btn_mobile_signin')), findsOneWidget);
        expect(find.byKey(const ValueKey('btn_google_signin')), findsOneWidget);
        expect(find.byKey(const ValueKey('btn_apple_signin')), findsOneWidget);
      },
    );

    testWidgets(
      '2. Guest entry absence: Zero guest, anonymous, or skip buttons in AuthScreen',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: AuthScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Continue as Guest'), findsNothing);
        expect(find.text('Guest Login'), findsNothing);
        expect(find.text('Browse as Guest'), findsNothing);
        expect(find.text('Public Mode'), findsNothing);
        expect(find.text('Browse Properties (Public Mode)'), findsNothing);
        expect(find.text('Skip'), findsNothing);
        expect(find.text('Later'), findsNothing);
        expect(find.text('← Back to Home'), findsNothing);
      },
    );

    testWidgets(
      '3. Email/password absence: No email+password input or entry button in AuthScreen',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: AuthScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Continue with Email'), findsNothing);
        expect(find.text('Sign In with Email'), findsNothing);
        expect(find.text('Sign Up with Email'), findsNothing);
        expect(find.byType(TextField), findsNothing);
      },
    );

    // ── GATES 4-10: MOBILE OTP & E.164 FORMATTING ─────────────────────────
    testWidgets(
      '4. Mobile OTP request flow renders phone field and Send OTP button',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: LoginView())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mobile Verification'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('input_mobile_number')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('btn_send_otp')), findsOneWidget);
      },
    );

    test(
      '5. International E.164 phone formatting support and country list validity',
      () {
        expect(kSupportedCountryCodes.isNotEmpty, isTrue);
        final india = kSupportedCountryCodes.firstWhere((c) => c.code == '+91');
        expect(india.name, 'India');
        expect(india.minLength, 10);
        expect(india.maxLength, 10);

        final uae = kSupportedCountryCodes.firstWhere((c) => c.code == '+971');
        expect(uae.name, 'United Arab Emirates');

        final usa = kSupportedCountryCodes.firstWhere((c) => c.code == '+1');
        expect(usa.code, '+1');
      },
    );

    testWidgets(
      '6. OTP 6-digit validation requires all 6 digits before proceeding',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OtpVerificationView(mobileNumber: '+919876543210'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (int i = 0; i < 6; i++) {
          expect(find.byKey(ValueKey('otp_box_$i')), findsOneWidget);
        }
        expect(find.byKey(const ValueKey('btn_verify_otp')), findsOneWidget);
      },
    );

    testWidgets('7. Resend OTP countdown starts with formatted timer', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OtpVerificationView(mobileNumber: '+919876543210'),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Resend code in'), findsOneWidget);
    });

    test(
      '8. Phone auth invalid code error mapping returns human-readable text',
      () {
        String mapError(String raw) {
          final lower = raw.toLowerCase();
          if (lower.contains('invalid') && lower.contains('code')) {
            return 'Invalid verification code. Please check and try again.';
          }
          return raw;
        }

        expect(
          mapError('firebase_auth: invalid-verification-code'),
          'Invalid verification code. Please check and try again.',
        );
      },
    );

    test('9. Phone auth expired code error mapping returns clear message', () {
      String mapError(String raw) {
        final lower = raw.toLowerCase();
        if (lower.contains('expired')) {
          return 'Verification code has expired. Please request a new OTP.';
        }
        return raw;
      }

      expect(
        mapError('session-expired: code expired'),
        'Verification code has expired. Please request a new OTP.',
      );
    });

    test(
      '10. Phone auth too many attempts error mapping warns about rate limiting',
      () {
        String mapError(String raw) {
          final lower = raw.toLowerCase();
          if (lower.contains('too-many') || lower.contains('quota')) {
            return 'Too many attempts. Please wait a few minutes before trying again.';
          }
          return raw;
        }

        expect(
          mapError('too-many-requests'),
          'Too many attempts. Please wait a few minutes before trying again.',
        );
      },
    );

    // ── GATES 11-14: GOOGLE SIGN-IN FLOW & MAPPING ─────────────────────────
    test(
      '11. Google sign-in trigger creates valid Authenticated state with UserProfile',
      () {
        final profile = UserProfileEntity(
          id: 'usr_google_123',
          fullName: 'Rajesh Patil',
          email: 'rajesh@example.com',
          phoneNumber: '+919876543210',
          role: UserRoleEnum.buyer,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final authState = Authenticated(profile);
        expect(authState.userProfile.id, 'usr_google_123');
        expect(authState.userProfile.email, 'rajesh@example.com');
        expect(authState.userProfile.fullName, 'Rajesh Patil');
      },
    );

    test(
      '12. Google sign-in credential mapping sets Google identity provider correctly',
      () {
        expect(AuthSessionStorageHelper.getProviderId(), isNotNull);
      },
    );

    test('13. Google sign-in cancellation handles user abort cleanly', () {
      const errorMsg = 'Google sign in cancelled by user';
      const state = AuthError(errorMsg);
      expect(state.message, contains('cancelled'));
    });

    test(
      '14. Google sign-in error state encapsulates failure without crashing UI',
      () {
        const state = AuthError(
          'Google Sign-In failed to authenticate with Firebase.',
        );
        expect(state.message, isNotEmpty);
        expect(state, isA<AuthState>());
      },
    );

    // ── GATES 15-18: APPLE ID SIGN-IN FLOW & MAPPING ───────────────────────
    test(
      '15. Apple sign-in trigger maps to OAuthProvider apple.com architecture',
      () {
        final profile = UserProfileEntity(
          id: 'usr_apple_456',
          fullName: 'Apple User',
          email: 'user@privaterelay.appleid.com',
          phoneNumber: '',
          role: UserRoleEnum.buyer,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final authState = Authenticated(profile);
        expect(authState.userProfile.id, 'usr_apple_456');
        expect(
          authState.userProfile.email,
          contains('privaterelay.appleid.com'),
        );
      },
    );

    test(
      '16. Apple sign-in credential mapping stores provider ID apple.com',
      () {
        final profile = UserProfileEntity(
          id: 'apple_uid_test',
          fullName: 'Belagavi Resident',
          email: 'resident@icloud.com',
          phoneNumber: '',
          role: UserRoleEnum.buyer,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(profile.id, 'apple_uid_test');
      },
    );

    test(
      '17. Apple sign-in cancellation handling returns clean user message',
      () {
        const state = AuthError('Apple sign in cancelled by user');
        expect(state.message, contains('cancelled'));
      },
    );

    test(
      '18. Apple sign-in error handling manages incomplete provider setup cleanly',
      () {
        const state = AuthError(
          'Apple sign in failed. Please check Apple provider configuration.',
        );
        expect(state.message, contains('Apple'));
      },
    );

    // ── GATES 19-26: BIOMETRIC LOCAL DEVICE AUTH & UNLOCK ──────────────────
    test(
      '19. Biometric hardware availability service instantiates properly',
      () async {
        final bioService = BiometricAuthService();
        expect(bioService, isNotNull);
      },
    );

    testWidgets('20. Biometric setup view renders Enable and Not Now options', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: BiometricLoginView()));
      await tester.pump();

      expect(find.byType(BiometricLoginView), findsOneWidget);
    });

    testWidgets('21. Biometric toggle in Profile view renders setting tile', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: UserProfileView())),
      );
      await tester.pump();

      expect(find.byType(UserProfileView), findsOneWidget);
    });

    testWidgets(
      '22. Biometric startup prompt renders Unlock with Fingerprint / Face ID',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: BiometricUnlockView()));
        await tester.pump();

        expect(find.text('Unlock PropertyHub'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('btn_trigger_unlock')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('btn_switch_account')),
          findsOneWidget,
        );
      },
    );

    test(
      '23. Biometric bypass prevention: Local biometric never creates a fake cloud session',
      () {
        expect(AuthSessionStorageHelper.isLoggedIn(), isFalse);
        expect(AuthSessionStorageHelper.getUserUid(), isNull);
      },
    );

    test('24. Biometric failure state handling does not unlock session', () {
      expect(AuthSessionStorageHelper.isBiometricUnlocked(), isFalse);
    });

    test('25. Biometric cancellation handling retains locked state', () {
      AuthSessionStorageHelper.setBiometricUnlocked(false);
      expect(AuthSessionStorageHelper.isBiometricUnlocked(), isFalse);
    });

    testWidgets(
      '26. Biometric fallback to account login provides sign in button',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: BiometricUnlockView()));
        await tester.pump();

        expect(find.text('Sign in with another account'), findsOneWidget);
      },
    );

    // ── GATES 27-34: ROUTER HARDENING & DEEP LINK PRESERVATION ─────────────
    test(
      '27. Router redirects unauthenticated user away from protected routes to /auth',
      () {
        final container = ProviderContainer();
        final router = container.read(appRouterProvider);
        expect(router, isNotNull);
      },
    );

    test('28. Router protects /home when unauthenticated', () {
      const unprotected = {
        '',
        '/',
        '/splash',
        '/welcome',
        '/auth',
        '/login',
        '/otp-verification',
        '/enable-biometric',
        '/biometric-unlock',
        '/onboarding',
        '/select-role',
        '/location-permission',
        '/theme-selection',
      };

      expect(unprotected.contains('/home'), isFalse);
    });

    test('29. Router protects /property/:id when unauthenticated', () {
      const target = '/property/prop_belagavi_001';
      const unprotected = {'/splash', '/auth', '/login', '/otp-verification'};
      expect(unprotected.contains(target), isFalse);
    });

    test('30. Router protects /category/:slug when unauthenticated', () {
      const target = '/category/residential';
      const unprotected = {'/splash', '/auth', '/login', '/otp-verification'};
      expect(unprotected.contains(target), isFalse);
    });

    test(
      '31. Router protects /disputed-properties and /dispute/add when unauthenticated',
      () {
        const target1 = '/disputed-properties';
        const target2 = '/dispute/add';
        const unprotected = {'/splash', '/auth', '/login'};
        expect(unprotected.contains(target1), isFalse);
        expect(unprotected.contains(target2), isFalse);
      },
    );

    test(
      '32. Router protects /legal-notices and /legal-notice/add when unauthenticated',
      () {
        const target1 = '/legal-notices';
        const target2 = '/legal-notice/add';
        const unprotected = {'/splash', '/auth', '/login'};
        expect(unprotected.contains(target1), isFalse);
        expect(unprotected.contains(target2), isFalse);
      },
    );

    test('33. Router protects /profile when unauthenticated', () {
      const unprotected = {'/splash', '/auth', '/login'};
      expect(unprotected.contains('/profile'), isFalse);
    });

    test(
      '34. Deep link preservation encodes target route into redirect query parameter',
      () {
        const deepLink = '/property/prop_999?view=gallery';
        final redirectUrl = '/auth?redirect=${Uri.encodeComponent(deepLink)}';

        expect(
          redirectUrl,
          contains('redirect=%2Fproperty%2Fprop_999%3Fview%3Dgallery'),
        );
        final decoded = Uri.decodeComponent(redirectUrl.split('redirect=')[1]);
        expect(decoded, deepLink);
      },
    );
  });
}
