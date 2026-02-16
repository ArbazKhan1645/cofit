import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../data/repositories/workout_repository.dart';

class WorkoutResumeData {
  final String workoutId;
  final int currentExerciseIndex;
  final int completedExerciseCount;
  final int elapsedSeconds;
  final String date; // yyyy-MM-dd — only valid for same day

  WorkoutResumeData({
    required this.workoutId,
    required this.currentExerciseIndex,
    required this.completedExerciseCount,
    required this.elapsedSeconds,
    required this.date,
  });

  factory WorkoutResumeData.fromJson(Map<String, dynamic> json) {
    return WorkoutResumeData(
      workoutId: json['workout_id'] as String,
      currentExerciseIndex: json['current_exercise_index'] as int,
      completedExerciseCount: json['completed_exercise_count'] as int,
      elapsedSeconds: json['elapsed_seconds'] as int,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workout_id': workoutId,
      'current_exercise_index': currentExerciseIndex,
      'completed_exercise_count': completedExerciseCount,
      'elapsed_seconds': elapsedSeconds,
      'date': date,
    };
  }
}

class WorkoutResumeService {
  final _storage = GetStorage();
  final WorkoutRepository _workoutRepo = WorkoutRepository();

  static String _key(String workoutId) => 'workout_resume_$workoutId';

  static String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Save progress locally (instant) + sync to Supabase in background
  void saveProgress({
    required String workoutId,
    required int exerciseIndex,
    required int completedCount,
    required int elapsedSeconds,
  }) {
    final date = _todayDate();
    try {
      final data = WorkoutResumeData(
        workoutId: workoutId,
        currentExerciseIndex: exerciseIndex,
        completedExerciseCount: completedCount,
        elapsedSeconds: elapsedSeconds,
        date: date,
      );
      // Save locally (instant)
      _storage.write(_key(workoutId), jsonEncode(data.toJson()));
    } catch (_) {}

    // Fire-and-forget Supabase sync
    _workoutRepo.upsertResumeProgress(
      workoutId: workoutId,
      currentExerciseIndex: exerciseIndex,
      completedExerciseCount: completedCount,
      elapsedSeconds: elapsedSeconds,
      date: date,
    );
  }

  /// Read resume data from local storage (instant, no network)
  WorkoutResumeData? getResumeData(String workoutId) {
    try {
      final cached = _storage.read<String>(_key(workoutId));
      if (cached == null) return null;

      final data = WorkoutResumeData.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );

      // Only valid for today
      if (data.date != _todayDate()) {
        clearResume(workoutId);
        return null;
      }

      return data;
    } catch (_) {
      return null;
    }
  }

  bool hasResumeData(String workoutId) {
    return getResumeData(workoutId) != null;
  }

  /// Clear resume locally + from Supabase
  void clearResume(String workoutId) {
    _storage.remove(_key(workoutId));
    // Fire-and-forget Supabase delete
    _workoutRepo.deleteResumeProgress(workoutId);
  }

  /// Sync from Supabase → local (call on workout detail load for cross-device)
  Future<void> syncFromSupabase(String workoutId) async {
    try {
      final result = await _workoutRepo.getResumeProgress(workoutId);
      result.fold(
        (error) {},
        (data) {
          if (data == null) return;

          final date = data['date'] as String;
          if (date != _todayDate()) return;

          final remoteData = WorkoutResumeData(
            workoutId: data['workout_id'] as String,
            currentExerciseIndex: data['current_exercise_index'] as int,
            completedExerciseCount: data['completed_exercise_count'] as int,
            elapsedSeconds: data['elapsed_seconds'] as int,
            date: date,
          );

          // Check if remote is more recent / further along than local
          final local = getResumeData(workoutId);
          if (local == null ||
              remoteData.completedExerciseCount >
                  local.completedExerciseCount) {
            _storage.write(
                _key(workoutId), jsonEncode(remoteData.toJson()));
          }
        },
      );
    } catch (_) {}
  }
}
