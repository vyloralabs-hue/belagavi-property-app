import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../bootstrap/app_bootstrap.dart';
import '../../../../core/security/biometric_auth_service.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';

/// Belagavi Property — Official Startup & Welcome Screen
/// Renders the approved luxury Belagavi Property welcome visual full-screen
/// with smooth 2.5-second display duration and seamless session navigation.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  static const String _startupVisualAsset =
      'assets/branding/belagavi_welcome_startup.jpg';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _navigateToNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_startupVisualAsset), context);
  }

  Future<void> _navigateToNext() async {
    bool navigationDone = false;
    final stopwatch = Stopwatch()..start();

    try {
      const env = appFlavor ?? 'prod';
      // Initialize app services in background while welcome screen is displayed
      await AppBootstrap.instance
          .initialize(env)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint(
                'AppBootstrap timed out in SplashView; continuing with fallback.',
              );
            },
          );

      // Ensure the approved welcome visual is displayed for 2.5 seconds total
      final elapsed = stopwatch.elapsedMilliseconds;
      const targetDurationMs = 2500;
      if (elapsed < targetDurationMs) {
        await Future.delayed(
          Duration(milliseconds: targetDurationMs - elapsed),
        );
      }

      if (mounted && !navigationDone) {
        navigationDone = true;
        bool loggedIn = false;
        try {
          loggedIn = AuthSessionStorageHelper.isLoggedIn();
        } catch (e) {
          debugPrint('Auth check warning in SplashView: $e');
        }

        if (loggedIn) {
          final biometricEnabled =
              AuthSessionStorageHelper.isBiometricEnabled();
          final biometricAvailable = await BiometricAuthService()
              .isBiometricAvailable();
          if (biometricEnabled &&
              biometricAvailable &&
              !AuthSessionStorageHelper.isBiometricUnlocked()) {
            context.go('/biometric-unlock');
          } else {
            context.go('/home');
          }
        } else {
          context.go('/auth');
        }
      }
    } catch (e) {
      debugPrint('Error caught in SplashView _navigateToNext: $e');
    } finally {
      if (mounted && !navigationDone) {
        navigationDone = true;
        try {
          context.go('/auth');
        } catch (e) {
          debugPrint('Fallback navigation error in SplashView: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF070B12),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF070B12),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SizedBox.expand(
            child: Image.asset(
              _startupVisualAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                // High-fidelity fallback to ensure continuous experience
                return Container(
                  color: const Color(0xFF070B12),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/branding/belagavi_property_llp_app_icon.png',
                    width: 140,
                    height: 140,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
