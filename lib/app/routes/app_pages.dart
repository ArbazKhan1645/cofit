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
import '../../features/workouts/controllers/workout_detail_controller.dart';
import '../../features/workouts/views/workout_player_screen.dart';
import '../../features/workouts/controllers/workout_player_controller.dart';
import '../../features/workouts/views/trainer_profile_screen.dart';
import '../../features/workouts/views/saved_workouts_screen.dart';
import '../../features/workouts/views/workout_library_screen.dart';

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
import '../../admin_modules/dashboard/admin_dashboard_controller.dart';
import '../../admin_modules/trainers/trainer_controller.dart';
import '../../admin_modules/trainers/trainer_list_screen.dart';
import '../../admin_modules/trainers/trainer_form_screen.dart';
import '../../admin_modules/challanges/challange_controller.dart';
import '../../admin_modules/challanges/challange_list_screen.dart';
import '../../admin_modules/challanges/challange_form_screen.dart';
import '../../admin_modules/challanges/challange_detail_screen.dart';
import '../../features/challenges/controllers/challenge_controller.dart';
import '../../features/challenges/views/challenges_screen.dart';
import '../../features/challenges/views/challenge_detail_screen.dart';
import '../../admin_modules/workouts/workout_controller.dart';
import '../../admin_modules/workouts/workout_list_screen.dart';
import '../../admin_modules/workouts/workout_form_screen.dart';
import '../../admin_modules/workouts/workout_view_screen.dart';
import '../../admin_modules/weekly_schedule/weekly_schedule_controller.dart';
import '../../admin_modules/weekly_schedule/weekly_schedule_screen.dart';
import '../../admin_modules/daily_plan/daily_plan_controller.dart';
import '../../admin_modules/daily_plan/daily_plan_screen.dart';
import '../../admin_modules/users/users_controller.dart';
import '../../admin_modules/users/user_list_screen.dart';
import '../../admin_modules/users/user_detail_screen.dart';
import '../../admin_modules/community/community_controller.dart';
import '../../admin_modules/community/community_dashboard_screen.dart';
import '../../admin_modules/community/admin_posts_screen.dart';
import '../../admin_modules/support/admin_support_controller.dart';
import '../../admin_modules/support/admin_ticket_list_screen.dart';
import '../../admin_modules/support/admin_ticket_chat_screen.dart';
import '../../features/achievements/views/achievements_screen.dart';
import '../../admin_modules/achievements/achievement_controller.dart';
import '../../admin_modules/achievements/achievement_list_screen.dart';
import '../../admin_modules/achievements/achievement_form_screen.dart';
import '../../admin_modules/achievements/achievement_detail_screen.dart';
import '../../features/support/support_controller.dart';
import '../../features/support/ticket_list_screen.dart';
import '../../features/support/ticket_chat_screen.dart';

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
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WorkoutDetailController());
      }),
      transition: Transition.rightToLeft,
    ),

    // Workout Player
    GetPage(
      name: AppRoutes.workoutPlayer,
      page: () => const WorkoutPlayerScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WorkoutPlayerController());
      }),
      transition: Transition.fadeIn,
    ),

    // Trainer Profile
    GetPage(
      name: AppRoutes.trainer,
      page: () => const TrainerProfileScreen(),
      transition: Transition.rightToLeft,
    ),

    // Saved Workouts
    GetPage(
      name: AppRoutes.savedWorkouts,
      page: () => const SavedWorkoutsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Workout Library
    GetPage(
      name: AppRoutes.workoutLibrary,
      page: () => const WorkoutLibraryScreen(),
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
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdminDashboardController());
      }),
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
      name: AppRoutes.adminChallangeDetail,
      page: () => const ChallangeDetailScreen(),
      transition: Transition.rightToLeft,
    ),

    // User-side Challenges
    GetPage(
      name: AppRoutes.challenges,
      page: () => const ChallengesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChallengeController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.challengeDetail,
      page: () => const ChallengeDetailScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ChallengeController>()) {
          Get.lazyPut(() => ChallengeController());
        }
        // Load detail from arguments if provided
        final challengeId = Get.arguments as String?;
        if (challengeId != null) {
          Get.find<ChallengeController>().loadChallengeDetail(challengeId);
        }
      }),
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
    GetPage(
      name: AppRoutes.adminWorkoutView,
      page: () => const WorkoutViewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminWeeklySchedule,
      page: () => const WeeklyScheduleScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WeeklyScheduleController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminDailyPlan,
      page: () => const DailyPlanScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DailyPlanController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminUserList,
      page: () => const UserListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdminUsersController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminUserDetail,
      page: () => const UserDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminCommunity,
      page: () => const CommunityDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdminCommunityController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminPostsList,
      page: () => const AdminPostsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminSupport,
      page: () => const AdminTicketListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AdminSupportController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminTicketChat,
      page: () => const AdminTicketChatScreen(),
      transition: Transition.rightToLeft,
    ),

    // User Achievements
    GetPage(
      name: AppRoutes.achievements,
      page: () => const AchievementsScreen(),
      transition: Transition.rightToLeft,
    ),

    // Admin Achievements
    GetPage(
      name: AppRoutes.adminAchievementList,
      page: () => const AchievementListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AchievementController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminAchievementForm,
      page: () => const AchievementFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminAchievementDetail,
      page: () => const AchievementDetailScreen(),
      transition: Transition.rightToLeft,
    ),

    // User Support
    GetPage(
      name: AppRoutes.supportTickets,
      page: () => const TicketListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SupportController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.supportChat,
      page: () => const TicketChatScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
