import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import '../../domain/entities/transaction_entities.dart';
import '../providers/transaction_notifier.dart';

class SendEnquiryModal extends ConsumerStatefulWidget {
  final PropertyEntity property;
  final String initialMode; // 'enquiry', 'site_visit', 'offer'

  const SendEnquiryModal({
    super.key,
    required this.property,
    this.initialMode = 'enquiry',
  });

  static Future<void> show(
    BuildContext context,
    PropertyEntity property, {
    String initialMode = 'enquiry',
  }) {
    if (!AuthSessionStorageHelper.isLoggedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in to submit a property enquiry, request a visit, or make an offer.',
          ),
          backgroundColor: Color(0xFFB45309),
        ),
      );
      context.go('/welcome');
      return Future.value();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SendEnquiryModal(property: property, initialMode: initialMode),
    );
  }

  @override
  ConsumerState<SendEnquiryModal> createState() => _SendEnquiryModalState();
}

class _SendEnquiryModalState extends ConsumerState<SendEnquiryModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _messageController;
  late TextEditingController _offerPriceController;
  late TextEditingController _monthlyRentController;
  late TextEditingController _depositController;
  late TextEditingController _leaseDurationController;
  late TextEditingController _termsController;

  late TransactionInterestType _interestType;
  late String _activeMode;
  final String _preferredContact = 'Phone Call';
  String _preferredVisitTime = 'Morning (10 AM - 1 PM)';
  final String _financingStatus = 'Self-Funded';
  DateTime? _selectedVisitDate;

  @override
  void initState() {
    super.initState();
    _activeMode = widget.initialMode;

    final purpose =
        (widget.property.features['listingType'] ??
                widget.property.features['purpose'])
            as String? ??
        'FOR_SALE';
    _interestType = purpose == 'FOR_RENT'
        ? TransactionInterestType.rent
        : (purpose == 'LEASE'
              ? TransactionInterestType.lease
              : TransactionInterestType.buy);

    final fbUser = FirebaseAuth.instance.currentUser;
    final userName =
        fbUser?.displayName ?? AuthSessionStorageHelper.getUserName() ?? '';
    final userPhone =
        fbUser?.phoneNumber ?? AuthSessionStorageHelper.getUserPhone() ?? '';
    final userEmail =
        fbUser?.email ?? AuthSessionStorageHelper.getUserEmail() ?? '';

    _nameController = TextEditingController(text: userName);
    _phoneController = TextEditingController(text: userPhone);
    _emailController = TextEditingController(text: userEmail);
    _messageController = TextEditingController(
      text: _activeMode == 'site_visit'
          ? 'I would like to schedule an on-site physical inspection of this property.'
          : (_activeMode == 'offer'
                ? 'Submitting a purchase proposal subject to title and legal document verification.'
                : 'I am interested in this ${_interestType.displayName.toLowerCase()} listing and would like more details.'),
    );
    _offerPriceController = TextEditingController(
      text: widget.property.price > 0
          ? widget.property.price.toStringAsFixed(0)
          : '',
    );
    _monthlyRentController = TextEditingController(
      text:
          _interestType == TransactionInterestType.rent &&
              widget.property.price > 0
          ? widget.property.price.toStringAsFixed(0)
          : '25000',
    );
    _depositController = TextEditingController(text: '150000');
    _leaseDurationController = TextEditingController(text: '36');
    _termsController = TextEditingController(
      text:
          'Subject to 30-year title verification, nil encumbrance certificate, and vacant possession.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _offerPriceController.dispose();
    _monthlyRentController.dispose();
    _depositController.dispose();
    _leaseDurationController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ??
        AuthSessionStorageHelper.getUserUid() ??
        'usr_authenticated';

    // Duplicate enquiry protection
    final hasExisting = await ref
        .read(transactionNotifierProvider.notifier)
        .hasActiveInquiry(
          propertyId: widget.property.id,
          buyerId: currentUserId,
        );
    if (hasExisting && _activeMode == 'enquiry') {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You have already expressed interest in this property. Track it under My Enquiries.',
            ),
            backgroundColor: Color(0xFFB45309),
          ),
        );
        context.go('/my-enquiries');
      }
      return;
    }

    final enquiryId = 'enq_${DateTime.now().millisecondsSinceEpoch}';
    final offer = double.tryParse(
      _offerPriceController.text.trim().replaceAll(',', ''),
    );
    final rent = double.tryParse(
      _monthlyRentController.text.trim().replaceAll(',', ''),
    );
    final deposit = double.tryParse(
      _depositController.text.trim().replaceAll(',', ''),
    );
    final leaseDuration = int.tryParse(_leaseDurationController.text.trim());

    // Build initial negotiation history event if submitting offer
    List<NegotiationOfferEvent> history = [];
    if (_activeMode == 'offer' && (offer != null || rent != null)) {
      history.add(
        NegotiationOfferEvent(
          id: 'off_${DateTime.now().millisecondsSinceEpoch}',
          enquiryId: enquiryId,
          submittedByUserId: currentUserId,
          submittedByName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'Prospective Buyer',
          isBuyerOffer: true,
          offerAmount: _interestType == TransactionInterestType.buy
              ? (offer ?? widget.property.price)
              : (rent ?? 25000),
          monthlyRent: rent,
          depositAmount: deposit,
          leaseDurationMonths: leaseDuration,
          termsAndConditions: _termsController.text.trim(),
          status: OfferLifecycleStatus.submitted,
          createdAt: DateTime.now(),
        ),
      );
    }

    final enquiry = PropertyEnquiryEntity(
      id: enquiryId,
      propertyId: widget.property.id,
      propertyTitle: widget.property.title,
      propertyCategory: widget.property.category.name,
      propertyLocation: '${widget.property.locality}, ${widget.property.city}',
      buyerId: currentUserId,
      buyerName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Prospective Buyer',
      buyerPhone: _phoneController.text.trim(),
      buyerEmail: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      sellerId: widget.property.ownerId,
      interestType: _interestType,
      initialMessage: _messageController.text.trim(),
      preferredContactMethod: _preferredContact,
      preferredVisitDate: _selectedVisitDate != null
          ? '${_selectedVisitDate!.day}/${_selectedVisitDate!.month}/${_selectedVisitDate!.year}'
          : (_activeMode == 'site_visit' ? 'This Weekend' : null),
      preferredVisitTime: _preferredVisitTime,
      financingStatus: _financingStatus,
      listedPrice: widget.property.price,
      monthlyRent: rent,
      depositAmount: deposit,
      leaseDurationMonths: leaseDuration,
      buyerOfferPrice: offer,
      currentNegotiatedAmount: offer ?? rent,
      offerStatus: _activeMode == 'offer'
          ? OfferLifecycleStatus.submitted
          : OfferLifecycleStatus.submitted,
      negotiationHistory: history,
      status: _activeMode == 'offer'
          ? TransactionStatus.negotiation
          : (_activeMode == 'site_visit'
                ? TransactionStatus.siteVisit
                : TransactionStatus.newEnquiry),
      siteVisitStatus: _activeMode == 'site_visit'
          ? SiteVisitStatus.requested
          : SiteVisitStatus.none,
      docVerificationStatus: DocVerificationStatus.notStarted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(transactionNotifierProvider.notifier).sendEnquiry(enquiry);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _activeMode == 'offer'
                  ? '✓ Offer submitted to owner! Track negotiation under My Enquiries.'
                  : (_activeMode == 'site_visit'
                        ? '✓ Site visit requested! Owner will confirm your time slot.'
                        : '✓ Enquiry submitted to property owner!'),
            ),
            backgroundColor: const Color(0xFF15803D),
          ),
        );
        context.go('/my-enquiries');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title & Property Reference
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeMode == 'site_visit'
                              ? 'Request Site Visit'
                              : (_activeMode == 'offer'
                                    ? 'Make Formal Offer'
                                    : "I'm Interested in Property"),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.property.title,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppDesignSystem.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mode Switcher Chips
              Row(
                children: [
                  ChoiceChip(
                    label: const Text(
                      "I'm Interested",
                      style: TextStyle(fontSize: 11),
                    ),
                    selected: _activeMode == 'enquiry',
                    onSelected: (s) {
                      if (s) setState(() => _activeMode = 'enquiry');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text(
                      'Site Visit',
                      style: TextStyle(fontSize: 11),
                    ),
                    selected: _activeMode == 'site_visit',
                    onSelected: (s) {
                      if (s) setState(() => _activeMode = 'site_visit');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text(
                      'Make Offer',
                      style: TextStyle(fontSize: 11),
                    ),
                    selected: _activeMode == 'offer',
                    onSelected: (s) {
                      if (s) setState(() => _activeMode = 'offer');
                    },
                  ),
                ],
              ),
              const Divider(height: 24),

              // Listed Price Summary
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
                        Text(
                          'Listed ${_interestType.displayName} Price',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '₹${widget.property.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _interestType.displayName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Offer Section (if Make Offer mode) ───
              if (_activeMode == 'offer') ...[
                if (_interestType == TransactionInterestType.buy) ...[
                  TextFormField(
                    controller: _offerPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Your Proposed Purchase Offer (₹)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                      helperText:
                          'Enter your proposed price for owner consideration',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return 'Please enter offer amount';
                      if (double.tryParse(val.replaceAll(',', '')) == null)
                        return 'Enter valid amount';
                      return null;
                    },
                  ),
                ] else if (_interestType == TransactionInterestType.rent) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _monthlyRentController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Offered Monthly Rent (₹)',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _depositController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Security Deposit (₹)',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _offerPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Lease Premium / Rent (₹)',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _leaseDurationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duration (Months)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _termsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Offer Terms & Contingencies',
                    border: OutlineInputBorder(),
                    helperText:
                        'e.g. subject to bank loan sanction, possession date',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ─── Site Visit Schedule Section (if site_visit mode or optional) ───
              if (_activeMode == 'site_visit') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 60),
                            ),
                          );
                          if (picked != null) {
                            setState(() => _selectedVisitDate = picked);
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                        ),
                        label: Text(
                          _selectedVisitDate != null
                              ? '${_selectedVisitDate!.day}/${_selectedVisitDate!.month}/${_selectedVisitDate!.year}'
                              : 'Select Visit Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _preferredVisitTime,
                        decoration: const InputDecoration(
                          labelText: 'Time Slot',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Morning (10 AM - 1 PM)',
                            child: Text(
                              'Morning (10-1)',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Afternoon (2 PM - 5 PM)',
                            child: Text(
                              'Afternoon (2-5)',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Evening (5 PM - 7 PM)',
                            child: Text(
                              'Evening (5-7)',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null)
                            setState(() => _preferredVisitTime = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Contact Details
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Message to Property Owner',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              // Safety & Statutory Disclaimer
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Safety & Diligence Notice: Please independently verify property and legal documents before proceeding. Offer submission is subject to documentation and not a legally binding deed.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Submit CTA
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _activeMode == 'offer'
                        ? 'Submit Offer to Owner'
                        : (_activeMode == 'site_visit'
                              ? 'Request Site Visit'
                              : 'Send Enquiry'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
}
