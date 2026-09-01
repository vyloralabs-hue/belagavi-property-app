import 'package:equatable/equatable.dart';

enum TeamType { brokerAgency, builderOrganization }

enum TeamRole { owner, manager, agent, viewer }

class TeamEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final TeamType type;
  final int maxMembers;
  final DateTime createdAt;

  const TeamEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    this.maxMembers = 5,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, ownerId, name, type, maxMembers, createdAt];
}

class TeamMemberEntity extends Equatable {
  final String id;
  final String teamId;
  final String userId;
  final String memberName;
  final String memberPhone;
  final TeamRole role;
  final List<String> grantedPermissions;
  final DateTime joinedAt;

  const TeamMemberEntity({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.memberName,
    required this.memberPhone,
    this.role = TeamRole.agent,
    this.grantedPermissions = const [],
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        teamId,
        userId,
        memberName,
        memberPhone,
        role,
        grantedPermissions,
        joinedAt,
      ];
}

class SecurityLogEntity extends Equatable {
  final String id;
  final String userId;
  final String eventType; // 'login', 'mfa_verified', 'password_change', 'role_switch'
  final String ipAddress;
  final String userAgent;
  final DateTime timestamp;

  const SecurityLogEntity({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.ipAddress,
    required this.userAgent,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, eventType, ipAddress, userAgent, timestamp];
}
