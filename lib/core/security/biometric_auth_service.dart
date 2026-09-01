import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/app_logger.dart';

class BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Check if the physical device supports biometric hardware and has enrolled biometrics
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool available = canCheckBiometrics || isDeviceSupported;
      AppLogger.i('[Biometric] Availability check: canCheck=$canCheckBiometrics, supported=$isDeviceSupported, available=$available');
      return available;
    } on PlatformException catch (e) {
      AppLogger.w('[Biometric] PlatformException during availability check: ${e.message}');
      return false;
    } catch (e) {
      AppLogger.w('[Biometric] Error during availability check: $e');
      return false;
    }
  }

  /// Get list of available biometric types on this hardware
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.w('[Biometric] Could not retrieve available biometrics: $e');
      return const [];
    }
  }

  /// Request native biometric authentication prompt
  Future<bool> authenticate({
    String localizedReason = 'Scan your fingerprint or face to authenticate',
  }) async {
    try {
      final bool available = await isBiometricAvailable();
      if (!available) {
        AppLogger.w('[Biometric] Hardware/enrollment unavailable for authentication prompt.');
        return false;
      }

      AppLogger.i('[Biometric] Displaying native OS biometric prompt...');
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      AppLogger.i('[Biometric] Native prompt result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      AppLogger.e('[Biometric] PlatformException during native prompt: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.e('[Biometric] Unexpected error during native prompt: $e');
      return false;
    }
  }
}
