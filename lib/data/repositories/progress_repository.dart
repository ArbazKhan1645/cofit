import '../models/progress_model.dart';
import 'base_repository.dart';

/// Progress Repository - Provides DB access for user progress stats
class ProgressRepository extends BaseRepository {
  /// Get daily progress for a specific week (Mon-Sun).
  /// Returns 7 DailyProgress entries, one per day, filling missing days with zeros.
  Future<Result<List<DailyProgress>>> getWeeklyStats(
      DateTime weekStart) async {
    try {
      if (userId == null) {
        return Result.success(_emptyWeek(weekStart));
      }

      final weekEnd = weekStart.add(const Duration(days: 7));

      final response = await client
          .from('user_progress')
          .select('completed_at, duration_minutes, calories_burned')
          .eq('user_id', userId!)
          .gte('completed_at', weekStart.toIso8601String())
          .lt('completed_at', weekEnd.toIso8601String());

      // Group by date
      final Map<String, DailyProgress> byDate = {};
      for (final row in response as List) {
        final completedAt = DateTime.parse(row['completed_at'] as String);
        final dateKey =
            '${completedAt.year}-${completedAt.month}-${completedAt.day}';

        final existing = byDate[dateKey];
        if (existing != null) {
          byDate[dateKey] = DailyProgress(
            date: DateTime(
                completedAt.year, completedAt.month, completedAt.day),
            workoutsCompleted: existing.workoutsCompleted + 1,
            minutesWorkedOut:
                existing.minutesWorkedOut + (row['duration_minutes'] as int),
            caloriesBurned:
                existing.caloriesBurned + (row['calories_burned'] as int? ?? 0),
          );
        } else {
          byDate[dateKey] = DailyProgress(
            date: DateTime(
                completedAt.year, completedAt.month, completedAt.day),
            workoutsCompleted: 1,
            minutesWorkedOut: row['duration_minutes'] as int,
            caloriesBurned: row['calories_burned'] as int? ?? 0,
          );
        }
      }

      // Fill all 7 days
      final result = <DailyProgress>[];
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateKey = '${date.year}-${date.month}-${date.day}';
        result.add(byDate[dateKey] ?? DailyProgress(date: date));
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's lifetime stats from users table (maintained by DB trigger).
  Future<Result<UserStats>> getUserStats() async {
    try {
      if (userId == null) {
        return Result.success(const UserStats(
          totalWorkouts: 0,
          totalMinutes: 0,
          totalCalories: 0,
          currentStreak: 0,
          longestStreak: 0,
        ));
      }

      final response = await client
          .from('users')
          .select(
              'total_workouts_completed, total_minutes_worked_out, total_calories_burned, current_streak, longest_streak')
          .eq('id', userId!)
          .single();

      return Result.success(UserStats(
        totalWorkouts: response['total_workouts_completed'] as int? ?? 0,
        totalMinutes: response['total_minutes_worked_out'] as int? ?? 0,
        totalCalories: response['total_calories_burned'] as int? ?? 0,
        currentStreak: response['current_streak'] as int? ?? 0,
        longestStreak: response['longest_streak'] as int? ?? 0,
      ));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get month stats from month_progress table.
  Future<Result<MonthProgressModel?>> getMonthStats(
      int year, int month) async {
    try {
      if (userId == null) return Result.success(null);

      final response = await client
          .from('month_progress')
          .select()
          .eq('user_id', userId!)
          .eq('year', year)
          .eq('month', month)
          .maybeSingle();

      if (response == null) return Result.success(null);
      return Result.success(MonthProgressModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workout dates as a Set for calendar display.
  Future<Result<Set<DateTime>>> getWorkoutDateSet({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (userId == null) return Result.success({});

      final response = await client
          .from('user_progress')
          .select('completed_at')
          .eq('user_id', userId!)
          .gte('completed_at', startDate.toIso8601String())
          .lte('completed_at', endDate.toIso8601String());

      final dates = (response as List).map((row) {
        final dt = DateTime.parse(row['completed_at'] as String);
        return DateTime(dt.year, dt.month, dt.day);
      }).toSet();

      return Result.success(dates);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Call update_month_progress RPC to aggregate current month stats.
  Future<Result<void>> callUpdateMonthProgress() async {
    try {
      if (userId == null) return Result.success(null);

      await client.rpc('update_month_progress', params: {
        'p_user_id': userId!,
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  List<DailyProgress> _emptyWeek(DateTime weekStart) {
    return List.generate(
        7, (i) => DailyProgress(date: weekStart.add(Duration(days: i))));
  }
}

/// Simple data class for user lifetime stats from users table.
class UserStats {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;
  final int currentStreak;
  final int longestStreak;

  const UserStats({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCalories,
    required this.currentStreak,
    required this.longestStreak,
  });
}
