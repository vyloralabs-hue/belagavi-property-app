import 'package:equatable/equatable.dart';

enum UnlockType {
  payPerProperty,
  credit,
  membership,
}

enum UnlockStatus {
  active,
  expired,
  revoked,
}

class PropertyUnlockEntity extends Equatable {
  final String id;
  final String propertyId;
  final String userId;
  final UnlockType unlockType;
  final double amount;
  final int creditsUsed;
  final DateTime unlockedAt;
  final DateTime? expiresAt;
  final UnlockStatus status;
  final DateTime createdAt;

  const PropertyUnlockEntity({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.unlockType,
    this.amount = 0.0,
    this.creditsUsed = 0,
    required this.unlockedAt,
    this.expiresAt,
    this.status = UnlockStatus.active,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        userId,
        unlockType,
        amount,
        creditsUsed,
        unlockedAt,
        expiresAt,
        status,
        createdAt,
      ];
}
