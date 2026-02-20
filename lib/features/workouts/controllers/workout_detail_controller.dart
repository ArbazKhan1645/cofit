import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/variant_resolution_service.dart';
import '../../../core/services/workout_resume_service.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../app/routes/app_routes.dart';

class WorkoutDetailController extends BaseController {
  final WorkoutRepository _workoutRepo = WorkoutRepository();
  final WorkoutResumeService _resumeService = WorkoutResumeService();

  late final WorkoutModel workout;
  final RxList<WorkoutExerciseModel> allExercises = <WorkoutExerciseModel>[].obs;
  final RxList<WorkoutVariantModel> variants = <WorkoutVariantModel>[].obs;
  final RxList<WorkoutExerciseModel> resolvedExercises =
      <WorkoutExerciseModel>[].obs;
  final Rx<WorkoutVariantModel?> activeVariant = Rx<WorkoutVariantModel?>(null);
  final RxBool isLoadingExercises = true.obs;

  // Resume data
  final Rx<WorkoutResumeData?> resumeData = Rx<WorkoutResumeData?>(null);

  // Saved / favorite state
  final RxBool isWorkoutSaved = false.obs;

  // Signal to pause preview video on navigation
  final RxBool shouldPausePreview = false.obs;

  @override
  void onInit() {
    super.onInit();
    workout = Get.arguments as WorkoutModel;
    _loadExercisesAndVariants();
    _loadSavedStatus();
  }

  Future<void> _loadExercisesAndVariants() async {
    isLoadingExercises.value = true;

    final results = await Future.wait([
      _workoutRepo.getWorkoutExercises(workout.id),
      _workoutRepo.getWorkoutVariants(workout.id),
    ]);

    results[0].fold(
      (error) {},
      (data) => allExercises.value = data as List<WorkoutExerciseModel>,
    );

    results[1].fold(
      (error) {},
      (data) => variants.value = data as List<WorkoutVariantModel>,
    );

    _resolveVariant();

    // Show local resume data instantly
    resumeData.value = _resumeService.getResumeData(workout.id);

    isLoadingExercises.value = false;

    // Sync resume from Supabase in background (cross-device support)
    _syncResumeFromSupabase();
  }

  void _resolveVariant() {
    final user = AuthService.to.currentUser;
    final userLimitations = user?.physicalLimitations ?? [];

    final result = VariantResolutionService.resolve(
      userLimitations: userLimitations,
      variants: variants,
      allExercises: allExercises,
    );

    activeVariant.value = result.matchedVariant;
    resolvedExercises.value = result.resolvedExercises;
  }

  /// Exercise count excluding rest-type exercises
  int get exerciseCount =>
      resolvedExercises.where((e) => e.exerciseType != 'rest').length;

  // ============================================
  // RESUME GETTERS
  // ============================================

  bool get hasResumeData => resumeData.value != null;

  int get completedExerciseCount =>
      resumeData.value?.completedExerciseCount ?? 0;

  int get resumeExerciseIndex =>
      resumeData.value?.currentExerciseIndex ?? 0;

  /// Sync resume data from Supabase then refresh local state
  Future<void> _syncResumeFromSupabase() async {
    await _resumeService.syncFromSupabase(workout.id);
    resumeData.value = _resumeService.getResumeData(workout.id);
  }

  /// Refresh resume data (called when returning from player)
  void refreshResumeData() {
    resumeData.value = _resumeService.getResumeData(workout.id);
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> startWorkout() async {
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      Get.snackbar(
        'No Internet',
        'You need an internet connection to start a workout.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    shouldPausePreview.value = true;
    Get.toNamed(
      AppRoutes.workoutPlayer,
      arguments: {
        'workout': workout,
        'exercises': resolvedExercises.toList(),
        'variant': activeVariant.value,
        if (hasResumeData) 'resumeData': resumeData.value,
      },
    )?.then((_) {
      shouldPausePreview.value = false;
      refreshResumeData();
    });
  }

  // ============================================
  // SAVED / FAVORITE
  // ============================================

  Future<void> _loadSavedStatus() async {
    final result = await _workoutRepo.isWorkoutSaved(workout.id);
    result.fold(
      (error) {},
      (saved) => isWorkoutSaved.value = saved,
    );
  }

  Future<void> toggleSaveWorkout() async {
    final wasSaved = isWorkoutSaved.value;
    // Optimistic update
    isWorkoutSaved.value = !wasSaved;

    final result = wasSaved
        ? await _workoutRepo.unsaveWorkout(workout.id)
        : await _workoutRepo.saveWorkout(workout.id);

    result.fold(
      (error) {
        // Revert on failure
        isWorkoutSaved.value = wasSaved;
      },
      (_) {},
    );
  }

  // ============================================
  // SHARE
  // ============================================

  void shareWorkout() {
    final text = '${workout.title} by ${workout.trainerName}\n'
        '${workout.durationMinutes} min • ${workout.difficulty}\n\n'
        'Check it out on CoFit Collective!';
    Share.share(text);
  }
}
