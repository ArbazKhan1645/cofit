import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import '../../data/models/progress_model.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/challenge_repository.dart';
import '../services/achievement_service.dart';
import '../services/progress_cache_service.dart';
import '../../shared/widgets/achievement_unlock_overlay.dart';

/// Central progress tracking service.
/// Single source of truth for all reactive progress stats consumed by
/// HomeController and ProgressController via ever() watchers.
class ProgressService extends GetxService {
  static ProgressService get to => Get.find();

  final ProgressRepository _progressRepo = ProgressRepository();
  final ChallengeRepository _challengeRepo = ChallengeRepository();
  ProgressCacheService get _cache => ProgressCacheService.to;

  // ============================================
  // REACTIVE STATE
  // ============================================

  // Weekly stats (current Mon-Sun)
  final RxList<DailyProgress> weeklyProgress = <DailyProgress>[].obs;
  final RxInt workoutsThisWeek = 0.obs;
  final RxInt minutesThisWeek = 0.obs;

  // Streak
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;

  // Lifetime totals
  final RxInt totalWorkouts = 0.obs;
  final RxInt totalMinutes = 0.obs;
  final RxInt totalCalories = 0.obs;

  // Monthly
  final RxInt totalWorkoutsThisMonth = 0.obs;

  // Workout calendar dates
  final RxSet<DateTime> workoutDates = <DateTime>{}.obs;

  // Notifier: incremented after achievements are processed so controllers can reload
  final RxInt achievementVersion = 0.obs;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<ProgressService> init() async {
    // 1. Show cached stats instantly
    _loadFromCache();

    // 2. Try fresh data from network
    if (await _hasInternet()) {
      await refreshStats();
    }
    return this;
  }

  /// Full reload of all stats from DB.
  Future<void> refreshStats() async {
    await Future.wait([
      _loadWeeklyStats(),
      _loadUserStats(),
      _loadMonthStats(),
      _loadWorkoutDates(),
    ]);
    _saveToCache();
  }

  void _loadFromCache() {
    final stats = _cache.getCachedStats();
    if (stats != null) {
      workoutsThisWeek.value = stats['workouts_this_week'] ?? 0;
      minutesThisWeek.value = stats['minutes_this_week'] ?? 0;
      currentStreak.value = stats['current_streak'] ?? 0;
      longestStreak.value = stats['longest_streak'] ?? 0;
      totalWorkouts.value = stats['total_workouts'] ?? 0;
      totalMinutes.value = stats['total_minutes'] ?? 0;
      totalCalories.value = stats['total_calories'] ?? 0;
      totalWorkoutsThisMonth.value = stats['total_workouts_this_month'] ?? 0;
    }
    final dates = _cache.getCachedWorkoutDates();
    if (dates != null) {
      workoutDates.clear();
      workoutDates.addAll(dates);
      workoutDates.refresh();
    }
  }

  void _saveToCache() {
    _cache.cacheStats(
      workoutsThisWeek: workoutsThisWeek.value,
      minutesThisWeek: minutesThisWeek.value,
      currentStreak: currentStreak.value,
      longestStreak: longestStreak.value,
      totalWorkouts: totalWorkouts.value,
      totalMinutes: totalMinutes.value,
      totalCalories: totalCalories.value,
      totalWorkoutsThisMonth: totalWorkoutsThisMonth.value,
    );
    _cache.cacheWorkoutDates(workoutDates.toSet());
  }

  // ============================================
  // STAT LOADING (private)
  // ============================================

