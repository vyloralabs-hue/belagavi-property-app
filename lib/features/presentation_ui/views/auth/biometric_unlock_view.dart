import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/security/biometric_auth_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../theme/app_design_system.dart';

/// Biometric Quick Unlock View — App Startup Screen
/// Protects active session on startup with native biometric hardware verification.
class BiometricUnlockView extends StatefulWidget {
  const BiometricUnlockView({super.key});

  @override
  State<BiometricUnlockView> createState() => _BiometricUnlockViewState();
}

class _BiometricUnlockViewState extends State<BiometricUnlockView> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometricUnlock();
    });
  }

  Future<void> _triggerBiometricUnlock() async {
    if (_isAuthenticating) return;

    // Security Invariant Check: Verify that an active, valid Firebase session exists
    final fbUser = (Firebase.apps.isNotEmpty) ? FirebaseAuth.instance.currentUser : null;
    final hasValidSession = (fbUser != null && !fbUser.isAnonymous) || AuthSessionStorageHelper.isLoggedIn();

    if (!hasValidSession) {
      AppLogger.w('[Biometric] No valid Firebase/authenticated session found. Redirecting to Auth.');
      await AuthSessionStorageHelper.logout();
      if (mounted) {
        try {
          context.go('/auth');
        } catch (e) {
          AppLogger.w('[Biometric] Router redirect warning: $e');
        }
      }
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final didAuthenticate = await _biometricService.authenticate(
        localizedReason: 'Scan your fingerprint or Face ID to unlock PropertyHub',
      );

      if (didAuthenticate) {
        AppLogger.i('[Biometric] Biometric unlock successful! Releasing app access.');
        await AuthSessionStorageHelper.setBiometricUnlocked(true);
        if (mounted) {
          String? redirectParam;
          try {
            redirectParam = GoRouterState.of(context).uri.queryParameters['redirect'];
          } catch (_) {
            redirectParam = null;
          }
          if (redirectParam != null && redirectParam.isNotEmpty) {
            try {
              context.go(redirectParam);
            } catch (_) {}
          } else {
            try {
              context.go('/home');
            } catch (_) {}
          }
        }
      } else {
        AppLogger.w('[Biometric] Biometric unlock failed or was cancelled by user.');
        if (mounted) {
          setState(() {
            _errorMessage = 'Biometric authentication was cancelled or not recognized.';
          });
        }
      }
    } catch (e) {
      AppLogger.e('[Biometric] Unexpected error during biometric unlock: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Biometric sensor error. Please try again or sign in with your account.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  Future<void> _signOutAndSwitchAccount() async {
    await AuthSessionStorageHelper.logout();
    if (mounted) {
      try {
        context.go('/auth');
      } catch (e) {
        AppLogger.w('[Biometric] Router redirect warning: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthSessionStorageHelper.getUserName() ?? 'PropertyHub User';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Fingerprint Emblem
              GestureDetector(
                onTap: _isAuthenticating ? null : _triggerBiometricUnlock,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB39D77), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x60B39D77),
                        blurRadius: 28,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isAuthenticating
                        ? const CircularProgressIndicator(color: Color(0xFFB39D77))
                        : const Icon(
                            Icons.fingerprint_rounded,
                            size: 72,
                            color: Color(0xFFB39D77),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Unlock PropertyHub',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFDFCF4),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Welcome back, $userName.\nScan fingerprint or Face ID to continue.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B1515),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 13,
                      color: Color(0xFFFCA5A5),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Unlock Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  key: const ValueKey('btn_trigger_unlock'),
                  icon: const Icon(Icons.fingerprint_rounded, size: 22),
                  label: const Text(
                    'Unlock with Fingerprint / Face ID',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: _isAuthenticating ? null : _triggerBiometricUnlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB39D77),
                    foregroundColor: const Color(0xFF0A0D11),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Switch Account Option
              TextButton(
                key: const ValueKey('btn_switch_account'),
                onPressed: _signOutAndSwitchAccount,
                child: const Text(
                  'Sign in with another account',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
