import 'package:equatable/equatable.dart';

class InternalNotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? propertyId;
  final bool isRead;
  final DateTime createdAt;

  const InternalNotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.propertyId,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, title, message, propertyId, isRead, createdAt];
}