  Future<void> _loadWeeklyStats() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    final result = await _progressRepo.getWeeklyStats(weekStart);
    result.fold(
      (error) {},
      (data) {
        weeklyProgress.value = data;
        workoutsThisWeek.value =
            data.fold(0, (sum, d) => sum + d.workoutsCompleted);
        minutesThisWeek.value =
            data.fold(0, (sum, d) => sum + d.minutesWorkedOut);
      },
    );
  }

  Future<void> _loadUserStats() async {
    final result = await _progressRepo.getUserStats();
    result.fold(
      (error) {},
      (stats) {
        totalWorkouts.value = stats.totalWorkouts;
        totalMinutes.value = stats.totalMinutes;
        totalCalories.value = stats.totalCalories;
        longestStreak.value = stats.longestStreak;
      },
    );
    // Calculate streak from user_progress (source of truth)
    final streakResult = await _progressRepo.calculateStreakFromProgress();
    streakResult.fold(
      (error) {},
      (streak) {
        currentStreak.value = streak;
        if (streak > longestStreak.value) {
          longestStreak.value = streak;
        }
      },
    );
  }

  Future<void> _loadMonthStats() async {
    final now = DateTime.now();
    final result = await _progressRepo.getMonthStats(now.year, now.month);
    result.fold(
      (error) {},
      (data) {
        totalWorkoutsThisMonth.value = data?.totalWorkouts ?? 0;
      },
    );
  }

  Future<void> _loadWorkoutDates() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 2, 1);

    final result = await _progressRepo.getWorkoutDateSet(
      startDate: start,
      endDate: now,
    );
    result.fold(
      (error) {},
      (dates) {
        workoutDates.clear();
        workoutDates.addAll(dates);
        workoutDates.refresh();
      },
    );
  }

  // ============================================
  // CONNECTIVITY
  // ============================================

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // ============================================
  // WORKOUT COMPLETED — CENTRAL ORCHESTRATOR
  // ============================================

  /// Called after workout completion is logged to DB.
  /// Handles: optimistic UI, achievements, challenges, month progress.
  Future<void> onWorkoutCompleted({
    required String workoutId,
    required String workoutCategory,
    required int durationMinutes,
    required int caloriesBurned,
  }) async {
    // 1. Optimistic local updates (instant UI feedback)
    _updateStatsOptimistically(durationMinutes, caloriesBurned);

    // 2. Fire-and-forget background operations
    unawaited(_processAchievements(
      workoutCategory: workoutCategory,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
    ));

    unawaited(_processChallenges(
      workoutCategory: workoutCategory,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
    ));

    unawaited(_progressRepo.callUpdateMonthProgress());

    // 3. Calculate streak from user_progress and update users table
    unawaited(_calculateAndUpdateStreak());
  }

  void _updateStatsOptimistically(int durationMinutes, int caloriesBurned) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // Update weekly progress
    final existingIndex = weeklyProgress.indexWhere(
      (d) =>
          d.date.year == todayDate.year &&
          d.date.month == todayDate.month &&
          d.date.day == todayDate.day,
    );

    if (existingIndex >= 0) {
      final existing = weeklyProgress[existingIndex];
      weeklyProgress[existingIndex] = DailyProgress(
        date: existing.date,
        workoutsCompleted: existing.workoutsCompleted + 1,
        minutesWorkedOut: existing.minutesWorkedOut + durationMinutes,
        caloriesBurned: existing.caloriesBurned + caloriesBurned,
      );
    } else {
      weeklyProgress.add(DailyProgress(
        date: todayDate,
        workoutsCompleted: 1,
        minutesWorkedOut: durationMinutes,
        caloriesBurned: caloriesBurned,
      ));
    }
    weeklyProgress.refresh();

    // Update aggregates
    workoutsThisWeek.value++;
    minutesThisWeek.value += durationMinutes;
    totalWorkouts.value++;
    totalMinutes.value += durationMinutes;
    totalCalories.value += caloriesBurned;
    totalWorkoutsThisMonth.value++;

    // Add today to workout dates
    workoutDates.add(todayDate);
    workoutDates.refresh();

    // Persist optimistic update to cache
    _saveToCache();
  }

  // ============================================
  // STREAK CALCULATION
  // ============================================

  Future<void> _calculateAndUpdateStreak() async {
    try {
      final result = await _progressRepo.calculateStreakFromProgress();
      result.fold(
        (error) {},
        (streak) {
          currentStreak.value = streak;
          final longest = streak > longestStreak.value
              ? streak
              : longestStreak.value;
          longestStreak.value = longest;

          // Persist streak + totals to users table
          _progressRepo.updateUserStats(
            currentStreak: streak,
            longestStreak: longest,
            totalWorkouts: totalWorkouts.value,
            totalMinutes: totalMinutes.value,
            totalCalories: totalCalories.value,
          );
        },
      );
    } catch (_) {}
  }

  // ============================================
  // ACHIEVEMENTS
  // ============================================

  Future<void> _processAchievements({
    required String workoutCategory,
    required int durationMinutes,
    required int caloriesBurned,
  }) async {
    try {
      if (!Get.isRegistered<AchievementService>()) return;
      final achievementService = Get.find<AchievementService>();

      final unlocked = await achievementService.onWorkoutCompleted(
        workoutCategory: workoutCategory,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
      );

      // Also update streak-based achievements
      final streakUnlocked = await achievementService.onStreakUpdated(
        currentStreak: currentStreak.value,
      );

      final allUnlocked = [...unlocked, ...streakUnlocked];

      // Notify controllers that achievements changed (even if none newly unlocked,
      // progress values may have updated in the DB)
      achievementVersion.value++;

      for (final achievement in allUnlocked) {
        AchievementUnlockOverlay.show(achievement);
        if (allUnlocked.length > 1) {
          await Future.delayed(const Duration(seconds: 4));
        }
      }
    } catch (_) {
      // Silent failure for background operation
    }
  }

  // ============================================
  // CHALLENGES
  // ============================================

  Future<void> _processChallenges({
    required String workoutCategory,
    required int durationMinutes,
    required int caloriesBurned,
  }) async {
    try {
      final result = await _challengeRepo.getMyActiveChallenges();
      if (!result.isSuccess) return;

      final activeChallenges = result.data!;

      for (final uc in activeChallenges) {
        final challenge = uc.challenge;
        if (challenge == null) continue;

        int increment = 0;
        bool shouldUpdate = false;

        switch (challenge.challengeType) {
          case 'workout_count':
          case 'specific_category':
            // Already handled by DB trigger — skip
            break;
          case 'minutes':
            increment = durationMinutes;
            shouldUpdate = true;
            break;
          case 'calories':
            increment = caloriesBurned;
            shouldUpdate = true;
            break;
          case 'streak':
            final newProgress = currentStreak.value;
            if (newProgress > uc.currentProgress) {
              await _challengeRepo.updateChallengeProgress(
                  challenge.id, newProgress);
              if (newProgress >= challenge.targetValue && !uc.isCompleted) {
                await _challengeRepo.markChallengeCompleted(challenge.id);
                _triggerChallengeAchievement();
              }
            }
            break;
        }

        if (shouldUpdate && increment > 0) {
          final newProgress = uc.currentProgress + increment;
          await _challengeRepo.updateChallengeProgress(
              challenge.id, newProgress);
          if (newProgress >= challenge.targetValue && !uc.isCompleted) {
            await _challengeRepo.markChallengeCompleted(challenge.id);
            _triggerChallengeAchievement();
          }
        }
      }
    } catch (_) {
      // Silent failure for background operation
    }
  }

  void _triggerChallengeAchievement() {
    if (!Get.isRegistered<AchievementService>()) return;
    unawaited(Get.find<AchievementService>().onChallengeCompleted());
  }
}
