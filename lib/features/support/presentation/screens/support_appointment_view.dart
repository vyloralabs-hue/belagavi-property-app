import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation_ui/theme/app_design_system.dart';
import '../../domain/entities/support_entities.dart';
import '../providers/appointment_notifier.dart';
import '../widgets/support_ticket_status_badge.dart';

/// Premium Appointment Booking Screen
class SupportAppointmentView extends ConsumerStatefulWidget {
  const SupportAppointmentView({super.key});

  @override
  ConsumerState<SupportAppointmentView> createState() =>
      _SupportAppointmentViewState();
}

class _SupportAppointmentViewState
    extends ConsumerState<SupportAppointmentView> {
  AppointmentType _selectedType = AppointmentType.propertyConsultation;
  int _selectedDayIndex = 0;
  int _selectedSlotIndex = -1;
  final _notesController = TextEditingController();

  static const _typeLabels = {
    AppointmentType.propertyConsultation: 'Property Consultation',
    AppointmentType.documentationReview: 'Documentation Review',
    AppointmentType.legalGuidance: 'Legal Guidance',
    AppointmentType.siteVisit: 'Site Visit',
  };

  static const _typeIcons = {
    AppointmentType.propertyConsultation: Icons.home_work_rounded,
    AppointmentType.documentationReview: Icons.description_rounded,
    AppointmentType.legalGuidance: Icons.gavel_rounded,
    AppointmentType.siteVisit: Icons.map_rounded,
  };

  static const _slots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
  ];

  List<DateTime> get _availableDays {
    final now = DateTime.now();
    return List.generate(
      7,
      (i) => now.add(Duration(days: i + 1)),
    ).where((d) => d.weekday != DateTime.sunday).toList();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apptState = ref.watch(appointmentNotifierProvider);

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Book a Consultation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppDesignSystem.textPrimary,
            size: 20,
          ),
        ),
      ),
      body: switch (apptState) {
        AppointmentBooked(appointment: final appt) => _buildSuccessState(
          context,
          appt,
        ),
        _ => _buildBookingForm(context, apptState),
      },
    );
  }

  Widget _buildBookingForm(BuildContext context, AppointmentState apptState) {
    final isLoading = apptState is AppointmentBooking;
    final days = _availableDays;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _buildStepLabel('1', 'Select Consultation Type'),
        const SizedBox(height: 12),
        ..._typeLabels.entries.map((e) {
          final isSelected = _selectedType == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEFF6FF)
                    : AppDesignSystem.cardWhite,
                borderRadius: AppDesignSystem.borderRadiusL,
                border: Border.all(
                  color: isSelected
                      ? AppDesignSystem.primaryNavy
                      : AppDesignSystem.borderSubtle,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: AppDesignSystem.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppDesignSystem.primaryNavy
                          : const Color(0xFFF1F5F9),
                      borderRadius: AppDesignSystem.borderRadiusM,
                    ),
                    child: Icon(
                      _typeIcons[e.key],
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : AppDesignSystem.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    e.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? AppDesignSystem.primaryNavy
                          : AppDesignSystem.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppDesignSystem.primaryNavy,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        _buildStepLabel('2', 'Pick a Date'),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, index) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final day = days[i];
              final isSelected = _selectedDayIndex == i;
              final dayNames = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDayIndex = i;
                  _selectedSlotIndex = -1;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppDesignSystem.primaryNavy
                        : Colors.white,
                    borderRadius: AppDesignSystem.borderRadiusL,
                    border: Border.all(
                      color: isSelected
                          ? AppDesignSystem.primaryNavy
                          : AppDesignSystem.borderSubtle,
                    ),
                    boxShadow: isSelected ? AppDesignSystem.softShadow : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[day.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white70
                              : AppDesignSystem.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppDesignSystem.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildStepLabel('3', 'Select Time Slot'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_slots.length, (i) {
            final isSelected = _selectedSlotIndex == i;
            return AppointmentSlotChip(
              label: _slots[i],
              isSelected: isSelected,
              onTap: () => setState(() => _selectedSlotIndex = i),
            );
          }),
        ),
        const SizedBox(height: 20),
        _buildStepLabel('4', 'Add Notes (Optional)'),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe your property or query briefly…',
            hintStyle: TextStyle(
              color: AppDesignSystem.textSecondary,
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: AppDesignSystem.borderRadiusL,
              borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDesignSystem.borderRadiusL,
              borderSide: BorderSide(color: AppDesignSystem.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDesignSystem.borderRadiusL,
              borderSide: BorderSide(
                color: AppDesignSystem.primaryNavy,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (isLoading || _selectedSlotIndex < 0)
                ? null
                : () {
                    final day = days[_selectedDayIndex];
                    final parts = _slots[_selectedSlotIndex].split(':');
                    var hour = int.parse(parts[0]);
                    final isPM = parts[1].contains('PM') && hour != 12;
                    if (isPM) hour += 12;
                    final slot = DateTime(day.year, day.month, day.day, hour);
                    ref
                        .read(appointmentNotifierProvider.notifier)
                        .bookAppointment(
                          userId: 'usr_current',
                          type: _selectedType,
                          slotDateTime: slot,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.primaryNavy,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: AppDesignSystem.borderRadiusL,
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _selectedSlotIndex < 0
                        ? 'Select a Time Slot to Continue'
                        : 'Confirm Booking — ${_slots[_selectedSlotIndex]}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLabel(String step, String label) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppDesignSystem.primaryNavy,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, AppointmentEntity appt) {
    final typeLabels = _typeLabels[appt.type] ?? 'Consultation';
    final formattedDate =
        '${appt.slotDateTime.day}/${appt.slotDateTime.month}/${appt.slotDateTime.year}';
    final formattedTime =
        '${appt.slotDateTime.hour > 12 ? appt.slotDateTime.hour - 12 : appt.slotDateTime.hour}:00 ${appt.slotDateTime.hour >= 12 ? 'PM' : 'AM'}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 44,
                color: AppDesignSystem.accentEmerald,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Appointment Booked!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppDesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$typeLabels\n$formattedDate at $formattedTime',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppDesignSystem.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our expert will call you at the scheduled time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppDesignSystem.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(appointmentNotifierProvider.notifier).reset();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryNavy,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDesignSystem.borderRadiusL,
                  ),
                ),
                child: const Text(
                  'Back to Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
