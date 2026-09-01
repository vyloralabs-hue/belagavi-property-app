import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/admin_panel/domain/entities/advertisement_entity.dart';
import 'package:belagavi_property/features/admin_panel/presentation/providers/founder_providers.dart';
import '../../theme/app_design_system.dart';

class AdsManagementView extends ConsumerStatefulWidget {
  const AdsManagementView({super.key});

  @override
  ConsumerState<AdsManagementView> createState() => _AdsManagementViewState();
}

class _AdsManagementViewState extends ConsumerState<AdsManagementView> {
  static const currentUserId = 'usr_founder_001';
  static const currentUserRole = UserRole.founder;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(localAdsNotifierProvider.notifier).fetchAdvertisements();
    });
  }

  void _showAddAdModal([AdvertisementEntity? editAd]) {
    final titleController = TextEditingController(text: editAd?.title ?? '');
    final descController = TextEditingController(
      text: editAd?.description ?? '',
    );
    final businessController = TextEditingController(
      text: editAd?.businessName ?? '',
    );
    final urlController = TextEditingController(text: editAd?.targetUrl ?? '');
    final imageUrlController = TextEditingController(
      text: editAd?.imageUrl ?? 'https://placeholder.com/ad.jpg',
    );
    AdPlacement selectedPlacement = editAd?.placement ?? AdPlacement.homeMiddle;
    int selectedPriority = editAd?.priority ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editAd != null
                          ? 'Edit Advertisement'
                          : 'Create New Local Advertisement',
                      style: const TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppDesignSystem.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Ad Title / Sponsor Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: businessController,
                  decoration: InputDecoration(
                    labelText: 'Business Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Ad Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'Target URL / Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<AdPlacement>(
                  initialValue: selectedPlacement,
                  items: AdPlacement.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setModalState(() => selectedPlacement = val);
                  },
                  decoration: InputDecoration(
                    labelText: 'Ad Placement',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: selectedPriority,
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Priority 1 (Highest)'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Priority 2 (Medium)'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('Priority 3 (Standard)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null)
                      setModalState(() => selectedPriority = val);
                  },
                  decoration: InputDecoration(
                    labelText: 'Delivery Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          businessController.text.isEmpty) {
                        return;
                      }

                      final now = DateTime.now();
                      final ad = AdvertisementEntity(
                        id: editAd?.id ?? 'ad_${now.millisecondsSinceEpoch}',
                        title: titleController.text,
                        description: descController.text,
                        imageUrl: imageUrlController.text,
                        businessName: businessController.text,
                        targetUrl: urlController.text,
                        placement: selectedPlacement,
                        status: AdStatus.active,
                        startDate: now,
                        endDate: now.add(const Duration(days: 30)),
                        priority: selectedPriority,
                        createdBy: currentUserId,
                        createdAt: editAd?.createdAt ?? now,
                        updatedAt: now,
                      );

                      final notifier = ref.read(
                        localAdsNotifierProvider.notifier,
                      );
                      final success = editAd != null
                          ? await notifier.updateAd(
                              authenticatedUserId: currentUserId,
                              userRole: currentUserRole,
                              ad: ad,
                            )
                          : await notifier.createAd(
                              authenticatedUserId: currentUserId,
                              userRole: currentUserRole,
                              ad: ad,
                            );

                      if (success && mounted) {
                        Navigator.pop(modalCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              editAd != null
                                  ? 'Ad updated successfully'
                                  : 'Ad created successfully',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      editAd != null ? 'Save Changes' : 'Create Advertisement',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final adsState = ref.watch(localAdsNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppDesignSystem.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Local Platform Advertisements',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppDesignSystem.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: AppDesignSystem.primaryNavy,
              size: 28,
            ),
            onPressed: () => _showAddAdModal(),
          ),
        ],
      ),
      body: SafeArea(
        child: adsState.status == LocalAdsStatus.loading
            ? const Center(
                child: const CircularProgressIndicator(
                  color: AppDesignSystem.primaryNavy,
                ),
              )
            : adsState.advertisements.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: adsState.advertisements.length,
                itemBuilder: (context, index) {
                  final ad = adsState.advertisements[index];
                  return _buildAdCard(ad);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.campaign_outlined,
              size: 64,
              color: AppDesignSystem.primaryNavy,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Platform Ads Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create local advertisements for Belagavi businesses, builders, or featured projects.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddAdModal(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Local Ad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard(AdvertisementEntity ad) {
    final statusColor = switch (ad.status) {
      AdStatus.active => Colors.green,
      AdStatus.paused => Colors.orange,
      AdStatus.scheduled => Colors.blue,
      AdStatus.expired => Colors.red,
      AdStatus.draft || AdStatus.archived => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppDesignSystem.borderSubtle),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ad.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Placement: ${ad.placement.name}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ad.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sponsor: ${ad.businessName}',
              style: const TextStyle(
                fontSize: 12,
                color: AppDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ad.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showAddAdModal(ad),
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    final target = ad.status == AdStatus.active
                        ? AdStatus.paused
                        : AdStatus.active;
                    ref
                        .read(localAdsNotifierProvider.notifier)
                        .toggleAdStatus(
                          authenticatedUserId: currentUserId,
                          userRole: currentUserRole,
                          adId: ad.id,
                          targetStatus: target,
                        );
                  },
                  child: Text(
                    ad.status == AdStatus.active ? 'Pause' : 'Activate',
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () => ref
                      .read(localAdsNotifierProvider.notifier)
                      .deleteAd(
                        authenticatedUserId: currentUserId,
                        userRole: currentUserRole,
                        adId: ad.id,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
