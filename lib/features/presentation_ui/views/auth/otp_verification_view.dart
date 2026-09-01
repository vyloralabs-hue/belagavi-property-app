import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../theme/app_design_system.dart';

/// OTP Verification Screen — Production Grade
/// Clean masked phone header, 6-digit PIN grid, Resend timer, Change Number, Firebase verification.
class OtpVerificationView extends ConsumerStatefulWidget {
  final String mobileNumber;

  const OtpVerificationView({
    super.key,
    this.mobileNumber = '+91 98765 43210',
  });

  @override
  ConsumerState<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getMaskedPhone(String rawPhone) {
    if (rawPhone.length < 6) return rawPhone;
    final prefix = rawPhone.substring(0, rawPhone.length > 5 ? 4 : 2);
    final suffix = rawPhone.substring(rawPhone.length - 4);
    return '$prefix ******$suffix';
  }

  Future<void> _verifyOtp() async {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit verification code.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(authNotifierProvider.notifier).verifyOtp(
          phoneNumber: widget.mobileNumber,
          otpToken: pin,
        );
  }

  Future<void> _resendCode() async {
    if (_secondsRemaining > 0) return;
    _startTimer();
    await ref.read(authNotifierProvider.notifier).sendOtp(widget.mobileNumber);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New verification code sent successfully.'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? redirectParam;
    try {
      redirectParam = GoRouterState.of(context).uri.queryParameters['redirect'];
    } catch (_) {
      redirectParam = null;
    }

    final formattedTimer = '00:${_secondsRemaining.toString().padLeft(2, '0')}';
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is Authenticated) {
        if (redirectParam != null && redirectParam.isNotEmpty) {
          context.go(redirectParam);
        } else {
          context.go('/home');
        }
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapErrorMessage(next.message)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFDFCF4), size: 20),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFB39D77), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_clock_rounded, size: 36, color: Color(0xFFB39D77)),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDFCF4),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'OTP sent to ${_getMaskedPhone(widget.mobileNumber)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 32),

                // 6-digit PIN Box Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 46,
                      height: 54,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        key: ValueKey('otp_box_$index'),
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFDFCF4),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFF1B2330),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFB39D77), width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (index == 5 && value.isNotEmpty) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                // Resend Timer & Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _secondsRemaining > 0 ? 'Resend code in $formattedTimer' : 'Didn\'t receive code?',
                      style: const TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    if (_secondsRemaining == 0) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _resendCode,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB39D77),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),

                // VERIFY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    key: const ValueKey('btn_verify_otp'),
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB39D77),
                      foregroundColor: const Color(0xFF0A0D11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0D11)),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Change Number Button
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Change Mobile Number',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapErrorMessage(String rawMessage) {
    final lower = rawMessage.toLowerCase();
    if (lower.contains('invalid') && lower.contains('code')) {
      return 'Invalid verification code. Please check and try again.';
    }
    if (lower.contains('expired')) {
      return 'Verification code has expired. Please request a new OTP.';
    }
    if (lower.contains('too-many') || lower.contains('quota')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }
    if (lower.contains('network') || lower.contains('socket') || lower.contains('connection')) {
      return 'Network problem. Please check your internet connection.';
    }
    return rawMessage;
  }
}
