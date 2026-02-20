import 'dart:io';

import 'package:get/get.dart';

import '../../../core/services/diet_plan_cache_service.dart';
import '../../../data/models/diet_plan_model.dart';
import '../../../data/repositories/diet_plan_repository.dart';
import '../../../shared/controllers/base_controller.dart';

class RecipeController extends BaseController {
  final DietPlanRepository _repository = DietPlanRepository();
  final DietPlanCacheService _cache = DietPlanCacheService.to;

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
  final RxBool detailOffline = false.obs;

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
  // LOAD DATA (cache-first, network-refresh)
  // ============================================

  Future<void> loadPlans() async {
    // 1. Show cached data instantly (no loading spinner)
    final cachedPlans = _cache.getCachedPlans();
    final cachedFeatured = _cache.getCachedFeaturedPlans();
    if (cachedPlans != null && cachedPlans.isNotEmpty) {
      allPlans.value = cachedPlans;
      featuredPlans.value = cachedFeatured ?? [];
      setSuccess();
    } else {
      setLoading(true);
    }

    // 2. Try loading fresh data from network
    if (await _hasInternet()) {
      await _loadFromNetwork();
    } else if (allPlans.isEmpty) {
      // No cache and no internet
      setEmpty();
    }

    setLoading(false);
  }

  Future<void> refreshPlans() async {
    if (await _hasInternet()) {
      setLoading(true);
      await _loadFromNetwork();
      setLoading(false);
    } else {
      Get.snackbar('Offline', 'No internet connection. Showing cached data.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _loadFromNetwork() async {
    final results = await Future.wait([
      _repository.getAllPlans(),
      _repository.getFeaturedPlans(),
    ]);

    results[0].fold(
      (error) {
        // Only show error if we have no cached data
        if (allPlans.isEmpty) setError(error.message);
      },
      (data) {
        final plans = data;
        allPlans.value = plans;
        _cache.cachePlans(plans);
        if (plans.isEmpty) {
          setEmpty();
        } else {
          setSuccess();
        }
      },
    );

    results[1].fold(
      (error) {},
      (data) {
        featuredPlans.value = data;
        _cache.cacheFeaturedPlans(data);
      },
    );
  }

  Future<void> loadPlanDetail(String planId) async {
    isLoadingDetail.value = true;
    detailOffline.value = false;
    selectedDayIndex.value = 0;
    selectedPlan.value = null;

    // 1. Show cached detail instantly
    final cached = _cache.getCachedPlanDetail(planId);
    if (cached != null) {
      selectedPlan.value = cached;
    }

    // 2. Try network
    if (await _hasInternet()) {
      final result = await _repository.getPlanWithDetails(planId);
      result.fold(
        (error) {
          if (selectedPlan.value == null) {
            Get.snackbar('Error', error.message,
                snackPosition: SnackPosition.BOTTOM);
          }
        },
        (plan) {
          selectedPlan.value = plan;
          _cache.cachePlanDetail(plan);
        },
      );
    } else if (selectedPlan.value == null) {
      // No cache + no internet
      detailOffline.value = true;
    }

    isLoadingDetail.value = false;
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
