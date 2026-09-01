import 'package:flutter/material.dart';
import '../domain/entities/admin_entities.dart';

class DynamicBrandingThemeHelper {
  DynamicBrandingThemeHelper._();

  /// Converts hex color string (e.g. '#1E3A8A') into Flutter Color
  static Color parseColor(String hexString, Color fallback) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  /// Builds dynamic ThemeData from PlatformBrandingEntity
  static ThemeData buildTheme(PlatformBrandingEntity branding) {
    final primary = parseColor(branding.primaryColorHex, const Color(0xFF1E3A8A));
    final secondary = parseColor(branding.secondaryColorHex, const Color(0xFF0D9488));

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        secondary: secondary,
      ),
    );
  }
}
