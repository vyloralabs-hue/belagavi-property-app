import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/security/biometric_auth_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../theme/app_design_system.dart';

/// Biometric Setup Flow View (Screen offered after first successful login)
/// "Enable Biometric Login?"
/// "Use fingerprint / Face ID to unlock PropertyHub faster on this device."
/// [ Enable ] | [ Not Now ]
class BiometricLoginView extends StatefulWidget {
  const BiometricLoginView({super.key});

  @override
  State<BiometricLoginView> createState() => _BiometricLoginViewState();
}

class _BiometricLoginViewState extends State<BiometricLoginView> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isChecking = true;
  bool _isSupported = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkHardware();
  }

  Future<void> _checkHardware() async {
    try {
      final available = await _biometricService.isBiometricAvailable();
      if (mounted) {
        setState(() {
          _isSupported = available;
          _isChecking = false;
        });
        // If not supported at all on this hardware, skip setup automatically
        if (!available) {
          _skipSetup();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSupported = false;
          _isChecking = false;
        });
        _skipSetup();
      }
    }
  }

  void _proceedToDestination() {
    String? redirectParam;
    try {
      redirectParam = GoRouterState.of(context).uri.queryParameters['redirect'];
    } catch (_) {
      redirectParam = null;
    }

    if (redirectParam != null && redirectParam.isNotEmpty) {
      context.go(redirectParam);
    } else {
      context.go('/home');
    }
  }

  Future<void> _enableBiometric() async {
    setState(() => _isAuthenticating = true);
    try {
      final didAuthenticate = await _biometricService.authenticate(
        localizedReason: 'Confirm your fingerprint or Face ID to enable quick unlock',
      );

      if (didAuthenticate) {
        AppLogger.i('[Biometric] Biometric setup confirmed successfully.');
        await AuthSessionStorageHelper.setBiometricEnabled(true);
        await AuthSessionStorageHelper.setBiometricUnlocked(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric quick unlock enabled successfully!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _proceedToDestination();
        }
      } else {
        AppLogger.w('[Biometric] Biometric confirmation was cancelled or failed.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication cancelled. You can enable it anytime in Profile Settings.'),
              backgroundColor: Color(0xFFD97706),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.e('[Biometric] Error during biometric setup: $e');
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  Future<void> _skipSetup() async {
    await AuthSessionStorageHelper.setBiometricEnabled(false);
    await AuthSessionStorageHelper.setBiometricUnlocked(true);
    if (mounted) {
      _proceedToDestination();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0D11),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB39D77)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Fingerprint Graphic Badge
              Container(
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
              const SizedBox(height: 36),

              const Text(
                'Enable Biometric Login?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFDFCF4),
                ),
              ),
              const SizedBox(height: 14),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Use fingerprint or Face ID to unlock PropertyHub faster and more securely on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),

              // Enable Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey('btn_enable_biometric'),
                  onPressed: _isAuthenticating ? null : _enableBiometric,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB39D77),
                    foregroundColor: const Color(0xFF0A0D11),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isAuthenticating
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0D11)),
                        )
                      : const Text(
                          'Enable',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Not Now Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  key: const ValueKey('btn_skip_biometric'),
                  onPressed: _isAuthenticating ? null : _skipSetup,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Not Now',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE2E8F0),
                    ),
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
