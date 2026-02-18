import 'dart:io';

import 'package:get/get.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/services/today_workout_cache_service.dart';
import '../../../core/services/variant_resolution_service.dart';
import '../../../data/models/challenge_model.dart';
import '../../../data/models/weekly_schedule_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/repositories/challenge_repository.dart';
import '../../../data/repositories/workout_repository.dart';

class HomeController extends BaseController {
  final AuthService _authService = AuthService.to;
  final ChallengeRepository _challengeRepo = ChallengeRepository();
  final WorkoutRepository _workoutRepo = WorkoutRepository();
  final _todayCache = TodayWorkoutCacheService();

  // User data
  final RxString userName = ''.obs;
  final RxInt workoutsThisWeek = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt totalWorkoutsThisMonth = 0.obs;
  final RxInt minutesThisWeek = 0.obs;

  // Today's workouts
  final Rx<WeeklyScheduleModel?> activeSchedule = Rx<WeeklyScheduleModel?>(
    null,
  );
  final RxList<WeeklyScheduleItemModel> todayItems =
      <WeeklyScheduleItemModel>[].obs;
  final RxSet<String> completedTodayIds = <String>{}.obs;
  final RxBool isLoadingSchedule = false.obs;

  // Current workout exercises (resolved by variant)
  final RxList<WorkoutExerciseModel> resolvedExercises =
      <WorkoutExerciseModel>[].obs;
  final Rx<WorkoutVariantModel?> activeVariant = Rx<WorkoutVariantModel?>(null);
  final RxBool isLoadingExercises = false.obs;
  String? _lastLoadedWorkoutId;

  // Challenges preview for home dashboard
  final RxList<UserChallengeModel> myChallenges = <UserChallengeModel>[].obs;
  final RxList<ChallengeModel> activeChallenges = <ChallengeModel>[].obs;
  final RxBool isLoadingChallenges = false.obs;

  // Hot workouts fallback (shown when all today's workouts are done)
  final RxList<WorkoutModel> hotWorkouts = <WorkoutModel>[].obs;

  // Saved workout IDs (for fav toggle)
  final RxSet<String> savedWorkoutIds = <String>{}.obs;

  Future<void> oninitialized() async {
    loadUserData();
    loadWorkoutStats();
    loadTodayWorkouts();
    loadHomeChallenges();
    loadHotWorkouts();
    _loadSavedWorkoutIds();
    // React to ProgressService changes
    if (Get.isRegistered<ProgressService>()) {
      final ps = Get.find<ProgressService>();
      ever(
        ps.workoutsThisWeek,
        (_) => workoutsThisWeek.value = ps.workoutsThisWeek.value,
      );
      ever(
        ps.currentStreak,
        (_) => currentStreak.value = ps.currentStreak.value,
      );
      ever(
        ps.totalWorkoutsThisMonth,
        (_) => totalWorkoutsThisMonth.value = ps.totalWorkoutsThisMonth.value,
      );
      ever(
        ps.minutesThisWeek,
        (_) => minutesThisWeek.value = ps.minutesThisWeek.value,
      );
    }
    // React to user changes from AuthService
    ever(_authService.currentUserRx, (_) {
      loadUserData();
      loadWorkoutStats();
      loadTodayWorkouts();
      loadHomeChallenges();
    });
  }

  void loadUserData() {
    final user = _authService.currentUser;
    userName.value = user?.displayName ?? 'Fitness Friend';
  }

  void loadWorkoutStats() {
    if (Get.isRegistered<ProgressService>()) {
      final ps = Get.find<ProgressService>();
      currentStreak.value = ps.currentStreak.value;
      workoutsThisWeek.value = ps.workoutsThisWeek.value;
      totalWorkoutsThisMonth.value = ps.totalWorkoutsThisMonth.value;
      minutesThisWeek.value = ps.minutesThisWeek.value;
    } else {
      final user = _authService.currentUser;
      currentStreak.value = user?.currentStreak ?? 0;
    }
  }

  // ============================================
  // CONNECTIVITY
  // ============================================

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // ============================================
  // TODAY'S WORKOUTS
  // ============================================

