import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/admin_panel/presentation/providers/founder_providers.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import '../../theme/app_design_system.dart';

class PropertyVerificationDetailView extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const PropertyVerificationDetailView({super.key, required this.property});

  @override
  ConsumerState<PropertyVerificationDetailView> createState() =>
      _PropertyVerificationDetailViewState();
}

class _PropertyVerificationDetailViewState
    extends ConsumerState<PropertyVerificationDetailView> {
  static const List<String> standardReasonCategories = [
    'Incorrect information',
    'Insufficient property details',
    'Invalid media',
    'Duplicate listing',
    'Ownership concern',
    'Location mismatch',
    'Legal/document concern',
    'Pricing information issue',
    'Policy violation',
    'Other',
  ];

  void _showActionDialog({
    required String title,
    required String actionLabel,
    required String action,
    required ListingStatus targetStatus,
    bool requireReason = true,
  }) {
    final notesController = TextEditingController();
    String selectedCategory = standardReasonCategories.first;
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usr_admin_001';
    const currentUserRole = UserRole.admin;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppDesignSystem.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property: ${widget.property.title}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              if (requireReason) ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Reason Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: standardReasonCategories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setDialogState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional Instructions / Feedback Notes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final notes = notesController.text.trim();
                final fullReason = requireReason
                    ? '$selectedCategory${notes.isNotEmpty ? ": $notes" : ""}'
                    : 'Admin Action';

                final notifier = ref.read(
                  founderControlNotifierProvider.notifier,
                );
                final success = await notifier.moderateProperty(
                  authenticatedUserId: currentUserId,
                  userRole: currentUserRole,
                  propertyId: widget.property.id,
                  targetStatus: targetStatus,
                  action: action,
                  reason: fullReason,
                );

                if (success && mounted) {
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context); // Return to queue
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Property action executed: $actionLabel'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    action == 'REJECT' ||
                        action == 'EMERGENCY_HIDE' ||
                        action == 'ADMIN_HIDE'
                    ? Colors.red
                    : AppDesignSystem.primaryNavy,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;

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
          'Verification Review',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppDesignSystem.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.primaryNavy.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prop.status.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppDesignSystem.primaryNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'ID: ${prop.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                prop.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${prop.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.accentGold,
                ),
              ),
              const SizedBox(height: 20),

              // Dedicated Moderation & Visibility Controls Card for Admin
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AppDesignSystem.primaryNavy,
                        ),
                        SizedBox(width: 8),
                        const Text(
                          'MODERATION / VISIBILITY GOVERNANCE',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppDesignSystem.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Current Status: ${prop.status.name.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showActionDialog(
                            title: 'Admin Hide Property',
                            actionLabel: 'Hide Property',
                            action: 'ADMIN_HIDE',
                            targetStatus: ListingStatus.paused,
                          ),
                          icon: const Icon(
                            Icons.visibility_off_rounded,
                            size: 14,
                          ),
                          label: const Text(
                            'Hide Property',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade900,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showActionDialog(
                            title: 'Put Property On Hold',
                            actionLabel: 'Put On Hold',
                            action: 'HOLD',
                            targetStatus: ListingStatus.paused,
                          ),
                          icon: const Icon(
                            Icons.pause_circle_rounded,
                            size: 14,
                          ),
                          label: const Text(
                            'Put On Hold',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showActionDialog(
                            title: 'Restore Property to Live',
                            actionLabel: 'Restore to Live',
                            action: 'RESTORE',
                            targetStatus: ListingStatus.published,
                            requireReason: false,
                          ),
                          icon: const Icon(Icons.restore_rounded, size: 14),
                          label: const Text(
                            'Restore',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showActionDialog(
                            title: 'Mark Disputed',
                            actionLabel: 'Mark Disputed',
                            action: 'DISPUTE',
                            targetStatus: ListingStatus.disputed,
                          ),
                          icon: const Icon(Icons.gavel_rounded, size: 14),
                          label: const Text(
                            'Dispute',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (prop.status == ListingStatus.disputed)
                          ElevatedButton.icon(
                            onPressed: () => _showActionDialog(
                              title: 'Resolve Dispute & Restore Listing',
                              actionLabel: 'Resolve Dispute',
                              action: 'RESOLVE_DISPUTE',
                              targetStatus: ListingStatus.published,
                              requireReason: false,
                            ),
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                            ),
                            label: const Text(
                              'Resolve Dispute',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Section Cards
              _buildSectionCard('1. Basic Details', [
                'Description: ${prop.description}',
                'Category: ${prop.category.name}',
                'Negotiable: ${prop.isNegotiable ? "Yes" : "No"}',
              ]),
              _buildSectionCard('2. Property Type', [
                'Subtype: ${prop.type.name}',
              ]),
              _buildSectionCard('3. Location Information', [
                'State: ${prop.state}',
                'District: ${prop.district}',
                'City: ${prop.city}',
                'Locality: ${prop.locality}',
                'Address: ${prop.address}',
                'Pincode: ${prop.pincode}',
              ]),
              _buildSectionCard('4. Price & Area Specifications', [
                'Price: ₹${prop.price}',
                'Super Built-Up Area: ${prop.specifications.superBuiltUpArea ?? "N/A"} ${prop.specifications.areaUnit}',
                'Carpet Area: ${prop.specifications.carpetArea ?? "N/A"} ${prop.specifications.areaUnit}',
                'Bedrooms: ${prop.specifications.bedrooms ?? "N/A"}',
                'Bathrooms: ${prop.specifications.bathrooms ?? "N/A"}',
              ]),
              _buildSectionCard('5. Owner / Seller Information', [
                'Owner ID: ${prop.ownerId}',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<String> lines) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppDesignSystem.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
