import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../providers/advertising_providers.dart';

class AdvertiseWithUsView extends ConsumerStatefulWidget {
  const AdvertiseWithUsView({super.key});

  @override
  ConsumerState<AdvertiseWithUsView> createState() => _AdvertiseWithUsViewState();
}

class _AdvertiseWithUsViewState extends ConsumerState<AdvertiseWithUsView> {
  final _formKey = GlobalKey<FormState>();

  // Advertiser info
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteUrlController = TextEditingController();

  // Campaign info
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPlacement = 'HOME_NATIVE_SPONSORED';
  final _localityController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 31));

  // Creative info
  final _headlineController = TextEditingController();
  final _bodyTextController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ctaTextController = TextEditingController(text: 'Contact Business');
  String _actionType = 'URL';
  final _actionValueController = TextEditingController();

  bool _isSubmitting = false;

  final List<Map<String, String>> _placements = [
    {'value': 'HOME_NATIVE_SPONSORED', 'label': 'Home Feed Native Sponsored'},
    {'value': 'SEARCH_NATIVE_SPONSORED', 'label': 'Search Results Native Sponsored'},
    {'value': 'LOCALITY_BANNER', 'label': 'Locality Banner'},
    {'value': 'CATEGORY_BANNER', 'label': 'Category Banner'},
    {'value': 'FEATURED_BUSINESS', 'label': 'Featured Business Directory'},
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _contactPersonController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteUrlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _localityController.dispose();
    _headlineController.dispose();
    _bodyTextController.dispose();
    _imageUrlController.dispose();
    _ctaTextController.dispose();
    _actionValueController.dispose();
    super.dispose();
  }

  Future<void> _submitCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit an advertising campaign.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      context.push('/auth');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(advertisingRepositoryProvider);
      final res = await repo.submitDirectAdCampaign(
        businessName: _businessNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        websiteUrl: _websiteUrlController.text.trim().isEmpty ? null : _websiteUrlController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        placement: _selectedPlacement,
        targetLocality: _localityController.text.trim().isEmpty ? null : _localityController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        headline: _headlineController.text.trim(),
        bodyText: _bodyTextController.text.trim().isEmpty ? null : _bodyTextController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        ctaText: _ctaTextController.text.trim().isEmpty ? 'Learn More' : _ctaTextController.text.trim(),
        actionType: _actionType,
        actionValue: _actionValueController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                SizedBox(width: 8),
                Text('Campaign Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  res['message'] as String? ?? 'Your campaign was submitted successfully!',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Text(
                    'Notice: Campaign pricing will be confirmed before activation. Our team will review your creative and contact you within 24 hours.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Back to App'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit campaign: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Advertise With Us',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.campaign_rounded, color: Color(0xFF2563EB), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Promote your local Belagavi business or real estate agency directly to thousands of active verified buyers and investors.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Business Details
              const Text(
                '1. Business Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business / Agency Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contactPersonController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Person *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _websiteUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Website (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language_rounded),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 2: Campaign Target
              const Text(
                '2. Campaign Placement & Dates',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Campaign Internal Title *',
                  hintText: 'e.g., Summer Villa Launch Tilakwadi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPlacement,
                decoration: const InputDecoration(
                  labelText: 'Placement Slot *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.layers_rounded),
                ),
                items: _placements.map((p) {
                  return DropdownMenuItem(
                    value: p['value'],
                    child: Text(p['label']!, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPlacement = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _localityController,
                decoration: const InputDecoration(
                  labelText: 'Target Locality in Belagavi (Optional)',
                  hintText: 'e.g., Tilakwadi, Mandoli, Shahapur (Blank = All)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ),

              const SizedBox(height: 24),

              // Section 3: Ad Creative
              const Text(
                '3. Ad Creative Content',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _headlineController,
                decoration: const InputDecoration(
                  labelText: 'Headline *',
                  hintText: 'e.g., Luxury 3BHK Apartments Starting at ₹45L',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyTextController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Body Text / Offer Details (Optional)',
                  hintText: 'e.g., Prime location near RPD Cross. 100% Vastu compliant.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Banner / Creative Image URL (Optional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _actionType,
                      decoration: const InputDecoration(
                        labelText: 'Action Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'URL', child: Text('Open URL')),
                        DropdownMenuItem(value: 'PHONE', child: Text('Call Phone')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _actionType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ctaTextController,
                      decoration: const InputDecoration(
                        labelText: 'Button Label *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _actionValueController,
                decoration: InputDecoration(
                  labelText: _actionType == 'PHONE' ? 'Phone Number with prefix (+91...) *' : 'Target Destination URL *',
                  hintText: _actionType == 'PHONE' ? '+919876543210' : 'https://mywebsite.com/project',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              // Pricing Confirmation Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Campaign pricing will be confirmed before activation. No payment is charged right now.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCampaign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Submit Campaign for Review',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