  Future<void> loadTodayWorkouts() async {
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      // Offline: use cached data
      final cachedSchedule = _todayCache.getCachedSchedule();
      final cachedItems = _todayCache.getCachedItems();
      if (cachedSchedule != null && cachedItems != null) {
        activeSchedule.value = cachedSchedule;
        _filterTodayItems(cachedItems);
      }
      return;
    }

    // 1. Load completed IDs FIRST — so cache rendering knows which are done
    final completedResult = await _workoutRepo.getTodayCompletedWorkoutIds();
    completedResult.fold((error) {}, (ids) {
      completedTodayIds.clear();
      completedTodayIds.addAll(ids);
      completedTodayIds.refresh();
    });

    // 2. Show cached data for instant display (now completedTodayIds is populated)
    final cachedSchedule = _todayCache.getCachedSchedule();
    final cachedItems = _todayCache.getCachedItems();
    if (cachedSchedule != null && cachedItems != null) {
      activeSchedule.value = cachedSchedule;
      _filterTodayItems(cachedItems);
    } else {
      isLoadingSchedule.value = true;
    }

    // 3. Fetch fresh schedule from network
    final scheduleResult = await _workoutRepo.getActiveSchedule();
    WeeklyScheduleModel? schedule;
    scheduleResult.fold((error) {}, (data) => schedule = data);

    activeSchedule.value = schedule;

    if (schedule != null) {
      _todayCache.cacheSchedule(schedule!);
      final itemsResult = await _workoutRepo.getScheduleItems(schedule!.id);
      itemsResult.fold((error) {}, (items) {
        _todayCache.cacheItems(items);
        _filterTodayItems(items);
      });
    }

