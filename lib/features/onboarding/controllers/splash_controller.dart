import 'package:cofit_collective/core/services/auth_service.dart';
import 'package:cofit_collective/core/services/progress_service.dart';
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

    // 🔹 Navigation logic (services already initialized in main.dart)
    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final authService = Get.find<AuthService>();
    final hasSeenIntro = _storage.read<bool>('hasSeenIntro') ?? false;

    // 1. ProgressService initialize
    if (!Get.isRegistered<ProgressService>()) {
      Get.put<ProgressService>(ProgressService(), permanent: true);
    }
    await Get.find<ProgressService>().init();

    // 2. HomeController initialize
    await Get.put<HomeController>(
      HomeController(),
      permanent: true,
    ).oninitialized();

    // 3. Navigation flow
    if (!hasSeenIntro) {
      Get.offAllNamed(AppRoutes.intro);
      return;
    }
    if (!authService.isAuthenticated) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }
    if (!authService.hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.journalPrompts);
      return;
    }
    if (!authService.hasActiveSubscription) {
      Get.offAllNamed(AppRoutes.subscription);
      return;
    }
    Get.offAllNamed(AppRoutes.main);
  }
}
