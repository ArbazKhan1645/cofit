import 'package:cofit_collective/core/services/crashlytics_service.dart';
import 'package:cofit_collective/core/services/supabase_service.dart';
import 'package:cofit_collective/firebase_options.dart';
import 'package:cofit_collective/notifications/background_service.dart';
import 'package:cofit_collective/notifications/local_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'app/app.dart';

void main() async {
  // Crashlytics — puri app ko guarded zone mai run karo
  await CrashlyticsService.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1️⃣ Local Storage — sirf yeh zaroori hai splash se pehle
    await GetStorage.init();

    // 2️⃣ Crashlytics device info (no dependencies)
    CrashlyticsService.instance.init();

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

Future<void> _runStreakCheck(BackgroundNotificationService bgService) async {
  try {
    // TODO: implement streak check
  } catch (e) {
    // Silently handle
  }
}

Future<void> _runWeeklyReport(BackgroundNotificationService bgService) async {
  try {
    // TODO: implement weekly report
  } catch (e) {
    // Silently handle
  }
}
