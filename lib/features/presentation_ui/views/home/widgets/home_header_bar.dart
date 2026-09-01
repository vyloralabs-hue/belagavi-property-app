import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/config/app_brand_config.dart';
import '../../../theme/app_design_system.dart';

/// Top Bar for Home Screen — Production Dual-Theme Architecture
/// Reference: Image 1 (Light Mode) & Image 2 (Dark Mode)
/// Elements: Brand Monogram & Wordmark, Location Pill, Language Pill, Profile Avatar
class HomeHeaderBar extends ConsumerStatefulWidget {
  const HomeHeaderBar({super.key});

  @override
  ConsumerState<HomeHeaderBar> createState() => _HomeHeaderBarState();
}

class _HomeHeaderBarState extends ConsumerState<HomeHeaderBar> {
  String _selectedLocation = AppBrandConfig.defaultCity;
  String _selectedLanguage = 'EN';

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppDesignSystem.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Location',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppDesignSystem.textP(ctx),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppDesignSystem.textS(ctx), size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Browse real estate listings by city or region.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textS(ctx),
                ),
              ),
              const SizedBox(height: 16),
              ...AppBrandConfig.availableLocations.map((loc) {
                final isSelected = loc == _selectedLocation;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.location_on_rounded,
                    color: isSelected ? AppDesignSystem.brandGold : AppDesignSystem.textS(ctx),
                    size: 20,
                  ),
                  title: Text(
                    loc,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppDesignSystem.brandGold : AppDesignSystem.textP(ctx),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppDesignSystem.brandGold, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _selectedLocation = loc);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppDesignSystem.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppDesignSystem.textP(ctx),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppDesignSystem.textS(ctx), size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...AppBrandConfig.availableLanguages.map((lang) {
                final isSelected = lang['code'] == _selectedLanguage;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_rounded, size: 20, color: AppDesignSystem.brandGold),
                  title: Text(
                    '${lang['name']} (${lang['code']})',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppDesignSystem.brandGold : AppDesignSystem.textP(ctx),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppDesignSystem.brandGold, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang['code']!);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);
    final pillBg = isDark ? const Color(0xFF131B2A) : const Color(0xFFFFFFFF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Brand Emblem Monogram
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131B2A) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppDesignSystem.brandGold, width: 1.2),
            ),
            child: const Center(
              child: Icon(
                Icons.apartment_rounded,
                size: 20,
                color: AppDesignSystem.brandGold,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Brand Wordmark
          Expanded(
            child: Text(
              AppBrandConfig.brandName,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textP,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Location Selector Pill
          GestureDetector(
            onTap: () => _showLocationPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol, width: 1),
                boxShadow: isDark ? null : AppDesignSystem.softShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: AppDesignSystem.brandGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedLocation,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textP,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: AppDesignSystem.textS(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Language Selector Pill
          GestureDetector(
            onTap: () => _showLanguagePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol, width: 1),
                boxShadow: isDark ? null : AppDesignSystem.softShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language_rounded,
                    size: 13,
                    color: AppDesignSystem.brandGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedLanguage,
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textP,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: AppDesignSystem.textS(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Profile / Account Button
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: pillBg,
                shape: BoxShape.circle,
                border: Border.all(color: borderCol, width: 1),
                boxShadow: isDark ? null : AppDesignSystem.softShadow,
              ),
              child: Center(
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: textP,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
