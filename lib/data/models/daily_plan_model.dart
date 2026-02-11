import 'workout_model.dart';

class DailyPlanModel {
  final String id;
  final String title;
  final int totalDays;
  final DateTime startDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyPlanModel({
    required this.id,
    required this.title,
    this.totalDays = 0,
    required this.startDate,
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyPlanModel.fromJson(Map<String, dynamic> json) {
    return DailyPlanModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      totalDays: json['total_days'] as int? ?? 0,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ??
          DateTime.now(),
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
      'total_days': totalDays,
      'start_date': dateOnly(startDate),
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Returns the date for the given day number (1-based).
  /// Day 1 = startDate, Day 2 = startDate + 1, etc.
  DateTime getDateForDay(int dayNumber) {
    return startDate.add(Duration(days: dayNumber - 1));
  }

  DailyPlanModel copyWith({
    String? id,
    String? title,
    int? totalDays,
    DateTime? startDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyPlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      totalDays: totalDays ?? this.totalDays,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Format DateTime as yyyy-MM-dd for Supabase DATE column.
  static String dateOnly(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class DailyPlanItemModel {
  final String id;
  final String planId;
  final int dayNumber; // 1-based
  final String workoutId;
  final int sortOrder;
  final DateTime createdAt;

  // Joined data
  final WorkoutModel? workout;

  DailyPlanItemModel({
    required this.id,
    required this.planId,
    required this.dayNumber,
    required this.workoutId,
    this.sortOrder = 0,
    required this.createdAt,
    this.workout,
  });

  factory DailyPlanItemModel.fromJson(Map<String, dynamic> json) {
    return DailyPlanItemModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      dayNumber: json['day_number'] as int,
      workoutId: json['workout_id'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      workout: json['workouts'] != null
          ? WorkoutModel.fromJson(json['workouts'] as Map<String, dynamic>)
          : null,
    );
  }

  DailyPlanItemModel copyWith({
    String? id,
    String? planId,
    int? dayNumber,
    String? workoutId,
    int? sortOrder,
    DateTime? createdAt,
    WorkoutModel? workout,
  }) {
    return DailyPlanItemModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayNumber: dayNumber ?? this.dayNumber,
      workoutId: workoutId ?? this.workoutId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      workout: workout ?? this.workout,
    );
  }
}
