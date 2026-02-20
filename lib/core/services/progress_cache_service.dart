import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Local cache for progress stats — shows last-known stats when offline.
class ProgressCacheService extends GetxService {
  static ProgressCacheService get to => Get.find();

  final _storage = GetStorage();

  static const String _statsKey = 'cached_progress_stats';
  static const String _workoutDatesKey = 'cached_workout_dates';

  Future<ProgressCacheService> init() async => this;

  // ============================================
  // STATS (all integer values)
  // ============================================

  Future<void> cacheStats({
    required int workoutsThisWeek,
    required int minutesThisWeek,
    required int currentStreak,
    required int longestStreak,
    required int totalWorkouts,
    required int totalMinutes,
    required int totalCalories,
    required int totalWorkoutsThisMonth,
  }) async {
    try {
      await _storage.write(_statsKey, jsonEncode({
        'workouts_this_week': workoutsThisWeek,
        'minutes_this_week': minutesThisWeek,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_workouts': totalWorkouts,
        'total_minutes': totalMinutes,
        'total_calories': totalCalories,
        'total_workouts_this_month': totalWorkoutsThisMonth,
      }));
    } catch (_) {}
  }

  Map<String, int>? getCachedStats() {
    try {
      final cached = _storage.read<String>(_statsKey);
      if (cached == null) return null;
      final json = jsonDecode(cached) as Map<String, dynamic>;
      return json.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // WORKOUT DATES
  // ============================================

  Future<void> cacheWorkoutDates(Set<DateTime> dates) async {
    try {
      final list = dates.map((d) => d.toIso8601String()).toList();
      await _storage.write(_workoutDatesKey, jsonEncode(list));
    } catch (_) {}
  }

  Set<DateTime>? getCachedWorkoutDates() {
    try {
      final cached = _storage.read<String>(_workoutDatesKey);
      if (cached == null) return null;
      final list = jsonDecode(cached) as List;
      return list.map((s) => DateTime.parse(s as String)).toSet();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // UTILS
  // ============================================

  bool hasCache() => _storage.read<String>(_statsKey) != null;

  Future<void> clearCache() async {
    await _storage.remove(_statsKey);
    await _storage.remove(_workoutDatesKey);
  }
}
