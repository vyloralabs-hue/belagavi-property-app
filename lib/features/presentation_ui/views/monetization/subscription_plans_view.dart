import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

class SubscriptionPlansView extends StatefulWidget {
  const SubscriptionPlansView({super.key});

  @override
  State<SubscriptionPlansView> createState() => _SubscriptionPlansViewState();
}

class _SubscriptionPlansViewState extends State<SubscriptionPlansView> {
  int _selectedPlanIndex = 1; // Default to Standard Plan

  static const List<Map<String, dynamic>> _plans = [
    {
      'title': 'Basic Plan',
      'price': '₹299',
      'period': '/ Month',
      'features': [
        '10 Property Listings',
        'Standard Search Visibility',
        'Basic Lead Alerts',
        'Email Support',
      ],
      'popular': false,
    },
    {
      'title': 'Standard Plan',
      'price': '₹599',
      'period': '/ Month',
      'features': [
        '30 Property Listings',
        'Priority RERA Badge Placement',
        'Instant WhatsApp & SMS Lead Alerts',
        'Featured Boost for 3 Listings',
        '24/7 Dedicated Support',
      ],
      'popular': true,
      'badge': 'MOST POPULAR',
    },
    {
      'title': 'Premium Plan',
      'price': '₹999',
      'period': '/ Month',
      'features': [
        'Unlimited Property Listings',
        'Top Search Ranking & Homepage Banner',
        'CRM & Lead Pipeline Access',
        'Featured Boost for 10 Listings',
        'Verified Builder Badge',
        'Personal Account Manager',
      ],
      'popular': false,
      'badge': 'BEST VALUE',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFDFCF4)),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: const Text(
          'Subscriptions & Membership',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFDFCF4),
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Membership Plan',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFDFCF4),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlock premium listing features, lead boosts, and verified buyer inquiries across Belagavi.',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 13,
                  color: Color(0xFFD9C394),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              ...List.generate(_plans.length, (index) {
                final plan = _plans[index];
                final isSelected = _selectedPlanIndex == index;
                final bool isPopular = plan['popular'] as bool;
                final String? badgeText = plan['badge'] as String?;

                return _MembershipCard(
                  title: plan['title'] as String,
                  price: plan['price'] as String,
                  period: plan['period'] as String,
                  features: plan['features'] as List<String>,
                  isSelected: isSelected,
                  isPopular: isPopular,
                  badgeText: badgeText,
                  onSelect: () => setState(() => _selectedPlanIndex = index),
                  onSubscribe: () {
                    HapticFeedback.lightImpact();
                    context.push('/payment', extra: {
                      'planName': plan['title'],
                      'amount': plan['price'],
                    });
                  },
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipCard extends StatefulWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isSelected;
  final bool isPopular;
  final String? badgeText;
  final VoidCallback onSelect;
  final VoidCallback onSubscribe;

  const _MembershipCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isSelected,
    required this.isPopular,
    required this.badgeText,
    required this.onSelect,
    required this.onSubscribe,
  });

  @override
  State<_MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<_MembershipCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onSelect();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white, // Crisp White Card Fill
            borderRadius: BorderRadius.circular(24), // 24px Rounded Corners
            border: Border.all(
              color: widget.isSelected ? const Color(0xFFB39037) : const Color(0xFFE2E8F0),
              width: widget.isSelected ? 2.5 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x40B39037),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: Offset(0, 6),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge & Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0D11), // High Contrast Dark Title
                    ),
                  ),
                  if (widget.badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB39037),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0D11),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Price Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0D11), // High Contrast Dark Price
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.period,
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB39037), // Rich Gold Period Accent
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              // Feature List
              ...widget.features.map((feat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Color(0xFF059669), // Emerald Green Check
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feat,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B), // High Contrast Dark Slate Feature Text
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Subscribe Now CTA Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isSelected ? const Color(0xFFB39037) : const Color(0xFF0A0D11),
                    foregroundColor: widget.isSelected ? const Color(0xFF0A0D11) : const Color(0xFFFDFCF4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
