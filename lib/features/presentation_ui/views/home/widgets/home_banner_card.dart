import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

/// Hero Banner Card — Master Design Blueprint
/// Luxury Property Hero Banner with "Find Your Dream Property in Belagavi", "Buy • Rent • Invest", and "Explore Now"
class HomeBannerCard extends StatelessWidget {
  const HomeBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 195,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFB39037).withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: AppDesignSystem.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Villa / Property Graphic Background on right
              Positioned(
                right: -20,
                top: -20,
                bottom: -20,
                width: 240,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.4, -0.2),
                      radius: 0.9,
                      colors: [
                        const Color(0xFFB39037).withValues(alpha: 0.25),
                        const Color(0xFF0F172A).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.villa_rounded,
                      size: 150,
                      color: const Color(0xFFB39037).withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),

              // Gradient Overlay for text legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A),
                      const Color(0xFF0F172A).withValues(alpha: 0.92),
                      const Color(0xFF0F172A).withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              // Content Layout
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Find Your',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFCBD5E1),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Dream ',
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFDFCF4),
                                  height: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: 'Property\n',
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD9C394),
                                  height: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: 'in Belagavi',
                                style: TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFDFCF4),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Buy • Rent • Invest',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Explore Now Button
                        GestureDetector(
                          onTap: () => context.go('/search'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppDesignSystem.brandGold,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40B39037),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Explore Now',
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        // Carousel Indicator Dots
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppDesignSystem.brandGold,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF475569),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
