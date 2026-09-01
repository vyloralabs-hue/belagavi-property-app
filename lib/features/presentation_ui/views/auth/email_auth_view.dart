import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../theme/app_design_system.dart';

class EmailAuthView extends ConsumerStatefulWidget {
  const EmailAuthView({super.key});
  @override
  ConsumerState<EmailAuthView> createState() => _EmailAuthViewState();
}

class _EmailAuthViewState extends ConsumerState<EmailAuthView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInEmailCtrl = TextEditingController();
  final _signInPasswordCtrl = TextEditingController();
  bool _signInObscure = true;
  String? _signInError;
  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPasswordCtrl = TextEditingController();
  final _signUpConfirmCtrl = TextEditingController();
  bool _signUpObscure = true;
  String? _signUpError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailCtrl.dispose();
    _signInPasswordCtrl.dispose();
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPasswordCtrl.dispose();
    _signUpConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _signInError = null);
    final email = _signInEmailCtrl.text.trim();
    final password = _signInPasswordCtrl.text;
    if (email.isEmpty || !email.contains("@")) {
      setState(() => _signInError = "Please enter a valid email address.");
      return;
    }
    if (password.length < 6) {
      setState(() => _signInError = "Password must be at least 6 characters.");
      return;
    }
    await ref
        .read(authNotifierProvider.notifier)
        .signInWithEmail(email: email, password: password);
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController();
    String? errorMsg;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF131922),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDFCF4),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email address and we will send you a reset link.',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 20),
                if (errorMsg != null) ...[
                  _ErrorBanner(message: errorMsg!),
                  const SizedBox(height: 12),
                ],
                _DarkTextField(
                  controller: emailCtrl,
                  label: 'Email Address',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setModalState(() => errorMsg = null),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    key: const ValueKey('btn_send_reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB39037),
                      foregroundColor: const Color(0xFF0A0D11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final em = emailCtrl.text.trim();
                      if (em.isEmpty || !em.contains('@')) {
                        setModalState(
                          () =>
                              errorMsg = 'Please enter a valid email address.',
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      await ref
                          .read(authNotifierProvider.notifier)
                          .sendPasswordResetEmail(em);
                    },
                    child: const Text(
                      'Send Reset Email',
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
          );
        },
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() => _signUpError = null);
    final name = _signUpNameCtrl.text.trim();
    final email = _signUpEmailCtrl.text.trim();
    final password = _signUpPasswordCtrl.text;
    final confirm = _signUpConfirmCtrl.text;
    if (name.isEmpty) {
      setState(() => _signUpError = "Please enter your full name.");
      return;
    }
    if (email.isEmpty || !email.contains("@")) {
      setState(() => _signUpError = "Please enter a valid email address.");
      return;
    }
    if (password.length < 6) {
      setState(() => _signUpError = "Password must be at least 6 characters.");
      return;
    }
    if (password != confirm) {
      setState(() => _signUpError = "Passwords do not match.");
      return;
    }
    await ref
        .read(authNotifierProvider.notifier)
        .signUpWithEmail(email: email, password: password, displayName: name);
  }

  @override
  Widget build(BuildContext context) {
    final redirectParam = GoRouterState.of(
      context,
    ).uri.queryParameters['redirect'];
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is Authenticated && mounted) {
        if (redirectParam != null && redirectParam.isNotEmpty) {
          context.go(redirectParam);
        } else {
          context.go("/home");
        }
      } else if (next is AuthPasswordResetSent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset email sent. Please check your inbox.',
            ),
            backgroundColor: Color(0xFF1B4332),
            duration: Duration(seconds: 4),
          ),
        );
        _tabController.animateTo(0);
      } else if (next is AuthError) {
        if (_tabController.index == 0) {
          setState(() => _signInError = next.message);
        } else {
          setState(() => _signUpError = next.message);
        }
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFFDFCF4),
          ),
          onPressed: () => context.go("/auth"),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFB39037)),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 40,
                    color: Color(0xFFB39037),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "BELAGAVI PROPERTY",
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB39037),
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 460),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131922),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x40B39037)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x60000000),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2330),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFFB39037),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          labelColor: const Color(0xFF0A0D11),
                          unselectedLabelColor: const Color(0xFF94A3B8),
                          tabs: const [
                            Tab(text: "Sign In"),
                            Tab(text: "Sign Up"),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 420,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSignInTab(isLoading),
                            _buildSignUpTab(isLoading),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.go("/auth"),
                  child: const Text(
                    "Back to Login Options",
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
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

  Widget _buildSignInTab(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_signInError != null) ...[
            _ErrorBanner(message: _signInError!),
            const SizedBox(height: 12),
          ],
          _DarkTextField(
            key: const ValueKey("signin_email"),
            controller: _signInEmailCtrl,
            label: "Email Address",
            hint: "you@example.com",
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() => _signInError = null),
          ),
          const SizedBox(height: 14),
          _DarkTextField(
            key: const ValueKey("signin_password"),
            controller: _signInPasswordCtrl,
            label: "Password",
            hint: "Min 6 characters",
            obscureText: _signInObscure,
            suffixIcon: IconButton(
              icon: Icon(
                _signInObscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: () => setState(() => _signInObscure = !_signInObscure),
            ),
            onChanged: (_) => setState(() => _signInError = null),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const ValueKey("btn_email_login"),
              onPressed: isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB39037),
                foregroundColor: const Color(0xFF0A0D11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF0A0D11),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const ValueKey('btn_forgot_password'),
            onPressed: isLoading ? null : _forgotPassword,
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 13,
                color: Color(0xFFB39037),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_signUpError != null) ...[
            _ErrorBanner(message: _signUpError!),
            const SizedBox(height: 10),
          ],
          _DarkTextField(
            key: const ValueKey("signup_name"),
            controller: _signUpNameCtrl,
            label: "Full Name",
            hint: "Rahul Sharma",
            onChanged: (_) => setState(() => _signUpError = null),
          ),
          const SizedBox(height: 10),
          _DarkTextField(
            key: const ValueKey("signup_email"),
            controller: _signUpEmailCtrl,
            label: "Email Address",
            hint: "you@example.com",
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() => _signUpError = null),
          ),
          const SizedBox(height: 10),
          _DarkTextField(
            key: const ValueKey("signup_password"),
            controller: _signUpPasswordCtrl,
            label: "Password",
            hint: "Min 6 characters",
            obscureText: _signUpObscure,
            suffixIcon: IconButton(
              icon: Icon(
                _signUpObscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: () => setState(() => _signUpObscure = !_signUpObscure),
            ),
            onChanged: (_) => setState(() => _signUpError = null),
          ),
          const SizedBox(height: 10),
          _DarkTextField(
            key: const ValueKey("signup_confirm"),
            controller: _signUpConfirmCtrl,
            label: "Confirm Password",
            hint: "Re-enter password",
            obscureText: _signUpObscure,
            onChanged: (_) => setState(() => _signUpError = null),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const ValueKey("btn_email_signup"),
              onPressed: isLoading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB39037),
                foregroundColor: const Color(0xFF0A0D11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF0A0D11),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Create Account",
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1212),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x80FF5252)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 12,
                color: Color(0xFFFCA5A5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  const _DarkTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 14,
            color: Color(0xFFFDFCF4),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 13),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF1B2330),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFB39037),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
