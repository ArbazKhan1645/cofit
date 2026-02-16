import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../home/controllers/home_controller.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    // Wait for auth service to initialize
    while (!_authService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Check if user has seen intro
    final hasSeenIntro = _storage.read<bool>('hasSeenIntro') ?? false;

    // Flow:
    // 1. Not seen intro → Intro screens
    // 2. Not authenticated → Sign In
    // 3. Authenticated but onboarding not complete → Journal Prompts
    // 4. Authenticated + onboarding complete but no subscription → Subscription
    // 5. Authenticated + onboarding complete + subscribed → Main

    if (!hasSeenIntro) {
      Get.offAllNamed(AppRoutes.intro);
      return;
    }

    if (!_authService.isAuthenticated) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }

    // User is authenticated - check onboarding status
    if (!_authService.hasCompletedOnboarding) {
      Get.offAllNamed(AppRoutes.journalPrompts);
      return;
    }

    // Onboarding complete - check subscription
    if (!_authService.hasActiveSubscription) {
      Get.offAllNamed(AppRoutes.subscription);
      return;
    }

    // Everything complete - pre-load home data then go to main app
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(), permanent: true);
    }
    Get.offAllNamed(AppRoutes.main);
  }
}
