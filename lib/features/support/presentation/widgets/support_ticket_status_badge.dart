import 'package:flutter/material.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/support_entities.dart';

/// Premium ticket status badge pill
class SupportTicketStatusBadge extends StatelessWidget {
  final SupportTicketStatus status;

  const SupportTicketStatusBadge({super.key, required this.status});

  String get _label {
    switch (status) {
      case SupportTicketStatus.open:
        return 'Open';
      case SupportTicketStatus.inProgress:
        return 'In Progress';
      case SupportTicketStatus.resolved:
        return 'Resolved';
      case SupportTicketStatus.closed:
        return 'Closed';
    }
  }

  Color get _bg {
    switch (status) {
      case SupportTicketStatus.open:
        return const Color(0xFFEFF6FF);
      case SupportTicketStatus.inProgress:
        return const Color(0xFFFEF3C7);
      case SupportTicketStatus.resolved:
        return const Color(0xFFD1FAE5);
      case SupportTicketStatus.closed:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get _text {
    switch (status) {
      case SupportTicketStatus.open:
        return AppDesignSystem.primaryNavy;
      case SupportTicketStatus.inProgress:
        return const Color(0xFFD97706);
      case SupportTicketStatus.resolved:
        return AppDesignSystem.accentEmerald;
      case SupportTicketStatus.closed:
        return AppDesignSystem.textSecondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case SupportTicketStatus.open:
        return Icons.radio_button_unchecked_rounded;
      case SupportTicketStatus.inProgress:
        return Icons.pending_rounded;
      case SupportTicketStatus.resolved:
        return Icons.check_circle_rounded;
      case SupportTicketStatus.closed:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: _bg, borderRadius: AppDesignSystem.borderRadiusPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _text),
          const SizedBox(width: 4),
          Text(_label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _text)),
        ],
      ),
    );
  }
}

/// Premium appointment type chip selector
class AppointmentSlotChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppointmentSlotChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppDesignSystem.primaryNavy : Colors.white,
          borderRadius: AppDesignSystem.borderRadiusPill,
          border: Border.all(
            color: isSelected ? AppDesignSystem.primaryNavy : AppDesignSystem.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppDesignSystem.softShadow : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppDesignSystem.textSecondary,
          ),
        ),
      ),
    );
  }
}
