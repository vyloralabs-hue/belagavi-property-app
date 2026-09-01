import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:belagavi_property/features/investment/presentation/providers/investment_notifier.dart';

class RequestCallbackModal extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectName;

  const RequestCallbackModal({super.key, this.projectId, this.projectName});

  static Future<void> show(
    BuildContext context, {
    String? projectId,
    String? projectName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0D11),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: RequestCallbackModal(
          projectId: projectId,
          projectName: projectName,
        ),
      ),
    );
  }

  @override
  ConsumerState<RequestCallbackModal> createState() =>
      _RequestCallbackModalState();
}

class _RequestCallbackModalState extends ConsumerState<RequestCallbackModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _preferredTime = 'Anytime';
  bool _submitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      await ref
          .read(investmentNotifierProvider.notifier)
          .requestCallback(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            preferredTime: _preferredTime,
            message: _messageController.text.trim(),
            projectId: widget.projectId,
            projectName: widget.projectName,
          );
      setState(() {
        _submitted = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsAppNumber(String phone) async {
    final normalized = '91$phone';
    final text = Uri.encodeComponent(
      widget.projectName != null
          ? 'Hello Belagavi Property LLP, I requested a callback for investment project "${widget.projectName}". Please connect with me.'
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

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _buildConfirmationView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB39037).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.headset_mic_outlined,
                    color: Color(0xFFD4AF37),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Callback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Belagavi Property LLP Investment Team',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB39037),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.projectName != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D26),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A3644)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.business_rounded,
                      color: Color(0xFFD4AF37),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Project: ${widget.projectName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade800),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Name Field
            const Text(
              'Your Name *',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hint: 'Enter your full name',
                icon: Icons.person_outline,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 14),
            // Phone Field
            const Text(
              'Mobile Number *',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hint: '10-digit mobile number',
                icon: Icons.phone_outlined,
                prefixText: '+91 ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Please enter mobile number';
                final clean = v.replaceAll(RegExp(r'\D'), '');
                if (clean.length < 10) return 'Enter a valid 10-digit number';
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Preferred Contact Time
            const Text(
              'Preferred Time for Callback',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _preferredTime,
              dropdownColor: const Color(0xFF161D26),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _inputDecoration(
                hint: 'Select time',
                icon: Icons.access_time,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Anytime',
                  child: Text('Anytime (10 AM - 7 PM)'),
                ),
                DropdownMenuItem(
                  value: 'Morning',
                  child: Text('Morning (10 AM - 1 PM)'),
                ),
                DropdownMenuItem(
                  value: 'Afternoon',
                  child: Text('Afternoon (1 PM - 4 PM)'),
                ),
                DropdownMenuItem(
                  value: 'Evening',
                  child: Text('Evening (4 PM - 7 PM)'),
                ),
              ],
              onChanged: (val) =>
                  setState(() => _preferredTime = val ?? 'Anytime'),
            ),
            const SizedBox(height: 14),
            // Message
            const Text(
              'Message / Questions (Optional)',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _messageController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hint: 'Share specific questions or investment range',
                icon: Icons.chat_outlined,
              ),
            ),
            const SizedBox(height: 20),
            // Submit CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Request Callback',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB39037).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFFD4AF37),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Callback Request Received',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Belagavi Property LLP investment team will contact you shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF161D26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A3644)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Or Connect Immediately:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDirectContactRow('9113219906'),
                const Divider(color: Color(0xFF2A3644), height: 16),
                _buildDirectContactRow('9886615159'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF2A3644)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectContactRow(String phone) {
    return Row(
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
              onPressed: () => _callNumber(phone),
              icon: const Icon(Icons.call, size: 14, color: Color(0xFFD4AF37)),
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
              onPressed: () => _whatsAppNumber(phone),
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
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
      filled: true,
      fillColor: const Color(0xFF161D26),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A3644)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A3644)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
      ),
    );
  }
}
