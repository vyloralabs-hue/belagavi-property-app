import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:belagavi_property/features/investment/domain/entities/investment_entities.dart';
import 'widgets/request_callback_modal.dart';

class InvestmentProjectDetailView extends StatefulWidget {
  final InvestmentProjectEntity project;

  const InvestmentProjectDetailView({super.key, required this.project});

  static Future<void> show(
    BuildContext context,
    InvestmentProjectEntity project,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => InvestmentProjectDetailView(project: project),
      ),
    );
  }

  @override
  State<InvestmentProjectDetailView> createState() =>
      _InvestmentProjectDetailViewState();
}

class _InvestmentProjectDetailViewState
    extends State<InvestmentProjectDetailView> {
  bool _termsAcknowledged = false;

  Future<void> _callLLP(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsAppLLP(String phone) async {
    final normalized = '91$phone';
    final text = Uri.encodeComponent(
      'Hello Belagavi Property LLP, I am interested in the investment opportunity for project "${widget.project.name}". Please share the next steps.',
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
          'Payment setup is being activated.\n\nPlease contact Belagavi Property LLP investment team or request a callback for bank account details and official documentation.',
          style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              RequestCallbackModal.show(
                context,
                projectId: widget.project.id,
                projectName: widget.project.name,
              );
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

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

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
        title: Text(
          p.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF1E293B), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF12171E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A3644)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB39037).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.status.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        p.propertyType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFD4AF37),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                  if (p.minimumInvestment != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161D26),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFB39037).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Minimum Investment:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            '₹${p.minimumInvestment!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12171E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A3644)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Description & Scope',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFCBD5E1),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact Belagavi Property LLP Support
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12171E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A3644)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Belagavi Property LLP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard('9113219906'),
                  const SizedBox(height: 10),
                  _buildContactCard('9886615159'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Terms Acknowledgment
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161D26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A3644)),
              ),
              child: CheckboxListTile(
                value: _termsAcknowledged,
                onChanged: (v) =>
                    setState(() => _termsAcknowledged = v ?? false),
                activeColor: const Color(0xFFD4AF37),
                checkColor: Colors.black,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'I have read and understood the applicable project terms & risk disclosures.',
                  style: TextStyle(fontSize: 11.5, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CTAs
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => RequestCallbackModal.show(
                      context,
                      projectId: p.id,
                      projectName: p.name,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2A3644)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Request Callback',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _termsAcknowledged
                        ? _showPaymentActivationNotice
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white12,
                      disabledForegroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Invest / Pay',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String phone) {
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
}
