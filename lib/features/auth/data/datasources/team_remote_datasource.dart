import 'package:injectable/injectable.dart';
import '../../../../core/backend/base_remote_datasource.dart';
import '../../../../core/backend/supabase_service.dart';
import '../../domain/entities/team_entities.dart';
import '../models/team_models.dart';

abstract class TeamRemoteDataSource {
  Future<TeamModel> createTeam({
    required String ownerId,
    required String name,
    required TeamType type,
  });
  Future<List<TeamMemberModel>> fetchTeamMembers(String teamId);
  Future<TeamMemberModel> inviteTeamMember({
    required String teamId,
    required String memberPhone,
    required String memberName,
    required TeamRole role,
  });
  Future<void> removeTeamMember(String memberId);
  Future<List<SecurityLogModel>> fetchSecurityLogs(String userId);
}

@LazySingleton(as: TeamRemoteDataSource)
class TeamRemoteDataSourceImpl extends BaseRemoteDataSource implements TeamRemoteDataSource {
  final SupabaseService _supabaseService;

  TeamRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<TeamModel> createTeam({
    required String ownerId,
    required String name,
    required TeamType type,
  }) async {
    return safeQuery(() async {
      final team = TeamModel(
        id: 'team_${DateTime.now().millisecondsSinceEpoch}',
        ownerId: ownerId,
        name: name,
        type: type,
        createdAt: DateTime.now(),
      );

      if (!_supabaseService.isInitialized) return team;

      final response =
          await _supabaseService.from('teams').insert(team.toJson()).select().single();
      return TeamModel.fromJson(response);
    });
  }

  @override
  Future<List<TeamMemberModel>> fetchTeamMembers(String teamId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return const [];
      final response =
          await _supabaseService.from('team_members').select().eq('team_id', teamId);
      return (response as List).map((json) => TeamMemberModel.fromJson(json)).toList();
    });
  }

  @override
  Future<TeamMemberModel> inviteTeamMember({
    required String teamId,
    required String memberPhone,
    required String memberName,
    required TeamRole role,
  }) async {
    return safeQuery(() async {
      final member = TeamMemberModel(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        teamId: teamId,
        userId: 'usr_invited_${DateTime.now().millisecondsSinceEpoch}',
        memberName: memberName,
        memberPhone: memberPhone,
        role: role,
        joinedAt: DateTime.now(),
      );

      if (!_supabaseService.isInitialized) return member;

      final response = await _supabaseService
          .from('team_members')
          .insert(member.toJson())
          .select()
          .single();
      return TeamMemberModel.fromJson(response);
    });
  }

  @override
  Future<void> removeTeamMember(String memberId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return;
      await _supabaseService.from('team_members').delete().eq('id', memberId);
    });
  }

  @override
  Future<List<SecurityLogModel>> fetchSecurityLogs(String userId) async {
    return safeQuery(() async {
      if (!_supabaseService.isInitialized) return const [];
      final response =
          await _supabaseService.from('security_logs').select().eq('user_id', userId);
      return (response as List).map((json) => SecurityLogModel.fromJson(json)).toList();
    });
  }
}
