import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/challenge_model.dart';

/// Local cache for challenge data — instant display while fetching fresh data.
class ChallengeCacheService extends GetxService {
  static ChallengeCacheService get to => Get.find();

  final _storage = GetStorage();

  static const String _activeChallengesKey = 'cached_active_challenges';
  static const String _featuredChallengesKey = 'cached_featured_challenges';
  static const String _upcomingChallengesKey = 'cached_upcoming_challenges';
  static const String _myChallengesKey = 'cached_my_challenges';

  Future<ChallengeCacheService> init() async => this;

  // ============================================
  // ACTIVE CHALLENGES
  // ============================================

  Future<void> cacheActiveChallenges(List<ChallengeModel> challenges) async {
    try {
      final jsonList = challenges.map((c) => c.toCacheJson()).toList();
      await _storage.write(_activeChallengesKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<ChallengeModel>? getCachedActiveChallenges() {
    try {
      final cached = _storage.read<String>(_activeChallengesKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => ChallengeModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // FEATURED CHALLENGES
  // ============================================

  Future<void> cacheFeaturedChallenges(List<ChallengeModel> challenges) async {
    try {
      final jsonList = challenges.map((c) => c.toCacheJson()).toList();
      await _storage.write(_featuredChallengesKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<ChallengeModel>? getCachedFeaturedChallenges() {
    try {
      final cached = _storage.read<String>(_featuredChallengesKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => ChallengeModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // UPCOMING CHALLENGES
  // ============================================

  Future<void> cacheUpcomingChallenges(List<ChallengeModel> challenges) async {
    try {
      final jsonList = challenges.map((c) => c.toCacheJson()).toList();
      await _storage.write(_upcomingChallengesKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<ChallengeModel>? getCachedUpcomingChallenges() {
    try {
      final cached = _storage.read<String>(_upcomingChallengesKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => ChallengeModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // MY CHALLENGES (UserChallengeModel)
  // ============================================

  Future<void> cacheMyChallenges(List<UserChallengeModel> challenges) async {
    try {
      final jsonList = challenges.map((c) => c.toCacheJson()).toList();
      await _storage.write(_myChallengesKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<UserChallengeModel>? getCachedMyChallenges() {
    try {
      final cached = _storage.read<String>(_myChallengesKey);
      if (cached == null) return null;
      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((j) => UserChallengeModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // UTILS
  // ============================================

  bool hasCache() => _storage.read<String>(_activeChallengesKey) != null;

  Future<void> clearCache() async {
    await _storage.remove(_activeChallengesKey);
    await _storage.remove(_featuredChallengesKey);
    await _storage.remove(_upcomingChallengesKey);
    await _storage.remove(_myChallengesKey);
  }
}
