import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/media/media_service.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/workout_model.dart';
import '../../shared/controllers/base_controller.dart';
import 'exercise_form_screen.dart';

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

  // Video
  final RxString videoSource = 'url'.obs; // 'url' or 'upload'
  final Rx<Uint8List?> selectedVideoBytes = Rx<Uint8List?>(null);
  final RxString uploadedVideoUrl = ''.obs;
  final RxBool isUploadingVideo = false.obs;

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
  final RxList<WorkoutExerciseModel> exercises = <WorkoutExerciseModel>[].obs;
  final List<String> _deletedExerciseIds = [];

  // Variants
  final RxList<WorkoutVariantModel> variants = <WorkoutVariantModel>[].obs;
  final Rx<WorkoutVariantModel?> selectedVariant = Rx<WorkoutVariantModel?>(
    null,
  );
  final List<String> _deletedVariantIds = [];

  // View state
  final Rx<WorkoutModel?> viewingWorkout = Rx<WorkoutModel?>(null);
  final RxList<WorkoutExerciseModel> viewExercises =
      <WorkoutExerciseModel>[].obs;
  final RxList<WorkoutVariantModel> viewVariants = <WorkoutVariantModel>[].obs;
  final RxBool isLoadingView = false.obs;
  final Rx<WorkoutVariantModel?> selectedViewVariant = Rx<WorkoutVariantModel?>(
    null,
  );

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
      list = list
          .where(
            (w) =>
                w.title.toLowerCase().contains(q) ||
                w.trainerName.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  /// Get exercises for the currently selected variant (null = default)
  List<WorkoutExerciseModel> get currentVariantExercises {
    final vid = selectedVariant.value?.id;
    if (vid == null) {
      return exercises.where((e) => e.variantId == null).toList();
    }
    return exercises.where((e) => e.variantId == vid).toList();
  }

  /// Get view exercises for the selected view variant
  List<WorkoutExerciseModel> get currentViewVariantExercises {
    final vid = selectedViewVariant.value?.id;
    if (vid == null) {
      return viewExercises.where((e) => e.variantId == null).toList();
    }
    return viewExercises.where((e) => e.variantId == vid).toList();
  }

  Future<void> loadWorkouts() async {
    setLoading(true);
    try {
      final response = await _supabase
          .from('workouts')
          .select('*, trainers(*)')
          .order('created_at', ascending: false);
      workouts.value = (response as List)
          .map((json) => WorkoutModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e);
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
          .map((json) => TrainerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> refreshWorkouts() async => loadWorkouts();

  // ============================================
  // VIEW
  // ============================================

  Future<void> loadWorkoutForView(WorkoutModel workout) async {
    viewingWorkout.value = workout;
    viewExercises.clear();
    viewVariants.clear();
    selectedViewVariant.value = null;
    isLoadingView.value = true;
    try {
      final response = await _supabase
          .from('workout_exercises')
          .select()
          .eq('workout_id', workout.id)
          .order('order_index');
      viewExercises.value = (response as List)
          .map(
            (json) =>
                WorkoutExerciseModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      // Load variants
      final variantResponse = await _supabase
          .from('workout_variants')
          .select()
          .eq('workout_id', workout.id)
          .order('created_at');
      viewVariants.value = (variantResponse as List)
          .map(
            (json) =>
                WorkoutVariantModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      viewExercises.clear();
      viewVariants.clear();
    }
    isLoadingView.value = false;
  }

  void selectViewVariant(WorkoutVariantModel? variant) {
    selectedViewVariant.value = variant;
  }

  // ============================================
  // FORM
  // ============================================

  void initFormForCreate() {
    editingWorkout.value = null;
    selectedImageBytes.value = null;
    selectedVideoBytes.value = null;
    uploadedVideoUrl.value = '';
    videoSource.value = 'url';
    isUploadingVideo.value = false;
    thumbnailUrl.value = '';
    titleController.clear();
    descriptionController.clear();
    videoUrlController.clear();
    durationController.clear();
    caloriesController.clear();
    weekNumberController.text = '1';
    sortOrderController.text = '0';
    selectedTrainerId.value = allTrainers.isNotEmpty
        ? allTrainers.first.id
        : '';
    difficulty.value = 'beginner';
    category.value = 'full_body';
    isPremium.value = false;
    isActive.value = true;
    equipment.clear();
    targetMuscles.clear();
    tags.clear();
    exercises.clear();
    _deletedExerciseIds.clear();
    variants.clear();
    selectedVariant.value = null;
    _deletedVariantIds.clear();
  }

  Future<void> initFormForEdit(WorkoutModel workout) async {
    editingWorkout.value = workout;
    selectedImageBytes.value = null;
    selectedVideoBytes.value = null;
    isUploadingVideo.value = false;
    thumbnailUrl.value = workout.thumbnailUrl;
    titleController.text = workout.title;
    descriptionController.text = workout.description;
    videoUrlController.text = workout.videoUrl;
    // If existing workout has a video URL, default to url mode
    videoSource.value = 'url';
    uploadedVideoUrl.value = '';
    durationController.text = workout.durationMinutes.toString();
    caloriesController.text = workout.caloriesBurned > 0
        ? workout.caloriesBurned.toString()
        : '';
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
    _deletedVariantIds.clear();
    selectedVariant.value = null;

    // Load exercises
    try {
      final response = await _supabase
          .from('workout_exercises')
          .select()
          .eq('workout_id', workout.id)
          .order('order_index');
      exercises.value = (response as List)
          .map(
            (json) =>
                WorkoutExerciseModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      exercises.clear();
    }

    // Load variants
    try {
      final variantResponse = await _supabase
          .from('workout_variants')
          .select()
          .eq('workout_id', workout.id)
          .order('created_at');
      variants.value = (variantResponse as List)
          .map(
            (json) =>
                WorkoutVariantModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      variants.clear();
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

  // ============================================
  // VIDEO
  // ============================================

  Future<void> pickVideo() async {
    final bytes = await MediaService.to.pickVideoFromGallery();
    if (bytes == null) return;
    selectedVideoBytes.value = bytes;
    // Upload immediately
    isUploadingVideo.value = true;
    try {
      final url = await MediaService.to.uploadWorkoutVideo(bytes);
      uploadedVideoUrl.value = url;
      Get.snackbar(
        'Success',
        'Video uploaded',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      selectedVideoBytes.value = null;
      Get.snackbar(
        'Error',
        'Video upload failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isUploadingVideo.value = false;
  }

  void removeVideo() {
    selectedVideoBytes.value = null;
    uploadedVideoUrl.value = '';
  }

  /// Validate URL format
  static String? validateVideoUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final url = value.trim();
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid URL';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'URL must start with http or https';
    }
    return null;
  }

  /// Get resolved video URL for save
  String get resolvedVideoUrl {
    if (videoSource.value == 'upload' && uploadedVideoUrl.value.isNotEmpty) {
      return uploadedVideoUrl.value;
    }
    return videoUrlController.text.trim();
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
  // VARIANTS
  // ============================================

  void selectVariant(WorkoutVariantModel? variant) {
    selectedVariant.value = variant;
  }

  void showVariantDialog() {
    // Get tags already used by existing variants
    final usedTags = variants.map((v) => v.variantTag).toSet();

    // Filter available tags
    final available = conditionTags
        .where((ct) => !usedTags.contains(ct['tag']))
        .toList();

    if (available.isEmpty) {
      Get.snackbar('All Added', 'All condition types are already added as variants.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.bottomSheet(
      Container(
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Condition Type',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final ct = available[index];
                  final tag = ct['tag']!;
                  final label = ct['label']!;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(label),
                    subtitle: Text(
                      'for ${label.toLowerCase()} users',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      variants.add(
                        WorkoutVariantModel(
                          id: 'temp_${_uuid.v4()}',
                          workoutId: editingWorkout.value?.id ?? '',
                          variantTag: tag,
                          label: label,
                          description: 'for ${label.toLowerCase()} users',
                          createdAt: DateTime.now(),
                        ),
                      );
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void removeVariant(WorkoutVariantModel variant) {
    if (!variant.id.startsWith('temp_')) {
      _deletedVariantIds.add(variant.id);
    }
    // Remove exercises belonging to this variant
    final variantExIds = exercises
        .where((e) => e.variantId == variant.id)
        .map((e) => e.id)
        .toList();
    for (final exId in variantExIds) {
      if (!exId.startsWith('temp_')) {
        _deletedExerciseIds.add(exId);
      }
    }
    exercises.removeWhere((e) => e.variantId == variant.id);
    variants.remove(variant);
    if (selectedVariant.value?.id == variant.id) {
      selectedVariant.value = null;
    }
  }

  // ============================================
  // EXERCISES
  // ============================================

  void showExerciseDialog({int? editIndex}) {
    Get.to(
      () => const ExerciseFormScreen(),
      arguments: {'editIndex': editIndex},
      transition: Transition.rightToLeft,
    );
  }

  // ============================================
  // EXERCISE ALTERNATIVES
  // ============================================

  /// All condition tags for alternatives
  static const List<Map<String, String>> conditionTags = [
    {'tag': 'knee_issue', 'label': 'Knee Issue'},
    {'tag': 'ankle_issue', 'label': 'Ankle Issue'},
    {'tag': 'hip_issue', 'label': 'Hip Issue'},
    {'tag': 'foot_issue', 'label': 'Foot Issue'},
    {'tag': 'lower_back_issue', 'label': 'Lower Back Issue'},
    {'tag': 'upper_back_issue', 'label': 'Upper Back Issue'},
    {'tag': 'neck_issue', 'label': 'Neck Issue'},
    {'tag': 'shoulder_issue', 'label': 'Shoulder Issue'},
    {'tag': 'elbow_issue', 'label': 'Elbow Issue'},
    {'tag': 'wrist_issue', 'label': 'Wrist Issue'},
    {'tag': 'cardio_limit', 'label': 'Cardio Limitation'},
    {'tag': 'balance_issue', 'label': 'Balance Issue'},
    {'tag': 'overweight_safe', 'label': 'Overweight Safe'},
    {'tag': 'pregnancy_safe', 'label': 'Pregnancy Safe'},
    {'tag': 'senior_safe', 'label': 'Senior Safe'},
    {'tag': 'rehab_mode', 'label': 'Rehab Mode'},
    {'tag': 'mobility_only', 'label': 'Mobility Only'},
    {'tag': 'beginner', 'label': 'Beginner'},
  ];

  void showAlternativesDialog(int exerciseIndex) {
    final ex = exercises[exerciseIndex];
    final altMap = Map<String, dynamic>.from(ex.alternatives);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Exercise Alternatives'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For: ${ex.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (altMap.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No alternatives added yet.'),
                      ),
                    ...altMap.entries.map((entry) {
                      final condition = entry.key;
                      final data = entry.value as Map<String, dynamic>;
                      final label = conditionTags.firstWhere(
                        (t) => t['tag'] == condition,
                        orElse: () => {'label': condition},
                      )['label']!;
                      return Card(
                        child: ListTile(
                          title: Text(label),
                          subtitle: Text(data['name'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() => altMap.remove(condition));
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          _showAddAlternativeDialog(altMap, setState);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Alternative'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  exercises[exerciseIndex] = WorkoutExerciseModel(
                    id: ex.id,
                    workoutId: ex.workoutId,
                    name: ex.name,
                    description: ex.description,
                    thumbnailUrl: ex.thumbnailUrl,
                    videoUrl: ex.videoUrl,
                    orderIndex: ex.orderIndex,
                    durationSeconds: ex.durationSeconds,
                    reps: ex.reps,
                    sets: ex.sets,
                    restSeconds: ex.restSeconds,
                    exerciseType: ex.exerciseType,
                    variantId: ex.variantId,
                    alternatives: altMap,
                    createdAt: ex.createdAt,
                  );
                  Get.back();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAlternativeDialog(
    Map<String, dynamic> altMap,
    void Function(void Function()) parentSetState,
  ) {
    // Filter out already-added conditions
    final available = conditionTags
        .where((t) => !altMap.containsKey(t['tag']))
        .toList();
    if (available.isEmpty) {
      Get.snackbar(
        'Info',
        'All conditions already have alternatives',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final selectedTag = available.first['tag']!.obs;
    final nameC = TextEditingController();
    final videoC = TextEditingController();
    final repsC = TextEditingController();
    final setsC = TextEditingController();
    final durationC = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Alternative'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedTag.value,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: available.map((t) {
                    return DropdownMenuItem(
                      value: t['tag'],
                      child: Text(t['label']!),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) selectedTag.value = v;
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: 'Alternative Exercise Name *',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: videoC,
                decoration: const InputDecoration(labelText: 'Video URL'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsC,
                      decoration: const InputDecoration(labelText: 'Sets'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsC,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationC,
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameC.text.trim().isEmpty) return;
              final altData = <String, dynamic>{'name': nameC.text.trim()};
              if (videoC.text.trim().isNotEmpty) {
                altData['video_url'] = videoC.text.trim();
              }
              if (repsC.text.isNotEmpty) {
                altData['reps'] = int.tryParse(repsC.text);
              }
              if (setsC.text.isNotEmpty) {
                altData['sets'] = int.tryParse(setsC.text);
              }
              if (durationC.text.isNotEmpty) {
                altData['duration_seconds'] = int.tryParse(durationC.text);
              }
              parentSetState(() {
                altMap[selectedTag.value] = altData;
              });
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void removeExercise(int index) {
    final ex = exercises[index];
    if (!ex.id.startsWith('temp_')) {
      _deletedExerciseIds.add(ex.id);
    }
    exercises.removeAt(index);
    // Update order indices for same variant group
    final vid = ex.variantId;
    int order = 0;
    for (var i = 0; i < exercises.length; i++) {
      if (exercises[i].variantId == vid) {
        exercises[i] = WorkoutExerciseModel(
          id: exercises[i].id,
          workoutId: exercises[i].workoutId,
          name: exercises[i].name,
          description: exercises[i].description,
          thumbnailUrl: exercises[i].thumbnailUrl,
          videoUrl: exercises[i].videoUrl,
          orderIndex: order++,
          durationSeconds: exercises[i].durationSeconds,
          reps: exercises[i].reps,
          sets: exercises[i].sets,
          restSeconds: exercises[i].restSeconds,
          exerciseType: exercises[i].exerciseType,
          variantId: exercises[i].variantId,
          alternatives: exercises[i].alternatives,
          createdAt: exercises[i].createdAt,
        );
      }
    }
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final variantExercises = currentVariantExercises;
    final item = variantExercises.removeAt(oldIndex);
    variantExercises.insert(newIndex, item);

    // Update order indices
    final vid = selectedVariant.value?.id;
    // Remove all exercises of this variant from main list
    exercises.removeWhere((e) => e.variantId == vid);
    // Re-add with corrected order
    for (var i = 0; i < variantExercises.length; i++) {
      final e = variantExercises[i];
      exercises.add(
        WorkoutExerciseModel(
          id: e.id,
          workoutId: e.workoutId,
          name: e.name,
          description: e.description,
          thumbnailUrl: e.thumbnailUrl,
          videoUrl: e.videoUrl,
          orderIndex: i,
          durationSeconds: e.durationSeconds,
          reps: e.reps,
          sets: e.sets,
          restSeconds: e.restSeconds,
          exerciseType: e.exerciseType,
          variantId: e.variantId,
          alternatives: e.alternatives,
          createdAt: e.createdAt,
        ),
      );
    }
  }

  // ============================================
  // SAVE / DELETE
  // ============================================

  Future<void> saveWorkout() async {
    // if (!formKey.currentState!.validate()) return;
    // if (selectedTrainerId.value.isEmpty) {
    //   Get.snackbar(
    //     'Error',
    //     'Please select a trainer',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    //   return;
    // }

    isSaving.value = true;
    try {
      String? newThumbnailUrl;
      if (selectedImageBytes.value != null) {
        newThumbnailUrl = await MediaService.to.uploadWorkoutThumbnail(
          selectedImageBytes.value!,
        );
      }

      final data = <String, dynamic>{
        'trainer_id': selectedTrainerId.value,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'thumbnail_url':
            newThumbnailUrl ??
            (thumbnailUrl.value.isNotEmpty ? thumbnailUrl.value : ''),
        'video_url': resolvedVideoUrl,
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
        await _supabase.from('workouts').update(data).eq('id', workoutId);
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

      // Delete removed variants (cascade deletes variant exercises)
      for (final vId in _deletedVariantIds) {
        await _supabase.from('workout_variants').delete().eq('id', vId);
      }

      // Upsert variants & remap temp IDs
      final variantIdMap = <String, String>{}; // temp_id -> real_id
      for (final v in variants) {
        final vData = {
          'workout_id': workoutId,
          'variant_tag': v.variantTag,
          'label': v.label,
          'description': v.description,
        };
        if (v.id.startsWith('temp_')) {
          final inserted = await _supabase
              .from('workout_variants')
              .insert(vData)
              .select('id')
              .single();
          variantIdMap[v.id] = inserted['id'] as String;
        } else {
          await _supabase.from('workout_variants').update(vData).eq('id', v.id);
        }
      }

      // Delete removed exercises
      for (final exId in _deletedExerciseIds) {
        await _supabase.from('workout_exercises').delete().eq('id', exId);
      }

      // Upsert exercises
      for (final ex in exercises) {
        // Resolve variant ID (temp → real)
        String? resolvedVariantId = ex.variantId;
        if (resolvedVariantId != null &&
            variantIdMap.containsKey(resolvedVariantId)) {
          resolvedVariantId = variantIdMap[resolvedVariantId];
        }

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
          'variant_id': resolvedVariantId,
          'alternatives': ex.alternatives,
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
        editingWorkout.value != null ? 'Workout updated' : 'Workout added',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to save workout',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSaving.value = false;
  }

  Future<void> deleteWorkout(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _supabase.from('workout_exercises').delete().eq('workout_id', id);
      await _supabase.from('workout_variants').delete().eq('workout_id', id);
      await _supabase.from('workouts').delete().eq('id', id);
      workouts.removeWhere((w) => w.id == id);
      Get.snackbar(
        'Success',
        'Workout deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete workout',
        snackPosition: SnackPosition.BOTTOM,
      );
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
