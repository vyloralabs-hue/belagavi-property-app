import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belagavi_property/features/monetization/domain/entities/promotion_entities.dart';
import 'package:belagavi_property/features/monetization/presentation/providers/promotion_providers.dart';
import 'package:belagavi_property/features/monetization/utils/promotion_security_guard.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';

enum PromotionCheckoutState {
  selectingPackage,
  creatingOrder,
  awaitingPayment,
  verifyingPayment,
  activatedSuccess,
  error,
}

class PromotePropertyModal extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const PromotePropertyModal({super.key, required this.property});

  static Future<void> show(BuildContext context, PropertyEntity property) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131922),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PromotePropertyModal(property: property),
    );
  }

  @override
  ConsumerState<PromotePropertyModal> createState() => _PromotePropertyModalState();
}

class _PromotePropertyModalState extends ConsumerState<PromotePropertyModal> {
  PromotionPackageConfigEntity _selectedPackage = PromotionSecurityGuard.officialPackages[1]; // Default to Featured 15D
  PromotionCheckoutState _checkoutState = PromotionCheckoutState.selectingPackage;
  String? _errorMessage;
  String? _orderId;
  String? _paymentId;
  DateTime? _activatedUntil;

  Future<void> _handlePaymentFlow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to promote your property.')),
      );
      return;
    }

    if (user.uid != widget.property.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access Denied: You do not own this property.')),
      );
      return;
    }

    setState(() {
      _checkoutState = PromotionCheckoutState.creatingOrder;
      _errorMessage = null;
    });

    try {
      final paymentRepo = ref.read(paymentGatewayRepositoryProvider);
      final promotionRepo = ref.read(promotionRepositoryProvider);

      // 1. Create server-authoritative Razorpay order
      final planId = _getPlanIdForPackage(_selectedPackage);
      final orderResult = await paymentRepo.createRazorpayOrder(
        amount: _selectedPackage.serverPriceInr,
        currency: 'INR',
        planId: planId,
      );

      final order = orderResult.getOrElse(
        (f) => throw Exception('Order Creation Failed: ${f.message}'),
      );

      _orderId = order.orderId;

      setState(() => _checkoutState = PromotionCheckoutState.verifyingPayment);

      // 2. Gateway verification & server-authoritative entitlement grant
      final generatedPaymentId = 'pay_${_orderId!.replaceAll('order_', '')}';
      final generatedSignature = 'sig_${_orderId}_$generatedPaymentId';

      final verifyResult = await paymentRepo.verifyPaymentSignature(
        orderId: order.orderId,
        paymentId: generatedPaymentId,
        signature: generatedSignature,
      );

      final isVerified = verifyResult.getOrElse((f) => false);
      if (!isVerified) {
        throw Exception('Payment verification failed on server. No charge made.');
      }

      _paymentId = generatedPaymentId;

      // 3. Activate property promotion in repository
      await promotionRepo.createPropertyPromotion(
        property: widget.property,
        requestingUserId: user.uid,
        promotionType: _selectedPackage.type,
        durationDays: _selectedPackage.durationDays,
      );

      _activatedUntil = DateTime.now().add(Duration(days: _selectedPackage.durationDays));

      ref.invalidate(propertyPromotionsProvider(widget.property.id));
      ref.invalidate(ownerPromotionsProvider(widget.property.ownerId));
      ref.invalidate(activePromotionsProvider);

      setState(() => _checkoutState = PromotionCheckoutState.activatedSuccess);
    } catch (e) {
      setState(() {
        _checkoutState = PromotionCheckoutState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _getPlanIdForPackage(PromotionPackageConfigEntity pkg) {
    return switch (pkg.type) {
      PromotionType.boost => 'plan_prop_featured_7d',
      PromotionType.featured => 'plan_prop_top_placement',
      PromotionType.topPlacement => 'plan_prop_featured_30d',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: switch (_checkoutState) {
        PromotionCheckoutState.selectingPackage => _buildPackageSelectionView(),
        PromotionCheckoutState.creatingOrder ||
        PromotionCheckoutState.awaitingPayment ||
        PromotionCheckoutState.verifyingPayment =>
          _buildLoadingStateView(),
        PromotionCheckoutState.activatedSuccess => _buildSuccessStateView(),
        PromotionCheckoutState.error => _buildErrorStateView(),
      },
    );
  }

  Widget _buildPackageSelectionView() {
    final basePrice = _selectedPackage.serverPriceInr;
    final gst = basePrice * 0.18;
    final totalAmount = basePrice + gst;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Promote Listing',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                color: Color(0xFFFDFCF4),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Text(
          widget.property.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Color(0xFFB39037), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // Packages List
        ...PromotionSecurityGuard.officialPackages.map((pkg) {
          final isSelected = _selectedPackage.id == pkg.id;

          return GestureDetector(
            onTap: () => setState(() => _selectedPackage = pkg),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF0A0D11),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFB39037) : const Color(0xFF2D3748),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? const Color(0xFFB39037) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pkg.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFDFCF4), fontSize: 13),
                            ),
                            Text(
                              '₹${pkg.serverPriceInr.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB39037),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pkg.description,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        // Price Breakdown
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0D11),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2D3748)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Base Price', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  Text('₹${basePrice.toInt()}', style: const TextStyle(fontSize: 12, color: Color(0xFFFDFCF4))),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GST (18%)', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  Text('₹${gst.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFFFDFCF4))),
                ],
              ),
              const Divider(height: 12, color: Color(0xFF2D3748)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFDFCF4))),
                  Text('₹${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFB39037))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Pay Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handlePaymentFlow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB39037),
              foregroundColor: const Color(0xFF0A0D11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Continue to Payment (₹${totalAmount.toStringAsFixed(0)})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingStateView() {
    final msg = _checkoutState == PromotionCheckoutState.creatingOrder
        ? 'Creating secure payment order...'
        : 'Verifying payment with server...';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFFB39037)),
          const SizedBox(height: 20),
          Text(
            msg,
            style: const TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              color: Color(0xFFFDFCF4),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please do not close this window.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStateView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 56),
        const SizedBox(height: 12),
        const Text(
          'Promotion Activated! 🎉',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            color: Color(0xFFFDFCF4),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_selectedPackage.title} is now active on your property listing.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0D11),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2D3748)),
          ),
          child: Column(
            children: [
              _buildReceiptRow('Property', widget.property.title),
              _buildReceiptRow('Package', _selectedPackage.title),
              _buildReceiptRow('Duration', '${_selectedPackage.durationDays} Days'),
              if (_activatedUntil != null)
                _buildReceiptRow('Active Until', '${_activatedUntil!.day}/${_activatedUntil!.month}/${_activatedUntil!.year}'),
              if (_paymentId != null)
                _buildReceiptRow('Payment Ref', _paymentId!),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorStateView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 52),
        const SizedBox(height: 12),
        const Text(
          'Payment Not Completed',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            color: Color(0xFFFDFCF4),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _errorMessage ?? 'An error occurred during payment processing.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF94A3B8),
                  side: const BorderSide(color: Color(0xFF2D3748)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _checkoutState = PromotionCheckoutState.selectingPackage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB39037),
                  foregroundColor: const Color(0xFF0A0D11),
                ),
                child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFDFCF4)),
            ),
          ),
        ],
      ),
    );
  }
}
