import 'package:injectable/injectable.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/team_entities.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_datasource.dart';

@LazySingleton(as: TeamRepository)
class TeamRepositoryImpl extends BaseRepository implements TeamRepository {
  final TeamRemoteDataSource _remoteDataSource;

  TeamRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<TeamEntity> createTeam({
    required String ownerId,
    required String name,
    required TeamType type,
  }) async {
    return safeCall(
      () => _remoteDataSource.createTeam(
        ownerId: ownerId,
        name: name,
        type: type,
      ),
    );
  }

  @override
  FutureEither<List<TeamMemberEntity>> getTeamMembers(String teamId) async {
    return safeCall(() => _remoteDataSource.fetchTeamMembers(teamId));
  }

  @override
  FutureEither<TeamMemberEntity> inviteTeamMember({
    required String teamId,
    required String memberPhone,
    required String memberName,
    required TeamRole role,
  }) async {
    return safeCall(
      () => _remoteDataSource.inviteTeamMember(
        teamId: teamId,
        memberPhone: memberPhone,
        memberName: memberName,
        role: role,
      ),
    );
  }

  @override
  FutureEither<void> removeTeamMember(String memberId) async {
    return safeCall(() => _remoteDataSource.removeTeamMember(memberId));
  }

  @override
  FutureEither<List<SecurityLogEntity>> getSecurityLogs(String userId) async {
    return safeCall(() => _remoteDataSource.fetchSecurityLogs(userId));
  }
}
