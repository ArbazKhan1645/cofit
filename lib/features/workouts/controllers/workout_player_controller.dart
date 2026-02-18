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

enum PlayerState { countdown, playing, paused, resting, completing, completed }

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

  // Active controller for currently playing exercise
  VideoPlayerController? videoController;

  // Video UI state
  final RxDouble videoProgress = 0.0.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isVideoError = false.obs;
  final RxInt videoRemainingSeconds = 0.obs;

  // Guards
  bool _exerciseFinishCalled = false;
  bool _disposed = false;

  // Timers
  Timer? _countdownTimer;
  Timer? _restTimer;
  Timer? _elapsedTimer;
  Timer? _exerciseTimer;

  final Stopwatch _stopwatch = Stopwatch();

  // ============================================
  // INIT / CLOSE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    workout = args['workout'] as WorkoutModel;
    exercises = args['exercises'] as List<WorkoutExerciseModel>;
    variant = args['variant'] as WorkoutVariantModel?;

    final resumeData = _resumeService.getResumeData(workout.id);
    if (resumeData != null &&
        resumeData.currentExerciseIndex < exercises.length) {
      currentExerciseIndex.value = resumeData.currentExerciseIndex;
      completedExerciseCount.value = resumeData.completedExerciseCount;

      int calculatedElapsed = 0;
      for (int i = 0; i < resumeData.currentExerciseIndex; i++) {
        final ex = exercises[i];
        if (ex.exerciseType == 'rest') {
          calculatedElapsed += ex.durationSeconds;
        } else {
          calculatedElapsed += ex.durationSeconds > 0 ? ex.durationSeconds : 30;
        }
        if (ex.restSeconds != null && ex.exerciseType != 'rest') {
          calculatedElapsed += ex.restSeconds!;
        }
      }
      elapsedSeconds.value = calculatedElapsed;
    }

    _startElapsedTimer();
    _startCountdown();
  }

  @override
  void onClose() {
    _disposed = true;
    _disposeTimers();
    videoController?.dispose();
    videoController = null;
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

  WorkoutExerciseModel get currentExercise =>
      exercises[currentExerciseIndex.value];
  bool get isLastExercise => currentExerciseIndex.value >= exercises.length - 1;

  void _startExercise() {
    final idx = currentExerciseIndex.value;
    final exercise = exercises[idx];

    playerState.value = PlayerState.playing;
    isVideoPlaying.value = false;
    videoProgress.value = 0.0;
    videoRemainingSeconds.value = 0;
    isVideoInitialized.value = false;
    isVideoError.value = false;
    _exerciseFinishCalled = false;

    if (exercise.exerciseType == 'rest') {
      _startExerciseCountdownTimer(exercise.durationSeconds);
      return;
    }

    if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) {
      _loadAndPlayVideo(idx, exercise);
    } else if (exercise.durationSeconds > 0) {
      _startExerciseCountdownTimer(exercise.durationSeconds);
    } else {
      _startExerciseCountdownTimer(30);
    }
  }

  // ============================================
  // VIDEO LOAD + PLAY
  // ============================================

  Future<void> _loadAndPlayVideo(int idx, WorkoutExerciseModel exercise) async {
    // Clean up any previous controller
    videoController?.dispose();
    videoController = null;
    isVideoInitialized.value = false;
    isVideoError.value = false;

    final url = exercise.videoUrl!;
    final vc = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await vc.initialize();

      // Guard: screen may have moved on (user went back, etc.)
      if (_disposed || currentExerciseIndex.value != idx) {
        vc.dispose();
        return;
      }

      videoController = vc;
      isVideoInitialized.value = true;

      // Reset progress AFTER initialization — duration is now known
      videoProgress.value = 0.0;
      videoRemainingSeconds.value = vc.value.duration.inSeconds;

      await vc.play();
      isVideoPlaying.value = true;

      // Start the listener-based progress tracker
      _attachVideoListener(vc, idx);
    } catch (e) {
      vc.dispose();
      isVideoError.value = true;
      // Fallback: 20-second timer so workout can continue
      _startExerciseCountdownTimer(20);
    }
  }

  // ============================================
  // VIDEO LISTENER — no polling, no Duration math
  //
  // Flutter's VideoPlayerController fires addListener on every frame.
  // We read position & duration directly from vc.value each callback.
  // Completion = position reached duration (with 300ms tolerance).
  // ============================================

  void _attachVideoListener(VideoPlayerController vc, int idx) {
    void listener() {
      // Stop if disposed or a different exercise is active
      if (_disposed ||
          currentExerciseIndex.value != idx ||
          videoController != vc) {
        vc.removeListener(listener);
        return;
      }

      final val = vc.value;
      if (!val.isInitialized) return;

      final durationMs = val.duration.inMilliseconds;
      final positionMs = val.position.inMilliseconds;

      // Duration must be settled (> 0) before we trust anything
      if (durationMs <= 0) return;

      // Update progress bar (0.0 → 1.0)
      final progress = (positionMs / durationMs).clamp(0.0, 1.0);
      videoProgress.value = progress;

      // Update remaining seconds display
      final remainingMs = (durationMs - positionMs).clamp(0, durationMs);
      videoRemainingSeconds.value = (remainingMs / 1000).ceil();

      // Update play/pause icon
      isVideoPlaying.value = val.isPlaying;

      // Completion: position within 300ms of end OR flutter marks it completed
      final isFinished = val.isCompleted || positionMs >= (durationMs - 300);

      if (!_exerciseFinishCalled && isFinished) {
        _exerciseFinishCalled = true;
        vc.removeListener(listener);
        _onExerciseFinished();
      }
    }

    vc.addListener(listener);
  }

  // ============================================
  // FALLBACK TIMER (no video / video error)
  // ============================================

  void _startExerciseCountdownTimer(int durationSeconds) {
    if (durationSeconds <= 0) durationSeconds = 30;
    int remaining = durationSeconds;
    videoRemainingSeconds.value = remaining;
    videoProgress.value = 0.0;

    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      videoRemainingSeconds.value = remaining.clamp(0, durationSeconds);
      videoProgress.value = 1.0 - (remaining / durationSeconds).clamp(0.0, 1.0);

      if (remaining <= 0) {
        timer.cancel();
        if (!_exerciseFinishCalled) {
          _exerciseFinishCalled = true;
          _onExerciseFinished();
        }
      }
    });
  }

  // ============================================
  // PLAY / PAUSE
  // ============================================

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
      // No video controller (timer-based exercise)
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
    _tearDownCurrentVideo();
    currentExerciseIndex.value--;
    _startCountdown();
  }

  // ============================================
  // EXERCISE TRANSITION
  // ============================================

  void _tearDownCurrentVideo() {
    _exerciseTimer?.cancel();
    videoController?.dispose();
    videoController = null;
    isVideoInitialized.value = false;
    isVideoError.value = false;
    videoRemainingSeconds.value = 0;
    videoProgress.value = 0.0;
    _exerciseFinishCalled = false;
  }

  void _onExerciseFinished() {
    videoController?.dispose();
    videoController = null;
    isVideoInitialized.value = false;
    isVideoError.value = false;
    videoRemainingSeconds.value = 0;
    completedExerciseCount.value++;

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

    Future.delayed(const Duration(seconds: 3), () {
      if (_disposed) return;
      playerState.value = PlayerState.completed;
      _logCompletion();
    });
  }

  Future<void> _logCompletion() async {
    _resumeService.clearResume(workout.id);
    final durationMinutes = (elapsedSeconds.value / 60).ceil();

    int retries = 0;
    const maxRetries = 3;
    bool saved = false;

    while (!saved && retries < maxRetries) {
      try {
        final result = await _workoutRepo.logWorkoutCompletion(
          workoutId: workout.id,
          durationMinutes: durationMinutes,
          caloriesBurned: workout.caloriesBurned,
          completionPercentage: 1.0,
        );

        result.fold(
          (error) async {
            retries++;
            if (retries < maxRetries) {
              await Future.delayed(Duration(milliseconds: 500 * retries));
            }
          },
          (_) {
            saved = true;
          },
        );
      } catch (e) {
        retries++;
        if (retries < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * retries));
        }
      }
    }

    if (Get.isRegistered<ProgressService>()) {
      unawaited(
        Get.find<ProgressService>().onWorkoutCompleted(
          workoutId: workout.id,
          workoutCategory: workout.category,
          durationMinutes: durationMinutes,
          caloriesBurned: workout.caloriesBurned,
        ),
      );
    }
  }

  Future<void> finishAndGoHome() async {
    if (playerState.value == PlayerState.completing) {
      await _logCompletion();
    }

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().onWorkoutCompleted(workout.id);
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
          'Your progress will be saved. You can resume this workout later today.',
        ),
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

  String get formattedRemaining {
    final total = elapsedSeconds.value;
    if (total <= 0) return '0:00';
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
