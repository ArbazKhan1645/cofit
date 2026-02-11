import 'package:get/get.dart';
import 'app_routes.dart';

// Onboarding
import '../../features/onboarding/views/splash_screen.dart';
import '../../features/onboarding/views/intro_screen.dart';
import '../../features/onboarding/views/sign_in_screen.dart';
import '../../features/onboarding/views/sign_up_screen.dart';
import '../../features/onboarding/views/subscription_screen.dart';
import '../../features/onboarding/views/journal_prompts_screen.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';

// Main Navigation
import '../../features/home/views/main_navigation_screen.dart';
import '../../features/home/bindings/home_binding.dart';

// Workouts
import '../../features/workouts/views/workout_detail_screen.dart';
import '../../features/workouts/views/trainer_profile_screen.dart';

// Notifications
import '../../features/notifications/views/notifications_screen.dart';

class AppPages {
  AppPages._();

  static final pages = [
    // Onboarding
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      binding: SubscriptionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.journalPrompts,
      page: () => const JournalPromptsScreen(),
      binding: JournalBinding(),
      transition: Transition.rightToLeft,
    ),

    // Main App
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigationScreen(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),

    // Workout Detail
    GetPage(
      name: AppRoutes.workoutDetail,
      page: () => const WorkoutDetailScreen(),
      transition: Transition.rightToLeft,
    ),

    // Trainer Profile
    GetPage(
      name: AppRoutes.trainer,
      page: () => const TrainerProfileScreen(),
      transition: Transition.rightToLeft,
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
