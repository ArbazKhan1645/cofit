import 'workout_model.dart';

class WeeklyScheduleModel {
  final String id;
  final String title;
  final List<int> disabledDays; // 0=Monday, 6=Sunday
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyScheduleModel({
    required this.id,
    required this.title,
    this.disabledDays = const [],
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyScheduleModel.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      disabledDays: (json['disabled_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'disabled_days': disabledDays,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'title': title,
      'disabled_days': disabledDays,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WeeklyScheduleModel copyWith({
    String? id,
    String? title,
    List<int>? disabledDays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      disabledDays: disabledDays ?? this.disabledDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isDayDisabled(int dayIndex) => disabledDays.contains(dayIndex);
}

class WeeklyScheduleItemModel {
  final String id;
  final String scheduleId;
  final int dayOfWeek; // 0=Monday, 6=Sunday
  final String workoutId;
  final int sortOrder;
  final DateTime createdAt;

  // Joined data
  final WorkoutModel? workout;

  WeeklyScheduleItemModel({
    required this.id,
    required this.scheduleId,
    required this.dayOfWeek,
    required this.workoutId,
    this.sortOrder = 0,
    required this.createdAt,
    this.workout,
  });

  factory WeeklyScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleItemModel(
      id: json['id'] as String,
      scheduleId: json['schedule_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      workoutId: json['workout_id'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      workout: json['workouts'] != null
          ? WorkoutModel.fromJson(json['workouts'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'schedule_id': scheduleId,
      'day_of_week': dayOfWeek,
      'workout_id': workoutId,
      'sort_order': sortOrder,
    };
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'day_of_week': dayOfWeek,
      'workout_id': workoutId,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      if (workout != null) 'workouts': workout!.toCacheJson(),
    };
  }

  WeeklyScheduleItemModel copyWith({
    String? id,
    String? scheduleId,
    int? dayOfWeek,
    String? workoutId,
    int? sortOrder,
    DateTime? createdAt,
    WorkoutModel? workout,
  }) {
    return WeeklyScheduleItemModel(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      workoutId: workoutId ?? this.workoutId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      workout: workout ?? this.workout,
    );
  }
}
