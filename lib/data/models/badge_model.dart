import 'package:flutter/material.dart';

/// Achievement Model - Achievement definitions created by admin
/// Supabase Table: achievements
class AchievementModel {
  final String id;
  final String name;
  final String description;
  final int iconCode; // Material Icon codePoint
  final String
  type; // workout_count, workout_minutes, streak_days, category_workouts, calories_burned, consecutive_days, first_workout, first_challenge, challenge_completions
  final int targetValue;
  final String targetUnit; // workouts, minutes, days, calories, challenges
  final String category; // workout, streak, milestone, community, special
  final String? targetCategory; // for category_workouts type (e.g. yoga, hiit)
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCode,
    required this.type,
    required this.targetValue,
    required this.targetUnit,
    required this.category,
    this.targetCategory,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get Flutter IconData from stored codePoint
  IconData getIconData() => IconData(iconCode, fontFamily: 'MaterialIcons');

  /// Human-readable type label
  String get typeLabel {
    switch (type) {
      case 'workout_count':
        return 'Workout Count';
      case 'workout_minutes':
        return 'Workout Minutes';
      case 'streak_days':
        return 'Streak Days';
      case 'category_workouts':
        return 'Category Workouts';
      case 'calories_burned':
        return 'Calories Burned';
      case 'consecutive_days':
        return 'Consecutive Days';
      case 'first_workout':
        return 'First Workout';
      case 'first_challenge':
        return 'First Challenge';
      case 'challenge_completions':
        return 'Challenge Completions';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  /// Human-readable category label
  String get categoryLabel {
    switch (category) {
      case 'workout':
        return 'Workout';
      case 'streak':
        return 'Streak';
      case 'milestone':
        return 'Milestone';
      case 'community':
        return 'Community';
      case 'special':
        return 'Special';
      default:
        return category;
    }
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconCode: json['icon_code'] as int? ?? 0xe5d2, // fitness_center default
      type: json['type'] as String? ?? 'workout_count',
      targetValue: json['target_value'] as int? ?? 1,
      targetUnit: json['target_unit'] as String? ?? 'workouts',
      category: json['category'] as String? ?? 'workout',
      targetCategory: json['target_category'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code': iconCode,
      'type': type,
      'target_value': targetValue,
      'target_unit': targetUnit,
      'category': category,
      'target_category': targetCategory,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AchievementModel copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCode,
    String? type,
    int? targetValue,
    String? targetUnit,
    String? category,
    String? targetCategory,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      category: category ?? this.category,
      targetCategory: targetCategory ?? this.targetCategory,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// User Achievement Model - Tracks user progress towards achievements
/// Supabase Table: user_achievements
class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final int currentProgress;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data (optional, populated from joins)
  final AchievementModel? achievement;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.achievement,
  });

  /// Whether user has started but not completed
  bool get isInProgress => !isCompleted && currentProgress > 0;

  /// Progress as percentage 0.0 - 1.0
  double get progressPercentage {
    if (achievement == null || achievement!.targetValue == 0) return 0.0;
    return (currentProgress / achievement!.targetValue).clamp(0.0, 1.0);
  }

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      currentProgress: json['current_progress'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      achievement: json['achievements'] != null
          ? AchievementModel.fromJson(
              json['achievements'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_id': achievementId,
      'current_progress': currentProgress,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cache-friendly JSON — includes joined achievement data
  Map<String, dynamic> toCacheJson() {
    final json = toJson();
    if (achievement != null) {
      json['achievements'] = achievement!.toJson();
    }
    return json;
  }

  UserAchievementModel copyWith({
    String? id,
    String? userId,
    String? achievementId,
    int? currentProgress,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    AchievementModel? achievement,
  }) {
    return UserAchievementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      achievement: achievement ?? this.achievement,
    );
  }
}

/// Achievement Stats Model - Computed analytics for admin detail view
class AchievementStatsModel {
  final int totalUsers;
  final int completedCount;
  final double avgProgress; // 0.0 - 1.0
  final int inProgressCount;

  AchievementStatsModel({
    required this.totalUsers,
    required this.completedCount,
    required this.avgProgress,
    required this.inProgressCount,
  });

  double get completionRate =>
      totalUsers > 0 ? completedCount / totalUsers : 0.0;
}
