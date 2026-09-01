import 'package:flutter/material.dart';

/// Official Master Design Specification Sheet — Belagavi Property
/// Dual-Theme Aware Design System (Light & Dark Mode)
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
abstract class AppDesignSystem {
  AppDesignSystem._();

  // ─── Brand Accents (Consistent across Light and Dark) ───────────────────
  static const Color brandGold = Color(0xFFC5A059);         // Champagne Gold
  static const Color brandGoldDeep = Color(0xFFB39037);     // Rich Deep Gold
  static const Color brandGoldMuted = Color(0xFFD9C394);    // Muted Gold
  static const Color brandGoldLight = Color(0xFFFEF3C7);    // Light Gold Tint
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color badgeTextGold = Color(0xFFC5A059);
  static const Color badgeBgGold = Color(0x20B39037);

  // ─── Legacy Static Neutral Surfaces & Aliases ───────────────────────────
  static const Color primaryNavy = Color(0xFF0A0D11);
  static const Color backgroundWhite = Color(0xFF0A0D11);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderGold = Color(0xFFB39037);

  // ─── Functional Semantic Status Tokens ─────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color disputeWarning = Color(0xFFE11D48);

  // ─── Dark Mode Specific Tokens (Reference Image 2) ─────────────────────
  static const Color bgDarkPrimary = Color(0xFF0A0E17);      // Deep Ink Canvas
  static const Color bgDarkSecondary = Color(0xFF0F172A);    // Secondary Navy
  static const Color surfaceDarkPrimary = Color(0xFF131B2A); // Elevated Dark Card
  static const Color surfaceDarkElevated = Color(0xFF1A2436);// Higher Elevation
  static const Color textDarkPrimary = Color(0xFFF8FAFC);    // Warm Off-White
  static const Color textDarkSecondary = Color(0xFF94A3B8);  // Slate Grey
  static const Color borderDarkSubtle = Color(0xFF222E42);   // Subtle Navy Border

  // ─── Light Mode Specific Tokens (Reference Image 1) ────────────────────
  static const Color bgLightPrimary = Color(0xFFF8F9FA);     // Warm Ivory Canvas
  static const Color bgLightSecondary = Color(0xFFFFFFFF);   // Pure White
  static const Color surfaceLightPrimary = Color(0xFFFFFFFF);// Clean White Surface
  static const Color surfaceLightElevated = Color(0xFFFFFFFF);
  static const Color textLightPrimary = Color(0xFF0F172A);   // Deep Navy Text
  static const Color textLightSecondary = Color(0xFF64748B); // Muted Slate Text
  static const Color borderLightSubtle = Color(0xFFE2E8F0);  // Subtle Light Border

  // ─── Typography ────────────────────────────────────────────────────────
  static const String fontFamily = 'Roboto';

  // ─── Theme-Aware Helper Methods ─────────────────────────────────────────
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color backgroundPrimary(BuildContext context) =>
      isDark(context) ? bgDarkPrimary : bgLightPrimary;

  static Color backgroundSecondary(BuildContext context) =>
      isDark(context) ? bgDarkSecondary : bgLightSecondary;

  static Color surfacePrimary(BuildContext context) =>
      isDark(context) ? surfaceDarkPrimary : surfaceLightPrimary;

  static Color surfaceElevated(BuildContext context) =>
      isDark(context) ? surfaceDarkElevated : surfaceLightElevated;

  static Color textPrimaryTheme(BuildContext context) =>
      isDark(context) ? textDarkPrimary : textLightPrimary;

  static Color textSecondaryTheme(BuildContext context) =>
      isDark(context) ? textDarkSecondary : textLightSecondary;

  static Color borderSubtleTheme(BuildContext context) =>
      isDark(context) ? borderDarkSubtle : borderLightSubtle;

  // ─── Standard Shorthands ─────────────────────────────────────────
  static Color scaffoldBg(BuildContext context) => backgroundPrimary(context);
  static Color surfaceBg(BuildContext context) => surfacePrimary(context);
  static Color cardBg(BuildContext context) => surfacePrimary(context);
  static Color inputBg(BuildContext context) =>
      isDark(context) ? surfaceDarkElevated : Colors.white;
  static Color textP(BuildContext context) => textPrimaryTheme(context);
  static Color textS(BuildContext context) => textSecondaryTheme(context);
  static Color borderCol(BuildContext context) => borderSubtleTheme(context);

  // ─── Metallic Gold Gradients ────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC5A059), Color(0xFFE5C88B), Color(0xFFB39037)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF131B2A), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient investCardGradient = LinearGradient(
    colors: [Color(0xFF0D1420), Color(0xFF131B2A), Color(0xFF1A2436)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ────────────────────────────────────────────────────────────
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x25C5A059),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> navShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 14,
      offset: Offset(0, -3),
    ),
  ];

  // ─── Border Radii ───────────────────────────────────────────────────────
  static const BorderRadius borderRadiusS = BorderRadius.all(Radius.circular(8));
  static const BorderRadius borderRadiusM = BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadiusL = BorderRadius.all(Radius.circular(16));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(20));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(50));
}
