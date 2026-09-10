import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/monetization/domain/entities/pricing_plan_entity.dart';
import 'package:belagavi_property/features/monetization/presentation/providers/pricing_providers.dart';
import 'package:belagavi_property/features/monetization/presentation/providers/payment_providers.dart';
import 'package:belagavi_property/features/monetization/presentation/services/razorpay_checkout_service.dart';
import '../../theme/app_design_system.dart';

/// Server-Authoritative Pricing Plans Catalog View.
/// Displays dynamic plans from Supabase backend.
/// Strictly adheres to:
/// - Zero hardcoded Rupee amounts (all fetched from backend pricing_plans)
/// - Strict product family separation
/// - Payment placeholder only (NO fake client-side entitlement activation)
class PricingPlansView extends ConsumerStatefulWidget {
  final String? initialProductFamily;
  final String? propertyId;

  const PricingPlansView({
    super.key,
    this.initialProductFamily,
    this.propertyId,
  });

  @override
  ConsumerState<PricingPlansView> createState() => _PricingPlansViewState();
}

class _PricingPlansViewState extends ConsumerState<PricingPlansView> {
  late String _selectedFamily;

  final List<Map<String, String>> _families = [
    {'key': 'residential_listing', 'label': 'Residential'},
    {'key': 'commercial_listing', 'label': 'Commercial'},
    {'key': 'legal_notice_publication', 'label': 'Legal Notice'},
    {'key': 'dispute_publication', 'label': 'Disputes'},
    {'key': 'property_watch', 'label': 'Property Watch'},
    {'key': 'survey_monitoring', 'label': 'Survey Watch'},
    {'key': 'buyer_unlock', 'label': 'Buyer Unlock'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFamily = widget.initialProductFamily ?? 'residential_listing';
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(activePricingPlansProvider);

    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final isDark = AppDesignSystem.isDark(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plans & Pricing',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: textP,
              ),
            ),
            const Text(
              'Server-Authoritative Catalog',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                color: AppDesignSystem.brandGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderCol, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Family Filter Pills
          Container(
            height: 52,
            color: surfaceBg,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _families.length,
              itemBuilder: (context, index) {
                final family = _families[index];
                final isSelected = _selectedFamily == family['key'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFamily = family['key']!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppDesignSystem.brandGold
                          : (isDark ? const Color(0xFF131922) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppDesignSystem.brandGold : borderCol,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      family['label']!,
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? Colors.black : textS,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: borderCol),

          // Family Banner Info / Disclaimers
          _buildFamilyBanner(context, _selectedFamily),

          // Plans List
          Expanded(
            child: plansAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load pricing catalog: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              data: (plans) {
                final filtered = plans
                    .where((p) => p.productFamily == _selectedFamily)
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No active plans found for this category.',
                      style: TextStyle(color: textS),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final plan = filtered[index];
                    return _buildPlanCard(context, plan);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyBanner(BuildContext context, String family) {
    String message = '';
    Color iconColor = AppDesignSystem.brandGold;
    IconData icon = Icons.info_outline_rounded;

    switch (family) {
      case 'residential_listing':
        message = 'New residential listings receive 15 Days FREE. Choose a plan to extend or reactivate.';
        break;
      case 'commercial_listing':
        message = 'Commercial listings require a paid plan from Day 1. No free period applies.';
        iconColor = Colors.amber.shade800;
        break;
      case 'legal_notice_publication':
        message = 'Platform publication only. Does NOT establish statutory court service or legal validity.';
        icon = Icons.gavel_outlined;
        break;
      case 'dispute_publication':
        message = 'Dispute watch is 100% FREE. Publication does not establish that allegations are legally proven.';
        icon = Icons.warning_amber_rounded;
        break;
      case 'property_watch':
        message = 'Normal property watch requires paid entitlement from watch #1. No free trial.';
        break;
      case 'survey_monitoring':
        message = 'Continuous survey number tracking. Paid monitoring quota from first watch.';
        break;
      case 'buyer_unlock':
        message = 'Access verified owner direct contact & exact address. Choose credits below.';
        icon = Icons.lock_open_rounded;
        break;
    }

    final isDark = AppDesignSystem.isDark(context);
    final textS = AppDesignSystem.textS(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? const Color(0xFF131922) : const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                color: textS,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PricingPlanEntity plan) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textP,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppDesignSystem.brandGold, width: 0.8),
                ),
                child: Text(
                  plan.durationLabel,
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                plan.formattedPrice,
                style: const TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppDesignSystem.brandGold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                plan.isBuyerUnlock
                    ? '/ ${plan.creditCount} ${plan.creditCount == 1 ? 'Property' : 'Properties'}'
                    : '/ ${plan.durationLabel}',
                style: TextStyle(
                  fontSize: 12,
                  color: textS,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _handleChoosePlan(context, plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Choose Plan — ${plan.formattedPrice}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChoosePlan(BuildContext context, PricingPlanEntity plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to subscribe to a plan.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      context.push('/auth');
      return;
    }

    final isMock = RazorpayCheckoutService.instance.isMockGateway;

    // Show Order Confirmation and Checkout Dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment_rounded, color: AppDesignSystem.brandGold, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Checkout — ${plan.name}',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.textP(modalContext),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.isDark(context)
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppDesignSystem.borderCol(context)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Plan Price', style: TextStyle(color: AppDesignSystem.textS(context), fontSize: 13)),
                            Text(plan.formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Validity', style: TextStyle(color: AppDesignSystem.textS(context), fontSize: 13)),
                            Text(plan.durationLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        if (plan.creditCount > 1) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quota / Credits', style: TextStyle(color: AppDesignSystem.textS(context), fontSize: 13)),
                              Text('${plan.creditCount} unlocks', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isMock)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFFB45309)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Live payment gateway credentials pending. Sandbox test checkout available.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              try {
                                final notifier = ref.read(paymentProcessNotifierProvider.notifier);
                                final order = await notifier.createOrder(
                                  planCode: plan.code,
                                  targetId: widget.propertyId,
                                );

                                if (order == null) {
                                  setModalState(() => isSubmitting = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ref.read(paymentProcessNotifierProvider).errorMessage ?? 'Order creation failed'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                  return;
                                }

                                if (isMock) {
                                  // Perform instant server-side verification in mock mode
                                  final mockPayId = 'pay_mock_${DateTime.now().millisecondsSinceEpoch}';
                                  final verifyRes = await notifier.completePayment(
                                    orderId: order.orderId,
                                    paymentId: mockPayId,
                                    signature: 'mock_signature',
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(modalContext);
                                    if (verifyRes != null && verifyRes.success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Plan "${plan.name}" successfully activated!'),
                                          backgroundColor: const Color(0xFF10B981),
                                        ),
                                      );
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/property-vault');
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Payment verification failed.'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Trigger physical Razorpay Checkout
                                  RazorpayCheckoutService.instance.initialize(
                                    onSuccess: (response) async {
                                      final verifyRes = await notifier.completePayment(
                                        orderId: order.orderId,
                                        paymentId: response.paymentId ?? '',
                                        signature: response.signature,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(modalContext);
                                        if (verifyRes != null && verifyRes.success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Plan "${plan.name}" successfully activated!'),
                                              backgroundColor: const Color(0xFF10B981),
                                            ),
                                          );
                                          context.pop();
                                        }
                                      }
                                    },
                                    onFailure: (response) {
                                      setModalState(() => isSubmitting = false);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Payment cancelled: ${response.message}'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                                  );

                                  RazorpayCheckoutService.instance.openCheckout(
                                    order: order,
                                    userEmail: user.email ?? 'user@belagaviproperty.com',
                                    userPhone: user.phoneNumber ?? '+919999999999',
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSubmitting = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text(
                              isMock ? 'Proceed with Test Checkout' : 'Proceed to Pay ${plan.formattedPrice}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
