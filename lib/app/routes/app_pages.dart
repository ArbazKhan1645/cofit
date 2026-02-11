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

// Profile
import '../../features/profile/views/edit_profile_screen.dart';
import '../../features/profile/views/settings_screen.dart';
import '../../features/profile/views/help_support_screen.dart';
import '../../features/profile/views/about_screen.dart';
import '../../features/profile/controllers/edit_profile_controller.dart';
import '../../features/profile/controllers/settings_controller.dart';

// Admin Modules
import '../../admin_modules/admin_home_screen.dart';
import '../../admin_modules/trainers/trainer_controller.dart';
import '../../admin_modules/trainers/trainer_list_screen.dart';
import '../../admin_modules/trainers/trainer_form_screen.dart';
import '../../admin_modules/challanges/challange_controller.dart';
import '../../admin_modules/challanges/challange_list_screen.dart';
import '../../admin_modules/challanges/challange_form_screen.dart';
import '../../admin_modules/workouts/workout_controller.dart';
import '../../admin_modules/workouts/workout_list_screen.dart';
import '../../admin_modules/workouts/workout_form_screen.dart';

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

    // Profile
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EditProfileController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => const HelpSupportScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutScreen(),
      transition: Transition.rightToLeft,
    ),

    // Admin Modules
    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminTrainerList,
      page: () => const TrainerListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TrainerController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminTrainerForm,
      page: () => const TrainerFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminChallangeList,
      page: () => const ChallangeListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChallangeController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminChallangeForm,
      page: () => const ChallangeFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminWorkoutList,
      page: () => const WorkoutListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdminWorkoutController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminWorkoutForm,
      page: () => const WorkoutFormScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
