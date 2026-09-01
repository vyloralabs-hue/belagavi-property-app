import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import 'package:belagavi_property/features/local_shops/presentation/providers/local_shops_notifier.dart';
import 'package:belagavi_property/features/local_shops/domain/entities/business_entities.dart';
import 'package:belagavi_property/core/localization/language_selector_modal.dart';
import 'shop_registration_view.dart';
import 'shop_detail_view.dart';

class LocalShopsDiscoveryView extends ConsumerStatefulWidget {
  const LocalShopsDiscoveryView({super.key});

  @override
  ConsumerState<LocalShopsDiscoveryView> createState() =>
      _LocalShopsDiscoveryViewState();
}

class _LocalShopsDiscoveryViewState
    extends ConsumerState<LocalShopsDiscoveryView> {
  final TextEditingController _locationSearchController =
      TextEditingController();
  final TextEditingController _keywordSearchController =
      TextEditingController();

  @override
  void dispose() {
    _locationSearchController.dispose();
    _keywordSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localShopsNotifierProvider);
    final notifier = ref.read(localShopsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Local Shops & Businesses',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShopRegistrationView()),
        ),
        backgroundColor: AppDesignSystem.primaryNavy,
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: const Text(
          'Register Shop',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Fast Location & Keyword Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Fast Location Autocomplete Bar
                  TextField(
                    controller: _locationSearchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search Location (e.g. Tilakwadi, Belagavi, Pune)',
                      prefixIcon: const Icon(
                        Icons.location_on_rounded,
                        color: AppDesignSystem.primaryNavy,
                      ),
                      suffixIcon: _locationSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _locationSearchController.clear();
                                notifier.updateLocation('Belagavi');
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
                    onSubmitted: (val) => notifier.updateLocation(val),
                  ),
                  const SizedBox(height: 10),
                  // Keyword Filter Bar
                  TextField(
                    controller: _keywordSearchController,
                    decoration: const InputDecoration(
                      hintText: 'Search shop name, pipes, hardware, paints...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppDesignSystem.textSecondary,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppDesignSystem.borderRadiusM,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (val) => notifier.updateSearchQuery(val),
                  ),
                ],
              ),
            ),

            // Active Location Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 16,
                    color: AppDesignSystem.accentEmerald,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Showing shops in: ${state.selectedLocation.displayLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppDesignSystem.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All Categories'),
                      selected: state.selectedCategoryId == null,
                      selectedColor: AppDesignSystem.primaryNavy,
                      labelStyle: TextStyle(
                        color: state.selectedCategoryId == null
                            ? Colors.white
                            : AppDesignSystem.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => notifier.selectCategory(null),
                    ),
                  ),
                  ...state.categories.map((cat) {
                    final isSelected = state.selectedCategoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: AppDesignSystem.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppDesignSystem.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => notifier.selectCategory(cat.id),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Business Results List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.businesses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.businesses.length,
                      itemBuilder: (context, index) {
                        final shop = state.businesses[index];
                        return _buildShopCard(context, shop);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No local shops found in this area',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Be the first to register your business!',
            style: TextStyle(color: AppDesignSystem.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, BusinessEntity shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: const RoundedRectangleBorder(
        borderRadius: AppDesignSystem.borderRadiusL,
      ),
      elevation: 1,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShopDetailView(shop: shop)),
        ),
        borderRadius: AppDesignSystem.borderRadiusL,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppDesignSystem.primaryNavy.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: AppDesignSystem.primaryNavy,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shop.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (shop.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 12,
                                      color: Color(0xFF059669),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shop.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppDesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                shop.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: shop.productsServices
                    .map(
                      (item) => Chip(
                        label: Text(item, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.grey.shade100,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
