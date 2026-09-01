import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

/// Welcome Screen — Master Design Blueprint
/// Dark Canvas #0A0D11, "DISCOVER EXTRAORDINARY LIVING IN BELAGAVI"
/// Hero Villa Image, "Explore Now" Gold CTA
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        // Header logo & wordmark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131922),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFB39037)),
                              ),
                              child: const Icon(Icons.apartment_rounded, color: Color(0xFFB39037), size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'BELAGAVI PROPERTY',
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFDFCF4),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Main Headline
                        const Text(
                          'DISCOVER\nEXTRAORDINARY\nLIVING IN BELAGAVI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFDFCF4),
                            letterSpacing: 1.2,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Hero House Image Card
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 240),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF131922),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFB39037).withValues(alpha: 0.4)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x60000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF1B2330),
                                        const Color(0xFF0A0D11).withValues(alpha: 0.9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.home_work_rounded,
                                      size: 110,
                                      color: Color(0xFFB39037),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 24,
                                  right: 24,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: () => context.push('/auth'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFB39037),
                                            foregroundColor: const Color(0xFF0A0D11),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            elevation: 4,
                                          ),
                                          child: const Text(
                                            'Explore Now',
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'The Smart Way to\nFind, Buy or Rent your Dream Property',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
