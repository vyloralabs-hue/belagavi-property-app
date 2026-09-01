import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_design_system.dart';
import '../../../admin_panel/presentation/providers/founder_providers.dart';
import '../../../admin_panel/domain/entities/moderation_audit_log_entity.dart';
import '../../../../core/security/user_role.dart';
import '../../../../core/localization/language_selector_modal.dart';

class PropertyModerationHistoryView extends ConsumerStatefulWidget {
  final String? propertyId;

  const PropertyModerationHistoryView({super.key, this.propertyId});

  @override
  ConsumerState<PropertyModerationHistoryView> createState() =>
      _PropertyModerationHistoryViewState();
}

class _PropertyModerationHistoryViewState
    extends ConsumerState<PropertyModerationHistoryView> {
  static const String currentUserId = 'usr_founder_001';
  static const UserRole currentUserRole = UserRole.founder;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(founderControlNotifierProvider.notifier)
          .fetchAuditLogs(
            authenticatedUserId: currentUserId,
            userRole: currentUserRole,
            propertyId: widget.propertyId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(founderControlNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Moderation Audit History',
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
      body: state.status == FounderControlStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : state.auditLogs.isEmpty
          ? _buildEmptyState()
          : _buildTimeline(state.auditLogs),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 64,
              color: AppDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Audit History Recorded',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Moderation audit logs will appear here as actions are taken.',
            style: TextStyle(color: AppDesignSystem.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<ModerationAuditLogEntity> logs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final isEmergency =
            log.action == 'EMERGENCY_HIDE' || log.action == 'MARK_DISPUTED';

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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isEmergency
                            ? Colors.red.shade50
                            : AppDesignSystem.primaryNavy.withValues(
                                alpha: 0.1,
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        log.action,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isEmergency
                              ? Colors.red.shade700
                              : AppDesignSystem.primaryNavy,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(log.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: AppDesignSystem.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Actor Role: ${log.actorRole.name.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.swap_horiz_rounded,
                      size: 16,
                      color: AppDesignSystem.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Transition: ${log.previousStatus.name.toUpperCase()} ➔ ${log.newStatus.name.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reason: ${log.reason}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
