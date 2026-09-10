import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../monetization/domain/entities/payment_entities.dart';
import '../../../monetization/presentation/providers/payment_providers.dart';
import '../../theme/app_design_system.dart';

class BillingPlansHistoryView extends ConsumerWidget {
  const BillingPlansHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingAsync = ref.watch(billingHistoryProvider);
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
              context.go('/profile');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing & Plans History',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: textP,
              ),
            ),
            const Text(
              'Orders & Payment Transactions',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                color: AppDesignSystem.brandGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(billingHistoryProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderCol, height: 1),
        ),
      ),
      body: billingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppDesignSystem.brandGold),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text('Failed to load billing history', style: TextStyle(fontWeight: FontWeight.bold, color: textP)),
                const SizedBox(height: 6),
                Text('$err', style: TextStyle(fontSize: 12, color: textS), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(billingHistoryProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppDesignSystem.brandGold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: AppDesignSystem.brandGold, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Billing Records Yet',
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textP,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When you subscribe to a listing, notice, watch, or unlock plan, your receipts and order details will appear here.',
                      style: TextStyle(fontSize: 12, color: textS, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.push('/pricing-plans'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignSystem.brandGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Explore Plans & Pricing', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = records[index];
              final isPaid = item.status == 'paid';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppDesignSystem.cardBg(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                  boxShadow: AppDesignSystem.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.planCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textP,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPaid ? const Color(0xFF10B981) : Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? const Color(0xFF10B981) : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Family: ${item.productFamily}',
                          style: TextStyle(fontSize: 12, color: textS),
                        ),
                        Text(
                          '₹${item.integerRupees}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isPaid ? const Color(0xFF10B981) : textP,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order: ${item.orderId}',
                          style: TextStyle(fontSize: 11, color: textS),
                        ),
                        Text(
                          '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                          style: TextStyle(fontSize: 11, color: textS),
                        ),
                      ],
                    ),
                    if (item.paymentId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Payment ID: ${item.paymentId}',
                        style: TextStyle(fontSize: 10, color: textS),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
