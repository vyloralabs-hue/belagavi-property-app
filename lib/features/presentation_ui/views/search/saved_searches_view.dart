import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';
import '../../../property_search/presentation/providers/saved_search_notifier.dart';
import '../../../property_search/presentation/providers/property_search_notifier.dart';
import '../../../property_search/domain/entities/saved_search_entity.dart';
import '../../../../core/localization/language_selector_modal.dart';

class SavedSearchesView extends ConsumerWidget {
  const SavedSearchesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedSearchNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: Text(
          'Saved Searches (${state.savedSearches.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.savedSearches.isEmpty
          ? _buildEmptyState(context)
          : _buildList(context, ref, state.savedSearches),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Saved Searches Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Save your frequent filter criteria to quickly run searches anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppDesignSystem.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<SavedSearchEntity> searches,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searches.length,
      itemBuilder: (context, index) {
        final item = searches[index];
        final q = item.query;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDesignSystem.borderRadiusL,
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppDesignSystem.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.deterministicSummary,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        ref
                            .read(savedSearchNotifierProvider.notifier)
                            .deleteSavedSearch(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved search deleted')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (q.city != null) _buildChip('City: ${q.city}'),
                    if (q.locality != null)
                      _buildChip('Locality: ${q.locality}'),
                    if (q.category != null)
                      _buildChip('Category: ${q.category!.name}'),
                    if (q.type != null) _buildChip('Type: ${q.type!.name}'),
                    if (q.purpose != null)
                      _buildChip('Purpose: ${q.purpose!.name}'),
                    if (q.minPrice != null || q.maxPrice != null)
                      _buildChip(
                        'Price: ₹${q.minPrice?.toInt() ?? 0} - ₹${q.maxPrice?.toInt() ?? 'Max'}',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.primaryNavy,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDesignSystem.borderRadiusM,
                      ),
                    ),
                    icon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Run Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(propertySearchNotifierProvider.notifier)
                          .executeSearch(q);
                      context.push('/search');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppDesignSystem.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
