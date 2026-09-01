import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';

class PaymentGatewayView extends StatefulWidget {
  final String planName;
  final String amount;

  const PaymentGatewayView({
    super.key,
    this.planName = 'Standard Plan',
    this.amount = '₹599',
  });

  @override
  State<PaymentGatewayView> createState() => _PaymentGatewayViewState();
}

class _PaymentGatewayViewState extends State<PaymentGatewayView> {
  String _selectedMethod = 'UPI';

  static const List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'UPI',
      'title': 'UPI (Google Pay, PhonePe, Paytm, BHIM)',
      'icon': Icons.qr_code_2_rounded,
      'subtitle': 'Instant zero-fee transfer via any UPI app',
    },
    {
      'id': 'Card',
      'title': 'Credit / Debit Card',
      'icon': Icons.credit_card_rounded,
      'subtitle': 'Visa, Mastercard, RuPay & Diners',
    },
    {
      'id': 'NetBanking',
      'title': 'Net Banking',
      'icon': Icons.account_balance_rounded,
      'subtitle': 'All major Indian commercial banks',
    },
  ];

  void _processPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppDesignSystem.accentEmerald,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.w700,
                color: AppDesignSystem.textPrimary,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Your subscription for ${widget.planName} (${widget.amount}) is now active.\nTransaction ID: PAY_${DateTime.now().millisecondsSinceEpoch}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 13,
            color: AppDesignSystem.textSecondary,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go to Home Dashboard'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Secure Payment Checkout',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            color: AppDesignSystem.primaryBlue,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppDesignSystem.primaryBlue.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER SUMMARY',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppDesignSystem.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.planName,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppDesignSystem.textPrimary,
                          ),
                        ),
                        Text(
                          widget.amount,
                          style: const TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppDesignSystem.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ..._paymentMethods.map((method) {
                final isSelected = _selectedMethod == method['id'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedMethod = method['id'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppDesignSystem.softShadow,
                      border: Border.all(
                        color: isSelected
                            ? AppDesignSystem.primaryBlue
                            : AppDesignSystem.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          method['icon'] as IconData,
                          size: 28,
                          color: AppDesignSystem.primaryBlue,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title'] as String,
                                style: const TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppDesignSystem.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method['subtitle'] as String,
                                style: const TextStyle(
                                  fontFamily: AppDesignSystem.fontFamily,
                                  fontSize: 11,
                                  color: AppDesignSystem.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: method['id'] as String,
                          groupValue: _selectedMethod,
                          activeColor: AppDesignSystem.primaryBlue,
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedMethod = val);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Proceed to Pay ${widget.amount}',
                    style: const TextStyle(
                      fontFamily: AppDesignSystem.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: AppDesignSystem.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '256-Bit SSL Encrypted Bank-Grade Razorpay Checkout',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 11,
                        color: AppDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
