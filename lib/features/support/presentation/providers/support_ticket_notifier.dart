import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/support_entities.dart';
import '../../domain/repositories/support_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

sealed class SupportTicketState extends Equatable {
  const SupportTicketState();
  @override
  List<Object?> get props => [];
}

class SupportTicketInitial extends SupportTicketState {
  const SupportTicketInitial();
}

class SupportTicketSubmitting extends SupportTicketState {
  const SupportTicketSubmitting();
}

class SupportTicketSubmitted extends SupportTicketState {
  final SupportTicketEntity ticket;
  const SupportTicketSubmitted(this.ticket);
  @override
  List<Object?> get props => [ticket];
}

class SupportTicketListLoaded extends SupportTicketState {
  final List<SupportTicketEntity> tickets;
  const SupportTicketListLoaded(this.tickets);
  @override
  List<Object?> get props => [tickets];
}

class SupportTicketError extends SupportTicketState {
  final String message;
  const SupportTicketError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final supportTicketNotifierProvider =
    NotifierProvider<SupportTicketNotifier, SupportTicketState>(SupportTicketNotifier.new);

class SupportTicketNotifier extends Notifier<SupportTicketState> {
  late final SupportRepository _repository;

  @override
  SupportTicketState build() {
    _repository = getIt<SupportRepository>();
    return const SupportTicketInitial();
  }

  Future<void> submitTicket({
    required String userId,
    required SupportCategory category,
    required String subject,
    required String message,
  }) async {
    state = const SupportTicketSubmitting();
    final ticket = SupportTicketEntity(
      id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      category: category,
      subject: subject,
      message: message,
      createdAt: DateTime.now(),
    );
    final result = await _repository.submitSupportTicket(ticket);
    result.fold(
      (failure) => state = SupportTicketError(failure.message),
      (submitted) => state = SupportTicketSubmitted(submitted),
    );
  }

  Future<void> loadMyTickets(String userId) async {
    state = const SupportTicketSubmitting(); // reuse loading state
    final result = await _repository.getMyTickets(userId);
    result.fold(
      (failure) => state = SupportTicketError(failure.message),
      (tickets) => state = SupportTicketListLoaded(tickets),
    );
  }

  void reset() => state = const SupportTicketInitial();
}
