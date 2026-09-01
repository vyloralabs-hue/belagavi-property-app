import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/transaction_entities.dart';
import '../providers/transaction_notifier.dart';

class EnquiryDetailWorkflowView extends ConsumerStatefulWidget {
  final String enquiryId;

  const EnquiryDetailWorkflowView({super.key, required this.enquiryId});

  @override
  ConsumerState<EnquiryDetailWorkflowView> createState() =>
      _EnquiryDetailWorkflowViewState();
}

class _EnquiryDetailWorkflowViewState
    extends ConsumerState<EnquiryDetailWorkflowView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(transactionNotifierProvider.notifier)
          .selectEnquiry(widget.enquiryId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionNotifierProvider);
    final enquiry = state.selectedEnquiry;

    if (enquiry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Transaction & Deal Hub',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/my-enquiries'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Property & Status Header Card ────────────────────────────────
            _buildHeaderCard(context, enquiry),
            const SizedBox(height: 16),

            // ─── 2. Step 1: Inception & Participant Details ──────────────────────
            _buildParticipantCard(enquiry),
            const SizedBox(height: 16),

            // ─── 3. Step 2: Site Visit Scheduling & Safety ───────────────────────
            _buildSiteVisitCard(context, enquiry),
            const SizedBox(height: 16),

            // ─── 4. Step 3: Price Negotiation & Offer History ────────────────────
            _buildNegotiationCard(context, enquiry),
            const SizedBox(height: 16),

            // ─── 5. Step 4: Document Verification Tracker ────────────────────────
            _buildDocVerificationCard(context, enquiry),
            const SizedBox(height: 16),

            // ─── 6. Statutory Disclaimer ─────────────────────────────────────────
            _buildDisclaimerCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, PropertyEnquiryEntity enquiry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(
          color: const Color(0xFFB39037).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39037).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${enquiry.propertyCategory.toUpperCase()} • ${enquiry.interestType.displayName.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB39037),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  enquiry.status.displayName,
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFDFCF4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            enquiry.propertyTitle,
            style: const TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFDFCF4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            enquiry.propertyLocation,
            style: const TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(PropertyEnquiryEntity enquiry) {
    return _buildSectionBox(
      title: '1. Contact & Participant Information',
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Buyer Name', enquiry.buyerName),
          _buildRow('Buyer Phone', enquiry.buyerPhone),
          if (enquiry.buyerEmail != null)
            _buildRow('Buyer Email', enquiry.buyerEmail!),
          _buildRow('Preferred Contact', enquiry.preferredContactMethod),
          _buildRow('Financing Status', enquiry.financingStatus),
          const SizedBox(height: 6),
          const Text(
            'Initial Message:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            enquiry.initialMessage,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteVisitCard(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    final visitStatus = enquiry.siteVisitStatus;
    final scheduledDate = enquiry.scheduledVisitDateTime;

    return _buildSectionBox(
      title: '2. Site Inspection & Visit Management',
      icon: Icons.calendar_month_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Visit Status: ${visitStatus.displayName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (visitStatus == SiteVisitStatus.confirmed ||
                  visitStatus == SiteVisitStatus.completed)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF15803D),
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (scheduledDate != null)
            Text(
              'Confirmed Scheduled Date: ${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0284C7),
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              'Requested Date / Slot: ${enquiry.preferredVisitDate ?? 'Flexible'} (${enquiry.preferredVisitTime ?? 'Morning'})',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (enquiry.siteVisitNotes != null) ...[
            const SizedBox(height: 6),
            Text(
              'Notes: ${enquiry.siteVisitNotes}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 10),

          // Safety reminder
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Safety Notice: Please independently verify physical boundaries and property condition before financial commitments.',
                    style: TextStyle(fontSize: 10, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () {
                  ref
                      .read(transactionNotifierProvider.notifier)
                      .respondToSiteVisit(
                        enquiryId: enquiry.id,
                        status: SiteVisitStatus.confirmed,
                        scheduledDateTime: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        notes: 'Visit confirmed by property owner/agent.',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Site visit confirmed!'),
                      backgroundColor: Color(0xFF15803D),
                    ),
                  );
                },
                child: const Text(
                  'Confirm Visit',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  _showRescheduleDialog(context, enquiry);
                },
                child: const Text('Reschedule', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  ref
                      .read(transactionNotifierProvider.notifier)
                      .respondToSiteVisit(
                        enquiryId: enquiry.id,
                        status: SiteVisitStatus.completed,
                        notes:
                            'Site inspection completed by prospective buyer.',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Visit marked as completed!'),
                      backgroundColor: Color(0xFF15803D),
                    ),
                  );
                },
                child: const Text(
                  'Mark Completed',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(transactionNotifierProvider.notifier)
                      .respondToSiteVisit(
                        enquiryId: enquiry.id,
                        status: SiteVisitStatus.cancelled,
                        notes: 'Visit cancelled by user.',
                      );
                },
                child: const Text(
                  'Cancel Visit',
                  style: TextStyle(fontSize: 11, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiationCard(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    final history = enquiry.negotiationHistory;

    return _buildSectionBox(
      title: '3. Price Offer & Negotiation History',
      icon: Icons.handshake_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pricing Summary Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Latest Buyer Offer',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      enquiry.buyerOfferPrice != null
                          ? '₹${enquiry.buyerOfferPrice!.toStringAsFixed(0)}'
                          : '—',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Owner Counter',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      enquiry.sellerCounterOfferPrice != null
                          ? '₹${enquiry.sellerCounterOfferPrice!.toStringAsFixed(0)}'
                          : '—',
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

          if (enquiry.currentNegotiatedAmount != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: enquiry.offerStatus == OfferLifecycleStatus.accepted
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                enquiry.offerStatus == OfferLifecycleStatus.accepted
                    ? '✓ Agreed Proposal: ₹${enquiry.currentNegotiatedAmount!.toStringAsFixed(0)} (Accepted - Proceed to Diligence)'
                    : 'Current Active Offer: ₹${enquiry.currentNegotiatedAmount!.toStringAsFixed(0)} (${enquiry.offerStatus.displayName})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: enquiry.offerStatus == OfferLifecycleStatus.accepted
                      ? const Color(0xFF15803D)
                      : const Color(0xFF92400E),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // ─── Step-by-Step Negotiation History Timeline ───
          if (history.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Negotiation Timeline (${history.length} events)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...history.map(
              (event) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: event.isBuyerOffer
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: event.isBuyerOffer
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      event.isBuyerOffer
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 16,
                      color: event.isBuyerOffer
                          ? const Color(0xFF15803D)
                          : const Color(0xFF1D4ED8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${event.submittedByName} (${event.isBuyerOffer ? 'Buyer Offer' : 'Owner Counter'})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${event.offerAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: event.isBuyerOffer
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                          if (event.monthlyRent != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Monthly Rent: ₹${event.monthlyRent!.toStringAsFixed(0)} • Deposit: ₹${event.depositAmount?.toStringAsFixed(0) ?? '—'}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                          if (event.termsAndConditions != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Terms: ${event.termsAndConditions}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${event.createdAt.day}/${event.createdAt.month} ${event.createdAt.hour}:${event.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.status.displayName,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Negotiation Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    _showOfferModal(context, enquiry, isBuyer: true),
                icon: const Icon(Icons.edit_note_rounded, size: 14),
                label: const Text('Buyer: Revise Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _showOfferModal(context, enquiry, isBuyer: false),
                icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                label: const Text('Seller: Propose Counter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  ref
                      .read(transactionNotifierProvider.notifier)
                      .updateOfferStatus(
                        enquiryId: enquiry.id,
                        status: OfferLifecycleStatus.accepted,
                        notes:
                            'Offer accepted by mutual agreement. Proceeding to due diligence.',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✓ Offer accepted! Moved to Document Due Diligence stage.',
                      ),
                      backgroundColor: Color(0xFF15803D),
                    ),
                  );
                },
                child: const Text(
                  'Accept Active Offer',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(transactionNotifierProvider.notifier)
                      .updateOfferStatus(
                        enquiryId: enquiry.id,
                        status: OfferLifecycleStatus.withdrawn,
                      );
                },
                child: const Text(
                  'Withdraw Offer',
                  style: TextStyle(fontSize: 11, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocVerificationCard(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    final docStatus = enquiry.docVerificationStatus;

    return _buildSectionBox(
      title: '4. Document Verification & Legal Due Diligence',
      icon: Icons.verified_user_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${docStatus.displayName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/legal-notices'),
                child: const Text(
                  'View Legal Checklist',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (enquiry.docVerificationNotes != null) ...[
            const SizedBox(height: 4),
            Text(
              'Notes: ${enquiry.docVerificationNotes}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
          ],
          const SizedBox(height: 10),
          DropdownButtonFormField<DocVerificationStatus>(
            initialValue: docStatus,
            decoration: const InputDecoration(
              labelText: 'Update Verification Stage',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: DocVerificationStatus.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s.displayName,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                )
                .toList(),
            onChanged: (newStatus) {
              if (newStatus != null) {
                ref
                    .read(transactionNotifierProvider.notifier)
                    .updateDocVerification(
                      enquiryId: enquiry.id,
                      status: newStatus,
                      notes: 'Stage updated to ${newStatus.displayName}',
                    );
              }
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push('/due-diligence/${enquiry.propertyId}'),
              icon: const Icon(Icons.verified_user_outlined, size: 16),
              label: const Text('Open Due Diligence Hub & Request Documents'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Facilitation Notice: PropertyHub provides workflow tracking between buyer and seller. All financial payments and legal title registrations must be executed independently before official government sub-registrars.',
        style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.4),
      ),
    );
  }

  Widget _buildSectionBox({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDesignSystem.borderRadiusM,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppDesignSystem.primaryNavy),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfferModal(
    BuildContext context,
    PropertyEnquiryEntity enquiry, {
    required bool isBuyer,
  }) {
    final amountController = TextEditingController(
      text: isBuyer
          ? (enquiry.buyerOfferPrice?.toStringAsFixed(0) ??
                enquiry.listedPrice.toStringAsFixed(0))
          : (enquiry.sellerCounterOfferPrice?.toStringAsFixed(0) ??
                enquiry.listedPrice.toStringAsFixed(0)),
    );
    final termsController = TextEditingController(
      text: isBuyer
          ? 'Subject to clean title search'
          : 'Includes all fixtures and parking',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isBuyer ? 'Submit Revised Offer' : 'Propose Counter Offer',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Proposed Amount (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: termsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Terms & Conditions',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(
                amountController.text.trim().replaceAll(',', ''),
              );
              if (amt != null) {
                ref
                    .read(transactionNotifierProvider.notifier)
                    .submitOfferEvent(
                      enquiryId: enquiry.id,
                      userId: isBuyer ? enquiry.buyerId : enquiry.sellerId,
                      userName: isBuyer ? enquiry.buyerName : 'Owner',
                      isBuyer: isBuyer,
                      offerAmount: amt,
                      terms: termsController.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBuyer ? '✓ Offer submitted!' : '✓ Counter offer sent!',
                    ),
                    backgroundColor: const Color(0xFF15803D),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(
    BuildContext context,
    PropertyEnquiryEntity enquiry,
  ) {
    final dateController = TextEditingController(text: 'Next Saturday');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Reschedule Site Visit',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: dateController,
          decoration: const InputDecoration(
            labelText: 'New Preferred Date / Time',
            border: OutlineInputBorder(),
          ),
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
                  .respondToSiteVisit(
                    enquiryId: enquiry.id,
                    status: SiteVisitStatus.rescheduleRequested,
                    notes: 'Rescheduled request: ${dateController.text.trim()}',
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
            ),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }
}
