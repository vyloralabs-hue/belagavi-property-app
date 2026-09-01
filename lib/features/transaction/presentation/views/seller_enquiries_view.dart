import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/transaction_entities.dart';
import '../providers/transaction_notifier.dart';

class SellerEnquiriesView extends ConsumerStatefulWidget {
  const SellerEnquiriesView({super.key});

  @override
  ConsumerState<SellerEnquiriesView> createState() =>
      _SellerEnquiriesViewState();
}

class _SellerEnquiriesViewState extends ConsumerState<SellerEnquiriesView> {
  TransactionStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(transactionNotifierProvider.notifier).loadEnquiries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionNotifierProvider);
    final allSellerEnquiries = state.sellerEnquiries;

    final filtered = _statusFilter == null
        ? allSellerEnquiries
        : allSellerEnquiries.where((e) => e.status == _statusFilter).toList();

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Inbound Property Enquiries',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/my-properties'),
        ),
      ),
      body: Column(
        children: [
          // Filter status chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('All (${allSellerEnquiries.length})'),
                  selected: _statusFilter == null,
                  selectedColor: AppDesignSystem.primaryNavy,
                  labelStyle: TextStyle(
                    color: _statusFilter == null
                        ? Colors.white
                        : AppDesignSystem.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (sel) {
                    if (sel) setState(() => _statusFilter = null);
                  },
                ),
                const SizedBox(width: 8),
                ...TransactionStatus.values.map((status) {
                  final isSel = _statusFilter == status;
                  final count = allSellerEnquiries
                      .where((e) => e.status == status)
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${status.displayName} ($count)'),
                      selected: isSel,
                      selectedColor: const Color(0xFFB39037),
                      labelStyle: TextStyle(
                        color: isSel
                            ? const Color(0xFF0F172A)
                            : AppDesignSystem.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (sel) {
                        setState(() => _statusFilter = sel ? status : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Enquiries List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? Center(
                    child: Text(
                      'No enquiries found for the selected filter.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final enquiry = filtered[index];
                      return _buildSellerLeadCard(context, enquiry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerLeadCard(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusM,
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Property reference + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    enquiry.propertyTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    enquiry.status.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Buyer Profile row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppDesignSystem.primaryNavy.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    enquiry.buyerName.isNotEmpty ? enquiry.buyerName[0] : 'B',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppDesignSystem.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enquiry.buyerName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.textPrimary,
                        ),
                      ),
                      Text(
                        '${enquiry.buyerPhone} • Contact: ${enquiry.preferredContactMethod}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppDesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    enquiry.financingStatus,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Initial message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                enquiry.initialMessage,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Price / Offer summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Listed Price',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      '₹${enquiry.listedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (enquiry.buyerOfferPrice != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buyer Offer',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        '₹${enquiry.buyerOfferPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                if (enquiry.sellerCounterOfferPrice != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Your Counter',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        '₹${enquiry.sellerCounterOfferPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSiteVisitDialog(context, enquiry);
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 14),
                    label: const Text('Site Visit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showCounterOfferDialog(context, enquiry);
                    },
                    icon: const Icon(Icons.handshake_outlined, size: 14),
                    label: const Text('Counter Offer'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(transactionNotifierProvider.notifier)
                        .selectEnquiry(enquiry.id);
                    context.go('/enquiry/${enquiry.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Manage'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSiteVisitDialog(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'Schedule / Confirm Site Visit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buyer: ${enquiry.buyerName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                'Preferred: ${enquiry.preferredVisitDate ?? 'Flexible'} (${enquiry.preferredVisitTime ?? 'Anytime'})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              const Text(
                'Confirm Scheduled Date:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_month, size: 16),
                label: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(transactionNotifierProvider.notifier)
                    .updateSiteVisit(
                      enquiryId: enquiry.id,
                      status: SiteVisitStatus.scheduled,
                      scheduledDateTime: selectedDate,
                      notes: 'Confirmed by seller for site inspection.',
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Site visit confirmed with buyer!'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryNavy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Visit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCounterOfferDialog(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    final controller = TextEditingController(
      text:
          enquiry.sellerCounterOfferPrice?.toStringAsFixed(0) ??
          enquiry.listedPrice.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Propose Counter Offer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Listed Price: ₹${enquiry.listedPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (enquiry.buyerOfferPrice != null)
              Text(
                'Buyer Offer: ₹${enquiry.buyerOfferPrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                ),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your Counter Offer Amount (₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(
                controller.text.trim().replaceAll(',', ''),
              );
              if (amount != null) {
                ref
                    .read(transactionNotifierProvider.notifier)
                    .submitOffer(
                      enquiryId: enquiry.id,
                      sellerCounterOffer: amount,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Counter offer communicated to buyer!'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Counter Offer'),
          ),
        ],
      ),
    );
  }
}
