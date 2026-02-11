/// User Progress Model - Daily workout log/progress entry
/// Supabase Table: user_progress
class UserProgressModel {
  final String id;
  final String userId;
  final String workoutId;
  final DateTime completedAt;
  final int durationMinutes;
  final int caloriesBurned;
  final double completionPercentage; // 0.0 to 1.0
  final int? heartRateAvg;
  final int? heartRateMax;
  final String? notes;
  final int rating; // 1-5 stars
  final String? mood; // energized, tired, motivated, etc.
  final bool countedForStreak;
  final DateTime createdAt;

  // Joined data
  final WorkoutSummary? workout;

  UserProgressModel({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.completedAt,
    required this.durationMinutes,
    this.caloriesBurned = 0,
    this.completionPercentage = 1.0,
    this.heartRateAvg,
    this.heartRateMax,
    this.notes,
    this.rating = 5,
    this.mood,
    this.countedForStreak = true,
    required this.createdAt,
    this.workout,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      caloriesBurned: json['calories_burned'] as int? ?? 0,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 1.0,
      heartRateAvg: json['heart_rate_avg'] as int?,
      heartRateMax: json['heart_rate_max'] as int?,
      notes: json['notes'] as String?,
      rating: json['rating'] as int? ?? 5,
      mood: json['mood'] as String?,
      countedForStreak: json['counted_for_streak'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      workout: json['workouts'] != null
          ? WorkoutSummary.fromJson(json['workouts'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
      'completed_at': completedAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'completion_percentage': completionPercentage,
      'heart_rate_avg': heartRateAvg,
      'heart_rate_max': heartRateMax,
      'notes': notes,
      'rating': rating,
      'mood': mood,
      'counted_for_streak': countedForStreak,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'workout_id': workoutId,
      'completed_at': completedAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'completion_percentage': completionPercentage,
      'heart_rate_avg': heartRateAvg,
      'heart_rate_max': heartRateMax,
      'notes': notes,
      'rating': rating,
      'mood': mood,
      'counted_for_streak': countedForStreak,
    };
  }

  UserProgressModel copyWith({
    String? id,
    String? userId,
    String? workoutId,
    DateTime? completedAt,
    int? durationMinutes,
    int? caloriesBurned,
    double? completionPercentage,
    int? heartRateAvg,
    int? heartRateMax,
    String? notes,
    int? rating,
    String? mood,
    bool? countedForStreak,
    DateTime? createdAt,
    WorkoutSummary? workout,
  }) {
    return UserProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutId: workoutId ?? this.workoutId,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      mood: mood ?? this.mood,
      countedForStreak: countedForStreak ?? this.countedForStreak,
      createdAt: createdAt ?? this.createdAt,
      workout: workout ?? this.workout,
    );
  }
}

/// Workout Summary - Minimal workout info for joins
class WorkoutSummary {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String category;

  WorkoutSummary({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.category,
  });

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      category: json['category'] as String,
    );
  }
}

/// Month Progress Model - Aggregated monthly statistics
/// Supabase Table: month_progress
class MonthProgressModel {
  final String id;
  final String userId;
  final int year;
  final int month; // 1-12
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;
  final int longestStreak;
  final int daysActive;
  final double averageRating;
  final double averageCompletion;
  final Map<String, int> workoutsByCategory; // category -> count
  final Map<String, int> workoutsByDay; // day of week -> count
  final DateTime createdAt;
  final DateTime updatedAt;

  MonthProgressModel({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
    this.totalWorkouts = 0,
    this.totalMinutes = 0,
    this.totalCalories = 0,
    this.longestStreak = 0,
    this.daysActive = 0,
    this.averageRating = 0.0,
    this.averageCompletion = 0.0,
    this.workoutsByCategory = const {},
    this.workoutsByDay = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthProgressModel.fromJson(Map<String, dynamic> json) {
    return MonthProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      totalWorkouts: json['total_workouts'] as int? ?? 0,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      totalCalories: json['total_calories'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      daysActive: json['days_active'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      averageCompletion: (json['average_completion'] as num?)?.toDouble() ?? 0.0,
      workoutsByCategory: (json['workouts_by_category'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      workoutsByDay: (json['workouts_by_day'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'year': year,
      'month': month,
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'total_calories': totalCalories,
      'longest_streak': longestStreak,
      'days_active': daysActive,
      'average_rating': averageRating,
      'average_completion': averageCompletion,
      'workouts_by_category': workoutsByCategory,
      'workouts_by_day': workoutsByDay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'year': year,
      'month': month,
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'total_calories': totalCalories,
      'longest_streak': longestStreak,
      'days_active': daysActive,
      'average_rating': averageRating,
      'average_completion': averageCompletion,
      'workouts_by_category': workoutsByCategory,
      'workouts_by_day': workoutsByDay,
    };
  }

  MonthProgressModel copyWith({
    String? id,
    String? userId,
    int? year,
    int? month,
    int? totalWorkouts,
    int? totalMinutes,
    int? totalCalories,
    int? longestStreak,
    int? daysActive,
    double? averageRating,
    double? averageCompletion,
    Map<String, int>? workoutsByCategory,
    Map<String, int>? workoutsByDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      month: month ?? this.month,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      totalCalories: totalCalories ?? this.totalCalories,
      longestStreak: longestStreak ?? this.longestStreak,
      daysActive: daysActive ?? this.daysActive,
      averageRating: averageRating ?? this.averageRating,
      averageCompletion: averageCompletion ?? this.averageCompletion,
      workoutsByCategory: workoutsByCategory ?? this.workoutsByCategory,
      workoutsByDay: workoutsByDay ?? this.workoutsByDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Get total hours worked out
  double get totalHours => totalMinutes / 60.0;
}

/// Weekly Progress Summary - For dashboard display
class WeeklyProgressSummary {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;
  final int currentStreak;
  final List<DailyProgress> dailyProgress;

  WeeklyProgressSummary({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCalories,
    required this.currentStreak,
    required this.dailyProgress,
  });

  factory WeeklyProgressSummary.fromDailyProgress(List<DailyProgress> progress) {
    return WeeklyProgressSummary(
      totalWorkouts: progress.fold(0, (sum, d) => sum + d.workoutsCompleted),
      totalMinutes: progress.fold(0, (sum, d) => sum + d.minutesWorkedOut),
      totalCalories: progress.fold(0, (sum, d) => sum + d.caloriesBurned),
      currentStreak: _calculateStreak(progress),
      dailyProgress: progress,
    );
  }

  static int _calculateStreak(List<DailyProgress> progress) {
    int streak = 0;
    final sortedProgress = List<DailyProgress>.from(progress)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final day in sortedProgress) {
      if (day.workoutsCompleted > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

/// Daily Progress - Single day's activity
class DailyProgress {
  final DateTime date;
  final int workoutsCompleted;
  final int minutesWorkedOut;
  final int caloriesBurned;

  DailyProgress({
    required this.date,
    this.workoutsCompleted = 0,
    this.minutesWorkedOut = 0,
    this.caloriesBurned = 0,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date'] as String),
      workoutsCompleted: json['workouts_completed'] as int? ?? 0,
      minutesWorkedOut: json['minutes_worked_out'] as int? ?? 0,
      caloriesBurned: json['calories_burned'] as int? ?? 0,
    );
  }

  bool get hasActivity => workoutsCompleted > 0;
}
