abstract class AppRoutes {
  AppRoutes._();

  // Onboarding Routes
  static const splash = '/splash';
  static const intro = '/intro';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const journalPrompts = '/journal-prompts';
  static const promptResult = '/prompt-result';
  static const subscription = '/subscription';

  // Main App Routes
  static const main = '/main';
  static const home = '/home';

  // Workout Routes
  static const workouts = '/workouts';
  static const workoutDetail = '/workout-detail';
  static const workoutPlayer = '/workout-player';
  static const workoutLibrary = '/workout-library';
  static const savedWorkouts = '/saved-workouts';
  static const trainerProfile = '/trainer-profile';

  // Progress Routes
  static const progress = '/progress';
  static const badges = '/badges';
  static const achievements = '/achievements';
  static const workoutHistory = '/workout-history';

  // Community Routes
  static const community = '/community';
  static const challenges = '/challenges';
  static const challengeDetail = '/challenge-detail';
  static const recipes = '/recipes';
  static const recipeDetail = '/recipe-detail';
  static const createPost = '/create-post';

  // Profile Routes
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const journalEntries = '/journal-entries';
  static const settings = '/settings';
  static const subscriptionManagement = '/subscription-management';

  // Other Routes
  static const notifications = '/notifications';
  static const trainer = '/trainer';
  static const helpSupport = '/help-support';
  static const about = '/about';

  // Admin Routes
  static const adminHome = '/admin';
  static const adminChallangeList = '/admin/challanges';
  static const adminChallangeForm = '/admin/challanges/form';
  static const adminChallangeDetail = '/admin/challanges/detail';
  static const adminTrainerList = '/admin/trainers';
  static const adminTrainerForm = '/admin/trainers/form';
  static const adminWorkoutList = '/admin/workouts';
  static const adminWorkoutForm = '/admin/workouts/form';
  static const adminWorkoutView = '/admin/workouts/view';
  static const adminWeeklySchedule = '/admin/weekly-schedule';
  static const adminDailyPlan = '/admin/daily-plan';
  static const adminUserList = '/admin/users';
  static const adminUserDetail = '/admin/users/detail';
  static const adminCommunity = '/admin/community';
  static const adminPostsList = '/admin/community/posts';
  static const adminSupport = '/admin/support';
  static const adminTicketChat = '/admin/support/chat';
  static const adminAchievementList = '/admin/achievements';
  static const adminAchievementForm = '/admin/achievements/form';
  static const adminAchievementDetail = '/admin/achievements/detail';

  // Support (User)
  static const supportTickets = '/support';
  static const supportChat = '/support/chat';
}
