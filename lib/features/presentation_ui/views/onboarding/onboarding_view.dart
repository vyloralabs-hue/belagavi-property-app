import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';
import 'onboarding_storage_helper.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingItem> _slides = [
    OnboardingItem(
      title: 'Welcome to Belagavi Property',
      description:
          'The principal real estate platform for Belagavi and surrounding districts.',
      icon: Icons.apartment,
      accentColor: AppDesignSystem.primaryNavy,
    ),
    OnboardingItem(
      title: 'Discover RERA Properties',
      description:
          'Explore verified residential homes, commercial spaces, plots and agricultural lands.',
      icon: Icons.verified_user,
      accentColor: AppDesignSystem.accentEmerald,
    ),
    OnboardingItem(
      title: 'Verified Land & Property Titles',
      description:
          'Dedicated legal due diligence, 7/12 land document records, and dispute transparency.',
      icon: Icons.policy_rounded,
      accentColor: Color(0xFF7C3AED),
    ),
    OnboardingItem(
      title: 'Business CRM & Kanban',
      description:
          'Dedicated 5-stage sales pipeline for Brokers, Builders, and Team Members.',
      icon: Icons.dashboard_customize,
      accentColor: Color(0xFFD97706),
    ),
    OnboardingItem(
      title: 'Bank-Grade Security',
      description:
          'Encrypted document verification, Row-Level Security, and automated threat monitoring.',
      icon: Icons.security,
      accentColor: Color(0xFF2563EB),
    ),
    OnboardingItem(
      title: 'Ready to Explore?',
      description:
          'Find your dream property or start managing real estate leads today.',
      icon: Icons.rocket_launch,
      accentColor: AppDesignSystem.primaryNavy,
    ),
  ];

  Future<void> _finishOnboarding() async {
    await OnboardingStorageHelper.markCompleted();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isLast)
            TextButton(
              onPressed: _finishOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppDesignSystem.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: slide.accentColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 80,
                            color: slide.accentColor,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppDesignSystem.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppDesignSystem.primaryNavy
                              : AppDesignSystem.borderSubtle,
                          borderRadius: AppDesignSystem.borderRadiusPill,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.primaryNavy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDesignSystem.borderRadiusPill,
                      ),
                    ),
                    onPressed: () {
                      if (isLast) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      isLast ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
