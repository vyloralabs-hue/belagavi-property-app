/// Utility class for common input validators used across the platform.
/// All validators return a [String] error message or [null] if the value is valid.
class AppValidators {
  AppValidators._();

  // ─── Phone ────────────────────────────────────────────────────────────────

  /// Validates a 10-digit Indian mobile number (without country code).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid 10-digit Indian mobile number.';
    }
    return null;
  }

  // ─── OTP ─────────────────────────────────────────────────────────────────

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required.';
    if (value.trim().length != 6 || !RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit OTP.';
    }
    return null;
  }

  // ─── Email ────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email address is required.';
    if (!RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$')
        .hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return email(value);
  }

  // ─── Name ─────────────────────────────────────────────────────────────────

  static String? name(String? value, {String label = 'Name'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    if (value.trim().length < 2) return '$label must be at least 2 characters.';
    if (value.trim().length > 100) return '$label must be under 100 characters.';
    return null;
  }

  // ─── Price ───────────────────────────────────────────────────────────────

  static String? price(String? value, {String label = 'Price'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) return 'Enter a valid $label.';
    return null;
  }

  // ─── Required text ────────────────────────────────────────────────────────

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  // ─── PIN Code ─────────────────────────────────────────────────────────────

  static String? pinCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'PIN code is required.';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit PIN code.';
    }
    return null;
  }
}
