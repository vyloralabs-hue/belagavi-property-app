import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/requirement_entities.dart';
import '../providers/intelligence_providers.dart';
import 'save_search_requirement_modal.dart';

class MyPropertyAlertsView extends ConsumerStatefulWidget {
  const MyPropertyAlertsView({super.key});

  @override
  ConsumerState<MyPropertyAlertsView> createState() => _MyPropertyAlertsViewState();
}

class _MyPropertyAlertsViewState extends ConsumerState<MyPropertyAlertsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedRequirementsNotifierProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedRequirementsNotifierProvider);
    final notifier = ref.read(savedRequirementsNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF0A0D11) : AppDesignSystem.backgroundWhite;
    final surfaceBg = isDark ? const Color(0xFF131922) : Colors.white;
    final textP = isDark ? const Color(0xFFFDFCF4) : const Color(0xFF0F172A);
    final textS = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final unreadMatchesCount = state.matches.where((m) => !m.isViewed).length;

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          'My Property Alerts',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textP,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppDesignSystem.brandGold),
            tooltip: 'Add Requirement',
            onPressed: () => SaveSearchRequirementModal.show(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppDesignSystem.brandGold,
          labelColor: AppDesignSystem.brandGold,
          unselectedLabelColor: textS,
          tabs: [
            Tab(
              child: Text(
                'Requirements (${state.requirements.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Matched (${state.matches.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (unreadMatchesCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadMatchesCount',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppDesignSystem.brandGold))
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Requirements Tab
                state.requirements.isEmpty
                    ? _buildEmptyRequirements(context, textP, textS)
                    : RefreshIndicator(
                        color: AppDesignSystem.brandGold,
                        onRefresh: () => notifier.loadAll(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.requirements.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final req = state.requirements[index];
                            return _buildRequirementCard(context, req, notifier, surfaceBg, textP, textS);
                          },
                        ),
                      ),

                // 2. Matches Tab
                state.matches.isEmpty
                    ? _buildEmptyMatches(context, textP, textS)
                    : RefreshIndicator(
                        color: AppDesignSystem.brandGold,
                        onRefresh: () => notifier.loadAll(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.matches.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final match = state.matches[index];
                            return _buildMatchCard(context, match, notifier, surfaceBg, textP, textS);
                          },
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppDesignSystem.brandGold,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Requirement', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => SaveSearchRequirementModal.show(context),
      ),
    );
  }

  Widget _buildEmptyRequirements(BuildContext context, Color textP, Color textS) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.saved_search_rounded, size: 48, color: AppDesignSystem.brandGold),
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Requirements',
              style: TextStyle(fontFamily: AppDesignSystem.fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: textP),
            ),
            const SizedBox(height: 6),
            Text(
              'Save your property criteria to get automated match notifications whenever a matching property is published in Belagavi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textS),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => SaveSearchRequirementModal.show(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create First Requirement', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMatches(BuildContext context, Color textP, Color textS) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_outlined, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'No Matches Yet',
              style: TextStyle(fontFamily: AppDesignSystem.fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: textP),
            ),
            const SizedBox(height: 6),
            Text(
              'When sellers list properties matching your budget and location criteria, they will appear here with deterministic match scores.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textS),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementCard(
    BuildContext context,
    SavedRequirementEntity req,
    SavedRequirementsNotifier notifier,
    Color cardBg,
    Color textP,
    Color textS,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: req.isActive ? AppDesignSystem.brandGold.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  req.title,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textP,
                  ),
                ),
              ),
              Switch(
                value: req.isActive,
                activeColor: AppDesignSystem.brandGold,
                onChanged: (val) => notifier.toggleActive(req.id, val),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '₹${(req.minBudget / 100000).toStringAsFixed(0)}L - ₹${(req.maxBudget / 100000).toStringAsFixed(0)}L (±${req.priceTolerancePercent.toInt()}% Tolerance)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppDesignSystem.brandGold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge(req.category.toUpperCase()),
              if (req.preferredLocalities.isNotEmpty)
                _buildBadge(req.preferredLocalities.join(', ')),
              if (req.minBedrooms != null)
                _buildBadge('${req.minBedrooms} BHK'),
              _buildBadge(req.alertFrequency.toUpperCase()),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                label: const Text('Delete', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                onPressed: () => notifier.deleteRequirement(req.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    PropertyAlertMatchEntity match,
    SavedRequirementsNotifier notifier,
    Color cardBg,
    Color textP,
    Color textS,
  ) {
    final snapshot = match.propertySnapshot;
    final title = (snapshot?['title'] as String?) ?? 'Matched Property';
    final locality = (snapshot?['locality'] as String?) ?? 'Belagavi';
    final price = (snapshot?['price'] as num?)?.toDouble() ?? 0.0;

    return InkWell(
      onTap: () {
        notifier.markMatchViewed(match.id);
        context.push('/property/${match.propertyId}');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: match.isViewed ? Colors.grey.withValues(alpha: 0.2) : AppDesignSystem.brandGold,
            width: match.isViewed ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match score circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              ),
              child: Center(
                child: Text(
                  '${match.matchScore}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textP,
                          ),
                        ),
                      ),
                      if (!match.isViewed) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppDesignSystem.brandGold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('NEW', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${(price / 100000).toStringAsFixed(1)} Lakhs • $locality',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppDesignSystem.brandGold,
                    ),
                  ),
                  if (match.matchReasons.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      match.matchReasons.join(' • '),
                      style: TextStyle(fontSize: 11, color: textS),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
