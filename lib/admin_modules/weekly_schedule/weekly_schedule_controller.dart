import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../data/models/weekly_schedule_model.dart';
import '../../data/models/workout_model.dart';
import '../../notifications/firebase_sender.dart';
import '../../shared/controllers/base_controller.dart';
import '../../shared/mixins/connectivity_mixin.dart';

class WeeklyScheduleController extends BaseController with ConnectivityMixin {
  final SupabaseService _supabase = SupabaseService.to;

  // ============================================
  // STATE
  // ============================================

  final Rx<WeeklyScheduleModel?> activeSchedule = Rx<WeeklyScheduleModel?>(
    null,
  );

  final RxMap<int, List<WeeklyScheduleItemModel>> dayItems =
      <int, List<WeeklyScheduleItemModel>>{}.obs;

  final RxList<WorkoutModel> allWorkouts = <WorkoutModel>[].obs;
  final RxString workoutSearchQuery = ''.obs;
  final RxList<int> disabledDays = <int>[].obs;
  final RxBool isSaving = false.obs;

  final titleController = TextEditingController();

  static const List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    _initDayItems();
    loadActiveSchedule();
    loadAllWorkouts();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _initDayItems() {
    for (int i = 0; i < 7; i++) {
      dayItems[i] = [];
    }
  }

  // ============================================
  // COMPUTED
  // ============================================

  List<WorkoutModel> get filteredWorkouts {
    if (workoutSearchQuery.value.isEmpty) return allWorkouts;
    final q = workoutSearchQuery.value.toLowerCase();
    return allWorkouts
        .where(
          (w) =>
              w.title.toLowerCase().contains(q) ||
              w.trainerName.toLowerCase().contains(q) ||
              w.category.toLowerCase().contains(q),
        )
        .toList();
  }

  List<WeeklyScheduleItemModel> getItemsForDay(int day) {
    return dayItems[day] ?? [];
  }

  bool isDayDisabled(int day) => disabledDays.contains(day);

  int get totalAssignedWorkouts {
    int count = 0;
    for (final items in dayItems.values) {
      count += items.length;
    }
    return count;
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadActiveSchedule() async {
    if (!await ensureConnectivity()) return;
    setLoading(true);
    try {
      final scheduleResponse = await _supabase
          .from('weekly_schedules')
          .select()
          .eq('is_active', true)
          .maybeSingle();

      if (scheduleResponse != null) {
        activeSchedule.value = WeeklyScheduleModel.fromJson(scheduleResponse);
        titleController.text = activeSchedule.value!.title;
        disabledDays.value = List<int>.from(activeSchedule.value!.disabledDays);

        await _loadScheduleItems(activeSchedule.value!.id);
        setSuccess();
      } else {
        activeSchedule.value = null;
        _initDayItems();
        disabledDays.clear();
        titleController.clear();
        setEmpty();
      }
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> _loadScheduleItems(String scheduleId) async {
    final itemsResponse = await _supabase
        .from('weekly_schedule_items')
        .select('*, workouts(*, trainers(*))')
        .eq('schedule_id', scheduleId)
        .order('sort_order');

    final items = (itemsResponse as List)
        .map(
          (json) =>
              WeeklyScheduleItemModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    _initDayItems();
    for (final item in items) {
      dayItems[item.dayOfWeek]?.add(item);
    }
    dayItems.refresh();
  }

  Future<void> loadAllWorkouts() async {
    if (!await ensureConnectivity()) return;
    try {
      final response = await _supabase
          .from('workouts')
          .select('*, trainers(*)')
          .eq('is_active', true)
          .order('title');
      allWorkouts.value = (response as List)
          .map((json) => WorkoutModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  // ============================================
  // ADD / REMOVE WORKOUTS
  // ============================================

  void addWorkoutToDay(int day, WorkoutModel workout) {
    final existingItems = dayItems[day] ?? [];
    if (existingItems.any((item) => item.workoutId == workout.id)) {
      Get.snackbar(
        'Already Added',
        'This workout is already assigned to ${dayNames[day]}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newItem = WeeklyScheduleItemModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      scheduleId: activeSchedule.value?.id ?? '',
      dayOfWeek: day,
      workoutId: workout.id,
      sortOrder: existingItems.length,
      createdAt: DateTime.now(),
      workout: workout,
    );

    final updated = List<WeeklyScheduleItemModel>.from(existingItems)
      ..add(newItem);
    dayItems[day] = updated;
    dayItems.refresh();
  }

  void removeWorkoutFromDay(int day, String itemId) {
    final existing = dayItems[day] ?? [];
    final updated = existing.where((item) => item.id != itemId).toList();
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(sortOrder: i);
    }
    dayItems[day] = updated;
    dayItems.refresh();
  }

  // ============================================
  // TOGGLE DAY
  // ============================================

  void toggleDay(int day) {
    if (disabledDays.contains(day)) {
      disabledDays.remove(day);
    } else {
      disabledDays.add(day);
    }
  }

  // ============================================
  // SAVE
  // ============================================

  Future<void> saveSchedule() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a schedule title',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!await ensureConnectivity()) return;

    isSaving.value = true;
    try {
      final isNewSchedule = activeSchedule.value == null;
      String scheduleId;

      if (!isNewSchedule) {
        scheduleId = activeSchedule.value!.id;
        await _supabase
            .from('weekly_schedules')
            .update({
              'title': titleController.text.trim(),
              'disabled_days': disabledDays.toList(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', scheduleId);
      } else {
        final response = await _supabase
            .from('weekly_schedules')
            .insert({
              'title': titleController.text.trim(),
              'disabled_days': disabledDays.toList(),
              'is_active': true,
            })
            .select('id')
            .single();
        scheduleId = response['id'] as String;
      }

      // Delete all existing items then re-insert
      await _supabase
          .from('weekly_schedule_items')
          .delete()
          .eq('schedule_id', scheduleId);

      final allItems = <Map<String, dynamic>>[];
      for (final entry in dayItems.entries) {
        for (final item in entry.value) {
          allItems.add({
            'schedule_id': scheduleId,
            'day_of_week': entry.key,
            'workout_id': item.workoutId,
            'sort_order': item.sortOrder,
          });
        }
      }
      if (allItems.isNotEmpty) {
        await _supabase.from('weekly_schedule_items').insert(allItems);
      }

      // Ensure this is the active schedule (deactivate others, activate this one)
      await _supabase
          .from('weekly_schedules')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .neq('id', scheduleId);
      await _supabase
          .from('weekly_schedules')
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', scheduleId);

      await loadActiveSchedule();

      // Send push notification to all users on new schedule (unawaited)
      if (isNewSchedule) {
        final schedTitle = titleController.text.trim();
        FcmNotificationSender().sendAdminBroadcast(
          title: 'This Week\'s Schedule is Ready!',
          body: '$schedTitle — $totalAssignedWorkouts workouts assigned.'
              ' Check out your plan for the week!',
        );
      }

      Get.snackbar(
        'Success',
        'Weekly schedule saved',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Save schedule error: $e');
      Get.snackbar(
        'Error',
        'Failed to save schedule',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSaving.value = false;
  }

  // ============================================
  // NEW WEEK
  // ============================================

  Future<void> createNewWeek() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('New Week'),
        content: const Text(
          'This will create a new empty schedule. The current schedule will be deactivated. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    activeSchedule.value = null;
    _initDayItems();
    disabledDays.clear();
    titleController.clear();
  }
}
