import '../../domain/entities/team_entities.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.type,
    super.maxMembers = 5,
    required super.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: TeamType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TeamType.brokerAgency,
      ),
      maxMembers: json['max_members'] as int? ?? 5,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'name': name,
        'type': type.name,
        'max_members': maxMembers,
        'created_at': createdAt.toIso8601String(),
      };
}

class TeamMemberModel extends TeamMemberEntity {
  const TeamMemberModel({
    required super.id,
    required super.teamId,
    required super.userId,
    required super.memberName,
    required super.memberPhone,
    super.role = TeamRole.agent,
    super.grantedPermissions = const [],
    required super.joinedAt,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as String? ?? '',
      teamId: json['team_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      memberName: json['member_name'] as String? ?? '',
      memberPhone: json['member_phone'] as String? ?? '',
      role: TeamRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => TeamRole.agent,
      ),
      grantedPermissions: (json['granted_permissions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'team_id': teamId,
        'user_id': userId,
        'member_name': memberName,
        'member_phone': memberPhone,
        'role': role.name,
        'granted_permissions': grantedPermissions,
        'joined_at': joinedAt.toIso8601String(),
      };
}

class SecurityLogModel extends SecurityLogEntity {
  const SecurityLogModel({
    required super.id,
    required super.userId,
    required super.eventType,
    required super.ipAddress,
    required super.userAgent,
    required super.timestamp,
  });

  factory SecurityLogModel.fromJson(Map<String, dynamic> json) {
    return SecurityLogModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      eventType: json['event_type'] as String? ?? 'login',
      ipAddress: json['ip_address'] as String? ?? '0.0.0.0',
      userAgent: json['user_agent'] as String? ?? 'Unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'event_type': eventType,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'timestamp': timestamp.toIso8601String(),
      };
}
