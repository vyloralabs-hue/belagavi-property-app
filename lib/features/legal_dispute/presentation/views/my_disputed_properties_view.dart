import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/presentation_ui/theme/app_design_system.dart';
import '../widgets/dispute_property_image.dart';
import '../../domain/entities/dispute_entities.dart';
import '../providers/dispute_providers.dart';

class MyDisputedPropertiesView extends ConsumerStatefulWidget {
  const MyDisputedPropertiesView({super.key});

  @override
  ConsumerState<MyDisputedPropertiesView> createState() => _MyDisputedPropertiesViewState();
}

class _MyDisputedPropertiesViewState extends ConsumerState<MyDisputedPropertiesView> {
  static const List<Map<String, String>> _statusTabs = [
    {'key': 'ALL', 'label': 'All'},
    {'key': 'DRAFT', 'label': 'Draft'},
    {'key': 'SUBMITTED', 'label': 'Submitted'},
    {'key': 'UNDER_REVIEW', 'label': 'Under Review'},
    {'key': 'PUBLISHED', 'label': 'Published'},
    {'key': 'RESOLVED', 'label': 'Resolved'},
    {'key': 'REJECTED_WITHDRAWN', 'label': 'Rejected / Withdrawn'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchDisputes());
  }

  void _fetchDisputes() {
    String userId = AuthSessionStorageHelper.getUserUid() ?? '';
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) {
        userId = fbUid;
      }
    } catch (_) {}

    if (userId.isNotEmpty) {
      ref.read(myDisputedPropertiesNotifierProvider.notifier).fetchMyDisputes(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myDisputedPropertiesNotifierProvider);
    final textP = AppDesignSystem.textP(context);
    final surfaceBg = AppDesignSystem.surfaceBg(context);
    final scaffoldBg = AppDesignSystem.scaffoldBg(context);
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);

    String currentUserId = AuthSessionStorageHelper.getUserUid() ?? '';
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) {
        currentUserId = fbUid;
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'My Disputed Properties',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: textP,
          ),
        ),
        backgroundColor: surfaceBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textP),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Add Dispute',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppDesignSystem.brandGold),
            onPressed: () => context.push(AppRoutes.addDispute),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Tabs Bar
          Container(
            color: surfaceBg,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _statusTabs.map((tab) {
                  final isSelected = state.activeTab == tab['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        tab['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppDesignSystem.brandGold,
                      backgroundColor: cardBg,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : textP),
                      onSelected: (_) {
                        ref.read(myDisputedPropertiesNotifierProvider.notifier).setActiveTab(tab['key']!, currentUserId);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Divider(height: 1, color: borderCol),

          // Main List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchDisputes(),
              color: AppDesignSystem.brandGold,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppDesignSystem.brandGold))
                  : state.disputes.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.disputes.length,
                          itemBuilder: (context, index) {
                            final item = state.disputes[index];
                            return _buildMyDisputeCard(context, item);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded, size: 54, color: AppDesignSystem.brandGold),
            const SizedBox(height: 12),
            Text(
              'No records in this tab',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textP),
            ),
            const SizedBox(height: 6),
            Text(
              'You have no disputed property submissions under the selected status filter.',
              style: TextStyle(fontSize: 12, color: textS),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.addDispute),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+ Report New Dispute'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.brandGold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyDisputeCard(BuildContext context, PropertyDisputeEntity dispute) {
    final cardBg = AppDesignSystem.cardBg(context);
    final borderCol = AppDesignSystem.borderCol(context);
    final textP = AppDesignSystem.textP(context);
    final textS = AppDesignSystem.textS(context);

    final status = dispute.verificationStatus;
    final (statusColor, statusBg) = switch (status) {
      DisputeVerificationStatus.publishedListed => (const Color(0xFF059669), const Color(0xFF059669).withValues(alpha: 0.15)),
      DisputeVerificationStatus.underReview => (const Color(0xFFD97706), const Color(0xFFD97706).withValues(alpha: 0.15)),
      DisputeVerificationStatus.submitted => (const Color(0xFF3B82F6), const Color(0xFF3B82F6).withValues(alpha: 0.15)),
      DisputeVerificationStatus.draft => (const Color(0xFF6B7280), const Color(0xFF6B7280).withValues(alpha: 0.15)),
      DisputeVerificationStatus.resolved => (const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.15)),
      _ => (const Color(0xFFEF4444), const Color(0xFFEF4444).withValues(alpha: 0.15)),
    };

    final coverMediaUrl = dispute.photoUrls.isNotEmpty
        ? dispute.photoUrls.first
        : (dispute.documentUrls.isNotEmpty ? dispute.documentUrls.first : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/disputed-properties/${dispute.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: DisputePropertyImage(
                    imageUrl: coverMediaUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.displayName,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              dispute.disputeCategory,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: textS,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dispute.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textP),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dispute.locality}, ${dispute.city}',
                          style: TextStyle(fontSize: 11, color: textS),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 1, color: borderCol),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Stage: ${dispute.currentStage}',
                    style: TextStyle(fontSize: 10, color: textS),
                  ),
                  const Spacer(),
                  Text(
                    '${dispute.documents.length + dispute.documentUrls.length} attached docs',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textP),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderCol.withValues(alpha: 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View Details Button
                  TextButton.icon(
                    onPressed: () => context.push('/disputed-properties/${dispute.id}'),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text('View', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppDesignSystem.brandGold,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  // Edit Button (Allowed for draft, submitted, under_review)
                  if (status == DisputeVerificationStatus.draft ||
                      status == DisputeVerificationStatus.submitted ||
                      status == DisputeVerificationStatus.underReview)
                    TextButton.icon(
                      onPressed: () => _handleEditDispute(dispute),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  // Withdraw Button (Allowed for submitted, under_review, publishedListed)
                  if (status == DisputeVerificationStatus.submitted ||
                      status == DisputeVerificationStatus.underReview ||
                      status == DisputeVerificationStatus.publishedListed)
                    TextButton.icon(
                      onPressed: () => _handleWithdrawDispute(dispute),
                      icon: const Icon(Icons.archive_outlined, size: 14),
                      label: const Text('Withdraw', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD97706),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  // Delete Button (Draft, submitted, or under_review)
                  if (status == DisputeVerificationStatus.draft ||
                      status == DisputeVerificationStatus.submitted ||
                      status == DisputeVerificationStatus.underReview)
                    TextButton.icon(
                      onPressed: () => _handleDeleteDispute(dispute),
                      icon: const Icon(Icons.delete_outline_rounded, size: 14),
                      label: const Text('Delete', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditDispute(PropertyDisputeEntity dispute) {
    context.push(
      AppRoutes.addDispute,
      extra: dispute,
    );
  }

  Future<void> _handleWithdrawDispute(PropertyDisputeEntity dispute) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Dispute Listing?'),
        content: Text(
          'Are you sure you want to withdraw "${dispute.title}"? It will no longer be active or visible in public registries.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    String currentUserId = AuthSessionStorageHelper.getUserUid() ?? '';
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) {
        currentUserId = fbUid;
      }
    } catch (_) {}

    final repo = ref.read(disputeRepositoryProvider);
    final result = await repo.updateDisputeStatus(
      disputeId: dispute.id,
      newStatus: DisputeVerificationStatus.withdrawn,
      authenticatedUserId: currentUserId,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          );
        }
      },
      (updated) {
        ref.read(myDisputedPropertiesNotifierProvider.notifier).updateDisputeLocally(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dispute listing withdrawn successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Future<void> _handleDeleteDispute(PropertyDisputeEntity dispute) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Dispute Listing?'),
        content: Text(
          'Are you sure you want to permanently delete "${dispute.title}"? This will also remove any uploaded documents and cannot be undone.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    String currentUserId = AuthSessionStorageHelper.getUserUid() ?? '';
    try {
      final fbUid = FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) {
        currentUserId = fbUid;
      }
    } catch (_) {}

    final repo = ref.read(disputeRepositoryProvider);
    final result = await repo.deleteDispute(
      dispute.id,
      authenticatedUserId: currentUserId,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          );
        }
      },
      (_) {
        ref.read(myDisputedPropertiesNotifierProvider.notifier).removeDisputeLocally(dispute.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dispute listing deleted permanently.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}
