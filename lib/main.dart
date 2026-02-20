import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cofit_collective/core/services/crashlytics_service.dart';
import 'package:cofit_collective/core/services/device_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:cofit_collective/core/services/supabase_service.dart';
import 'package:cofit_collective/data/models/user_model.dart';
import 'package:cofit_collective/firebase_options.dart';
import 'package:cofit_collective/notifications/background_service.dart';
import 'package:cofit_collective/notifications/local_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'app/app.dart';

void main() async {
  // Crashlytics — puri app ko guarded zone mai run karo
  await CrashlyticsService.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();

    // 0️⃣ Environment variables load karo (secrets .env file se)
    await dotenv.load(fileName: '.env');

    // 1️⃣ Local Storage — sirf yeh zaroori hai splash se pehle
    await GetStorage.init();

    // 2️⃣ Device ID + Crashlytics device info
    await DeviceService.instance.init();
    await CrashlyticsService.instance.init();

    // ✅ App turant start — splash dikhega
    // Firebase, Supabase, Auth sab SplashController mai load hongi
    runApp(const CoFitApp());
  });
}

/// Background isolate — Workmanager tasks ke liye
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    await GetStorage.init();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Get.putAsync<SupabaseService>(
      () => SupabaseService().init(),
      permanent: true,
    );

    final localService = LocalNotificationService();
    await localService.initialize();

    final bgService = BackgroundNotificationService();

    switch (taskName) {
      case 'streakCheckTask':
        await _runStreakCheck(bgService);
        break;
      case 'weeklyReportTask':
        await _runWeeklyReport(bgService);
        break;
    }

    return true;
  });
}

// ============================================================
// HELPER — Background isolate mein userId aur cached user data
// ============================================================

