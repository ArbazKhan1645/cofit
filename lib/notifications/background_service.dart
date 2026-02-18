// ============================================================
// background_notification_service.dart
// Background calculations se triggered notifications
// Workmanager ya flutter_background_service se call hota hai
// Streak check, goal progress, rest day detection, weekly reports
// ============================================================

import 'dart:developer' as developer;

import 'package:cofit_collective/notifications/local_service.dart';
import 'package:cofit_collective/notifications/types.dart';

class BackgroundNotificationService {
  BackgroundNotificationService._internal();
  static final BackgroundNotificationService _instance =
      BackgroundNotificationService._internal();
  factory BackgroundNotificationService() => _instance;

  final LocalNotificationService _localService = LocalNotificationService();

  // ============================================================
  // STREAK MONITORING
  // Background mein chalega - user ke workout data check karega
  // ============================================================

  /// Workmanager periodic task mein call karo - din mein 2-3 baar
  Future<void> checkAndNotifyStreak({
    required int currentStreak,
    required DateTime? lastWorkoutDate,
    required bool userHasWorkedOutToday,
  }) async {
    if (userHasWorkedOutToday) return; // Pehle se workout ho gayi - no warning

    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final hoursLeft = endOfDay.difference(now).inHours;

    // Sirf tab notify karo jab streak meaningful ho aur time kam ho
    if (currentStreak < 2) return; // 1-2 din ki streak mein warning nahi

    if (hoursLeft <= 1 || hoursLeft <= 3 || hoursLeft <= 8) {
      await _localService.showStreakWarning(
        currentStreak: currentStreak,
        hoursLeft: hoursLeft,
      );
      developer.log(
        'Streak warning shown: $currentStreak days, $hoursLeft hours left',
        name: 'BackgroundService',
      );
    }
  }

  // ============================================================
  // DAILY GOAL PROGRESS
  // Din mein ek baar evening ko check karo
  // ============================================================

  Future<void> checkAndNotifyGoalProgress({
    required String goalType, // 'steps', 'calories', 'workout_minutes'
    required int currentValue,
    required int targetValue,
    required bool alreadyNotifiedToday,
  }) async {
    if (alreadyNotifiedToday) return;

    final percentComplete = ((currentValue / targetValue) * 100)
        .clamp(0, 100)
        .toInt();
    final remaining = (targetValue - currentValue).clamp(0, targetValue);

    String unit;
    switch (goalType) {
      case 'steps':
        unit = 'steps';
        break;
      case 'calories':
        unit = 'calories';
        break;
      case 'workout_minutes':
        unit = 'minutes';
        break;
      default:
        unit = goalType;
    }

    // Sirf meaningful times par notify karo
    if (percentComplete < 100) {
      await _localService.showGoalProgress(
        percentComplete: percentComplete,
        goalType: goalType,
        remaining: remaining,
        unit: unit,
      );
    }
  }

  // ============================================================
  // REST DAY DETECTION
  // Consecutive workout days count karo
  // ============================================================

  Future<void> checkAndNotifyRestDay({
    required int consecutiveWorkoutDays,
    required List<String> recentMuscleGroups,
  }) async {
    // 5+ consecutive days k baad rest suggest karo
    if (consecutiveWorkoutDays >= 5) {
      final muscleGroup = recentMuscleGroups.isNotEmpty
          ? recentMuscleGroups.join(', ')
          : null;

      await _localService.showRestDayRecommendation(
        consecutiveDays: consecutiveWorkoutDays,
        muscleGroupWorked: muscleGroup,
      );
    }
  }

  // ============================================================
  // WEEKLY PROGRESS REPORT
  // Har Sunday ko run karo
  // ============================================================

  Future<void> generateAndShowWeeklyReport({
    required List<Map<String, dynamic>> weekWorkouts,
    required List<Map<String, dynamic>> previousWeekWorkouts,
  }) async {
    if (weekWorkouts.isEmpty) return;

    final thisWeekStats = _calculateWeekStats(weekWorkouts);
    final lastWeekStats = _calculateWeekStats(previousWeekWorkouts);

    double improvement = 0;
    if (lastWeekStats['total_minutes']! > 0) {
      improvement =
          ((thisWeekStats['total_minutes']! - lastWeekStats['total_minutes']!) /
              lastWeekStats['total_minutes']!) *
          100;
    }

    await _localService.showWeeklyProgressUpdate(
      workoutsCompleted: thisWeekStats['count']!.toInt(),
      totalMinutes: thisWeekStats['total_minutes']!.toInt(),
      caloriesBurned: thisWeekStats['total_calories']!.toInt(),
      weekOverWeekImprovement: improvement,
    );

    developer.log('Weekly report sent', name: 'BackgroundService');
  }

  // ============================================================
  // MONTHLY PROGRESS REPORT
  // Har mahine ki 1 tarikh ko run karo
  // ============================================================

