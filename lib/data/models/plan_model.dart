/// User Plan Model - Personalized fitness plan generated after onboarding
/// Supabase Table: user_plans
class UserPlanModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int weeklyWorkoutTarget;
  final int sessionDurationMinutes;
  final int weeklyCalorieTarget;
  final List<String> preferredWorkoutTypes;
  final List<String> targetGoals;
  final String fitnessLevel; // beginner, intermediate, advanced
  final String preferredTime; // morning, afternoon, evening
  final Map<String, bool> weeklySchedule; // {mon: true, tue: false, ...}
  final int durationWeeks; // How long the plan runs
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int currentWeek;
  final double completionRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPlanModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.weeklyWorkoutTarget,
    required this.sessionDurationMinutes,
    this.weeklyCalorieTarget = 0,
    this.preferredWorkoutTypes = const [],
    this.targetGoals = const [],
    required this.fitnessLevel,
    required this.preferredTime,
    this.weeklySchedule = const {},
    this.durationWeeks = 12,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.currentWeek = 1,
    this.completionRate = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPlanModel.fromJson(Map<String, dynamic> json) {
    return UserPlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      weeklyWorkoutTarget: json['weekly_workout_target'] as int,
      sessionDurationMinutes: json['session_duration_minutes'] as int,
      weeklyCalorieTarget: json['weekly_calorie_target'] as int? ?? 0,
      preferredWorkoutTypes: (json['preferred_workout_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      targetGoals: (json['target_goals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fitnessLevel: json['fitness_level'] as String,
      preferredTime: json['preferred_time'] as String,
      weeklySchedule: (json['weekly_schedule'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          {},
      durationWeeks: json['duration_weeks'] as int? ?? 12,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      currentWeek: json['current_week'] as int? ?? 1,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'weekly_workout_target': weeklyWorkoutTarget,
      'session_duration_minutes': sessionDurationMinutes,
      'weekly_calorie_target': weeklyCalorieTarget,
      'preferred_workout_types': preferredWorkoutTypes,
      'target_goals': targetGoals,
      'fitness_level': fitnessLevel,
      'preferred_time': preferredTime,
      'weekly_schedule': weeklySchedule,
      'duration_weeks': durationWeeks,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'current_week': currentWeek,
      'completion_rate': completionRate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'weekly_workout_target': weeklyWorkoutTarget,
      'session_duration_minutes': sessionDurationMinutes,
      'weekly_calorie_target': weeklyCalorieTarget,
      'preferred_workout_types': preferredWorkoutTypes,
      'target_goals': targetGoals,
      'fitness_level': fitnessLevel,
      'preferred_time': preferredTime,
      'weekly_schedule': weeklySchedule,
      'duration_weeks': durationWeeks,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'current_week': currentWeek,
      'completion_rate': completionRate,
    };
  }

  UserPlanModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? weeklyWorkoutTarget,
    int? sessionDurationMinutes,
    int? weeklyCalorieTarget,
    List<String>? preferredWorkoutTypes,
    List<String>? targetGoals,
    String? fitnessLevel,
    String? preferredTime,
    Map<String, bool>? weeklySchedule,
    int? durationWeeks,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? currentWeek,
    double? completionRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      weeklyWorkoutTarget: weeklyWorkoutTarget ?? this.weeklyWorkoutTarget,
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      weeklyCalorieTarget: weeklyCalorieTarget ?? this.weeklyCalorieTarget,
      preferredWorkoutTypes:
          preferredWorkoutTypes ?? this.preferredWorkoutTypes,
      targetGoals: targetGoals ?? this.targetGoals,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      preferredTime: preferredTime ?? this.preferredTime,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      currentWeek: currentWeek ?? this.currentWeek,
      completionRate: completionRate ?? this.completionRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get workout days as a list of day names
  List<String> get workoutDays {
    final days = <String>[];
    weeklySchedule.forEach((day, isActive) {
      if (isActive) days.add(day);
    });
    return days;
  }

  /// Calculate weeks remaining
  int get weeksRemaining => durationWeeks - currentWeek + 1;

  /// Check if plan has ended
  bool get hasEnded =>
      endDate != null && DateTime.now().isAfter(endDate!) || !isActive;

  /// Get progress percentage through the plan
  double get progressPercentage =>
      durationWeeks > 0 ? (currentWeek / durationWeeks).clamp(0.0, 1.0) : 0.0;
}

/// Plan Week Model - Weekly plan breakdown
/// Supabase Table: plan_weeks
class PlanWeekModel {
  final String id;
  final String planId;
  final int weekNumber;
  final String? theme; // e.g., "Foundation Week", "Push Week"
  final String? description;
  final int targetWorkouts;
  final int completedWorkouts;
  final int targetMinutes;
  final int completedMinutes;
  final bool isCompleted;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final DateTime createdAt;

  PlanWeekModel({
    required this.id,
    required this.planId,
    required this.weekNumber,
    this.theme,
    this.description,
    required this.targetWorkouts,
    this.completedWorkouts = 0,
    required this.targetMinutes,
    this.completedMinutes = 0,
    this.isCompleted = false,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.createdAt,
  });

  factory PlanWeekModel.fromJson(Map<String, dynamic> json) {
    return PlanWeekModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      weekNumber: json['week_number'] as int,
      theme: json['theme'] as String?,
      description: json['description'] as String?,
      targetWorkouts: json['target_workouts'] as int,
      completedWorkouts: json['completed_workouts'] as int? ?? 0,
      targetMinutes: json['target_minutes'] as int,
      completedMinutes: json['completed_minutes'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      weekStartDate: DateTime.parse(json['week_start_date'] as String),
      weekEndDate: DateTime.parse(json['week_end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'week_number': weekNumber,
      'theme': theme,
      'description': description,
      'target_workouts': targetWorkouts,
      'completed_workouts': completedWorkouts,
      'target_minutes': targetMinutes,
      'completed_minutes': completedMinutes,
      'is_completed': isCompleted,
      'week_start_date': weekStartDate.toIso8601String(),
      'week_end_date': weekEndDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get workout completion percentage
  double get workoutCompletionRate =>
      targetWorkouts > 0 ? (completedWorkouts / targetWorkouts).clamp(0.0, 1.0) : 0.0;

  /// Get minutes completion percentage
  double get minutesCompletionRate =>
      targetMinutes > 0 ? (completedMinutes / targetMinutes).clamp(0.0, 1.0) : 0.0;

  /// Check if this is the current week
  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(weekStartDate) && now.isBefore(weekEndDate);
  }
}

/// Scheduled Workout Model - Planned workouts in a user's plan
/// Supabase Table: scheduled_workouts
class ScheduledWorkoutModel {
  final String id;
  final String planId;
  final String? planWeekId;
  final String userId;
  final String workoutId;
  final DateTime scheduledDate;
  final String? scheduledTime; // HH:mm format
  final bool isCompleted;
  final DateTime? completedAt;
  final String? progressId; // Link to user_progress when completed
  final bool reminderSent;
  final DateTime createdAt;

  ScheduledWorkoutModel({
    required this.id,
    required this.planId,
    this.planWeekId,
    required this.userId,
    required this.workoutId,
    required this.scheduledDate,
    this.scheduledTime,
    this.isCompleted = false,
    this.completedAt,
    this.progressId,
    this.reminderSent = false,
    required this.createdAt,
  });

  factory ScheduledWorkoutModel.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkoutModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      planWeekId: json['plan_week_id'] as String?,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledTime: json['scheduled_time'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      progressId: json['progress_id'] as String?,
      reminderSent: json['reminder_sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'plan_week_id': planWeekId,
      'user_id': userId,
      'workout_id': workoutId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': scheduledTime,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'progress_id': progressId,
      'reminder_sent': reminderSent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'plan_id': planId,
      'plan_week_id': planWeekId,
      'user_id': userId,
      'workout_id': workoutId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': scheduledTime,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'progress_id': progressId,
      'reminder_sent': reminderSent,
    };
  }

  /// Check if workout is overdue
  bool get isOverdue =>
      !isCompleted && DateTime.now().isAfter(scheduledDate.add(const Duration(days: 1)));

  /// Check if workout is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }
}
