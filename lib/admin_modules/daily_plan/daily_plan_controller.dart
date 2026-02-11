import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../data/models/daily_plan_model.dart';
import '../../data/models/workout_model.dart';
import '../../shared/controllers/base_controller.dart';

class DailyPlanController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;

  // ============================================
  // STATE
  // ============================================

  final Rx<DailyPlanModel?> activePlan = Rx<DailyPlanModel?>(null);

  /// day_number (1-based) → list of items for that day
  final RxMap<int, List<DailyPlanItemModel>> dayItems =
      <int, List<DailyPlanItemModel>>{}.obs;

  final RxInt totalDays = 0.obs;

  /// Start date: Day 1 = this date, Day N = startDate + (N-1)
  final Rx<DateTime> startDate = DateTime.now().obs;

  final RxList<WorkoutModel> allWorkouts = <WorkoutModel>[].obs;
  final RxString workoutSearchQuery = ''.obs;
  final RxBool isSaving = false.obs;

  final titleController = TextEditingController();

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadActivePlan();
    loadAllWorkouts();
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  // ============================================
  // COMPUTED
  // ============================================

  List<WorkoutModel> get filteredWorkouts {
    if (workoutSearchQuery.value.isEmpty) return allWorkouts;
    final q = workoutSearchQuery.value.toLowerCase();
    return allWorkouts
        .where((w) =>
            w.title.toLowerCase().contains(q) ||
            w.trainerName.toLowerCase().contains(q) ||
            w.category.toLowerCase().contains(q))
        .toList();
  }

  List<DailyPlanItemModel> getItemsForDay(int dayNumber) {
    return dayItems[dayNumber] ?? [];
  }

  int get totalAssignedWorkouts {
    int count = 0;
    for (final items in dayItems.values) {
      count += items.length;
    }
    return count;
  }

  /// Returns the date for a given day number based on startDate.
  DateTime getDateForDay(int dayNumber) {
    return startDate.value.add(Duration(days: dayNumber - 1));
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadActivePlan() async {
    setLoading(true);
    try {
      final planResponse = await _supabase
          .from('daily_plans')
          .select()
          .eq('is_active', true)
          .maybeSingle();

      if (planResponse != null) {
        activePlan.value = DailyPlanModel.fromJson(planResponse);
        titleController.text = activePlan.value!.title;
        startDate.value = activePlan.value!.startDate;

        await _loadPlanItems(activePlan.value!.id);

        // Derive totalDays from actual items
        if (dayItems.isNotEmpty) {
          totalDays.value = dayItems.keys.reduce((a, b) => a > b ? a : b);
        } else {
          totalDays.value = 0;
        }
        setSuccess();
      } else {
        activePlan.value = null;
        dayItems.clear();
        totalDays.value = 0;
        startDate.value = DateTime.now();
        titleController.clear();
        setEmpty();
      }
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> _loadPlanItems(String planId) async {
    final itemsResponse = await _supabase
        .from('daily_plan_items')
        .select('*, workouts(*, trainers(*))')
        .eq('plan_id', planId)
        .order('day_number')
        .order('sort_order');

    final items = (itemsResponse as List)
        .map((json) =>
            DailyPlanItemModel.fromJson(json as Map<String, dynamic>))
        .toList();

    dayItems.clear();
    for (final item in items) {
      dayItems[item.dayNumber] ??= [];
      dayItems[item.dayNumber]!.add(item);
    }
    dayItems.refresh();
  }

  Future<void> loadAllWorkouts() async {
    try {
      final response = await _supabase
          .from('workouts')
          .select('*, trainers(*)')
          .eq('is_active', true)
          .order('title');
      allWorkouts.value = (response as List)
          .map((json) =>
              WorkoutModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  // ============================================
  // DAY MANAGEMENT
  // ============================================

  void addDay() {
    // When adding the first day, anchor startDate to today
    if (totalDays.value == 0) {
      startDate.value = DateTime.now();
    }
    totalDays.value++;
    dayItems[totalDays.value] ??= [];
    dayItems.refresh();
  }

  void removeDay(int dayNumber) {
    dayItems.remove(dayNumber);

    // Re-index all days above the removed one
    final newDayItems = <int, List<DailyPlanItemModel>>{};
    final sortedKeys = dayItems.keys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      final newDayNum = i + 1;
      final items = dayItems[sortedKeys[i]]!
          .map((item) => item.copyWith(dayNumber: newDayNum))
          .toList();
      newDayItems[newDayNum] = items;
    }
    dayItems.value = newDayItems;
    totalDays.value = newDayItems.length;
    dayItems.refresh();
  }

  // ============================================
  // ADD / REMOVE WORKOUTS
  // ============================================

  void addWorkoutToDay(int dayNumber, WorkoutModel workout) {
    final existingItems = dayItems[dayNumber] ?? [];
    if (existingItems.any((item) => item.workoutId == workout.id)) {
      Get.snackbar(
        'Already Added',
        'This workout is already assigned to Day $dayNumber',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newItem = DailyPlanItemModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      planId: activePlan.value?.id ?? '',
      dayNumber: dayNumber,
      workoutId: workout.id,
      sortOrder: existingItems.length,
      createdAt: DateTime.now(),
      workout: workout,
    );

    dayItems[dayNumber] = List<DailyPlanItemModel>.from(existingItems)
      ..add(newItem);
    dayItems.refresh();
  }

  void removeWorkoutFromDay(int dayNumber, String itemId) {
    final existing = dayItems[dayNumber] ?? [];
    final updated = existing.where((item) => item.id != itemId).toList();
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(sortOrder: i);
    }
    dayItems[dayNumber] = updated;
    dayItems.refresh();
  }

  // ============================================
  // SAVE
  // ============================================

  Future<void> savePlan() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a plan title',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;
    try {
      String planId;

      if (activePlan.value != null) {
        planId = activePlan.value!.id;
        await _supabase
            .from('daily_plans')
            .update({
              'title': titleController.text.trim(),
              'total_days': totalDays.value,
              'start_date': DailyPlanModel.dateOnly(startDate.value),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', planId);
      } else {
        final response = await _supabase
            .from('daily_plans')
            .insert({
              'title': titleController.text.trim(),
              'total_days': totalDays.value,
              'start_date': DailyPlanModel.dateOnly(startDate.value),
              'is_active': true,
            })
            .select('id')
            .single();
        planId = response['id'] as String;
      }

      // Delete all existing items then re-insert
      await _supabase
          .from('daily_plan_items')
          .delete()
          .eq('plan_id', planId);

      final allItems = <Map<String, dynamic>>[];
      for (final entry in dayItems.entries) {
        for (final item in entry.value) {
          allItems.add({
            'plan_id': planId,
            'day_number': entry.key,
            'workout_id': item.workoutId,
            'sort_order': item.sortOrder,
          });
        }
      }
      if (allItems.isNotEmpty) {
        await _supabase.from('daily_plan_items').insert(allItems);
      }

      // Ensure this is the active plan
      await _supabase
          .from('daily_plans')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .neq('id', planId);
      await _supabase
          .from('daily_plans')
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', planId);

      await loadActivePlan();
      Get.snackbar('Success', 'Daily plan saved',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save plan',
          snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  // ============================================
  // NEW PLAN
  // ============================================

  Future<void> createNewPlan() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('New Plan'),
        content: const Text(
          'This will create a new empty daily plan. The current plan will be deactivated. Continue?',
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

    activePlan.value = null;
    dayItems.clear();
    totalDays.value = 0;
    startDate.value = DateTime.now();
    titleController.clear();
  }
}
