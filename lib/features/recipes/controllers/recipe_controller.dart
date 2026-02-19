import 'package:get/get.dart';

import '../../../data/models/diet_plan_model.dart';
import '../../../data/repositories/diet_plan_repository.dart';
import '../../../shared/controllers/base_controller.dart';

class RecipeController extends BaseController {
  final DietPlanRepository _repository = DietPlanRepository();

  // All published plans
  final RxList<DietPlanModel> allPlans = <DietPlanModel>[].obs;
  final RxList<DietPlanModel> featuredPlans = <DietPlanModel>[].obs;

  // Filters
  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Detail view
  final Rx<DietPlanModel?> selectedPlan = Rx<DietPlanModel?>(null);
  final RxBool isLoadingDetail = false.obs;
  final RxInt selectedDayIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  // ============================================
  // COMPUTED
  // ============================================

  List<DietPlanModel> get filteredPlans {
    var list = allPlans.toList();

    if (selectedCategory.value != 'all') {
      list = list.where((p) => p.category == selectedCategory.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              (p.description?.toLowerCase().contains(q) ?? false) ||
              p.categoryLabel.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  DietPlanDayModel? get selectedDay {
    final plan = selectedPlan.value;
    if (plan == null || plan.days.isEmpty) return null;
    if (selectedDayIndex.value >= plan.days.length) return null;
    return plan.days[selectedDayIndex.value];
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadPlans() async {
    setLoading(true);
    final results = await Future.wait([
      _repository.getAllPlans(),
      _repository.getFeaturedPlans(),
    ]);

    results[0].fold(
      (error) => setError(error.message),
      (data) {
        allPlans.value = data as List<DietPlanModel>;
        setSuccess();
      },
    );

    results[1].fold(
      (error) {},
      (data) => featuredPlans.value = data as List<DietPlanModel>,
    );

    setLoading(false);
  }

  Future<void> refreshPlans() async => loadPlans();

  Future<void> loadPlanDetail(String planId) async {
    isLoadingDetail.value = true;
    selectedDayIndex.value = 0;

    final result = await _repository.getPlanWithDetails(planId);
    result.fold(
      (error) {
        Get.snackbar('Error', error.message,
            snackPosition: SnackPosition.BOTTOM);
      },
      (plan) => selectedPlan.value = plan,
    );

    isLoadingDetail.value = false;
  }
}
