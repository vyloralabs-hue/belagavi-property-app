import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

/// Theme Selection Screen (Screen 7) — Official Navigation Flow
class ThemeSelectionView extends StatefulWidget {
  const ThemeSelectionView({super.key});

  @override
  State<ThemeSelectionView> createState() => _ThemeSelectionViewState();
}

class _ThemeSelectionViewState extends State<ThemeSelectionView> {
  String _selected = 'dark';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              const Text(
                'Choose Your\nDisplay Theme',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFDFCF4),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select how you want Belagavi Property to look.\nYou can always change this later in Settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Theme Options
              Row(
                children: [
                  Expanded(
                    child: _ThemeCard(
                      id: 'card_dark_theme',
                      label: 'Dark Mode',
                      subtitle: 'Premium Luxury',
                      icon: Icons.dark_mode_rounded,
                      isSelected: _selected == 'dark',
                      bgColor: const Color(0xFF0A0D11),
                      textColor: const Color(0xFFB39D77),
                      borderColor: const Color(0xFFB39D77),
                      onTap: () => setState(() => _selected = 'dark'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ThemeCard(
                      id: 'card_light_theme',
                      label: 'Light Mode',
                      subtitle: 'Clean & Bright',
                      icon: Icons.light_mode_rounded,
                      isSelected: _selected == 'light',
                      bgColor: const Color(0xFFFDFCF4),
                      textColor: const Color(0xFF131922),
                      borderColor: const Color(0xFF131922),
                      onTap: () => setState(() => _selected = 'light'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // System Default
              _ThemeCardWide(
                id: 'card_system_theme',
                label: 'System Default',
                subtitle: 'Follow your device settings automatically',
                icon: Icons.settings_brightness_rounded,
                isSelected: _selected == 'system',
                onTap: () => setState(() => _selected = 'system'),
              ),
              const Spacer(flex: 2),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  key: const ValueKey('btn_theme_continue'),
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB39D77),
                    foregroundColor: const Color(0xFF0A0D11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Continue to Dashboard',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(id),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 140,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB39D77)
                : const Color(0xFF2D3748),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x40B39D77),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFB39D77) : textColor,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isSelected ? const Color(0xFFB39D77) : textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFFD9C394)
                    : textColor.withValues(alpha: 0.6),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFB39D77),
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeCardWide extends StatelessWidget {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCardWide({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(id),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF131922),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB39D77)
                : const Color(0xFF2D3748),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x40B39D77),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFB39D77)
                  : const Color(0xFF94A3B8),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isSelected
                          ? const Color(0xFFB39D77)
                          : const Color(0xFFFDFCF4),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFB39D77),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
