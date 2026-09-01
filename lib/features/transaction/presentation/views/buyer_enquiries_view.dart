import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/transaction_entities.dart';
import '../providers/transaction_notifier.dart';

class BuyerEnquiriesView extends ConsumerStatefulWidget {
  const BuyerEnquiriesView({super.key});

  @override
  ConsumerState<BuyerEnquiriesView> createState() => _BuyerEnquiriesViewState();
}

class _BuyerEnquiriesViewState extends ConsumerState<BuyerEnquiriesView> {
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
    final enquiries = state.buyerEnquiries;

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'My Enquiries & Visits',
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
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : enquiries.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: enquiries.length,
              itemBuilder: (context, index) {
                final item = enquiries[index];
                return _buildEnquiryCard(context, item);
              },
            ),
    );
  }

  Widget _buildEnquiryCard(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    final status = enquiry.status;
    final visitStatus = enquiry.siteVisitStatus;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusM,
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 1,
      child: InkWell(
        borderRadius: AppDesignSystem.borderRadiusM,
        onTap: () {
          ref
              .read(transactionNotifierProvider.notifier)
              .selectEnquiry(enquiry.id);
          context.go('/enquiry/${enquiry.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Type badge + Status pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.primaryNavy.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${enquiry.propertyCategory} • ${enquiry.interestType.displayName}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppDesignSystem.primaryNavy,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Property Title
              Text(
                enquiry.propertyTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                enquiry.propertyLocation,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Price & Negotiation summary
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Your Offer',
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
                            'Seller Counter',
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
              ),
              const SizedBox(height: 12),

              // Step Progress Tracker
              _buildProgressStepper(status),
              const SizedBox(height: 12),

              // Site Visit / Doc Status note
              if (visitStatus != SiteVisitStatus.none)
                Row(
                  children: [
                    const Icon(
                      Icons.event_available_outlined,
                      size: 14,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Site Visit: ${visitStatus.displayName} (${enquiry.preferredVisitDate ?? 'Pending'})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStepper(TransactionStatus current) {
    const steps = ['Enquiry', 'Visit', 'Negotiation', 'Verification', 'Closed'];

    final currentIndex = switch (current) {
      TransactionStatus.newEnquiry ||
      TransactionStatus.contacted ||
      TransactionStatus.inDiscussion => 0,
      TransactionStatus.siteVisit ||
      TransactionStatus.siteVisitRequested ||
      TransactionStatus.siteVisitScheduled => 1,
      TransactionStatus.negotiation => 2,
      TransactionStatus.documents ||
      TransactionStatus.documentVerification => 3,
      TransactionStatus.closed => 4,
      TransactionStatus.rejected => 0,
    };

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = i ~/ 2;
          final isPassed = stepIdx < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isPassed ? const Color(0xFF15803D) : Colors.grey.shade300,
            ),
          );
        } else {
          final stepIdx = i ~/ 2;
          final isDone = stepIdx <= currentIndex;
          final isCurrent = stepIdx == currentIndex;
          return Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? (isCurrent
                            ? AppDesignSystem.primaryNavy
                            : const Color(0xFF15803D))
                      : Colors.grey.shade300,
                ),
                child: isDone && !isCurrent
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 2),
              Text(
                steps[stepIdx],
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent
                      ? AppDesignSystem.primaryNavy
                      : Colors.grey.shade600,
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Color _getStatusBgColor(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.newEnquiry => const Color(0xFFFEF3C7),
      TransactionStatus.contacted ||
      TransactionStatus.inDiscussion ||
      TransactionStatus.siteVisit ||
      TransactionStatus.siteVisitRequested ||
      TransactionStatus.siteVisitScheduled => const Color(0xFFE0F2FE),
      TransactionStatus.negotiation => const Color(0xFFF3E8FF),
      TransactionStatus.documents ||
      TransactionStatus.documentVerification => const Color(0xFFFFFBEB),
      TransactionStatus.closed => const Color(0xFFDCFCE7),
      TransactionStatus.rejected => const Color(0xFFF1F5F9),
    };
  }

  Color _getStatusTextColor(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.newEnquiry => const Color(0xFFB45309),
      TransactionStatus.contacted ||
      TransactionStatus.inDiscussion ||
      TransactionStatus.siteVisit ||
      TransactionStatus.siteVisitRequested ||
      TransactionStatus.siteVisitScheduled => const Color(0xFF0284C7),
      TransactionStatus.negotiation => const Color(0xFF7C3AED),
      TransactionStatus.documents ||
      TransactionStatus.documentVerification => const Color(0xFFD97706),
      TransactionStatus.closed => const Color(0xFF15803D),
      TransactionStatus.rejected => const Color(0xFF64748B),
    };
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Enquiries Sent Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse properties and tap "I\'m Interested" to schedule a site visit or propose an offer directly to property owners.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryNavy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Explore Properties'),
            ),
          ],
        ),
      ),
    );
  }
}
