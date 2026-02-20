import 'dart:io';

import 'package:get/get.dart';

import '../../../core/services/challenge_cache_service.dart';
import '../../../data/models/challenge_model.dart';
import '../../../data/repositories/challenge_repository.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../shared/widgets/widgets.dart';

class ChallengeController extends BaseController {
  final ChallengeRepository _repository = ChallengeRepository();

  // ============================================
  // BROWSE STATE
  // ============================================
  final RxList<ChallengeModel> activeChallenges = <ChallengeModel>[].obs;
  final RxList<ChallengeModel> featuredChallenges = <ChallengeModel>[].obs;
  final RxList<ChallengeModel> upcomingChallenges = <ChallengeModel>[].obs;

  // ============================================
  // MY CHALLENGES
  // ============================================
  final RxList<UserChallengeModel> myChallenges = <UserChallengeModel>[].obs;
  final RxList<UserChallengeModel> completedChallenges =
      <UserChallengeModel>[].obs;
  final RxBool isLoadingMyChallenges = false.obs;

  // ============================================
  // DETAIL STATE
  // ============================================
  final Rx<ChallengeModel?> selectedChallenge = Rx<ChallengeModel?>(null);
  final RxList<ChallengeLeaderboardEntry> leaderboard =
      <ChallengeLeaderboardEntry>[].obs;
  final Rx<int?> myRank = Rx<int?>(null);
  final RxBool isLoadingDetail = false.obs;
  final RxBool isLoadingLeaderboard = false.obs;

  // ============================================
  // ACTION STATE
  // ============================================
  final RxBool isJoining = false.obs;
  final RxBool isLeaving = false.obs;

  // ============================================
  // TAB STATE
  // ============================================
  final RxInt selectedTabIndex = 0.obs; // 0=Active, 1=Upcoming, 2=My Challenges

  @override
  void onInit() {
    super.onInit();
    loadChallenges();
  }

  // ============================================
  // BROWSE
  // ============================================

