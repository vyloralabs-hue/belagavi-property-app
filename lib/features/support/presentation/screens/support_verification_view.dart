import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';

/// Property Verification Assistance Screen
class SupportVerificationView extends StatefulWidget {
  const SupportVerificationView({super.key});

  @override
  State<SupportVerificationView> createState() =>
      _SupportVerificationViewState();
}

class _SupportVerificationViewState extends State<SupportVerificationView> {
  final _propertyIdController = TextEditingController();
  final _addressController = TextEditingController();
  bool _submitted = false;

  static const _services = [
    _VerificationService(
      icon: Icons.fact_check_rounded,
      iconBg: Color(0xFFEFF6FF),
      iconColor: AppDesignSystem.primaryNavy,
      title: 'Document Verification',
      description:
          'Sale deed, title chain, and encumbrance check by our experts.',
      duration: '3–5 days',
    ),
    _VerificationService(
      icon: Icons.location_on_rounded,
      iconBg: Color(0xFFD1FAE5),
      iconColor: AppDesignSystem.accentEmerald,
      title: 'Physical Site Visit',
      description:
          'Our agent visits the property to verify dimensions, boundaries, and condition.',
      duration: '1–2 days',
    ),
    _VerificationService(
      icon: Icons.gavel_rounded,
      iconBg: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      title: 'Legal Due Diligence',
      description:
          'Comprehensive check for liens, disputes, and ownership clarity.',
      duration: '5–7 days',
    ),
    _VerificationService(
      icon: Icons.shield_rounded,
      iconBg: Color(0xFFEDE9FE),
      iconColor: Color(0xFF7C3AED),
      title: 'RERA Compliance Check',
      description:
          'Verify builder RERA registration and project compliance status.',
      duration: 'Instant',
    ),
  ];

  @override
  void dispose() {
    _propertyIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Property Verification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
            fontSize: 17,
          ),
        ),
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
      ),
      body: _submitted
          ? _buildSuccessState(context)
          : _buildRequestForm(context),
    );
  }

  Widget _buildRequestForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _buildTrustBanner(),
        const SizedBox(height: 24),
        const Text(
          'Verification Services',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        ..._services.map(_buildServiceCard),
        const SizedBox(height: 24),
        const Text(
          'Request Verification',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        _buildRequestForm2(),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed:
                _propertyIdController.text.isNotEmpty ||
                    _addressController.text.isNotEmpty
                ? () => setState(() => _submitted = true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusL,
              ),
              elevation: 0,
            ),
            child: const Text(
              'Submit Verification Request',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), AppDesignSystem.primaryNavy],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: Colors.white, size: 36),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PropertyHub Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Our team physically verifies documents, title, and ownership before granting the ✓ Verified badge.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(_VerificationService s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: s.iconBg,
              borderRadius: AppDesignSystem.borderRadiusM,
            ),
            child: Icon(s.icon, color: s.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignSystem.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppDesignSystem.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                s.duration,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestForm2() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Property Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _propertyIdController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Property ID (optional)',
              hintText: 'e.g. PROP_2291',
              prefixIcon: Icon(Icons.tag_rounded, size: 18),
              border: const OutlineInputBorder(
                borderRadius: AppDesignSystem.borderRadiusM,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDesignSystem.borderRadiusM,
                borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDesignSystem.borderRadiusM,
                borderSide: BorderSide(
                  color: AppDesignSystem.primaryNavy,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Property Address',
              hintText: 'Full address with locality, Belagavi…',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on_outlined, size: 18),
              ),
              border: const OutlineInputBorder(
                borderRadius: AppDesignSystem.borderRadiusM,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDesignSystem.borderRadiusM,
                borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDesignSystem.borderRadiusM,
                borderSide: BorderSide(
                  color: AppDesignSystem.primaryNavy,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 44,
                color: AppDesignSystem.accentEmerald,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Verification Request Submitted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our team will review the property details and contact you within 24 hours. You can track the status in My Tickets.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppDesignSystem.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.push('/support/tickets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryNavy,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDesignSystem.borderRadiusL,
                  ),
                ),
                child: const Text(
                  'Track in My Tickets',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Support'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationService {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final String duration;

  const _VerificationService({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.duration,
  });
}
