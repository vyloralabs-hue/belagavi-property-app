import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/utils/auth_session_storage_helper.dart';
import '../../theme/app_design_system.dart';

class RoleSelectionView extends ConsumerStatefulWidget {
  const RoleSelectionView({super.key});

  @override
  ConsumerState<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends ConsumerState<RoleSelectionView> {
  UserRoleEnum _selectedRole = UserRoleEnum.buyer;

  static const List<Map<String, dynamic>> _roles = [
    {
      'role': UserRoleEnum.buyer,
      'title': 'Property Buyer / Tenant',
      'subtitle': 'Search residential homes, plots, and rental properties.',
      'icon': Icons.home,
    },
    {
      'role': UserRoleEnum.seller,
      'title': 'Property Owner / Seller',
      'subtitle': 'List your flat, plot, or commercial property directly.',
      'icon': Icons.sell,
    },
    {
      'role': UserRoleEnum.broker,
      'title': 'Real Estate Broker',
      'subtitle': 'Manage multiple listings, leads & client Kanban pipelines.',
      'icon': Icons.business_center,
    },
    {
      'role': UserRoleEnum.builder,
      'title': 'Property Builder / Developer',
      'subtitle': 'Manage new housing projects, unit inventories & sales.',
      'icon': Icons.domain,
    },
    {
      'role': UserRoleEnum.builderTeamMember,
      'title': 'Builder Team Member',
      'subtitle': 'Access developer project sales dashboard as sales staff.',
      'icon': Icons.groups,
    },
    {
      'role': UserRoleEnum.brokerTeamMember,
      'title': 'Broker Agency Staff',
      'subtitle': 'Manage leads under agency broker supervisor.',
      'icon': Icons.badge,
    },
  ];

  void _confirmRole() async {
    ref.read(authNotifierProvider.notifier).switchRole(_selectedRole);
    await AuthSessionStorageHelper.setUserRole(_selectedRole.name);
    if (mounted) {
      context.go('/location-permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Select Your Account Role',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'How will you be using Belagavi Property?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final item = _roles[index];
                  final role = item['role'] as UserRoleEnum;
                  final isSelected = _selectedRole == role;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDesignSystem.borderRadiusM,
                      side: BorderSide(
                        color: isSelected
                            ? AppDesignSystem.primaryNavy
                            : AppDesignSystem.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppDesignSystem.primaryNavy
                              : const Color(0xFFF1F5F9),
                          borderRadius: AppDesignSystem.borderRadiusM,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : AppDesignSystem.primaryNavy,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item['subtitle'] as String,
                          style: const TextStyle(
                            color: AppDesignSystem.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppDesignSystem.primaryNavy
                            : AppDesignSystem.textSecondary,
                      ),
                      onTap: () => setState(() => _selectedRole = role),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignSystem.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDesignSystem.borderRadiusPill,
                    ),
                  ),
                  onPressed: _confirmRole,
                  child: const Text(
                    'Confirm & Access Platform',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
