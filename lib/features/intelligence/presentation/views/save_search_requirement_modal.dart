import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/requirement_entities.dart';
import '../providers/intelligence_providers.dart';
import '../../../presentation_ui/theme/app_design_system.dart';

class SaveSearchRequirementModal extends ConsumerStatefulWidget {
  final String? initialTitle;
  final String? category;
  final String? locality;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;

  const SaveSearchRequirementModal({
    super.key,
    this.initialTitle,
    this.category,
    this.locality,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialTitle,
    String? category,
    String? locality,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SaveSearchRequirementModal(
          initialTitle: initialTitle,
          category: category,
          locality: locality,
          minPrice: minPrice,
          maxPrice: maxPrice,
          bedrooms: bedrooms,
        ),
      ),
    );
  }

  @override
  ConsumerState<SaveSearchRequirementModal> createState() =>
      _SaveSearchRequirementModalState();
}

class _SaveSearchRequirementModalState extends ConsumerState<SaveSearchRequirementModal> {
  late final TextEditingController _titleController;
  late double _minBudget;
  late double _maxBudget;
  double _tolerance = 10.0; // 5.0, 10.0, 20.0
  String _alertFrequency = 'instant'; // 'instant', 'daily', 'weekly'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final cat = widget.category ?? 'Residential';
    final loc = widget.locality != null && widget.locality!.isNotEmpty ? widget.locality! : 'Belagavi';
    _titleController = TextEditingController(
      text: widget.initialTitle ?? '$loc $cat Requirement',
    );
    _minBudget = widget.minPrice ?? 2000000;
    _maxBudget = widget.maxPrice ?? 6000000;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for this requirement')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final req = SavedRequirementEntity(
      id: '',
      profileId: '',
      title: title,
      purpose: 'buy',
      category: widget.category?.toLowerCase() ?? 'residential',
      preferredLocalities: widget.locality != null && widget.locality!.isNotEmpty
          ? [widget.locality!]
          : const [],
      minBudget: _minBudget,
      maxBudget: _maxBudget,
      priceTolerancePercent: _tolerance,
      minBedrooms: widget.bedrooms,
      alertFrequency: _alertFrequency,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await ref
        .read(savedRequirementsNotifierProvider.notifier)
        .saveRequirement(req);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search requirement saved! You will receive match alerts (±${_tolerance.toInt()}% budget tolerance).'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save search requirement. Please sign in and try again.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF131922) : Colors.white;
    final textP = isDark ? const Color(0xFFFDFCF4) : const Color(0xFF0F172A);
    final textS = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final tolMin = _minBudget * (1.0 - (_tolerance / 100.0));
    final tolMax = _maxBudget * (1.0 + (_tolerance / 100.0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: AppDesignSystem.brandGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save Search & Get Alerts',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textP,
                          ),
                        ),
                        Text(
                          'Get notified whenever new matching properties are listed',
                          style: TextStyle(fontSize: 11, color: textS),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title input
              Text('Requirement Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textP)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: TextStyle(color: textP, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Tilakwadi 2BHK Under 50L',
                  hintStyle: TextStyle(color: textS, fontSize: 13),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF18202B) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Summary of Criteria
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
                    Text('Active Filter Criteria:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textS)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (widget.category != null) _buildTag('Category: ${widget.category}'),
                        if (widget.locality != null && widget.locality!.isNotEmpty) _buildTag('Locality: ${widget.locality}'),
                        if (widget.bedrooms != null) _buildTag('${widget.bedrooms} BHK'),
                        _buildTag('Budget: ₹${(_minBudget / 100000).toStringAsFixed(0)}L - ₹${(_maxBudget / 100000).toStringAsFixed(0)}L'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Price Tolerance Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price Tolerance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textP)),
                  Text('Allow ±${_tolerance.toInt()}% flexibility', style: const TextStyle(fontSize: 11, color: AppDesignSystem.brandGold, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Matches properties between ₹${(tolMin / 100000).toStringAsFixed(1)}L and ₹${(tolMax / 100000).toStringAsFixed(1)}L',
                style: TextStyle(fontSize: 11, color: textS),
              ),
              const SizedBox(height: 10),
              Row(
                children: [5.0, 10.0, 20.0].map((tol) {
                  final isSel = _tolerance == tol;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('±${tol.toInt()}%'),
                      selected: isSel,
                      selectedColor: AppDesignSystem.brandGold,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : textP,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _tolerance = tol),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Alert Frequency
              Text('Alert Frequency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textP)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFrequencyChip('instant', 'Instant Notification'),
                  const SizedBox(width: 8),
                  _buildFrequencyChip('daily', 'Daily Digest'),
                ],
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _handleSave,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Save Requirement & Start Monitoring',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppDesignSystem.brandGold),
      ),
    );
  }

  Widget _buildFrequencyChip(String key, String label) {
    final isSel = _alertFrequency == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: AppDesignSystem.brandGold,
      labelStyle: TextStyle(
        color: isSel ? Colors.white : null,
        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _alertFrequency = key),
    );
  }
}
