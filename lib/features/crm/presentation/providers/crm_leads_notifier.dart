import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/crm_entities.dart';
import '../../domain/repositories/crm_repository.dart';

sealed class CRMLeadsState extends Equatable {
  const CRMLeadsState();

  @override
  List<Object?> get props => [];
}

class CRMLeadsInitial extends CRMLeadsState {
  const CRMLeadsInitial();
}

class CRMLeadsLoading extends CRMLeadsState {
  const CRMLeadsLoading();
}

class CRMLeadsLoaded extends CRMLeadsState {
  final List<CRMLeadEntity> leads;

  const CRMLeadsLoaded(this.leads);

  List<CRMLeadEntity> getLeadsByStage(KanbanStageEnum stage) {
    return leads.where((l) => l.stage == stage).toList();
  }

  @override
  List<Object?> get props => [leads];
}

class CRMLeadsError extends CRMLeadsState {
  final String message;

  const CRMLeadsError(this.message);

  @override
  List<Object?> get props => [message];
}

final crmLeadsNotifierProvider =
    NotifierProvider<CRMLeadsNotifier, CRMLeadsState>(CRMLeadsNotifier.new);

class CRMLeadsNotifier extends Notifier<CRMLeadsState> {
  late final CRMRepository _repository;

  @override
  CRMLeadsState build() {
    _repository = getIt<CRMRepository>();
    return const CRMLeadsInitial();
  }

  Future<void> fetchLeads(String userId) async {
    state = const CRMLeadsLoading();
    final result = await _repository.getLeadsForUser(userId);
    result.fold(
      (failure) => state = CRMLeadsError(failure.message),
      (leads) => state = CRMLeadsLoaded(leads),
    );
  }

  Future<void> updateStage({
    required String leadId,
    required KanbanStageEnum newStage,
    required String userId,
  }) async {
    final result = await _repository.updateLeadStage(leadId: leadId, newStage: newStage);
    result.fold(
      (failure) => state = CRMLeadsError(failure.message),
      (_) => fetchLeads(userId),
    );
  }
}
