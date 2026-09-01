import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/admin_panel/presentation/providers/founder_providers.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import 'package:belagavi_property/features/property/presentation/providers/my_properties_notifier.dart';
import '../../theme/app_design_system.dart';
import 'property_verification_detail_view.dart';

class PropertyVerificationQueueView extends ConsumerStatefulWidget {
  const PropertyVerificationQueueView({super.key});

  @override
  ConsumerState<PropertyVerificationQueueView> createState() =>
      _PropertyVerificationQueueViewState();
}

class _PropertyVerificationQueueViewState
    extends ConsumerState<PropertyVerificationQueueView> {
  static const String currentUserId = 'usr_admin_001';
  static const UserRole currentUserRole = UserRole.admin;

  String _selectedTab = 'SUBMITTED';

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesListProvider);

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
          'Property Verification Queue',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppDesignSystem.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children:
                    [
                          'SUBMITTED',
                          'UNDER_REVIEW',
                          'CHANGES_REQUESTED',
                          'APPROVED',
                          'REJECTED',
                          'DISPUTED',
                          'PAUSED',
                          'ARCHIVED',
                        ]
                        .map(
                          (tab) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(tab.replaceAll('_', ' ')),
                              selected: _selectedTab == tab,
                              selectedColor: AppDesignSystem.primaryNavy,
                              labelStyle: TextStyle(
                                color: _selectedTab == tab
                                    ? Colors.white
                                    : AppDesignSystem.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedTab = tab),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            Expanded(
              child: switch (propertiesAsync.status) {
                MyPropertiesStateStatus.loading ||
                MyPropertiesStateStatus.initial => const Center(
                  child: const CircularProgressIndicator(
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
                MyPropertiesStateStatus.error => Center(
                  child: Text(
                    'Error loading verification queue: ${propertiesAsync.errorMessage ?? "Unknown error"}',
                  ),
                ),
                MyPropertiesStateStatus.loaded => Builder(
                  builder: (_) {
                    final properties = propertiesAsync.allProperties;
                    final filtered = properties.where((p) {
                      final statusStr = p.status.name.toUpperCase();
                      if (_selectedTab == 'SUBMITTED') {
                        return statusStr == 'SUBMITTED' ||
                            statusStr == 'PENDINGVERIFICATION';
                      }
                      if (_selectedTab == 'UNDER_REVIEW')
                        return statusStr == 'UNDERREVIEW';
                      if (_selectedTab == 'CHANGES_REQUESTED')
                        return statusStr == 'CHANGESREQUESTED';
                      if (_selectedTab == 'APPROVED')
                        return statusStr == 'APPROVED' ||
                            statusStr == 'PUBLISHED';
                      if (_selectedTab == 'REJECTED')
                        return statusStr == 'REJECTED';
                      if (_selectedTab == 'DISPUTED')
                        return statusStr == 'DISPUTED';
                      if (_selectedTab == 'PAUSED')
                        return statusStr == 'PAUSED';
                      if (_selectedTab == 'ARCHIVED')
                        return statusStr == 'ARCHIVED';
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final prop = filtered[index];
                        return _buildQueueCard(prop);
                      },
                    );
                  },
                ),
              },
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
          const Icon(
            Icons.verified_outlined,
            size: 64,
            color: AppDesignSystem.primaryNavy,
          ),
          const SizedBox(height: 16),
          const Text(
            'Queue Clear',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No listings currently pending verification in $_selectedTab.',
            style: const TextStyle(
              fontSize: 13,
              color: AppDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(PropertyEntity prop) {
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
                    color: AppDesignSystem.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prop.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppDesignSystem.primaryNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Owner ID: ${prop.ownerId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              prop.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${prop.locality}, ${prop.city}',
              style: const TextStyle(
                fontSize: 12,
                color: AppDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${prop.price.toStringAsFixed(0)} • ${prop.category.name.toUpperCase()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.accentGold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyVerificationDetailView(property: prop),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                  label: const Text('Review Listing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryNavy,
                    foregroundColor: Colors.white,
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
