import '../../domain/entities/property_entities.dart';

class PropertyUnlockModel extends PropertyUnlockEntity {
  const PropertyUnlockModel({
    required super.id,
    required super.propertyId,
    required super.userId,
    required super.unlockType,
    super.amount = 0.0,
    super.creditsUsed = 0,
    required super.unlockedAt,
    super.expiresAt,
    super.status = UnlockStatus.active,
    required super.createdAt,
  });

  factory PropertyUnlockModel.fromJson(Map<String, dynamic> json) {
    return PropertyUnlockModel(
      id: json['id'] as String? ?? '',
      propertyId: json['property_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      unlockType: UnlockType.values.firstWhere(
        (e) => e.name == json['unlock_type'],
        orElse: () => UnlockType.payPerProperty,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      creditsUsed: json['credits_used'] as int? ?? 0,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      status: UnlockStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UnlockStatus.active,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'user_id': userId,
        'unlock_type': unlockType.name,
        'amount': amount,
        'credits_used': creditsUsed,
        'unlocked_at': unlockedAt.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'status': status.name,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };
}
