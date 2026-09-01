import '../../../../core/utils/typedefs.dart';
import '../entities/team_entities.dart';

abstract class TeamRepository {
  FutureEither<TeamEntity> createTeam({
    required String ownerId,
    required String name,
    required TeamType type,
  });

  FutureEither<List<TeamMemberEntity>> getTeamMembers(String teamId);

  FutureEither<TeamMemberEntity> inviteTeamMember({
    required String teamId,
    required String memberPhone,
    required String memberName,
    required TeamRole role,
  });

  FutureEither<void> removeTeamMember(String memberId);

  FutureEither<List<SecurityLogEntity>> getSecurityLogs(String userId);
}
