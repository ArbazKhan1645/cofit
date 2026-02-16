import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/repositories/achievement_repository.dart';

class ProgressController extends BaseController {
  final _storage = GetStorage();
  final AchievementRepository _achievementRepo = AchievementRepository();

  // Stats
  final RxInt totalWorkouts = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxInt totalMinutes = 0.obs;
  final RxInt totalCalories = 0.obs;

  // Achievements
  final RxList<AchievementModel> allAchievements = <AchievementModel>[].obs;
  final RxList<UserAchievementModel> userAchievements =
      <UserAchievementModel>[].obs;
  final RxBool isLoadingAchievements = false.obs;

  // Workout dates for calendar
  final RxList<DateTime> workoutDates = <DateTime>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadAchievements();
    loadWorkoutHistory();
  }

  void loadStats() {
    totalWorkouts.value = _storage.read<int>('totalWorkouts') ?? 24;
    currentStreak.value = _storage.read<int>('currentStreak') ?? 5;
    longestStreak.value = _storage.read<int>('longestStreak') ?? 12;
    totalMinutes.value = _storage.read<int>('totalMinutes') ?? 720;
    totalCalories.value = _storage.read<int>('totalCalories') ?? 4800;
  }

  Future<void> loadAchievements() async {
    isLoadingAchievements.value = true;

    final results = await Future.wait([
      _achievementRepo.getActiveAchievements(),
      _achievementRepo.getMyAchievements(),
    ]);

    results[0].fold(
      (error) {},
      (data) => allAchievements.value = data as List<AchievementModel>,
    );

    results[1].fold(
      (error) {},
      (data) => userAchievements.value = data as List<UserAchievementModel>,
    );

    isLoadingAchievements.value = false;
  }

  /// Sorted display list: in-progress first (by % desc), completed, then locked
  List<_AchievementDisplay> get sortedDisplayItems {
    final items = <_AchievementDisplay>[];

    for (final achievement in allAchievements) {
      final userProgress = userAchievements.firstWhereOrNull(
        (ua) => ua.achievementId == achievement.id,
      );
      items.add(_AchievementDisplay(
        achievement: achievement,
        userProgress: userProgress,
      ));
    }

    // Sort: in-progress (by % desc) → completed (by date desc) → locked (by sortOrder)
    items.sort((a, b) {
      if (a.isInProgress && !b.isInProgress) return -1;
      if (!a.isInProgress && b.isInProgress) return 1;
      if (a.isInProgress && b.isInProgress) {
        return b.progressPercentage.compareTo(a.progressPercentage);
      }
      if (a.isCompleted && !b.isCompleted) return -1;
      if (!a.isCompleted && b.isCompleted) return 1;
      if (a.isCompleted && b.isCompleted) {
        final aDate = a.userProgress?.completedAt ?? DateTime(2000);
        final bDate = b.userProgress?.completedAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      }
      return a.achievement.sortOrder.compareTo(b.achievement.sortOrder);
    });

    return items;
  }

  int get completedCount =>
      userAchievements.where((ua) => ua.isCompleted).length;

  void loadWorkoutHistory() {
    // Mock workout dates for the last 30 days
    final now = DateTime.now();
    workoutDates.value = [
      now.subtract(const Duration(days: 1)),
      now.subtract(const Duration(days: 2)),
      now.subtract(const Duration(days: 4)),
      now.subtract(const Duration(days: 5)),
      now.subtract(const Duration(days: 6)),
      now.subtract(const Duration(days: 8)),
      now.subtract(const Duration(days: 9)),
      now.subtract(const Duration(days: 11)),
      now.subtract(const Duration(days: 12)),
      now.subtract(const Duration(days: 15)),
    ];
  }

  String getMotivationalMessage() {
    if (currentStreak.value >= 7) {
      return "You're on fire! ${currentStreak.value} days strong!";
    } else if (currentStreak.value >= 3) {
      return "Great momentum! Keep it up!";
    } else if (totalWorkouts.value > 0) {
      return "Every workout counts. You've got this!";
    } else {
      return "Ready to start your fitness journey?";
    }
  }
}

class _AchievementDisplay {
  final AchievementModel achievement;
  final UserAchievementModel? userProgress;

  const _AchievementDisplay({
    required this.achievement,
    this.userProgress,
  });

  bool get isCompleted => userProgress?.isCompleted ?? false;
  bool get isInProgress =>
      userProgress != null &&
      !userProgress!.isCompleted &&
      userProgress!.currentProgress > 0;
  bool get isLocked => userProgress == null || userProgress!.currentProgress == 0;

  double get progressPercentage {
    if (userProgress == null) return 0.0;
    final target = achievement.targetValue;
    if (target <= 0) return 0.0;
    return (userProgress!.currentProgress / target).clamp(0.0, 1.0);
  }
}
