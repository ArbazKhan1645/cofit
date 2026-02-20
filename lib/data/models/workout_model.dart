/// Workout Model - Main workout content
/// Supabase Table: workouts
class WorkoutModel {
  final String id;
  final String trainerId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final int durationMinutes;
  final String difficulty; // beginner, intermediate, advanced
  final String category; // full_body, upper_body, lower_body, core, cardio, hiit, yoga, pilates
  final int caloriesBurned;
  final List<String> equipment; // mat, dumbbells, resistance_band, none
  final List<String> targetMuscles;
  final List<String> tags;
  final int weekNumber; // For weekly rotation (1-4)
  final int sortOrder;
  final bool isPremium;
  final bool isActive;
  final int totalCompletions;
  final double averageRating;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final TrainerModel? trainer;

  // Client-side flags (not stored in DB)
  final bool isCompleted;
  final bool isSaved;

  WorkoutModel({
    required this.id,
    required this.trainerId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.durationMinutes,
    required this.difficulty,
    required this.category,
    this.caloriesBurned = 0,
    this.equipment = const [],
    this.targetMuscles = const [],
    this.tags = const [],
    this.weekNumber = 1,
    this.sortOrder = 0,
    this.isPremium = false,
    this.isActive = true,
    this.totalCompletions = 0,
    this.averageRating = 0.0,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.trainer,
    this.isCompleted = false,
    this.isSaved = false,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      trainerId: json['trainer_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      category: json['category'] as String? ?? 'full_body',
      caloriesBurned: json['calories_burned'] as int? ?? 0,
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      targetMuscles: (json['target_muscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      weekNumber: json['week_number'] as int? ?? 1,
      sortOrder: json['sort_order'] as int? ?? 0,
      isPremium: json['is_premium'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      totalCompletions: json['total_completions'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      trainer: json['trainers'] != null
          ? TrainerModel.fromJson(json['trainers'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainer_id': trainerId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'duration_minutes': durationMinutes,
      'difficulty': difficulty,
      'category': category,
      'calories_burned': caloriesBurned,
      'equipment': equipment,
      'target_muscles': targetMuscles,
      'tags': tags,
      'week_number': weekNumber,
      'sort_order': sortOrder,
      'is_premium': isPremium,
      'is_active': isActive,
      'total_completions': totalCompletions,
      'average_rating': averageRating,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCacheJson() {
    final json = toJson();
    if (trainer != null) {
      json['trainers'] = trainer!.toJson();
    }
    return json;
  }

  WorkoutModel copyWith({
    String? id,
    String? trainerId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    int? durationMinutes,
    String? difficulty,
    String? category,
    int? caloriesBurned,
    List<String>? equipment,
    List<String>? targetMuscles,
    List<String>? tags,
    int? weekNumber,
    int? sortOrder,
    bool? isPremium,
    bool? isActive,
    int? totalCompletions,
    double? averageRating,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    TrainerModel? trainer,
    bool? isCompleted,
    bool? isSaved,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      equipment: equipment ?? this.equipment,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      tags: tags ?? this.tags,
      weekNumber: weekNumber ?? this.weekNumber,
      sortOrder: sortOrder ?? this.sortOrder,
      isPremium: isPremium ?? this.isPremium,
      isActive: isActive ?? this.isActive,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      averageRating: averageRating ?? this.averageRating,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trainer: trainer ?? this.trainer,
      isCompleted: isCompleted ?? this.isCompleted,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  /// Get trainer name from joined data or fallback
  String get trainerName => trainer?.fullName ?? 'Unknown Trainer';

  /// Get trainer avatar from joined data
  String? get trainerAvatar => trainer?.avatarUrl;

  /// Get difficulty color
  String get difficultyLabel {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return difficulty;
    }
  }

  /// Format duration as string
  String get formattedDuration {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '$durationMinutes min';
  }
}

/// Trainer Model - Fitness instructor profiles
/// Supabase Table: trainers
class TrainerModel {
  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final List<String> specialties;
  final List<String> certifications;
  final int yearsExperience;
  final String? instagramHandle;
  final String? websiteUrl;
  final bool isActive;
  final int totalWorkouts;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrainerModel({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.bio,
    this.specialties = const [],
    this.certifications = const [],
    this.yearsExperience = 0,
    this.instagramHandle,
    this.websiteUrl,
    this.isActive = true,
    this.totalWorkouts = 0,
    this.averageRating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      yearsExperience: json['years_experience'] as int? ?? 0,
      instagramHandle: json['instagram_handle'] as String?,
      websiteUrl: json['website_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      totalWorkouts: json['total_workouts'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'specialties': specialties,
      'certifications': certifications,
      'years_experience': yearsExperience,
      'instagram_handle': instagramHandle,
      'website_url': websiteUrl,
      'is_active': isActive,
      'total_workouts': totalWorkouts,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TrainerModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? bio,
    List<String>? specialties,
    List<String>? certifications,
    int? yearsExperience,
    String? instagramHandle,
    String? websiteUrl,
    bool? isActive,
    int? totalWorkouts,
    double? averageRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      certifications: certifications ?? this.certifications,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isActive: isActive ?? this.isActive,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Saved Workout Model - User's saved/bookmarked workouts
/// Supabase Table: saved_workouts
class SavedWorkoutModel {
  final String id;
  final String userId;
  final String workoutId;
  final DateTime savedAt;
  final String? note;
  final DateTime createdAt;

  // Joined data
  final WorkoutModel? workout;

  SavedWorkoutModel({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.savedAt,
    this.note,
    required this.createdAt,
    this.workout,
  });

  factory SavedWorkoutModel.fromJson(Map<String, dynamic> json) {
    return SavedWorkoutModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      workout: json['workouts'] != null
          ? WorkoutModel.fromJson(json['workouts'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
      'saved_at': savedAt.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'workout_id': workoutId,
      'saved_at': savedAt.toIso8601String(),
      'note': note,
    };
  }

  Map<String, dynamic> toCacheJson() {
    final json = toJson();
    if (workout != null) {
      json['workouts'] = workout!.toCacheJson();
    }
    return json;
  }
}

/// Workout Exercise Model - Individual exercises within a workout
/// Supabase Table: workout_exercises
class WorkoutExerciseModel {
  final String id;
  final String workoutId;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int orderIndex;
  final int durationSeconds;
  final int? reps;
  final int? sets;
  final int? restSeconds;
  final String exerciseType; // timed, reps, rest
  final String? variantId;
  final Map<String, dynamic> alternatives;
  final DateTime createdAt;

  WorkoutExerciseModel({
    required this.id,
    required this.workoutId,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    required this.orderIndex,
    required this.durationSeconds,
    this.reps,
    this.sets,
    this.restSeconds,
    required this.exerciseType,
    this.variantId,
    this.alternatives = const {},
    required this.createdAt,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
      orderIndex: json['order_index'] as int,
      durationSeconds: json['duration_seconds'] as int,
      reps: json['reps'] as int?,
      sets: json['sets'] as int?,
      restSeconds: json['rest_seconds'] as int?,
      exerciseType: json['exercise_type'] as String,
      variantId: json['variant_id'] as String?,
      alternatives:
          (json['alternatives'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'order_index': orderIndex,
      'duration_seconds': durationSeconds,
      'reps': reps,
      'sets': sets,
      'rest_seconds': restSeconds,
      'exercise_type': exerciseType,
      'variant_id': variantId,
      'alternatives': alternatives,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Workout Variant Model - Different versions of a workout for specific conditions
/// Supabase Table: workout_variants
class WorkoutVariantModel {
  final String id;
  final String workoutId;
  final String variantTag; // 'knee_safe', 'beginner', 'senior_safe'
  final String label; // 'Knee Safe Version'
  final String? description;
  final DateTime createdAt;

  WorkoutVariantModel({
    required this.id,
    required this.workoutId,
    required this.variantTag,
    required this.label,
    this.description,
    required this.createdAt,
  });

  factory WorkoutVariantModel.fromJson(Map<String, dynamic> json) {
    return WorkoutVariantModel(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      variantTag: json['variant_tag'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'variant_tag': variantTag,
      'label': label,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'workout_id': workoutId,
      'variant_tag': variantTag,
      'label': label,
      'description': description,
    };
  }

  WorkoutVariantModel copyWith({
    String? id,
    String? workoutId,
    String? variantTag,
    String? label,
    String? description,
    DateTime? createdAt,
  }) {
    return WorkoutVariantModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      variantTag: variantTag ?? this.variantTag,
      label: label ?? this.label,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
