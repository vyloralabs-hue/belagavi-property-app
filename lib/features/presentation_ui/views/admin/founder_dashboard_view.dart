import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

class FounderDashboardView extends StatelessWidget {
  const FounderDashboardView({super.key});

  void _navigateTo(BuildContext context, String route, String moduleName) {
    HapticFeedback.lightImpact();
    try {
      context.push(route);
    } catch (_) {
      _showComingSoonSnackbar(context, moduleName);
    }
  }

  void _showComingSoonSnackbar(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFB39037),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$moduleName module is currently under development.',
                style: const TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFDFCF4),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF131922),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFB39037), width: 1),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFFDFCF4),
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: const Text(
          'Founder Control Panel',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFDFCF4),
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF059669), width: 1),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Color(0xFF059669)),
                SizedBox(width: 6),
                Text(
                  'ONLINE',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── Executive Header Overview Card ──
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E3A8A),
                    Color(0xFF0A0D11),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFB39037), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB39037).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB39037),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'PLATFORM OVERVIEW',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB39037),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.security_rounded,
                        color: Color(0xFFB39037),
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belagavi Property RE-OS',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFDFCF4),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Real-Time Telemetry & Operations Command',
                    style: TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Color(0x33B39037), height: 1),
                  const SizedBox(height: 16),
                  // 3x2 Metrics Grid
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TelemetryMetricItem(
                        label: 'Total Properties',
                        value: '1,420',
                      ),
                      _TelemetryMetricItem(label: 'Active Leads', value: '385'),
                      _TelemetryMetricItem(
                        label: 'Monthly Revenue',
                        value: '₹4.8L',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TelemetryMetricItem(
                        label: 'Total Brokers',
                        value: '142',
                      ),
                      _TelemetryMetricItem(
                        label: 'Active Users',
                        value: '12.8K',
                      ),
                      _TelemetryMetricItem(
                        label: "Today's Activity",
                        value: '+48 New',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Founding Team Section ──
            const Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFB39037),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Founding Team',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDFCF4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Executive Leadership & Governance Board',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),

            const _FounderCard(
              name: 'Nikhil Sadanand Pawar',
              role: 'Founder & Chief Executive Officer',
              badgeText: 'FOUNDER & CEO',
              initials: 'NP',
              subcaption: 'Platform Strategy & Core Engineering Architecture',
              avatarColor: Color(0xFFB39037),
            ),
            const SizedBox(height: 12),
            const _FounderCard(
              name: 'Sadanand Maruti Pawar',
              role: 'Co-Founder & Executive Director',
              badgeText: 'CO-FOUNDER',
              initials: 'SP',
              subcaption: 'Real Estate Operations & Strategic Alliances',
              avatarColor: Color(0xFF1E3A8A),
            ),
            const SizedBox(height: 12),
            const _FounderCard(
              name: 'Sakshi Nikhil Pawar',
              role: 'Co-Founder & Chief Operating Officer',
              badgeText: 'CO-FOUNDER',
              initials: 'SP',
              subcaption: 'Business Development & Growth Operations',
              avatarColor: Color(0xFF059669),
            ),

            const SizedBox(height: 28),

            // ── Management Modules Section ──
            const Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFFB39037),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Management Modules',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDFCF4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Executive Operational Controls & Platform Engines',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),

            _InteractiveModuleCard(
              icon: Icons.gavel_rounded,
              title: 'Property Verification & Moderation Queue',
              subtitle:
                  'Review pending submissions, approve/reject, handle disputes',
              accentColor: const Color(0xFFDC2626),
              onTap: () => _navigateTo(
                context,
                '/admin/moderation',
                'Property Moderation',
              ),
            ),
            _InteractiveModuleCard(
              icon: Icons.dashboard_customize_rounded,
              title: 'Broker & Investor CRM Funnel',
              subtitle: 'Manage 5-stage sales funnel and client leads',
              accentColor: const Color(0xFF1E3A8A),
              onTap: () =>
                  _navigateTo(context, '/crm', 'Broker & Investor CRM'),
            ),
            _InteractiveModuleCard(
              icon: Icons.campaign_rounded,
              title: 'Advertisement & Revenue Management',
              subtitle:
                  'Track platform ads, sponsor slots, and total ad revenue',
              accentColor: const Color(0xFFB39037),
              onTap: () => _navigateTo(
                context,
                '/ads-management',
                'Advertisement & Revenue',
              ),
            ),
            _InteractiveModuleCard(
              icon: Icons.workspace_premium_rounded,
              title: 'Subscriptions & Membership',
              subtitle: 'Review active broker/builder plans and upgrades',
              accentColor: const Color(0xFF059669),
              onTap: () => _navigateTo(
                context,
                '/subscriptions',
                'Subscriptions & Membership',
              ),
            ),
            _InteractiveModuleCard(
              icon: Icons.apartment_rounded,
              title: 'Premium Builders Showcase',
              subtitle: 'Manage RERA-verified developer listings',
              accentColor: const Color(0xFF8B5CF6),
              onTap: () => _navigateTo(
                context,
                '/builders',
                'Premium Builders Showcase',
              ),
            ),
            _InteractiveModuleCard(
              icon: Icons.foundation_rounded,
              title: 'Developer & Infrastructure Projects',
              subtitle: 'Review township masterplans and land parcels',
              accentColor: const Color(0xFF6366F1),
              onTap: () =>
                  _navigateTo(context, '/projects', 'Developer Projects'),
            ),
            _InteractiveModuleCard(
              icon: Icons.support_agent_rounded,
              title: 'Customer Support & SLA Escalations',
              subtitle: '24/7 ticket resolution, FAQ & live verification',
              accentColor: const Color(0xFFF59E0B),
              onTap: () => _navigateTo(context, '/support', 'Customer Support'),
            ),
            _InteractiveModuleCard(
              icon: Icons.security_rounded,
              title: 'System Telemetry & Security Logs',
              subtitle: 'Platform health, biometrics & audit trail',
              accentColor: const Color(0xFFF43F5E),
              onTap: () => _navigateTo(
                context,
                '/enable-biometric',
                'System Telemetry & Security',
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TelemetryMetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _TelemetryMetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFFFDFCF4),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

class _FounderCard extends StatelessWidget {
  final String name;
  final String role;
  final String badgeText;
  final String initials;
  final String subcaption;
  final Color avatarColor;

  const _FounderCard({
    required this.name,
    required this.role,
    required this.badgeText,
    required this.initials,
    required this.subcaption,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB39037), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Initials Avatar Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0D11),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB39037), width: 2),
              boxShadow: [
                BoxShadow(
                  color: avatarColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB39037),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(
                            0xFF0A0D11,
                          ), // High contrast dark text on white card
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB39037),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0D11),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A), // Dark blue highlights
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subcaption,
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 11,
                    color: Color(0xFF475569), // Slate subtitle text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveModuleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _InteractiveModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_InteractiveModuleCard> createState() => _InteractiveModuleCardState();
}

class _InteractiveModuleCardState extends State<_InteractiveModuleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: widget.onTap,
              highlightColor: widget.accentColor.withValues(alpha: 0.05),
              splashColor: widget.accentColor.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(
                                0xFF0A0D11,
                              ), // High contrast dark text on white card
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(
                              fontFamily: AppDesignSystem.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(
                                0xFF475569,
                              ), // Slate dark subtitle text on white card
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFB39037), // Gold arrow
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
