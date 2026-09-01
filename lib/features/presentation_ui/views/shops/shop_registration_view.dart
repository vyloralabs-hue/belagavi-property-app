import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/local_shops/presentation/providers/local_shops_notifier.dart';
import 'package:belagavi_property/features/local_shops/domain/entities/business_entities.dart';
import 'package:belagavi_property/features/local_shops/utils/business_location_resolver.dart';
import 'package:belagavi_property/core/security/user_role.dart';

class ShopRegistrationView extends ConsumerStatefulWidget {
  const ShopRegistrationView({super.key});

  @override
  ConsumerState<ShopRegistrationView> createState() =>
      _ShopRegistrationViewState();
}

class _ShopRegistrationViewState extends ConsumerState<ShopRegistrationView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationQueryController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController(text: '09:00 AM - 08:30 PM');
  final _productsController = TextEditingController();

  String _selectedCategory = 'cat_building';

  @override
  void dispose() {
    _nameController.dispose();
    _locationQueryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _productsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Register Your Business',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Business Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business / Shop Name *',
                  border: const OutlineInputBorder(
                    borderRadius: AppDesignSystem.borderRadiusM,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter business name'
                    : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: const OutlineInputBorder(
                    borderRadius: AppDesignSystem.borderRadiusM,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'cat_building',
                    child: Text('Building Materials'),
                  ),
                  DropdownMenuItem(
                    value: 'cat_pipes',
                    child: Text('Pipes & Fittings'),
                  ),
                  DropdownMenuItem(
                    value: 'cat_hardware',
                    child: Text('Hardware & Tools'),
                  ),
                  DropdownMenuItem(
                    value: 'cat_electrical',
                    child: Text('Electricals'),
                  ),
                  DropdownMenuItem(
                    value: 'cat_paint',
                    child: Text('Paints & Wallpapers'),
                  ),
                  DropdownMenuItem(
                    value: 'cat_tiles',
                    child: Text('Tiles & Sanitary'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Fast Location Search Field (0 Forced Multi-Level Selection)
              TextFormField(
                controller: _locationQueryController,
                decoration: const InputDecoration(
                  labelText: 'Location / City / Locality *',
                  hintText: 'Type location e.g. Tilakwadi, Belagavi',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: const OutlineInputBorder(
                    borderRadius: AppDesignSystem.borderRadiusM,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter your location'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Full Shop Address *',
                  border: const OutlineInputBorder(
                    borderRadius: AppDesignSystem.borderRadiusM,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter full address'
                    : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        border: const OutlineInputBorder(
                          borderRadius: AppDesignSystem.borderRadiusM,
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp (Optional)',
                        border: const OutlineInputBorder(
                          borderRadius: AppDesignSystem.borderRadiusM,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Business Description *',
                  border: const OutlineInputBorder(
                    borderRadius: AppDesignSystem.borderRadiusM,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please describe your business'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _productsController,
                decoration: const InputDecoration(
                  labelText: 'Key Products / Services (comma-separated)',
                  border: const OutlineInputBorder(
                    borderRadius: AppDesignSystem.borderRadiusM,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDesignSystem.borderRadiusL,
                  ),
                ),
                child: const Text(
                  'Submit Business Registration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final locationText = _locationQueryController.text.trim();
      final resolved = BusinessLocationResolver.resolve(locationText);

      final newShop = BusinessEntity(
        id: 'biz_${DateTime.now().millisecondsSinceEpoch}',
        ownerId: 'usr_owner_current',
        name: _nameController.text.trim(),
        categoryId: _selectedCategory,
        subcategoryId: 'sub_general',
        stateId: resolved.stateId,
        districtId: resolved.districtId,
        cityId: resolved.cityId,
        localityId: resolved.localityId,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim().isNotEmpty
            ? _whatsappController.text.trim()
            : null,
        description: _descriptionController.text.trim(),
        openingHours: _hoursController.text.trim(),
        productsServices: _productsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        createdAt: DateTime.now(),
      );

      final success = await ref
          .read(localShopsNotifierProvider.notifier)
          .registerShop(newShop);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Shop registered successfully! Pending admin verification.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
