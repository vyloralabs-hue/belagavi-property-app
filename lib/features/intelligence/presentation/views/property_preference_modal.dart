import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/preference_entities.dart';
import '../providers/intelligence_providers.dart';
import '../../../presentation_ui/theme/app_design_system.dart';

class PropertyPreferenceModal extends ConsumerStatefulWidget {
  const PropertyPreferenceModal({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF131922) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: const PropertyPreferenceModal(),
      ),
    );
  }

  @override
  ConsumerState<PropertyPreferenceModal> createState() => _PropertyPreferenceModalState();
}

class _PropertyPreferenceModalState extends ConsumerState<PropertyPreferenceModal> {
  int _currentStep = 0;

  String _purpose = 'buy';
  String _category = 'residential';
  final List<String> _selectedLocalities = [];
  double _minBudget = 2000000; // 20L
  double _maxBudget = 8000000; // 80L
  int? _minBedrooms = 2;
  double? _minArea;

  static const List<String> _belagaviLocalities = [
    'Tilakwadi',
    'Mandoli Road',
    'Hindwadi',
    'Shahapur',
    'Camp',
    'Vadgaon',
    'Angol',
    'Khasbag',
    'Bhagya Nagar',
    'Channamma Nagar',
    'Udyambag',
    'Auto Nagar',
    'Macche',
    'Peeranwadi',
    'Sambhaji Nagar',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentPref = ref.read(propertyPreferenceNotifierProvider).preference;
      if (currentPref != null) {
        setState(() {
          _purpose = currentPref.purpose;
          _category = currentPref.category;
          _selectedLocalities.clear();
          _selectedLocalities.addAll(currentPref.preferredLocalities);
          if (currentPref.minBudget != null) _minBudget = currentPref.minBudget!;
          if (currentPref.maxBudget != null) _maxBudget = currentPref.maxBudget!;
          _minBedrooms = currentPref.minBedrooms;
          _minArea = currentPref.minArea;
        });
      }
    });
  }

  Future<void> _handleSave() async {
    final currentPref = ref.read(propertyPreferenceNotifierProvider).preference;
    final entity = PropertyPreferenceEntity(
      id: currentPref?.id ?? '',
      profileId: currentPref?.profileId ?? '',
      purpose: _purpose,
      category: _category,
      preferredLocalities: _selectedLocalities,
      minBudget: _minBudget,
      maxBudget: _maxBudget,
      minBedrooms: _minBedrooms,
      minArea: _minArea,
      isActive: true,
      createdAt: currentPref?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await ref
        .read(propertyPreferenceNotifierProvider.notifier)
        .savePreference(entity);

    if (mounted) {
      if (success) {
        // Refresh personalized feed
        ref.read(personalizedFeedNotifierProvider.notifier).loadPersonalizedProperties(entity);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property preferences saved successfully! Feed personalized.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save preferences. Please sign in and try again.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefState = ref.watch(propertyPreferenceNotifierProvider);
    final hasExisting = prefState.preference != null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF131922) : Colors.white;
    final textP = isDark ? const Color(0xFFFDFCF4) : const Color(0xFF0F172A);
    final textS = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return SafeArea(
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppDesignSystem.brandGold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Preferences',
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textP,
                        ),
                      ),
                      Text(
                        'Personalize recommendations & alerts for Belagavi',
                        style: TextStyle(fontSize: 12, color: textS),
                      ),
                    ],
                  ),
                ),
                if (hasExisting)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: 'Reset Preferences',
                    onPressed: () async {
                      await ref.read(propertyPreferenceNotifierProvider.notifier).resetPreference();
                      if (mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Step Indicator Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStepDot(0, 'Purpose'),
                _buildStepDivider(),
                _buildStepDot(1, 'Category'),
                _buildStepDivider(),
                _buildStepDot(2, 'Location'),
                _buildStepDivider(),
                _buildStepDot(3, 'Budget'),
                _buildStepDivider(),
                _buildStepDot(4, 'Specs'),
              ],
            ),
          ),
          const Divider(height: 24),

          // Step Content (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCurrentStepContent(textP, textS),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: bgCol,
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('Back'),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Skip For Now', style: TextStyle(color: textS)),
                  ),
                const Spacer(),
                if (_currentStep < 4)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.brandGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => setState(() => _currentStep++),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Next Step', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: prefState.isLoading ? null : _handleSave,
                    icon: prefState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String title) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;
    return GestureDetector(
      onTap: () => setState(() => _currentStep = step),
      child: Column(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppDesignSystem.brandGold
                  : isDone
                      ? const Color(0xFF10B981)
                      : Colors.grey.withValues(alpha: 0.2),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppDesignSystem.brandGold : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildCurrentStepContent(Color textP, Color textS) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your primary goal?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textP)),
            const SizedBox(height: 8),
            Text('Choose the primary transaction type you are seeking in Belagavi.', style: TextStyle(fontSize: 13, color: textS)),
            const SizedBox(height: 16),
            _buildSelectionTile(
              title: 'Buy Property',
              subtitle: 'Seeking ownership of homes, plots, or commercial real estate',
              icon: Icons.home_rounded,
              isSelected: _purpose == 'buy',
              onTap: () => setState(() => _purpose = 'buy'),
            ),
            _buildSelectionTile(
              title: 'Rent / Lease',
              subtitle: 'Looking for residential rentals or commercial lease spaces',
              icon: Icons.key_rounded,
              isSelected: _purpose == 'rent',
              onTap: () => setState(() => _purpose = 'rent'),
            ),
            _buildSelectionTile(
              title: 'Long-term Investment',
              subtitle: 'High appreciation plots, farmland, and commercial assets',
              icon: Icons.trending_up_rounded,
              isSelected: _purpose == 'investment',
              onTap: () => setState(() => _purpose = 'investment'),
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What type of property?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textP)),
            const SizedBox(height: 8),
            Text('Select your preferred category.', style: TextStyle(fontSize: 13, color: textS)),
            const SizedBox(height: 16),
            _buildSelectionTile(
              title: 'Residential',
              subtitle: 'Apartments, independent villas, row houses, and flats',
              icon: Icons.apartment_rounded,
              isSelected: _category == 'residential',
              onTap: () => setState(() => _category = 'residential'),
            ),
            _buildSelectionTile(
              title: 'Plots & Layouts',
              subtitle: 'MUDA approved, NA plots, gated layouts',
              icon: Icons.landscape_rounded,
              isSelected: _category == 'plotLand',
              onTap: () => setState(() => _category = 'plotLand'),
            ),
            _buildSelectionTile(
              title: 'Commercial',
              subtitle: 'Retail shops, offices, warehouses, and showrooms',
              icon: Icons.storefront_rounded,
              isSelected: _category == 'commercial',
              onTap: () => setState(() => _category = 'commercial'),
            ),
            _buildSelectionTile(
              title: 'Agricultural / Raw Land',
              subtitle: 'Farmland, agricultural parcels, development acreage',
              icon: Icons.grass_rounded,
              isSelected: _category == 'land',
              onTap: () => setState(() => _category = 'land'),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferred Localities in Belagavi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textP)),
            const SizedBox(height: 8),
            Text('Select one or more key areas you prefer.', style: TextStyle(fontSize: 13, color: textS)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _belagaviLocalities.map((loc) {
                final isSel = _selectedLocalities.contains(loc);
                return FilterChip(
                  selected: isSel,
                  label: Text(loc),
                  selectedColor: AppDesignSystem.brandGold,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : textP,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLocalities.add(loc);
                      } else {
                        _selectedLocalities.remove(loc);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textP)),
            const SizedBox(height: 8),
            Text('Set your comfortable pricing bracket.', style: TextStyle(fontSize: 13, color: textS)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetBox('Min Budget', '₹${(_minBudget / 100000).toStringAsFixed(0)} Lakhs', textP, textS),
                const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                _buildBudgetBox('Max Budget', '₹${(_maxBudget / 100000).toStringAsFixed(0)} Lakhs', textP, textS),
              ],
            ),
            const SizedBox(height: 24),
            RangeSlider(
              values: RangeValues(_minBudget, _maxBudget),
              min: 500000, // 5L
              max: 20000000, // 2 Cr
              divisions: 39,
              activeColor: AppDesignSystem.brandGold,
              onChanged: (values) {
                setState(() {
                  _minBudget = values.start;
                  _maxBudget = values.end;
                });
              },
            ),
          ],
        );

      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specifications (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textP)),
            const SizedBox(height: 8),
            Text('Refine bedrooms and minimum carpet area.', style: TextStyle(fontSize: 13, color: textS)),
            const SizedBox(height: 20),
            Text('Preferred Bedrooms (BHK):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textP)),
            const SizedBox(height: 10),
            Row(
              children: [1, 2, 3, 4].map((bhk) {
                final isSel = _minBedrooms == bhk;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$bhk BHK'),
                    selected: isSel,
                    selectedColor: AppDesignSystem.brandGold,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : textP,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() => _minBedrooms = selected ? bhk : null);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Minimum Area (sqft):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textP)),
            const SizedBox(height: 10),
            Row(
              children: [600.0, 1000.0, 1500.0, 2400.0].map((area) {
                final isSel = _minArea == area;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${area.toInt()} sqft'),
                    selected: isSel,
                    selectedColor: AppDesignSystem.brandGold,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : textP,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() => _minArea = selected ? area : null);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppDesignSystem.brandGold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppDesignSystem.brandGold : Colors.grey.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppDesignSystem.brandGold : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppDesignSystem.brandGold, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetBox(String label, String value, Color textP, Color textS) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: textS)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textP)),
        ],
      ),
    );
  }
}
