import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/support_entities.dart';
import '../../domain/repositories/support_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

sealed class AppointmentState extends Equatable {
  const AppointmentState();
  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentBooking extends AppointmentState {
  const AppointmentBooking();
}

class AppointmentBooked extends AppointmentState {
  final AppointmentEntity appointment;
  const AppointmentBooked(this.appointment);
  @override
  List<Object?> get props => [appointment];
}

class AppointmentError extends AppointmentState {
  final String message;
  const AppointmentError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final appointmentNotifierProvider =
    NotifierProvider<AppointmentNotifier, AppointmentState>(AppointmentNotifier.new);

class AppointmentNotifier extends Notifier<AppointmentState> {
  late final SupportRepository _repository;

  @override
  AppointmentState build() {
    _repository = getIt<SupportRepository>();
    return const AppointmentInitial();
  }

  Future<void> bookAppointment({
    required String userId,
    required AppointmentType type,
    required DateTime slotDateTime,
    String? notes,
  }) async {
    state = const AppointmentBooking();
    final appointment = AppointmentEntity(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      slotDateTime: slotDateTime,
      status: AppointmentSlotStatus.booked,
      notes: notes,
      createdAt: DateTime.now(),
    );
    final result = await _repository.bookAppointment(appointment);
    result.fold(
      (failure) => state = AppointmentError(failure.message),
      (booked) => state = AppointmentBooked(booked),
    );
  }

  void reset() => state = const AppointmentInitial();
}
