import '../models/models.dart';
import 'base_repository.dart';

/// Challenge Repository - Handles challenges and leaderboards
class ChallengeRepository extends BaseRepository {
  // ============================================
  // CHALLENGES
  // ============================================

  /// Get active challenges
  Future<Result<List<ChallengeModel>>> getActiveChallenges() async {
    try {
      final response = await client
          .from('challenges')
          .select()
          .eq('status', 'active')
          .order('is_featured', ascending: false)
          .order('start_date');

      final challenges = (response as List).map((json) {
        final challenge = ChallengeModel.fromJson(json);
        return challenge;
      }).toList();

      // Check if user has joined each challenge
      if (userId != null) {
        final userChallenges = await _getUserChallengeIds();
        return Result.success(challenges.map((c) {
          return c.copyWith(
            isJoined: userChallenges.contains(c.id),
          );
        }).toList());
      }

      return Result.success(challenges);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get featured challenges
  Future<Result<List<ChallengeModel>>> getFeaturedChallenges() async {
    try {
      final response = await client
          .from('challenges')
          .select()
          .eq('status', 'active')
          .eq('is_featured', true)
          .order('start_date');

      final challenges = (response as List)
          .map((json) => ChallengeModel.fromJson(json))
          .toList();

      return Result.success(challenges);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get challenge by ID
  Future<Result<ChallengeModel>> getChallenge(String challengeId) async {
    try {
      final response = await client
          .from('challenges')
          .select()
          .eq('id', challengeId)
          .single();

      var challenge = ChallengeModel.fromJson(response);

      // Get user's progress if authenticated
      if (userId != null) {
        final userChallengeResult = await getUserChallenge(challengeId);
        if (userChallengeResult.isSuccess && userChallengeResult.data != null) {
          challenge = challenge.copyWith(
            isJoined: true,
            userProgress: userChallengeResult.data!.currentProgress,
            userRank: userChallengeResult.data!.rank,
          );
        }
      }

      return Result.success(challenge);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get upcoming challenges
  Future<Result<List<ChallengeModel>>> getUpcomingChallenges() async {
    try {
      final response = await client
          .from('challenges')
          .select()
          .eq('status', 'upcoming')
          .order('start_date');

      final challenges = (response as List)
          .map((json) => ChallengeModel.fromJson(json))
          .toList();

      return Result.success(challenges);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // USER CHALLENGES
  // ============================================

  /// Join a challenge
  Future<Result<UserChallengeModel>> joinChallenge(String challengeId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      // Check if already joined
      final existing = await client
          .from('user_challenges')
          .select('id')
          .eq('user_id', userId!)
          .eq('challenge_id', challengeId)
          .maybeSingle();

      if (existing != null) {
        return Result.failure(
            RepositoryException(message: 'Already joined this challenge'));
      }

      final response = await client
          .from('user_challenges')
          .insert({
            'user_id': userId!,
            'challenge_id': challengeId,
            'current_progress': 0,
            'joined_at': DateTime.now().toIso8601String(),
            'last_updated': DateTime.now().toIso8601String(),
          })
          .select('*, challenges(*)')
          .single();

      return Result.success(UserChallengeModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Leave a challenge
  Future<Result<void>> leaveChallenge(String challengeId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('user_challenges')
          .delete()
          .eq('user_id', userId!)
          .eq('challenge_id', challengeId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's joined challenges
  Future<Result<List<UserChallengeModel>>> getMyActiveChallenges() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', userId!)
          .eq('is_completed', false)
          .order('joined_at', ascending: false);

      final challenges = (response as List)
          .map((json) => UserChallengeModel.fromJson(json))
          .toList();

      return Result.success(challenges);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's completed challenges
  Future<Result<List<UserChallengeModel>>> getMyCompletedChallenges() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', userId!)
          .eq('is_completed', true)
          .order('completed_at', ascending: false);

      final challenges = (response as List)
          .map((json) => UserChallengeModel.fromJson(json))
          .toList();

      return Result.success(challenges);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's progress for a specific challenge
  Future<Result<UserChallengeModel?>> getUserChallenge(
      String challengeId) async {
    try {
      if (userId == null) {
        return Result.success(null);
      }

      final response = await client
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', userId!)
          .eq('challenge_id', challengeId)
          .maybeSingle();

      if (response == null) {
        return Result.success(null);
      }

      return Result.success(UserChallengeModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update challenge progress for a specific user challenge
  Future<Result<void>> updateChallengeProgress(
      String challengeId, int newProgress) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('user_challenges')
          .update({
            'current_progress': newProgress,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId!)
          .eq('challenge_id', challengeId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Mark a challenge as completed
  Future<Result<void>> markChallengeCompleted(String challengeId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('user_challenges')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId!)
          .eq('challenge_id', challengeId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Helper to get user's joined challenge IDs
  Future<Set<String>> _getUserChallengeIds() async {
    if (userId == null) return {};

    try {
      final response = await client
          .from('user_challenges')
          .select('challenge_id')
          .eq('user_id', userId!);

      return (response as List)
          .map((json) => json['challenge_id'] as String)
          .toSet();
    } catch (e) {
      return {};
    }
  }

  // ============================================
  // LEADERBOARD
  // ============================================

  /// Get challenge leaderboard
  Future<Result<List<ChallengeLeaderboardEntry>>> getLeaderboard(
    String challengeId, {
    int limit = 50,
  }) async {
    try {
      final response = await executeFunction<List<dynamic>>(
        'get_challenge_leaderboard',
        params: {
          'p_challenge_id': challengeId,
          'p_limit': limit,
        },
      );

      final entries = response
          .map((json) =>
              ChallengeLeaderboardEntry.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(entries);
    } catch (e) {
      // Fallback to direct query
      return _getLeaderboardDirect(challengeId, limit: limit);
    }
  }

  Future<Result<List<ChallengeLeaderboardEntry>>> _getLeaderboardDirect(
    String challengeId, {
    int limit = 50,
  }) async {
    try {
      final challengeResult = await getChallenge(challengeId);
      if (!challengeResult.isSuccess) {
        return Result.failure(challengeResult.error!);
      }
      final targetValue = challengeResult.data!.targetValue;

      final response = await client
          .from('user_challenges')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('challenge_id', challengeId)
          .order('current_progress', ascending: false)
          .limit(limit);

      int rank = 0;
      final entries = (response as List).map((json) {
        rank++;
        final progress = json['current_progress'] as int;
        return ChallengeLeaderboardEntry(
          rank: rank,
          userId: json['user_id'] as String,
          fullName: json['users']?['full_name'] as String?,
          username: json['users']?['username'] as String?,
          avatarUrl: json['users']?['avatar_url'] as String?,
          progress: progress,
          progressPercentage:
              targetValue > 0 ? ((progress * 100) ~/ targetValue).clamp(0, 100) : 0,
        );
      }).toList();

      return Result.success(entries);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // PARTICIPANTS & STATS
  // ============================================

  /// Get participants for a challenge (with user profile data)
  Future<Result<List<ChallengeParticipantModel>>> getParticipants(
    String challengeId, {
    int limit = 100,
  }) async {
    try {
      final response = await client
          .from('user_challenges')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('challenge_id', challengeId)
          .order('current_progress', ascending: false)
          .limit(limit);

      final participants = (response as List)
          .map((json) =>
              ChallengeParticipantModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(participants);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get challenge statistics (computed from participants)
  Future<Result<ChallengeStatsModel>> getChallengeStats(
    String challengeId,
  ) async {
    try {
      final response = await client
          .from('user_challenges')
          .select('current_progress, is_completed')
          .eq('challenge_id', challengeId);

      final participants = response as List;
      final total = participants.length;
      final completed =
          participants.where((p) => p['is_completed'] == true).length;

      // Get challenge target for percentage calculation
      final challengeResult = await getChallenge(challengeId);
      final targetValue =
          challengeResult.isSuccess ? challengeResult.data!.targetValue : 1;

      double sumProgress = 0;
      for (final p in participants) {
        final progress = (p['current_progress'] as int? ?? 0);
        sumProgress += (progress / targetValue).clamp(0.0, 1.0);
      }

      return Result.success(ChallengeStatsModel(
        totalParticipants: total,
        completedCount: completed,
        avgProgress: total > 0 ? sumProgress / total : 0.0,
        activeCount: total - completed,
      ));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get all challenges with participant counts (for admin dashboard)
  Future<Result<Map<String, int>>> getChallengeOverviewStats() async {
    try {
      final challengesRes = await client.from('challenges').select('id, status');
      final challenges = challengesRes as List;

      final participantsRes = await client
          .from('user_challenges')
          .select('challenge_id, is_completed');
      final participants = participantsRes as List;

      return Result.success({
        'total': challenges.length,
        'active': challenges.where((c) => c['status'] == 'active').length,
        'upcoming': challenges.where((c) => c['status'] == 'upcoming').length,
        'completed': challenges.where((c) => c['status'] == 'completed').length,
        'totalParticipants': participants.length,
        'totalCompletions':
            participants.where((p) => p['is_completed'] == true).length,
      });
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's rank in a challenge
  Future<Result<int?>> getUserRank(String challengeId) async {
    try {
      if (userId == null) return Result.success(null);

      final leaderboardResult = await getLeaderboard(challengeId);
      if (!leaderboardResult.isSuccess) {
        return Result.failure(leaderboardResult.error!);
      }

      final userEntry = leaderboardResult.data!
          .where((e) => e.userId == userId)
          .firstOrNull;

      return Result.success(userEntry?.rank);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }
}
