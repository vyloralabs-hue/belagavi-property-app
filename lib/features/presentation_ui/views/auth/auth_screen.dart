import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../theme/app_design_system.dart';

/// Authentication Screen — CTO Master Directive
/// ONLY 3 Authentication Methods: Mobile OTP, Google, and Apple ID.
/// Zero Guest / Zero Email-Password / Zero Skip.
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? redirectParam;
    try {
      redirectParam = GoRouterState.of(context).uri.queryParameters['redirect'];
    } catch (_) {
      redirectParam = null;
    }

    void navigatePostAuth() {
      if (redirectParam != null && redirectParam.isNotEmpty) {
        context.go(redirectParam);
      } else {
        context.go('/home');
      }
    }

    // Listen for auth state changes safely
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is Authenticated) {
        navigatePostAuth();
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Logo Emblem
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFB39D77), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x40B39D77), blurRadius: 24, spreadRadius: 2),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.apartment_rounded, size: 40, color: Color(0xFFB39D77)),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                const Text(
                  'Welcome to Belagavi Property',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDFCF4),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtext
                const Text(
                  'Sign in securely to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 36),

                // Auth Card with ONLY 3 Provider Buttons
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFB39D77).withValues(alpha: 0.25)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x60000000), blurRadius: 20, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PRIMARY BUTTON: Mobile OTP
                      _AuthButton(
                        id: 'btn_mobile_signin',
                        icon: Icons.phone_android_rounded,
                        iconColor: const Color(0xFFB39D77),
                        label: 'Continue with Mobile',
                        isPrimary: true,
                        isLoading: isLoading,
                        onPressed: () {
                          final route = redirectParam != null
                              ? '/login?redirect=${Uri.encodeComponent(redirectParam)}'
                              : '/login';
                          context.go(route);
                        },
                      ),
                      const SizedBox(height: 16),

                      // SECONDARY BUTTON: Google Login
                      _AuthButton(
                        id: 'btn_google_signin',
                        icon: Icons.g_mobiledata_rounded,
                        iconColor: Colors.redAccent,
                        label: 'Continue with Google',
                        isPrimary: false,
                        isLoading: isLoading,
                        onPressed: () async {
                          await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                        },
                      ),
                      const SizedBox(height: 16),

                      // THIRD BUTTON: Apple Login
                      _AuthButton(
                        id: 'btn_apple_signin',
                        icon: Icons.apple_rounded,
                        iconColor: Colors.white,
                        label: 'Continue with Apple',
                        isPrimary: false,
                        isLoading: isLoading,
                        onPressed: () async {
                          await ref.read(authNotifierProvider.notifier).signInWithApple();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Terms and Security Guarantee
                const Text(
                  'End-to-End Encrypted • Verified Identity Network',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isPrimary = false,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        key: ValueKey(id),
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFB39D77) : const Color(0xFF1B2330),
          foregroundColor: isPrimary ? const Color(0xFF0A0D11) : const Color(0xFFFDFCF4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isPrimary ? const Color(0xFFD9C394) : const Color(0xFF2D3748),
            ),
          ),
          elevation: isPrimary ? 2 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          children: [
            Icon(icon, color: isPrimary ? const Color(0xFF0A0D11) : iconColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? const Color(0xFF0A0D11) : const Color(0xFFFDFCF4),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isPrimary ? const Color(0xFF0A0D11).withValues(alpha: 0.6) : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
