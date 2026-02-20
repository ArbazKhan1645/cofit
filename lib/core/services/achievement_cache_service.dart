import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/badge_model.dart';

/// Local cache for achievement data — instant display while fetching fresh data.
class AchievementCacheService extends GetxService {
  static AchievementCacheService get to => Get.find();

  final _storage = GetStorage();

  static const String _allAchievementsKey = 'cached_all_achievements';
  static const String _userAchievementsKey = 'cached_user_achievements';

  Future<AchievementCacheService> init() async => this;

  // ============================================
  // ALL ACHIEVEMENTS
  // ============================================

  Future<void> cacheAllAchievements(List<AchievementModel> achievements) async {
    try {
      final jsonList = achievements.map((a) => a.toJson()).toList();
      await _storage.write(_allAchievementsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<AchievementModel>? getCachedAllAchievements() {
    try {
      final cached = _storage.read<String>(_allAchievementsKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => AchievementModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // USER ACHIEVEMENTS
  // ============================================

  Future<void> cacheUserAchievements(
      List<UserAchievementModel> achievements) async {
    try {
      final jsonList = achievements.map((a) => a.toCacheJson()).toList();
      await _storage.write(_userAchievementsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<UserAchievementModel>? getCachedUserAchievements() {
    try {
      final cached = _storage.read<String>(_userAchievementsKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) =>
              UserAchievementModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // UTILS
  // ============================================

  bool hasCache() => _storage.read<String>(_allAchievementsKey) != null;

  Future<void> clearCache() async {
    await _storage.remove(_allAchievementsKey);
    await _storage.remove(_userAchievementsKey);
  }
}
