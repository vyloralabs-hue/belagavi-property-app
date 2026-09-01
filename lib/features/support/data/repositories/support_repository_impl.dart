import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/support_entities.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepositoryImpl extends BaseRepository implements SupportRepository {
  final SupportRemoteDataSource _dataSource;

  SupportRepositoryImpl(this._dataSource);

  @override
  FutureEither<List<FAQEntity>> getSupportFAQs() => safeCall(
        () => _dataSource.getSupportFAQs(),
      );

  @override
  FutureEither<SupportTicketEntity> submitSupportTicket(SupportTicketEntity ticket) => safeCall(
        () => _dataSource.submitSupportTicket(ticket),
      );

  @override
  FutureEither<List<SupportTicketEntity>> getMyTickets(String userId) => safeCall(
        () => _dataSource.getMyTickets(userId),
      );

  @override
  FutureEither<AppointmentEntity> bookAppointment(AppointmentEntity appointment) => safeCall(
        () => _dataSource.bookAppointment(appointment),
      );

  @override
  FutureEither<List<DocumentServiceEntity>> getDocumentServices() => safeCall(
        () => _dataSource.getDocumentServices(),
      );
}
