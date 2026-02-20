import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../data/models/badge_model.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../shared/controllers/base_controller.dart';
import '../../shared/mixins/connectivity_mixin.dart';
import 'widgets/material_icon_picker.dart';

class AchievementController extends BaseController with ConnectivityMixin {
  final SupabaseService _supabase = SupabaseService.to;
  final AchievementRepository _repository = AchievementRepository();

  // ============================================
  // LIST STATE
  // ============================================
  final RxList<AchievementModel> achievements = <AchievementModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filterCategory = 'all'.obs;

  List<AchievementModel> get filteredAchievements {
    var list = achievements.toList();
    if (filterCategory.value != 'all') {
      list = list.where((a) => a.category == filterCategory.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (a) =>
                a.name.toLowerCase().contains(q) ||
                a.description.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  // ============================================
  // FORM STATE
  // ============================================
  final formKey = GlobalKey<FormState>();
  final RxBool isSaving = false.obs;
  final Rx<AchievementModel?> editingAchievement = Rx<AchievementModel?>(null);

  // Text controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final targetValueController = TextEditingController();
  final sortOrderController = TextEditingController();

  // Reactive form fields
  final RxString achievementType = 'workout_count'.obs;
  final RxString targetUnit = 'workouts'.obs;
  final RxString category = 'workout'.obs;
  final RxString targetCategory = ''.obs;
  final RxInt selectedIconCode = 0xe5d2.obs; // Icons.fitness_center
  final RxBool isActive = true.obs;

  // ============================================
  // DETAIL / ANALYTICS STATE
  // ============================================
  final Rx<AchievementModel?> selectedAchievement = Rx<AchievementModel?>(null);
  final Rx<AchievementStatsModel?> achievementStats =
      Rx<AchievementStatsModel?>(null);
  final RxList<UserAchievementModel> achievementUsers =
      <UserAchievementModel>[].obs;
  final RxBool isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
  }

  // ============================================
  // LIST OPERATIONS
  // ============================================

  Future<void> loadAchievements() async {
    if (!await ensureConnectivity()) return;
    setLoading(true);
    try {
      final response = await _supabase
          .from('achievements')
          .select()
          .order('sort_order')
          .order('created_at', ascending: false);
      achievements.value = (response as List)
          .map(
            (json) => AchievementModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> refreshAchievements() async => loadAchievements();

  // ============================================
  // FORM OPERATIONS
  // ============================================

  void initFormForCreate() {
    editingAchievement.value = null;
    nameController.clear();
    descriptionController.clear();
    targetValueController.clear();
    sortOrderController.text = '0';
    achievementType.value = 'workout_count';
    targetUnit.value = 'workouts';
    category.value = 'workout';
    targetCategory.value = '';
    selectedIconCode.value = 0xe5d2; // Icons.fitness_center
    isActive.value = true;
  }

  void initFormForEdit(AchievementModel a) {
    editingAchievement.value = a;
    nameController.text = a.name;
    descriptionController.text = a.description;
    targetValueController.text = a.targetValue.toString();
    sortOrderController.text = a.sortOrder.toString();
    achievementType.value = a.type;
    targetUnit.value = a.targetUnit;
    category.value = a.category;
    targetCategory.value = a.targetCategory ?? '';
    selectedIconCode.value = a.iconCode;
    isActive.value = a.isActive;
  }

  void showIconPicker() {
    Get.dialog(
      MaterialIconPicker(
        currentIconCode: selectedIconCode.value,
        onIconSelected: (code) => selectedIconCode.value = code,
      ),
    );
  }

  /// Auto-set target unit based on achievement type
  void onTypeChanged(String type) {
    achievementType.value = type;
    switch (type) {
      case 'workout_count':
      case 'category_workouts':
      case 'first_workout':
        targetUnit.value = 'workouts';
        break;
      case 'workout_minutes':
        targetUnit.value = 'minutes';
        break;
      case 'streak_days':
      case 'consecutive_days':
        targetUnit.value = 'days';
        break;
      case 'calories_burned':
        targetUnit.value = 'calories';
        break;
      case 'first_challenge':
      case 'challenge_completions':
        targetUnit.value = 'challenges';
        break;
    }
    // Auto-set target to 1 for "first" types
    if (type == 'first_workout' || type == 'first_challenge') {
      targetValueController.text = '1';
    }
  }

  Future<void> saveAchievement() async {
    if (!formKey.currentState!.validate()) return;
    if (!await ensureConnectivity()) return;

    isSaving.value = true;
    try {
      final data = <String, dynamic>{
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'icon_code': selectedIconCode.value,
        'type': achievementType.value,
        'target_value': int.tryParse(targetValueController.text) ?? 1,
        'target_unit': targetUnit.value,
        'category': category.value,
        'target_category': targetCategory.value.isNotEmpty
            ? targetCategory.value
            : null,
        'is_active': isActive.value,
        'sort_order': int.tryParse(sortOrderController.text) ?? 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (editingAchievement.value != null) {
        await _supabase
            .from('achievements')
            .update(data)
            .eq('id', editingAchievement.value!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from('achievements').insert(data);
      }

      await loadAchievements();
      Get.back();
      Get.snackbar(
        'Success',
        editingAchievement.value != null
            ? 'Achievement updated'
            : 'Achievement created',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save achievement',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSaving.value = false;
  }

  Future<void> deleteAchievement(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Achievement'),
        content: const Text(
          'Are you sure you want to delete this achievement?',
        ),
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
    if (!await ensureConnectivity()) return;

    try {
      await _supabase.from('achievements').delete().eq('id', id);
      achievements.removeWhere((a) => a.id == id);
      Get.snackbar(
        'Success',
        'Achievement deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete achievement',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // DETAIL / ANALYTICS
  // ============================================

  Future<void> loadAchievementDetail(String id) async {
    if (!await ensureConnectivity()) return;
    isLoadingDetail.value = true;
    achievementUsers.clear();
    achievementStats.value = null;

    selectedAchievement.value = achievements.firstWhereOrNull(
      (a) => a.id == id,
    );
    if (selectedAchievement.value == null) {
      final result = await _repository.getAchievement(id);
      result.fold(
        (error) => setError(error.message),
        (data) => selectedAchievement.value = data,
      );
    }

    await Future.wait([_loadStats(id), _loadUsers(id)]);

    isLoadingDetail.value = false;
  }

  Future<void> _loadStats(String id) async {
    final result = await _repository.getAchievementStats(id);
    result.fold((error) {}, (data) => achievementStats.value = data);
  }

  Future<void> _loadUsers(String id) async {
    final result = await _repository.getAchievementUsers(id);
    result.fold((error) {}, (data) => achievementUsers.value = data);
  }

  @override
  void onClose() {
    // nameController.dispose();
    // descriptionController.dispose();
    // targetValueController.dispose();
    // sortOrderController.dispose();
    super.onClose();
  }
}
