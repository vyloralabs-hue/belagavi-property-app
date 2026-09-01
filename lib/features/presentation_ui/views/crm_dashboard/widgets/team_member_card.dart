import 'package:flutter/material.dart';
import '../../../theme/app_design_system.dart';

/// Premium team member card for broker/builder team management screen
class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final bool isActive;
  final int assignedLeads;
  final VoidCallback? onRemove;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.phone,
    this.isActive = true,
    this.assignedLeads = 0,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppDesignSystem.cardWhite,
        borderRadius: AppDesignSystem.borderRadiusL,
        boxShadow: AppDesignSystem.softShadow,
        border: Border.all(color: AppDesignSystem.borderSubtle),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'T',
                  style: const TextStyle(
                    color: AppDesignSystem.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppDesignSystem.accentEmerald
                        : const Color(0xFFDC2626),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  borderRadius: AppDesignSystem.borderRadiusPill,
                ),
                child: Text(
                  '$assignedLeads Leads',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppDesignSystem.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: AppDesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
