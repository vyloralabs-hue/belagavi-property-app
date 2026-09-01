import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_design_system.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  static const List<Map<String, dynamic>> _actions = [
    {'title': 'Buy Property', 'icon': Icons.home, 'color': Color(0xFF2563EB)},
    {'title': 'Rent Property', 'icon': Icons.key, 'color': Color(0xFF059669)},
    {
      'title': 'Sell Property',
      'icon': Icons.add_business,
      'color': Color(0xFFD97706),
    },
    {
      'title': 'Builder Projects',
      'icon': Icons.domain,
      'color': Color(0xFF7C3AED),
    },
    {
      'title': 'Land Valuation',
      'icon': Icons.analytics,
      'color': Color(0xFFDC2626),
    },
    {
      'title': 'Broker Directory',
      'icon': Icons.badge,
      'color': Color(0xFF0891B2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final item = _actions[index];
              return InkWell(
                onTap: () => context.go('/search'),
                borderRadius: AppDesignSystem.borderRadiusM,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDesignSystem.borderRadiusM,
                    boxShadow: AppDesignSystem.softShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppDesignSystem.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
