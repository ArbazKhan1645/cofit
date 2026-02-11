import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/media/media_service.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/workout_model.dart';
import '../../shared/controllers/base_controller.dart';

class AdminWorkoutController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;
  final _uuid = const Uuid();

  // List state
  final RxList<WorkoutModel> workouts = <WorkoutModel>[].obs;
  final RxList<TrainerModel> allTrainers = <TrainerModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'all'.obs;

  // Form state
  final formKey = GlobalKey<FormState>();
  final RxBool isSaving = false.obs;
  final Rx<WorkoutModel?> editingWorkout = Rx<WorkoutModel?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final videoUrlController = TextEditingController();
  final durationController = TextEditingController();
  final caloriesController = TextEditingController();
  final weekNumberController = TextEditingController(text: '1');
  final sortOrderController = TextEditingController(text: '0');

  // Reactive fields
  final RxString thumbnailUrl = ''.obs;
  final RxString selectedTrainerId = ''.obs;
  final RxString difficulty = 'beginner'.obs;
  final RxString category = 'full_body'.obs;
  final RxBool isPremium = false.obs;
  final RxBool isActive = true.obs;

  // Tags
  final RxList<String> equipment = <String>[].obs;
  final RxList<String> targetMuscles = <String>[].obs;
  final RxList<String> tags = <String>[].obs;

  // Exercises
  final RxList<WorkoutExerciseModel> exercises =
      <WorkoutExerciseModel>[].obs;
  final List<String> _deletedExerciseIds = [];

  @override
  void onInit() {
    super.onInit();
    loadWorkouts();
    loadTrainers();
  }

  List<WorkoutModel> get filteredWorkouts {
    var list = workouts.toList();
    if (filterStatus.value == 'active') {
      list = list.where((w) => w.isActive).toList();
    } else if (filterStatus.value == 'inactive') {
      list = list.where((w) => !w.isActive).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((w) =>
          w.title.toLowerCase().contains(q) ||
          w.trainerName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Future<void> loadWorkouts() async {
    setLoading(true);
    try {
      final response = await _supabase
          .from('workouts')
          .select('*, trainers(*)')
          .order('created_at', ascending: false);
      workouts.value = (response as List)
          .map((json) =>
              WorkoutModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> loadTrainers() async {
    try {
      final response = await _supabase
          .from('trainers')
          .select()
          .eq('is_active', true)
          .order('full_name');
      allTrainers.value = (response as List)
          .map((json) =>
              TrainerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> refreshWorkouts() async => loadWorkouts();

  // ============================================
  // FORM
  // ============================================

  void initFormForCreate() {
    editingWorkout.value = null;
    selectedImageBytes.value = null;
    thumbnailUrl.value = '';
    titleController.clear();
    descriptionController.clear();
    videoUrlController.clear();
    durationController.clear();
    caloriesController.clear();
    weekNumberController.text = '1';
    sortOrderController.text = '0';
    selectedTrainerId.value =
        allTrainers.isNotEmpty ? allTrainers.first.id : '';
    difficulty.value = 'beginner';
    category.value = 'full_body';
    isPremium.value = false;
    isActive.value = true;
    equipment.clear();
    targetMuscles.clear();
    tags.clear();
    exercises.clear();
    _deletedExerciseIds.clear();
  }

  Future<void> initFormForEdit(WorkoutModel workout) async {
    editingWorkout.value = workout;
    selectedImageBytes.value = null;
    thumbnailUrl.value = workout.thumbnailUrl;
    titleController.text = workout.title;
    descriptionController.text = workout.description;
    videoUrlController.text = workout.videoUrl;
    durationController.text = workout.durationMinutes.toString();
    caloriesController.text =
        workout.caloriesBurned > 0 ? workout.caloriesBurned.toString() : '';
    weekNumberController.text = workout.weekNumber.toString();
    sortOrderController.text = workout.sortOrder.toString();
    selectedTrainerId.value = workout.trainerId;
    difficulty.value = workout.difficulty;
    category.value = workout.category;
    isPremium.value = workout.isPremium;
    isActive.value = workout.isActive;
    equipment.value = List<String>.from(workout.equipment);
    targetMuscles.value = List<String>.from(workout.targetMuscles);
    tags.value = List<String>.from(workout.tags);
    _deletedExerciseIds.clear();

    // Load exercises
    try {
      final response = await _supabase
          .from('workout_exercises')
          .select()
          .eq('workout_id', workout.id)
          .order('order_index');
      exercises.value = (response as List)
          .map((json) =>
              WorkoutExerciseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      exercises.clear();
    }
  }

  Future<void> pickThumbnail() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes != null) selectedImageBytes.value = bytes;
  }

  void removeThumbnail() {
    selectedImageBytes.value = null;
    thumbnailUrl.value = '';
  }

  // Tags helpers
  void addEquipment(String v) {
    if (v.trim().isNotEmpty && !equipment.contains(v.trim())) {
      equipment.add(v.trim());
    }
  }

  void removeEquipment(String v) => equipment.remove(v);

  void addTargetMuscle(String v) {
    if (v.trim().isNotEmpty && !targetMuscles.contains(v.trim())) {
      targetMuscles.add(v.trim());
    }
  }

  void removeTargetMuscle(String v) => targetMuscles.remove(v);

  void addTag(String v) {
    if (v.trim().isNotEmpty && !tags.contains(v.trim())) tags.add(v.trim());
  }

  void removeTag(String v) => tags.remove(v);

  // ============================================
  // EXERCISES
  // ============================================

  void showExerciseDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final ex = isEdit ? exercises[editIndex] : null;

    final nameC = TextEditingController(text: ex?.name ?? '');
    final descC = TextEditingController(text: ex?.description ?? '');
    final videoC = TextEditingController(text: ex?.videoUrl ?? '');
    final durationC =
        TextEditingController(text: ex?.durationSeconds.toString() ?? '30');
    final repsC = TextEditingController(text: ex?.reps?.toString() ?? '');
    final setsC = TextEditingController(text: ex?.sets?.toString() ?? '');
    final restC =
        TextEditingController(text: ex?.restSeconds?.toString() ?? '');
    final exType = (ex?.exerciseType ?? 'timed').obs;

    Get.dialog(AlertDialog(
      title: Text(isEdit ? 'Edit Exercise' : 'Add Exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Name *')),
            const SizedBox(height: 12),
            TextField(
                controller: descC,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2),
            const SizedBox(height: 12),
            TextField(
                controller: videoC,
                decoration:
                    const InputDecoration(labelText: 'Video URL')),
            const SizedBox(height: 16),
            Obx(() => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'timed', label: Text('Timed')),
                    ButtonSegment(value: 'reps', label: Text('Reps')),
                    ButtonSegment(value: 'rest', label: Text('Rest')),
                  ],
                  selected: {exType.value},
                  onSelectionChanged: (s) => exType.value = s.first,
                )),
            const SizedBox(height: 12),
            Obx(() {
              if (exType.value == 'reps') {
                return Column(children: [
                  TextField(
                      controller: setsC,
                      decoration: const InputDecoration(labelText: 'Sets'),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(
                      controller: repsC,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      keyboardType: TextInputType.number),
                ]);
              }
              return TextField(
                  controller: durationC,
                  decoration:
                      const InputDecoration(labelText: 'Duration (seconds)'),
                  keyboardType: TextInputType.number);
            }),
            const SizedBox(height: 12),
            TextField(
                controller: restC,
                decoration:
                    const InputDecoration(labelText: 'Rest (seconds)'),
                keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (nameC.text.trim().isEmpty) return;
            final newEx = WorkoutExerciseModel(
              id: ex?.id ?? 'temp_${_uuid.v4()}',
              workoutId: editingWorkout.value?.id ?? '',
              name: nameC.text.trim(),
              description: descC.text.trim().isNotEmpty
                  ? descC.text.trim()
                  : null,
              videoUrl: videoC.text.trim().isNotEmpty
                  ? videoC.text.trim()
                  : null,
              orderIndex: isEdit ? ex!.orderIndex : exercises.length,
              durationSeconds:
                  int.tryParse(durationC.text) ?? 30,
              reps: repsC.text.isNotEmpty
                  ? int.tryParse(repsC.text)
                  : null,
              sets: setsC.text.isNotEmpty
                  ? int.tryParse(setsC.text)
                  : null,
              restSeconds: restC.text.isNotEmpty
                  ? int.tryParse(restC.text)
                  : null,
              exerciseType: exType.value,
              createdAt: ex?.createdAt ?? DateTime.now(),
            );
            if (isEdit) {
              exercises[editIndex] = newEx;
            } else {
              exercises.add(newEx);
            }
            Get.back();
          },
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    ));
  }

  void removeExercise(int index) {
    final ex = exercises[index];
    if (!ex.id.startsWith('temp_')) {
      _deletedExerciseIds.add(ex.id);
    }
    exercises.removeAt(index);
    // Update order indices
    for (var i = 0; i < exercises.length; i++) {
      exercises[i] = WorkoutExerciseModel(
        id: exercises[i].id,
        workoutId: exercises[i].workoutId,
        name: exercises[i].name,
        description: exercises[i].description,
        thumbnailUrl: exercises[i].thumbnailUrl,
        videoUrl: exercises[i].videoUrl,
        orderIndex: i,
        durationSeconds: exercises[i].durationSeconds,
        reps: exercises[i].reps,
        sets: exercises[i].sets,
        restSeconds: exercises[i].restSeconds,
        exerciseType: exercises[i].exerciseType,
        createdAt: exercises[i].createdAt,
      );
    }
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    for (var i = 0; i < exercises.length; i++) {
      exercises[i] = WorkoutExerciseModel(
        id: exercises[i].id,
        workoutId: exercises[i].workoutId,
        name: exercises[i].name,
        description: exercises[i].description,
        thumbnailUrl: exercises[i].thumbnailUrl,
        videoUrl: exercises[i].videoUrl,
        orderIndex: i,
        durationSeconds: exercises[i].durationSeconds,
        reps: exercises[i].reps,
        sets: exercises[i].sets,
        restSeconds: exercises[i].restSeconds,
        exerciseType: exercises[i].exerciseType,
        createdAt: exercises[i].createdAt,
      );
    }
  }

  // ============================================
  // SAVE / DELETE
  // ============================================

  Future<void> saveWorkout() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedTrainerId.value.isEmpty) {
      Get.snackbar('Error', 'Please select a trainer',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;
    try {
      String? newThumbnailUrl;
      if (selectedImageBytes.value != null) {
        newThumbnailUrl = await MediaService.to
            .uploadWorkoutThumbnail(selectedImageBytes.value!);
      }

      final data = <String, dynamic>{
        'trainer_id': selectedTrainerId.value,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'thumbnail_url': newThumbnailUrl ??
            (thumbnailUrl.value.isNotEmpty ? thumbnailUrl.value : ''),
        'video_url': videoUrlController.text.trim(),
        'duration_minutes': int.tryParse(durationController.text) ?? 0,
        'difficulty': difficulty.value,
        'category': category.value,
        'calories_burned': int.tryParse(caloriesController.text) ?? 0,
        'equipment': equipment.toList(),
        'target_muscles': targetMuscles.toList(),
        'tags': tags.toList(),
        'week_number': int.tryParse(weekNumberController.text) ?? 1,
        'sort_order': int.tryParse(sortOrderController.text) ?? 0,
        'is_premium': isPremium.value,
        'is_active': isActive.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      String workoutId;
      if (editingWorkout.value != null) {
        workoutId = editingWorkout.value!.id;
        await _supabase
            .from('workouts')
            .update(data)
            .eq('id', workoutId);
      } else {
        data['published_at'] = DateTime.now().toIso8601String();
        data['created_at'] = DateTime.now().toIso8601String();
        final response = await _supabase
            .from('workouts')
            .insert(data)
            .select('id')
            .single();
        workoutId = response['id'] as String;
      }

      // Delete removed exercises
      for (final exId in _deletedExerciseIds) {
        await _supabase
            .from('workout_exercises')
            .delete()
            .eq('id', exId);
      }

      // Upsert exercises
      for (final ex in exercises) {
        final exData = {
          'workout_id': workoutId,
          'name': ex.name,
          'description': ex.description,
          'thumbnail_url': ex.thumbnailUrl,
          'video_url': ex.videoUrl,
          'order_index': ex.orderIndex,
          'duration_seconds': ex.durationSeconds,
          'reps': ex.reps,
          'sets': ex.sets,
          'rest_seconds': ex.restSeconds,
          'exercise_type': ex.exerciseType,
        };

        if (ex.id.startsWith('temp_')) {
          await _supabase.from('workout_exercises').insert(exData);
        } else {
          await _supabase
              .from('workout_exercises')
              .update(exData)
              .eq('id', ex.id);
        }
      }

      await loadWorkouts();
      Get.back();
      Get.snackbar(
          'Success',
          editingWorkout.value != null
              ? 'Workout updated'
              : 'Workout added',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save workout',
          snackPosition: SnackPosition.BOTTOM);
    }
    isSaving.value = false;
  }

  Future<void> deleteWorkout(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Workout'),
        content:
            const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _supabase.from('workout_exercises').delete().eq('workout_id', id);
      await _supabase.from('workouts').delete().eq('id', id);
      workouts.removeWhere((w) => w.id == id);
      Get.snackbar('Success', 'Workout deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete workout',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
    durationController.dispose();
    caloriesController.dispose();
    weekNumberController.dispose();
    sortOrderController.dispose();
    super.onClose();
  }
}
