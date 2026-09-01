import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../providers/support_faq_notifier.dart';
import '../widgets/faq_accordion_item.dart';

/// Premium FAQ Centre with search and category filtering
class SupportFAQView extends ConsumerStatefulWidget {
  const SupportFAQView({super.key});

  @override
  ConsumerState<SupportFAQView> createState() => _SupportFAQViewState();
}

class _SupportFAQViewState extends ConsumerState<SupportFAQView> {
  final _searchController = TextEditingController();

  static const _categories = [
    ('all', 'All'),
    ('buying', 'Buying'),
    ('selling', 'Selling'),
    ('documentation', 'Documents'),
    ('legal', 'Legal'),
    ('general', 'General'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(supportFAQNotifierProvider.notifier).loadFAQs(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faqState = ref.watch(supportFAQNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'FAQ Centre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppDesignSystem.textPrimary,
            size: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (q) =>
                  ref.read(supportFAQNotifierProvider.notifier).search(q),
              decoration: InputDecoration(
                hintText: 'Search FAQs…',
                hintStyle: const TextStyle(
                  color: AppDesignSystem.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppDesignSystem.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: AppDesignSystem.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(supportFAQNotifierProvider.notifier)
                              .search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: const OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusPill,
                  borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusPill,
                  borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppDesignSystem.borderRadiusPill,
                  borderSide: BorderSide(
                    color: AppDesignSystem.primaryNavy,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Category Filter Chips
          if (faqState is SupportFAQLoaded)
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (key, label) = _categories[i];
                  final selected = faqState.selectedCategory == key;
                  return GestureDetector(
                    onTap: () => ref
                        .read(supportFAQNotifierProvider.notifier)
                        .filterByCategory(key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppDesignSystem.primaryNavy
                            : Colors.white,
                        borderRadius: AppDesignSystem.borderRadiusPill,
                        border: Border.all(
                          color: selected
                              ? AppDesignSystem.primaryNavy
                              : AppDesignSystem.borderSubtle,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppDesignSystem.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          // FAQ List
          Expanded(
            child: switch (faqState) {
              SupportFAQInitial() => const Center(
                child: CircularProgressIndicator(
                  color: AppDesignSystem.primaryNavy,
                ),
              ),
              SupportFAQLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppDesignSystem.primaryNavy,
                ),
              ),
              SupportFAQError(message: final msg) => Center(
                child: Text(
                  'Error: $msg',
                  style: const TextStyle(color: AppDesignSystem.textSecondary),
                ),
              ),
              SupportFAQLoaded(filteredFAQs: final faqs) =>
                faqs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          final faq = faqs[index];
                          return FAQAccordionItem(
                            question: faq.question,
                            answer: faq.answer,
                            helpfulCount: faq.helpfulCount,
                            isPinned: faq.isPinned,
                          );
                        },
                      ),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/tickets'),
        backgroundColor: AppDesignSystem.primaryNavy,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Ask a Question',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppDesignSystem.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No FAQs found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or browse all categories',
            style: TextStyle(
              color: AppDesignSystem.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(supportFAQNotifierProvider.notifier)
                ..search('')
                ..filterByCategory('all');
            },
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }
}
