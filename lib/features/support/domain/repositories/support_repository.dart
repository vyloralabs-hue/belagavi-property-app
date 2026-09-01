import '../../../../core/utils/typedefs.dart';
import '../entities/support_entities.dart';

abstract class SupportRepository {
  /// Fetch all FAQs (optionally filtered by category)
  FutureEither<List<FAQEntity>> getSupportFAQs();

  /// Submit a new support ticket
  FutureEither<SupportTicketEntity> submitSupportTicket(SupportTicketEntity ticket);

  /// Fetch all tickets for a given user
  FutureEither<List<SupportTicketEntity>> getMyTickets(String userId);

  /// Book a consultation appointment
  FutureEither<AppointmentEntity> bookAppointment(AppointmentEntity appointment);

  /// Fetch all available document assistance services
  FutureEither<List<DocumentServiceEntity>> getDocumentServices();
}
