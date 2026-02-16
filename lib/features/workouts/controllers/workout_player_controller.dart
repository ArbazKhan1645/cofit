import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/services/workout_resume_service.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';

enum PlayerState {
  countdown,
  playing,
  paused,
  resting,
  completing,
  completed,
}

class WorkoutPlayerController extends GetxController {
  final WorkoutRepository _workoutRepo = WorkoutRepository();
  final WorkoutResumeService _resumeService = WorkoutResumeService();

  // From arguments
  late final WorkoutModel workout;
  late final List<WorkoutExerciseModel> exercises;
  late final WorkoutVariantModel? variant;

  // Core state
  final Rx<PlayerState> playerState = PlayerState.countdown.obs;
  final RxInt currentExerciseIndex = 0.obs;
  final RxInt countdownValue = 3.obs;
  final RxInt restTimeRemaining = 0.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxInt completedExerciseCount = 0.obs;

  // Video
  VideoPlayerController? videoController;
  final RxDouble videoProgress = 0.0.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxBool isVideoInitialized = false.obs;

  // Timers
  Timer? _countdownTimer;
  Timer? _restTimer;
  Timer? _elapsedTimer;
  Timer? _exerciseTimer;

  // Stopwatch for total elapsed
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    workout = args['workout'] as WorkoutModel;
    exercises = args['exercises'] as List<WorkoutExerciseModel>;
    variant = args['variant'] as WorkoutVariantModel?;

    // Check for resume data
    final resumeData = _resumeService.getResumeData(workout.id);
    if (resumeData != null && resumeData.currentExerciseIndex < exercises.length) {
      currentExerciseIndex.value = resumeData.currentExerciseIndex;
      completedExerciseCount.value = resumeData.completedExerciseCount;
      // Restore elapsed time
      _stopwatch.reset();
      // We can't set stopwatch directly, so track offset
      elapsedSeconds.value = resumeData.elapsedSeconds;
    }

