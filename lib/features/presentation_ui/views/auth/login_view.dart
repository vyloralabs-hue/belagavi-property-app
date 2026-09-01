import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../theme/app_design_system.dart';

/// Supported Country Dial Codes for International Expansion
class CountryDialCode {
  final String name;
  final String code;
  final String flag;
  final int minLength;
  final int maxLength;

  const CountryDialCode({
    required this.name,
    required this.code,
    required this.flag,
    this.minLength = 10,
    this.maxLength = 10,
  });
}

const List<CountryDialCode> kSupportedCountryCodes = [
  CountryDialCode(name: 'India', code: '+91', flag: '🇮🇳', minLength: 10, maxLength: 10),
  CountryDialCode(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪', minLength: 9, maxLength: 9),
  CountryDialCode(name: 'United States / Canada', code: '+1', flag: '🇺🇸', minLength: 10, maxLength: 10),
  CountryDialCode(name: 'United Kingdom', code: '+44', flag: '🇬🇧', minLength: 10, maxLength: 11),
  CountryDialCode(name: 'Singapore', code: '+65', flag: '🇸🇬', minLength: 8, maxLength: 8),
  CountryDialCode(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦', minLength: 9, maxLength: 9),
  CountryDialCode(name: 'Australia', code: '+61', flag: '🇦🇺', minLength: 9, maxLength: 10),
  CountryDialCode(name: 'Qatar', code: '+974', flag: '🇶🇦', minLength: 8, maxLength: 8),
  CountryDialCode(name: 'Germany', code: '+49', flag: '🇩🇪', minLength: 10, maxLength: 11),
];

/// Mobile Login Screen — Enters phone number with selectable country code then dispatches OTP
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  CountryDialCode _selectedCountry = kSupportedCountryCodes.first;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp(String? redirectParam) async {
    final rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (rawPhone.length < _selectedCountry.minLength || rawPhone.length > _selectedCountry.maxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid ${_selectedCountry.minLength}-digit mobile number for ${_selectedCountry.name}.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final fullE164Phone = '${_selectedCountry.code}$rawPhone';
    await ref.read(authNotifierProvider.notifier).sendOtp(fullE164Phone);

    final currentAuthState = ref.read(authNotifierProvider);
    if (currentAuthState is AuthError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentAuthState.message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (mounted) {
      final route = redirectParam != null
          ? '/otp-verification?redirect=${Uri.encodeComponent(redirectParam)}'
          : '/otp-verification';
      context.go(route, extra: fullE164Phone);
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

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFDFCF4), size: 20),
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFB39D77), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.phone_android_rounded, size: 36, color: Color(0xFFB39D77)),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Mobile Verification',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDFCF4),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We will send a 6-digit one-time code (OTP) to your phone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 32),

                // Input Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2D3748)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Country Code Selector + Phone Field
                      Row(
                        children: [
                          // Country Code Dropdown Button
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2330),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CountryDialCode>(
                                value: _selectedCountry,
                                dropdownColor: const Color(0xFF1B2330),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB39D77), size: 18),
                                items: kSupportedCountryCodes.map((c) {
                                  return DropdownMenuItem<CountryDialCode>(
                                    value: c,
                                    child: Text(
                                      '${c.flag} ${c.code}',
                                      style: const TextStyle(
                                        fontFamily: AppDesignSystem.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFDFCF4),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCountry = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Phone Number Input
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: TextField(
                                key: const ValueKey('input_mobile_number'),
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
                                ],
                                style: const TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFDFCF4),
                                  letterSpacing: 1.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter phone number',
                                  hintStyle: const TextStyle(
                                    fontFamily: AppDesignSystem.fontFamily,
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1B2330),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF334155)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF334155)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFB39D77), width: 1.5),
                                  ),
                                ),
                                onSubmitted: (_) => _sendOtp(redirectParam),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SEND OTP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          key: const ValueKey('btn_send_otp'),
                          onPressed: isLoading ? null : () => _sendOtp(redirectParam),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB39D77),
                            foregroundColor: const Color(0xFF0A0D11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0D11)),
                                )
                              : const Text(
                                  'Send OTP',
                                  style: TextStyle(
                                    fontFamily: AppDesignSystem.fontFamily,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => context.go('/auth'),
                  child: const Text(
                    '← Back to Sign In options',
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
}
