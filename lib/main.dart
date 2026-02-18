import 'package:cofit_collective/core/services/auth_service.dart';
import 'package:cofit_collective/core/services/feed_cache_service.dart';
import 'package:cofit_collective/core/services/media/media_service.dart';
import 'package:cofit_collective/core/services/supabase_service.dart';
import 'package:cofit_collective/firebase_options.dart';
import 'package:cofit_collective/notifications/background_service.dart';
import 'package:cofit_collective/notifications/local_service.dart';
import 'package:cofit_collective/notifications/service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Local Storage — sabse pehle (baaki services ispe depend karti hain)
  await GetStorage.init();

  // 2️⃣ Firebase initialize
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3️⃣ Supabase initialize (auth aur DB ke liye zaroori)
  await Get.putAsync<SupabaseService>(
    () => SupabaseService().init(),
    permanent: true,
  );

  // 4️⃣ Auth Service (Supabase ke baad)
  await Get.putAsync<AuthService>(() => AuthService().init(), permanent: true);

  // 5️⃣ Notification Service (Firebase ke baad)
  await NotificationService().initialize(
    onNavigate: (route) {
      print('device notification route is $route');
    },
    onFcmTokenReceived: (token) async {
      final authService = Get.find<AuthService>();
      await authService.updateProfile(fcm_token: token);
      print('device token is $token');
    },
  );

  // 6️⃣ Feed Cache & Media Services
  await Get.putAsync<FeedCacheService>(
    () => FeedCacheService().init(),
    permanent: true,
  );
  await Get.putAsync<MediaService>(
    () => MediaService().init(),
    permanent: true,
  );

  // 7️⃣ Workmanager background tasks
  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    'streak-check',
    'streakCheckTask',
    frequency: const Duration(hours: 3),
    constraints: Constraints(networkType: NetworkType.notRequired),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  await Workmanager().registerPeriodicTask(
    'weekly-report',
    'weeklyReportTask',
    frequency: const Duration(days: 7),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  runApp(const CoFitApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Background isolate — fresh initialize karna zaroori hai
    WidgetsFlutterBinding.ensureInitialized();

    // 1️⃣ Local Storage
    await GetStorage.init();

    // 2️⃣ Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3️⃣ Supabase (background tasks mein DB access ke liye)
    await Get.putAsync<SupabaseService>(
      () => SupabaseService().init(),
      permanent: true,
    );

    // 4️⃣ Local Notifications
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

Future<void> _runStreakCheck(BackgroundNotificationService bgService) async {
  try {
    // final supabase = Supabase.instance.client;
    // final userId = supabase.auth.currentUser?.id;
    // if (userId == null) return;
    //
    // final stats = await supabase
    //     .from('user_stats')
    //     .select('current_streak, last_workout_date')
    //     .eq('user_id', userId)
    //     .single();
    //
    // await bgService.checkAndNotifyStreak(
    //   currentStreak: stats['current_streak'] as int,
    //   lastWorkoutDate: DateTime.parse(stats['last_workout_date']),
    //   userHasWorkedOutToday: stats['worked_out_today'] as bool,
    // );
  } catch (e) {
    // Silently handle — background crash nahi karna
  }
}

Future<void> _runWeeklyReport(BackgroundNotificationService bgService) async {
  try {
    // final supabase = Supabase.instance.client;
    // final now = DateTime.now();
    // final weekStart = now.subtract(Duration(days: now.weekday - 1));
    // ...
    //
    // await bgService.generateAndShowWeeklyReport(
    //   weekWorkouts: [...],
    //   previousWeekWorkouts: [...],
    // );
  } catch (e) {
    // Silently handle
  }
}
