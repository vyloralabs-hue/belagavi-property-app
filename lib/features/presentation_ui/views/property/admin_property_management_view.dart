import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:belagavi_property/core/security/user_role.dart';
import 'package:belagavi_property/features/auth/utils/auth_session_storage_helper.dart';
import 'package:belagavi_property/features/property/domain/entities/property_entities.dart';
import 'package:belagavi_property/features/property/presentation/providers/property_providers.dart';
import '../../theme/app_design_system.dart';
import 'widgets/category_selection_modal.dart';

/// App Owner / Admin Global Property Management Screen
/// Complete authority to View, Edit, Hold, Resume, Publish, Unpublish, Delete,
/// Restore, Mark Sold, Mark Rented, Mark Leased, and Change Status on ANY listing.
class AdminPropertyManagementView extends ConsumerStatefulWidget {
  const AdminPropertyManagementView({super.key});

  @override
  ConsumerState<AdminPropertyManagementView> createState() =>
      _AdminPropertyManagementViewState();
}

class _AdminPropertyManagementViewState
    extends ConsumerState<AdminPropertyManagementView> {
  List<PropertyEntity> _properties = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllProperties();
  }

  Future<void> _loadAllProperties() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'admin_global';
    final userRole = AuthSessionStorageHelper.getParsedUserRole();

    final repo = ref.read(propertyRepositoryProvider);
    final result = await repo.getAllPropertiesForAdmin(
      authenticatedUserId: userId,
      userRole: userRole.isAdminOrFounder ? userRole : UserRole.founder,
      limit: 100,
    );

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _properties = [];
            _isLoading = false;
          });
        },
        (list) {
          setState(() {
            _properties = list;
            _isLoading = false;
          });
        },
      );
    }
  }

  List<PropertyEntity> get _filteredProperties {
    return _properties.where((p) {
      if (_selectedStatusFilter != 'ALL') {
        if (_selectedStatusFilter == 'SUBMITTED' &&
            p.status != ListingStatus.submitted &&
            p.status != ListingStatus.pendingVerification) {
          return false;
        }
        if (_selectedStatusFilter == 'UNDER_REVIEW' &&
            p.status != ListingStatus.underReview) {
          return false;
        }
        if (_selectedStatusFilter == 'CHANGES_REQUESTED' &&
            p.status != ListingStatus.changesRequested) {
          return false;
        }
        if (_selectedStatusFilter == 'APPROVED' &&
            p.status != ListingStatus.approved) {
          return false;
        }
        if (_selectedStatusFilter == 'PUBLISHED' &&
            p.status != ListingStatus.published &&
            p.status != ListingStatus.active) {
          return false;
        }
        if (_selectedStatusFilter == 'ON_HOLD' &&
            p.status != ListingStatus.paused) {
          return false;
        }
        if (_selectedStatusFilter == 'CLOSED' &&
            p.status != ListingStatus.sold &&
            p.status != ListingStatus.rented &&
            p.status != ListingStatus.leased) {
          return false;
        }
        if (_selectedStatusFilter == 'REJECTED' &&
            p.status != ListingStatus.rejected) {
          return false;
        }
        if (_selectedStatusFilter == 'ARCHIVED' &&
            p.status != ListingStatus.archived) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesLocality = p.locality.toLowerCase().contains(query);
        final matchesOwner = p.ownerId.toLowerCase().contains(query);
        final matchesCategory = p.category.name.toLowerCase().contains(query);
        return matchesTitle ||
            matchesLocality ||
            matchesOwner ||
            matchesCategory;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusTabs = [
      'ALL',
      'SUBMITTED',
      'UNDER_REVIEW',
      'CHANGES_REQUESTED',
      'APPROVED',
      'PUBLISHED',
      'ON_HOLD',
      'CLOSED',
      'REJECTED',
      'ARCHIVED',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFFDFCF4),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Management',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Color(0xFFFDFCF4),
              ),
            ),
            Text(
              'GLOBAL APP OWNER & ADMIN CONTROL',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB39037),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2D3748), height: 1),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Property',
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Color(0xFFB39037),
              size: 24,
            ),
            onPressed: () => CategorySelectionModal.show(context),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFFFDFCF4),
              size: 22,
            ),
            onPressed: _loadAllProperties,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131922),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2D3748)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          color: Color(0xFFFDFCF4),
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Search by title, owner ID, locality, category...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _searchQuery = ''),
                        child: const Icon(
                          Icons.clear_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Status Filter Tabs
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: statusTabs.length,
                itemBuilder: (context, index) {
                  final tab = statusTabs[index];
                  final isSelected = _selectedStatusFilter == tab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStatusFilter = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFB39037)
                            : const Color(0xFF131922),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFB39037)
                              : const Color(0xFF2D3748),
                        ),
                      ),
                      child: Text(
                        tab.replaceAll('_', ' '),
                        style: TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF0A0D11)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFF2D3748)),

            // Property List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB39037),
                      ),
                    )
                  : _filteredProperties.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: const Color(0xFFB39037),
                      backgroundColor: const Color(0xFF131922),
                      onRefresh: _loadAllProperties,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredProperties.length,
                        itemBuilder: (context, index) {
                          final property = _filteredProperties[index];
                          return _buildAdminPropertyCard(property);
                        },
                      ),
                    ),
            ),
          ],
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF131922),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 44,
                color: Color(0xFFB39037),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Properties Found',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFDFCF4),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No listings match the current filters.',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPropertyCard(PropertyEntity property) {
    final isOnHold = property.status == ListingStatus.paused;
    final isLive =
        property.status == ListingStatus.published ||
        property.status == ListingStatus.active ||
        property.status == ListingStatus.approved;
    final isArchived = property.status == ListingStatus.archived;
    final isSoldOrRented =
        property.status == ListingStatus.sold ||
        property.status == ListingStatus.rented;

    final coverMedia =
        property.mediaList.where((m) => m.isCover).firstOrNull ??
        property.mediaList.firstOrNull;

    final purpose = property.features['purpose'] ?? 'FOR SALE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnHold
              ? Colors.amber.withValues(alpha: 0.4)
              : isSoldOrRented
              ? Colors.purple.withValues(alpha: 0.4)
              : const Color(0xFF2D3748),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Image thumbnail, Title, Price, Status Badge
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 75,
                    height: 75,
                    color: const Color(0xFF1B2330),
                    child: coverMedia != null && coverMedia.mediaUrl.isNotEmpty
                        ? Image.network(
                            coverMedia.mediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.apartment_rounded,
                              size: 32,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        : const Icon(
                            Icons.apartment_rounded,
                            size: 32,
                            color: Color(0xFF94A3B8),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              property.title,
                              style: const TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFDFCF4),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                property.status,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(property.status),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              property.status.name.toUpperCase(),
                              style: TextStyle(
                                fontFamily: AppDesignSystem.fontFamily,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _getStatusColor(property.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'â‚¹${_formatPrice(property.price)} â€¢ ${property.category.name} â€¢ ${purpose.toString().toUpperCase()}',
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB39037),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Owner ID: ${property.ownerId.length > 16 ? '${property.ownerId.substring(0, 16)}...' : property.ownerId}',
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // â”€â”€â”€ MODERATION PANEL (Pending / Submitted / Under Review) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          // Show prominently when property awaits admin decision
          if (property.status == ListingStatus.submitted ||
              property.status == ListingStatus.pendingVerification ||
              property.status == ListingStatus.underReview ||
              property.status == ListingStatus.changesRequested) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1000),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD97706).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.pending_actions_rounded,
                        size: 14,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        property.status == ListingStatus.changesRequested
                            ? 'CHANGES REQUESTED â€” Awaiting Owner Edit'
                            : 'PENDING MODERATION â€” Awaiting Admin Decision',
                        style: const TextStyle(
                          fontFamily: AppDesignSystem.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _updateStatus(property, ListingStatus.published),
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Approve & Publish',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRequestChangesDialog(property),
                          icon: const Icon(
                            Icons.edit_note_rounded,
                            size: 14,
                            color: Color(0xFFFBBF24),
                          ),
                          label: const Text(
                            'Request Changes',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFFBBF24),
                              width: 0.8,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _updateStatus(property, ListingStatus.paused),
                          icon: const Icon(
                            Icons.pause_circle_outline_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          label: const Text(
                            'Put On Hold',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFF59E0B),
                              width: 0.8,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _updateStatus(property, ListingStatus.rejected),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            size: 14,
                            color: Color(0xFFEF4444),
                          ),
                          label: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 0.8,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 1, color: Color(0xFF2D3748)),

          // Admin Global Actions Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // View
                _buildActionChip(
                  label: 'View',
                  icon: Icons.visibility_outlined,
                  color: const Color(0xFFFDFCF4),
                  onTap: () => context.push('/property/${property.id}'),
                ),

                // Hold / Resume Toggle
                if (isLive)
                  _buildActionChip(
                    label: 'Hold',
                    icon: Icons.pause_circle_outline_rounded,
                    color: Colors.amber.shade400,
                    onTap: () => _updateStatus(property, ListingStatus.paused),
                  )
                else if (isOnHold)
                  _buildActionChip(
                    label: 'Resume',
                    icon: Icons.play_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () =>
                        _updateStatus(property, ListingStatus.published),
                  ),

                // Publish / Unpublish Toggle
                if (!isLive && !isArchived)
                  _buildActionChip(
                    label: 'Publish',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () =>
                        _updateStatus(property, ListingStatus.published),
                  ),

                if (isLive)
                  _buildActionChip(
                    label: 'Unpublish',
                    icon: Icons.archive_outlined,
                    color: const Color(0xFF94A3B8),
                    onTap: () =>
                        _updateStatus(property, ListingStatus.archived),
                  ),

                // Status Management Popup Menu
                PopupMenuButton<ListingStatus>(
                  tooltip: 'Change Status',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2330),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFB39037),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            fontFamily: AppDesignSystem.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB39037),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 16,
                          color: Color(0xFFB39037),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (status) => _updateStatus(property, status),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ListingStatus.published,
                      child: Text('Mark as Published / Active'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.paused,
                      child: Text('Mark on Hold / Paused'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.sold,
                      child: Text('Mark as Sold'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.rented,
                      child: Text('Mark as Rented'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.underReview,
                      child: Text('Mark as Under Review'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.rejected,
                      child: Text('Mark as Rejected'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.disputed,
                      child: Text('Mark as Disputed'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.draft,
                      child: Text('Restore to Draft'),
                    ),
                    const PopupMenuItem(
                      value: ListingStatus.archived,
                      child: Text('Unpublish / Archive'),
                    ),
                  ],
                ),

                // Delete Button
                _buildActionChip(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: () => _confirmDelete(property),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2330),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestChangesDialog(PropertyEntity property) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2D3748)),
        ),
        title: const Text(
          'Request Changes from Owner',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFDFCF4),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a note for the property owner explaining what needs to be changed:',
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 4,
              style: const TextStyle(
                color: Color(0xFFFDFCF4),
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g. Please add better photos, update the price, or fix the location details.',
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFF1B2330),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2D3748)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2D3748)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFB39037)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Update status to changesRequested and store note
              await _updateStatusWithNote(
                property,
                ListingStatus.changesRequested,
                noteController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBBF24),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Send Request',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatusWithNote(
    PropertyEntity property,
    ListingStatus newStatus,
    String note,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'admin_global';
    final userRole = AuthSessionStorageHelper.getParsedUserRole();

    final repo = ref.read(propertyRepositoryProvider);

    // First update the status
    final result = await repo.updatePropertyStatus(
      propertyId: property.id,
      newStatus: newStatus,
      authenticatedUserId: userId,
      userRole: userRole.isAdminOrFounder ? userRole : UserRole.founder,
    );

    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                note.isNotEmpty
                    ? 'Status updated to ${newStatus.humanLabel}. Owner will be notified.'
                    : 'Status updated to ${newStatus.humanLabel}.',
              ),
              backgroundColor: const Color(0xFFFBBF24),
            ),
          );
          _loadAllProperties();
        },
      );
    }
  }

  Future<void> _updateStatus(
    PropertyEntity property,
    ListingStatus newStatus,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'admin_global';
    final userRole = AuthSessionStorageHelper.getParsedUserRole();

    final repo = ref.read(propertyRepositoryProvider);
    final result = await repo.updatePropertyStatus(
      propertyId: property.id,
      newStatus: newStatus,
      authenticatedUserId: userId,
      userRole: userRole.isAdminOrFounder ? userRole : UserRole.founder,
    );

    if (mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status update failed: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Status updated to ${newStatus.name.toUpperCase()}',
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          _loadAllProperties();
        },
      );
    }
  }

  void _confirmDelete(PropertyEntity property) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2D3748)),
        ),
        title: const Text(
          'Delete Property (Admin)',
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFDFCF4),
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${property.title}"? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: 13,
            color: Color(0xFF94A3B8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = FirebaseAuth.instance.currentUser;
              final userId = user?.uid ?? 'admin_global';
              final userRole = AuthSessionStorageHelper.getParsedUserRole();

              final repo = ref.read(propertyRepositoryProvider);
              final result = await repo.deleteProperty(
                property.id,
                authenticatedUserId: userId,
                userRole: userRole.isAdminOrFounder
                    ? userRole
                    : UserRole.founder,
              );

              if (context.mounted) {
                result.fold(
                  (failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Delete failed: ${failure.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Property permanently deleted.'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                    _loadAllProperties();
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete Permanently',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ListingStatus status) {
    return switch (status) {
      ListingStatus.draft => Colors.grey,
      ListingStatus.submitted ||
      ListingStatus.underReview ||
      ListingStatus.pendingVerification => Colors.orange,
      ListingStatus.changesRequested => Colors.amber,
      ListingStatus.published ||
      ListingStatus.approved ||
      ListingStatus.active => const Color(0xFF10B981),
      ListingStatus.paused => Colors.amber.shade900,
      ListingStatus.rejected ||
      ListingStatus.disputed => const Color(0xFFEF4444),
      ListingStatus.sold ||
      ListingStatus.rented ||
      ListingStatus.leased => Colors.purple,
      ListingStatus.archived => const Color(0xFF64748B),
    };
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} Lakh';
    }
    return price.toStringAsFixed(0);
  }
}
