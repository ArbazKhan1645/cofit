import 'package:cofit_collective/core/services/feed_cache_service.dart';
import 'package:cofit_collective/core/services/media/media_service.dart';
import 'package:cofit_collective/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/progress_service.dart';
import '../../home/controllers/home_controller.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();
  late AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Splash animation delay
    await Future.delayed(const Duration(seconds: 2));

    // 🔹 Device & UI setup
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 🔹 Local storage
    await GetStorage.init();

    // 🔹 Services init
    await _initServices();

    // 🔹 Navigation logic
    _navigateToNextScreen();
  }

  Future<void> _initServices() async {
    await Get.putAsync<SupabaseService>(
      () => SupabaseService().init(),
      permanent: true,
    );

    _authService = await Get.putAsync<AuthService>(
      () => AuthService().init(),
      permanent: true,
    );

    await Get.putAsync<FeedCacheService>(
      () => FeedCacheService().init(),
      permanent: true,
    );

    await Get.putAsync<MediaService>(
      () => MediaService().init(),
      permanent: true,
    );
  }

  Future<void> _navigateToNextScreen() async {
    final hasSeenIntro = _storage.read<bool>('hasSeenIntro') ?? false;

    if (!hasSeenIntro) {
      Get.offAllNamed(AppRoutes.intro);
      return;
    }

    if (!_authService.isAuthenticated) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }

    if (!_authService.hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.journalPrompts);
      return;
    }

    if (!_authService.hasActiveSubscription) {
      Get.offAllNamed(AppRoutes.subscription);
      return;
    }

    // 1. ProgressService MUST be created permanent + initialized BEFORE HomeController
    //    so HomeController.onInit() reads real DB data (not zeros).
    if (!Get.isRegistered<ProgressService>()) {
      Get.put<ProgressService>(ProgressService(), permanent: true);
    }
    await Get.find<ProgressService>().init();

    // 2. Now create HomeController — it will read from the initialized ProgressService
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(), permanent: true);
    }

    Get.offAllNamed(AppRoutes.main);
  }
}
