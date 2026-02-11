import '../models/models.dart';
import 'base_repository.dart';

/// Workout Repository - Handles workout-related operations
class WorkoutRepository extends BaseRepository {
  // ============================================
  // WORKOUTS
  // ============================================

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
