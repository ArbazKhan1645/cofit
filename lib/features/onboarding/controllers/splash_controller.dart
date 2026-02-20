import 'package:cofit_collective/core/services/achievement_cache_service.dart';
import 'package:cofit_collective/core/services/auth_service.dart';
import 'package:cofit_collective/core/services/challenge_cache_service.dart';
import 'package:cofit_collective/core/services/diet_plan_cache_service.dart';
import 'package:cofit_collective/core/services/feed_cache_service.dart';
import 'package:cofit_collective/core/services/media/media_service.dart';
import 'package:cofit_collective/core/services/progress_cache_service.dart';
import 'package:cofit_collective/core/services/progress_service.dart';
import 'package:cofit_collective/core/services/workout_cache_service.dart';
import 'package:cofit_collective/core/services/supabase_service.dart';
import 'package:cofit_collective/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 🔹 Splash animation + sari services parallel mai load karo
    // User splash dekhta rahega, Firebase/Supabase/Auth sab background mai ready hongi
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)), // splash animation
      _initCoreServices(),
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 🔹 Navigation logic — sab services ready hain ab
    await _navigateToNextScreen();
  }

  /// Core + secondary services — splash ke dauran sab load hongi
  Future<void> _initCoreServices() async {
    // 1️⃣ Firebase — Supabase se independent hai
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 2️⃣ Supabase (Firebase ke saath parallel nahi — order matters for stability)
    await Get.putAsync<SupabaseService>(
      () => SupabaseService().init(),
      permanent: true,
    );

    // 3️⃣ Auth Service (Supabase ke baad)
    await Get.putAsync<AuthService>(() => AuthService().init(), permanent: true);

    // 4️⃣ Secondary services — Auth ke baad parallel load
    await Future.wait([
      Get.putAsync<FeedCacheService>(
        () => FeedCacheService().init(),
        permanent: true,
      ),
      Get.putAsync<DietPlanCacheService>(
        () => DietPlanCacheService().init(),
        permanent: true,
      ),
      Get.putAsync<ProgressCacheService>(
        () => ProgressCacheService().init(),
        permanent: true,
      ),
      Get.putAsync<WorkoutCacheService>(
        () => WorkoutCacheService().init(),
        permanent: true,
      ),
      Get.putAsync<ChallengeCacheService>(
        () => ChallengeCacheService().init(),
        permanent: true,
      ),
      Get.putAsync<AchievementCacheService>(
        () => AchievementCacheService().init(),
        permanent: true,
      ),
      Get.putAsync<MediaService>(
        () => MediaService().init(),
        permanent: true,
      ),
    ]);
  }

  Future<void> _navigateToNextScreen() async {
    final authService = Get.find<AuthService>();
    final hasSeenIntro = _storage.read<bool>('hasSeenIntro') ?? false;

    // 1. Navigation flow - check if user needs onboarding/auth first
    if (!hasSeenIntro) {
      Get.offAllNamed(AppRoutes.intro);
      return;
    }
    if (!authService.isAuthenticated) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }

    // Ban check — if user is banned, sign out and show message
    if (authService.currentUser?.isBanned == true) {
      await authService.signOut();
      Get.offAllNamed(AppRoutes.signIn);
      Get.snackbar(
        'Account Banned',
        'Your account has been banned. Contact support for help.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!authService.hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.journalPrompts);
      return;
    }

    // 2. User is authenticated & ready - initialize services + load home data
    if (!Get.isRegistered<ProgressService>()) {
      Get.put<ProgressService>(ProgressService(), permanent: true);
    }
    await Get.find<ProgressService>().init();

    await Get.put<HomeController>(
      HomeController(),
      permanent: true,
    ).oninitialized();
    if (!authService.hasActiveSubscription) {
      Get.offAllNamed(AppRoutes.subscription);
      return;
    }

    Get.offAllNamed(AppRoutes.main);
  }
}
