import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/media/media_service.dart';
import '../../data/models/diet_plan_model.dart';
import '../../data/repositories/diet_plan_repository.dart';
import '../../shared/controllers/base_controller.dart';
import '../../shared/mixins/connectivity_mixin.dart';

class AdminRecipeController extends BaseController with ConnectivityMixin {
  final DietPlanRepository _repository = DietPlanRepository();

  // ============================================
  // LIST STATE
  // ============================================

  final RxList<DietPlanModel> allPlans = <DietPlanModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filterCategory = 'all'.obs;
  final RxString filterStatus = 'all'.obs; // all, published, draft

  // ============================================
  // FORM STATE
  // ============================================

  final formKey = GlobalKey<FormState>();
  final RxBool isSaving = false.obs;
  final Rx<DietPlanModel?> editingPlan = Rx<DietPlanModel?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final caloriesController = TextEditingController();

  // Reactive fields
  final RxString imageUrl = ''.obs;
  final RxString planType = 'custom'.obs;
  final RxString category = 'general'.obs;
  final RxString difficultyLevel = 'beginner'.obs;
  final RxBool isPublished = false.obs;
  final RxBool isFeatured = false.obs;

  // ============================================
  // DAY EDITOR STATE
  // ============================================

  final Rx<DietPlanModel?> currentPlan = Rx<DietPlanModel?>(null);
  final RxList<DietPlanDayModel> planDays = <DietPlanDayModel>[].obs;
  final RxInt selectedDayIndex = 0.obs;
  final RxBool isLoadingDays = false.obs;
  final RxBool isSavingMeal = false.obs;

  // Meal form
  final mealFormKey = GlobalKey<FormState>();
  final mealTitleController = TextEditingController();
  final mealDescriptionController = TextEditingController();
  final mealCaloriesController = TextEditingController();
  final mealProteinController = TextEditingController();
  final mealCarbsController = TextEditingController();
  final mealFatController = TextEditingController();
  final mealFiberController = TextEditingController();
  final mealInstructionsController = TextEditingController();
  final mealPrepTimeController = TextEditingController();
  final RxString mealType = 'breakfast'.obs;
  final RxList<IngredientModel> mealIngredients = <IngredientModel>[].obs;
  final Rx<DietPlanMealModel?> editingMeal = Rx<DietPlanMealModel?>(null);

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  @override
  void onClose() {
    // titleController.dispose();
    // descriptionController.dispose();
    // durationController.dispose();
    // caloriesController.dispose();
    // mealTitleController.dispose();
    // mealDescriptionController.dispose();
    // mealCaloriesController.dispose();
    // mealProteinController.dispose();
    // mealCarbsController.dispose();
    // mealFatController.dispose();
    // mealFiberController.dispose();
    // mealInstructionsController.dispose();
    // mealPrepTimeController.dispose();
    super.onClose();
  }

  // ============================================
  // COMPUTED
  // ============================================

  List<DietPlanModel> get filteredPlans {
    var list = allPlans.toList();

    // Filter by status
    if (filterStatus.value == 'published') {
      list = list.where((p) => p.isPublished).toList();
    } else if (filterStatus.value == 'draft') {
      list = list.where((p) => !p.isPublished).toList();
    }

    // Filter by category
    if (filterCategory.value != 'all') {
      list = list.where((p) => p.category == filterCategory.value).toList();
    }

    // Search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                (p.description?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return list;
  }

