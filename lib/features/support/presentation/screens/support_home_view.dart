import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../widgets/support_channel_card.dart';

/// Premium Support Home — Hub screen for all support channels and services
class SupportHomeView extends StatelessWidget {
  const SupportHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Contact Support'),
                  const SizedBox(height: 12),
                  _buildContactChannels(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Real Estate Services'),
                  const SizedBox(height: 12),
                  _buildServiceGrid(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Help'),
                  const SizedBox(height: 12),
                  _buildQuickHelpRow(context),
                  const SizedBox(height: 24),
                  _buildFutureServicesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppDesignSystem.textPrimary,
          size: 20,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support Centre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F7FF), Colors.white],
            ),
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.push('/support/tickets'),
          icon: const Icon(
            Icons.confirmation_number_outlined,
            size: 16,
            color: AppDesignSystem.primaryNavy,
          ),
          label: const Text(
            'My Tickets',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppDesignSystem.primaryNavy, Color(0xFF2563EB)],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Expert real estate assistance for Belagavi & beyond.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: AppDesignSystem.borderRadiusPill,
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Mon–Sat, 9 AM – 7 PM IST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.support_agent_rounded,
            color: Colors.white38,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppDesignSystem.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildContactChannels(BuildContext context) {
    return Column(
      children: [
        SupportChannelCard(
          title: 'WhatsApp Support',
          subtitle: 'Chat with our support team instantly',
          availability: 'Typically replies in under 5 minutes',
          icon: Icons.chat_rounded,
          iconColor: const Color(0xFF25D366),
          iconBg: const Color(0xFFDCFCE7),
          borderColor: const Color(0xFF25D366),
          onTap: () {},
        ),
        const SizedBox(height: 10),
        SupportChannelCard(
          title: 'Call Support',
          subtitle: 'Speak directly with a real estate expert',
          availability: 'Available Mon–Sat, 9 AM – 7 PM',
          icon: Icons.call_rounded,
          iconColor: AppDesignSystem.primaryNavy,
          iconBg: const Color(0xFFEFF6FF),
          borderColor: AppDesignSystem.primaryNavy,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        SupportChannelCard(
          title: 'Helpdesk Ticket',
          subtitle: 'Submit a ticket for property and legal queries',
          availability: '24/7 Ticket Submission',
          icon: Icons.confirmation_number_outlined,
          iconColor: const Color(0xFF7C3AED),
          iconBg: const Color(0xFFEDE9FE),
          borderColor: const Color(0xFF7C3AED),
          badgeLabel: 'ACTIVE',
          onTap: () => context.push('/support/tickets'),
        ),
      ],
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    const services = [
      _ServiceItem(
        Icons.description_rounded,
        'Documentation',
        'EC, Khata, RTC',
        Color(0xFFEFF6FF),
        AppDesignSystem.primaryNavy,
        '/support/docs',
      ),
      _ServiceItem(
        Icons.calendar_month_rounded,
        'Consultation',
        'Book a slot',
        Color(0xFFD1FAE5),
        AppDesignSystem.accentEmerald,
        '/support/appointment',
      ),
      _ServiceItem(
        Icons.verified_rounded,
        'Verification',
        'Property check',
        Color(0xFFFEF3C7),
        Color(0xFFD97706),
        '/support/verification',
      ),
      _ServiceItem(
        Icons.help_outline_rounded,
        'FAQ Centre',
        'Common questions',
        Color(0xFFEDE9FE),
        Color(0xFF7C3AED),
        '/support/faq',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: services.map((s) => _buildServiceTile(context, s)).toList(),
    );
  }

  Widget _buildServiceTile(BuildContext context, _ServiceItem s) {
    return GestureDetector(
      onTap: () => context.push(s.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppDesignSystem.cardWhite,
          borderRadius: AppDesignSystem.borderRadiusL,
          boxShadow: AppDesignSystem.softShadow,
          border: Border.all(color: AppDesignSystem.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: s.iconBg,
                borderRadius: AppDesignSystem.borderRadiusM,
              ),
              child: Icon(s.icon, color: s.iconColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              s.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            Text(
              s.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppDesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickHelpTile(
            context,
            Icons.confirmation_number_rounded,
            'My Tickets',
            '/support/tickets',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickHelpTile(
            context,
            Icons.live_help_rounded,
            'File a Complaint',
            '/support/tickets',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHelpTile(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppDesignSystem.cardWhite,
          borderRadius: AppDesignSystem.borderRadiusL,
          boxShadow: AppDesignSystem.softShadow,
          border: Border.all(color: AppDesignSystem.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppDesignSystem.primaryNavy),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppDesignSystem.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureServicesSection() {
    final upcoming = [
      ('🎥', 'Video Consultation', 'Coming soon'),
      ('💬', 'Live Chat', 'Coming soon'),
      ('🏦', 'Home Loan Guidance', 'Coming soon'),
      ('⚖️', 'Legal Partner Network', 'Coming soon'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.rocket_launch_rounded,
                size: 16,
                color: Color(0xFF7C3AED),
              ),
              SizedBox(width: 8),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: upcoming.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FF),
                  borderRadius: AppDesignSystem.borderRadiusPill,
                  border: Border.all(color: AppDesignSystem.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final String route;

  const _ServiceItem(
    this.icon,
    this.title,
    this.subtitle,
    this.iconBg,
    this.iconColor,
    this.route,
  );
}
