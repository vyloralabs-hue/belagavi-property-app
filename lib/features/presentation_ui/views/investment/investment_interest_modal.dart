import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/investment/presentation/providers/investment_notifier.dart';
import '../../theme/app_design_system.dart';

class InvestmentInterestModal extends ConsumerStatefulWidget {
  const InvestmentInterestModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const InvestmentInterestModal(),
    );
  }

  @override
  ConsumerState<InvestmentInterestModal> createState() =>
      _InvestmentInterestModalState();
}

class _InvestmentInterestModalState
    extends ConsumerState<InvestmentInterestModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController(text: 'Belagavi');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _regionController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  String _preferredContactMethod = 'WhatsApp';
  bool _consentAccepted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _regionController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentNotifierProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Register Interest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.config.legalEntityName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppDesignSystem.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter full name'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter mobile number'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address (Optional)',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City *'),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'State *'),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'Interested Region (Optional)',
                  hintText: 'e.g. Shahapur, Tilakwadi',
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Indicative Interest Amount (₹) (Optional)',
                  hintText: 'e.g. 500000',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _preferredContactMethod,
                decoration: const InputDecoration(
                  labelText: 'Preferred Contact Method',
                ),
                items: const [
                  DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp')),
                  DropdownMenuItem(value: 'Call', child: Text('Phone Call')),
                  DropdownMenuItem(value: 'Email', child: Text('Email')),
                ],
                onChanged: (val) {
                  if (val != null)
                    setState(() => _preferredContactMethod = val);
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _messageController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Message / Notes (Optional)',
                ),
              ),
              const SizedBox(height: 14),

              // Consent Checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _consentAccepted,
                activeColor: AppDesignSystem.primaryNavy,
                title: const Text(
                  'I acknowledge that submitting this form is for information and interest registration only. It does NOT constitute an investment, acceptance of funds, or guaranteed returns.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                onChanged: (val) =>
                    setState(() => _consentAccepted = val ?? false),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || !_consentAccepted)
                      ? null
                      : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Interest',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final amount = double.tryParse(_amountController.text.trim());

    final notifier = ref.read(investmentNotifierProvider.notifier);
    await notifier.submitInvestmentInterest(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      city: _cityController.text.trim(),
      stateName: _stateController.text.trim(),
      indicativeInterestAmount: amount,
      preferredContactMethod: _preferredContactMethod,
      message:
          [
            if (_regionController.text.trim().isNotEmpty)
              'Region of interest: ${_regionController.text.trim()}',
            if (_messageController.text.trim().isNotEmpty)
              _messageController.text.trim(),
          ].where((s) => s.isNotEmpty).join(' | ').isNotEmpty
          ? [
              if (_regionController.text.trim().isNotEmpty)
                'Region of interest: ${_regionController.text.trim()}',
              if (_messageController.text.trim().isNotEmpty)
                _messageController.text.trim(),
            ].join(' | ')
          : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Interest submitted successfully to Belagavi Property LLP. Our team will contact you.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
