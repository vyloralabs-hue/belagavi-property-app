import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bootstrap/bootstrap.dart';
import '../../domain/entities/support_entities.dart';
import '../../domain/repositories/support_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

sealed class SupportFAQState extends Equatable {
  const SupportFAQState();
  @override
  List<Object?> get props => [];
}

class SupportFAQInitial extends SupportFAQState {
  const SupportFAQInitial();
}

class SupportFAQLoading extends SupportFAQState {
  const SupportFAQLoading();
}

class SupportFAQLoaded extends SupportFAQState {
  final List<FAQEntity> allFAQs;
  final List<FAQEntity> filteredFAQs;
  final String selectedCategory;
  final String searchQuery;

  const SupportFAQLoaded({
    required this.allFAQs,
    required this.filteredFAQs,
    this.selectedCategory = 'all',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allFAQs, filteredFAQs, selectedCategory, searchQuery];
}

class SupportFAQError extends SupportFAQState {
  final String message;
  const SupportFAQError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final supportFAQNotifierProvider =
    NotifierProvider<SupportFAQNotifier, SupportFAQState>(SupportFAQNotifier.new);

class SupportFAQNotifier extends Notifier<SupportFAQState> {
  late final SupportRepository _repository;

  @override
  SupportFAQState build() {
    _repository = getIt<SupportRepository>();
    return const SupportFAQInitial();
  }

  Future<void> loadFAQs() async {
    state = const SupportFAQLoading();
    final result = await _repository.getSupportFAQs();
    result.fold(
      (failure) => state = SupportFAQError(failure.message),
      (faqs) => state = SupportFAQLoaded(allFAQs: faqs, filteredFAQs: faqs),
    );
  }

  void filterByCategory(String category) {
    final current = state;
    if (current is! SupportFAQLoaded) return;
    final filtered = category == 'all'
        ? current.allFAQs
        : current.allFAQs.where((f) => f.category == category).toList();
    state = SupportFAQLoaded(
      allFAQs: current.allFAQs,
      filteredFAQs: _applySearch(filtered, current.searchQuery),
      selectedCategory: category,
      searchQuery: current.searchQuery,
    );
  }

  void search(String query) {
    final current = state;
    if (current is! SupportFAQLoaded) return;
    final base = current.selectedCategory == 'all'
        ? current.allFAQs
        : current.allFAQs.where((f) => f.category == current.selectedCategory).toList();
    state = SupportFAQLoaded(
      allFAQs: current.allFAQs,
      filteredFAQs: _applySearch(base, query),
      selectedCategory: current.selectedCategory,
      searchQuery: query,
    );
  }

  List<FAQEntity> _applySearch(List<FAQEntity> faqs, String query) {
    if (query.trim().isEmpty) return faqs;
    final q = query.toLowerCase();
    return faqs
        .where((f) => f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q))
        .toList();
  }
}