  Future<void> loadChallenges() async {
    final hasInternet = await _hasInternet();
    final cache = ChallengeCacheService.to;

    if (!hasInternet) {
      // Offline: use cached data
      final cachedActive = cache.getCachedActiveChallenges();
      final cachedFeatured = cache.getCachedFeaturedChallenges();
      final cachedUpcoming = cache.getCachedUpcomingChallenges();
      final cachedMy = cache.getCachedMyChallenges();
      if (cachedActive != null) activeChallenges.value = cachedActive;
      if (cachedFeatured != null) featuredChallenges.value = cachedFeatured;
      if (cachedUpcoming != null) upcomingChallenges.value = cachedUpcoming;
      if (cachedMy != null) myChallenges.value = cachedMy;
      setSuccess();
      return;
    }

    // Show cached data instantly while loading fresh
    if (activeChallenges.isEmpty) {
      final cachedActive = cache.getCachedActiveChallenges();
      final cachedFeatured = cache.getCachedFeaturedChallenges();
      final cachedUpcoming = cache.getCachedUpcomingChallenges();
      final cachedMy = cache.getCachedMyChallenges();
      if (cachedActive != null) activeChallenges.value = cachedActive;
      if (cachedFeatured != null) featuredChallenges.value = cachedFeatured;
      if (cachedUpcoming != null) upcomingChallenges.value = cachedUpcoming;
      if (cachedMy != null) myChallenges.value = cachedMy;
    }

    setLoading(true);

    final results = await Future.wait([
      _repository.getActiveChallenges(),
      _repository.getFeaturedChallenges(),
      _repository.getUpcomingChallenges(),
      _repository.getMyActiveChallenges(),
    ]);

    results[0].fold(
      (error) {},
      (data) {
        final list = data as List<ChallengeModel>;
        activeChallenges.value = list;
        cache.cacheActiveChallenges(list);
      },
    );

    results[1].fold(
      (error) {},
      (data) {
        final list = data as List<ChallengeModel>;
        featuredChallenges.value = list;
        cache.cacheFeaturedChallenges(list);
      },
    );

    results[2].fold(
      (error) {},
      (data) {
        final list = data as List<ChallengeModel>;
        upcomingChallenges.value = list;
        cache.cacheUpcomingChallenges(list);
      },
    );

    results[3].fold(
      (error) {},
      (data) {
        final list = data as List<UserChallengeModel>;
        myChallenges.value = list;
        cache.cacheMyChallenges(list);
      },
    );

    setSuccess();
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> refreshChallenges() async => loadChallenges();

  // ============================================
  // DETAIL
  // ============================================

  Future<void> loadChallengeDetail(String challengeId) async {
    isLoadingDetail.value = true;
    leaderboard.clear();
    myRank.value = null;

    final result = await _repository.getChallenge(challengeId);
    result.fold(
      (error) => setError(error.message),
      (data) => selectedChallenge.value = data,
    );

    isLoadingDetail.value = false;

    // Load leaderboard in background
    loadLeaderboard(challengeId);
  }

  Future<void> loadLeaderboard(String challengeId) async {
    isLoadingLeaderboard.value = true;

    final result = await _repository.getLeaderboard(challengeId, limit: 50);
    result.fold(
      (error) {},
      (data) => leaderboard.value = data,
    );

    final rankResult = await _repository.getUserRank(challengeId);
    rankResult.fold(
      (error) {},
      (data) => myRank.value = data,
    );

    isLoadingLeaderboard.value = false;
  }

  // ============================================
  // ACTIONS
  // ============================================

  Future<void> joinChallenge(String challengeId) async {
    isJoining.value = true;

    final result = await _repository.joinChallenge(challengeId);
    result.fold(
      (error) {
        if (Get.context != null) {
          AppSnackbar.error(
            Get.context!,
            message: error.message,
            title: 'Failed to Join',
          );
        }
      },
      (data) {
        // Update selectedChallenge to reflect joined state
        if (selectedChallenge.value?.id == challengeId) {
          selectedChallenge.value = selectedChallenge.value!.copyWith(
            isJoined: true,
            participantCount: selectedChallenge.value!.participantCount + 1,
          );
        }
        // Add to my challenges
        myChallenges.add(data);
        // Update in active list
        _updateChallengeJoinedState(challengeId, true);

        if (Get.context != null) {
          AppSnackbar.success(
            Get.context!,
            message: 'You\'ve joined the challenge!',
            title: 'Joined',
          );
        }
      },
    );

    isJoining.value = false;
  }

  Future<void> leaveChallenge(String challengeId) async {
    isLeaving.value = true;

    final result = await _repository.leaveChallenge(challengeId);
    result.fold(
      (error) {
        if (Get.context != null) {
          AppSnackbar.error(
            Get.context!,
            message: error.message,
            title: 'Failed to Leave',
          );
        }
      },
      (_) {
        if (selectedChallenge.value?.id == challengeId) {
          selectedChallenge.value = selectedChallenge.value!.copyWith(
            isJoined: false,
            userProgress: 0,
            userRank: null,
            participantCount:
                (selectedChallenge.value!.participantCount - 1).clamp(0, 99999),
          );
        }
        myChallenges.removeWhere((c) => c.challengeId == challengeId);
        _updateChallengeJoinedState(challengeId, false);

        if (Get.context != null) {
          AppSnackbar.success(
            Get.context!,
            message: 'You\'ve left the challenge',
            title: 'Left',
          );
        }
      },
    );

    isLeaving.value = false;
  }

  void _updateChallengeJoinedState(String challengeId, bool joined) {
    final idx = activeChallenges.indexWhere((c) => c.id == challengeId);
    if (idx != -1) {
      activeChallenges[idx] = activeChallenges[idx].copyWith(isJoined: joined);
      activeChallenges.refresh();
    }
  }

  // ============================================
  // MY CHALLENGES
  // ============================================

  Future<void> loadMyCompletedChallenges() async {
    isLoadingMyChallenges.value = true;
    final result = await _repository.getMyCompletedChallenges();
    result.fold(
      (error) {},
      (data) => completedChallenges.value = data,
    );
    isLoadingMyChallenges.value = false;
  }

  // ============================================
  // CLEANUP
  // ============================================

  void clearDetail() {
    selectedChallenge.value = null;
    leaderboard.clear();
    myRank.value = null;
  }
}