    _startElapsedTimer();
    _startCountdown();
  }

  @override
  void onClose() {
    _disposeTimers();
    videoController?.dispose();
    _stopwatch.stop();
    super.onClose();
  }

  void _disposeTimers() {
    _countdownTimer?.cancel();
    _restTimer?.cancel();
    _elapsedTimer?.cancel();
    _exerciseTimer?.cancel();
  }

  // ============================================
  // ELAPSED TIMER
  // ============================================

  int _elapsedOffset = 0;

  void _startElapsedTimer() {
    _elapsedOffset = elapsedSeconds.value;
    _stopwatch.start();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value = _elapsedOffset + _stopwatch.elapsed.inSeconds;
    });
  }

  // ============================================
  // COUNTDOWN (3, 2, 1, GO!)
  // ============================================

  void _startCountdown() {
    playerState.value = PlayerState.countdown;
    countdownValue.value = 3;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdownValue.value--;
      if (countdownValue.value <= 0) {
        timer.cancel();
        _startExercise();
      }
    });
  }

  // ============================================
  // EXERCISE PLAYBACK
  // ============================================

  WorkoutExerciseModel get currentExercise => exercises[currentExerciseIndex.value];
  bool get isLastExercise => currentExerciseIndex.value >= exercises.length - 1;

  void _startExercise() {
    final exercise = currentExercise;
    playerState.value = PlayerState.playing;
    isVideoPlaying.value = true;
    videoProgress.value = 0.0;
    isVideoInitialized.value = false;

    if (exercise.exerciseType == 'rest') {
      // Rest-type exercises are just countdown timers
      _startExerciseCountdownTimer(exercise.durationSeconds);
      return;
    }

    // Video-first: always try video URL regardless of exercise type
    if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) {
      _initializeVideo(exercise.videoUrl!);
    } else if (exercise.durationSeconds > 0) {
      // No video — use timer-based exercise
      _startExerciseCountdownTimer(exercise.durationSeconds);
    } else {
      // Reps with no video and no duration: auto-complete after 30 seconds
      _startExerciseCountdownTimer(30);
    }
  }

  Future<void> _initializeVideo(String url) async {
    videoController?.dispose();
    videoController = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await videoController!.initialize();
      isVideoInitialized.value = true;
      videoController!.play();

      videoController!.addListener(_onVideoUpdate);
    } catch (_) {
      // Fallback to timer if video fails
      final duration = currentExercise.durationSeconds;
      _startExerciseCountdownTimer(duration > 0 ? duration : 30);
    }
  }

  void _onVideoUpdate() {
    final vc = videoController;
    if (vc == null || !vc.value.isInitialized) return;

    final duration = vc.value.duration;
    final position = vc.value.position;

    if (duration.inMilliseconds > 0) {
      videoProgress.value =
          (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    }

    isVideoPlaying.value = vc.value.isPlaying;

    // Check if video completed
    if (position >= duration && duration.inMilliseconds > 0) {
      vc.removeListener(_onVideoUpdate);
      _onExerciseFinished();
    }
  }

  void _startExerciseCountdownTimer(int durationSeconds) {
    if (durationSeconds <= 0) {
      durationSeconds = 30; // Safety fallback
    }
    int remaining = durationSeconds;
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      videoProgress.value =
          1.0 - (remaining / durationSeconds).clamp(0.0, 1.0);
      if (remaining <= 0) {
        timer.cancel();
        _onExerciseFinished();
      }
    });
  }

  void togglePlayPause() {
    final vc = videoController;
    if (vc != null && vc.value.isInitialized) {
      if (vc.value.isPlaying) {
        vc.pause();
        playerState.value = PlayerState.paused;
        _stopwatch.stop();
      } else {
        vc.play();
        playerState.value = PlayerState.playing;
        _stopwatch.start();
      }
      isVideoPlaying.value = vc.value.isPlaying;
    } else {
      // Timer-based exercise toggle
      if (playerState.value == PlayerState.paused) {
        playerState.value = PlayerState.playing;
        _stopwatch.start();
      } else if (playerState.value == PlayerState.playing) {
        playerState.value = PlayerState.paused;
        _stopwatch.stop();
      }
    }
  }

  // ============================================
  // GO TO PREVIOUS EXERCISE
  // ============================================

  bool get canGoBack => currentExerciseIndex.value > 0;

  void goToPreviousExercise() {
    if (!canGoBack) return;

    // Dispose current playback
    _exerciseTimer?.cancel();
    videoController?.removeListener(_onVideoUpdate);
    videoController?.pause();
    videoController?.dispose();
    videoController = null;
    isVideoInitialized.value = false;

    currentExerciseIndex.value--;
    _startCountdown();
  }

  // ============================================
  // EXERCISE TRANSITION
  // ============================================

  void _onExerciseFinished() {
    videoController?.dispose();
    videoController = null;
    isVideoInitialized.value = false;
    completedExerciseCount.value++;

    // Save resume progress
    _resumeService.saveProgress(
      workoutId: workout.id,
      exerciseIndex: currentExerciseIndex.value + 1,
      completedCount: completedExerciseCount.value,
      elapsedSeconds: elapsedSeconds.value,
    );

    if (isLastExercise) {
      _startCompleting();
      return;
    }

    // Always go through rest state before next exercise
    final exercise = currentExercise;
    final restSeconds = exercise.restSeconds ?? 0;
    _startRestTimer(restSeconds > 0 ? restSeconds : 5);
  }

  void _startRestTimer(int seconds) {
    playerState.value = PlayerState.resting;
    restTimeRemaining.value = seconds;

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      restTimeRemaining.value--;
      if (restTimeRemaining.value <= 0) {
        timer.cancel();
        _goToNextExercise();
      }
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    _goToNextExercise();
  }

  void _goToNextExercise() {
    currentExerciseIndex.value++;
    _startCountdown();
  }

  // ============================================
  // COMPLETION
  // ============================================

  void _startCompleting() {
    playerState.value = PlayerState.completing;
    _stopwatch.stop();
    _elapsedTimer?.cancel();

    // Show animation for 3 seconds then move to completed
    Future.delayed(const Duration(seconds: 3), () {
      playerState.value = PlayerState.completed;
      _logCompletion();
    });
  }

  Future<void> _logCompletion() async {
    // Clear resume data on full completion
    _resumeService.clearResume(workout.id);

    final durationMinutes = (elapsedSeconds.value / 60).ceil();
    await _workoutRepo.logWorkoutCompletion(
      workoutId: workout.id,
      durationMinutes: durationMinutes,
      caloriesBurned: workout.caloriesBurned,
      completionPercentage: 1.0,
    );

    // Trigger progress tracking pipeline (fire-and-forget)
    if (Get.isRegistered<ProgressService>()) {
      unawaited(Get.find<ProgressService>().onWorkoutCompleted(
        workoutId: workout.id,
        workoutCategory: workout.category,
        durationMinutes: durationMinutes,
        caloriesBurned: workout.caloriesBurned,
      ));
    }
  }

  void finishAndGoHome() {
    // Notify HomeController
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().onWorkoutCompleted(workout.id);
    }
    Get.until((route) => route.settings.name == AppRoutes.main);
  }

  // ============================================
  // EXIT EARLY
  // ============================================

  Future<bool> exitWorkout() async {
    if (playerState.value == PlayerState.completed) {
      finishAndGoHome();
      return true;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text(
            'Your progress will be saved. You can resume this workout later today.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _stopwatch.stop();
      _disposeTimers();

      // Save progress for resume (don't clear)
      _resumeService.saveProgress(
        workoutId: workout.id,
        exerciseIndex: currentExerciseIndex.value,
        completedCount: completedExerciseCount.value,
        elapsedSeconds: elapsedSeconds.value,
      );

      Get.back();
      return true;
    }
    return false;
  }

  // ============================================
  // HELPERS
  // ============================================

  String get formattedElapsed {
    final total = elapsedSeconds.value;
    final m = total ~/ 60;
    final s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  WorkoutExerciseModel? get nextExercise {
    final nextIdx = currentExerciseIndex.value + 1;
    if (nextIdx < exercises.length) return exercises[nextIdx];
    return null;
  }
}