  Future<void> generateAndShowMonthlyReport({
    required int month,
    required int year,
    required List<Map<String, dynamic>> monthWorkouts,
  }) async {
    if (monthWorkouts.isEmpty) return;

    final stats = _calculateMonthStats(monthWorkouts);

    await _localService.showMonthlyProgressUpdate(
      month: month,
      year: year,
      stats: stats,
    );
  }

  // ============================================================
  // SMART NOTIFICATION SCHEDULING
  // User ke patterns dekh kar optimal time schedule karo
  // ============================================================

  /// User ke past workout times analyze karo aur optimal reminder time nikalo
  Future<void> scheduleSmartWorkoutReminders({
    required List<DateTime> pastWorkoutTimes,
    required Map<String, dynamic> userPreferences,
  }) async {
    if (pastWorkoutTimes.isEmpty) return;

    // User ke most common workout hours find karo
    final hourFrequency = <int, int>{};
    for (final time in pastWorkoutTimes) {
      hourFrequency[time.hour] = (hourFrequency[time.hour] ?? 0) + 1;
    }

    // Most frequent hour
    final sortedHours = hourFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedHours.isNotEmpty) {
      final optimalHour = sortedHours.first.key;

      // 30 min pehle reminder schedule karo
      final reminderHour = optimalHour > 0 ? optimalHour - 1 : 0;
      final reminderMinute = optimalHour > 0 ? 30 : 0;

      await _localService.scheduleDailyGoalReminder(
        hour: reminderHour,
        minute: reminderMinute,
      );

      developer.log(
        'Smart reminder scheduled at $reminderHour:$reminderMinute (optimal workout hour: $optimalHour)',
        name: 'BackgroundService',
      );
    }
  }

  // ============================================================
  // INACTIVITY DETECTION
  // Agar user ne kaafi dino se app nahi kholi
  // ============================================================

  Future<void> checkInactivityAndNotify({
    required DateTime lastAppOpenDate,
    required int currentStreak,
  }) async {
    final daysSinceLastOpen = DateTime.now().difference(lastAppOpenDate).inDays;

    if (daysSinceLastOpen >= 3 && daysSinceLastOpen < 7) {
      await _localService.showImmediate(
        id: 9001,
        payload: NotificationPayload(
          title: '👋 Hum miss kar rahe hain tumhe!',
          body:
              '$daysSinceLastOpen din ho gaye hain. ${currentStreak > 0 ? "$currentStreak din ki streak bacha lo!" : "Wapas aao aur apna fitness journey jaari rakho!"}',
          channel: NotificationChannel.workoutReminder,
          actionRoute: '/home',
        ),
      );
    } else if (daysSinceLastOpen >= 7) {
      await _localService.showImmediate(
        id: 9002,
        payload: const NotificationPayload(
          title: '💪 Ek hafte ho gaya!',
          body:
              'Tumhari fitness journey tumhara wait kar rahi hai. Sirf 10 minute ka workout bhi count karta hai - shuru karo!',
          channel: NotificationChannel.workoutReminder,
          actionRoute: '/workout/quick-start',
        ),
      );
    }
  }

  // ============================================================
  // PRIVATE CALCULATION HELPERS
  // ============================================================

  Map<String, double> _calculateWeekStats(List<Map<String, dynamic>> workouts) {
    double totalMinutes = 0;
    double totalCalories = 0;

    for (final workout in workouts) {
      totalMinutes += (workout['duration_minutes'] as num?)?.toDouble() ?? 0;
      totalCalories += (workout['calories_burned'] as num?)?.toDouble() ?? 0;
    }

    return {
      'count': workouts.length.toDouble(),
      'total_minutes': totalMinutes,
      'total_calories': totalCalories,
    };
  }

  Map<String, dynamic> _calculateMonthStats(
    List<Map<String, dynamic>> workouts,
  ) {
    int totalMinutes = 0;
    int totalCalories = 0;
    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    // Sort by date
    final sorted = List<Map<String, dynamic>>.from(workouts)
      ..sort(
        (a, b) => DateTime.parse(
          a['date'] as String,
        ).compareTo(DateTime.parse(b['date'] as String)),
      );

    for (final workout in sorted) {
      totalMinutes += (workout['duration_minutes'] as num?)?.toInt() ?? 0;
      totalCalories += (workout['calories_burned'] as num?)?.toInt() ?? 0;

      final date = DateTime.parse(workout['date'] as String);
      if (lastDate != null && date.difference(lastDate!).inDays == 1) {
        currentStreak++;
        bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
      } else {
        currentStreak = 1;
      }
      lastDate = date;
    }

    return {
      'total_workouts': workouts.length,
      'total_minutes': totalMinutes,
      'total_calories': totalCalories,
      'best_streak': bestStreak,
    };
  }
}
