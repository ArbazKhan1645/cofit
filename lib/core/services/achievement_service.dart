import 'package:get/get.dart';

import '../../data/models/badge_model.dart';
import '../../data/repositories/achievement_repository.dart';

class AchievementService extends GetxService {
  static AchievementService get to => Get.find();

  final AchievementRepository _repository = AchievementRepository();
  List<AchievementModel>? _cachedAchievements;

  // ============================================
  // PUBLIC EVENT HANDLERS
  // ============================================

  /// Call when a user completes a workout.
  /// Checks: workout_count, first_workout, workout_minutes, calories_burned, category_workouts
  /// Returns list of newly unlocked achievements.
  Future<List<AchievementModel>> onWorkoutCompleted({
    required String workoutCategory,
    required int durationMinutes,
    required int caloriesBurned,
  }) async {
    final achievements = await _getAchievements();
    final newlyUnlocked = <AchievementModel>[];

    for (final achievement in achievements) {
      bool unlocked = false;
      switch (achievement.type) {
        case 'workout_count':
          unlocked = await _incrementProgress(achievement.id, 1, achievement.targetValue);
          break;
        case 'first_workout':
          unlocked = await _setProgress(achievement.id, 1, achievement.targetValue);
          break;
        case 'workout_minutes':
          unlocked = await _incrementProgress(
              achievement.id, durationMinutes, achievement.targetValue);
          break;
        case 'calories_burned':
          unlocked = await _incrementProgress(
              achievement.id, caloriesBurned, achievement.targetValue);
          break;
        case 'category_workouts':
          if (achievement.targetCategory != null &&
              achievement.targetCategory!.toLowerCase() ==
                  workoutCategory.toLowerCase()) {
            unlocked = await _incrementProgress(
                achievement.id, 1, achievement.targetValue);
          }
          break;
        default:
          break;
      }
      if (unlocked) newlyUnlocked.add(achievement);
    }
    return newlyUnlocked;
  }

  /// Call when the user's streak is updated.
  /// Checks: streak_days, consecutive_days
  /// Returns list of newly unlocked achievements.
  Future<List<AchievementModel>> onStreakUpdated({required int currentStreak}) async {
    final achievements = await _getAchievements();
    final newlyUnlocked = <AchievementModel>[];

    for (final achievement in achievements) {
      bool unlocked = false;
      switch (achievement.type) {
        case 'streak_days':
        case 'consecutive_days':
          unlocked = await _setProgress(
              achievement.id, currentStreak, achievement.targetValue);
          break;
        default:
          break;
      }
      if (unlocked) newlyUnlocked.add(achievement);
    }
    return newlyUnlocked;
  }

  /// Call when a user completes a challenge.
  /// Checks: challenge_completions, first_challenge
  /// Returns list of newly unlocked achievements.
  Future<List<AchievementModel>> onChallengeCompleted() async {
    final achievements = await _getAchievements();
    final newlyUnlocked = <AchievementModel>[];

    for (final achievement in achievements) {
      bool unlocked = false;
      switch (achievement.type) {
        case 'challenge_completions':
          unlocked = await _incrementProgress(achievement.id, 1, achievement.targetValue);
          break;
        case 'first_challenge':
          unlocked = await _setProgress(achievement.id, 1, achievement.targetValue);
          break;
        default:
          break;
      }
      if (unlocked) newlyUnlocked.add(achievement);
    }
    return newlyUnlocked;
  }

  /// Invalidate cached achievements (call after admin creates/edits achievements)
  void invalidateCache() {
    _cachedAchievements = null;
  }

  // ============================================
  // PRIVATE HELPERS
  // ============================================

  Future<List<AchievementModel>> _getAchievements() async {
    if (_cachedAchievements != null) return _cachedAchievements!;

    final result = await _repository.getActiveAchievements();
    return result.fold(
      (error) => <AchievementModel>[],
      (data) {
        _cachedAchievements = data;
        return data;
      },
    );
  }

  /// Returns true if the achievement was newly completed.
  Future<bool> _incrementProgress(
      String achievementId, int delta, int target) async {
    final result = await _repository.getUserAchievement(achievementId);
    return result.fold(
      (error) async {
        // No record yet — create with delta
        await _repository.upsertProgress(
            achievementId: achievementId, newProgress: delta);
        if (delta >= target) {
          await _repository.markCompleted(achievementId);
          return true;
        }
        return false;
      },
      (data) async {
        if (data != null && data.isCompleted) return false; // Already done

        final current = data?.currentProgress ?? 0;
        final updated = current + delta;
        await _repository.upsertProgress(
            achievementId: achievementId, newProgress: updated);
        if (updated >= target) {
          await _repository.markCompleted(achievementId);
          return true;
        }
        return false;
      },
    );
  }

  /// Returns true if the achievement was newly completed.
  Future<bool> _setProgress(
      String achievementId, int value, int target) async {
    final result = await _repository.getUserAchievement(achievementId);
    return result.fold(
      (error) async {
        await _repository.upsertProgress(
            achievementId: achievementId, newProgress: value);
        if (value >= target) {
          await _repository.markCompleted(achievementId);
          return true;
        }
        return false;
      },
      (data) async {
        if (data != null && data.isCompleted) return false;

        final current = data?.currentProgress ?? 0;
        // Only update if new value is higher (for streaks)
        if (value > current) {
          await _repository.upsertProgress(
              achievementId: achievementId, newProgress: value);
          if (value >= target) {
            await _repository.markCompleted(achievementId);
            return true;
          }
        }
        return false;
      },
    );
  }
}
