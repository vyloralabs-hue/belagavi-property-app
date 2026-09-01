import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';
import 'package:belagavi_property/features/investment/presentation/localization/investment_localizations.dart';
import 'package:belagavi_property/features/investment/presentation/providers/investment_notifier.dart';
import 'widgets/request_callback_modal.dart';
import 'investment_project_detail_view.dart';

class InvestWithUsView extends ConsumerStatefulWidget {
  const InvestWithUsView({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const InvestWithUsView()),
    );
  }

  @override
  ConsumerState<InvestWithUsView> createState() => _InvestWithUsViewState();
}

class _InvestWithUsViewState extends ConsumerState<InvestWithUsView> {
  bool _rulesExpanded = false;
  bool _projectsExpanded = true;
  bool _paymentExpanded = true;
  bool _documentsExpanded = false;
  bool _contactExpanded = false;

  final Map<int, bool> _acknowledgements = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
  };

  bool get _allAcknowledged => _acknowledgements.values.every((v) => v);

  Future<void> _callLLP(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsAppLLP(String phone, {String? projectName}) async {
    final normalized = '91$phone';
    final text = Uri.encodeComponent(
      projectName != null
          ? 'Hello Belagavi Property LLP, I am interested in the investment opportunity for "$projectName". Please share the next steps.'
          : 'Hello Belagavi Property LLP, I am interested in learning more about your project-specific investment opportunities. Please contact me.',
    );
    final nativeUri = Uri.parse('whatsapp://send?phone=$normalized&text=$text');
    final webUri = Uri.parse('https://wa.me/$normalized?text=$text');

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPaymentActivationNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161D26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A3644)),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 22),
            SizedBox(width: 8),
            Text(
              'Payment Activation',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Payment setup is being activated.\n\nPlease contact Belagavi Property LLP investment team or request a callback for official bank account details and project allocation documents.',
          style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              RequestCallbackModal.show(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD4AF37),
              side: const BorderSide(color: Color(0xFFB39037)),
            ),
            child: const Text('Request Callback'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _whatsAppLLP('9113219906');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.black,
            ),
            child: const Text('WhatsApp Team'),
          ),
        ],
      ),
    );
  }

  void _onProceedToInvestment(InvestmentState state) {
    if (state.hasOpenProjects) {
      final firstProject = state.openProjects.first;
      InvestmentProjectDetailView.show(context, firstProject);
    } else {
      RequestCallbackModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentNotifierProvider);
    final selectedLang = ref.watch(investmentLanguageProvider);
    final loc = InvestmentLocalizations(selectedLang);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: const TextSpan(
            text: 'Belagavi Property ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'LLP Invest',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Language selector
          PopupMenuButton<InvestmentLanguage>(
            icon: const Icon(
              Icons.language_rounded,
              color: Color(0xFFD4AF37),
              size: 22,
            ),
            color: const Color(0xFF161D26),
            onSelected: (lang) {
              ref.read(investmentLanguageProvider.notifier).setLanguage(lang);
            },
            itemBuilder: (ctx) => InvestmentLanguage.values.map((l) {
              return PopupMenuItem(
                value: l,
                child: Text(
                  l.label,
                  style: TextStyle(
                    color: selectedLang == l
                        ? const Color(0xFFD4AF37)
                        : Colors.white,
                    fontWeight: selectedLang == l
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF1E293B), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Hero Card
              _buildHeroCard(),

              const SizedBox(height: 14),

              // Info Banner: Rules & investment terms open on tap
              InkWell(
                onTap: () {
                  setState(() {
                    _rulesExpanded = !_rulesExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12171E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A3644)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Rules & investment terms open on tap',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        _rulesExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_right,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Quick Actions Header
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Quick Actions Grid (3 cards)
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.trending_up_rounded,
                      title: 'Invest Now',
                      subtitle: 'Explore & invest in projects',
                      onTap: () => _onProceedToInvestment(state),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.phone_in_talk_outlined,
                      title: 'Contact Belagavi Property LLP',
                      subtitle: 'Speak with our investment team',
                      onTap: () {
                        setState(() {
                          _contactExpanded = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.headset_mic_outlined,
                      title: 'Request Callback',
                      subtitle: "We'll call you soon",
                      onTap: () => RequestCallbackModal.show(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 1. Investment Rules & Regulations (Expandable)
              _buildAccordionCard(
                icon: Icons.description_outlined,
                title: 'Investment Rules & Regulations',
                isExpanded: _rulesExpanded,
                onToggle: () =>
                    setState(() => _rulesExpanded = !_rulesExpanded),
                content: _buildRulesContent(loc),
              ),

              const SizedBox(height: 12),

              // 2. Project Opportunities (Dynamic)
              _buildAccordionCard(
                icon: Icons.apartment_rounded,
                title: 'Project Opportunities',
                isExpanded: _projectsExpanded,
                onToggle: () =>
                    setState(() => _projectsExpanded = !_projectsExpanded),
                content: _buildProjectsContent(state),
              ),

              const SizedBox(height: 12),

              // 3. Payment Options (Expandable)
              _buildAccordionCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payment Options',
                isExpanded: _paymentExpanded,
                onToggle: () =>
                    setState(() => _paymentExpanded = !_paymentExpanded),
                content: _buildPaymentContent(),
              ),

              const SizedBox(height: 12),

              // 4. Documents & Verification (Expandable)
              _buildAccordionCard(
                icon: Icons.verified_user_outlined,
                title: 'Documents & Verification',
                isExpanded: _documentsExpanded,
                onToggle: () =>
                    setState(() => _documentsExpanded = !_documentsExpanded),
                content: _buildDocumentsContent(state, loc),
              ),

              const SizedBox(height: 12),

              // 5. Contact Belagavi Property LLP Team (Expandable)
              _buildAccordionCard(
                icon: Icons.person_outline,
                title: 'Contact Belagavi Property LLP',
                isExpanded: _contactExpanded,
                onToggle: () =>
                    setState(() => _contactExpanded = !_contactExpanded),
                content: _buildContactContent(),
              ),

              const SizedBox(height: 18),

              // Bottom Trust Badge Card
              _buildTrustBadgeCard(),

              const SizedBox(height: 20),

              // Sticky Proceed to Investment CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onProceedToInvestment(state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Proceed to Investment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB39037).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39037).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Project-Based\nInvestment Opportunities',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 220,
                child: Text(
                  'Invest with structured guidance and direct support from Belagavi Property LLP.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: Opacity(
              opacity: 0.85,
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 90,
                height: 90,
                errorBuilder: (ctx, e, st) => const Icon(
                  Icons.domain,
                  color: Color(0xFFB39037),
                  size: 80,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF12171E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A3644)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB39037).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFB39037),
                  size: 12,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionCard({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12171E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFFB39037).withValues(alpha: 0.5)
              : const Color(0xFF2A3644),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFFD4AF37), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: Color(0xFF1E293B), height: 1),
            Padding(padding: const EdgeInsets.all(16), child: content),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesContent(InvestmentLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRuleItem(
          'Project-Specific Investment',
          loc.text('projectSpecificDesc'),
        ),
        _buildRuleItem('Fund Utilisation', loc.text('fundUtilisationDesc')),
        _buildRuleItem('Profit Participation', loc.text('profitSharingDesc')),
        _buildRuleItem(
          'No Guaranteed Returns Warning',
          loc.text('noGuaranteedReturnsDesc'),
          isWarning: true,
        ),
        _buildRuleItem('Record Transparency', loc.text('transparencyDesc')),
        _buildRuleItem('Payment Safety & Security', loc.text('paymentSafety')),
        const SizedBox(height: 10),
        const Text(
          'Governing Law & Legal Jurisdiction:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.text('governingLaw'),
          style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
        ),
        Text(
          loc.text('jurisdiction'),
          style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String title, String desc, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWarning
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 14,
                color: isWarning
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFD4AF37),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? const Color(0xFFF59E0B) : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF94A3B8),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsContent(InvestmentState state) {
    if (!state.hasOpenProjects && !state.hasUpcomingProjects) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161D26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A3644)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.apartment_outlined,
              color: Color(0xFFB39037),
              size: 36,
            ),
            const SizedBox(height: 10),
            const Text(
              'No investment opportunities are open right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Register your interest to get priority updates when new project opportunities open.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => RequestCallbackModal.show(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(color: Color(0xFFB39037)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Request Callback',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _whatsAppLLP('9113219906'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'WhatsApp Team',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (state.hasOpenProjects) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Open Investment Opportunities',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...state.openProjects.map((p) => _buildProjectCard(p)),
        ],
        if (state.hasUpcomingProjects) ...[
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Upcoming Investment Opportunities',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...state.upcomingProjects.map((p) => _buildProjectCard(p)),
        ],
      ],
    );
  }

  Widget _buildProjectCard(InvestmentProjectEntity project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161D26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3644)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39037).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  project.status.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFD4AF37),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                project.location,
                style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (project.minimumInvestment != null)
                Text(
                  'Min: ₹${project.minimumInvestment!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        InvestmentProjectDetailView.show(context, project),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2A3644)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => RequestCallbackModal.show(
                      context,
                      projectId: project.id,
                      projectName: project.name,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'Express Interest',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161D26),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2A3644)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 6, color: Color(0xFFD4AF37)),
                  SizedBox(width: 8),
                  Text(
                    'Bank transfer details will be added here',
                    style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.circle, size: 6, color: Color(0xFFD4AF37)),
                  SizedBox(width: 8),
                  Text(
                    'Direct payment available after account details are activated',
                    style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showPaymentActivationNotice,
                icon: const Icon(Icons.payment, size: 16, color: Colors.black),
                label: const Text(
                  'Pay Directly',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => RequestCallbackModal.show(context),
                icon: const Icon(
                  Icons.phone_in_talk,
                  size: 16,
                  color: Color(0xFFD4AF37),
                ),
                label: const Text(
                  'Contact Before Payment',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFB39037)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsContent(
    InvestmentState state,
    InvestmentLocalizations loc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...state.documents.map((doc) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF161D26),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A3644)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  color: Color(0xFFD4AF37),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doc.documentType,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.visibility_outlined,
                  color: Color(0xFFCBD5E1),
                  size: 16,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Speak directly with Belagavi Property LLP investment team:',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 12),
        _buildContactRow('9113219906'),
        const SizedBox(height: 10),
        _buildContactRow('9886615159'),
      ],
    );
  }

  Widget _buildContactRow(String phone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161D26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A3644)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            phone,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _callLLP(phone),
                icon: const Icon(
                  Icons.call,
                  size: 14,
                  color: Color(0xFFD4AF37),
                ),
                label: const Text(
                  'Call',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  side: const BorderSide(color: Color(0xFFB39037)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _whatsAppLLP(phone),
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  size: 14,
                  color: Colors.black,
                ),
                label: const Text(
                  'WhatsApp',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadgeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12171E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB39037).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFB39037).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: Color(0xFFD4AF37),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invest with Confidence',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Project-specific investment only',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: Color(0xFFCBD5E1),
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Review terms before payment',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.headset_mic_outlined,
                      color: Color(0xFFCBD5E1),
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Direct assistance available',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
