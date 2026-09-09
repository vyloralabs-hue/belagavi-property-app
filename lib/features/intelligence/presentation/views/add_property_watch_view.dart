import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/property_watch_entities.dart';
import '../../domain/services/survey_identity_normalizer.dart';
import '../providers/intelligence_providers.dart';

class AddPropertyWatchView extends ConsumerStatefulWidget {
  const AddPropertyWatchView({super.key});

  @override
  ConsumerState<AddPropertyWatchView> createState() => _AddPropertyWatchViewState();
}

class _AddPropertyWatchViewState extends ConsumerState<AddPropertyWatchView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _stateController = TextEditingController(text: 'Karnataka');
  final _districtController = TextEditingController(text: 'Belagavi');
  String _taluk = 'Belagavi';
  final _cityVillageController = TextEditingController(text: 'Belagavi');
  final _localityController = TextEditingController();
  final _surveyController = TextEditingController();
  final _subdivisionController = TextEditingController();
  WatchRelationship _relationship = WatchRelationship.prospectiveBuyer;

  bool _isSubmitting = false;

  static const List<String> _belagaviTaluks = [
    'Belagavi',
    'Gokak',
    'Bailhongal',
    'Chikkodi',
    'Hukkeri',
    'Khanapur',
    'Ramdurg',
    'Raybag',
    'Saundatti',
    'Athani',
    'Kittur',
    'Mudalgi',
    'Kagwad',
    'Nippani',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityVillageController.dispose();
    _localityController.dispose();
    _surveyController.dispose();
    _subdivisionController.dispose();
    super.dispose();
  }

  String get _normalizedPreview {
    return SurveyIdentityNormalizer.normalize(
      country: 'India',
      state: _stateController.text,
      district: _districtController.text,
      taluk: _taluk,
      cityOrVillage: _cityVillageController.text,
      locality: _localityController.text,
      surveyNumber: _surveyController.text,
      subdivisionNumber: _subdivisionController.text,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final watch = PropertyWatchEntity(
      id: '',
      profileId: '',
      watchName: _nameController.text.trim(),
      relationship: _relationship,
      country: 'India',
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
      taluk: _taluk,
      cityOrVillage: _cityVillageController.text.trim(),
      locality: _localityController.text.trim(),
      surveyNumber: _surveyController.text.trim(),
      subdivisionNumber: _subdivisionController.text.trim().isNotEmpty
          ? _subdivisionController.text.trim()
          : null,
      normalizedIdentity: _normalizedPreview,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await ref
        .read(propertyWatchNotifierProvider.notifier)
        .addWatch(watch);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property watch added successfully! Public record monitoring is active.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        final err = ref.read(propertyWatchNotifierProvider).error ?? 'Failed to add watch';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF0A0D11) : AppDesignSystem.backgroundWhite;
    final surfaceBg = isDark ? const Color(0xFF131922) : Colors.white;
    final textP = isDark ? const Color(0xFFFDFCF4) : const Color(0xFF0F172A);
    final textS = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Property & Survey Watch',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textP,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.brandGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppDesignSystem.brandGold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppDesignSystem.brandGold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hierarchical survey identity ensures subdivision precision and avoids cross-taluk duplicates.',
                          style: TextStyle(fontSize: 12, color: textP, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Watch Name
                _buildLabel('Watch Label / Friendly Name *', textP),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textP, fontSize: 14),
                  decoration: _inputDecoration('e.g. Shahapur Survey 123 Plot', textS, isDark),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),

                // Relationship Type
                _buildLabel('Your Relationship to Property *', textP),
                DropdownButtonFormField<WatchRelationship>(
                  value: _relationship,
                  dropdownColor: surfaceBg,
                  style: TextStyle(color: textP, fontSize: 14),
                  decoration: _inputDecoration('', textS, isDark),
                  items: WatchRelationship.values.map((rel) {
                    return DropdownMenuItem(
                      value: rel,
                      child: Text(rel.displayName),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _relationship = v);
                  },
                ),
                const SizedBox(height: 16),

                // Taluk Dropdown
                _buildLabel('Taluk *', textP),
                DropdownButtonFormField<String>(
                  value: _taluk,
                  dropdownColor: surfaceBg,
                  style: TextStyle(color: textP, fontSize: 14),
                  decoration: _inputDecoration('', textS, isDark),
                  items: _belagaviTaluks.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _taluk = v);
                  },
                ),
                const SizedBox(height: 16),

                // City / Village
                _buildLabel('City or Village *', textP),
                TextFormField(
                  controller: _cityVillageController,
                  style: TextStyle(color: textP, fontSize: 14),
                  decoration: _inputDecoration('e.g. Belagavi, Peeranwadi, Vadgaon', textS, isDark),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter city or village' : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Locality
                _buildLabel('Locality / Landmark *', textP),
                TextFormField(
                  controller: _localityController,
                  style: TextStyle(color: textP, fontSize: 14),
                  decoration: _inputDecoration('e.g. Tilakwadi, Mandoli Road', textS, isDark),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter locality' : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Survey Number & Subdivision Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Survey No. / CTS *', textP),
                          TextFormField(
                            controller: _surveyController,
                            style: TextStyle(color: textP, fontSize: 14),
                            decoration: _inputDecoration('e.g. 123', textS, isDark),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Subdivision', textP),
                          TextFormField(
                            controller: _subdivisionController,
                            style: TextStyle(color: textP, fontSize: 14),
                            decoration: _inputDecoration('e.g. 2A', textS, isDark),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Canonical Identity Preview Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Normalized Identity (Canonical Key):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textS)),
                      const SizedBox(height: 4),
                      SelectableText(
                        _normalizedPreview,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppDesignSystem.brandGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.brandGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.visibility_rounded, size: 20),
                    label: const Text(
                      'Activate Survey Monitoring',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textP) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textP)),
    );
  }

  InputDecoration _inputDecoration(String hint, Color textS, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textS, fontSize: 13),
      filled: true,
      fillColor: isDark ? const Color(0xFF18202B) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
