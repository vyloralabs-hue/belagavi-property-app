import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

/// Location Permission Screen (Screen 6) — Official Navigation Flow
class LocationPermissionView extends StatelessWidget {
  const LocationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Location Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF131922),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFB39D77), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x40B39D77), blurRadius: 24, spreadRadius: 4),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.location_on_rounded, size: 52, color: Color(0xFFB39D77)),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Enable Location\nAccess',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFDFCF4),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Allow Belagavi Property to access your location to show nearby properties, projects, and local market insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              // Benefits list
              _buildBenefit(Icons.search_rounded, 'Discover properties near you'),
              const SizedBox(height: 12),
              _buildBenefit(Icons.map_rounded, 'View properties on an interactive map'),
              const SizedBox(height: 12),
              _buildBenefit(Icons.trending_up_rounded, 'Get local market price insights'),
              const Spacer(flex: 2),
              // Allow Button (Gold)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  key: const ValueKey('btn_allow_location'),
                  onPressed: () => context.go('/theme-selection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB39D77),
                    foregroundColor: const Color(0xFF0A0D11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Allow Location Access',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Skip Button
              TextButton(
                onPressed: () => context.go('/theme-selection'),
                child: const Text(
                  'Skip for Now',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
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

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2330),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFB39D77), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 14,
              color: Color(0xFFFDFCF4),
            ),
          ),
        ),
      ],
    );
  }
}