/// GetStorage se cached user read karo (AuthService ne save kiya tha)
UserModel? _getCachedUser() {
  try {
    final cached = GetStorage().read<String>('cached_current_user');
    if (cached == null) return null;
    return UserModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

/// Background mein userId resolve karo — Supabase session + GetStorage fallback
String? _resolveUserId() {
  // 1. Supabase session se (auto-restored from disk)
  final supabaseUserId = SupabaseService.to.userId;
  if (supabaseUserId != null) return supabaseUserId;

  // 2. GetStorage cached user se (file-based — background isolate mein reliable)
  final cachedUser = _getCachedUser();
  return cachedUser?.id;
}

// ============================================================
// STREAK CHECK — din mein 2-3 baar chalega
// ============================================================

Future<void> _runStreakCheck(BackgroundNotificationService bgService) async {
  try {
    final supabase = SupabaseService.to;
    final userId = _resolveUserId();
    if (userId == null) {
      developer.log('Streak check skipped: no user', name: 'BackgroundTask');
      return;
    }

    // Cached user se streak data le lo (instant, no network)
    final cachedUser = _getCachedUser();

    // Fresh data try karo Supabase se — agar session valid hai
    int currentStreak;
    DateTime? lastWorkoutDate;
    bool notificationsEnabled;

    try {
      final userData = await supabase.client
          .from('users')
          .select(
            'current_streak, longest_streak, last_workout_date, notifications_enabled',
          )
          .eq('id', userId)
          .single();

      currentStreak = userData['current_streak'] as int? ?? 0;
      lastWorkoutDate = userData['last_workout_date'] != null
          ? DateTime.parse(userData['last_workout_date'] as String)
          : null;
      notificationsEnabled = userData['notifications_enabled'] as bool? ?? true;
    } catch (_) {
      // Supabase session expired — cached data use karo
      if (cachedUser == null) return;
      currentStreak = cachedUser.currentStreak;
      lastWorkoutDate = cachedUser.lastWorkoutDate;
      notificationsEnabled = cachedUser.notificationsEnabled;
    }

    if (!notificationsEnabled) return;

    // Aaj workout hui ya nahi — user_progress table se check
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    bool hasWorkedOutToday = false;
    try {
      final todayWorkouts = await supabase.client
          .from('user_progress')
          .select('id')
          .eq('user_id', userId)
          .gte('completed_at', todayStart.toIso8601String())
          .lt('completed_at', todayEnd.toIso8601String())
          .limit(1);

      hasWorkedOutToday = (todayWorkouts as List).isNotEmpty;
    } catch (_) {
      // Session expired — check from lastWorkoutDate
      if (lastWorkoutDate != null) {
        hasWorkedOutToday =
            lastWorkoutDate.year == now.year &&
            lastWorkoutDate.month == now.month &&
            lastWorkoutDate.day == now.day;
      }
    }

    // Streak warning — agar aaj workout nahi hui aur streak meaningful hai
    await bgService.checkAndNotifyStreak(
      currentStreak: currentStreak,
      lastWorkoutDate: lastWorkoutDate,
      userHasWorkedOutToday: hasWorkedOutToday,
    );

    // Inactivity check — agar kaafi din se workout nahi
    if (lastWorkoutDate != null) {
      await bgService.checkInactivityAndNotify(
        lastAppOpenDate: lastWorkoutDate,
        currentStreak: currentStreak,
      );
    }

    // Rest day check — agar lagatar 5+ din workout ho rahi hai
    if (hasWorkedOutToday && currentStreak >= 5) {
      try {
        final recentWorkouts = await supabase.client
            .from('user_progress')
            .select('workouts(category)')
            .eq('user_id', userId)
            .order('completed_at', ascending: false)
            .limit(5);

        final muscleGroups = (recentWorkouts as List)
            .map((w) => (w['workouts'] as Map?)?['category'] as String?)
            .whereType<String>()
            .toList();

        await bgService.checkAndNotifyRestDay(
          consecutiveWorkoutDays: currentStreak,
          recentMuscleGroups: muscleGroups,
        );
      } catch (_) {
        // Muscle groups na mile toh bhi rest day suggest karo
        await bgService.checkAndNotifyRestDay(
          consecutiveWorkoutDays: currentStreak,
          recentMuscleGroups: [],
        );
      }
    }

    developer.log(
      'Streak check done: streak=$currentStreak, workedOutToday=$hasWorkedOutToday',
      name: 'BackgroundTask',
    );
  } catch (e) {
    developer.log('Streak check error: $e', name: 'BackgroundTask');
  }
}

// ============================================================
// WEEKLY REPORT — har hafte chalega
// ============================================================

Future<void> _runWeeklyReport(BackgroundNotificationService bgService) async {
  try {
    final supabase = SupabaseService.to;
    final userId = _resolveUserId();
    if (userId == null) {
      developer.log('Weekly report skipped: no user', name: 'BackgroundTask');
      return;
    }

    // Notification preference — cached se check karo pehle
    final cachedUser = _getCachedUser();
    bool notificationsEnabled = cachedUser?.notificationsEnabled ?? true;

    try {
      final userData = await supabase.client
          .from('users')
          .select('notifications_enabled')
          .eq('id', userId)
          .single();
      notificationsEnabled = userData['notifications_enabled'] as bool? ?? true;
    } catch (_) {
      // Cached value use karo
    }

    if (!notificationsEnabled) return;

    final now = DateTime.now();

    // This week: Monday se aaj tak
    final thisWeekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    // Last week
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    // This week ke workouts
    final thisWeekWorkouts = await supabase.client
        .from('user_progress')
        .select('duration_minutes, calories_burned, completed_at')
        .eq('user_id', userId)
        .gte('completed_at', thisWeekStart.toIso8601String())
        .order('completed_at');

    // Last week ke workouts
    final lastWeekWorkouts = await supabase.client
        .from('user_progress')
        .select('duration_minutes, calories_burned, completed_at')
        .eq('user_id', userId)
        .gte('completed_at', lastWeekStart.toIso8601String())
        .lt('completed_at', thisWeekStart.toIso8601String())
        .order('completed_at');

    // Weekly report generate karo
    await bgService.generateAndShowWeeklyReport(
      weekWorkouts: List<Map<String, dynamic>>.from(thisWeekWorkouts as List),
      previousWeekWorkouts: List<Map<String, dynamic>>.from(
        lastWeekWorkouts as List,
      ),
    );

    // Monthly report — sirf mahine ki 1 tarikh ko
    if (now.day == 1) {
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
      final lastMonthStart = DateTime(lastMonthYear, lastMonth, 1);
      final thisMonthStart = DateTime(now.year, now.month, 1);

      final monthWorkouts = await supabase.client
          .from('user_progress')
          .select('duration_minutes, calories_burned, completed_at')
          .eq('user_id', userId)
          .gte('completed_at', lastMonthStart.toIso8601String())
          .lt('completed_at', thisMonthStart.toIso8601String())
          .order('completed_at');

      await bgService.generateAndShowMonthlyReport(
        month: lastMonth,
        year: lastMonthYear,
        monthWorkouts: List<Map<String, dynamic>>.from(monthWorkouts as List),
      );
    }

    developer.log('Weekly report done', name: 'BackgroundTask');
  } catch (e) {
    developer.log('Weekly report error: $e', name: 'BackgroundTask');
  }
}
