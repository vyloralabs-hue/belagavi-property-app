import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_design_system.dart';

/// Main Navigation Shell — Production Dual-Theme Architecture
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// 5 tabs: Home, Search, Post (Elevated Center Gold CTA), Listings, Profile
class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final scaffoldBg = AppDesignSystem.backgroundPrimary(context);
    final isDark = AppDesignSystem.isDark(context);
    final surfaceBg = isDark ? const Color(0xFF0A0E17) : Colors.white;
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final currentIndex = navigationShell.currentIndex;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: surfaceBg,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _onTap(context, index),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: AppDesignSystem.brandGold),
              unselectedIconTheme: IconThemeData(color: textS),
              selectedLabelTextStyle: const TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                color: AppDesignSystem.brandGold,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                color: textS,
                fontSize: 12,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: Text('Post'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.apartment_outlined),
                  selectedIcon: Icon(Icons.apartment_rounded),
                  label: Text('Listings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
            VerticalDivider(thickness: 1, width: 1, color: borderCol),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          navigationShell,

          // Center floating Post Property pill button (matching reference images)
          if (currentIndex == 0)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _onTap(context, 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC5A059), Color(0xFFD4AF37), Color(0xFFB39037)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB39037).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Color(0xFF0F172A),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Post Property',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceBg,
          boxShadow: AppDesignSystem.navShadow,
          border: Border(
            top: BorderSide(color: borderCol, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search_rounded,
                  label: 'Search',
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.add_circle_outline_rounded,
                  activeIcon: Icons.add_circle_rounded,
                  label: 'Post',
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.apartment_outlined,
                  activeIcon: Icons.apartment_rounded,
                  label: 'Listings',
                  isSelected: currentIndex == 3,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    final textS = AppDesignSystem.textS(context);

    return InkWell(
      onTap: () => _onTap(context, index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? AppDesignSystem.brandGold : textS,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppDesignSystem.brandGold : textS,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
