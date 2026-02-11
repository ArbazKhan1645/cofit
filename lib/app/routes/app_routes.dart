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
  static const trainerProfile = '/trainer-profile';

  // Progress Routes
  static const progress = '/progress';
  static const badges = '/badges';
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
}
