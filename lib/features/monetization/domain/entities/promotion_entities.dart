import 'package:equatable/equatable.dart';

enum PromotionType {
  featured,
  boost,
  topPlacement,
}

extension PromotionTypeExtension on PromotionType {
  String get displayName => switch (this) {
        PromotionType.featured => 'Featured Listing (Master Gold)',
        PromotionType.boost => 'Search Boost (High Visibility)',
        PromotionType.topPlacement => 'Top City Placement',
      };

  int get defaultPriority => switch (this) {
        PromotionType.topPlacement => 3,
        PromotionType.featured => 2,
        PromotionType.boost => 1,
      };

  static PromotionType fromString(String? val) {
    if (val == null) return PromotionType.featured;
    return PromotionType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == val.toLowerCase() ||
          e.name.toLowerCase() == val.replaceAll('_', '').toLowerCase(),
      orElse: () => PromotionType.featured,
    );
  }
}

enum PromotionStatus {
  pending,
  active,
  paused,
  expired,
  cancelled,
  rejected,
}

extension PromotionStatusExtension on PromotionStatus {
  String get displayName => switch (this) {
        PromotionStatus.pending => 'Pending Activation',
        PromotionStatus.active => 'Active Promotion',
        PromotionStatus.paused => 'Paused',
        PromotionStatus.expired => 'Expired',
        PromotionStatus.cancelled => 'Cancelled',
        PromotionStatus.rejected => 'Rejected by Admin',
      };

  static PromotionStatus fromString(String? val) {
    if (val == null) return PromotionStatus.active;
    return PromotionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PromotionStatus.active,
    );
  }
}

class PropertyPromotionEntity extends Equatable {
  final String id;
  final String propertyId;
  final String ownerId;
  final PromotionType promotionType;
  final int priorityLevel;
  final PromotionStatus status;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyPromotionEntity({
    required this.id,
    required this.propertyId,
    required this.ownerId,
    required this.promotionType,
    this.priorityLevel = 1,
    this.status = PromotionStatus.active,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return status == PromotionStatus.active && !now.isBefore(startAt) && now.isBefore(endAt);
  }

  PropertyPromotionEntity copyWith({
    PromotionStatus? status,
    DateTime? endAt,
    DateTime? updatedAt,
  }) {
    return PropertyPromotionEntity(
      id: id,
      propertyId: propertyId,
      ownerId: ownerId,
      promotionType: promotionType,
      priorityLevel: priorityLevel,
      status: status ?? this.status,
      startAt: startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'owner_id': ownerId,
        'promotion_type': promotionType.name.toUpperCase(),
        'priority_level': priorityLevel,
        'status': status.name.toUpperCase(),
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PropertyPromotionEntity.fromJson(Map<String, dynamic> json) {
    return PropertyPromotionEntity(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      ownerId: json['owner_id'] as String,
      promotionType: PromotionTypeExtension.fromString(json['promotion_type'] as String?),
      priorityLevel: (json['priority_level'] ?? 1) as int,
      status: PromotionStatusExtension.fromString(json['status'] as String?),
      startAt: DateTime.parse((json['start_at'] ?? DateTime.now().toIso8601String()) as String),
      endAt: DateTime.parse((json['end_at'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()) as String),
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        ownerId,
        promotionType,
        priorityLevel,
        status,
        startAt,
        endAt,
        createdAt,
        updatedAt,
      ];
}

class UserEntitlementEntity extends Equatable {
  final String id;
  final String userId;
  final String entitlementKey;
  final int totalQuota;
  final int usedQuota;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntitlementEntity({
    required this.id,
    required this.userId,
    required this.entitlementKey,
    this.totalQuota = 0,
    this.usedQuota = 0,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasRemainingQuota => (totalQuota - usedQuota) > 0;
  int get remainingQuota => (totalQuota - usedQuota).clamp(0, totalQuota);

  UserEntitlementEntity copyWith({
    int? totalQuota,
    int? usedQuota,
    DateTime? expiresAt,
    DateTime? updatedAt,
  }) {
    return UserEntitlementEntity(
      id: id,
      userId: userId,
      entitlementKey: entitlementKey,
      totalQuota: totalQuota ?? this.totalQuota,
      usedQuota: usedQuota ?? this.usedQuota,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entitlement_key': entitlementKey,
        'total_quota': totalQuota,
        'used_quota': usedQuota,
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserEntitlementEntity.fromJson(Map<String, dynamic> json) {
    return UserEntitlementEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      entitlementKey: json['entitlement_key'] as String,
      totalQuota: (json['total_quota'] ?? 0) as int,
      usedQuota: (json['used_quota'] ?? 0) as int,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        entitlementKey,
        totalQuota,
        usedQuota,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}

class PromotionPackageConfigEntity extends Equatable {
  final String id;
  final PromotionType type;
  final String title;
  final String description;
  final double serverPriceInr;
  final int durationDays;
  final int priorityLevel;

  const PromotionPackageConfigEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.serverPriceInr,
    required this.durationDays,
    required this.priorityLevel,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        serverPriceInr,
        durationDays,
        priorityLevel,
      ];
}
