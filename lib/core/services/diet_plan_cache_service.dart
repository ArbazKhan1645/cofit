import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/diet_plan_model.dart';

/// Local cache for diet plans — instant display while fetching fresh data.
/// If no internet, cached plans are shown. If online, fresh data replaces cache.
class DietPlanCacheService extends GetxService {
  static DietPlanCacheService get to => Get.find();

  final _storage = GetStorage();

  static const String _plansCacheKey = 'cached_diet_plans';
  static const String _featuredCacheKey = 'cached_diet_featured';
  static const String _cacheTimestampKey = 'diet_plans_cache_ts';
  static const String _planDetailPrefix = 'cached_diet_plan_';

  Future<DietPlanCacheService> init() async => this;

  // ============================================
  // ALL PLANS
  // ============================================

  Future<void> cachePlans(List<DietPlanModel> plans) async {
    try {
      final jsonList = plans.map((p) => p.toCacheJson()).toList();
      await _storage.write(_plansCacheKey, jsonEncode(jsonList));
      await _storage.write(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  List<DietPlanModel>? getCachedPlans() {
    try {
      final cached = _storage.read<String>(_plansCacheKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => DietPlanModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // FEATURED PLANS
  // ============================================

  Future<void> cacheFeaturedPlans(List<DietPlanModel> plans) async {
    try {
      final jsonList = plans.map((p) => p.toCacheJson()).toList();
      await _storage.write(_featuredCacheKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<DietPlanModel>? getCachedFeaturedPlans() {
    try {
      final cached = _storage.read<String>(_featuredCacheKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => DietPlanModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // PLAN DETAIL (with days + meals)
  // ============================================

  Future<void> cachePlanDetail(DietPlanModel plan) async {
    try {
      await _storage.write(
        '$_planDetailPrefix${plan.id}',
        jsonEncode(plan.toCacheJson()),
      );
    } catch (_) {}
  }

  DietPlanModel? getCachedPlanDetail(String planId) {
    try {
      final cached = _storage.read<String>('$_planDetailPrefix$planId');
      if (cached == null) return null;
      return DietPlanModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // UTILS
  // ============================================

  bool hasCache() => _storage.read<String>(_plansCacheKey) != null;

  Future<void> clearCache() async {
    await _storage.remove(_plansCacheKey);
    await _storage.remove(_featuredCacheKey);
    await _storage.remove(_cacheTimestampKey);
  }
}
