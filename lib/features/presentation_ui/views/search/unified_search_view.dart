import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/unified_search/presentation/providers/unified_search_notifier.dart';
import 'package:belagavi_property/features/unified_search/domain/entities/unified_search_entity.dart';
import 'package:belagavi_property/core/localization/language_selector_modal.dart';
import '../shops/shop_registration_view.dart';
import '../shops/shop_detail_view.dart';

class UnifiedSearchView extends ConsumerStatefulWidget {
  const UnifiedSearchView({super.key});

  @override
  ConsumerState<UnifiedSearchView> createState() => _UnifiedSearchViewState();
}

class _UnifiedSearchViewState extends ConsumerState<UnifiedSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unifiedSearchNotifierProvider);
    final notifier = ref.read(unifiedSearchNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Unified Search',
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language_rounded,
              color: AppDesignSystem.primaryNavy,
            ),
            tooltip: 'Change Language',
            onPressed: () => LanguageSelectorModal.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Input & Active Location Chip
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search property, shop, business or location...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppDesignSystem.primaryNavy,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                notifier.updateQuery('');
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(
                        borderRadius: AppDesignSystem.borderRadiusM,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (val) => notifier.updateQuery(val),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: AppDesignSystem.accentEmerald,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Location Context: ${state.activeLocation.displayLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mode Filter Chips ([All], [Properties], [Shops], [Locations])
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: UnifiedSearchMode.values.map((mode) {
                  final isSelected = state.mode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(mode.name.toUpperCase()),
                      selected: isSelected,
                      selectedColor: AppDesignSystem.primaryNavy,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppDesignSystem.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) => notifier.setMode(mode),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Auto-Suggestions List (0 AI)
            if (state.suggestions.isNotEmpty && state.query.isNotEmpty)
              Container(
                color: Colors.amber.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Suggestion: ${state.suggestions.first}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Unified Results List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.results.isEmpty && state.query.isNotEmpty
                  ? _buildZeroResultFallback(context)
                  : state.query.isEmpty
                  ? _buildInitialDiscoveryPrompt()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final res = state.results[index];
                        return _buildResultCard(context, res);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialDiscoveryPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Explore India Property & Local Businesses',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Type a location, property type, or shop name to discover.',
            style: TextStyle(
              color: AppDesignSystem.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZeroResultFallback(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.amber.shade800,
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching results found in this area',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search query or location context.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppDesignSystem.textSecondary),
          ),
          const SizedBox(height: 24),

          // Zero-Result Contextual Actions
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopRegistrationView()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusL,
              ),
            ),
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            label: const Text(
              'Register Your Shop in this Area',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, UnifiedSearchResultEntity res) {
    IconData icon;
    Color iconBg;

    switch (res.type) {
      case UnifiedSearchResultType.property:
        icon = Icons.home_work_rounded;
        iconBg = Colors.blue.shade50;
        break;
      case UnifiedSearchResultType.business:
        icon = Icons.storefront_rounded;
        iconBg = Colors.amber.shade50;
        break;
      case UnifiedSearchResultType.location:
        icon = Icons.location_city_rounded;
        iconBg = Colors.green.shade50;
        break;
      case UnifiedSearchResultType.category:
        icon = Icons.category_rounded;
        iconBg = Colors.purple.shade50;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: const RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: AppDesignSystem.primaryNavy),
        ),
        title: Text(
          res.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(res.subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppDesignSystem.primaryNavy.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            res.type.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
        ),
        onTap: () {
          if (res.businessEntity != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShopDetailView(shop: res.businessEntity!),
              ),
            );
          }
        },
      ),
    );
  }
}
