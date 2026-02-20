import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/workout_cache_service.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/models/weekly_schedule_model.dart';
import '../../../data/repositories/workout_repository.dart';

class WorkoutsController extends BaseController {
  final WorkoutRepository _repository = WorkoutRepository();
  WorkoutCacheService get _cache => WorkoutCacheService.to;

  // ============================================
  // STATE
  // ============================================

  // Trainers
  final RxList<TrainerModel> trainers = <TrainerModel>[].obs;

  // Weekly schedule
  final Rx<WeeklyScheduleModel?> activeSchedule = Rx<WeeklyScheduleModel?>(
    null,
  );
  final RxMap<int, List<WeeklyScheduleItemModel>> dayItems =
      <int, List<WeeklyScheduleItemModel>>{}.obs;
  final RxInt selectedDayIndex = 0.obs;

  // Saved workouts
  final RxList<SavedWorkoutModel> savedWorkouts = <SavedWorkoutModel>[].obs;
  final savedWorkoutIds = <String>[].obs;

  // All workouts (for library)
  final RxList<WorkoutModel> allWorkouts = <WorkoutModel>[].obs;

  // Search & filter
  final RxString searchQuery = ''.obs;
  final RxString filterCategory = 'all'.obs;
  final RxString filterDifficulty = 'all'.obs;
  final RxBool isSearching = false.obs;
  final searchController = TextEditingController();

  // Loading states
  final RxBool isInitialLoading = true.obs;
  final RxBool isLoadingSaved = false.obs;

  static const List<String> dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> fullDayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> categories = [
    'all',
    'full_body',
    'upper_body',
    'lower_body',
    'core',
    'cardio',
    'hiit',
    'yoga',
    'pilates',
  ];

  static const List<String> difficulties = [
    'all',
    'beginner',
    'intermediate',
    'advanced',
  ];

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    _setCurrentDay();
    _initDayItems();
    loadData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _setCurrentDay() {
    // DateTime weekday: 1=Monday, 7=Sunday → our index: 0=Monday, 6=Sunday
    selectedDayIndex.value = DateTime.now().weekday - 1;
  }

  void _initDayItems() {
    for (int i = 0; i < 7; i++) {
      dayItems[i] = [];
    }
  }

  // ============================================
  // COMPUTED
  // ============================================

  /// Get today's day index (0=Monday, 6=Sunday)
  int get todayIndex => DateTime.now().weekday - 1;

  /// Workouts for the currently selected day
  List<WorkoutModel> get selectedDayWorkouts {
    final items = dayItems[selectedDayIndex.value] ?? [];
    return items
        .where((item) => item.workout != null)
        .map((item) => item.workout!)
        .toList();
  }

  /// Whether the selected day is a rest day
  bool get isSelectedDayRestDay {
    if (activeSchedule.value == null) return false;
    return activeSchedule.value!.isDayDisabled(selectedDayIndex.value);
  }

  /// Get workout count for a specific day
  int getWorkoutCountForDay(int dayIndex) {
    return dayItems[dayIndex]?.length ?? 0;
  }

  /// Whether a day is disabled (rest day)
  bool isDayDisabled(int dayIndex) {
    return activeSchedule.value?.isDayDisabled(dayIndex) ?? false;
  }

  /// Filtered workouts for library
  List<WorkoutModel> get filteredWorkouts {
    var list = allWorkouts.toList();

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (w) =>
                w.title.toLowerCase().contains(q) ||
                w.trainerName.toLowerCase().contains(q) ||
                w.category.toLowerCase().contains(q) ||
                w.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }

    if (filterCategory.value != 'all') {
      list = list.where((w) => w.category == filterCategory.value).toList();
    }

    if (filterDifficulty.value != 'all') {
      list = list.where((w) => w.difficulty == filterDifficulty.value).toList();
    }