  DietPlanDayModel? get selectedDay {
    if (planDays.isEmpty || selectedDayIndex.value >= planDays.length) {
      return null;
    }
    return planDays[selectedDayIndex.value];
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadPlans() async {
    if (!await ensureConnectivity()) return;
    setLoading(true);
    final result = await _repository.getAllPlans(adminMode: true);
    result.fold((error) => setError(error.message), (data) {
      allPlans.value = data;
      setSuccess();
    });
    setLoading(false);
  }

  Future<void> refreshPlans() async => loadPlans();

  // ============================================
  // PLAN FORM
  // ============================================

  void initFormForCreate() {
    editingPlan.value = null;
    selectedImageBytes.value = null;
    imageUrl.value = '';
    titleController.clear();
    descriptionController.clear();
    durationController.text = '7';
    caloriesController.clear();
    planType.value = 'custom';
    category.value = 'general';
    difficultyLevel.value = 'beginner';
    isPublished.value = false;
    isFeatured.value = false;
  }

  void initFormForEdit(DietPlanModel plan) {
    editingPlan.value = plan;
    selectedImageBytes.value = null;
    imageUrl.value = plan.coverImageUrl ?? '';
    titleController.text = plan.title;
    descriptionController.text = plan.description ?? '';
    durationController.text = plan.durationDays.toString();
    caloriesController.text = plan.caloriesPerDay?.toString() ?? '';
    planType.value = plan.planType;
    category.value = plan.category;
    difficultyLevel.value = plan.difficultyLevel;
    isPublished.value = plan.isPublished;
    isFeatured.value = plan.isFeatured;
  }

  void onPlanTypeChanged(String type) {
    planType.value = type;
    switch (type) {
      case 'weekly':
        durationController.text = '7';
        break;
      case 'monthly':
        durationController.text = '30';
        break;
    }
  }

  Future<void> pickImage() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes != null) selectedImageBytes.value = bytes;
  }

  void removeImage() {
    selectedImageBytes.value = null;
    imageUrl.value = '';
  }

  Future<void> savePlan() async {
    if (!formKey.currentState!.validate()) return;

    final duration = int.tryParse(durationController.text) ?? 7;
    if (duration < 1 || duration > 365) {
      Get.snackbar(
        'Error',
        'Duration must be between 1 and 365 days',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!await ensureConnectivity()) return;
    isSaving.value = true;
    try {
      String? newImageUrl;
      if (selectedImageBytes.value != null) {
        newImageUrl = await MediaService.to.uploadChallengeImage(
          selectedImageBytes.value!,
        );
      }

      final data = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        'cover_image_url':
            newImageUrl ?? (imageUrl.value.isNotEmpty ? imageUrl.value : null),
        'plan_type': planType.value,
        'duration_days': duration,
        'category': category.value,
        'difficulty_level': difficultyLevel.value,
        'calories_per_day': caloriesController.text.isNotEmpty
            ? int.tryParse(caloriesController.text)
            : null,
        'is_published': isPublished.value,
        'is_featured': isFeatured.value,
      };

      if (editingPlan.value != null) {
        // Update existing
        await _repository.updatePlan(editingPlan.value!.id, data);
      } else {
        // Create new + auto-create days
        final result = await _repository.createPlan(data);
        result.fold((error) => throw Exception(error.message), (plan) async {
          await _repository.createDays(plan.id, duration);
        });
      }

      await loadPlans();
      Get.back();
      Get.snackbar(
        'Success',
        editingPlan.value != null ? 'Diet plan updated' : 'Diet plan created',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save diet plan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSaving.value = false;
  }

  Future<void> deletePlan(String planId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Diet Plan'),
        content: const Text(
          'Are you sure? This will delete the plan and all its meals. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!await ensureConnectivity()) return;
    try {
      await _repository.deletePlan(planId);
      allPlans.removeWhere((p) => p.id == planId);
      Get.snackbar(
        'Success',
        'Diet plan deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete plan',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> togglePublish(DietPlanModel plan) async {
    if (!await ensureConnectivity()) return;
    try {
      final newStatus = !plan.isPublished;
      await _repository.updatePlan(plan.id, {'is_published': newStatus});
      final idx = allPlans.indexWhere((p) => p.id == plan.id);
      if (idx != -1) {
        allPlans[idx] = plan.copyWith(isPublished: newStatus);
        allPlans.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // DAY EDITOR
  // ============================================

  Future<void> loadPlanDays(DietPlanModel plan) async {
    if (!await ensureConnectivity()) return;
    currentPlan.value = plan;
    isLoadingDays.value = true;
    selectedDayIndex.value = 0;

    final result = await _repository.getPlanDays(plan.id);
    result.fold(
      (error) {
        Get.snackbar(
          'Error',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (days) {
        if (days.isEmpty) {
          // Auto-create days if none exist
          _createMissingDays(plan);
        } else {
          planDays.value = days;
        }
      },
    );

    isLoadingDays.value = false;
  }

  Future<void> _createMissingDays(DietPlanModel plan) async {
    final result = await _repository.createDays(plan.id, plan.durationDays);
    result.fold((error) {}, (days) => planDays.value = days);
  }

  Future<void> refreshDays() async {
    if (currentPlan.value == null) return;
    final result = await _repository.getPlanDays(currentPlan.value!.id);
    result.fold((error) {}, (days) => planDays.value = days);
  }

  /// Copy meals from previous day → "Same as previous day" feature
  Future<void> copyFromPreviousDay(int targetDayIndex) async {
    if (!await ensureConnectivity()) return;
    if (targetDayIndex <= 0 || targetDayIndex >= planDays.length) return;

    final sourceDay = planDays[targetDayIndex - 1];
    final targetDay = planDays[targetDayIndex];

    if (sourceDay.meals.isEmpty) {
      Get.snackbar(
        'Info',
        'Previous day has no meals to copy',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _repository.copyDayMeals(sourceDay.id, targetDay.id);
      await refreshDays();
      Get.snackbar(
        'Success',
        'Meals copied from Day ${sourceDay.dayNumber}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to copy meals',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Copy meals from any specific day
  Future<void> copyFromDay(int sourceDayIndex, int targetDayIndex) async {
    if (!await ensureConnectivity()) return;
    if (sourceDayIndex < 0 ||
        sourceDayIndex >= planDays.length ||
        targetDayIndex < 0 ||
        targetDayIndex >= planDays.length) {
      return;
    }

    final sourceDay = planDays[sourceDayIndex];
    final targetDay = planDays[targetDayIndex];

    try {
      await _repository.copyDayMeals(sourceDay.id, targetDay.id);
      await refreshDays();
      Get.snackbar(
        'Success',
        'Meals copied from Day ${sourceDay.dayNumber}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to copy meals',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // MEAL CRUD
  // ============================================

  void initMealFormForCreate(String dayId) {
    editingMeal.value = null;
    mealTitleController.clear();
    mealDescriptionController.clear();
    mealCaloriesController.clear();
    mealProteinController.clear();
    mealCarbsController.clear();
    mealFatController.clear();
    mealFiberController.clear();
    mealInstructionsController.clear();
    mealPrepTimeController.clear();
    mealType.value = _nextMealType();
    mealIngredients.clear();
  }

  void initMealFormForEdit(DietPlanMealModel meal) {
    editingMeal.value = meal;
    mealTitleController.text = meal.title;
    mealDescriptionController.text = meal.description ?? '';
    mealCaloriesController.text = meal.calories > 0
        ? meal.calories.toString()
        : '';
    mealProteinController.text = meal.proteinG > 0
        ? meal.proteinG.toString()
        : '';
    mealCarbsController.text = meal.carbsG > 0 ? meal.carbsG.toString() : '';
    mealFatController.text = meal.fatG > 0 ? meal.fatG.toString() : '';
    mealFiberController.text = meal.fiberG > 0 ? meal.fiberG.toString() : '';
    mealInstructionsController.text = meal.recipeInstructions ?? '';
    mealPrepTimeController.text = meal.prepTimeMinutes != null
        ? meal.prepTimeMinutes.toString()
        : '';
    mealType.value = meal.mealType;
    mealIngredients.value = List.from(meal.ingredients);
  }

  String _nextMealType() {
    final day = selectedDay;
    if (day == null) return 'breakfast';
    final existingTypes = day.meals.map((m) => m.mealType).toSet();
    for (final type in kMealTypes) {
      if (!existingTypes.contains(type)) return type;
    }
    return 'breakfast';
  }

  void addIngredient(String name, String? quantity, String? unit) {
    if (name.trim().isEmpty) return;
    mealIngredients.add(
      IngredientModel(
        name: name.trim(),
        quantity: quantity?.trim(),
        unit: unit?.trim(),
      ),
    );
  }

  void removeIngredient(int index) {
    if (index >= 0 && index < mealIngredients.length) {
      mealIngredients.removeAt(index);
    }
  }

  Future<void> saveMeal() async {
    if (!mealFormKey.currentState!.validate()) return;
    final day = selectedDay;
    if (day == null) return;

    if (!await ensureConnectivity()) return;
    isSavingMeal.value = true;
    try {
      final data = {
        'day_id': day.id,
        'meal_type': mealType.value,
        'title': mealTitleController.text.trim(),
        'description': mealDescriptionController.text.trim().isNotEmpty
            ? mealDescriptionController.text.trim()
            : null,
        'calories': int.tryParse(mealCaloriesController.text) ?? 0,
        'protein_g': double.tryParse(mealProteinController.text) ?? 0,
        'carbs_g': double.tryParse(mealCarbsController.text) ?? 0,
        'fat_g': double.tryParse(mealFatController.text) ?? 0,
        'fiber_g': double.tryParse(mealFiberController.text) ?? 0,
        'recipe_instructions': mealInstructionsController.text.trim().isNotEmpty
            ? mealInstructionsController.text.trim()
            : null,
        'prep_time_minutes': mealPrepTimeController.text.isNotEmpty
            ? int.tryParse(mealPrepTimeController.text)
            : null,
        'ingredients': mealIngredients.map((e) => e.toJson()).toList(),
        'sort_order': kMealTypes.indexOf(mealType.value),
      };

      if (editingMeal.value != null) {
        await _repository.updateMeal(editingMeal.value!.id, data);
      } else {
        await _repository.addMeal(data);
      }

      await _repository.recalculateDayTotals(day.id);
      await refreshDays();

      Get.back();
      Get.snackbar(
        'Success',
        editingMeal.value != null ? 'Meal updated' : 'Meal added',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save meal',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSavingMeal.value = false;
  }

  Future<void> deleteMeal(DietPlanMealModel meal) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Delete "${meal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!await ensureConnectivity()) return;
    try {
      await _repository.deleteMeal(meal.id);
      await _repository.recalculateDayTotals(meal.dayId);
      await refreshDays();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete meal',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // COPY DAY DIALOG
  // ============================================

  void showCopyFromDayDialog(int targetDayIndex) {
    final daysWithMeals = <int>[];
    for (int i = 0; i < planDays.length; i++) {
      if (i != targetDayIndex && planDays[i].hasMeals) {
        daysWithMeals.add(i);
      }
    }

    if (daysWithMeals.isEmpty) {
      Get.snackbar(
        'Info',
        'No other days have meals to copy from',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Copy Meals From'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: daysWithMeals.length,
            itemBuilder: (context, index) {
              final dayIdx = daysWithMeals[index];
              final day = planDays[dayIdx];
              return ListTile(
                title: Text('Day ${day.dayNumber}'),
                subtitle: Text(
                  '${day.mealCount} meals - ${day.computedCalories} cal',
                ),
                onTap: () {
                  Get.back();
                  copyFromDay(dayIdx, targetDayIndex);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
