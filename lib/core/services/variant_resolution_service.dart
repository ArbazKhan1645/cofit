import '../../data/models/workout_model.dart';

class VariantResolutionResult {
  final WorkoutVariantModel? matchedVariant;
  final List<WorkoutExerciseModel> resolvedExercises;

  VariantResolutionResult({
    this.matchedVariant,
    required this.resolvedExercises,
  });
}

class VariantResolutionService {
  /// Resolve the correct exercise list for a user based on their physical limitations.
  ///
  /// Priority:
  /// 1. Find first variant whose variantTag matches any user limitation
  /// 2. Use that variant's exercises (variantId == variant.id)
  /// 3. If no match, use default exercises (variantId == null)
  /// 4. For each exercise, apply per-exercise alternatives from the alternatives map
  static VariantResolutionResult resolve({
    required List<String> userLimitations,
    required List<WorkoutVariantModel> variants,
    required List<WorkoutExerciseModel> allExercises,
  }) {
    // Step 1: Find matching variant
    WorkoutVariantModel? matchedVariant;
    for (final variant in variants) {
      if (userLimitations.contains(variant.variantTag)) {
        matchedVariant = variant;
        break;
      }
    }

    // Step 2: Filter exercises to the matching variant (or default)
    List<WorkoutExerciseModel> exercises;
    if (matchedVariant != null) {
      exercises = allExercises
          .where((e) => e.variantId == matchedVariant!.id)
          .toList();
      // Fallback: if variant has no exercises, use defaults
      if (exercises.isEmpty) {
        exercises =
            allExercises.where((e) => e.variantId == null).toList();
        matchedVariant = null;
      }
    } else {
      exercises =
          allExercises.where((e) => e.variantId == null).toList();
    }

    // Step 3: Sort by orderIndex
    exercises.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    // Step 4: Apply per-exercise alternatives
    final resolved = exercises.map((exercise) {
      return _applyAlternatives(exercise, userLimitations);
    }).toList();

    return VariantResolutionResult(
      matchedVariant: matchedVariant,
      resolvedExercises: resolved,
    );
  }

  /// Check if any user limitation has a matching key in exercise.alternatives.
  /// If so, create a modified copy with the alternative's data.
  static WorkoutExerciseModel _applyAlternatives(
    WorkoutExerciseModel exercise,
    List<String> userLimitations,
  ) {
    if (exercise.alternatives.isEmpty) return exercise;

    for (final limitation in userLimitations) {
      if (exercise.alternatives.containsKey(limitation)) {
        final alt = exercise.alternatives[limitation] as Map<String, dynamic>;
        return WorkoutExerciseModel(
          id: exercise.id,
          workoutId: exercise.workoutId,
          name: alt['name'] as String? ?? exercise.name,
          description: alt['description'] as String? ?? exercise.description,
          thumbnailUrl: exercise.thumbnailUrl,
          videoUrl: alt['video_url'] as String? ?? exercise.videoUrl,
          orderIndex: exercise.orderIndex,
          durationSeconds:
              alt['duration_seconds'] as int? ?? exercise.durationSeconds,
          reps: alt['reps'] as int? ?? exercise.reps,
          sets: alt['sets'] as int? ?? exercise.sets,
          restSeconds: exercise.restSeconds,
          exerciseType: exercise.exerciseType,
          variantId: exercise.variantId,
          alternatives: exercise.alternatives,
          createdAt: exercise.createdAt,
        );
      }
    }
    return exercise;
  }
}