    isLoadingSchedule.value = false;
  }

  void _filterTodayItems(List<WeeklyScheduleItemModel> allItems) {
    // DateTime.weekday: 1=Monday, 7=Sunday → convert to 0=Monday, 6=Sunday
    final todayIndex = DateTime.now().weekday - 1;
    todayItems.value =
        allItems
            .where(
              (item) => item.dayOfWeek == todayIndex && item.workout != null,
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    // Load exercises for the current workout
    _loadCurrentWorkoutExercises();
  }

  /// Load exercises + variants for current workout, resolve by user health
  Future<void> _loadCurrentWorkoutExercises() async {
    final workout = currentWorkout;
    if (workout == null) {
      resolvedExercises.clear();
      activeVariant.value = null;
      _lastLoadedWorkoutId = null;
      return;
    }

    // Skip reload if same workout exercises are already loaded
    if (_lastLoadedWorkoutId == workout.id && resolvedExercises.isNotEmpty) {
      return;
    }

    // Only show loading spinner on initial load (no existing data)
    final isInitialLoad = resolvedExercises.isEmpty;
    if (isInitialLoad) {
      isLoadingExercises.value = true;
    }

    _lastLoadedWorkoutId = workout.id;

    final results = await Future.wait([
      _workoutRepo.getWorkoutExercises(workout.id),
      _workoutRepo.getWorkoutVariants(workout.id),
    ]);

    List<WorkoutExerciseModel> allExercises = [];
    List<WorkoutVariantModel> variants = [];

    results[0].fold(
      (error) {},
      (data) => allExercises = data as List<WorkoutExerciseModel>,
    );

    results[1].fold(
      (error) {},
      (data) => variants = data as List<WorkoutVariantModel>,
    );

    final user = _authService.currentUser;
    final userLimitations = user?.physicalLimitations ?? [];

    final result = VariantResolutionService.resolve(
      userLimitations: userLimitations,
      variants: variants,
      allExercises: allExercises,
    );

    activeVariant.value = result.matchedVariant;
    resolvedExercises.value = result.resolvedExercises;
    isLoadingExercises.value = false;
  }

  /// The current workout (first non-completed)
  WorkoutModel? get currentWorkout {
    for (final item in todayItems) {
      if (!completedTodayIds.contains(item.workoutId) && item.workout != null) {
        return item.workout;
      }
    }
    return null;
  }

  /// Up-next workouts (remaining after currentWorkout, excluding completed)
  List<WorkoutModel> get upNextWorkouts {
    bool passedCurrent = false;
    final result = <WorkoutModel>[];
    for (final item in todayItems) {
      if (!completedTodayIds.contains(item.workoutId) && item.workout != null) {
        if (!passedCurrent) {
          passedCurrent = true;
          continue;
        }
        result.add(item.workout!);
      }
    }
    return result;
  }

  /// Whether today is a rest day
  bool get isTodayRestDay {
    if (activeSchedule.value == null) return false;
    return activeSchedule.value!.isDayDisabled(DateTime.now().weekday - 1);
  }

  /// Workouts completed today (for "completed" section)
  List<WorkoutModel> get completedTodayWorkouts {
    return todayItems
        .where(
          (item) =>
              completedTodayIds.contains(item.workoutId) &&
              item.workout != null,
        )
        .map((item) => item.workout!)
        .toList();
  }

  /// Whether all today's workouts are completed
  bool get allTodayCompleted {
    if (todayItems.isEmpty) return false;
    return todayItems.every(
      (item) => completedTodayIds.contains(item.workoutId),
    );
  }

  /// The last completed workout (for "all done" banner)
  WorkoutModel? get lastCompletedWorkout {
    if (!allTodayCompleted) return null;
    // Return the last item's workout
    for (int i = todayItems.length - 1; i >= 0; i--) {
      if (todayItems[i].workout != null) {
        return todayItems[i].workout;
      }
    }
    return null;
  }

  /// Called after a workout is completed to refresh the home view
  Future<void> onWorkoutCompleted(String workoutId) async {
    completedTodayIds.add(workoutId);
    completedTodayIds.refresh();
    loadWorkoutStats();
    _loadCurrentWorkoutExercises();

    // Persist to Supabase so it survives app restart
    // Note: The actual workout completion logging happens in WorkoutPlayerController._logCompletion()
    // This just ensures the UI is updated. The completion is already saved to Supabase by the player.
  }

  /// Exercise count excluding rest-type exercises
  int get exerciseCount =>
      resolvedExercises.where((e) => e.exerciseType != 'rest').length;

  // ============================================
  // HOT WORKOUTS (fallback when all done)
  // ============================================

  Future<void> loadHotWorkouts() async {
    final result = await _workoutRepo.getAllWorkouts();
    result.fold((error) {}, (workouts) {
      final shuffled = List<WorkoutModel>.from(workouts)..shuffle();
      hotWorkouts.value = shuffled.take(5).toList();
    });
  }

  // ============================================
  // SAVED / FAVORITE WORKOUTS
  // ============================================

  Future<void> _loadSavedWorkoutIds() async {
    final result = await _workoutRepo.getSavedWorkoutIds();
    result.fold((error) {}, (ids) {
      savedWorkoutIds.clear();
      savedWorkoutIds.addAll(ids);
    });
  }

  bool isWorkoutSaved(String workoutId) => savedWorkoutIds.contains(workoutId);

  Future<void> toggleSaveWorkout(String workoutId) async {
    if (savedWorkoutIds.contains(workoutId)) {
      // Optimistic remove
      savedWorkoutIds.remove(workoutId);
      savedWorkoutIds.refresh();
      final result = await _workoutRepo.unsaveWorkout(workoutId);
      result.fold((error) {
        // Revert on failure
        savedWorkoutIds.add(workoutId);
        savedWorkoutIds.refresh();
      }, (_) {});
    } else {
      // Optimistic add
      savedWorkoutIds.add(workoutId);
      savedWorkoutIds.refresh();
      final result = await _workoutRepo.saveWorkout(workoutId);
      result.fold((error) {
        // Revert on failure
        savedWorkoutIds.remove(workoutId);
        savedWorkoutIds.refresh();
      }, (_) {});
    }
  }

  // ============================================
  // CHALLENGES
  // ============================================

  Future<void> loadHomeChallenges() async {
    isLoadingChallenges.value = true;

    final results = await Future.wait([
      _challengeRepo.getMyActiveChallenges(),
      _challengeRepo.getActiveChallenges(),
    ]);

    results[0].fold(
      (error) {},
      (data) => myChallenges.value = data as List<UserChallengeModel>,
    );

    results[1].fold(
      (error) {},
      (data) => activeChallenges.value = data as List<ChallengeModel>,
    );

    isLoadingChallenges.value = false;
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
