import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../data/models/weekly_schedule_model.dart';

class TodayWorkoutCacheService {
  final _storage = GetStorage();

  static const String _scheduleKey = 'cached_active_schedule';
  static const String _itemsKey = 'cached_schedule_items';
  static const String _cacheTimestampKey = 'schedule_cache_timestamp';

  void cacheSchedule(WeeklyScheduleModel schedule) {
    try {
      _storage.write(_scheduleKey, jsonEncode({
        'id': schedule.id,
        'title': schedule.title,
        'disabled_days': schedule.disabledDays,
        'is_active': schedule.isActive,
        'created_at': schedule.createdAt.toIso8601String(),
        'updated_at': schedule.updatedAt.toIso8601String(),
      }));
      _storage.write(
          _cacheTimestampKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  void cacheItems(List<WeeklyScheduleItemModel> items) {
    try {
      final jsonList = items.map((item) {
        final map = <String, dynamic>{
          'id': item.id,
          'schedule_id': item.scheduleId,
          'day_of_week': item.dayOfWeek,
          'workout_id': item.workoutId,
          'sort_order': item.sortOrder,
          'created_at': item.createdAt.toIso8601String(),
        };
        if (item.workout != null) {
          final workoutJson = item.workout!.toJson();
          if (item.workout!.trainer != null) {
            workoutJson['trainers'] = item.workout!.trainer!.toJson();
          }
          map['workouts'] = workoutJson;
        }
        return map;
      }).toList();
      _storage.write(_itemsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  WeeklyScheduleModel? getCachedSchedule() {
    try {
      final cached = _storage.read<String>(_scheduleKey);
      if (cached == null) return null;
      return WeeklyScheduleModel.fromJson(
          jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  List<WeeklyScheduleItemModel>? getCachedItems() {
    try {
      final cached = _storage.read<String>(_itemsKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((json) =>
              WeeklyScheduleItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  bool hasCachedData() {
    return _storage.read<String>(_scheduleKey) != null;
  }

  void clearCache() {
    _storage.remove(_scheduleKey);
    _storage.remove(_itemsKey);
    _storage.remove(_cacheTimestampKey);
  }
}
