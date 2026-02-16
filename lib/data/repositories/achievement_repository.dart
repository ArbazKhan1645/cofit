import '../models/badge_model.dart';
import 'base_repository.dart';

class AchievementRepository extends BaseRepository {
  // ============================================
  // ACHIEVEMENTS (Read)
  // ============================================

  /// Get all active achievements ordered by sort_order
  Future<Result<List<AchievementModel>>> getActiveAchievements() async {
    try {
      final response = await client
          .from('achievements')
          .select()
          .eq('is_active', true)
          .order('sort_order')
          .order('created_at');

      final achievements = (response as List)
          .map((json) =>
              AchievementModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(achievements);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get single achievement by ID
  Future<Result<AchievementModel>> getAchievement(String id) async {
    try {
      final response =
          await client.from('achievements').select().eq('id', id).single();

      return Result.success(AchievementModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // USER ACHIEVEMENTS
  // ============================================

  /// Get current user's achievements with joined achievement data
  Future<Result<List<UserAchievementModel>>> getMyAchievements() async {
    if (userId == null) {
      return Result.failure(
          RepositoryException(message: 'Not authenticated'));
    }

    try {
      final response = await client
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', userId!)
          .order('updated_at', ascending: false);

      final userAchievements = (response as List)
          .map((json) =>
              UserAchievementModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(userAchievements);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's progress for a specific achievement
  Future<Result<UserAchievementModel?>> getUserAchievement(
      String achievementId) async {
    if (userId == null) {
      return Result.failure(
          RepositoryException(message: 'Not authenticated'));
    }

    try {
      final response = await client
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', userId!)
          .eq('achievement_id', achievementId)
          .maybeSingle();

      if (response == null) return Result.success(null);

      return Result.success(UserAchievementModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Upsert user achievement progress
  Future<Result<UserAchievementModel>> upsertProgress({
    required String achievementId,
    required int newProgress,
  }) async {
    if (userId == null) {
      return Result.failure(
          RepositoryException(message: 'Not authenticated'));
    }

    try {
      final now = DateTime.now().toIso8601String();
      final response = await client
          .from('user_achievements')
          .upsert(
            {
              'user_id': userId!,
              'achievement_id': achievementId,
              'current_progress': newProgress,
              'updated_at': now,
            },
            onConflict: 'user_id,achievement_id',
          )
          .select('*, achievements(*)')
          .single();

      return Result.success(UserAchievementModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Mark achievement as completed
  Future<Result<void>> markCompleted(String achievementId) async {
    if (userId == null) {
      return Result.failure(
          RepositoryException(message: 'Not authenticated'));
    }

    try {
      final now = DateTime.now().toIso8601String();
      await client
          .from('user_achievements')
          .update({
            'is_completed': true,
            'completed_at': now,
            'updated_at': now,
          })
          .eq('user_id', userId!)
          .eq('achievement_id', achievementId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // ADMIN ANALYTICS
  // ============================================

  /// Get stats for a specific achievement
  Future<Result<AchievementStatsModel>> getAchievementStats(
      String achievementId) async {
    try {
      final response = await client
          .from('user_achievements')
          .select('current_progress, is_completed')
          .eq('achievement_id', achievementId);

      final rows = response as List;
      final totalUsers = rows.length;
      final completedCount =
          rows.where((r) => r['is_completed'] == true).length;
      final inProgressCount = rows
          .where((r) =>
              r['is_completed'] != true &&
              (r['current_progress'] as int? ?? 0) > 0)
          .length;

      // Get target value for average progress calculation
      final achievementRes = await client
          .from('achievements')
          .select('target_value')
          .eq('id', achievementId)
          .single();
      final targetValue =
          achievementRes['target_value'] as int? ?? 1;

      double avgProgress = 0.0;
      if (totalUsers > 0 && targetValue > 0) {
        final totalProgress = rows.fold<int>(
            0, (sum, r) => sum + ((r['current_progress'] as int?) ?? 0));
        avgProgress =
            (totalProgress / (totalUsers * targetValue)).clamp(0.0, 1.0);
      }

      return Result.success(AchievementStatsModel(
        totalUsers: totalUsers,
        completedCount: completedCount,
        avgProgress: avgProgress,
        inProgressCount: inProgressCount,
      ));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get all user progress entries for an achievement (admin detail)
  Future<Result<List<UserAchievementModel>>> getAchievementUsers(
    String achievementId, {
    int limit = 100,
  }) async {
    try {
      final response = await client
          .from('user_achievements')
          .select(
              '*, achievements(*), users:user_id(id, full_name, username, avatar_url)')
          .eq('achievement_id', achievementId)
          .order('current_progress', ascending: false)
          .limit(limit);

      final users = (response as List)
          .map((json) =>
              UserAchievementModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(users);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get overview stats for admin dashboard
  Future<Result<Map<String, int>>> getAchievementOverviewStats() async {
    try {
      final achievementsRes =
          await client.from('achievements').select('id, is_active');
      final achievements = achievementsRes as List;

      final userAchRes = await client
          .from('user_achievements')
          .select('id, is_completed');
      final userAch = userAchRes as List;

      return Result.success({
        'total': achievements.length,
        'active':
            achievements.where((a) => a['is_active'] == true).length,
        'completions':
            userAch.where((u) => u['is_completed'] == true).length,
        'users_tracking': userAch.length,
      });
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }
}
