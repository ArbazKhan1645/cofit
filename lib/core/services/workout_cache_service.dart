import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/workout_model.dart';
import '../../data/models/weekly_schedule_model.dart';

/// Local cache for workout data — instant display while fetching fresh data.
class WorkoutCacheService extends GetxService {
  static WorkoutCacheService get to => Get.find();

  final _storage = GetStorage();

  static const String _trainersKey = 'cached_trainers';
  static const String _scheduleKey = 'cached_schedule';
  static const String _scheduleItemsKey = 'cached_schedule_items';
  static const String _savedIdsKey = 'cached_saved_workout_ids';
  static const String _savedWorkoutsKey = 'cached_saved_workouts';
  static const String _allWorkoutsKey = 'cached_all_workouts';

  Future<WorkoutCacheService> init() async => this;

  // ============================================
  // TRAINERS
  // ============================================

  Future<void> cacheTrainers(List<TrainerModel> trainers) async {
    try {
      final jsonList = trainers.map((t) => t.toJson()).toList();
      await _storage.write(_trainersKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<TrainerModel>? getCachedTrainers() {
    try {
      final cached = _storage.read<String>(_trainersKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => TrainerModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // WEEKLY SCHEDULE
  // ============================================

  Future<void> cacheSchedule(
    WeeklyScheduleModel? schedule,
    List<WeeklyScheduleItemModel> items,
  ) async {
    try {
      if (schedule != null) {
        await _storage.write(_scheduleKey, jsonEncode(schedule.toCacheJson()));
      }
      final jsonList = items.map((i) => i.toCacheJson()).toList();
      await _storage.write(_scheduleItemsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  WeeklyScheduleModel? getCachedSchedule() {
    try {
      final cached = _storage.read<String>(_scheduleKey);
      if (cached == null) return null;
      return WeeklyScheduleModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  List<WeeklyScheduleItemModel>? getCachedScheduleItems() {
    try {
      final cached = _storage.read<String>(_scheduleItemsKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) =>
              WeeklyScheduleItemModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // SAVED WORKOUTS
  // ============================================

  Future<void> cacheSavedWorkoutIds(List<String> ids) async {
    try {
      await _storage.write(_savedIdsKey, jsonEncode(ids));
    } catch (_) {}
  }

  List<String>? getCachedSavedWorkoutIds() {
    try {
      final cached = _storage.read<String>(_savedIdsKey);
      if (cached == null) return null;
      final list = jsonDecode(cached) as List;
      return list.map((e) => e as String).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheSavedWorkouts(List<SavedWorkoutModel> workouts) async {
    try {
      final jsonList = workouts.map((w) => w.toCacheJson()).toList();
      await _storage.write(_savedWorkoutsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<SavedWorkoutModel>? getCachedSavedWorkouts() {
    try {
      final cached = _storage.read<String>(_savedWorkoutsKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => SavedWorkoutModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // LIBRARY (ALL WORKOUTS)
  // ============================================

  Future<void> cacheAllWorkouts(List<WorkoutModel> workouts) async {
    try {
      final jsonList = workouts.map((w) => w.toCacheJson()).toList();
      await _storage.write(_allWorkoutsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<WorkoutModel>? getCachedAllWorkouts() {
    try {
      final cached = _storage.read<String>(_allWorkoutsKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => WorkoutModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // UTILS
  // ============================================

  bool hasCache() => _storage.read<String>(_trainersKey) != null;

  Future<void> clearCache() async {
    await _storage.remove(_trainersKey);
    await _storage.remove(_scheduleKey);
    await _storage.remove(_scheduleItemsKey);
    await _storage.remove(_savedIdsKey);
    await _storage.remove(_savedWorkoutsKey);
    await _storage.remove(_allWorkoutsKey);
  }
}
