import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/security/biometric_auth_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_selector_modal.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../theme/app_design_system.dart';
import '../../theme/app_theme_manager.dart';

class UserProfileView extends ConsumerWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(appThemeManagerProvider);

    final User? firebaseUser = (Firebase.apps.isNotEmpty)
        ? FirebaseAuth.instance.currentUser
        : null;
    final GoogleSignInAccount? googleUser = GoogleSignIn().currentUser;
    final String? storedName = AuthSessionStorageHelper.getUserName();
    final String? storedEmail = AuthSessionStorageHelper.getUserEmail();
    final String? storedPhoto = AuthSessionStorageHelper.getUserPhoto();
    final bool sessionIsLoggedIn = AuthSessionStorageHelper.isLoggedIn();

    final String displayName;
    final String? displayEmail;
    final String? displayPhotoUrl;
    final String roleBadge;
    final bool isSignedIn;

    final bool hasActiveSession =
        sessionIsLoggedIn ||
        firebaseUser != null ||
        googleUser != null ||
        (storedEmail != null && storedEmail.isNotEmpty) ||
        (storedName != null && storedName.isNotEmpty);

    if (firebaseUser != null) {
      displayName =
          firebaseUser.displayName ??
          googleUser?.displayName ??
          storedName ??
          'Belagavi Property User';
      displayEmail =
          firebaseUser.email ??
          googleUser?.email ??
          storedEmail ??
          'user@belagaviproperty.com';
      displayPhotoUrl =
          firebaseUser.photoURL ?? googleUser?.photoUrl ?? storedPhoto;
      roleBadge = 'GOLD MEMBER';
      isSignedIn = true;
    } else if (authState is Authenticated) {
      displayName = authState.userProfile.fullName;
      displayEmail = authState.userProfile.email;
      displayPhotoUrl = authState.userProfile.avatarUrl;
      final isOwner =
          displayEmail?.toLowerCase().trim() == 'belagaviproperty@gmail.com';
      roleBadge = isOwner
          ? 'OWNER / SUPER ADMIN'
          : authState.userProfile.role.name.toUpperCase();
      isSignedIn = true;
    } else if (googleUser != null) {
      displayName =
          googleUser.displayName ?? storedName ?? 'Belagavi Property User';
      displayEmail = googleUser.email;
      displayPhotoUrl = googleUser.photoUrl;
      final isOwner =
          displayEmail.toLowerCase().trim() == 'belagaviproperty@gmail.com';
      roleBadge = isOwner ? 'OWNER / SUPER ADMIN' : 'GOLD MEMBER';
      isSignedIn = true;
    } else if (hasActiveSession) {
      displayName = (storedName != null && storedName.isNotEmpty)
          ? storedName
          : 'Belagavi Property User';
      displayEmail = (storedEmail != null && storedEmail.isNotEmpty)
          ? storedEmail
          : 'belagaviproperty@gmail.com';
      displayPhotoUrl = storedPhoto ?? googleUser?.photoUrl;
      final isOwner =
          displayEmail.toLowerCase().trim() == 'belagaviproperty@gmail.com';
      roleBadge = isOwner ? 'OWNER / SUPER ADMIN' : 'GOLD MEMBER';
      isSignedIn = true;
    } else {
      displayName = 'Guest User';
      displayEmail = 'Sign in to access saved properties & features';
      displayPhotoUrl = null;
      roleBadge = 'GUEST ACCOUNT';
      isSignedIn = false;
    }

    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'My Profile & Account',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            color: textP,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: surfaceBg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // ── Profile / Guest Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppDesignSystem.brandGold, width: 1.5),
              boxShadow: AppDesignSystem.cardShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar Ring
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppDesignSystem.brandGold,
                          width: 2,
                        ),
                        color: AppDesignSystem.brandGold.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            (displayPhotoUrl != null &&
                                displayPhotoUrl.isNotEmpty)
                            ? Image.network(
                                displayPhotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color: AppDesignSystem.brandGold,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: AppDesignSystem.brandGold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: textP,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayEmail ?? '',
                            style: TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 12,
                              color: textS,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppDesignSystem.brandGold.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppDesignSystem.brandGold,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              roleBadge,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppDesignSystem.brandGold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Theme Selector Card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol, width: 1.2),
              boxShadow: AppDesignSystem.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.palette_outlined,
                      size: 18,
                      color: AppDesignSystem.brandGold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'App Appearance & Theme',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textP,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeOption(
                        context: context,
                        ref: ref,
                        label: 'Light Mode',
                        icon: Icons.light_mode_rounded,
                        mode: ThemeMode.light,
                        currentMode: themeMode,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOption(
                        context: context,
                        ref: ref,
                        label: 'Dark Mode',
                        icon: Icons.dark_mode_rounded,
                        mode: ThemeMode.dark,
                        currentMode: themeMode,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOption(
                        context: context,
                        ref: ref,
                        label: 'System',
                        icon: Icons.brightness_auto_rounded,
                        mode: ThemeMode.system,
                        currentMode: themeMode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── App Language Tile ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol, width: 1.2),
              boxShadow: AppDesignSystem.cardShadow,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 20,
                  color: AppDesignSystem.brandGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref
                            .watch(appLocalizationsProvider)
                            .translate('appLanguageSetting'),
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textP,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ref.watch(localizationNotifierProvider).nativeName} (${ref.watch(localizationNotifierProvider).name})',
                        style: TextStyle(fontSize: 12, color: textS),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => LanguageSelectorModal.show(context),
                  icon: const Icon(Icons.translate_rounded, size: 14),
                  label: const Text(
                    'Change',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Section 1 Header ──
          Text(
            'Property Services & Management',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textP,
            ),
          ),
          const SizedBox(height: 12),

          _InteractiveActionTile(
            icon: Icons.favorite_rounded,
            title: 'Liked / Saved Properties',
            subtitle: 'Quick access to all your shortlisted homes & plots',
            iconColor: Colors.redAccent,
            onTap: () => context.push('/favorites'),
          ),
          _InteractiveActionTile(
            icon: Icons.inbox_rounded,
            title: 'Property Enquiries (Seller Leads)',
            subtitle: 'Manage buyer leads, visits, negotiations & verification',
            iconColor: const Color(0xFF15803D),
            onTap: () => context.push('/seller-enquiries'),
          ),
          _InteractiveActionTile(
            icon: Icons.home_work_rounded,
            title: 'My Properties',
            subtitle: 'View, hold, and manage your listed properties',
            iconColor: AppDesignSystem.brandGold,
            onTap: () => context.push('/my-properties'),
          ),
          _InteractiveActionTile(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Property Management (Admin)',
            subtitle: 'Global management authority across all listings',
            iconColor: const Color(0xFFE11D48),
            onTap: () => context.push('/admin-properties'),
          ),
          _InteractiveActionTile(
            icon: Icons.add_business_rounded,
            title: 'List Your Property',
            subtitle: 'Post a new house, plot, commercial space, or land',
            iconColor: AppDesignSystem.brandGold,
            onTap: () => context.push('/add-property'),
          ),
          _InteractiveActionTile(
            icon: Icons.domain_rounded,
            title: 'Builder Project Control Panel',
            subtitle: 'Manage residential/commercial projects & unit inventory',
            iconColor: AppDesignSystem.brandGold,
            onTap: () => context.push('/builder-projects'),
          ),

          const SizedBox(height: 20),

          // ── Section 2 Header ──
          Text(
            'Account & Security',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textP,
            ),
          ),
          const SizedBox(height: 12),

          _AccountVerificationDetailsCard(
            firebaseUser: firebaseUser,
            email: displayEmail,
            phoneNumber:
                (firebaseUser?.phoneNumber != null &&
                    firebaseUser!.phoneNumber!.isNotEmpty)
                ? firebaseUser.phoneNumber
                : AuthSessionStorageHelper.getMobileNumber(),
            isSignedIn: isSignedIn,
          ),
          const SizedBox(height: 12),

          _InteractiveActionTile(
            icon: Icons.badge_outlined,
            title: 'Account Type & Marketplace Role',
            subtitle:
                'Manage whether you use Belagavi Property as Buyer, Seller, Broker, or Builder',
            iconColor: AppDesignSystem.brandGold,
            onTap: () => _showRoleManagementModal(context, ref),
          ),
          const _BiometricSettingTile(),

          if (isSignedIn) ...[
            const SizedBox(height: 12),
            _InteractiveActionTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out of Belagavi Property session',
              iconColor: Colors.redAccent,
              isDestructive: true,
              onTap: () async {
                await AuthSessionStorageHelper.logout();
                if (context.mounted) {
                  context.go('/auth');
                }
              },
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    final isDark = AppDesignSystem.isDark(context);

    return GestureDetector(
      onTap: () {
        ref.read(appThemeManagerProvider.notifier).setThemeMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppDesignSystem.brandGold
              : (isDark ? const Color(0xFF1B2330) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppDesignSystem.brandGold
                : AppDesignSystem.borderCol(context),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppDesignSystem.textP(context),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppDesignSystem.textP(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const _InteractiveActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_InteractiveActionTile> createState() => _InteractiveActionTileState();
}

class _InteractiveActionTileState extends State<_InteractiveActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isDestructive ? const Color(0xFFFFF1F2) : cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDestructive ? const Color(0xFFFECDD3) : borderCol,
              width: 1.2,
            ),
            boxShadow: AppDesignSystem.cardShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.isDestructive
                            ? const Color(0xFFBE123C)
                            : textP,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 11.5,
                        color: widget.isDestructive
                            ? const Color(0xFFE11D48)
                            : textS,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.isDestructive ? const Color(0xFFFDA4AF) : textS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BiometricSettingTile extends StatefulWidget {
  const _BiometricSettingTile();

  @override
  State<_BiometricSettingTile> createState() => _BiometricSettingTileState();
}

class _BiometricSettingTileState extends State<_BiometricSettingTile> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAvailable = false;
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = AuthSessionStorageHelper.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isAvailable = available;
        _isEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final success = await _biometricService.authenticate(
        localizedReason:
            'Confirm your biometric identity to enable Biometric Login',
      );
      if (success) {
        await AuthSessionStorageHelper.setBiometricEnabled(true);
        if (mounted) {
          setState(() => _isEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric Login enabled.'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Biometric authentication failed. Toggle not changed.',
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      await AuthSessionStorageHelper.setBiometricEnabled(false);
      if (mounted) {
        setState(() => _isEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric Login disabled.'),
            backgroundColor: Color(0xFF64748B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppDesignSystem.brandGold,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: AppDesignSystem.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppDesignSystem.brandGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: AppDesignSystem.brandGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Quick Unlock',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isAvailable
                      ? (_isEnabled
                            ? 'Enabled for fast fingerprint/Face ID unlock'
                            : 'Disabled — tap toggle to enable')
                      : 'Biometric authentication is not available on this device.',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 11.5,
                    color: _isAvailable ? textS : const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ),
          if (_isAvailable)
            Switch.adaptive(
              key: const ValueKey('switch_biometric'),
              value: _isEnabled,
              activeColor: AppDesignSystem.brandGold,
              onChanged: _toggleBiometric,
            ),
        ],
      ),
    );
  }
}

void _showRoleManagementModal(BuildContext context, WidgetRef ref) {
  final currentRoleStr = AuthSessionStorageHelper.getUserRole() ?? 'buyer';
  final currentRole = UserRoleEnum.values.firstWhere(
    (e) => e.name.toLowerCase() == currentRoleStr.toLowerCase(),
    orElse: () => UserRoleEnum.buyer,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final surfaceBg = AppDesignSystem.surfaceBg(ctx);
      final textP = AppDesignSystem.textP(ctx);
      final textS = AppDesignSystem.textS(ctx);
      final cardBg = AppDesignSystem.cardBg(ctx);
      final borderCol = AppDesignSystem.borderCol(ctx);

      const roles = [
        {
          'role': UserRoleEnum.buyer,
          'title': 'Property Buyer / Tenant',
          'subtitle': 'Search residential homes, plots, and rental properties.',
          'icon': Icons.home_rounded,
        },
        {
          'role': UserRoleEnum.seller,
          'title': 'Property Owner / Seller',
          'subtitle': 'List your flat, plot, or commercial property directly.',
          'icon': Icons.sell_rounded,
        },
        {
          'role': UserRoleEnum.broker,
          'title': 'Real Estate Broker / Agent',
          'subtitle': 'Manage multiple listings, leads & client portfolios.',
          'icon': Icons.business_center_rounded,
        },
        {
          'role': UserRoleEnum.builder,
          'title': 'Property Builder / Developer',
          'subtitle': 'Manage housing projects, unit inventories & sales.',
          'icon': Icons.domain_rounded,
        },
        {
          'role': UserRoleEnum.builderTeamMember,
          'title': 'Builder Team Member',
          'subtitle':
              'Access developer project sales dashboard as sales staff.',
          'icon': Icons.groups_rounded,
        },
        {
          'role': UserRoleEnum.brokerTeamMember,
          'title': 'Broker Agency Staff',
          'subtitle': 'Manage leads under agency broker supervisor.',
          'icon': Icons.badge_rounded,
        },
      ];

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: borderCol),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.badge_rounded,
                      color: AppDesignSystem.brandGold,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Marketplace Account Role',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textP,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Select your primary account mode. You can switch anytime.',
                  style: TextStyle(fontSize: 13, color: textS),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: roles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final item = roles[idx];
                      final role = item['role'] as UserRoleEnum;
                      final isSelected = currentRole == role;

                      return InkWell(
                        onTap: () async {
                          ref
                              .read(authNotifierProvider.notifier)
                              .switchRole(role);
                          await AuthSessionStorageHelper.setUserRole(role.name);
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Account role updated to ${item['title']}',
                                ),
                                backgroundColor: const Color(0xFF16A34A),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppDesignSystem.brandGold.withValues(
                                    alpha: 0.12,
                                  )
                                : cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppDesignSystem.brandGold
                                  : borderCol,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: isSelected
                                    ? AppDesignSystem.brandGold
                                    : textS,
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: isSelected
                                            ? AppDesignSystem.brandGold
                                            : textP,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: textS,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppDesignSystem.brandGold,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _AccountVerificationDetailsCard extends StatefulWidget {
  final User? firebaseUser;
  final String? email;
  final String? phoneNumber;
  final bool isSignedIn;

  const _AccountVerificationDetailsCard({
    required this.firebaseUser,
    required this.email,
    required this.phoneNumber,
    required this.isSignedIn,
  });

  @override
  State<_AccountVerificationDetailsCard> createState() =>
      _AccountVerificationDetailsCardState();
}

class _AccountVerificationDetailsCardState
    extends State<_AccountVerificationDetailsCard> {
  bool _isReloading = false;

  Future<void> _sendVerificationEmail() async {
    final user = widget.firebaseUser;
    if (user == null) return;
    try {
      await user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification link sent! Please check your email inbox.',
            ),
            backgroundColor: Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not send verification email: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _refreshVerificationStatus() async {
    final user = widget.firebaseUser;
    if (user == null) return;
    setState(() => _isReloading = true);
    try {
      await user.reload();
      if (mounted) {
        setState(() => _isReloading = false);
        final freshUser = FirebaseAuth.instance.currentUser;
        final isVerified = freshUser?.emailVerified ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVerified
                  ? 'Email verified successfully!'
                  : 'Email is not verified yet. Please check your inbox.',
            ),
            backgroundColor: isVerified
                ? const Color(0xFF15803D)
                : const Color(0xFFB45309),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isReloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppDesignSystem.cardBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);

    final user = widget.firebaseUser;
    final isEmailVerified = user?.emailVerified ?? false;
    final providers = user?.providerData.map((p) => p.providerId).toSet() ?? {};
    final isGoogleLinked = providers.contains('google.com');
    final isAppleLinked = providers.contains('apple.com');
    final isPhoneLinked =
        (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) ||
        providers.contains('phone');

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: AppDesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: AppDesignSystem.brandGold,
              ),
              const SizedBox(width: 8),
              Text(
                'Identity & Account Verification',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textP,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Email Verification Status ──
          if (widget.email != null && widget.email!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: textS),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.email!,
                    style: TextStyle(
                      fontSize: 13,
                      color: textP,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isEmailVerified
                        ? const Color(0xFF15803D).withValues(alpha: 0.15)
                        : const Color(0xFFB45309).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isEmailVerified
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB45309),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    isEmailVerified ? '✓ Verified' : 'Unverified',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isEmailVerified
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            if (!isEmailVerified && user != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _sendVerificationEmail,
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text(
                      'Verify Email',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _isReloading ? null : _refreshVerificationStatus,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text(
                      'Refresh Status',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 18),
          ],

          // ── Mobile Number Verification Status ──
          Row(
            children: [
              Icon(Icons.phone_android_rounded, size: 16, color: textS),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.phoneNumber ?? 'Not Added',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        (widget.phoneNumber != null &&
                            widget.phoneNumber!.isNotEmpty)
                        ? textP
                        : textS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPhoneLinked
                      ? const Color(0xFF15803D).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isPhoneLinked
                        ? const Color(0xFF15803D)
                        : Colors.grey,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isPhoneLinked ? '✓ Verified' : 'Not Added',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPhoneLinked
                        ? const Color(0xFF15803D)
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),

          // ── Connected Sign-in Methods ──
          Text(
            'Connected Sign-In Methods',
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textS,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildProviderBadge(
                'Google',
                Icons.g_mobiledata_rounded,
                isGoogleLinked,
              ),
              _buildProviderBadge(
                'Phone OTP',
                Icons.sms_outlined,
                isPhoneLinked,
              ),
              _buildProviderBadge('Apple', Icons.apple_rounded, isAppleLinked),
            ],
          ),
          const SizedBox(height: 12),

          // ── Clarification Notice ──
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155), width: 0.8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppDesignSystem.brandGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Identity verification confirms login credential ownership only. Property ownership and legal verification are separate processes.',
                    style: TextStyle(fontSize: 10.5, color: textS, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderBadge(String label, IconData icon, bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isConnected
            ? AppDesignSystem.brandGold.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected
              ? AppDesignSystem.brandGold
              : Colors.grey.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isConnected ? AppDesignSystem.brandGold : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ${isConnected ? "Connected" : "Not Linked"}',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isConnected ? FontWeight.w600 : FontWeight.normal,
              color: isConnected ? AppDesignSystem.brandGold : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