    return list;
  }

  /// Category display label
  String getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'full_body':
        return 'Full Body';
      case 'upper_body':
        return 'Upper Body';
      case 'lower_body':
        return 'Lower Body';
      case 'core':
        return 'Core';
      case 'cardio':
        return 'Cardio';
      case 'hiit':
        return 'HIIT';
      case 'yoga':
        return 'Yoga';
      case 'pilates':
        return 'Pilates';
      default:
        return category;
    }
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadData() async {
    // 1. Show cached data instantly
    _loadFromCache();
    isInitialLoading.value = trainers.isEmpty;

    // 2. Try fresh data from network
    if (await _hasInternet()) {
      await Future.wait([
        _loadTrainers(),
        _loadActiveSchedule(),
        loadSavedWorkoutIds(),
      ]);
    }
    isInitialLoading.value = false;
  }

  Future<void> refreshData() async {
    if (await _hasInternet()) {
      await Future.wait([
        _loadTrainers(),
        _loadActiveSchedule(),
        loadSavedWorkoutIds(),
      ]);
    } else {
      Get.snackbar('Offline', 'No internet connection. Showing cached data.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _loadFromCache() {
    final cachedTrainers = _cache.getCachedTrainers();
    if (cachedTrainers != null && cachedTrainers.isNotEmpty) {
      trainers.value = cachedTrainers;
    }

    final cachedSchedule = _cache.getCachedSchedule();
    if (cachedSchedule != null) {
      activeSchedule.value = cachedSchedule;
      final cachedItems = _cache.getCachedScheduleItems();
      if (cachedItems != null) {
        _initDayItems();
        for (final item in cachedItems) {
          dayItems[item.dayOfWeek]?.add(item);
        }
        dayItems.refresh();
      }
    }

    final cachedIds = _cache.getCachedSavedWorkoutIds();
    if (cachedIds != null) {
      savedWorkoutIds.clear();
      savedWorkoutIds.addAll(cachedIds);
    }
  }

  Future<void> _loadTrainers() async {
    final result = await _repository.getTrainers();
    result.fold((error) => {}, (data) {
      trainers.value = data;
      _cache.cacheTrainers(data);
    });
  }

  Future<void> _loadActiveSchedule() async {
    final scheduleResult = await _repository.getActiveSchedule();
    scheduleResult.fold((error) {}, (schedule) async {
      activeSchedule.value = schedule;
      if (schedule != null) {
        final itemsResult = await _repository.getScheduleItems(schedule.id);
        itemsResult.fold((error) {}, (items) {
          _initDayItems();
          for (final item in items) {
            dayItems[item.dayOfWeek]?.add(item);
          }
          dayItems.refresh();
          _cache.cacheSchedule(schedule, items);
        });
      }
    });
  }

  Future<void> loadSavedWorkoutIds() async {
    final result = await _repository.getSavedWorkoutIds();
    result.fold((error) => {}, (ids) {
      savedWorkoutIds.clear();
      savedWorkoutIds.addAll(ids);
      _cache.cacheSavedWorkoutIds(ids.toList());
    });
  }

  Future<void> loadSavedWorkouts() async {
    // Show cache first
    final cached = _cache.getCachedSavedWorkouts();
    if (cached != null && cached.isNotEmpty) {
      savedWorkouts.value = cached;
    }

    isLoadingSaved.value = savedWorkouts.isEmpty;
    if (await _hasInternet()) {
      final result = await _repository.getSavedWorkouts();
      result.fold((error) => {}, (data) {
        savedWorkouts.value = data;
        _cache.cacheSavedWorkouts(data);
      });
    }
    isLoadingSaved.value = false;
  }

  Future<void> loadAllWorkouts() async {
    // Show cache first
    if (allWorkouts.isEmpty) {
      final cached = _cache.getCachedAllWorkouts();
      if (cached != null && cached.isNotEmpty) {
        allWorkouts.value = cached;
        setSuccess();
      }
    }
    if (allWorkouts.isNotEmpty && !(await _hasInternet())) return;

    setLoading(allWorkouts.isEmpty);
    if (await _hasInternet()) {
      final result = await _repository.getAllWorkouts();
      result.fold((error) {
        if (allWorkouts.isEmpty) setError(error.message);
      }, (data) {
        allWorkouts.value = data;
        _cache.cacheAllWorkouts(data);
        setSuccess();
      });
    }
    setLoading(false);
  }

  // ============================================
  // SAVED WORKOUTS
  // ============================================

  bool isWorkoutSaved(String workoutId) {
    return savedWorkoutIds.contains(workoutId);
  }

  Future<void> toggleSaveWorkout(WorkoutModel workout) async {
    if (isWorkoutSaved(workout.id)) {
      // Unsave
      savedWorkoutIds.remove(workout.id);
      savedWorkoutIds.refresh();
      final result = await _repository.unsaveWorkout(workout.id);
      result.fold(
        (error) {
          // Revert on failure
          savedWorkoutIds.add(workout.id);
          savedWorkoutIds.refresh();
          Get.snackbar(
            'Error',
            'Failed to unsave workout',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (_) {
          savedWorkouts.removeWhere((s) => s.workoutId == workout.id);
        },
      );
    } else {
      // Save
      savedWorkoutIds.add(workout.id);
      savedWorkoutIds.refresh();
      final result = await _repository.saveWorkout(workout.id);
      result.fold(
        (error) {
          // Revert on failure
          savedWorkoutIds.remove(workout.id);
          savedWorkoutIds.refresh();
          Get.snackbar(
            'Error',
            'Failed to save workout',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (saved) {
          savedWorkouts.insert(0, saved);
        },
      );
    }
  }

  // ============================================
  // SEARCH & FILTER
  // ============================================

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
      searchController.clear();
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void setFilterCategory(String category) {
    filterCategory.value = category;
  }

  void setFilterDifficulty(String difficulty) {
    filterDifficulty.value = difficulty;
  }

  void clearFilters() {
    filterCategory.value = 'all';
    filterDifficulty.value = 'all';
    searchQuery.value = '';
    searchController.clear();
  }

  // ============================================
  // DAY SELECTION
  // ============================================

  void selectDay(int dayIndex) {
    selectedDayIndex.value = dayIndex;
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
}
