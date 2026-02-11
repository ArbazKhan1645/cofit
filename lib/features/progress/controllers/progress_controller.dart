import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../data/mock/mock_data.dart';

class ProgressController extends BaseController {
  final _storage = GetStorage();

  // Stats
  final RxInt totalWorkouts = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxInt totalMinutes = 0.obs;
  final RxInt totalCalories = 0.obs;

  // Badges
  final RxList<MockBadge> badges = <MockBadge>[].obs;
  final RxList<MockBadge> unlockedBadges = <MockBadge>[].obs;

  // Workout dates for calendar
  final RxList<DateTime> workoutDates = <DateTime>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadBadges();
    loadWorkoutHistory();
  }

  void loadStats() {
    totalWorkouts.value = _storage.read<int>('totalWorkouts') ?? 24;
    currentStreak.value = _storage.read<int>('currentStreak') ?? 5;
    longestStreak.value = _storage.read<int>('longestStreak') ?? 12;
    totalMinutes.value = _storage.read<int>('totalMinutes') ?? 720;
    totalCalories.value = _storage.read<int>('totalCalories') ?? 4800;
  }

  void loadBadges() {
    badges.value = MockData.getMockBadges();
    unlockedBadges.value = badges.where((b) => b.isUnlocked).toList();
  }

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
