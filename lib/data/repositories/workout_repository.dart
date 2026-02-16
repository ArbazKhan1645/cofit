import '../models/models.dart';
import 'base_repository.dart';

/// Workout Repository - Handles workout-related operations
class WorkoutRepository extends BaseRepository {
  // ============================================
  // WEEKLY SCHEDULE (User Side)
  // ============================================

  /// Get the active weekly schedule with all items + joined workouts
  Future<Result<WeeklyScheduleModel?>> getActiveSchedule() async {
    try {
      final response = await client
          .from('weekly_schedules')
          .select()
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return Result.success(null);
      return Result.success(WeeklyScheduleModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get schedule items for a specific schedule, with joined workout + trainer
  Future<Result<List<WeeklyScheduleItemModel>>> getScheduleItems(
      String scheduleId) async {
    try {
      final response = await client
          .from('weekly_schedule_items')
          .select('*, workouts(*, trainers(*))')
          .eq('schedule_id', scheduleId)
          .order('sort_order');

      final items = (response as List)
          .map((json) =>
              WeeklyScheduleItemModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(items);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get all saved workout IDs for the current user (for quick lookup)
  Future<Result<Set<String>>> getSavedWorkoutIds() async {
    try {
      if (userId == null) return Result.success({});

      final response = await client
          .from('saved_workouts')
          .select('workout_id')
          .eq('user_id', userId!);

      final ids = (response as List)
          .map((json) => json['workout_id'] as String)
          .toSet();

      return Result.success(ids);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // WORKOUTS
  // ============================================

  /// Get all active workouts with trainer data
  Future<Result<List<WorkoutModel>>> getAllWorkouts() async {
    try {
      final response = await client
          .from('workouts')
          .select('*, trainers(*)')
          .eq('is_active', true)
          .order('sort_order');

      final workouts = (response as List)
          .map((json) => WorkoutModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(workouts);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get weekly workouts (current rotation)
  Future<Result<List<WorkoutModel>>> getWeeklyWorkouts({int? weekNumber}) async {
    try {
      final query = client
          .from('workouts')
          .select('*, trainers(*)')
          .eq('is_active', true);

      if (weekNumber != null) {
        query.eq('week_number', weekNumber);
      }

      final response = await query.order('sort_order');

      final workouts = (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();

      return Result.success(workouts);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workout by ID
  Future<Result<WorkoutModel>> getWorkout(String workoutId) async {
    try {
      final response = await client
          .from('workouts')
          .select('*, trainers(*)')
          .eq('id', workoutId)
          .single();

      return Result.success(WorkoutModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workouts by category
  Future<Result<List<WorkoutModel>>> getWorkoutsByCategory(
      String category) async {
    try {
      final response = await client
          .from('workouts')
          .select('*, trainers(*)')
          .eq('is_active', true)
          .eq('category', category)
          .order('sort_order');

      final workouts = (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();

      return Result.success(workouts);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workouts by trainer
  Future<Result<List<WorkoutModel>>> getWorkoutsByTrainer(
      String trainerId) async {
    try {
      final response = await client
          .from('workouts')
          .select('*, trainers(*)')
          .eq('is_active', true)
          .eq('trainer_id', trainerId)
          .order('sort_order');

      final workouts = (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();

      return Result.success(workouts);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workout exercises
  Future<Result<List<WorkoutExerciseModel>>> getWorkoutExercises(
      String workoutId) async {
    try {
      final response = await client
          .from('workout_exercises')
          .select()
          .eq('workout_id', workoutId)
          .order('order_index');

      final exercises = (response as List)
          .map((json) => WorkoutExerciseModel.fromJson(json))
          .toList();

      return Result.success(exercises);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workout variants for a specific workout
  Future<Result<List<WorkoutVariantModel>>> getWorkoutVariants(
      String workoutId) async {
    try {
      final response = await client
          .from('workout_variants')
          .select()
          .eq('workout_id', workoutId)
          .order('created_at');

      final variants = (response as List)
          .map((json) =>
              WorkoutVariantModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(variants);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workout IDs completed today by the current user
  Future<Result<Set<String>>> getTodayCompletedWorkoutIds() async {
    try {
      if (userId == null) return Result.success({});

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final response = await client
          .from('user_progress')
          .select('workout_id')
          .eq('user_id', userId!)
          .gte('completed_at', todayStart.toIso8601String());

      final ids = (response as List)
          .map((json) => json['workout_id'] as String)
          .toSet();

      return Result.success(ids);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // SAVED WORKOUTS
  // ============================================

  /// Get user's saved workouts
  Future<Result<List<SavedWorkoutModel>>> getSavedWorkouts() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('saved_workouts')
          .select('*, workouts(*, trainers(*))')
          .eq('user_id', userId!)
          .order('saved_at', ascending: false);

      final saved = (response as List)
          .map((json) => SavedWorkoutModel.fromJson(json))
          .toList();

      return Result.success(saved);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Save a workout
  Future<Result<SavedWorkoutModel>> saveWorkout(String workoutId,
      {String? note}) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('saved_workouts')
          .insert({
            'user_id': userId!,
            'workout_id': workoutId,
            'saved_at': DateTime.now().toIso8601String(),
            'note': note,
          })
          .select('*, workouts(*, trainers(*))')
          .single();

      return Result.success(SavedWorkoutModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Unsave a workout
  Future<Result<void>> unsaveWorkout(String workoutId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('saved_workouts')
          .delete()
          .eq('user_id', userId!)
          .eq('workout_id', workoutId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Check if workout is saved
  Future<Result<bool>> isWorkoutSaved(String workoutId) async {
    try {
      if (userId == null) return Result.success(false);

      final response = await client
          .from('saved_workouts')
          .select('id')
          .eq('user_id', userId!)
          .eq('workout_id', workoutId)
          .maybeSingle();

      return Result.success(response != null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // WORKOUT PROGRESS
  // ============================================

  /// Log workout completion
  Future<Result<UserProgressModel>> logWorkoutCompletion({
    required String workoutId,
    required int durationMinutes,
    int caloriesBurned = 0,
    double completionPercentage = 1.0,
    int? heartRateAvg,
    int? heartRateMax,
    String? notes,
    int rating = 5,
    String? mood,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('user_progress')
          .insert({
            'user_id': userId!,
            'workout_id': workoutId,
            'completed_at': DateTime.now().toIso8601String(),
            'duration_minutes': durationMinutes,
            'calories_burned': caloriesBurned,
            'completion_percentage': completionPercentage,
            'heart_rate_avg': heartRateAvg,
            'heart_rate_max': heartRateMax,
            'notes': notes,
            'rating': rating,
            'mood': mood,
            'counted_for_streak': true,
          })
          .select('*, workouts(id, title, thumbnail_url, category)')
          .single();

      return Result.success(UserProgressModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get workout history
  Future<Result<List<UserProgressModel>>> getWorkoutHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('user_progress')
          .select('*, workouts(id, title, thumbnail_url, category)')
          .eq('user_id', userId!)
          .order('completed_at', ascending: false)
          .range(offset, offset + limit - 1);

      final history = (response as List)
          .map((json) => UserProgressModel.fromJson(json))
          .toList();

      return Result.success(history);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get recent completions for calendar
  Future<Result<List<DateTime>>> getWorkoutDates({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('user_progress')
          .select('completed_at')
          .eq('user_id', userId!)
          .gte('completed_at', startDate.toIso8601String())
          .lte('completed_at', endDate.toIso8601String());

      final dates = (response as List)
          .map((json) => DateTime.parse(json['completed_at'] as String))
          .toList();

      return Result.success(dates);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // WORKOUT RESUME PROGRESS (cross-device sync)
  // ============================================

  /// Upsert workout resume progress to Supabase
  Future<Result<void>> upsertResumeProgress({
    required String workoutId,
    required int currentExerciseIndex,
    required int completedExerciseCount,
    required int elapsedSeconds,
    required String date,
  }) async {
    try {
      if (userId == null) return Result.success(null);

      await client.from('workout_resume_progress').upsert(
        {
          'user_id': userId!,
          'workout_id': workoutId,
          'current_exercise_index': currentExerciseIndex,
          'completed_exercise_count': completedExerciseCount,
          'elapsed_seconds': elapsedSeconds,
          'date': date,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,workout_id,date',
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get resume progress for a workout (today only)
  Future<Result<Map<String, dynamic>?>> getResumeProgress(
      String workoutId) async {
    try {
      if (userId == null) return Result.success(null);

      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response = await client
          .from('workout_resume_progress')
          .select()
          .eq('user_id', userId!)
          .eq('workout_id', workoutId)
          .eq('date', today)
          .maybeSingle();

      return Result.success(response);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete resume progress for a workout
  Future<Result<void>> deleteResumeProgress(String workoutId) async {
    try {
      if (userId == null) return Result.success(null);

      await client
          .from('workout_resume_progress')
          .delete()
          .eq('user_id', userId!)
          .eq('workout_id', workoutId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // TRAINERS
  // ============================================

  /// Get all trainers
  Future<Result<List<TrainerModel>>> getTrainers() async {
    try {
      final response = await client
          .from('trainers')
          .select()
          .eq('is_active', true)
          .order('full_name');

      final trainers = (response as List)
          .map((json) => TrainerModel.fromJson(json))
          .toList();

      return Result.success(trainers);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get trainer by ID
  Future<Result<TrainerModel>> getTrainer(String trainerId) async {
    try {
      final response = await client
          .from('trainers')
          .select()
          .eq('id', trainerId)
          .single();

      return Result.success(TrainerModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }
}
