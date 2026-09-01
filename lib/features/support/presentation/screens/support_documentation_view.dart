import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/support_entities.dart';
import '../widgets/document_service_card.dart';

/// Premium Documentation Services Screen
class SupportDocumentationView extends StatelessWidget {
  const SupportDocumentationView({super.key});

  static const _services = [
    DocumentServiceEntity(
      id: 'doc_1',
      title: 'Encumbrance Certificate (EC)',
      description:
          'Official record of all registered transactions on a property. Essential for buying, selling, and home loans.',
      serviceType: 'encumbrance',
      fee: 499,
      isFree: false,
      turnaround: '2–3 working days',
      iconEmoji: '📜',
    ),
    DocumentServiceEntity(
      id: 'doc_2',
      title: 'Khata Certificate',
      description:
          'Municipal document certifying property ownership for tax purposes. Required for registrations and licences.',
      serviceType: 'khata',
      fee: 0,
      isFree: true,
      turnaround: '3–5 working days',
      iconEmoji: '🏛️',
    ),
    DocumentServiceEntity(
      id: 'doc_3',
      title: 'Property Registration Guidance',
      description:
          'Expert guidance through the entire property registration process at the Sub-Registrar Office, Belagavi.',
      serviceType: 'registration',
      fee: 999,
      isFree: false,
      turnaround: '1 working day',
      iconEmoji: '✍️',
    ),
    DocumentServiceEntity(
      id: 'doc_4',
      title: 'Legal Title Opinion',
      description:
          'Comprehensive legal review of property title documents to confirm clear and marketable title.',
      serviceType: 'legal_opinion',
      fee: 1999,
      isFree: false,
      turnaround: '5–7 working days',
      iconEmoji: '⚖️',
    ),
    DocumentServiceEntity(
      id: 'doc_5',
      title: 'RTC / 7-12 Extract',
      description:
          'Revenue department extract showing land ownership, survey number, and crop details. Essential for agricultural and plot transactions.',
      serviceType: 'rtc',
      fee: 0,
      isFree: true,
      turnaround: '1–2 working days',
      iconEmoji: '🌾',
    ),
    DocumentServiceEntity(
      id: 'doc_6',
      title: 'RERA Verification',
      description:
          'Verify builder project RERA registration and compliance status directly from Karnataka RERA portal.',
      serviceType: 'rera',
      fee: 0,
      isFree: true,
      turnaround: 'Instant',
      iconEmoji: '🏗️',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Documentation Services',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),
          const Text(
            'Available Services',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          ..._services.map(
            (service) => DocumentServiceCard(
              emoji: service.iconEmoji,
              title: service.title,
              description: service.description,
              fee: service.fee,
              isFree: service.isFree,
              turnaround: service.turnaround,
              isPremiumOnly: service.isPremiumOnly,
              onRequest: () => _showRequestDialog(context, service),
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomRequestCard(context),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: AppDesignSystem.borderRadiusL,
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppDesignSystem.primaryNavy,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PropertyHub Documentation Assistance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Our team of property documentation experts helps you navigate Belagavi's land records, registration offices, and legal requirements with ease.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppDesignSystem.textSecondary,
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

  Widget _buildCustomRequestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), AppDesignSystem.primaryNavy],
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline_rounded,
            color: Colors.white70,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a Custom Service?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Contact us for bespoke documentation assistance',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppDesignSystem.primaryNavy,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusPill,
              ),
            ),
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog(BuildContext context, DocumentServiceEntity service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDesignSystem.borderRadiusL,
        ),
        title: Text(
          'Request ${service.title}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.description,
              style: const TextStyle(
                color: AppDesignSystem.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee_rounded,
                  size: 14,
                  color: AppDesignSystem.primaryNavy,
                ),
                Text(
                  service.isFree
                      ? 'Free Service'
                      : '₹${service.fee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppDesignSystem.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  service.turnaround,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ctx.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Request submitted! Our team will contact you shortly.',
                  ),
                  backgroundColor: AppDesignSystem.accentEmerald,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
            ),
            child: const Text(
              'Confirm Request',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
