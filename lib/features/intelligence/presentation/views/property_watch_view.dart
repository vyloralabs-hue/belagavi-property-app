import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/property_watch_entities.dart';
import '../providers/intelligence_providers.dart';

class PropertyWatchView extends ConsumerStatefulWidget {
  const PropertyWatchView({super.key});

  @override
  ConsumerState<PropertyWatchView> createState() => _PropertyWatchViewState();
}

class _PropertyWatchViewState extends ConsumerState<PropertyWatchView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(propertyWatchNotifierProvider.notifier).loadWatchesAndEntitlement();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyWatchNotifierProvider);
    final notifier = ref.read(propertyWatchNotifierProvider.notifier);

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
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          'Survey & Property Watch',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textP,
          ),
        ),
        actions: [
          if (state.isPaidEntitled)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppDesignSystem.brandGold),
              tooltip: 'Add Monitored Survey',
              onPressed: () => context.push('/property-watch/add'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppDesignSystem.brandGold))
          : !state.isPaidEntitled
              ? _buildPremiumFeatureLock(context, surfaceBg, textP, textS)
              : state.watches.isEmpty
                  ? _buildEmptyWatches(context, textP, textS)
                  : RefreshIndicator(
                      color: AppDesignSystem.brandGold,
                      onRefresh: () => notifier.loadWatchesAndEntitlement(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.watches.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final watch = state.watches[index];
                          return _buildWatchCard(context, watch, notifier, surfaceBg, textP, textS);
                        },
                      ),
                    ),
      floatingActionButton: state.isPaidEntitled
          ? FloatingActionButton.extended(
              backgroundColor: AppDesignSystem.brandGold,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Watch', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => context.push('/property-watch/add'),
            )
          : null,
    );
  }

  /// 100% Paid-Only Lock Card for Free Users (NO fake free trials)
  Widget _buildPremiumFeatureLock(BuildContext context, Color surfaceBg, Color textP, Color textS) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppDesignSystem.brandGold.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, size: 44, color: AppDesignSystem.brandGold),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PAID SUBSCRIPTION FEATURE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Paid Property & Survey Monitoring',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textP,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Track specific survey numbers, subdivisions, and land parcels across Belagavi district with automated public record updates.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textS, height: 1.4),
              ),
              const SizedBox(height: 20),
              // Feature bullets
              _buildFeatureBullet(Icons.check_circle_rounded, 'Contextual identity tracking (Taluk > Village > Survey/CTS)', textP),
              const SizedBox(height: 8),
              _buildFeatureBullet(Icons.check_circle_rounded, 'Instant alerts when new public listings or notices match', textP),
              const SizedBox(height: 8),
              _buildFeatureBullet(Icons.check_circle_rounded, 'Strict privacy protection & neutral public record timeline', textP),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.brandGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Monitoring Packs'),
                        content: const Text(
                          'Property & Survey Monitoring packs will be available soon. For early enterprise or advocate access in Belagavi, please contact support.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                  label: const Text(
                    'View Monitoring Plans',
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

  Widget _buildFeatureBullet(IconData icon, String text, Color textP) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF10B981)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: textP, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildEmptyWatches(BuildContext context, Color textP, Color textS) {
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
              child: const Icon(Icons.visibility_outlined, size: 48, color: AppDesignSystem.brandGold),
            ),
            const SizedBox(height: 16),
            Text(
              'No Monitored Properties Yet',
              style: TextStyle(fontFamily: AppDesignSystem.fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: textP),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first survey number or land parcel to monitor public records, listings, and approved notices.',
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
              onPressed: () => context.push('/property-watch/add'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Monitored Survey', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchCard(
    BuildContext context,
    PropertyWatchEntity watch,
    PropertyWatchNotifier notifier,
    Color cardBg,
    Color textP,
    Color textS,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppDesignSystem.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  watch.formattedSurveyDisplayName,
                  style: const TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppDesignSystem.brandGold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MONITORING ACTIVE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            watch.watchName,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textP,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  watch.formattedLocationDisplayName,
                  style: TextStyle(fontSize: 12, color: textS),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Role: ${watch.relationship.displayName}',
                style: TextStyle(fontSize: 12, color: textS),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Recent neutral events
          if (watch.recentEvents.isNotEmpty) ...[
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'Public Record Updates:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textS),
            ),
            const SizedBox(height: 6),
            ...watch.recentEvents.take(2).map((ev) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppDesignSystem.brandGold),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ev.title,
                          style: TextStyle(fontSize: 11, color: textP, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              'No public notices or conflicting listings observed to date.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: textS),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                label: const Text('Remove Watch', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                onPressed: () => notifier.deleteWatch(watch.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
