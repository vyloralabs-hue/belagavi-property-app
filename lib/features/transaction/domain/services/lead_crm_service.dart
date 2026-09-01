import '../entities/lead_crm_entities.dart';

class LeadCRMService {
  /// Update stage of a lead
  static LeadCRMRecord updateStage(LeadCRMRecord lead, LeadStage newStage) {
    return lead.copyWith(
      stage: newStage,
      updatedAt: DateTime.now(),
    );
  }

  /// Add a private seller note (strictly isolated from buyer)
  static LeadCRMRecord addPrivateNote({
    required LeadCRMRecord lead,
    required String authorId,
    required String content,
  }) {
    if (content.trim().isEmpty) return lead;

    final newNote = SellerPrivateLeadNote(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      authorId: authorId,
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    final updatedNotes = List<SellerPrivateLeadNote>.from(lead.privateNotes)..add(newNote);

    return lead.copyWith(
      privateNotes: updatedNotes,
      updatedAt: DateTime.now(),
    );
  }

  /// Schedule a follow-up reminder
  static LeadCRMRecord scheduleFollowUp(LeadCRMRecord lead, DateTime followUpDate) {
    return lead.copyWith(
      followUpScheduledAt: followUpDate,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark lead as spam or block abusive buyer
  static LeadCRMRecord blockBuyer(LeadCRMRecord lead, {bool markSpam = true}) {
    return lead.copyWith(
      isBuyerBlocked: true,
      isMarkedSpam: markSpam,
      stage: LeadStage.lost,
      updatedAt: DateTime.now(),
    );
  }
}
